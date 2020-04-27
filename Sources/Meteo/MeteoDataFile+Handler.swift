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
    let 💾 = FileManager.default
    
    if !💾.fileExists(atPath: path) {
      throw MeteoDataFileError.fileNotFound(path)
    }

    var url = URL(fileURLWithPath: path)
    
    if url.hasDirectoryPath {
      if let fileName = try 💾.contentsOfDirectory(atPath: path).first(where:
        { item in item.hasSuffix("mto") || item.hasPrefix("TMY") } )
      {
        url.appendPathComponent(fileName)
      } else {
        throw MeteoDataFileError.fileNotFound(path)
      }
    }
    print("Meteo file in use: \(url.path)\n")
    self.file = try url.pathExtension == "mto" ? MET(url) : TMY(url)
  }

  public func callAsFunction() throws -> MeteoDataSource {
    let metaData = try file.fetchInfo()
    let data = try file.fetchData()
    return MeteoDataSource(name: file.name, data: data, metaData)
  }
}

public enum MeteoDataFileError: Error {
  case fileNotFound(String), lineMissingValue(Int)
  case unexpectedRowCount, empty, startNotFound,
  unknownLocation, unknownDelimeter
}

protocol MeteoDataFile {
  var name: String { get }
  func fetchInfo() throws -> (year: Int, location: Location)
  func fetchData() throws -> [MeteoData]
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
        // Outter array
        return content.split(separator: newLine).map { line in
          // Inner array
          return line.dropLast().split(separator: separator).map { slice in
            return String(decoding: UnsafeRawBufferPointer(rebasing: slice),
                          as: UTF8.self)
          }          
        }
      }
    } else {
      self.content = rawData.withUnsafeBytes { content in
        // Outter array
        return content.split(separator: newLine).map { line in
          // Inner array
          return line.split(separator: separator).map { slice in
            return String(decoding: UnsafeRawBufferPointer(rebasing: slice),
                          as: UTF8.self)
          }
        }
      }
    }
  }

  func fetchInfo() throws -> (year: Int, location: Location) {
    var metaData = content.dropFirst().prefix(4)

    guard let y = metaData.popFirst()?.first, let year = Int(y)
      else { throw MeteoDataFileError.empty }

    guard let long = metaData.popFirst()?.first,
      let lat = metaData.popFirst()?.first,
      let longitude = Float(long), let latitude = Float(lat)
      else { throw MeteoDataFileError.unknownLocation }

    let location = Location(
      longitude: -longitude, latitude: latitude, elevation: 0
    )

    return (year, location)
  }

  func fetchData() throws -> [MeteoData] {
    let prefix = "1"

    guard let startIndex = content.firstIndex(where: 
      { $0.first?.hasPrefix(prefix) ?? false }
    )
    else { throw MeteoDataFileError.startNotFound }

    let dataRange = startIndex ..< content.endIndex
    // Check whether the dataRange matches one year of values.
    guard dataRange.count.isMultiple(of: 8760)
    //  || dataRange.count.isMultiple(of: 8764)
    else { throw MeteoDataFileError.unexpectedRowCount }
    var line = startIndex + 1
    
    return try content[dataRange].indices.map { idx in
      let values = content[idx].dropFirst(3).compactMap(Float.init)

      guard values.count > 2
      else { throw MeteoDataFileError.lineMissingValue(line) }
      line += 1
      return MeteoData(values)
    }
  }
}

extension MeteoDataFileError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .unexpectedRowCount:
      return "Meteo file does not have enough values for one year."
    case let .lineMissingValue(row):
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

private struct TMY: MeteoDataFile {
  let name: String
  let content: (headers1: [Float], headers2: [String], values: [[Float]])
  
  init(_ url: URL) throws {
    let rawData = try Data(contentsOf: url)
    self.name = url.lastPathComponent
    
    let newLine = UInt8(ascii: "\n")
    let separator = UInt8(ascii: ",")
    
    guard let _  = rawData.firstIndex(of: newLine) else {
      throw MeteoDataFileError.empty
    }
    
    guard let _ = rawData.firstIndex(of: separator) else {
      throw MeteoDataFileError.unknownDelimeter
    }
    
    self.content = try rawData.withUnsafeBytes { content throws in
      let lines = content.split(separator: newLine)
      guard lines.endIndex > 2 else { throw MeteoDataFileError.empty }
      return (
        lines[0].split(separator: separator).dropFirst(3).map { slice in
            let pointer = UnsafeRawBufferPointer(rebasing: slice)
              .baseAddress!.assumingMemoryBound(to: Int8.self)
            return strtof(pointer, nil)
        },
        lines[1].split(separator: separator).dropFirst(2).map { slice in
          return String(decoding: UnsafeRawBufferPointer(rebasing: slice),
                        as: UTF8.self)
        },
        lines[2...].map { line in
          line.split(separator: separator).dropFirst(2).map { slice in
            let pointer = UnsafeRawBufferPointer(rebasing: slice)
              .baseAddress!.assumingMemoryBound(to: Int8.self)
            return strtof(pointer, nil)
          }
        }
      )
    }
  }

  func fetchLocation() throws -> Location {
    let values = content.headers1
    guard values.endIndex > 3
      else { throw MeteoDataFileError.unknownLocation }
    let longitude = values[2]
    let latitude = values[1]
    let elevation = values[3]
    return Location(
      longitude: longitude, latitude: latitude, elevation: elevation
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

    if Set(order).count < 5 {
      throw MeteoDataFileError.startNotFound
    }
    let last = Set(order).max()!
    return try zip(dataRange, 3...).map { data, line in
      guard data.endIndex > last else {
        throw MeteoDataFileError.lineMissingValue(line)
      }
      return MeteoData(tmy: data, order: order)
    }
  }
}
