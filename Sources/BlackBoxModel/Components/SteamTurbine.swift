//
//  Copyright 2023 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import DateExtensions
import Meteo
import Utilities

extension SteamTurbine: CustomStringConvertible {
  public var description: String {
    "  Mode:".padding(20) + "\(operationMode)".padding(30) + "\(efficiency)"
  }
}

extension SteamTurbine.OperationMode: CustomStringConvertible {
  public var description: String {
    switch self {
      case .noOperation(let minutes): return "No Operation \(minutes)min "
      case .operating(let load): return "Operation \(load.singleBar)"
      case .startUp(let minutes, energy: let energy):
       return "Start up \(minutes)min energy: \(energy)"
      case .scheduledMaintenance: return "Scheduled Maintenance"
    }
  }
}

/// This struct contains the state as well as the functions for mapping the steam turbine
public struct SteamTurbine: Parameterizable {
  
  /// Returns the operating state
  public internal(set) var operationMode: OperationMode
  /// Returns the load applied
  public internal(set) var load: Ratio {
    get { 
      if case .operating(let load) = operationMode
        { return load } else { return .zero }
    }
    set { 
      if case .operating(_) = operationMode 
        { operationMode = .operating(newValue) }
    }
  }

  public internal(set) var efficiency: Ratio = .zero

  public enum OperationMode {
    case noOperation(time: Int)
    case startUp(time: Int, energy: Double)
    case scheduledMaintenance
    case operating(Ratio)
  }

  public var isOperating: Bool {
    switch operationMode {
    case .operating: return true
    default: return false
    }
  }

  static let initialState = SteamTurbine(operationMode: .noOperation(time: 0))

  public static var parameter: Parameter = Parameters.tb

  /// Used to sum time only when time step has changed
  static private var oldMinute = 0

  /// Calculates the Electric gross
  mutating func callAsFunction(
    heatFlow: ThermalEnergy,
    heater: Heater,
    heatExchanger: HeatExchanger,
    temperature: Temperature    
  )
    -> Double
  {
    let parameter = SteamTurbine.parameter
    defer { SteamTurbine.oldMinute = DateTime.current.minute }

    let minutes = Int(Simulation.time.steps.fraction * 60)
    if heatFlow.heatExchanger.isZero {
      // Avoid summing up inside an iteration
      if DateTime.current.minute != SteamTurbine.oldMinute {

        if case .noOperation(let standStillTime) = operationMode {
          operationMode = .noOperation(time: standStillTime + minutes)
        } else {
          operationMode = .noOperation(time: minutes)
        }
      }
      return 0

    } else {  // Energy is coming to the turbine

      switch operationMode {
      case .noOperation(let standStillTime):
        if standStillTime < parameter.hotStartUpTime {
          operationMode = .operating(1.0)
        } else {
          operationMode = .startUp(time: 0, energy: 0)
        }
      case .startUp(let startUpTime, let startUpEnergy):
        if startUpTime >= parameter.startUpTime,
          startUpEnergy >= parameter.startUpEnergy
        {
          operationMode = .operating(1.0)
        }
      case .scheduledMaintenance: return 0
      case .operating: break
      }

      if isOperating {
        let maxLoad: Double
        (maxLoad, efficiency.quotient) = SteamTurbine.perform(
          load: load,
          heatExchanger: heatExchanger.temperature.inlet,
          ambient: temperature
        )
        
        let gross = heatFlow.heatExchanger.megaWatt * efficiency.quotient
        let ratio = gross / parameter.power.max
        load = Ratio(ratio, cap: maxLoad)
        return gross
      } else {  // Start Up sequence: Energy is lost / Dumped
        // Avoid summing up inside an iteration
        if DateTime.current.minute != SteamTurbine.oldMinute {
          if case .startUp(let startUpTime, let startUpEnergy) = operationMode {
            var energy = heatFlow.heatExchanger.megaWatt
            if heater.massFlow > .zero { energy = heatFlow.heatExchanger.megaWatt }

            operationMode = .startUp(
              time: startUpTime + minutes,
              energy: startUpEnergy + energy * Simulation.time.steps.fraction
            )
          }
        }
        return 0
      }
    }
  }

  static func minLoad(atTemperature ambient: Temperature) -> Ratio {
    let minLoad: Ratio
    if SteamTurbine.parameter.minPowerFromTemp.isInapplicable {
      minLoad = Ratio(
        SteamTurbine.parameter.power.min
        / SteamTurbine.parameter.power.max)
    } else {
      minLoad = Ratio(
        SteamTurbine.parameter.minPowerFromTemp(ambient)
        / SteamTurbine.parameter.power.max)
    }
    return minLoad
  }

  static func minPower(atTemperature ambient: Temperature) -> Double {
    var minPower: Double
    if SteamTurbine.parameter.minPowerFromTemp.isInapplicable {
      minPower =
        SteamTurbine.parameter.power.min
        / SteamTurbine.parameter.efficiencyNominal
    } else {
      minPower = SteamTurbine.parameter.minPowerFromTemp(ambient)

      minPower = max(
        SteamTurbine.parameter.power.nominal * minPower,
        SteamTurbine.parameter.power.min)
    }
    return minPower
  }

  static func perform(
    load: Ratio,
    heatExchanger: Temperature,
    ambient: Temperature
  ) -> (maxLoad: Double, efficiency: Double) {
    let maxEfficiency =
      parameter.efficiencyNominal
      * (parameter.efficiencyTempIn_A
        * heatExchanger.celsius ** parameter.efficiencyTempIn_B)
        * parameter.efficiencyTempIn_cf  

    // Dependency of Heat Rate on Ambient Temperature

    var maxLoad: Double = 1
    var dcFactor = 1.0
    
    if parameter.efficiencyTemperature[1] >= 1 {
      
      let (dc, loadMax) = DryCooling.perform(
        steamTurbineLoad: load,
        temperature: ambient
      )

      maxLoad = loadMax.quotient
      dcFactor = dc.quotient
    }

    var efficiency = parameter.efficiency(load)

    if parameter.efficiencyTemperature.coefficients.isEmpty == false {
      efficiency *= parameter.efficiencyTemperature(ambient.celsius)
    }

    // wet bulb temperature effect

    let wetBulbTemperature = 1.1
    var correctionWetBulbTemperature = 1.0
    
    if parameter.efficiencyWetBulb.coefficients.isEmpty {
      correctionWetBulbTemperature = 1.0
    } else {
      if wetBulbTemperature < parameter.WetBulbTstep {
        for i in 0...2 {
          correctionWetBulbTemperature +=
            parameter.efficiencyWetBulb[i]
            * wetBulbTemperature ** Double(i)
        }
      } else {
        for i in 3...5 {
          correctionWetBulbTemperature +=
            parameter.efficiencyWetBulb[i]
            * wetBulbTemperature ** Double(i - 3)
        }
      }
    }
    
    if parameter.efficiencyTemperature[1] >= 1 {
      efficiency *= maxEfficiency / dcFactor
    } else {
      efficiency *= maxEfficiency * correctionWetBulbTemperature
    }

    let adjustmentFactor = Simulation.adjustmentFactor.efficiencyTurbine
    return (maxLoad, efficiency * adjustmentFactor)
  }
}
