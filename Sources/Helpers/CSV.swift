//
//  Copyright 2021 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation

/// Read files only containing numbers.
/// - Note: Auto-detect of optional String headers.
public struct CSV {
  public let headerRow: [String]?
  public let dataRows: [[Double]]

  public var csv: String { peek(dataRows.indices) }

  public var head: String { peek(0..<30) }

  public var tail: String { 
    if dataRows.count > 30 {
      return peek(dataRows.endIndex-30..<dataRows.endIndex) 
    }
    return peek(0..<dataRows.endIndex) 
  }

  public func peek(_ range: Array.Indices) -> String {
    if let headerRow = headerRow {
      return headerRow.joined(separator: ", ") + "\n" 
       + Array.formatted(dataRows[range])
    }
    return Array.formatted(dataRows[range])
  }

  public subscript(row: Int) -> [Double] {
    dataRows[row]
  }

  public subscript(column: String, row: Int) -> Double {
    dataRows[row][headerRow?.firstIndex(of: column) ?? dataRows[row].startIndex]
  }

  public subscript(column: String) -> [Double] {
    let c = headerRow?.firstIndex(of: column) ?? dataRows[0].startIndex
    return self[column: c]
  }

  public subscript(column c: Int) -> [Double] {
    return Array<Double>(unsafeUninitializedCapacity: dataRows.count) {
      uninitializedMemory, resultCount in
      resultCount = dataRows.count
      for i in dataRows.indices {
        uninitializedMemory[i] = dataRows[i][c]
      }
    }
  }

  public init?(url: URL, separator: Unicode.Scalar = ",") {
    guard let rawData = try? Data(contentsOf: url) else { return nil }
    let newLine = UInt8(ascii: "\n")
    let cr = UInt8(ascii: "\r")
    let separator = UInt8(ascii: separator)
    let isSpace = { $0 != UInt8(ascii: " ") }
    let isLetter = { $0 < UInt8(ascii: "A") }
    guard let firstNewLine = rawData.firstIndex(of: newLine) else { return nil }
    let firstSeparator = rawData.firstIndex(of: separator) ?? 0
    guard firstSeparator < firstNewLine else { return nil }
    let hasCR = rawData[rawData.index(before: firstNewLine)] == cr
    let end = hasCR ? rawData.index(before: firstNewLine) : firstNewLine
    let hasHeader = rawData[..<end].contains(where: isLetter)
    let start = hasHeader ? rawData.index(after: firstNewLine) : rawData.startIndex
    self.headerRow = !hasHeader ? nil : rawData[..<end].split(separator: separator).map { slice in
      String(decoding: slice.filter(isSpace), as: UTF8.self)
    }
    #if DEBUG
    if let headerRow = headerRow {
      print("Header row detected.", headerRow)
    } else {
      print("No header.")
    }
    #endif
    self.dataRows = rawData[start...].withUnsafeBytes { content in
      content.split(separator: newLine).map { line in
        let line = hasCR ? line.dropLast() : line
        return line.split(separator: separator).map { slice in
          let buffer = UnsafeRawBufferPointer(rebasing: slice)
            .baseAddress!.assumingMemoryBound(to: Int8.self)
          return strtod(buffer, nil)
        }
      }
    }
    #if DEBUG
    if let headerRow = headerRow, dataRows[0].count != headerRow.count {
      print("Header missing !")
      print(dataRows[0])
    }
    print("\(url.absoluteString) loaded.")
    #endif
  }
}

public extension Array where Element == Double {
  var formatted: String {
    self.map(\.description).joined(separator: ", ")
  }
}

public extension Array where Element == Double {
  static func formatted(_ array: ArraySlice<[Double]>) -> String {
    array.map(\.formatted).joined(separator: "\n")
  }
}
