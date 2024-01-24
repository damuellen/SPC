// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import DateExtensions
import Foundation
import Helpers
import SolarPosition

/// Handles the import of files with meteorological data.
public class MeteoDataFileHandler {

  /// FileManager instance for file operations.
  let 💾 = FileManager.default

  /// URL of the meteorological data file.
  public private(set) var url: URL

  /// Flag indicating whether interpolation is enabled or not.
  public var interpolation = true

  /// The meteorological data file being used.
  private let file: MeteoDataFile

  /// Initializes the MeteoDataFileHandler for reading data from the file at the given path.
  ///
  /// - Parameter path: The file path to read meteorological data from.
  /// - Throws: An error if the file is not found or there's an issue with reading it.
  public init(forReadingAtPath path: String) throws {

    // Check if the file exists at the specified path.
    if !💾.fileExists(atPath: path) { throw MeteoFileError.fileNotFound(path) }

    // Initialize the URL with the provided path.
    url = URL(fileURLWithPath: path)

    // If the URL represents a directory, find the meteorological data file (either .mto or .TMY).
    if url.hasDirectoryPath {
      print("Search for meteo file in directory:\n  \(path)\n")
      guard let fileName = try 💾.contentsOfDirectory(atPath: path).first(where: {
            $0.lowercased().hasSuffix("mto") || $0.hasPrefix("TMY")
          })
      else { throw MeteoFileError.fileNotFound(path) }
      // Append the found file name to the URL to complete the file path.
      url.appendPathComponent(fileName)
    }
    // Create the appropriate MeteoDataFile instance based on the file extension.
    let data = try? Data(contentsOf: url, options: [.mappedIfSafe])
    guard let data = data else { throw MeteoFileError.empty }
    print("Meteo file in use:\n\(url.path)")
    self.file = try url.pathExtension.lowercased() == "mto" ? MET(data) : TMY(data)
    try file.checkForConsistence()
    // Print the path of the meteorological data file being used.
  }

  /// Retrieve information from the meteorological data file.
  ///
  /// - Returns: A tuple containing the year and location information.
  public func info() -> (year: Int, location: Location) {
    (file.year, file.location)
  }

  /// Retrieve meteorological data values with the specified number of values per hour.
  ///
  /// - Parameter valuesPerHour: The number of values required per hour for interpolation.
  /// - Returns: An array of `MeteoData` containing the meteorological data.
  /// - Throws: An error if there's an issue with fetching the data.
  public func data(valuesPerHour: Int) -> [MeteoData] {
    // Fetch raw data from the meteorological data file.
    let data = file.data

    // Calculate the number of steps to interpolate the data based on valuesPerHour.
    var hours = data.count.quotientAndRemainder(dividingBy: 8760)
    if hours.remainder > 0 {
      hours = data.count.quotientAndRemainder(
        dividingBy: 8760 + hours.remainder)
    }
    var steps = valuesPerHour / hours.quotient

    // If no interpolation is needed, return the raw data as is.
    if steps == 1 { return data }

    // If interpolation is enabled, perform interpolation on the data.
    if interpolation {
      // Calculate the half of the steps for interpolation.
      let half = steps / 2
      steps -= 1
      // Wrap the data array to simplify the interpolation process.
      let wrapped = [data.last!] + data + [data.first!]
      // Interpolate the data using the wrapped array and the calculated steps.
      let interpolated = wrapped.interpolate(steps: steps)
      // Drop the first and last half of the interpolated data to remove unnecessary points.
      return interpolated.dropFirst(half).dropLast(half + 1)
    } else {
      // If interpolation is disabled, repeat each data point according to the calculated steps.
      return data.reduce(into: []) { $0 += repeatElement($1, count: steps) }
    }
  }
}

public enum MeteoFileError: Error {
  case fileNotFound(String)
  case missingValueInLine(Int)
  case unexpectedRowCount, empty, unknownLocation, unknownDelimeter,
    missingHeaders
}

/// A protocol representing a meteorological data file.
protocol MeteoDataFile {
  /// The year of the meteorological data.
  var year: Int { get }
  
  /// The location associated with the meteorological data.
  var location: Location { get }
  
  /// The array of `MeteoData` containing meteorological data values.
  var data: [MeteoData] { get }

  /// Checks the consistency of the meteorological data, throwing an error if inconsistencies are found.
  func checkForConsistence() throws
}

extension MeteoDataFile {
  func checkForConsistence() throws {
    let y = year
    let isLeapYear = (y >= 1582 && y % 4 == 0 && y % 100 != 0 || y % 400 == 0)
    let hasLeapDay =
      data.count.quotientAndRemainder(dividingBy: 366).remainder == 0
    if isLeapYear, !hasLeapDay { throw MeteoFileError.unexpectedRowCount }
  }
}

private struct MET: MeteoDataFile {
  var year: Int
  var location: Location
  var data: [MeteoData]

