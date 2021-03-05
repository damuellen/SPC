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

  let 💾 = FileManager.default

  public let isBinaryFile: Bool

  public private(set) var url: URL

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
      isBinaryFile = false
    } else {
      let newUrl = url.deletingPathExtension().appendingPathExtension("bin")
      let path = newUrl.path
      if 💾.fileExists(atPath: path) {
        url = newUrl
        isBinaryFile = true
      } else {
        isBinaryFile = false
      }
    }
    print("Meteo file in use:\n  \(url.path)\n")
  }
  
  public func callAsFunction() throws -> MeteoDataSource {
    if isBinaryFile, let data = try? Data(contentsOf: url) {
      return MeteoDataSource(data: data)
    }

    let file: MeteoDataFile = try url.pathExtension == "mto" 
      ? MET(url) : TMY(url)
    let metaData = try file.fetchInfo()
    let data = try file.fetchData()
    return MeteoDataSource(name: file.name, data: data, metaData)
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
  let data: [[Float]]
  
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
    
    let hasCR = rawData[rawData.index(before: firstNewLine)] == cr
    
    (metadata, data) = try rawData.withUnsafeBytes { content throws in
      let lines = content.split(separator: newLine, maxSplits: 10,
                                omittingEmptySubsequences: false)
      guard lines.endIndex > 10 else { throw MeteoDataFileError.empty }
      return (
        lines[0..<10].map { line in
          let line = hasCR ? line.dropLast() : line
          let buffer = UnsafeRawBufferPointer(rebasing: line)
          return String(decoding: buffer, as: UTF8.self)
        },
        lines[10].split(separator: newLine).map { line in
          let line = hasCR ? line.dropLast() : line
          return line.split(separator: separator).dropFirst(3).map { slice in
            let buffer = UnsafeRawBufferPointer(rebasing: slice)
              .baseAddress!.assumingMemoryBound(to: Int8.self)
            return strtof(buffer, nil)
          }
        }
      )
    }
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
      (-longitude, latitude, 0), timezone: timezone
    )
    return (year, location)
  }
  
  func fetchData() throws -> [MeteoData] {
    // Check whether the dataRange matches one year of values.
    guard data.count.isMultiple(of: 8760)
    //  || dataRange.count.isMultiple(of: 8764)
    else { throw MeteoDataFileError.unexpectedRowCount }
    return try zip(data, 11...).map { values, line in
      guard values.count > 2
      else { throw MeteoDataFileError.missingValueInLine(line) }
      return MeteoData(meteo: values)
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
  let content: (headers1: [Float], headers2: [String], values: [[Float]])
  
  init(_ url: URL) throws {
    let rawData = try Data(contentsOf: url)
    self.name = url.lastPathComponent
    
    let newLine = UInt8(ascii: "\n")
    let separator = UInt8(ascii: ",")
    
    guard let _ = rawData.firstIndex(of: newLine) else {
      throw MeteoDataFileError.empty
    }
    
    guard let _ = rawData.firstIndex(of: separator) else {
      throw MeteoDataFileError.unknownDelimeter
    }
    
    content = try rawData.withUnsafeBytes { content throws in
      let lines = content.split(separator: newLine, maxSplits: 2)
      guard lines.endIndex > 2 else { throw MeteoDataFileError.empty }
      return (
        lines[0].split(separator: separator).dropFirst(3).map { slice in
          let buffer = UnsafeRawBufferPointer(rebasing: slice)
            .baseAddress!.assumingMemoryBound(to: Int8.self)
          return strtof(buffer, nil)
        },
        lines[1].split(separator: separator).dropFirst(2).map { slice in
          let buffer = UnsafeRawBufferPointer(rebasing: slice)
          return String(decoding: buffer, as: UTF8.self)
        },
        lines[2].split(separator: newLine).map { line in
          line.split(separator: separator).dropFirst(2).map { slice in
            let buffer = UnsafeRawBufferPointer(rebasing: slice)
              .baseAddress!.assumingMemoryBound(to: Int8.self)
            return strtof(buffer, nil)
          }
        }
      )
    }
  }
  
  func fetchLocation() throws -> Location {
    let values = content.headers1
    guard values.endIndex > 3
    else { throw MeteoDataFileError.unknownLocation }
    let longitude = Double(values[2])
    let latitude = Double(values[1])
    let elevation = Double(values[3])
    let tz = fetchTimeZone()
    return Location(
      (longitude,  latitude,  elevation), timezone: tz
    )
  }
  
  func fetchTimeZone() -> Int {
    let tz = content.headers1.first ?? 0
    return Int(-tz)
  }
  
  func fetchYear() -> Int { 2011 }

  func fetchInfo() throws -> (year: Int, location: Location) {
    var location = try fetchLocation()
    location.timezone = fetchTimeZone()
    return (fetchYear(), location)
  }

  func fetchData() throws -> [MeteoData] {
    let dataRange = content.values
    // Check whether the dataRange matches one year of values.
    guard dataRange.count.isMultiple(of: 8760)
    //  || dataRange.count.isMultiple(of: 8764)
    else { throw MeteoDataFileError.unexpectedRowCount }

    var order = [Int](repeating: 0, count: 5)
    for (name, pos) in zip(content.headers2, 0...) {
      switch name {
      case "DNI (W/m^2)": order[0] = pos
      case "Dry-bulb (C)": order[1] = pos
      case "Wspd (m/s)": order[2] = pos
      case "GHI (W/m^2)": order[3] = pos
      case "DHI (W/m^2)": order[4] = pos
      default: break
      }
    }

    let last = Set(order).max()!
    return try zip(dataRange, 3...).map { data, line in
      guard data.endIndex > last else {
        throw MeteoDataFileError.missingValueInLine(line)
      }
      return MeteoData(tmy: data, order: order)
    }
  }
}
