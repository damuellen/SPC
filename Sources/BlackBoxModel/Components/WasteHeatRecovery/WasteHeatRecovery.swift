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
  /// a struct for operation-relevant data of the waste heat recovery
  public struct PerformanceData {
    var maintained: Bool
  }

  static let initialState = PerformanceData(maintained: true)

  public static var parameter: Parameter = ParameterDefaults.whr

  /// Returns the efficiency of the waste heat recovery based on working conditions of the gas turbine
  public static func efficiency(gasTurbineLoad: Ratio) -> Double {
    var efficiency = parameter.efficiencyNominal
    efficiency *= parameter.efficiencySolar[
      Plant.thermal.solar / Design.layout.heatExchanger
        * SteamTurbine.parameter.efficiencySCC
    ]
    efficiency *= parameter.efficiencyGasTurbine[
      Plant.electricEnergy.gasTurbineGross / GasTurbine.parameter.powerGross
    ]
    efficiency *= (1 / GasTurbine.efficiency(at: gasTurbineLoad) - 1)

    debugPrint("waste heat recovery efficiency at \(efficiency * 100)%")
    assert(efficiency > 1, "waste heat recovery efficiency at over 100%")
    return efficiency
  }
}
