//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import SolarPosition
import Foundation
import Helpers

/// Handles the import of files with meteorological data.
public class MeteoDataFileHandler {

  let 💾 = FileManager.default

  public private(set) var url: URL

  public var interpolation = true

  private let file: MeteoDataFile

  public init(forReadingAtPath path: String) throws {

    if !💾.fileExists(atPath: path) {
      throw MeteoDataFileError.fileNotFound(path)
    }

    url = URL(fileURLWithPath: path)

    if url.hasDirectoryPath {
      guard let fileName = try 💾.contentsOfDirectory(atPath: path).first(
        where: { $0.hasSuffix("mto") || $0.hasPrefix("TMY") }) else {
          throw MeteoDataFileError.fileNotFound(path)
      }
      url.appendPathComponent(fileName)
    }
    print("Meteo file in use:\n  \(url.path)\n")
    self.file = try url.pathExtension == "mto" ? MET(url) : TMY(url)
  }

  public func metadata() throws -> (year: Int, location: Location)  { 
    try file.fetchInfo()
  }

  public func data(valuesPerHour: Int) throws -> [MeteoData] {
    let data = try file.fetchData()
    var steps = data.count / 8760
    steps = valuesPerHour / steps
    if steps == 1 { return data }
    if interpolation {
      let half = steps / 2
      steps -= 1
      let wrapped = [data.last!] + data + [data.first!]
      let interpolated = wrapped.interpolate(steps: steps)
      return interpolated.dropFirst(half).dropLast(half+1)
    } else {
      return data.reduce(into: []) { $0 += repeatElement($1, count: steps) }
    }
  }
}

public enum MeteoDataFileError: Error {
  case fileNotFound(String)
  case missingValueInLine(Int)
  case unexpectedRowCount, empty,
       unknownLocation, unknownDelimeter
}

protocol MeteoDataFile {
  var name: String { get }
  func fetchInfo() throws -> (year: Int, location: Location)
  func fetchData() throws -> [MeteoData]
}

private struct MET: MeteoDataFile {
  let name: String
  let metadata: [String]
  let csv: CSVReader

  init(_ url: URL) throws {
    let rawData = try Data(contentsOf: url, options: [.mappedIfSafe, .uncached])
    self.name = url.lastPathComponent

    let newLine = UInt8(ascii: "\n")
    let cr = UInt8(ascii: "\r")
    let separator = UInt8(ascii: ",")

    guard let firstNewLine = rawData.firstIndex(of: newLine) else {
      throw MeteoDataFileError.empty
    }

    guard let _ = rawData.firstIndex(of: separator) else {
      throw MeteoDataFileError.unknownDelimeter
    }

    let hasCR = rawData[rawData.index(before: firstNewLine)] == cr

    let lines = rawData.split(separator: newLine, maxSplits: 10,
                              omittingEmptySubsequences: false)
    guard lines.endIndex > 10 else { throw MeteoDataFileError.empty }
    self.metadata = lines[0..<10].map { line in
      let line = hasCR ? line.dropLast() : line
      return String(decoding: line.filter { $0 > separator }, as: UTF8.self)
    }
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
    guard csv.dataRows.count.isMultiple(of: 24)
    //  || dataRange.count.isMultiple(of: 8764)
    else { throw MeteoDataFileError.unexpectedRowCount }
    return try zip(csv.dataRows, 11...).map { values, line in
      guard values.count >= 6 // Day,Hour,Min,DNI,Temperature,Windspeed
      else { throw MeteoDataFileError.missingValueInLine(line) }
      return MeteoData(meteo: Array(values[3...]))
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
    }
  }
}

private struct TMY: MeteoDataFile {
  let name: String
  let metadata: [Double]
  let csv: CSVReader

  init(_ url: URL) throws {
    let rawData = try Data(contentsOf: url, options: [.mappedIfSafe, .uncached])
    self.name = url.lastPathComponent

    let newLine = UInt8(ascii: "\n")
    let separator = UInt8(ascii: ",")

    guard let _ = rawData.firstIndex(of: newLine) else {
      throw MeteoDataFileError.empty
    }

    guard let _ = rawData.firstIndex(of: separator) else {
      throw MeteoDataFileError.unknownDelimeter
    }

    let lines = rawData.split(separator: newLine, maxSplits: 1)
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
    guard dataRange.count.isMultiple(of: 8760)
    //  || dataRange.count.isMultiple(of: 8764)
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
      return MeteoData(tmy: data, order: order)
    }
  }
}
