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
  
  public init(forReadingAtPath path: String)throws {
    if !FileManager.default.fileExists(atPath: path) {
      throw MeteoDataFileError.fileNotFound(path)
    }
    self.filePath = path
  }
  
  public func makeDataSource()throws -> MeteoDataSource {
    
    let string = try String(contentsOfFile: filePath, encoding: .ascii)
    let file = MeteoDataFile(string: string)
    
    let data = try file.readContentForData()
    let location = try file.readContentForLocation()
    let timeZone = file.readContentForTimeZone()
    
    
    return MeteoDataSource(
      name: String(filePath.split(separator: "/").last!),
      data: data,
      location: location,
      year: Int(file.content[1]),
      timeZone: timeZone)
  }
}

enum MeteoDataFileError: Error {
  case fileNotFound(String), rowNotReadable(String)
  case unexpectedRowCount, startOfYearNotFound,
  unknownLocation, unknownDelimeter, empty
}

private struct MeteoDataFile {
  
  let content: [String]
  
  init(string: String) {
    let separator: Character = string.contains("\r\n") ? "\r\n" : "\n"
    self.content = string.split(separator: separator).map(String.init)
  }
  
  func readContentForTimeZone() -> Int {
    guard let longitude = Int(content[4].whitespacesTrimmed) else { return 0 }
    return longitude / 15
  }
  
  func readContentForLocation()throws -> Location {
    let values = Array(content[2...3])
    guard let longitude = Double(values[0].whitespacesTrimmed),
      let latitude = Double(values[1].whitespacesTrimmed)
      else { throw MeteoDataFileError.unknownLocation }
    return Location(
      longitude: longitude, latitude: latitude, elevation: 0)
  }
  
  func readContentForData()throws -> [MeteoData] {
    
    guard let endOfFile = content.last
      else { throw MeteoDataFileError.empty }
    
    let separator: Character
    
    if endOfFile.contains("\t") { separator = "\t" }
    else if endOfFile.contains(",") { separator = "," }
    else { throw MeteoDataFileError.unknownDelimeter }
    
    let prefix = ["1","0","0"].joined(separator: String(separator))
    
    guard let startIndex = content.index(where: { $0.hasPrefix(prefix) })
      else { throw MeteoDataFileError.startOfYearNotFound }
    
    let dataRange = startIndex ..< content.endIndex
    // Check whether the dataRange matches one year of hourly values.
    guard dataRange.count == 8760 || dataRange.count == 8784
      else { throw MeteoDataFileError.unexpectedRowCount }
    
    return try content[dataRange].flatMap { line in
      let stringValues = line.split(separator: separator)[3...]
      
      let floatValues = stringValues.map(String.init)
        .map({ $0.whitespacesTrimmed })
        .flatMap(Float.init)
      
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
    case .rowNotReadable(let row):
      return "Meteofile format of line is wrong: \(row)"
    case .fileNotFound(let path):
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
  var whitespacesTrimmed: String {
    return self.trimmingCharacters(in: .whitespaces)
  }
}
