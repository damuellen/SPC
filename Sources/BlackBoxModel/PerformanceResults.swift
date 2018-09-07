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

public struct PerformanceResults: CustomStringConvertible {
  public var thermal = ThermalEnergy()
  public var fuel = FuelConsumption()
  public var parasitics = Parasitics()
  public var electric = ElectricEnergy()

  // Meteodata: [WHr/sqm]
  public var dni: Double = 0
  public var ghi: Double = 0
  public var dhi: Double = 0
  public var temp: Double = 0
  public var ws: Double = 0

  // SolarField
  public var ico: Double = 0
  public var insolationAbsorber: Double = 0
  public var heatLossSolarField: Double = 0
  public var heatLossHeader: Double = 0
  public var heatLossHCE: Double = 0

  //public var status: Plant.PerformanceData?

  var values: [String] {
    return [
      String(format: "%.1f", dni),
      String(format: "%.1f", ghi),
      String(format: "%.1f", dhi),
      String(format: "%.1f", temp),
      String(format: "%.1f", ws),
      String(format: "%.1f", ico),
      String(format: "%.1f", insolationAbsorber),
      String(format: "%.1f", heatLossSolarField),
      String(format: "%.1f", heatLossHeader),
      String(format: "%.1f", heatLossHCE),
    ]
  }

  var csv: String {
    return String(
      format: "%.1f, %.1f, %.1f, %.1f, %.1f, %.0f, %.0f, %.0f, %.0f, %.0f, ",
      dni, ghi, dhi, temp, ws, ico, insolationAbsorber, heatLossSolarField,
      heatLossHeader, heatLossHCE
    )
  }

  static var columns: [(String, String)] {
    return [
      ("Meteo|DNI", "W/m2"), ("Meteo|GHI", "W/m2"), ("Meteo|DHI", "W/m2"),
      ("Meteo|Temperature", "degC"), ("Meteo|Windspeed", "m/s"),
      ("SolarField|ICO", "W/m2"), ("SolarField|InsolationAbsorber", "W/m2"),
      ("SolarField|HeatLosses", "MWh"), ("SolarField|HeatLossHeader", "MWh"),
      ("SolarField|HeatLossHCE", "MWh"),
    ]
  }

  public var description: String {
    return thermal.description + fuel.description
      + parasitics.description + electric.description
      + zip(values, PerformanceResults.columns).reduce("") { result, next in
        let text = next.1.0 >< (next.0 + " " + next.1.1)
        return result + text
    }
  }

  mutating func add(solarfield: SolarField.PerformanceData, fraction: Double) {
    self.insolationAbsorber += solarfield.insolationAbsorber * fraction
    self.heatLossSolarField += solarfield.heatLosses * fraction
    self.heatLossHeader += solarfield.heatLossHeader * fraction
    self.heatLossHCE += solarfield.heatLossHCE * fraction
  }

  mutating func accumulate(_ result: PerformanceResults, fraction: Double) {
    self.thermal.accumulate(result.thermal, fraction: fraction)
    self.fuel.accumulate(result.fuel, fraction: fraction)
    self.parasitics.accumulate(result.parasitics, fraction: fraction)
    self.electric.accumulate(result.electric, fraction: fraction)
    self.dni += result.dni * fraction
    self.ghi += result.ghi * fraction
    self.dhi += result.dhi * fraction
    self.ico += result.ico * fraction
    self.insolationAbsorber += result.insolationAbsorber * fraction
    self.heatLossSolarField += result.heatLossSolarField * fraction
    self.heatLossHeader += result.heatLossHeader * fraction
    self.heatLossHCE += result.heatLossHCE * fraction
  }

  mutating func reset() {
    self.thermal = ThermalEnergy()
    self.fuel = FuelConsumption()
    self.parasitics = Parasitics()
    self.electric = ElectricEnergy()
    self.dni = 0; self.ghi = 0; self.dhi = 0; self.ico = 0
    self.temp = 0; self.ws = 0
    self.insolationAbsorber = 0; self.heatLossSolarField = 0
    self.heatLossHeader = 0; self.heatLossHCE = 0
  }
}
