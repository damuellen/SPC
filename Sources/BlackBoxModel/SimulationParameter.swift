// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import Utilities

/// The Simulation namespace contains structures and extensions related to simulation parameters.
extension Simulation {
  /// The Parameter struct represents simulation parameters and is Codable for serialization.
  struct Parameter: Codable {
    /// The temperature difference for start-up of anti-freeze pumping [K].
    let deltaFreezeTemperaturePump: Double
    /// The temperature difference for start-up of anti-freeze heating [K].
    let deltaFreezeTemperatureHeat: Double
    /// The minimum raise of temperature for start-up [K].
    let minTemperatureRaiseStartUp: Double
    /// The tolerance for temperature iteration [K].
    let tempTolerance: Double
    /// The minimum raise of insolation for start-up [W/m²].
    let minInsolationRaiseStartUp: Double
    /// The iteration tolerance for electrical production meeting demand [MW].
    let heatTolerance: Double
    /// The tolerance for time iteration [min].
    let timeTolerance: Double
    /// The tolerance for mass iteration [kg].
    let massTolerance: Double
    /// The minimum insolation for start-up [W/m²].
    let minInsolation: Double
    /// The maximum heat input to power block during boiler operation.
    let maxToPowerBlock: Double
    /// The minimal heat from the solar field required for boiler start-up.
    let minInsolationForBoiler: Double
    /// The iteration tolerance for electrical production [MW].
    let electricalTolerance: Double
    /// The iteration start value for parasitics [% of production].
    let electricalParasitics: Double
    /// The tolerance for temperature drop in hot header iteration [K].
    let heatlossTempTolerance: Double
    /// The adjustment factors for efficiency and heat losses.
    var adjustmentFactor: AdjustmentFactors
  }

  /// The AdjustmentFactors struct represents adjustment factors for efficiency and heat losses and is Codable for serialization.
  struct AdjustmentFactors: Codable {
    /// The adjustment factor for solar field efficiency.
    var efficiencySolarField: Double
    /// The adjustment factor for turbine efficiency.
    var efficiencyTurbine: Double
    /// The adjustment factor for heater efficiency.
    var efficiencyHeater: Double
    /// The adjustment factor for boiler efficiency.
    var efficiencyBoiler: Double
    /// The adjustment factor for heat loss in HCE (Heat Collection Element).
    var heatLossHCE: Double
    /// The adjustment factor for heat loss in HTF system.
    var heatLossHTF: Double
    /// The adjustment factor for heat loss in the power block.
    var heatLossH2O: Double
    /// The adjustment factor for parasitic power.
    var electricalParasitics: Double
  }
}

extension Simulation.AdjustmentFactors: CustomStringConvertible {
  public var description: String {
    "Adjustment factor for Solar Field Efficiency:" * efficiencySolarField.description
    + "Adjustment factor for HCE heat Losses:" * heatLossHCE.description
    + "Adjustment factor for Heat Losses in Piping and HTF- System:" * heatLossHTF.description
    + "Adjustment factor for Heat Losses in Power Block:" * heatLossH2O.description
    + "Adjustment factor for Turbine Efficiency:" * efficiencyTurbine.description
    + "Adjustment factor for Parasitic Power:" * electricalParasitics.description
  }
}

extension Simulation.Parameter: CustomStringConvertible {
  public var description: String {
    "Delta T for Start-Up of Anti-Freeze Pumping:"
    * deltaFreezeTemperaturePump.description
    + "Delta T for Start-Up of Anti-Freeze Heating:"
    * deltaFreezeTemperatureHeat.description
    + "Minimum Raise of Temperature for Start-Up [K]:"
    * minTemperatureRaiseStartUp.description
    + "Minimum Raise of Insolation for Start-Up [W/m²]:"
    * minInsolationRaiseStartUp.description
    + "Iteration Tolerance for Electrical Production meeting demand [MW]:"
    * heatTolerance.description
    + "Tolerance for Temperature Iteration [K]:" * tempTolerance.description
    + "Tolerance for Time Iteration [min]:" * timeTolerance.description
    + "Tolerance for Mass Iteration [kg]:" * massTolerance.description
    + "Minimum Insolation for Start-Up [W/m²]:" * minInsolation.description
    + "\(adjustmentFactor)"
    + "Maximal heat input to power block (Boiler Operation):"
    * maxToPowerBlock.description
    + "Minimal heat from solar field for boiler start-up:"
    * minInsolationForBoiler.description
    + "Iteration Tolerance for Electrical Production [MW]:"
    * electricalTolerance.description
    + "Iteration Start Value for Parasitics [% of production]:"
    * "\(electricalParasitics * 100)"
    + "Tolerance for Temperature Drop in Hot Header Iteration [K]:"
    * heatlossTempTolerance.description
  }
}

extension Simulation.Parameter: TextConfigInitializable {
  init(file: TextConfigFile) throws {
    let ln: (Int) throws -> Double = { try file.readDouble(lineNumber: $0) }
    let adjustmentFactor = try Simulation.AdjustmentFactors(
      efficiencySolarField: ln(34),
      efficiencyTurbine: ln(46),
      efficiencyHeater: ln(52),
      efficiencyBoiler: ln(55),
      heatLossHCE: ln(61),
      heatLossHTF: ln(40),
      heatLossH2O: ln(43),
      electricalParasitics: ln(61) / 100
    )

    self = try Simulation.Parameter(
      deltaFreezeTemperaturePump: ln(7),
      deltaFreezeTemperatureHeat: ln(10),
      minTemperatureRaiseStartUp: ln(13),
      tempTolerance: ln(22),
      minInsolationRaiseStartUp: ln(16),
      heatTolerance: ln(19),
      timeTolerance: ln(25),
      massTolerance: ln(28),
      minInsolation: ln(31),
      maxToPowerBlock: ln(16),
      minInsolationForBoiler: ln(16),
      electricalTolerance: ln(58),
      electricalParasitics: ln(19),
      heatlossTempTolerance: 0.1,
      adjustmentFactor: adjustmentFactor
    )
  }
}
