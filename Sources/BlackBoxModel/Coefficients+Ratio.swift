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

public struct Coefficients: Codable {
  let coefficients: [Double]

  public init(values: Double...) {
    self.coefficients = values
  }

  init(_ array: [Double]) {
    self.coefficients = array
  }

  var indices: CountableRange<Int> {
    return self.coefficients.indices
  }

  var isEmpty: Bool {
    return self.coefficients.isEmpty
  }

  @_transparent func apply(_ value: Double) -> Double {
    // Use Horner’s Method for solving
    var result = 0.0
    for coefficient in self.coefficients.reversed() {
      result = fma(result, value, coefficient) // result * value + coefficient
    }
    return result
  }

  subscript(temperature: Temperature) -> Double {
    return self.apply(temperature.kelvin)
  }

  public subscript(value: Double) -> Double {
    return self.apply(value)
  }

  subscript(ratio: Ratio) -> Double {
    return self.apply(ratio.ratio)
  }

  subscript(index: Int) -> Double {
    return self.coefficients[index]
  }
}

extension Coefficients: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: Double...) {
    self.coefficients = elements
  }
}

public struct Ratio: CustomStringConvertible, Codable {
  var ratio: Double

  var isZero: Bool { return self.ratio == 0 }

  public var percentage: Double { return self.ratio * 100.0 }

  public var description: String { return "\(self.percentage)%" }

  public init(percent: Double) {
    self.ratio = percent / 100
  }

  public init(_ value: Double) {
    precondition(0 ... 1 ~= Int(value), "Ratio out of range.")
    self.ratio = value > 1 ? 1 : value
  }
}

extension Ratio: ExpressibleByFloatLiteral {
  public init(floatLiteral value: Double) {
    self.ratio = value
  }
}

extension Ratio: Equatable {
  public static func == (lhs: Ratio, rhs: Ratio) -> Bool {
    return lhs.ratio == rhs.ratio
  }
}

extension Ratio: Comparable {
  public static func < (lhs: Ratio, rhs: Ratio) -> Bool {
    return lhs.ratio < rhs.ratio
  }
}

public struct Demand { }
