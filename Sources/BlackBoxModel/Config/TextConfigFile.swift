//
//  Copyright 2023 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation

// A protocol that allows types to be initialized from a TextConfigFile.
public protocol TextConfigInitializable {
  init(file: TextConfigFile) throws
}

// A struct representing a configuration file with lines of text and associated functionality.
public struct TextConfigFile {
  // The lines of text in the configuration file.
  public var lines: [String]

  // Computed property to get the name of the configuration file.
  public var name: String {
    if lines.count > 6, !lines[6].isEmpty {
      return lines[6]
    }
    return url.lastPathComponent
  }

  /// The URL of the configuration file.
  public let url: URL
  
  // Initializes a TextConfigFile instance from the contents of a URL.
  public init(url: URL) throws {
    let content = try String(contentsOf: url, encoding: .windowsCP1252)
    self = .init(content: content, url: url)
  }

  // Initializes a TextConfigFile instance from the given content and URL.
  init(content: String, url: URL) {
    self.url = url
    // Determine the line separator used in the content (either "\r\n" or "\n").
    let separator: Character = content.contains("\r\n") ? "\r\n" : "\n"
    // Split the content into lines and trim each line.
    lines = content.split(
      separator: separator, omittingEmptySubsequences: false
    ).map(\.trimmed)
  }

  /// An enumeration representing read errors that may occur while processing the file.
  public enum ReadError: Error {
    case unexpectedEndOfFile(Int, String)
    case missingValueInLine(Int, String)
    case invalidValueInLine(Int, String)
  }

  /// Read a string from a specific line in the configuration file.
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

  /// Read a double value from a specific line in the configuration file.
  public func readDouble(lineNumber: Int) throws -> Double {
    let value = try readString(lineNumber: lineNumber)
    if let value = Double(value) {
      return value
    } else {
      throw ReadError.invalidValueInLine(lineNumber, self.url.path)
    }
  }

  /// Read an integer value from a specific line in the configuration file.
  public func readInteger(lineNumber: Int) throws -> Int {
    let value = try readString(lineNumber: lineNumber)
    if let value = Int(value) {
      return value
    } else {
      throw ReadError.invalidValueInLine(lineNumber, self.url.path)
    }
  }

  /// Read an array of integers from a specific line in the configuration file.
  public func readIntegers(lineNumber: Int) throws -> [Int] {
    let s = try readString(lineNumber: lineNumber)
    let i = s.split(separator: ",").map(String.init).compactMap(Int.init)
    if i.count != 24 {
      throw ReadError.invalidValueInLine(lineNumber, self.url.path)
    }
    return i
  }
}

// An extension to provide a description for the ReadError enumeration.
extension TextConfigFile.ReadError: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .invalidValueInLine(line, path):
      return "\(path) invalid value in line \(line)."
    case let .unexpectedEndOfFile(line, path):
      return "\(path) has less than \(line) lines."
    case let .missingValueInLine(line, path):
      return "\(path) missing value in line \(line)."
    }
  }
}

// An extension to Substring to provide a utility for trimming whitespace from both ends.
extension Substring {
  var trimmed: String {
    var trimmed = self
    // Trim leading whitespace.
    while trimmed.first?.isWhitespace == .some(true) {
      trimmed = trimmed.dropFirst()
    }
    // Trim trailing whitespace.
    while trimmed.last?.isWhitespace == .some(true) {
      trimmed = trimmed.dropLast()
    }
    return String(trimmed)
  }
}
