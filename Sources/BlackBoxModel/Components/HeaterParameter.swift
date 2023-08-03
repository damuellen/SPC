//
//  Copyright 2023 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Utilities

extension Heater {
  /**
  A struct representing the parameters of the heater.

  The heater parameter set contains the following:
    - Name
    - Efficiency
    - Minimum load
    - Maximum mass flow
    - Nominal electrical parasitics
    - Anti-freeze temperature
    - Nominal outlet temperature
    - Parasitics at full load
    - Parasitic performance coefficients
  */
  struct Parameter: Codable, Equatable {
    /// The name of the heater parameter set.
    let name: String
    /// The efficiency of the heater.
    let efficiency: Ratio
    /// The minimum load of the heater.
    let minLoad: Ratio
    /// The maximum mass flow of the heater.
    var maximumMassFlow: Double
    /// The nominal electrical parasitics of the heater.
    let nominalElectricalParasitics: Double
    /// The anti-freeze temperature of the heater.
    let antiFreezeTemperature: Temperature
    /// The nominal outlet temperature of the heater.
    let nominalTemperatureOut: Temperature
    /// The coefficients for the parasitics function as a function of load.
    let electricalParasitics: [Double]
    /// A boolean indicating whether the heater should be used in parallel to the solar field.
    let onlyWithSolarField: Bool
  }
}

extension Heater.Parameter: CustomStringConvertible {
  /// A description of the `Heater.Parameter` instance.
  public var description: String {
    "Description:" * name
    + "Capacity of HTF-Heater [MW]:" * Design.layout.heater.description
    + "Efficiency [%]:" * efficiency.percentage.description
    + "Outlet Temperature for Freeze Protection [°C]:"
    * String(format: "%3.1f", antiFreezeTemperature.celsius)
    + "Nominal Outlet Temperature [°C]:"
    * String(format: "%3.1f", nominalTemperatureOut.celsius)
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
  /// Creates a `Heater.Parameter` instance using the data from a `TextConfigFile`.
  /// - Parameter file: The `TextConfigFile` containing the data for the parameter.
  init(file: TextConfigFile) throws {
    let ln: (Int) throws -> Double = { try file.readDouble(lineNumber: $0) }
    self = try .init(
      name: file.name,
      efficiency: Ratio(ln(10) / 100),
      minLoad: Ratio(ln(25) / 100),
      maximumMassFlow: ln(22),
      nominalElectricalParasitics: ln(28),
      antiFreezeTemperature: Temperature(celsius: ln(16)),
      nominalTemperatureOut: Temperature(celsius: ln(19)),
      electricalParasitics: [ln(31), ln(34)],
      onlyWithSolarField: true
    )
  }
}
