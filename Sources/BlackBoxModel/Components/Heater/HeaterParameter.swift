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
  public struct Parameter: ComponentParameter, Codable, Equatable {
    let name: String
    let efficiency, minLoad: Ratio
    var maximumMassFlow, nominalElectricalParasitics: Double
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
      >< "\(efficiency.percentage)"
    d += "Outlet Temperature for Freeze Protection [°C]:"
      >< "\(antiFreezeTemperature.celsius)"
    d += "Nominal Outlet Temperature [°C]:"
      >< "\(nominalTemperatureOut.celsius)"
    d += "Maximum Mass Flow [kg/s]:"
      >< "\(maximumMassFlow)"
    d += "Minimum Load [%]:"
      >< "\(minLoad.percentage)"
    d += "Parasitics at Full Load [MW]:"
      >< "\(nominalElectricalParasitics)"
    d += "Parasitic Energy Coefficients;\nParasitics(Load) = Parasitics(100%)*(c0+c1*load)\n"
    d += "c0:" >< "\(electricalParasitics[0])"
    d += "c1:" >< "\(electricalParasitics[1])"
    d += "Use Heater in Parallel to SF:"
      >< (onlyWithSolarField ? "YES" : "NO ")
    return d
  }
}

extension Heater.Parameter: TextConfigInitializable {
  public init(file: TextConfigFile) throws {
    let line: (Int) throws -> Double = { try file.parseDouble(line: $0) }
    name = file.name
    efficiency = try Ratio(line(10))
    antiFreezeTemperature = try Temperature(line(16))
    nominalTemperatureOut = try Temperature(line(19))
    maximumMassFlow = try line(22)
    minLoad = try Ratio(line(25))
    nominalElectricalParasitics = try line(28)
    electricalParasitics = [try line(31), try line(34)]
    onlyWithSolarField = true
  }
}
