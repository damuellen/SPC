//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation

public struct MeteoDataFileHandler {
  private var filePath: String

  public init(forReadingAtPath path: String) throws {
    if FileManager.default.fileExists(atPath: path) == false {
      throw MeteoDataFileError.fileNotFound(path)
    }
    self.filePath = path
  }

  public func makeDataSource() throws -> MeteoDataSource {
    let string = try String(contentsOfFile: filePath, encoding: .ascii)
    let file: MeteoDataFile

    if self.filePath.hasSuffix("csv") {
      file = TMY(string)
    } else {
      file = MET(string)
    }

    let data = try file.fetchData()
    let location = try file.fetchLocation()
    let year = file.fetchYear()
    let timeZone = file.fetchTimeZone()

    return MeteoDataSource(
      name: String(self.filePath.split(separator: "/").last!),
      data: data,
      location: location,
      year: year,
      timeZone: timeZone
    )
  }
}

enum MeteoDataFileError: Error {
  case fileNotFound(String), rowNotReadable(String)
  case unexpectedRowCount, startOfYearNotFound,
    unknownLocation, unknownDelimeter, empty
}

protocol MeteoDataFile {
  func fetchLocation() throws -> Position
  func fetchData() throws -> [MeteoData]
  func fetchYear() -> Int
  func fetchTimeZone() -> Int
}

private struct MET: MeteoDataFile {
  let content: [String]

  init(_ string: String) {
    let separator: Character = string.contains("\r\n") ? "\r\n" : "\n"
    content = string.split(separator: separator).map(String.init)
  }

  func fetchTimeZone() -> Int {
    guard let longitude = Int(content[4].withoutWhitespaces) else { return 0 }
    return longitude / 15
  }

  func fetchLocation() throws -> Position {
    let values = Array(content[2 ... 3])
    
    guard let longitude = Float(values[0].withoutWhitespaces),
      let latitude = Float(values[1].withoutWhitespaces)
    else { throw MeteoDataFileError.unknownLocation }

    return Position(
      longitude: -longitude, latitude: latitude, elevation: 0
    )
  }

  func fetchYear() -> Int {
    return Int(self.content[1]) ?? 1970
  }

  func fetchData() throws -> [MeteoData] {
    guard let endOfFile = content.last
    else { throw MeteoDataFileError.empty }

    let separator: Character

    if endOfFile.contains("\t") { separator = "\t" }
    else if endOfFile.contains(",") { separator = "," }
    else { throw MeteoDataFileError.unknownDelimeter }

    let prefix = ["1", "0", "0"].joined(separator: String(separator))

    guard let startIndex = content.index(where: { $0.hasPrefix(prefix) })
    else { throw MeteoDataFileError.startOfYearNotFound }

    let dataRange = startIndex ..< content.endIndex
    // Check whether the dataRange matches one year of hourly values.
    guard dataRange.count == 8760 || dataRange.count == 8784
      || dataRange.count == 8760 * 4 || dataRange.count == 8784
    else { throw MeteoDataFileError.unexpectedRowCount }

    return try self.content[dataRange].compactMap { line in
      let stringValues = line.split(separator: separator)[3...]

      let floatValues = stringValues.map(String.init)
        .map({ $0.withoutWhitespaces })
        .compactMap(Float.init)

      guard stringValues.count == floatValues.count
      else { throw MeteoDataFileError.rowNotReadable(line) }

      return MeteoData(floatValues)
    }
  }
}

extension MeteoDataFileError: LocalizedError {
  private var errorDescription: String {
    switch self {
    case .unexpectedRowCount:
      return "Meteofile is not in hourly periods."
    case let .rowNotReadable(row):
      return "Meteofile format of line is wrong: \(row)"
    case let .fileNotFound(path):
      return "Meteofile not found at \(path)"
    case .unknownLocation:
      return "Meteofile does not contain any location."
    case .startOfYearNotFound:
      return "Meteofile format is unknown."
    case .unknownDelimeter:
      return "Meteofile unknown delimeter for values."
    case .empty:
      return "Meteofile is empty."
    }
  }
}

extension String {
  var withoutWhitespaces: String {
    return trimmingCharacters(in: .whitespaces)
  }
}

extension Float {
  init?<S: StringProtocol>(_ optionalDecimalValue: S?) {
    guard let string = optionalDecimalValue else { return nil }
    self.init(string)
  }
}

private struct TMY: MeteoDataFile {
  let content: [String]

  init(_ string: String) {
    let separator: Character = string.contains("\r\n") ? "\r\n" : "\n"
    content = string.split(separator: separator).map(String.init)
  }

  func fetchLocation() throws -> Position {
    let values = Array(content[..<3])
    guard let longitude = Float(values[1].split(separator: " ").last),
      let latitude = Float(values[0].split(separator: " ").last),
      let elevation = Float(values[2].split(separator: " ").last)
    else { throw MeteoDataFileError.unknownLocation }
    return Position(
      longitude: longitude, latitude: latitude, elevation: elevation
    )
  }

  func fetchTimeZone() -> Int {
    guard let longitude = Float(content[1].split(separator: " ").last)
      else { return 0 }
    return Int(longitude / 15)
  }

  func fetchYear() -> Int {
    return 1970
  }

  func fetchData() throws -> [MeteoData] {
    guard let endOfFile = content.last
    else { throw MeteoDataFileError.empty }

    let separator: Character

    if endOfFile.contains("\t") { separator = "\t" }
    else if endOfFile.contains(",") { separator = "," }
    else { throw MeteoDataFileError.unknownDelimeter }

    let dataRange = 17 ..< content.endIndex
    // Check whether the dataRange matches one year of hourly values.
    guard dataRange.count == 8760 || dataRange.count == 8784
      || dataRange.count == 8760 * 4 || dataRange.count == 8784
    else { throw MeteoDataFileError.unexpectedRowCount }

    return try self.content[dataRange].compactMap { line in
      let stringValues = line.split(separator: separator)[1...]

      let floatValues = stringValues.map(String.init)
        .map({ $0.withoutWhitespaces })
        .compactMap(Float.init)

      guard stringValues.count == floatValues.count
      else { throw MeteoDataFileError.rowNotReadable(line) }

      return MeteoData(tmy: floatValues)
    }
  }
}
