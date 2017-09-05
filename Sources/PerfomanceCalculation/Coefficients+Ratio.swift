//
//  Copyright (c) 2017 Daniel Müllenborn. All rights reserved.
//  Distributed under the The Non-Profit Open Software License version 3.0
//  http://opensource.org/licenses/NPOSL-3.0
//
//  This project is NOT free software. It is open source, you are allowed to
//  modify it (if you keep the license), but it may not be commercially
//  distributed other than under the conditions noted above.
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
  
  func solved(with value: Double) -> Double {
    var result = 0.0
    for (i, c) in coefficients.enumerated() {
      result += c * pow(value, Double(i))
    }
    return result
  }
  
  subscript(value: Double) -> Double {
    return solved(with: value)
  }
  
  subscript(ratio: Ratio) -> Double {
    return solved(with: ratio.value)
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
  
  let value: Double
  
  var isZero: Bool { return value == 0 }
  
  var percentage: Float { return Float(value) * 100.0 }
  
  public var description: String { return "\(percentage)%" }
  
  public init(percent: Double) {
    self.value = percent / 100
  }
  
  public init(_ value: Double) {
    self.value = value < 0
      ? 0 : value > 1
      ? 1 : value
  }
}

extension Ratio: ExpressibleByFloatLiteral {
  public init(floatLiteral value: Double) {
    self.value = value
  }
}

extension Ratio: Equatable {
  public static func ==(lhs: Ratio, rhs: Ratio) -> Bool {
    return lhs.value == rhs.value
  }
}

extension Ratio: Comparable {
  public static func <(lhs: Ratio, rhs: Ratio) -> Bool {
    return lhs.value < rhs.value
  }
}

public struct Demand {
  
}
