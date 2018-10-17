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

extension SteamTurbine.PerformanceData: CustomDebugStringConvertible {
  public var debugDescription: String {
    return "\(operationMode), "
      + String(format: "Load: %.2f ", load.ratio)
      + String(format: "Efficiency: %.2f %", efficiency * 100)
      + String(format: "Back pressure: %.2f, ", backPressure)
  }
}

public enum SteamTurbine: Component {
  /// Contains all data needed to simulate the operation of the steam turbine
  public struct PerformanceData: Equatable {
    var operationMode: OperationMode
    var load: Ratio
    var efficiency: Double
    var backPressure: Double

    public enum OperationMode: Equatable {
      case noOperation(time: Int), startUp(time: Int, energy: Double),
      scheduledMaintenance, operating

      public static func == (lhs: OperationMode, rhs: OperationMode) -> Bool {
        switch (lhs, rhs) {
        case let (.noOperation(lhs), .noOperation(rhs)): return lhs == rhs
        case let (.startUp(lhs), .startUp(rhs)): return lhs == rhs
        case (.scheduledMaintenance, .scheduledMaintenance): return true
        case (.operating, .operating): return true
        default: return false
        }
      }
    }

    public static func == (lhs: PerformanceData, rhs: PerformanceData) -> Bool {
      return lhs.operationMode == rhs.operationMode
        && lhs.load == rhs.load
        && lhs.backPressure == rhs.backPressure
    }
  }

  static let initialState = PerformanceData(
    operationMode: .noOperation(time: 5),
    load: 1.0, efficiency: 1.0, backPressure: 0
  )

  public static var parameter: Parameter = ParameterDefaults.tb

  /// Used to sum time only when time step has changed
  static private var oldMinute = 0
  typealias Status = (gross: Double, status: PerformanceData)
  /// Calculates the Electric gross,
  static func update(_ status: Plant.PerformanceData,
                     heat: Double, meteo: MeteoData,
                     result: (SteamTurbine.Status) -> ()) {
    var steamTurbine = status.steamTurbine
    let parameter = SteamTurbine.parameter
    
    defer { oldMinute = TimeStep.current.minute }
    steamTurbine.load = 0.0
    
    if heat <= 0 {
      Plant.thermal.startUp = 0.0
      // Avoid summing up inside an iteration
      if TimeStep.current.minute != oldMinute {
        
        if case .noOperation(let standStillTime)
          = steamTurbine.operationMode
        {
          steamTurbine.operationMode =
            .noOperation(time: standStillTime + Int(hourFraction * 60))
        } else {
          steamTurbine.operationMode =
            .noOperation(time: Int(hourFraction * 60))
        }
      }
      result((0, steamTurbine))
      
    } else { // Energy is coming to the turbine
      
      switch steamTurbine.operationMode {
      case .noOperation(let standStillTime):
        if standStillTime < parameter.hotStartUpTime {
          steamTurbine.operationMode = .operating
        } else {
          steamTurbine.operationMode = .startUp(time: 0, energy: 0)
        }
      case .startUp(let startUpTime, let startUpEnergy):
        if startUpTime >= parameter.startUpTime,
          startUpEnergy >= parameter.startUpEnergy
        {
          steamTurbine.operationMode = .operating
          
        }
      case .scheduledMaintenance: result((0, steamTurbine)); return
      case .operating: break
      }
      
      if status.steamTurbine.operationMode == .operating  {
        Plant.thermal.startUp = 0.0

        let (maxLoad, st) = SteamTurbine.calculate(status)
        steamTurbine = st
        let eff = st.efficiency
        steamTurbine.load.ratio = min(heat * eff / parameter.power.max,
                                      maxLoad)
        let gross = status.steamTurbine.load.ratio * parameter.power.max * eff
        result((gross, steamTurbine))
      } else { // Start Up sequence: Energy is lost / Dumped
        // Avoid summing up inside an iteration
        if TimeStep.current.minute != oldMinute {
          if case .startUp(let startUpTime, let startUpEnergy)
            = steamTurbine.operationMode
          {
            var energy = Plant.thermal.production.megaWatt
            Plant.thermal.production = 0.0
            energy += Plant.thermal.storage.megaWatt
              + Plant.thermal.boiler.megaWatt
            Plant.thermal.startUp.megaWatt = energy
            if status.heater.massFlow.rate > 0 { energy = heat }
            
            steamTurbine.operationMode = .startUp(
              time: startUpTime + Int(hourFraction * 60),
              energy: startUpEnergy + energy * hourFraction
            )
          }
        }
        result((0, steamTurbine))
      }
    }
  }
  
