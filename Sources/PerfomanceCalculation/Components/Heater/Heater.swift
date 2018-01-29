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

extension Heater.Instance: CustomDebugStringConvertible {
  var debugDescription: String { return "\(workingConditions.current)" }
}

public enum Heater: Component {
  
  final class Instance {
    // A singleton class holding the state of the heater
    fileprivate static let shared = Instance()
    var parameter: Heater.Parameter!
    var workingConditions: (previous: PerformanceData?, current: PerformanceData)
    
    private init() {
      workingConditions = (nil, initialState)
    }
  }
  
  /// a struct for operation-relevant data of the heater
  public struct PerformanceData: Equatable, HeatTransfer, WorkingConditions {
    var operationMode: OperationMode
    var isMaintained: Bool
    var load: Ratio
    var temperature: (inlet: Temperature, outlet: Temperature)
    var massFlow: MassFlow
    var totalMassFlow, heatIn: Double
    
    public enum OperationMode: String, CustomStringConvertible {
      case normal, charge, reheat, freezeProtection,
      noOperation, maintenance, unknown
      
      public var description: String {
        return self.rawValue
      }
    }
    
    public static func ==(lhs: PerformanceData, rhs: PerformanceData) -> Bool {
      return lhs.operationMode == rhs.operationMode
        && lhs.isMaintained == rhs.isMaintained
        && lhs.load == rhs.load
        && lhs.temperature == rhs.temperature
        && lhs.massFlow == rhs.massFlow
        && lhs.totalMassFlow == rhs.totalMassFlow
        && lhs.heatIn == rhs.heatIn
    }
  }
  
  /// working conditions of the heater at start
  fileprivate static let initialState = PerformanceData(
    operationMode: .noOperation,
    isMaintained: false,
    load: 0.0,
    temperature: (inlet: Simulation.initialValues.temperatureOfHTFinPipes,
                  outlet: Simulation.initialValues.temperatureOfHTFinPipes),
    massFlow: 0.0,
    totalMassFlow: 0.0,
    heatIn: 0.0
  )
  
  /// Returns the current working conditions of the heater
  public static var status: PerformanceData {
    get { return Instance.shared.workingConditions.current }
    set {
      if Instance.shared.workingConditions.current != newValue {
        Log.debugMessage("Heater \(Instance.shared.workingConditions.current)")
        Instance.shared.workingConditions =
          (Instance.shared.workingConditions.current, newValue)
      }
    }
  }
  
  /// Returns the previous working conditions of the heater
  private static var previous: PerformanceData? {
    return Instance.shared.workingConditions.previous
  }
  
  public static var parameter: Heater.Parameter {
    get { return Instance.shared.parameter }
    set { Instance.shared.parameter = newValue }
  }
  
  /// Calculates the parasitics of the heater which only depends on the current load
  public static func parasitics(at load: Ratio) -> Double {
    return parameter.nominalElectricalParasitics *
      (parameter.electricalParasitics[0]
        + parameter.electricalParasitics[1] * load.ratio)
  }
  
  fileprivate static func noOperation(_ heater: inout Heater.PerformanceData) {
    heater.operationMode = .noOperation
    heater.load = 0.0
    heater.massFlow = 0.0
  }
  
