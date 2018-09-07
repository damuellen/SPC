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

extension WasteHeatRecovery {
  public struct Parameter: ComponentParameter, Codable {
    let name: String
    let operation: Operation

    public enum Operation: String, Codable {
      case pure, integrated
    }

    let efficiencyNominal: Double
    let efficiencyPure: Double
    var ratioHTF: Double
    let efficiencySolar: Coefficients
    let efficiencyGasTurbine: Coefficients
  }
}

extension WasteHeatRecovery.Parameter: CustomStringConvertible {
  public var description: String {
    var d = ""
    d += "Operation Mode:" >< operation.rawValue
    d += "Efficiency in Hybrid Mode:" >< "\(efficiencyNominal * 100)"
    d += "Efficiency in CC Mode:" >< "\(efficiencyPure * 100)"
    d += "Ratio Fossil/Solar Thermal Contribution :" >< "\(ratioHTF)"
    d += "Efficiency(Solar-Load) = c0+c1*load+c2*load^2+c3*load^3+c4*load^4)\n"
    for (i, c) in efficiencySolar.coefficients.enumerated() {
      d += "c\(i):" >< String(format: "%.4E", c)
    }
    d += "Efficiency(GT-Load) = c0+c1*load+c2*load^2+c3*load^3+c4*load^4)\n"
    for (i, c) in efficiencyGasTurbine.coefficients.enumerated() {
      d += "c\(i):" >< String(format: "%.4E", c)
    }
    return d
  }
}

extension WasteHeatRecovery.Parameter: TextConfigInitializable {
  public init(file: TextConfigFile) throws {
    let row: (Int) throws -> Double = { try file.parseDouble(row: $0) }
    name = file.name
    operation = .integrated
    efficiencyNominal = try row(13)
    efficiencyPure = try row(16)
    ratioHTF = try row(19)
    efficiencySolar = try [row(32), row(35), row(38), row(41), row(44)]
    efficiencyGasTurbine = try [row(47), row(50), row(53), row(56), row(59)]
  }
}
