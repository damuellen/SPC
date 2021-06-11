//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Libc
import Meteo

public struct Temperatures {
  public var cold: Temperature
  public var hot: Temperature

  public init(cold: Temperature, hot: Temperature) {
    self.cold = cold
    self.hot = hot
  }
}

/// A unit of measure for temperture.
///
/// Temperature is a comparative measure of thermal energy.
/// The SI unit for temperature is the kelvin (K),
/// which is defined in terms of the triple point of water.
public struct Temperature: CustomStringConvertible, Equatable {
  /// Returns the degree Kelvin unit of temperature.
  public var kelvin: Double
  /// Absolute zero of temperature.
  public static var zero = 0

  public static var absoluteZeroCelsius = -273.15
  /// Returns the degree Celsius unit of temperature.
  public var celsius: Double { return kelvin + Temperature.absoluteZeroCelsius }

  public var description: String {
    String(format: "%.1f °C", celsius)
  }

  public init() {
    kelvin = -Temperature.absoluteZeroCelsius
  }

  public static func mixture(m1: Mass, m2: Mass, t1: T, t2: T) -> T {
    .init((m1.kg * t1.kelvin + m2.kg * t2.kelvin) / (m1.kg + m2.kg))
  }

  /// Create a Temperature given a specified value in degrees Kelvin.
  public init(_ kelvin: Double) {
    if kelvin < 0 {
      self.kelvin = 0
    } else {
      assert(kelvin.isFinite)
      self.kelvin = kelvin
    }
  }
  /// Abbreviation for temperature
  public typealias T = Temperature

  public static func average(_ t1: T,_ t2: T) -> T {
    T((t1.kelvin + t2.kelvin) / 2)
  }

  /// Create a Temperature given a specified value in degrees Celsius.
  public init(celsius: Double) {
    assert(celsius.isFinite, "\(celsius)")
    assert(celsius > Temperature.absoluteZeroCelsius)
    self.kelvin = celsius - Temperature.absoluteZeroCelsius
  }
  /// Create a Temperature using the ambient conditions.
  public init(meteo: MeteoData) {
    assert(meteo.temperature > -30)
    assert(meteo.temperature < 70)
    self = .init(celsius: Double(meteo.temperature))
  }

  public mutating func adjust(with ratio: Ratio) {
    self.kelvin *= ratio.quotient
  }

  public func adjusted(_ ratio: Ratio) -> Temperature {
    Temperature(kelvin * ratio.quotient)
  }

  public mutating func adjust(withFactor factor: Double) {
    kelvin *= factor
  }

  public mutating func limit(to max: Temperature) {
    kelvin = min(max.kelvin, self.kelvin)
  }

  public func adjusted(_ factor: Double) -> Temperature {
    Temperature(kelvin * factor)
  }

  public func isLower(than degree: Temperature) -> Bool {
    kelvin < degree.kelvin
  }

  public static func + (lhs: Temperature, rhs: Temperature) -> Temperature {
    Temperature(lhs.kelvin + rhs.kelvin)
  }

  public static func - (lhs: Temperature, rhs: Temperature) -> Temperature {
    Temperature(lhs.kelvin - rhs.kelvin)
  }

  public static func + (lhs: Temperature, rhs: Double) -> Temperature {
    Temperature(lhs.kelvin + rhs)
  }

  public static func - (lhs: Temperature, rhs: Double) -> Temperature {
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
    let celsius = try Double(container.decode(Float.self))
    kelvin = celsius - Temperature.absoluteZeroCelsius
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(Float(celsius))
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
