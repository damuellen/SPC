//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import DateGenerator
import Libc
import Meteo

public struct Temperatures {
  var cold: Temperature
  var hot: Temperature
}

/// A temperature value in Kelvin.
public struct Temperature: CustomStringConvertible, Equatable {

  var kelvin: Double {
    willSet { 
      assert(newValue.isFinite)
      assert(kelvin.isNormal)
      assert(kelvin.sign == .plus)
    }
  }

  static var absoluteZeroCelsius = -273.15

  public var celsius: Double { return kelvin + Temperature.absoluteZeroCelsius }

  public var description: String {
    String(format: "%.1f °C", celsius)
  }

  public init() {
    kelvin = -Temperature.absoluteZeroCelsius
  }

  static func mixture(m1: Mass, m2: Mass, t1: T, t2: T) -> T {
    .init((m1.kg * t1.kelvin + m2.kg * t2.kelvin) / (m1.kg + m2.kg))
  }

  public init(_ kelvin: Double) {
    assert(kelvin.isFinite)
    assert(kelvin.isNormal)
    assert(kelvin.sign == .plus)
    self.kelvin = kelvin
  }

  typealias T = Temperature

  static func average(_ t1: T,_ t2: T) -> T {
    T((t1.kelvin + t2.kelvin) / 2)
  }

  public init(celsius: Double) {
    assert(celsius.isFinite, "\(celsius), \(DateTime.current)")
    assert(celsius > Temperature.absoluteZeroCelsius)
    self.kelvin = celsius - Temperature.absoluteZeroCelsius
  }

  public init(meteo: MeteoData) {
    assert(meteo.temperature > -30)
    assert(meteo.temperature < 70)
    self = .init(celsius: Double(meteo.temperature))
  }

  mutating func adjust(with ratio: Ratio) {
    self.kelvin *= ratio.ratio
  }

  func adjusted(_ ratio: Ratio) -> Temperature {
    Temperature(kelvin * ratio.ratio)
  }

  mutating func adjust(withFactor factor: Double) {
    kelvin *= factor
  }

  mutating func limit(to max: Temperature) {
    kelvin = min(max.kelvin, self.kelvin)
  }

  func adjusted(_ factor: Double) -> Temperature {
    Temperature(kelvin * factor)
  }

  func isLower(than degree: Temperature) -> Bool {
    kelvin < degree.kelvin
  }

  static func + (lhs: Temperature, rhs: Temperature) -> Temperature {
    Temperature(lhs.kelvin + rhs.kelvin)
  }

  static func - (lhs: Temperature, rhs: Temperature) -> Temperature {
    Temperature(lhs.kelvin - rhs.kelvin)
  }

  static func + (lhs: Temperature, rhs: Double) -> Temperature {
    Temperature(lhs.kelvin + rhs)
  }

  static func - (lhs: Temperature, rhs: Double) -> Temperature {
    Temperature(lhs.kelvin - rhs)
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
    return abs(lhs.kelvin - rhs.kelvin) < 1e-4
  }
}
