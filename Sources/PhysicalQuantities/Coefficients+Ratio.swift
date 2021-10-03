//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Helpers

/// Represents a polynomial function, e.g. `2 + 3x + 4x²`.
public struct Polynomial: Codable, Equatable {
  /// Represents the coefficients of the polynomial
  public let coefficients: [Double]

  public init(coeffs: Double...) {
    self.coefficients = coeffs
  }

  public init(_ array: [Double]) {
    self.coefficients = array
  }

  public var indices: CountableRange<Int> { coefficients.indices }

  public var isEmpty: Bool { coefficients.isEmpty }

  public var isInapplicable: Bool { coefficients.count < 2 }

  @_transparent func evaluated(_ value: Double) -> Double {
    // Use Horner’s Method for solving
    coefficients.reversed().reduce(into: 0.0) { result, coefficient in
      result = coefficient.addingProduct(result, value)
    }
  }

  public func callAsFunction(_ temperature: Temperature) -> Double {
    evaluated(temperature.kelvin)
  }

  public func callAsFunction(_ value: Double) -> Double {
    evaluated(value)
  }

  public func callAsFunction(_ ratio: Ratio) -> Double {
    evaluated(ratio.quotient)
  }

  public subscript(index: Int) -> Double {
    coefficients[index]
  }
}

extension Polynomial: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: Double...) {
    self.coefficients = elements
  }
}

extension Polynomial: CustomStringConvertible {
  public var description: String {
    var s: String = ""
    for (i, c) in coefficients.enumerated() {
      s += "c\(i):" * String(format: "%.6e", c)
    }
    return s
  }
}

public struct Ratio: CustomStringConvertible, Codable {
  public var quotient: Double

  public var isZero: Bool { self == .zero }

  public static var zero: Ratio { Ratio(0) }

  public var percentage: Double { quotient * 100.0 }

  public var description: String { 
    String(format: "%3.1f", percentage) + "%"
  }

  public init(percent: Double) {
    self.quotient = percent / 100
  }

  public init(_ value: Double) {
    precondition(0...1.01 ~= value, "Ratio out of range.")
    self.quotient = value > 1 ? 1 : value
  }

  public init(_ value: Double, cap: Double) {
    precondition(0 <= value, "Ratio out of range.")
    self.quotient = min(value, cap)
  }

  public mutating func limited(to max: Ratio) {
    quotient = min(max.quotient, quotient)
  }
}

extension Ratio: ExpressibleByFloatLiteral {
  public init(floatLiteral value: Double) {
    self.quotient = value
  }
}

extension Ratio: Equatable {
  public static func == (lhs: Ratio, rhs: Ratio) -> Bool {
    lhs.quotient == rhs.quotient
  }
}

extension Ratio: Comparable {
  public static func < (lhs: Ratio, rhs: Ratio) -> Bool {
    lhs.quotient < rhs.quotient
  }
}

extension Ratio {
  public var multiBar: String {
    let (bar_chunks, remainder) = Int(quotient * 80)
      .quotientAndRemainder(dividingBy: 8)
    let full = UnicodeScalar("█").value
    let fractionalPart = remainder > 0
      ? String(UnicodeScalar(full + UInt32(8 - remainder))!) : ""
    return String(repeating: "█", count: bar_chunks)
      + fractionalPart 
      + String(repeating: " ", count: 10 - bar_chunks) 
      + description
  }

  public var singleBar: String {
    let bar = Int(quotient * 7)
    let full = UnicodeScalar("█").value
    let block = String(UnicodeScalar(full - UInt32(7 - bar))!)
    return block + " " + description
  }
}

func * (lhs: String, rhs: String) -> String {
  let width = min(max(terminalWidth(), 70), 100)  
  var c = width - lhs.count - rhs.count - 1
  c = c < 0 ? 1 : c
  return lhs + String(repeating: " ", count: c) + rhs + "\n"
}