  static func calculate(
    _ status: Plant.PerformanceData
    ) -> (Double, SteamTurbine.PerformanceData)
  {
    guard status.steamTurbine.load.ratio > 0 else {
      return (0, status.steamTurbine)
    }
    var maxLoad: Double = 1
    var maxEfficiency: Double = 1

    if case .operating = status.boiler.operationMode {
      // this restriction was planned to simulate an specific case,
      // not correct for every case with Boiler

      if Plant.thermal.boiler.megaWatt > 50 || Plant.thermal.solar.watt == 0 {
        maxEfficiency = parameter.efficiencyBoiler
      } else {
        maxEfficiency = (Plant.thermal.boiler.megaWatt
          * parameter.efficiencyBoiler + 4.0
          * Plant.thermal.heatExchanger.megaWatt
          * parameter.efficiencyNominal)
          / (Plant.thermal.boiler.megaWatt + 4.0
            * Plant.thermal.heatExchanger.megaWatt)
        // maxEfficiency = parameter.effnom
      }
    } else if case .integrated = status.gasTurbine.operationMode {
      maxEfficiency = parameter.efficiencySCC
    } else {
      if parameter.efficiencyTempIn_A == 0
        && parameter.efficiencyTempIn_B == 0 {
        parameter.efficiencyTempIn_A = 0.2383
        parameter.efficiencyTempIn_B = 0.2404
        parameter.efficiencyTempIn_cf = 1
      }

      if parameter.efficiencyTempIn_cf == 0 {
        parameter.efficiencyTempIn_cf = 1
      }

      maxEfficiency = parameter.efficiencyNominal
        * (parameter.efficiencyTempIn_A
          * pow((status.heatExchanger.temperature.inlet.celsius),
                parameter.efficiencyTempIn_B))
        * parameter.efficiencyTempIn_cf
    }

    if case .pure = status.gasTurbine.operationMode {
      maxEfficiency = parameter.efficiencySCC
    }
    var steamTurbine = status.steamTurbine
    // Dependency of Heat Rate on Ambient Temperature  - DRY COOLING -
    #warning("The implementation here differs from PCT")
    if parameter.efficiencyTemperature[1] >= 1 {
      let (_, maxDCLoad, backPressure) = DryCooling.update(
        steamTurbineLoad: steamTurbine.load.ratio,
        temperature: Plant.ambientTemperature
      )
      steamTurbine.backPressure = backPressure
      maxLoad = maxDCLoad.ratio
    }
    // Dependency of Heat Rate on Ambient Temperature  - DRY COOLING -
    // now a polynom of fourth degree -
    var efficiency = parameter.efficiency[status.steamTurbine.load]
    var correcture = 0.0
    if parameter.efficiencyTemperature.coefficients.isEmpty == false {
      correcture += parameter.efficiencyTemperature[Plant.ambientTemperature.celsius]
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
      efficiency *= maxEfficiency * adjustmentFactor //  / DCFactor
    } else {
      efficiency *= maxEfficiency * adjustmentFactor
        * correctionWetBulbTemperature
    }
    steamTurbine.efficiency = efficiency
    return (maxLoad, steamTurbine)
  }
}
