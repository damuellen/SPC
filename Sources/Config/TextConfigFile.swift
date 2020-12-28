// Copyright 2021 TSK Flagsol Engineering GmbH
// SPDX-License-Identifier: Apache-2.0

import Foundation

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
    return self.values[idx].trimmingCharacters(in: .whitespaces)
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
