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

/// Meteorological data
public struct MeteoData: CustomStringConvertible {
  public var temperature, dni, ghi, dhi, windSpeed: Double
  var wetBulbTemperature: Double? = nil

  var conditions: [Double] { [temperature, windSpeed] }
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

  public init(meteo: [Double]) {
    self.dni = meteo[0]
    self.temperature = meteo[1]
    self.windSpeed = meteo[2]
    self.ghi = meteo.count > 4 ? meteo[4] : 0
    self.dhi = meteo.count > 5 ? meteo[5] : 0
  }

  public init(insolation: [Double], conditions: [Double]) {
    self.temperature = conditions[0]
    self.dni = insolation[0]
    self.ghi = insolation[1]
    self.dhi = insolation[2]
    self.windSpeed = conditions[1]
  }

  public init(tmy values: [Double], order: [Int]) {
    self.dni = values[order[0]]
    self.temperature = values[order[1]]
    self.windSpeed = values[order[2]]
    self.ghi = values[order[3]]
    self.dhi = values[order[4]]
  }

  public var description: String {
    String(format: "\nAmbient: %.1f degC", temperature)
      + String(format: "  DNI: %.1f W/m2", dni)
      + String(format: "  GHI: %.1f W/m2", ghi)
      + String(format: "  DHI: %.1f W/m2", dhi)
      + String(format: "  WS: %.1f m/s\n", windSpeed)
  }
}