  init(_ data: Data) throws {
    let newLine = UInt8(ascii: "\n")
    let cr = UInt8(ascii: "\r")
    let separator = UInt8(ascii: ",")

    guard let firstNewLine = data.firstIndex(of: newLine) else {
      throw MeteoFileError.empty
    }

    guard let _ = data.firstIndex(of: separator) else {
      throw MeteoFileError.unknownDelimeter
    }

    let hasCR = data[data.index(before: firstNewLine)] == cr

    let lines = data.split(
      separator: newLine, maxSplits: 10, omittingEmptySubsequences: false)
    guard lines.endIndex > 10 else { throw MeteoFileError.empty }
    let metadata = lines[0..<10]
      .map { line in
        let line = hasCR ? line.dropLast() : line
        return String(decoding: line.filter { $0 > separator }, as: UTF8.self)
      }

    guard let year = Int(metadata[1]) else { throw MeteoFileError.empty }
    print("Description:", metadata[0])
    self.year = year
    print("Year: \(year)")
    guard var longitude = Double(metadata[2]),
      let latitude = Double(metadata[3]), let lat_tz = Int(metadata[4])
    else { throw MeteoFileError.unknownLocation }
    longitude *= -1 // The sign of the longitude must be swapped
    let timezone = -lat_tz / 15
    self.location = Location((longitude, latitude, 0), tz: timezone)
    print("Location longitude: \(longitude) latitude: \(latitude)")
    print("https://www.osmap.uk/#7/\(latitude)/\(longitude)")

    if let tz = TimeZone(location) {
      #if os(Windows)
        let offset = Int(-tz.secondsFromGMT(for: DateInterval(ofYear: year).start) / 3600)
      #else
        let offset = Int(tz.secondsFromGMT(for: DateInterval(ofYear: year).start) / 3600)
      #endif
      print("Offset meteo file: GMT\(timezone > -1 ? "+" : "")\(timezone)")
      if offset != timezone {
        print("Time zone set: GMT\(offset > -1 ? "+" : "")\(offset) \(tz)")
        self.location.timezone = Int(offset)
      }
    }
    
    guard let header = String(data: lines[8], encoding: .utf8) else {
      throw MeteoFileError.missingHeaders
    }

    let lc = header.split(separator: ",").map { $0.lowercased() }
    var order = [
      lc.firstIndex {
        $0.contains("dni") || (!$0.contains("wind") && $0.contains("dir"))
      }, lc.firstIndex { $0.contains("temp") || $0.contains("tamb") },
      lc.firstIndex {
        $0.contains("ws") || ($0.contains("wind") && !$0.contains("dir"))
      }, lc.firstIndex { $0.contains("ghi") || $0.contains("glo") },
      lc.firstIndex { $0.contains("dhi") || $0.contains("dif") },
    ]
    guard let csv = CSVReader(data: lines[10], separator: ",") else {
      throw MeteoFileError.empty
    }

    // Check whether the dataRange matches one year of values.
    let div = csv.dataRows.count.quotientAndRemainder(dividingBy: 24)
    guard div.remainder == 0 else { throw MeteoFileError.unexpectedRowCount }
    if div.quotient % 366 == 0 {
      let x = div.quotient / 366
      print("Meteo data read for leap year. \(x>1 ? "\(x) values":"One value") per hour.") 
    } else {
      let x = div.quotient / 365
      print("Meteo data read for year. \(x>1 ? "\(x) values":"One value") per hour.")
    }
    if order[0] == nil {
      print("Meteo file without header row. Use default order.")
      order = [3,4,5,nil,nil]
    }
    let lastIndex = order.reduce(0, { max($0, $1 ?? 0) })
    self.data = try zip(csv.dataRows, 11...)
      .map { values, line in
        guard values.endIndex > lastIndex else {
          throw MeteoFileError.missingValueInLine(line)
        }
        return MeteoData(values, order: order)
      }
  }
}

extension MeteoFileError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .unexpectedRowCount:
      return "Meteo file does not have enough values for one year."
    case let .missingValueInLine(line):
      return "Meteo file error. Format in line \(line) is invalid."
    case let .fileNotFound(path): return "Meteo file not found at: \(path)"
    case .unknownLocation: return "Meteo file does not contain a location."
    case .unknownDelimeter: return "Meteo file unknown delimeter for values."
    case .empty: return "Meteo file does not contain data."
    case .missingHeaders: return "Meteo file does not contain headers."
    }
  }
}

private struct TMY: MeteoDataFile {
  var year: Int
  var location: Location
  var data: [MeteoData]

  init(_ data: Data) throws {
    let newLine = UInt8(ascii: "\n")
    let separator = UInt8(ascii: ",")

    guard let _ = data.firstIndex(of: newLine) else {
      throw MeteoFileError.empty
    }

    guard let _ = data.firstIndex(of: separator) else {
      throw MeteoFileError.unknownDelimeter
    }

    let lines = data.split(separator: newLine, maxSplits: 1)
    guard lines.endIndex > 1, let header = CSVReader(data: lines[0]),
      let values = CSVReader(data: lines[1])
    else { throw MeteoFileError.empty }
    self.year = 2011

    guard header.dataRows[0].endIndex > 3 else {
      throw MeteoFileError.unknownLocation
    }
    let longitude = header.dataRows[0][2]
    let latitude = header.dataRows[0][1]
    let elevation = header.dataRows[0][3]
    let tz = Int(-header.dataRows[0][0])
    self.location = Location((longitude, latitude, elevation), tz: tz)

    // Check whether the dataRange matches one year of values.
    let div = values.dataRows.count.quotientAndRemainder(dividingBy: 24)
    guard div.remainder == 0 else { throw MeteoFileError.unexpectedRowCount }

    var order = [Int](repeating: 0, count: 5)
    for (name, pos) in zip(values.headerRow!, 0...) {
      switch name {
      case "DNI(W/m^2)": order[0] = pos
      case "Dry-bulb(C)": order[1] = pos
      case "Wspd(m/s)": order[2] = pos
      case "GHI(W/m^2)": order[3] = pos
      case "DHI(W/m^2)": order[4] = pos
      default: break
      }
    }

    let last = Set(order).max()!
    self.data = try zip(values.dataRows, 3...)
      .map { data, line in
        guard data.endIndex > last else {
          throw MeteoFileError.missingValueInLine(line)
        }
        return MeteoData(data, order: order)
      }
  }
}
