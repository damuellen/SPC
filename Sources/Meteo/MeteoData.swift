// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import Foundation
import SolarPosition

/// A data structure representing meteorological data, including temperature, solar irradiance, and wind speed.
public struct MeteoData: CustomStringConvertible {
  /// The temperature in degrees Celsius.
  public var temperature: Double

  /// The solar irradiance data, including direct, global, and diffuse irradiance in watts per square meter (W/m²).
  public var insolation: Insolation

  /// The wind speed in meters per second (m/s).
  public var windSpeed: Double

  /// The optional wet-bulb temperature in degrees Celsius.
  var wetBulbTemperature: Double? = nil

  /// Returns an array containing the temperature and wind speed.
  var conditions: [Double] { [temperature, windSpeed] }

  /// Initializes a MeteoData instance with provided parameters.
  /// - Parameters:
  ///   - dni: The direct normal irradiance in watts per square meter (W/m2).
  ///   - ghi: The global horizontal irradiance in watts per square meter (W/m2).
  ///   - dhi: The diffuse horizontal irradiance in watts per square meter (W/m2).
  ///   - temperature: The temperature in degrees Celsius.
  ///   - windSpeed: The wind speed in meters per second (m/s).
  public init(
    dni: Double = 0, ghi: Double = 0, dhi: Double = 0,
    temperature: Double = 0, windSpeed: Double = 0
  ) {
    self.insolation = .init(direct: dni, global: ghi, diffuse: dhi)
    self.temperature = temperature
    self.windSpeed = windSpeed
  }

  /// Initializes a MeteoData instance with provided insolation and conditions.
  /// - Parameters:
  ///   - insolation: An array containing direct, global, and diffuse irradiance values in watts per square meter (W/m2).
  ///   - conditions: An array containing temperature and wind speed values.
  public init(insolation: [Double], conditions: [Double]) {
    self.insolation = .init(direct: insolation[0], global: insolation[1], diffuse: insolation[2])
    self.temperature = conditions[0]
    self.windSpeed = conditions[1]
  }

  /// Initializes a MeteoData instance with provided values based on the given order.
  /// - Parameters:
  ///   - values: An array containing all values.
  ///   - order: An array specifying the order of dni, temperature, windSpeed, ghi, and dhi in the values array.
  public init(_ values: [Double], order: [Int?]) {
    let dni, ghi, dhi: Double
    if let i = order[0] { dni = values[i] } else { dni = .zero }
    if let i = order[1] { self.temperature = values[i] } else { self.temperature = .zero }
    if let i = order[2] { self.windSpeed = values[i] } else { self.windSpeed = .zero }
    if let i = order[3] { ghi = values[i] } else { ghi = .zero }
    if let i = order[4] { dhi = values[i] } else { dhi = .zero }
    self.insolation = .init(direct: dni, global: ghi, diffuse: dhi)
  }

  /// A textual representation of the MeteoData instance.
  public var description: String {
    String(format: "\nAmbient: %.1f degC", temperature)
      + String(format: "  DNI: %.1f W/m2", insolation.direct)
      + String(format: "  GHI: %.1f W/m2", insolation.global)
      + String(format: "  DHI: %.1f W/m2", insolation.diffuse)
      + String(format: "  WS: %.1f m/s\n", windSpeed)
  }
}