  public static func operate(_ heater: inout Heater.PerformanceData,
                             powerBlock: inout PowerBlock.PerformanceData,
                             steamTurbine: SteamTurbine.PerformanceData,
                             storage: Storage.PerformanceData,
                             solarField: SolarField.PerformanceData,
                             demand heat: Double,
                             availableFuel: Double,
                             heatFlow: inout HeatFlow,
                             fuelFlow: inout Double) {
    // Freeze protection is always possible: massFlow fixed
    if case .charge = heater.operationMode {
      // Fossil charge of storage
      if Fuelmode == "predefined" {
        // fuel consumption is predefined
        fuelFlow = availableFuel / hourFraction / 2
        // The fuelfl avl. [MW]
        heatFlow.heater = fuelFlow * parameter.efficiency
          * Simulation.parameter.adjustmentFactor.efficiencyHeater
        // net thermal power avail [MW]
        heater.load = Ratio(heatFlow.heater / Design.layout.heater) // load avail.
        
        guard heater.load.ratio > parameter.minLoad else {
          ////report = "HR operation requested but not performed because of HR underload.\n"
          noOperation(&heater)
          heatFlow.heater = 0
          return
        }
        // Normal operation possible -
        
        heater.operationMode = .normal
        // if Reheating, then do not change displayed operating status / mode
        heater.temperature.outlet = parameter.nominalTemperatureOut
        
        // Calc. mass flow that can be achieved [kg/sec] = [MJ/sec] * 1000 / [kJ/kg]
        
        if Design.hasStorage, case .ph = storage.operationMode {
          heater.massFlow = storage.massFlow
        } else {
          heater.massFlow = MassFlow(heatFlow.heater * 1_000
            / htf.heatDelta(heater.temperature.outlet,
                            powerBlock.temperature.inlet))
        }
      } else {
        if powerBlock.temperature.inlet == parameter.nominalTemperatureOut {
          powerBlock.temperature.inlet = -1.0 // FIXME
        }
        heater.massFlow = MassFlow(Design.layout.heater
          / htf.heatDelta(parameter.nominalTemperatureOut,
                          powerBlock.temperature.inlet))
        
        fuelFlow = Design.layout.heater / parameter.efficiency
        heater.load = 1.0
        // Parasitic power [MW]
        heatFlow.heater = Design.layout.heater
        // return
      }
    } else if case .freezeProtection = heater.operationMode {
      heatFlow.heater = heater.massFlow.rate * htf.heatDelta(
        parameter.antiFreezeTemperature, heater.temperature.inlet) / 1_000
      
      if heatFlow.heater > Design.layout.heater {
        heatFlow.heater = Design.layout.heater
        if heater.massFlow.rate > 0 {
          heater.temperature.outlet = htf.temperatureDelta(
            heatFlow.heater * 1_000 / heater.massFlow.rate, heater.temperature.inlet)
        }
      } else {
        heater.temperature.outlet = parameter.antiFreezeTemperature
      }
      // [MW]=[kg/sec]*[kJ/kg]/1000
      fuelFlow = heatFlow.heater / parameter.efficiency
      heater.load = Ratio(heatFlow.heater / Design.layout.heater)
      // return
      // No operation requested or QProd > QNeed
    } else if case .noOperation = heater.operationMode { /* || heat >= 0 */
      noOperation(&heater)
      if heater.isMaintained {
        heater.operationMode = .maintenance
      }
      heater.temperature.outlet = solarField.header.temperature.outlet
      heatFlow.heater = 0
    } else if heater.isMaintained {
      // operation is requested
      ////report = "Sched. maintnc. of HR disables requested operation.\n"
      noOperation(&heater)
      heater.operationMode = .maintenance
      heatFlow.heater = 0
    } else {
      // Normal operation requested  The fuel flow needed [MW]
      fuelFlow = min(-heat, Design.layout.heater) / parameter.efficiency
        / Simulation.parameter.adjustmentFactor.efficiencyHeater
      // The fuelfl avl. [MW]
      fuelFlow = min(availableFuel, fuelFlow * hourFraction) / hourFraction
      // net thermal power avail [MW]
      heatFlow.heater = fuelFlow * parameter.efficiency
        * Simulation.parameter.adjustmentFactor.efficiencyHeater
      heater.load = Ratio(heatFlow.heater / Design.layout.heater) // load avail.
      
      // if heateroperationMode { // added, shams-1
      if heater.load.ratio < parameter.minLoad {
        heater.load = Ratio(parameter.minLoad)
        heatFlow.heater = heater.load.ratio * Design.layout.heater
        fuelFlow = heatFlow.heater / parameter.efficiency
      }
      // }
      guard heater.load.ratio > parameter.minLoad else {
        // report = "HR operation requested but not performed because of HR underload.\n"
        noOperation(&heater)
        heatFlow.heater = 0
        return
      }
      // Normal operation possible
      if case .reheat = heater.operationMode {
        heater.operationMode = .normal
      }
      // if Reheating, then do not change displayed operating status / mode
      heater.temperature.outlet = parameter.nominalTemperatureOut
      // Calc. mass flow that can be achieved [kg/sec] = [MJ/sec] * 1000 / [kJ/kg]
      if Design.hasStorage, case .ph = storage.operationMode {
        heater.massFlow = storage.massFlow
      } else {
        heater.massFlow = MassFlow(heatFlow.heater * 1_000
          / htf.heatDelta(heater.temperature.outlet,
                          heater.temperature.inlet))
      }
    }
    noOperation(&heater)
    heatFlow.heater = 0
  }
}
