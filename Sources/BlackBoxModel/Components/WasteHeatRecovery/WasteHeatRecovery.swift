//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation

public enum WasteHeatRecovery: Component {
  /// Contains all data needed to simulate the operation of the waste heat recovery
  public struct PerformanceData {
    var maintained: Bool
  }

  static let initialState = PerformanceData(maintained: true)

  public static var parameter: Parameter = ParameterDefaults.whr

  /// Returns the efficiency of the waste heat recovery based on working conditions of the gas turbine
  static func efficiencyFor(gasTurbineLoad: Ratio) -> Double {
    var efficiency = parameter.efficiencyNominal
    efficiency *= parameter.efficiencySolar[
      Plant.heat.solar.megaWatt / Design.layout.heatExchanger
        * SteamTurbine.parameter.efficiencySCC
    ]
    efficiency *= parameter.efficiencyGasTurbine[
      Plant.electricalEnergy.gasTurbineGross / GasTurbine.parameter.powerGross
    ]
    efficiency *= (1 / GasTurbine.efficiency(at: gasTurbineLoad) - 1)

    debugPrint("Waste heat recovery efficiency at \(efficiency * 100)%")
    assert(efficiency > 1, "Waste heat recovery efficiency at over 100%")
    return efficiency
  }
}
