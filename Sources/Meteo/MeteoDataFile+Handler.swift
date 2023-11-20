// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import SolarPosition
import Foundation
import Helpers

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
    if !💾.fileExists(atPath: path) {
      throw MeteoDataFileError.fileNotFound(path)
    }

    // Initialize the URL with the provided path.
    url = URL(fileURLWithPath: path)

    // If the URL represents a directory, find the meteorological data file (either .mto or .TMY).
    if url.hasDirectoryPath {
      guard let fileName = try 💾.contentsOfDirectory(atPath: path).first(
        where: { $0.hasSuffix("mto") || $0.hasPrefix("TMY") }) else {
          throw MeteoDataFileError.fileNotFound(path)
      }
      // Append the found file name to the URL to complete the file path.
      url.appendPathComponent(fileName)
    }
    // Print the path of the meteorological data file being used.
    print("Meteo file in use:\n  \(url.path)\n")

    // Create the appropriate MeteoDataFile instance based on the file extension.
    self.file = try url.pathExtension.lowercased() == "mto" ? MET(url) : TMY(url)
    try file.checkForConsistence()
  }

  /// Retrieve metadata from the meteorological data file.
  ///
  /// - Returns: A tuple containing the year and location information.
  /// - Throws: An error if there's an issue with fetching the metadata.
  public func metadata() throws -> (year: Int, location: Location)  { 
    try file.fetchInfo()
  }

  /// Retrieve meteorological data values with the specified number of values per hour.
  ///
  /// - Parameter valuesPerHour: The number of values required per hour for interpolation.
  /// - Returns: An array of `MeteoData` containing the meteorological data.
  /// - Throws: An error if there's an issue with fetching the data.
  public func data(valuesPerHour: Int) throws -> [MeteoData] {
    // Fetch raw data from the meteorological data file.
    let data = try file.fetchData()

    // Calculate the number of steps to interpolate the data based on valuesPerHour.
    var hours = data.count.quotientAndRemainder(dividingBy: 8760)
    if hours.remainder > 0 {
      hours = data.count.quotientAndRemainder(dividingBy: 8760 + hours.remainder)
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
      return interpolated.dropFirst(half).dropLast(half+1)
    } else {
      // If interpolation is disabled, repeat each data point according to the calculated steps.
      return data.reduce(into: []) { $0 += repeatElement($1, count: steps) }
    }
  }
}

public enum MeteoDataFileError: Error {
  case fileNotFound(String)
  case missingValueInLine(Int)
  case unexpectedRowCount, empty, unknownLocation, unknownDelimeter, missingHeaders
}

/// A protocol representing a meteorological data file.
protocol MeteoDataFile {
  /// The name of the meteorological data file.
  var name: String { get }
  
  /// Fetches metadata from the meteorological data file.
  ///
  /// - Returns: A tuple containing the year and location information.
  /// - Throws: An error if there's an issue with fetching the metadata.
  func fetchInfo() throws -> (year: Int, location: Location)
  
  /// Fetches meteorological data from the file.
  ///
  /// - Returns: An array of `MeteoData` containing the meteorological data.
  /// - Throws: An error if there's an issue with fetching the data.
  func fetchData() throws -> [MeteoData]
}

extension MeteoDataFile {
  func checkForConsistence() throws {
    let y = try fetchInfo().year
    let isLeapYear = (y >= 1582 && y % 4 == 0 && y % 100 != 0 || y % 400 == 0);
    let hasLeapDay = try fetchData().count.quotientAndRemainder(dividingBy: 365).remainder > 0
    if isLeapYear != hasLeapDay { throw MeteoDataFileError.unexpectedRowCount }
  }
}

private struct MET: MeteoDataFile {
  let name: String
  let metadata: [String]
  let csv: CSVReader
  let order: [Int?]

  init(_ url: URL) throws {
    let fileHandle = try FileHandle(forReadingFrom: url)
    let data = try fileHandle.readToEnd()
    try fileHandle.close()
    guard let data = data else { throw MeteoDataFileError.empty }
    self.name = url.lastPathComponent

    let newLine = UInt8(ascii: "\n")
    let cr = UInt8(ascii: "\r")
    let separator = UInt8(ascii: ",")

    guard let firstNewLine = data.firstIndex(of: newLine) else {
      throw MeteoDataFileError.empty
    }

    guard let _ = data.firstIndex(of: separator) else {
      throw MeteoDataFileError.unknownDelimeter
    }

    let hasCR = data[data.index(before: firstNewLine)] == cr

    let lines = data.split(separator: newLine, maxSplits: 10,
                              omittingEmptySubsequences: false)
    guard lines.endIndex > 10 else { throw MeteoDataFileError.empty }
    self.metadata = lines[0..<10].map { line in
      let line = hasCR ? line.dropLast() : line
      return String(decoding: line.filter { $0 > separator }, as: UTF8.self)
    }
    guard let header = String(data: lines[8], encoding: .utf8) else {
      throw MeteoDataFileError.missingHeaders
    }

    let lc = header.split(separator: ",").map { $0.lowercased() }
    self.order = [
      lc.firstIndex { $0.contains("dni") || (!$0.contains("wind") && $0.contains("dir")) },
      lc.firstIndex { $0.contains("temp") || $0.contains("tamb") },
      lc.firstIndex { $0.contains("ws") || ($0.contains("wind") && !$0.contains("dir")) },
      lc.firstIndex { $0.contains("ghi") || $0.contains("glo") },
      lc.firstIndex { $0.contains("dhi") || $0.contains("dif") },
    ]
    guard let csv = CSVReader(data: lines[10], separator: ",")
    else { throw MeteoDataFileError.empty }
    self.csv = csv
  }

