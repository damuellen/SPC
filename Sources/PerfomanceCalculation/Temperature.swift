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

/// A temperature value in Kelvin.
public struct Temperature {

  var kelvin: Double {
    willSet { assert(newValue > 0) }
  }
  
  static var absoluteZeroCelsius = -273.15
  
  var celsius: Double { return kelvin + Temperature.absoluteZeroCelsius }
  
  public init() {
    self.kelvin = Temperature.absoluteZeroCelsius
  }
  
  public init(_ kelvin: Double) {
    assert(kelvin >= 0)
    self.kelvin = kelvin
  }
  
  /// Creates a new instance initialized to the given value converted to Kelvin.
  public init(celsius: Double) {
    assert(celsius > Temperature.absoluteZeroCelsius)
    self.kelvin = celsius.toKelvin
  }
  
  public init(celsius: Float) {
    assert(celsius > Float(Temperature.absoluteZeroCelsius))
    self.kelvin = Double(celsius).toKelvin
  }
  
  mutating func adjust(with ratio: Ratio) {
    kelvin *= ratio.ratio
  }
  
  func adjusted(with ratio: Ratio) -> Temperature {
    return Temperature(kelvin * ratio.ratio)
  }
  
  mutating func adjust(with factor: Double) {
    kelvin *= factor
  }
  
  func adjusted(with factor: Double) -> Temperature {
    return Temperature(kelvin * factor)
  }
  
  func raised(by degree: Double) -> Temperature {
    return Temperature(kelvin + degree)
  }
  
  func lowered(by degree: Double) -> Temperature {
    return Temperature(kelvin - degree)
  }
  
  func isHigher(than degree: Double) -> Bool {
    return kelvin > degree
  }
  
  func isLower(than degree: Double) -> Bool {
    return kelvin < degree
  }
  
  static func + (lhs: Temperature, rhs: Temperature) -> Temperature {
    return Temperature(lhs.kelvin + rhs.kelvin)
  }
  
  static func - (lhs: Temperature, rhs: Temperature) -> Temperature {
    return Temperature(lhs.kelvin - rhs.kelvin)
  }
}

extension Temperature: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.kelvin = try container.decode(Double.self)
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(self.kelvin)
  }
}

extension Temperature: ExpressibleByFloatLiteral {
  public init(floatLiteral kelvin: Double) {
    self.kelvin = kelvin
  }
}

extension Temperature: Comparable {
  public static func < (lhs: Temperature, rhs: Temperature) -> Bool {
    return lhs.kelvin < rhs.kelvin
  }
  
  public static func == (lhs: Temperature, rhs: Temperature) -> Bool {
    return fdim(lhs.kelvin, rhs.kelvin) < 1e-4
  }
}
