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

  init(content: String, path: String) {
    self.path = path
    let separator: Character = content.contains("\r\n") ? "\r\n" : "\n"
    values = content.split(
      separator: separator, omittingEmptySubsequences: false
    ).map(String.init)
  }

  public enum ReadError: Error {
    case missingRowInFile(Int, String)
    case missingValueInRow(Int, String)
    case invalidValueInRow(Int, String)
    case unexpectedValueCount
  }

  public subscript(_ idx: Int) -> String? {
    guard self.values.indices.contains(idx) else {
      return nil
    }
    return self.values[idx].trimmingCharacters(in: .whitespaces)
  }

  public func string(_ line: Int) throws -> String {
    guard let string = self[line - 1], string.count > 0 else {
      throw ReadError.missingValueInRow(line, self.path)
    }
    return string
  }

  public func double(line: Int) throws -> Double {
    let value = try string(line)
    if let value = Double(value) {
      return value
    } else {
      throw ReadError.invalidValueInRow(line, self.path)
    }
  }

  public func integer(line: Int) throws -> Int {
    let value = try string(line)
    if let value = Int(value) {
      return value
    } else {
      throw ReadError.invalidValueInRow(line, self.path)
    }
  }
}

extension TextConfigFile.ReadError: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .invalidValueInRow(line, path):
      return "\(path) - Invalid value in line \(line)."
    case let .missingRowInFile(line, path):
      return "\(path) - File has less then \(line) lines."
    case let .missingValueInRow(row, path):
      return "\(path) - Missing value in line \(row)."
    case .unexpectedValueCount:
      return "Layout file has unexpected format."
    }
  }
}
