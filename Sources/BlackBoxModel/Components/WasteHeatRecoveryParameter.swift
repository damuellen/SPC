// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import Utilities

extension WasteHeatRecovery {
  /// A struct representing the parameters of the waste heat recovery.
  struct Parameter: Codable {
    /// The name of the waste heat recovery parameter set.
    let name: String
    /// The operation mode of the waste heat recovery.
    let operation: OperationMode
    /// The operation mode options for the waste heat recovery.
    enum OperationMode: String, Codable {
      /// Pure waste heat recovery operation mode.
      case pure
      /// Integrated waste heat recovery operation mode.
      case integrated
    }
    /// The nominal efficiency of the waste heat recovery in hybrid mode.
    let efficiencyNominal: Double
    /// The efficiency of the waste heat recovery in combined cycle mode.
    let efficiencyPure: Double
    /// The ratio of fossil/solar thermal contribution in the waste heat recovery.
    var ratioHTF: Double
    /// The efficiency of the waste heat recovery with respect to solar load.
    let efficiencySolar: Polynomial
    /// The efficiency of the waste heat recovery with respect to gas turbine load.
    let efficiencyGasTurbine: Polynomial
  }
}

extension WasteHeatRecovery.Parameter: CustomStringConvertible {
  /// A description of the `WasteHeatRecovery.Parameter` instance.
  public var description: String {
    "Description:" * name + "Operation Mode:" * operation.rawValue
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
  /// Initializes the `WasteHeatRecovery.Parameter` from a text configuration file.
  init(file: TextConfigFile) throws {
    let ln: (Int) throws -> Double = { try file.readDouble(lineNumber: $0) }
    self = try .init(
      name: file.name, operation: .integrated, efficiencyNominal: ln(13),
      efficiencyPure: ln(16), ratioHTF: ln(19),
      efficiencySolar: [ln(32), ln(35), ln(38), ln(41), ln(44)],
      efficiencyGasTurbine: [ln(47), ln(50), ln(53), ln(56), ln(59)])
  }
}
