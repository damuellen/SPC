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

extension GasTurbine {
/**
 A struct representing the parameters of the gas turbine.

 The gas turbine parameter set contains the following:
   - Name
   - Gross power
   - ISO efficiency
   - Minimum load
   - Altitude
   - Efficiency as a function of load (polynomial coefficients)
   - Maximum power as a function of temperature (polynomial coefficients)
   - Parasitics as a function of load (polynomial coefficients)
   - Design temperature
 */
  struct Parameter: Codable, Equatable {
    /// The name of the gas turbine parameter set.
    let name: String
    /// The gross power of the gas turbine.
    let powerGross: Double
    /// The ISO efficiency of the gas turbine.
    let efficiencyISO: Double
    /// The minimum load of the gas turbine.
    let loadMin: Double
    /// The altitude at which the gas turbine operates.
    let altitude: Double
    /// The coefficients for the efficiency function as a function of load.
    let efficiencyFromLoad: Polynomial
    /// The coefficients for the maximum power function as a function of temperature.
    let loadMaxFromTemperature: Polynomial
    /// The coefficients for the parasitics function as a function of load.
    let parasiticsFromLoad: Polynomial
    /// The design temperature for the gas turbine.
    let designTemperature: Double
  }
}

extension GasTurbine.Parameter: CustomStringConvertible {
  /// A description of the `GasTurbine.Parameter` instance.
  public var description: String {
    "Description:" * name
  // d += "Gross Power [MW]: \t\(Pgross * 100 / Design.layout.gasTurbine)"
    + "Efficiency:" * (efficiencyISO * 100).description
    + "Altitude [m]:" * altitude.description
    + "Efficiency; "
    + "Efficiency(Load) = c0+c1*load+c2*load^2+c3*load^3+c4*load^4)"
    + "\n\(efficiencyFromLoad)"
    + "Maximum Power as a func of temperature; "
    + "Power(T) = GrossPower*(c0+c1*T+c2*T^2+c3*T^3+c4*T^4)"
    + "\n\(loadMaxFromTemperature)"
    + "Parasitic as a func of load; "
    + "Parasitics(Load) = Parasitcs(100%)*(c0+c1*load+c2*load^2+c3*load^3+c4*load^4)"
    + "\n\(parasiticsFromLoad)"
  }
}

extension GasTurbine.Parameter: TextConfigInitializable {
  /// Creates a `GasTurbine.Parameter` instance using the data from a `TextConfigFile`.
  /// - Parameter file: The `TextConfigFile` containing the data for the parameter.
  init(file: TextConfigFile) throws {
    let ln: (Int) throws -> Double = { try file.readDouble(lineNumber: $0) }
    self = try .init(
      name: file.name,
      powerGross: ln(10),
      efficiencyISO: ln(13),
      loadMin: ln(16),
      altitude: ln(19),
      efficiencyFromLoad: [ln(41), ln(44), ln(47), ln(50), ln(53)],
      loadMaxFromTemperature: [ln(60), ln(63), ln(66), ln(69), ln(72)],
      parasiticsFromLoad: [ln(79), ln(82), ln(85), ln(88), ln(91)],
      designTemperature: ln(28)
    )
  }
}
