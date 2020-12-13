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
    let operation: OperationMode

    public enum OperationMode: String, Codable {
      case pure, integrated
    }

    let efficiencyNominal: Double
    let efficiencyPure: Double
    var ratioHTF: Double
    let efficiencySolar: Polynomial
    let efficiencyGasTurbine: Polynomial
  }
}

extension WasteHeatRecovery.Parameter: CustomStringConvertible {
  public var description: String {
    "Operation Mode:" >< operation.rawValue
    + "Efficiency in Hybrid Mode:" >< "\(efficiencyNominal * 100)"
    + "Efficiency in CC Mode:" >< "\(efficiencyPure * 100)"
    + "Ratio Fossil/Solar Thermal Contribution :" >< "\(ratioHTF)"
    + "Efficiency(Solar-Load) = c0+c1*load+c2*load^2+c3*load^3+c4*load^4)"
    + "\n\(efficiencySolar)"
    + "Efficiency(GT-Load) = c0+c1*load+c2*load^2+c3*load^3+c4*load^4)"
    + "\n\(efficiencyGasTurbine)"
  }
}

extension WasteHeatRecovery.Parameter: TextConfigInitializable {
  public init(file: TextConfigFile) throws {
    let line: (Int) throws -> Double = { try file.parseDouble(line: $0) }
    name = file.name
    operation = .integrated
    efficiencyNominal = try line(13)
    efficiencyPure = try line(16)
    ratioHTF = try line(19)
    efficiencySolar = try [line(32), line(35), line(38), line(41), line(44)]
    efficiencyGasTurbine = try [line(47), line(50), line(53), line(56), line(59)]
  }
}
