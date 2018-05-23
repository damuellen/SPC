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
  
  init(values: Double...) {
    self.coefficients = values
  }
  
  init(_ array: [Double]) {
    self.coefficients = array
  }
  
  var indices: CountableRange<Int> {
    return coefficients.indices
  }
  
  var isEmpty: Bool {
    return coefficients.isEmpty
  }
  
  @inline(__always) func apply(_ value: Double) -> Double {
    // Use Horner’s Method for solving
    var result = 0.0
    for coefficient in coefficients.reversed() {
      result = fma(result, value, coefficient) // result * value + coefficient
    }
    return result
  }
  
  subscript(temperature: Temperature) -> Double {
    return apply(temperature.kelvin)
  }
  
  subscript(value: Double) -> Double {
    return apply(value)
  }
  
  subscript(ratio: Ratio) -> Double {
    return apply(ratio.ratio)
  }
  
  subscript(index: Int) -> Double {
    return coefficients[index]
  }
}

extension Coefficients: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: Double...) {
    self.coefficients = elements
  }
}

public struct Ratio: CustomStringConvertible, Codable {
  
  let ratio: Double
  
  var isZero: Bool { return ratio == 0 }
  
  var percentage: Float { return Float(ratio) * 100.0 }
  
  public var description: String { return "\(percentage)%" }
  
  public init(percent: Double) {
    self.ratio = percent / 100
  }
  
  public init(_ value: Double) {
    assert(0...1 ~= Int(value), "Ratio out of range.")
    self.ratio = value > 1 ? 1 : value
  }
}

extension Ratio: ExpressibleByFloatLiteral {
  public init(floatLiteral value: Double) {
    self.ratio = value
  }
}

extension Ratio: Equatable {
  public static func ==(lhs: Ratio, rhs: Ratio) -> Bool {
    return lhs.ratio == rhs.ratio
  }
}

extension Ratio: Comparable {
  public static func <(lhs: Ratio, rhs: Ratio) -> Bool {
    return lhs.ratio < rhs.ratio
  }
}

public struct Demand {
  
}
