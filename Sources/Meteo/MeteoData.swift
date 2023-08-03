// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering
import Foundation
import SolarPosition

/// A struct called MeteoData that represents meteorological data.
public struct MeteoData: CustomStringConvertible {
  /// The temperature in degrees Celsius.
  public var temperature: Double
  /// The solar irradiance in watts per square meter (W/m2).
  public var insolation: Insolation
  /// The wind speed in meters per second (m/s).
  public var windSpeed: Double
  var wetBulbTemperature: Double? = nil
  /// Returns an array containing the temperature and wind speed.
  var conditions: [Double] { [temperature, windSpeed] }

  public init(
    dni: Double = 0, ghi: Double = 0, dhi: Double = 0,
    temperature: Double = 0, windSpeed: Double = 0
  ) {
    self.insolation = .init(direct: dni, global: ghi, diffuse: dhi)
    self.temperature = temperature
    self.windSpeed = windSpeed
  }

  public init(insolation: [Double], conditions: [Double]) {
    self.insolation = .init(direct: insolation[0], global: insolation[1], diffuse: insolation[2])
    self.temperature = conditions[0]
    self.windSpeed = conditions[1]
  }

  public init(_ values: [Double], order: [Int?]) {
    let dni, ghi, dhi: Double
    if let i = order[0] { dni = values[i] } else { dni = .zero }
    if let i = order[1] { self.temperature = values[i] } else { self.temperature = .zero }
    if let i = order[2] { self.windSpeed = values[i] } else { self.windSpeed = .zero }
    if let i = order[3] { ghi = values[i] } else { ghi = .zero }
    if let i = order[4] { dhi = values[i] } else { dhi = .zero }
    self.insolation = .init(direct: dni, global: ghi, diffuse: dhi)
  }

  public var description: String {
    String(format: "\nAmbient: %.1f degC", temperature)
      + String(format: "  DNI: %.1f W/m2", insolation.direct)
      + String(format: "  GHI: %.1f W/m2", insolation.global)
      + String(format: "  DHI: %.1f W/m2", insolation.diffuse)
      + String(format: "  WS: %.1f m/s\n", windSpeed)
  }
}
