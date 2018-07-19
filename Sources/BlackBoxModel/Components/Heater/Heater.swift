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

extension Heater.PerformanceData: CustomStringConvertible {
  
  public var description: String {
    return "\(operationMode), "
      + "Maintenance: \(isMaintained ? "Yes" : "No"), "
      + String(format:"Load: %.1f%, ", load.percentage)
      + String(format:"Mfl: %.1f, ", totalMassFlow)
      + String(format:"Heat In: %.1f", heatIn)
  }
}

public enum Heater: Component {
  
  /// a struct for operation-relevant data of the heater
  public struct PerformanceData: Equatable, HeatCycle {
    var name = ""
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
  static let initialState = PerformanceData(
    name: "",
    operationMode: .noOperation,
    isMaintained: false,
    load: 0.0,
    temperature: (inlet: Simulation.initialValues.temperatureOfHTFinPipes,
                  outlet: Simulation.initialValues.temperatureOfHTFinPipes),
    massFlow: 0.0,
    totalMassFlow: 0.0,
    heatIn: 0.0
  )
  
  static var parameter: Parameter = ParameterDefaults.hr
  
  /// Calculates the parasitics of the heater which only depends on the current load
  static func parasitics(at load: Ratio) -> Double {
    return parameter.nominalElectricalParasitics *
      (parameter.electricalParasitics[0]
        + parameter.electricalParasitics[1] * load.ratio)
  }
  
  fileprivate static func noOperation(_ heater: inout Heater.PerformanceData) {
    heater.operationMode = .noOperation
    heater.load = 0.0
    heater.massFlow = 0.0
  }
  
  static func update(_ status: inout Plant.PerformanceData,
                     demand heat: Double,
                     availableFuel: Double,
                     thermal: inout ThermalEnergy,
                     fuelFlow: inout Double) {
    // Freeze protection is always possible: massFlow fixed
    if case .charge = status.heater.operationMode {
      // Fossil charge of storage
      if Fuelmode == "predefined" {
        // fuel consumption is predefined
        fuelFlow = availableFuel / hourFraction / 2
        // The fuelfl avl. [MW]
        thermal.heater = fuelFlow * parameter.efficiency
          * Simulation.adjustmentFactor.efficiencyHeater
        // net thermal power avail [MW]
        status.heater.load = Ratio(thermal.heater / Design.layout.heater) // load avail.
        
        guard status.heater.load.ratio > parameter.minLoad else {
          ////report = "HR operation requested but not performed because of HR underload.\n"
          noOperation(&status.heater)
          thermal.heater = 0
          return
        }
        // Normal operation possible -
        
        status.heater.operationMode = .normal
        // if Reheating, then do not change displayed operating status / mode
        status.heater.temperature.outlet = parameter.nominalTemperatureOut
        
        // Calc. mass flow that can be achieved [kg/sec] = [MJ/sec] * 1000 / [kJ/kg]
        
        if Design.hasStorage, case .ph = status.storage.operationMode {
          status.heater.massFlow = status.storage.massFlow
        } else {
          status.heater.massFlow = MassFlow(thermal.heater * 1_000
            / htf.heatDelta(status.heater.temperature.outlet,
                            status.powerBlock.temperature.inlet))
        }
      } else {
        if status.powerBlock.temperature.inlet == parameter.nominalTemperatureOut {
          status.powerBlock.temperature.inlet = -1.0 // FIXME
        }
        status.heater.massFlow = MassFlow(Design.layout.heater
          / htf.heatDelta(parameter.nominalTemperatureOut,
                           status.powerBlock.temperature.inlet))
        
        fuelFlow = Design.layout.heater / parameter.efficiency
        status.heater.load = 1.0
        // Parasitic power [MW]
        thermal.heater = Design.layout.heater
        // return
      }
    } else if case .freezeProtection = status.heater.operationMode {
      thermal.heater = status.heater.massFlow.rate * htf.heatDelta(
        parameter.antiFreezeTemperature, status.heater.temperature.inlet) / 1_000
      
      if thermal.heater > Design.layout.heater {
        thermal.heater = Design.layout.heater
        if status.heater.massFlow.rate > 0 {
          status.heater.temperature.outlet = htf.temperatureDelta(
            thermal.heater * 1_000 / status.heater.massFlow.rate,
            status.heater.temperature.inlet)
        }
      } else {
        status.heater.temperature.outlet = parameter.antiFreezeTemperature
      }
      // [MW]=[kg/sec]*[kJ/kg]/1000
      fuelFlow = thermal.heater / parameter.efficiency
      status.heater.load = Ratio(thermal.heater / Design.layout.heater)
      // return
      // No operation requested or QProd > QNeed
    } else if case .noOperation = status.heater.operationMode { /* || heat >= 0 */
      noOperation(&status.heater)
      if status.heater.isMaintained {
        status.heater.operationMode = .maintenance
      }
      status.heater.temperature.outlet = status.solarField.header.temperature.outlet
      thermal.heater = 0
    } else if status.heater.isMaintained {
      // operation is requested
      ////report = "Sched. maintnc. of HR disables requested operation.\n"
      noOperation(&status.heater)
      status.heater.operationMode = .maintenance
      thermal.heater = 0
    } else {
      // Normal operation requested  The fuel flow needed [MW]
      fuelFlow = min(-heat, Design.layout.heater) / parameter.efficiency
        / Simulation.adjustmentFactor.efficiencyHeater
      // The fuelfl avl. [MW]
      fuelFlow = min(availableFuel, fuelFlow * hourFraction) / hourFraction
     // fuelFlow = max(fuelFlow, 0)
      // net thermal power avail [MW]
      thermal.heater = fuelFlow * parameter.efficiency
        * Simulation.adjustmentFactor.efficiencyHeater
      
      status.heater.load = Ratio(thermal.heater / Design.layout.heater) // load avail.
      
      // if heateroperationMode { // added, shams-1
      if status.heater.load.ratio < parameter.minLoad {
        status.heater.load = Ratio(parameter.minLoad)
        thermal.heater = status.heater.load.ratio * Design.layout.heater
        fuelFlow = thermal.heater / parameter.efficiency
      }
      // }
      guard status.heater.load.ratio > parameter.minLoad else {
        // report = "HR operation requested but not performed because of HR underload.\n"
        noOperation(&status.heater)
        thermal.heater = 0
        return
      }
      // Normal operation possible
      if case .reheat = status.heater.operationMode {
        status.heater.operationMode = .normal
      }
      // if Reheating, then do not change displayed operating status / mode
     status.heater.temperature.outlet = parameter.nominalTemperatureOut
      // Calc. mass flow that can be achieved [kg/sec] = [MJ/sec] * 1000 / [kJ/kg]
      if Design.hasStorage, case .ph = status.storage.operationMode {
        status.heater.massFlow = status.storage.massFlow
      } else {
        status.heater.massFlow = MassFlow(thermal.heater * 1_000
          / htf.heatDelta(status.heater.temperature.outlet,
                          status.heater.temperature.inlet))
      }
    }
   // noOperation(&status.heater)
   // thermal.heater = 0
  }
}
