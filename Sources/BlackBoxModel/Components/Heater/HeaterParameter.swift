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
  public struct Parameter: Codable, Equatable {
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
    "Description:" * name
    + "Capacity of HTF-Heater [MW]:" * Design.layout.heater.description
    + "Efficiency [%]:" * efficiency.percentage.description
    + "Outlet Temperature for Freeze Protection [°C]:"
    * antiFreezeTemperature.celsius.description
    + "Nominal Outlet Temperature [°C]:"
    * nominalTemperatureOut.celsius.description
    + "Maximum Mass Flow [kg/s]:" * maximumMassFlow.description
    + "Minimum Load [%]:" * minLoad.percentage.description
    + "Parasitics at Full Load [MW]:" * nominalElectricalParasitics.description
    + "Parasitic Performance Coefficients;\nParasitics(Load) = Parasitics(100%)*(c0+c1*load)\n"
    + "c0:" * electricalParasitics[0].description
    + "c1:" * electricalParasitics[1].description
    + "Use Heater in Parallel to SF:"
    * (onlyWithSolarField ? "YES" : "NO ")
  }
}

extension Heater.Parameter: TextConfigInitializable {
  public init(file: TextConfigFile) throws {
    let ln: (Int) throws -> Double = { try file.double(line: $0) }
    self = try .init(
      name: file.name,
      efficiency: Ratio(ln(10) / 100),
      minLoad: Ratio(ln(25) / 100),
      maximumMassFlow: ln(22),
      nominalElectricalParasitics: ln(28),
      antiFreezeTemperature: Temperature(ln(16)),
      nominalTemperatureOut: Temperature(ln(19)),
      electricalParasitics: [ln(31), ln(34)],
      onlyWithSolarField: true
    )
  }
}
