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

public struct CSV {
  public let header: [String]
  public let data: [[Double]]

  public subscript(row: Int) -> [Double] {
    data[row]
  }

  public subscript(column: String, row: Int) -> Double {
    data[row][header.firstIndex(of: column) ?? data[row].startIndex]
  }

  public subscript(column: String) -> [Double] {
    let c = header.firstIndex(of: column) ?? data[0].startIndex
    return Array<Double>(unsafeUninitializedCapacity: data.count) { 
      uninitializedMemory, resultCount in 
      resultCount = data.count
      for i in data.indices { uninitializedMemory[i] = data[i][c] }
    }
  }

  public init?(url: URL, separator: Unicode.Scalar = ",") {
    guard let rawData = try? Data(contentsOf: url) else { return nil }
    let newLine = UInt8(ascii: "\n")
    let cr = UInt8(ascii: "\r")
    let separator = UInt8(ascii: separator)
    let isSpace = { $0 != UInt8(ascii: "\"") }
    let isLetter = { $0 < UInt8(ascii: "A") }
    guard let firstNewLine = rawData.firstIndex(of: newLine) else { return nil }
    let firstSeparator = rawData.firstIndex(of: separator) ?? 0
    guard firstSeparator < firstNewLine else { return nil }
    let hasCR = rawData[rawData.index(before: firstNewLine)] == cr
    let end = hasCR ? rawData.index(before: firstNewLine) : firstNewLine
    let hasHeader = rawData[..<end].contains(where: isLetter)
    let start = hasHeader ? rawData.index(after: firstNewLine) : rawData.startIndex
    self.header = !hasHeader ? [] : rawData[..<end].split(separator: separator).map { slice in
      String(decoding: slice.filter(isSpace), as: UTF8.self)
    }
    self.data = rawData[start...].withUnsafeBytes { content in
      content.split(separator: newLine).map { line in
        let line = hasCR ? line.dropLast() : line
        return line.split(separator: separator).map { slice in
          let buffer = UnsafeRawBufferPointer(rebasing: slice)
            .baseAddress!.assumingMemoryBound(to: Int8.self)
          return strtod(buffer, nil)
        }
      }
    }
  }
}
