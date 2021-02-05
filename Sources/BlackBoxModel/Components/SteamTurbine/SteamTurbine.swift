//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import DateGenerator
import Meteo
/// Contains all data needed to simulate the operation of the steam turbine
public struct SteamTurbine: Parameterizable {
  
  var operationMode: OperationMode

  var load: Ratio {
    get {
      if case .operating(let load) = operationMode { return load } else { return .zero }
    }
    set {
      if case .operating(_) = operationMode {
        operationMode = .operating(newValue)
      }
    }
  }

  // var efficiency: Double

  public enum OperationMode {
    case noOperation(time: Int)
    case startUp(time: Int, energy: Double)
    case scheduledMaintenance
    case operating(Ratio)
  }

  var isOperating: Bool {
    switch operationMode {
    case .operating: return true
    default: return false
    }
  }

  static let initialState = SteamTurbine(
    operationMode: .noOperation(time: 0)
  )

  public static var parameter: Parameter = ParameterDefaults.tb

  /// Used to sum time only when time step has changed
  static private var oldMinute = 0

  /// Calculates the Electric gross
  mutating func callAsFunction(
    heater: Heater,
    modeBoiler: Boiler.OperationMode,
    modeGasTurbine: GasTurbine.OperationMode,
    heatExchanger: HeatExchanger,
    temperature: Temperature,
    heatFlow: ThermalEnergy
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
        let (maxLoad, efficiency) = SteamTurbine.perform(
          load, heatFlow, modeBoiler, modeGasTurbine,
          heatExchanger.temperature.inlet, temperature)
        
        let gross = heatFlow.heatExchanger.megaWatt * efficiency
        let ratio = gross / parameter.power.max
        load = Ratio(ratio, cap: maxLoad)
        return gross
      } else {  // Start Up sequence: Energy is lost / Dumped
        // Avoid summing up inside an iteration
        if DateTime.current.minute != SteamTurbine.oldMinute {
          if case .startUp(let startUpTime, let startUpEnergy) = operationMode {
            var energy = heatFlow.heatExchanger.megaWatt
            // FIXME    Plant.heatFlow.startUp.megaWatt = energy

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

  static func minLoad(ambient: Temperature) -> Ratio {
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

  static func minPower(ambient: Temperature) -> Double {
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
    _ load: Ratio, _ heatFlow: ThermalEnergy,
    _ boiler: Boiler.OperationMode,
    _ gasTurbine: GasTurbine.OperationMode,
    _ heatExchanger: Temperature,
    _ ambient: Temperature
  )
    -> (maxLoad: Double, maxEfficiency: Double)
  {
    guard load > .zero else { return (1, 1) }

    var maxLoad: Double = 1

    var maxEfficiency: Double = 1

    if case .operating = boiler {
      // this restriction was planned to simulate an specific case,
      // not correct for every case with Boiler

      if heatFlow.boiler.megaWatt > 50 || heatFlow.solar.watt == 0 {
        maxEfficiency = parameter.efficiencyBoiler
      } else {
        maxEfficiency =
          (heatFlow.boiler.megaWatt
            * parameter.efficiencyBoiler + 4.0
            * heatFlow.heatExchanger.megaWatt
            * parameter.efficiencyNominal)
          / (heatFlow.boiler.megaWatt + 4.0
            * heatFlow.heatExchanger.megaWatt)
        // maxEfficiency = parameter.effnom
      }
    } else if case .integrated = gasTurbine {
      maxEfficiency = parameter.efficiencySCC
    } else {
      if parameter.efficiencyTempIn_A == 0
        && parameter.efficiencyTempIn_B == 0
      {
        parameter.efficiencyTempIn_A = 0.2383
        parameter.efficiencyTempIn_B = 0.2404
        parameter.efficiencyTempIn_cf = 1
      }

      if parameter.efficiencyTempIn_cf == 0 {
        parameter.efficiencyTempIn_cf = 1
      }

      maxEfficiency =
        parameter.efficiencyNominal
        * (parameter.efficiencyTempIn_A
          * heatExchanger.celsius ** parameter.efficiencyTempIn_B)
          * parameter.efficiencyTempIn_cf
    }

    if case .pure = gasTurbine {
      maxEfficiency = parameter.efficiencySCC
    }

    var dcFactor = 1.0
    // Dependency of Heat Rate on Ambient Temperature  - DRY COOLING -
    //#warning("The implementation here differs from PCT")
    if parameter.efficiencyTemperature[1] >= 1 {
      let (dc, loadMax) = DryCooling.perform(
        steamTurbineLoad: load,
        temperature: ambient
      )

      maxLoad = loadMax.quotient
      dcFactor = dc.quotient
    }
    // Dependency of Heat Rate on Ambient Temperature  - DRY COOLING -
    var efficiency = parameter.efficiency(load)

    var correcture = 0.0

    if parameter.efficiencyTemperature.coefficients.isEmpty == false {
      correcture += parameter.efficiencyTemperature(ambient.celsius)
    }
    efficiency *= correcture

    let wetBulbTemperature = 1.1

    var correctionWetBulbTemperature = 1.0
    // wet bulb temperature effect
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
      efficiency *=
        maxEfficiency * correctionWetBulbTemperature
    }
    let adjustmentFactor = Simulation.adjustmentFactor.efficiencyTurbine
    return (maxLoad, efficiency * adjustmentFactor)
  }
}
