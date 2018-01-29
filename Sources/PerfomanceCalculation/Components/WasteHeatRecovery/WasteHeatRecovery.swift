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

extension WasteHeatRecovery.Instance: CustomDebugStringConvertible {
  var debugDescription: String { return "\(workingConditions.current)" }
}

public enum WasteHeatRecovery: Component {
  
  final class Instance {
    // A singleton class holding the state of the waste heat recovery
    fileprivate static let shared = Instance()
    var parameter: WasteHeatRecovery.Parameter!
    var workingConditions: (previous: PerformanceData?, current: PerformanceData)
    
    private init() {
      workingConditions = (nil, initialState)
    }
  }

  /// a struct for operation-relevant data of the waste heat recovery
  public struct PerformanceData: WorkingConditions {
    var maintained: Bool
  }

  fileprivate static let initialState = PerformanceData(maintained: true)

  /// Returns the current working conditions of the waste heat recovery
  public static var status: PerformanceData {
    get { return Instance.shared.workingConditions.current }
    set {
      Instance.shared.workingConditions =
       (Instance.shared.workingConditions.current, newValue) 
    }
  }

  /// Returns the previous working conditions of the waste heat recovery
  private static var previous: PerformanceData? {
    return Instance.shared.workingConditions.previous
  }

  public static var parameter: WasteHeatRecovery.Parameter {
    get { return Instance.shared.parameter }
    set { Instance.shared.parameter = newValue }
  }

  /// Returns the efficiency of the waste heat recovery based on working conditions of the gas turbine
  public static func efficiency(gasTurbineLoad: Ratio) -> Double {
    var efficiency = WasteHeatRecovery.parameter.efficiencyNominal
    efficiency *= WasteHeatRecovery.parameter.efficiencySolar[
      Plant.heatFlow.solar / Design.layout.heatExchanger
        * SteamTurbine.parameter.efficiencySCC]
    efficiency *= WasteHeatRecovery.parameter.efficiencyGasTurbine[
      Plant.electricEnergy.gasTurbineGross / GasTurbine.parameter.Pgross]
    efficiency *=  (1 / GasTurbine.efficiency(at: gasTurbineLoad) - 1)

    debugPrint("waste heat recovery efficiency at \(efficiency * 100)%")
    precondition(efficiency > 1, "waste heat recovery efficiency at over 100%")
    return efficiency
  }
}
