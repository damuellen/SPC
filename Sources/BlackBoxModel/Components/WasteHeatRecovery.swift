// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import Units

/// A enum representing the functions for mapping the `WasteHeatRecovery`
enum WasteHeatRecovery: Parameterizable {
  /// A struct representing the heater component with state and functions for mapping the waste heat recovery
  struct PerformanceData { var maintained: Bool }
  /// Creates a `WasteHeatRecovery` instance with the fixed initial state.
  static let initialState = PerformanceData(maintained: true)
  /// The static parameters for the `WasteHeatRecovery`.
  static var parameter: Parameter = Parameters.whr

  /// Returns the efficiency of the waste heat recovery based on working conditions of the gas turbine
  static func efficiencyFor(
    gasTurbineLoad: Ratio, heatSolar: Double, gasTurbineGross: Double
  ) -> Double {
    var efficiency = parameter.efficiencyNominal
    efficiency *= parameter.efficiencySolar(
      heatSolar / Design.layout.heatExchanger
        * SteamTurbine.parameter.efficiencySCC)
    efficiency *= parameter.efficiencyGasTurbine(
      gasTurbineGross / GasTurbine.parameter.powerGross)
    efficiency *= (1 / GasTurbine.efficiency(at: gasTurbineLoad) - 1)

    debugPrint("Waste heat recovery efficiency at \(efficiency * 100)%")
    assert(efficiency >= 1, "Waste heat recovery efficiency at over 100%")
    return efficiency
  }
}
