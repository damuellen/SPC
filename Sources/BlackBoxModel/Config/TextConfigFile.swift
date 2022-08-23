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

public enum ConfigFormat { case json, text }

public protocol TextConfigInitializable {
  init(file: TextConfigFile) throws
}

public struct TextConfigFile {
  public var values: [String]

  public var name: String {
    return self.values.indices.contains(6) ? self.values[6] : ""
  }

  private let path: String

  // Returns a String, which contains the content of needed config file.
  public init?(url: URL) {
    let path = url.path
    do {
      let content = try String(contentsOf: url, encoding: .windowsCP1252)
      self = .init(content: content, path: path)
    } catch let error {
      print(error.localizedDescription)
      print("  " + url.path)
      return nil
    }
  }

  init(content: String, path: String) {
    self.path = path
    let separator: Character = content.contains("\r\n") ? "\r\n" : "\n"
    values = content.split(
      separator: separator, omittingEmptySubsequences: false
    ).map(String.init)
  }

  public enum ReadError: Error {
    case unexpectedEndOfFile(Int, String)
    case missingValueInLine(Int, String)
    case invalidValueInLine(Int, String)
  }

  public subscript(_ idx: Int) -> String? {
    guard self.values.indices.contains(idx) else {
      return nil
    }
    return self.values[idx].trimWhitespace()
  }

  public func string(_ line: Int) throws -> String {
    guard let string = self[line - 1], string.count > 0 else {
      throw ReadError.missingValueInLine(line, self.path)
    }
    return string
  }

  public func double(line: Int) throws -> Double {
    let value = try string(line)
    if let value = Double(value) {
      return value
    } else {
      throw ReadError.invalidValueInLine(line, self.path)
    }
  }

  public func integer(line: Int) throws -> Int {
    let value = try string(line)
    if let value = Int(value) {
      return value
    } else {
      throw ReadError.invalidValueInLine(line, self.path)
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

extension Character {
  fileprivate var isASCIIWhitespace: Bool {
    self == " " || self == "\t"
  }
}

extension String {
  fileprivate func trimWhitespace() -> String {
    var me = Substring(self)
    while me.first?.isASCIIWhitespace == .some(true) {
      me = me.dropFirst()
    }
    while me.last?.isASCIIWhitespace == .some(true) {
      me = me.dropLast()
    }
    return String(me)
  }
}