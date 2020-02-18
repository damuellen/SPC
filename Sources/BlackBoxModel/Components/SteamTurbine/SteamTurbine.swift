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
import Meteo

public struct SteamTurbine: Component {
  /// Contains all data needed to simulate the operation of the steam turbine

  var operationMode: OperationMode
  
  var load: Ratio

  var efficiency: Double

  public enum OperationMode {
    case noOperation(time: Int), startUp(time: Int, energy: Double),
    scheduledMaintenance, operating
  }

  var isOperating: Bool { 
    switch operationMode {
      case .operating: return true
      default: return false
    }
  }

  static let initialState = SteamTurbine(
    operationMode: .noOperation(time: 5),
    load: 1.0, efficiency: 1.0
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
    heat: Double,
    temperature: Temperature)
    -> Double
  {
    let parameter = SteamTurbine.parameter
    defer { SteamTurbine.oldMinute = TimeStep.current.minute }
    //load = 0.0
    let minutes = Int(Simulation.time.steps.fraction * 60)
    if heat <= 0 {
      Plant.heat.startUp = 0.0
      // Avoid summing up inside an iteration
      if TimeStep.current.minute != SteamTurbine.oldMinute {
        
        if case .noOperation(let standStillTime)
          = operationMode
        {
          operationMode =
            .noOperation(time: standStillTime + minutes)
        } else {
          operationMode =
            .noOperation(time: minutes)
        }
      }
      return 0
      
    } else { // Energy is coming to the turbine
      
      switch operationMode {
      case .noOperation(let standStillTime):
        if standStillTime < parameter.hotStartUpTime {
          operationMode = .operating
        } else {
          operationMode = .startUp(time: 0, energy: 0)
        }
      case .startUp(let startUpTime, let startUpEnergy):
        if startUpTime >= parameter.startUpTime,
          startUpEnergy >= parameter.startUpEnergy
        {
          operationMode = .operating
          
        }
      case .scheduledMaintenance: return 0
      case .operating: break
      }
      
      if isOperating  {
        Plant.heat.startUp = 0.0
        let maxLoad: Double
        (maxLoad, efficiency) = SteamTurbine.perform(
          load, modeBoiler, modeGasTurbine,
          heatExchanger.temperature.inlet, temperature)
        #warning("Check this again")

        load.ratio = (heat * efficiency / parameter.power.max)
          .limited(by: maxLoad)
        let gross = load.ratio * parameter.power.max * efficiency
        return gross
      } else { // Start Up sequence: Energy is lost / Dumped
        // Avoid summing up inside an iteration
        if TimeStep.current.minute != SteamTurbine.oldMinute {
          if case .startUp(let startUpTime, let startUpEnergy)
            = operationMode
          {
            var energy = Plant.heat.production.megaWatt
            
            Plant.heat.production = 0.0
            
            energy += Plant.heat.storage.megaWatt
              + Plant.heat.boiler.megaWatt
            
            Plant.heat.startUp.megaWatt = energy
            
            if heater.massFlow.rate > 0 { energy = heat }
            
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
  
  static func perform(
    _ load: Ratio,
    _ boiler: Boiler.OperationMode,
    _ gasTurbine: GasTurbine.OperationMode,
    _ heatExchanger: Temperature,
    _ ambient: Temperature)
    -> (maxLoad: Double, maxEfficiency: Double)
  {
    guard load.ratio > 0 else { return (0, 0) }

    var maxLoad: Double = 1

    var maxEfficiency: Double = 1

    if case .operating = boiler {
      // this restriction was planned to simulate an specific case,
      // not correct for every case with Boiler

      if Plant.heat.boiler.megaWatt > 50 || Plant.heat.solar.watt == 0 {
        maxEfficiency = parameter.efficiencyBoiler
      } else {
        maxEfficiency = (Plant.heat.boiler.megaWatt
          * parameter.efficiencyBoiler + 4.0
          * Plant.heat.heatExchanger.megaWatt
          * parameter.efficiencyNominal)
          / (Plant.heat.boiler.megaWatt + 4.0
            * Plant.heat.heatExchanger.megaWatt)
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

      maxEfficiency = parameter.efficiencyNominal
        * (parameter.efficiencyTempIn_A
          * pow((heatExchanger.celsius),
                parameter.efficiencyTempIn_B))
        * parameter.efficiencyTempIn_cf
    }

    if case .pure = gasTurbine {
      maxEfficiency = parameter.efficiencySCC
    }

    var dcFactor = 1.0
    // Dependency of Heat Rate on Ambient Temperature  - DRY COOLING -
    #warning("The implementation here differs from PCT")
    if parameter.efficiencyTemperature[1] >= 1 {
      let (dc, loadMax) = DryCooling.update(
        steamTurbineLoad: load.ratio,
        temperature: ambient
      )

      maxLoad = loadMax.ratio
      dcFactor = dc.ratio
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
        for i in 0 ... 2 {
          correctionWetBulbTemperature += parameter.efficiencyWetBulb[i]
            * pow(wetBulbTemperature, Double(i))
        }
      } else {
        for i in 3 ... 5 {
          correctionWetBulbTemperature += parameter.efficiencyWetBulb[i]
            * pow(wetBulbTemperature, Double(i - 3))
        }
      }
    }
    let adjustmentFactor = Simulation.adjustmentFactor.efficiencyTurbine
    if parameter.efficiencyTemperature[1] >= 1 {
      efficiency *= maxEfficiency * adjustmentFactor / dcFactor
    } else {
      efficiency *= maxEfficiency * adjustmentFactor
        * correctionWetBulbTemperature
    }
    return (maxLoad, efficiency)
  }
}
