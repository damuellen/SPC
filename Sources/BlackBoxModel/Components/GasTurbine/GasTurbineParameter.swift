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
  public struct Parameter: ComponentParameter, Codable {
    let name: String
    let powerGross, efficiencyISO, loadMin, altitude: Double
    let efficiencyFromLoad, loadMaxFromTemperature, parasiticsFromLoad: Coefficients
    let designTemperature: Double
  }
}

extension GasTurbine.Parameter: CustomStringConvertible {
  public var description: String {
    var d: String = ""
    d += "Description:\t\(name)\n"
    // d += "Gross Power [MW]: \t\(Pgross * 100 / Design.layout.gasTurbine)"
    d += "Efficiency:" >< "\(efficiencyISO * 100)"
    d += "Altitude [m]:" >< "\(altitude)"
    d += "Efficiency; Efficiency(Load) = c0+c1*load+c2*load^2+c3*load^3+c4*load^4)"
    for (i, c) in efficiencyFromLoad.coefficients.enumerated() {
      d += "c\(i):" >< String(format: "%.4E", c)
    }
    d += "Maximum Power as a func of Temperature; Power(T) = GrossPower*(c0+c1*T+c2*T^2+c3*T^3+c4*T^4)"
    for (i, c) in loadMaxFromTemperature.coefficients.enumerated() {
      d += "c\(i):" >< String(format: "%.4E", c)
    }
    d += "Parasitic ; Parasitics(Load) = Parasitcs(100%)*(c0+c1*load+c2*load^2+c3*load^3+c4*load^4)"
    for (i, c) in parasiticsFromLoad.coefficients.enumerated() {
      d += "c\(i):" >< String(format: "%.4E", c)
    }
    return d
  }
}

extension GasTurbine.Parameter: TextConfigInitializable {
  public init(file: TextConfigFile) throws {
    let row: (Int) throws -> Double = { try file.parseDouble(row: $0) }
    name = file.name
    powerGross = try row(10)
    efficiencyISO = try row(13)
    loadMin = try row(16)
    altitude = try row(19)
    efficiencyFromLoad = try [row(41), row(44), row(47), row(50), row(53)]
    loadMaxFromTemperature = try [row(60), row(63), row(66), row(69), row(72)]
    parasiticsFromLoad = try [row(79), row(82), row(85), row(88), row(91)]
    designTemperature = try row(28)
  }
}
