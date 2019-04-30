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
  private var file: MeteoDataFile
  
  public init(forReadingAtPath path: String) throws {
    if FileManager.default.fileExists(atPath: path) {
      print("Meteo file found: \(path)\n")
    } else {
      throw MeteoDataFileError.fileNotFound(path)
    }
    
    if path.hasSuffix("csv") {
      self.file = try TMY(URL(fileURLWithPath: path))
    } else {
      self.file = try MET(URL(fileURLWithPath: path))
    }
  }

  public func makeDataSource() throws -> MeteoDataSource {
    let data = try file.fetchData()
    let location = try file.fetchLocation()
    let year = file.fetchYear()
    let timeZone = file.fetchTimeZone()

    return MeteoDataSource(
      name: file.name,
      data: data,
      location: location,
      year: year,
      timeZone: timeZone
    )
  }
}

public enum MeteoDataFileError: Error {
  case fileNotFound(String), lineNotReadable(Int)
  case unexpectedRowCount, empty, startNotFound,
  unknownLocation, unknownDelimeter
}

protocol MeteoDataFile {
  var name: String { get }
  func fetchLocation() throws -> Position
  func fetchData() throws -> [MeteoData]
  func fetchYear() -> Int
  func fetchTimeZone() -> Int
}

private struct MET: MeteoDataFile {
  let name: String
  let content: [[String]]
  
  init(_ url: URL) throws {
    let rawData = try Data(contentsOf: url)
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

    if rawData[rawData.index(before: firstNewLine)] == cr {
      self.content = rawData.withUnsafeBytes { content in
        return content.split(separator: newLine).map { line in
          line.dropLast().split(separator: separator).map { part in
            String(decoding: UnsafeRawBufferPointer(rebasing: part),
                   as: UTF8.self)
          }
        }
      }
    } else {
      self.content = rawData.withUnsafeBytes { content in
        return content.split(separator: newLine).map { line in
          line.split(separator: separator).map { part in
            String(decoding: UnsafeRawBufferPointer(rebasing: part),
                   as: UTF8.self)
          }
        }
      }
    }
  }

  func fetchTimeZone() -> Int {
    guard let longitude = Int(content[4][0]) else { return 0 }
    return longitude / 15
  }

  func fetchLocation() throws -> Position {
    let values = Array(content[2 ... 3])
    guard let longitude = Float(values[0][0]),
      let latitude = Float(values[1][0])
      else { throw MeteoDataFileError.unknownLocation }
    return Position(
      longitude: -longitude, latitude: latitude, elevation: 0
    )
  }

  func fetchYear() -> Int {
    return Int(self.content[1][0]) ?? 1990
  }

  func fetchData() throws -> [MeteoData] {
    let prefix = "1"

    guard let startIndex = content.firstIndex(where: { $0[0].hasPrefix(prefix) })
    else { throw MeteoDataFileError.startNotFound }

    let dataRange = startIndex ..< content.endIndex
    // Check whether the dataRange matches one year of values.
    guard dataRange.count.isMultiple(of: 8760)
    //  || dataRange.count.isMultiple(of: 8764)
    else { throw MeteoDataFileError.unexpectedRowCount }
    var line = 11
    return try content[dataRange].indices.map { idx in
      let strings = content[idx][3...]
      let numbers = strings.compactMap(Float.init)

      guard strings.count == numbers.count
      else { throw MeteoDataFileError.lineNotReadable(line) }
      line += 1
      return MeteoData(numbers)
    }
  }
}

extension MeteoDataFileError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .unexpectedRowCount:
      return "Meteo file does not have enough values for one year."
    case let .lineNotReadable(row):
      return "Meteo file error. Format in line \(row) is invalid."
    case let .fileNotFound(path):
      return "Meteo file not found at: \(path)"
    case .unknownLocation:
      return "Meteo file does not contain a location."
    case .startNotFound:
      return "Meteo file format is unknown."
    case .unknownDelimeter:
      return "Meteo file unknown delimeter for values."
    case .empty:
      return "Meteo file is empty."
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
  let name: String
  let content: [String]
  
  init(_ url: URL) throws {
    let data = try Data(contentsOf: url)
    self.name = url.lastPathComponent
    self.content = data.withUnsafeBytes {
      return $0.split(separator: UInt8(ascii: "\n")).map {
        String(decoding: UnsafeRawBufferPointer(rebasing: $0), as: UTF8.self)
      }
    }
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
    return 1990
  }

  func fetchData() throws -> [MeteoData] {
    guard let endOfFile = content.last
    else { throw MeteoDataFileError.empty }

    let separator: Character

    if endOfFile.contains("\t") { separator = "\t" }
    else if endOfFile.contains(",") { separator = "," }
    else { throw MeteoDataFileError.unknownDelimeter }

    let dataRange = 17 ..< content.endIndex
    // Check whether the dataRange matches one year of values.
    guard dataRange.count.isMultiple(of: 8760)
    //  || dataRange.count.isMultiple(of: 8764)
    else { throw MeteoDataFileError.unexpectedRowCount }
    var no = 1
    return try self.content[dataRange].compactMap { line in
      let substrings = line.split(separator: separator)[1...]
      let floats = substrings.compactMap(Float.init)

      guard substrings.count == floats.count
      else { throw MeteoDataFileError.lineNotReadable(no) }
      no += 1
      return MeteoData(tmy: floats)
    }
  }
}
