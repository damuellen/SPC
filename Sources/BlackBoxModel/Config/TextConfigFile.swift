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

public protocol TextConfigInitializable {
  init(file: TextConfigFile) throws
}

public struct TextConfigFile {
  public var lines: [String]

  public var name: String {
    if lines.count > 6, !lines[6].isEmpty {
      return lines[6]
    }
    return url.lastPathComponent
  }

  public let url: URL
  
  public init(url: URL) throws {
    let content = try String(contentsOf: url, encoding: .windowsCP1252)
    self = .init(content: content, url: url)
  }

  init(content: String, url: URL) {
    self.url = url
    let separator: Character = content.contains("\r\n") ? "\r\n" : "\n"
    lines = content.split(
      separator: separator, omittingEmptySubsequences: false
    ).map(\.trimmed)
  }

  public enum ReadError: Error {
    case unexpectedEndOfFile(Int, String)
    case missingValueInLine(Int, String)
    case invalidValueInLine(Int, String)
  }

  public func readString(lineNumber: Int) throws -> String {
    let index = lineNumber - 1
    guard lines.indices.contains(index) else {
      throw ReadError.unexpectedEndOfFile(lineNumber, self.url.path)
    }
    let string = lines[lineNumber - 1]
    guard string.count > 0 else {
      throw ReadError.missingValueInLine(lineNumber, self.url.path)
    }
    return string
  }

  public func readDouble(lineNumber: Int) throws -> Double {
    let value = try readString(lineNumber: lineNumber)
    if let value = Double(value) {
      return value
    } else {
      throw ReadError.invalidValueInLine(lineNumber, self.url.path)
    }
  }

  public func readInteger(lineNumber: Int) throws -> Int {
    let value = try readString(lineNumber: lineNumber)
    if let value = Int(value) {
      return value
    } else {
      throw ReadError.invalidValueInLine(lineNumber, self.url.path)
    }
  }
}

extension TextConfigFile.ReadError: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .invalidValueInLine(line, path):
      return "\(path) invalid value in line \(line)."
    case let .unexpectedEndOfFile(line, path):
      return "\(path) has less then \(line) lines."
    case let .missingValueInLine(line, path):
      return "\(path) missing value in line \(line)."
    }
  }
}

extension Substring {
  var trimmed: String {
    var trimmed = self
    while trimmed.first?.isWhitespace == .some(true) {
      trimmed = trimmed.dropFirst()
    }
    while trimmed.last?.isWhitespace == .some(true) {
      trimmed = trimmed.dropLast()
    }
    return String(trimmed)
  }
}