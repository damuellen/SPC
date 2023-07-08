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
import SolarPosition

/// A struct called MeteoData that represents meteorological data.
public struct MeteoData: CustomStringConvertible {
  /// The temperature in degrees Celsius.
  public var temperature: Double
  /// The direct normal irradiance in watts per square meter (W/m2).
  public var dni: Double
  /// The global horizontal irradiance in watts per square meter (W/m2).
  public var ghi: Double
  /// The diffuse horizontal irradiance in watts per square meter (W/m2).
  public var dhi: Double
  /// The wind speed in meters per second (m/s).
  public var windSpeed: Double
  var wetBulbTemperature: Double? = nil
  /// Returns an array containing the temperature and wind speed.
  var conditions: [Double] { [temperature, windSpeed] }
  /// Returns an array containing the dni, ghi, and dhi.
  var insolation: [Double] { [dni, ghi, dhi] }

  public init(
    dni: Double = 0, ghi: Double = 0, dhi: Double = 0,
    temperature: Double = 0, windSpeed: Double = 0
  ) {
    self.dni = dni
    self.ghi = ghi
    self.dhi = dhi
    self.temperature = temperature
    self.windSpeed = windSpeed
  }

  public init(insolation: [Double], conditions: [Double]) {
    self.temperature = conditions[0]
    self.dni = insolation[0]
    self.ghi = insolation[1]
    self.dhi = insolation[2]
    self.windSpeed = conditions[1]
  }

  public init(_ values: [Double], order: [Int?]) {
    if let i = order[0] { self.dni = values[i] } else { self.dni = .zero }
    if let i = order[1] { self.temperature = values[i] } else { self.temperature = .zero }
    if let i = order[2] { self.windSpeed = values[i] } else { self.windSpeed = .zero }
    if let i = order[3] { self.ghi = values[i] } else { self.ghi = .zero }
    if let i = order[4] { self.dhi = values[i] } else { self.dhi = .zero }
  }

  public var description: String {
    String(format: "\nAmbient: %.1f degC", temperature)
      + String(format: "  DNI: %.1f W/m2", dni)
      + String(format: "  GHI: %.1f W/m2", ghi)
      + String(format: "  DHI: %.1f W/m2", dhi)
      + String(format: "  WS: %.1f m/s\n", windSpeed)
  }
}
