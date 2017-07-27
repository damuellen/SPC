//
//  Copyright (c) 2017 Daniel Müllenborn. All rights reserved.
//  Distributed under the The Non-Profit Open Software License version 3.0
//  http://opensource.org/licenses/NPOSL-3.0
//
//  This project is NOT free software. It is open source, you are allowed to
//  modify it (if you keep the license), but it may not be commercially
//  distributed other than under the conditions noted above.
//

public protocol TextConfigInitializable {
  init(file: TextConfigFile)throws
}

public struct TextConfigFile {
  
  public var values: [String]
  
  public var name: String {
    return values.indices.contains(6) ? values[6] : ""
  }
  
  private let path: String
  
  init(content: String, path: String) {
    self.path = path
    let separator: Character = content.contains("\r\n") ? "\r\n" : "\n"
    self.values = content.split(
      separator: separator, omittingEmptySubsequences: false).map(String.init)
  }
  
  public enum ReadError: Error {
    case missingRowInFile(Int, String)
    case missingValueInRow(Int, String)
    case invalidValueInRow(Int, String)
    case unexpectedValueCount
  }
  
  public subscript(row row: Int) -> String? {
    let idx = row - 1
    guard values.indices.contains(idx) else {
      return nil
    }
    return values[idx].trimmingCharacters(in: .whitespaces)
  }
  
  public func extractString(from row: Int)throws -> String {
    guard let string = self[row: row], string.count > 0 else {
      throw ReadError.missingValueInRow(row, path)
    }
    return string
  }
  
  public func double(row: Int)throws -> Double {
    let value = try extractString(from: row)
    if let value = Double(value) {
      return value
    } else {
      throw ReadError.invalidValueInRow(row, path)
    }
  }
  
  public func doubles(rows: Int...)throws -> [Double] {
    return try rows.map { row -> Double in
      let value = try extractString(from: row)
      if let value = Double(value) {
        return value
      } else {
        throw ReadError.invalidValueInRow(row, path)
      }
    }
  }
  
  public func integer(row: Int)throws -> Int {
    let value = try extractString(from: row)
    if let value = Int(value) {
      return value
    } else {
      throw ReadError.invalidValueInRow(row, path)
    }
  }
}

extension TextConfigFile.ReadError {
  var errorDescription: String {
    switch self {
    case .invalidValueInRow(let row, let path):
      return "\(path) - Invalid value in row \(row)."
    case .missingRowInFile(let row, let path):
      return "\(path) - File has less then \(row) rows."
    case .missingValueInRow(let row, let path):
      return "\(path) - Missing value in row \(row)."
    case .unexpectedValueCount:
      return "Layout file has unexpected format."
      
    }
  }
}