  func fetchInfo() throws -> (year: Int, location: Location) {
    guard let year = Int(metadata[1])
    else { throw MeteoDataFileError.empty }

    guard let longitude = Double(metadata[2]),
          let latitude = Double(metadata[3]),
          let lat_tz = Int(metadata[4])
    else { throw MeteoDataFileError.unknownLocation }

    let timezone = -lat_tz / 15
    let location = Location(
      (-longitude, latitude, 0), tz: timezone
    )
    return (year, location)
  }

  func fetchData() throws -> [MeteoData] {
    // Check whether the dataRange matches one year of values.
    let div = csv.dataRows.count.quotientAndRemainder(dividingBy: 24)
    guard div.remainder == 0, case 365...366 = div.quotient
      else { throw MeteoDataFileError.unexpectedRowCount }
    let lastIndex = order.reduce(0, { max($0, $1 ?? 0) })
    return try zip(csv.dataRows, 11...).map { values, line in
      guard values.endIndex > lastIndex else {
        throw MeteoDataFileError.missingValueInLine(line)
      }
      return MeteoData(values, order: order)
    }
  }
}

extension MeteoDataFileError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .unexpectedRowCount:
      return "Meteo file does not have enough values for one year."
    case let .missingValueInLine(line):
      return "Meteo file error. Format in line \(line) is invalid."
    case let .fileNotFound(path):
      return "Meteo file not found at: \(path)"
    case .unknownLocation:
      return "Meteo file does not contain a location."
    case .unknownDelimeter:
      return "Meteo file unknown delimeter for values."
    case .empty:
      return "Meteo file does not contain data."
    case .missingHeaders:
      return "Meteo file does not contain headers."
    }
  }
}

private struct TMY: MeteoDataFile {
  let name: String
  let metadata: [Double]
  let csv: CSVReader

  init(_ url: URL) throws {
    let fileHandle = try FileHandle(forReadingFrom: url)
    let data = try fileHandle.readToEnd()
    try fileHandle.close()
    guard let data = data else { throw MeteoDataFileError.empty }
    self.name = url.lastPathComponent

    let newLine = UInt8(ascii: "\n")
    let separator = UInt8(ascii: ",")

    guard let _ = data.firstIndex(of: newLine) else {
      throw MeteoDataFileError.empty
    }

    guard let _ = data.firstIndex(of: separator) else {
      throw MeteoDataFileError.unknownDelimeter
    }

    let lines = data.split(separator: newLine, maxSplits: 1)
    guard lines.endIndex > 1,
          let metadata = CSVReader(data: lines[0])?.dataRows[0],
          let csv = CSVReader(data: lines[1])
    else { throw MeteoDataFileError.empty }
    self.metadata = metadata
    self.csv = csv
  }

  func fetchLocation() throws -> Location {
    let values = metadata
    guard values.endIndex > 3
    else { throw MeteoDataFileError.unknownLocation }
    let longitude = values[2]
    let latitude = values[1]
    let elevation = values[3]
    let tz = fetchTimeZone()
    return Location(
      (longitude,  latitude,  elevation), tz: tz
    )
  }

  func fetchTimeZone() -> Int {
    let tz = metadata.first ?? 0
    return Int(-tz)
  }

  func fetchYear() -> Int { 2011 }

  func fetchInfo() throws -> (year: Int, location: Location) {
    var location = try fetchLocation()
    location.timezone = fetchTimeZone()
    return (fetchYear(), location)
  }

  func fetchData() throws -> [MeteoData] {
    let dataRange = csv.dataRows
    // Check whether the dataRange matches one year of values.
    let div = dataRange.count.quotientAndRemainder(dividingBy: 24)
    guard div.remainder == 0, case 365...366 = div.quotient
    else { throw MeteoDataFileError.unexpectedRowCount }

    var order = [Int](repeating: 0, count: 5)
    for (name, pos) in zip(csv.headerRow!, 0...) {
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
    return try zip(csv.dataRows, 3...).map { data, line in
      guard data.endIndex > last else {
        throw MeteoDataFileError.missingValueInLine(line)
      }
      return MeteoData(data, order: order)
    }
  }
}
