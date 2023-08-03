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

extension Boiler {
  /// A struct representing the parameters of the boiler.
  struct Parameter: Codable, Equatable {
    /// The name of the boiler parameter set.
    let name: String
    /// The nominal outlet temperature of the boiler.
    let nominalTemperatureOut: Double
    /// The minimum load percentage of the boiler.
    let minLoad: Double
    /// The nominal electrical parasitics of the boiler.
    let nominalElectricalParasitics: Double
    /// A struct representing the start parameters of the boiler.
    struct StartParameter: Codable, Equatable {
      /// A struct representing the values for cold and warm start parameters.
      struct Values: Codable, Equatable {
        /// The value for cold start.
        let cold: Double
        /// The value for warm start.
        let warm: Double
      }
      /// The hours needed for cold and warm start.
      let hours: Values
      /// The energy performance needed for cold and warm start.
      let energy: Values
    }
    /// The start parameters of the boiler.
    let start: StartParameter
    /// The electrical parasitics and efficiency of the boiler.
    let electricalParasitics, efficiency: Polynomial
    /// Boolean indicating whether booster superheater is used.
    var booster = true
  }
}

extension Boiler.Parameter: CustomStringConvertible {
  /// A description of the `Boiler.Parameter` instance.
  public var description: String {
    "Description:" * name 
    + "Nominal Outlet Temperature [°]:" * nominalTemperatureOut.description
    + "Minimum Load [%]:" * (minLoad * 100).description
    + "Cold Start-up necessary after [h]:" * start.hours.cold.description
    + "Performance needed for Cold Start-up [MWh]:" * start.energy.cold.description
    + "Warm Start-up necessary after [h]:" * start.hours.warm.description
    + "Performance needed for Warm Start-up [MWh]:" * start.energy.warm.description
    + "Parasitics at Full Load [MW]:" * nominalElectricalParasitics.description
    + "Parasitic Performance Coefficients; "
    + "Parasitics(Load) = Parasitics(100%)*(c0+c1*load)\n"
    + "c0:" * electricalParasitics[0].description
    + "c1:" * electricalParasitics[1].description
    + "Efficiency; "
    + "Efficiency(Load) = c0+c1*load+c2*load^2+c3*load^3+c4*load^4)"
    + "\n\(efficiency)"
    + "Booster Superheater (if NO regular boiler selected):"
    * (booster ? "YES" : "NO")
  }
}

extension Boiler.Parameter: TextConfigInitializable {
  /// Creates a `Boiler.Parameter` instance using the data from a `TextConfigFile`.
  /// - Parameter file: The `TextConfigFile` containing the data for the parameter.
  init(file: TextConfigFile) throws {
    let ln: (Int) throws -> Double = { try file.readDouble(lineNumber: $0) }
    self = try .init(
      name: file.name,
      nominalTemperatureOut: ln(10),
      minLoad: ln(13),
      nominalElectricalParasitics: ln(34),
      start: .init(hours: .init(cold: ln(16),
      warm: ln(25)),
      energy: .init(cold: ln(22), warm: ln(31))),
      electricalParasitics: [ln(37), ln(40)],
      efficiency: [ln(50), ln(53), ln(56), ln(59), ln(62)]
    )
  }
}
