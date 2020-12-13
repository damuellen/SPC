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

extension GasTurbine {
  public struct Parameter: ComponentParameter, Codable, Equatable {    
    let name: String
    let powerGross, efficiencyISO, loadMin, altitude: Double
    let efficiencyFromLoad, loadMaxFromTemperature,
      parasiticsFromLoad: Polynomial
    let designTemperature: Double
  }
}

extension GasTurbine.Parameter: CustomStringConvertible {
  public var description: String {
    "Description:" >< name
  // d += "Gross Power [MW]: \t\(Pgross * 100 / Design.layout.gasTurbine)"
    + "Efficiency:" >< "\(efficiencyISO * 100)"
    + "Altitude [m]:" >< "\(altitude)"
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
    let line: (Int) throws -> Double = { try file.parseDouble(line: $0) }
    name = file.name
    powerGross = try line(10)
    efficiencyISO = try line(13)
    loadMin = try line(16)
    altitude = try line(19)
    efficiencyFromLoad = try [line(41), line(44), line(47), line(50), line(53)]
    loadMaxFromTemperature = try [line(60), line(63), line(66), line(69), line(72)]
    parasiticsFromLoad = try [line(79), line(82), line(85), line(88), line(91)]
    designTemperature = try line(28)
  }
}
