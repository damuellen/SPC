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
public struct Temperature: CustomStringConvertible {
  var kelvin: Double

  static var absoluteZeroCelsius = -273.15

  public var celsius: Double { return kelvin + Temperature.absoluteZeroCelsius }

  public var description: String {
    return String(format: "%.1f°C", celsius)
  }

  public init() {
    kelvin = -Temperature.absoluteZeroCelsius
  }

  static func calculate(
    massFlow1: MassFlow, massFlow2: MassFlow,
    temperature1: Temperature, temperature2: Temperature
    ) -> Temperature {
    return Temperature((massFlow1.rate * temperature1.kelvin
      + massFlow2.rate * temperature2.kelvin) / (massFlow1 + massFlow2).rate)
  }
  
  public init(_ kelvin: Double) {
 //   precondition(0 ..< 850 ~= kelvin)
    self.kelvin = kelvin
  }

  public static func average(_ t: Temperature...) -> Temperature {
    if t.count == 2 {
      return Temperature((t[0].kelvin + t[1].kelvin) / 2)
    }
    return Temperature(t.reduce(0) { result, temp in
      result + temp.kelvin } / Double(t.count)
    )
  }

  public init(celsius: Double) {
    assert(celsius > Temperature.absoluteZeroCelsius)
    self.kelvin = celsius.toKelvin
  }

  public init(celsius: Float) {
    assert(celsius > Float(Temperature.absoluteZeroCelsius))
    self.kelvin = Double(celsius).toKelvin
  }

  mutating func adjust(with ratio: Ratio) {
    self.kelvin *= ratio.ratio
  }

  func adjusted(with ratio: Ratio) -> Temperature {
    return Temperature(kelvin * ratio.ratio)
  }

  mutating func adjust(withFactor factor: Double) {
    self.kelvin *= factor
  }

  func adjusted(with factor: Double) -> Temperature {
    return Temperature(kelvin * factor)
  }

  func isHigher(than degree: Temperature) -> Bool {
    return self.kelvin > degree.kelvin
  }

  func isLower(than degree: Temperature) -> Bool {
    return self.kelvin < degree.kelvin
  }

  static func + (lhs: Temperature, rhs: Temperature) -> Temperature {
    return Temperature(lhs.kelvin + rhs.kelvin)
  }

  static func - (lhs: Temperature, rhs: Temperature) -> Temperature {
    return Temperature(lhs.kelvin - rhs.kelvin)
  }
  
  static func + (lhs: Temperature, rhs: Double) -> Temperature {
    return Temperature(lhs.kelvin + rhs)
  }
  
  static func - (lhs: Temperature, rhs: Double) -> Temperature {
    return Temperature(lhs.kelvin - rhs)
  }
}
/*
extension Temperature {
typealias T = Temperature
public func + (lhs: T, rhs: Double) -> Double {
  return lhs.kelvin + rhs.value
}

public func -  (lhs: T, rhs: Double) -> Double {
  return lhs.kelvin - rhs.value
}

public func <  (lhs: T, rhs: Double) -> Bool {
  return lhs.kelvin < rhs.value
}

public func ==  (lhs: T, rhs: Double) -> Bool {
  return lhs.kelvin == rhs.value
}

public func +=  (lhs: inout T, rhs: Double) {
  lhs.value = lhs.value + rhs.value
}

public func -= (lhs: inout T, rhs: Double) {
  lhs.value = lhs.value - rhs.value
}
}*/
extension Temperature: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    kelvin = try container.decode(Double.self)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(kelvin)
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
