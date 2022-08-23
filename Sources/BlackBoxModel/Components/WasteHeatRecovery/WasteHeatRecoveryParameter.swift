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

extension WasteHeatRecovery {
  public struct Parameter: Codable {
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
    "Operation Mode:" * operation.rawValue
    + "Efficiency in Hybrid Mode:" * (efficiencyNominal * 100).description
    + "Efficiency in CC Mode:" * (efficiencyPure * 100).description
    + "Ratio Fossil/Solar Thermal Contribution :" * ratioHTF.description
    + "Efficiency(Solar-Load) = c0+c1*load+c2*load^2+c3*load^3+c4*load^4)"
    + "\n\(efficiencySolar)"
    + "Efficiency(GT-Load) = c0+c1*load+c2*load^2+c3*load^3+c4*load^4)"
    + "\n\(efficiencyGasTurbine)"
  }
}

extension WasteHeatRecovery.Parameter: TextConfigInitializable {
  public init(file: TextConfigFile) throws {
    let ln: (Int) throws -> Double = { try file.double(line: $0) }
    self = try .init(
      name: file.name,
      operation: .integrated,
      efficiencyNominal: ln(13),
      efficiencyPure: ln(16),
      ratioHTF: ln(19),
      efficiencySolar: [ln(32), ln(35), ln(38), ln(41), ln(44)],
      efficiencyGasTurbine: [ln(47), ln(50), ln(53), ln(56), ln(59)]
    )
  }
}
