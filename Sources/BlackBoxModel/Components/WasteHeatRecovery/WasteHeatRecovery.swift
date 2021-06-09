//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import PhysicalQuantities

public enum WasteHeatRecovery: Parameterizable {
  /// This struct contains the state as well as the functions for mapping the waste heat recovery
  public struct PerformanceData {
    var maintained: Bool
  }
  /// Returns the fixed initial state.
  static let initialState = PerformanceData(maintained: true)
  /// Returns the static parameters.
  public static var parameter: Parameter = ParameterDefaults.whr

  /// Returns the efficiency of the waste heat recovery based on working conditions of the gas turbine
  static func efficiencyFor(gasTurbineLoad: Ratio, heatSolar: Double, gasTurbineGross: Double)
    -> Double
  {
    var efficiency = parameter.efficiencyNominal
    efficiency *= parameter.efficiencySolar(
      heatSolar / Design.layout.heatExchanger
        * SteamTurbine.parameter.efficiencySCC
    )
    efficiency *= parameter.efficiencyGasTurbine(
      gasTurbineGross / GasTurbine.parameter.powerGross
    )
    efficiency *= (1 / GasTurbine.efficiency(at: gasTurbineLoad) - 1)

    debugPrint("Waste heat recovery efficiency at \(efficiency * 100)%")
    assert(efficiency >= 1, "Waste heat recovery efficiency at over 100%")
    return efficiency
  }
}
