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
    "Description:" >< name
    + "Capacity of HTF-Heater [MW]:" >< "\(Design.layout.heater)"
    + "Efficiency [%]:" >< "\(efficiency.percentage)"
    + "Outlet Temperature for Freeze Protection [°C]:"
    >< "\(antiFreezeTemperature.celsius)"
    + "Nominal Outlet Temperature [°C]:"
    >< "\(nominalTemperatureOut.celsius)"
    + "Maximum Mass Flow [kg/s]:" >< "\(maximumMassFlow)"
    + "Minimum Load [%]:" >< "\(minLoad.percentage)"
    + "Parasitics at Full Load [MW]:" >< "\(nominalElectricalParasitics)"
    + "Parasitic Energy Coefficients;\nParasitics(Load) = Parasitics(100%)*(c0+c1*load)\n"
    + "c0:" >< "\(electricalParasitics[0])"
    + "c1:" >< "\(electricalParasitics[1])"
    + "Use Heater in Parallel to SF:"
    >< (onlyWithSolarField ? "YES" : "NO ")
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
