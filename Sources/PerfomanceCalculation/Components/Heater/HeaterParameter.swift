//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Config

extension Heater {
  public struct Parameter: ComponentParameter, Codable {
    let name: String
    let efficiency, maxMassFlow, minLoad, nominalElectricalParasitics: Double
    let antiFreezeTemperature, nominalTemperatureOut: Temperature
    let electricalParasitics: [Double]
    let onlyWithSolarField: Bool
  }
}

extension Heater.Parameter: CustomStringConvertible {
  public var description: String {
    var d: String = ""
    d += "Description:\t\(name)\n"
    d += "Capacity of HTF-Heater [MW]:"
      >< "\(Design.layout.heater)"
    d += "Efficiency [%]:"
      >< "\(efficiency)"
    d += "Outlet Temperature for Freeze Protection [°C]:"
      >< "\(antiFreezeTemperature.celsius)"
    d += "Nominal Outlet Temperature [°C]:"
      >< "\(nominalTemperatureOut.celsius)"
    d += "Maximum Mass Flow [kg/s]:"
      >< "\(maxMassFlow)"
    d += "Minimum Load [%]:"
      >< "\(minLoad)"
    d += "Parasitics at Full Load [MW]:"
      >< "\(nominalElectricalParasitics)"
    d += "Parasitic Energy Coefficients; Parasitics(Load) = Parasitics(100%)*(c0+c1*load)"
    d += "c0:" >< "\(electricalParasitics[0])"
    d += "c1:" >< "\(electricalParasitics[1])"
    d += "Use Heater in Parallel to SF:"
      >< (onlyWithSolarField ? "YES" : "NO ")
    return d
  }
}

extension Heater.Parameter: TextConfigInitializable {
  public init(file: TextConfigFile)throws {
    let row: (Int)throws -> Double = { try file.parseDouble(row: $0) }
    self.name = file.name
    self.efficiency = try row(10)
    self.antiFreezeTemperature = try Temperature( row(16))
    self.nominalTemperatureOut = try Temperature( row(19))
    self.maxMassFlow = try row(22)
    self.minLoad = try row(25)
    self.nominalElectricalParasitics = try row(28)
    self.electricalParasitics = [try row(31), try row(34)]
    self.onlyWithSolarField = false
  }
}

