//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Utilities

extension GasTurbine {
  /// A struct with the assigned details of the gas turbine
  public struct Parameter: Codable, Equatable {    
    let name: String
    let powerGross, efficiencyISO, loadMin, altitude: Double
    let efficiencyFromLoad, loadMaxFromTemperature,
      parasiticsFromLoad: Polynomial
    let designTemperature: Double
  }
}

extension GasTurbine.Parameter: CustomStringConvertible {
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
  public init(file: TextConfigFile) throws {
    let ln: (Int) throws -> Double = { try file.double(line: $0) }
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
