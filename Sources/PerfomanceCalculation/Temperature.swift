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

public struct Temperature {
  
  var value: Double
  
  var toCelsius: Double { return value - 273.15 }
  var toKelvin: Double { return value + 273.15 }
  
  static var zero: Temperature { return Temperature(0.0 as Double) }
  
  public init(_ value: Double) {
    self.value = value
  }
  
  public init(_ value: Float) {
    self.value = Double(value)
  }

  mutating func adjust(with ratio: Ratio) {
    value *= ratio.value
  }
  
  func adjusted(with ratio: Ratio) -> Temperature {
    return Temperature(value * ratio.value)
  }
  
  mutating func adjust(with factor: Double) {
    value *= factor
  }
  
  func adjusted(with factor: Double) -> Temperature {
    return Temperature(value * factor)
  }
  
  func raised(by degree: Double) -> Temperature {
    return Temperature(value + degree)
  }
  
  func lowered(by degree: Double) -> Temperature {
    return Temperature(value - degree)
  }
  
  func isHigher(than degree: Double) -> Bool {
    return value > degree
  }
  
  func isLower(than degree: Double) -> Bool {
    return value < degree
  }
  
  static func + (lhs: Temperature, rhs: Temperature) -> Temperature {
    return Temperature(lhs.value + rhs.value)
  }
  
  static func - (lhs: Temperature, rhs: Temperature) -> Temperature {
    return Temperature(lhs.value - rhs.value)
  }
}

extension Temperature: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.value = try container.decode(Double.self)
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(self.value)
  }
}

extension Temperature: ExpressibleByFloatLiteral {
  public init(floatLiteral value: Double) {
    self.value = value
  }
}

extension Temperature: Comparable {
  public static func < (lhs: Temperature, rhs: Temperature) -> Bool {
    return lhs.value < rhs.value
  }
  
  public static func == (lhs: Temperature, rhs: Temperature) -> Bool {
    return Int(lhs.value * 1000) == Int(rhs.value * 1000)
  }
}
