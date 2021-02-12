//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

public struct Polynomial: Codable, Equatable {
  let coefficients: [Double]

  public init(values: Double...) {
    self.coefficients = values
  }

  init(_ array: [Double]) {
    self.coefficients = array
  }

  var indices: CountableRange<Int> { coefficients.indices }

  var isEmpty: Bool { coefficients.isEmpty }

  var isInapplicable: Bool { coefficients.count < 2 }

  @_transparent func evaluated(_ value: Double) -> Double {
    // Use Horner’s Method for solving
    coefficients.reversed().reduce(into: 0.0) { result, coefficient in
      result = coefficient.addingProduct(result, value)
    }
  }

  func callAsFunction(_ temperature: Temperature) -> Double {
    evaluated(temperature.kelvin)
  }

  public func callAsFunction(_ value: Double) -> Double {
    evaluated(value)
  }

  func callAsFunction(_ ratio: Ratio) -> Double {
    evaluated(ratio.quotient)
  }

  subscript(index: Int) -> Double {
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
  var quotient: Double

  var isZero: Bool { self == .zero }

  public static var zero: Ratio { Ratio(0) }

  public var percentage: Double { quotient * 100.0 }

  public var description: String { 
    String(format: "%3.1f", quotient * 100.0) + "%"
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

  mutating func limited(to max: Ratio) {
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

public struct Demand {}
