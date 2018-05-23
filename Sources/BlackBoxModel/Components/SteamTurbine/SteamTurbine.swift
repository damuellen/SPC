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

extension SteamTurbine.PerformanceData: CustomDebugStringConvertible {
  public var debugDescription: String {
    return "\(operationMode), "
      + String(format:"Load: %.2f ", load.ratio)
      + "Maintenance: \(isMaintained ? "Yes" : "No"), "
      + String(format:"Back pressure: %.2f, ", backPressure)
      + String(format:"Op: %.2f, ", Op)
      + String(format:"PminfT: %.2f", PminfT)
  }
}

public enum SteamTurbine: Component {

  /// a struct for operation-relevant data of the steam turbine
  public struct PerformanceData: Equatable {
    var operationMode: OperationMode
    var load: Ratio
    var isMaintained: Bool
    var backPressure: Double
    var Op: Double
    var PminfT: Double
    
    public enum OperationMode: Equatable {
      case noOperation(hours: Double), scheduledMaintenance
      
      public static func ==(lhs: OperationMode, rhs: OperationMode) -> Bool {
        switch (lhs, rhs) {
        case (.noOperation(let lhs), .noOperation(let rhs)): return lhs == rhs
        case (.noOperation(_), .scheduledMaintenance): return false
        case (.scheduledMaintenance, .noOperation(_)): return false
        case (.scheduledMaintenance, .scheduledMaintenance): return true
        }
      }
    }
    
    public static func ==(lhs: PerformanceData, rhs: PerformanceData) -> Bool {
      return lhs.operationMode == rhs.operationMode
        && lhs.load == rhs.load
        && lhs.isMaintained == rhs.isMaintained
        && lhs.backPressure == rhs.backPressure
        && lhs.Op == rhs.Op
        && lhs.PminfT == rhs.PminfT
    }
  }

  static let initialState = PerformanceData(
    operationMode: .noOperation(hours: 6),
    load: 1.0,
    isMaintained: false,
    backPressure: 0,
    Op: 0,
    PminfT: 0
  )

  static var parameter: Parameter = ParameterDefaults.tb

  static func efficiency(_ status: inout Plant.PerformanceData, Lmax: Ratio) -> Double {
    guard status.steamTurbine.load.ratio > 0 else { return 1 }
  //  return 0.9 // FIXME
    var parameter = SteamTurbine.parameter
    
    var maxEfficiency: Double = 1

    if case .operating = status.boiler.operationMode {
      // this restriction was planned to simulate an specific case, not correct for every case with Boiler
      
      if Plant.thermal.boiler > 50 || Plant.thermal.solar == 0 {
        maxEfficiency = parameter.efficiencyBoiler
      } else {
        maxEfficiency = (Plant.thermal.boiler * parameter.efficiencyBoiler
          + 4 * Plant.thermal.heatExchanger * parameter.efficiencyNominal)
          / (Plant.thermal.boiler + 4 * Plant.thermal.heatExchanger)
        // maxEfficiency = parameter.effnom
      }
    } else if case .ic = status.gasTurbine.operationMode {
      maxEfficiency = parameter.efficiencySCC
    } else {
      if parameter.efficiencytempIn_A == 0
        && parameter.efficiencytempIn_B == 0 {
        parameter.efficiencytempIn_A = 0.2383
        parameter.efficiencytempIn_B = 0.2404
        parameter.efficiencytempIn_cf = 1
      }

      if parameter.efficiencytempIn_cf == 0 {
        parameter.efficiencytempIn_cf = 1
      }

      maxEfficiency = parameter.efficiencyNominal
        * (parameter.efficiencytempIn_A
          * pow((status.heatExchanger.temperature.inlet.celsius),
                parameter.efficiencytempIn_B))
        * parameter.efficiencytempIn_cf
    }

    if case .pc = status.gasTurbine.operationMode {
      maxEfficiency = parameter.efficiencySCC
    }

    // Dependency of Heat Rate on Ambient Temperature  - DRY COOLING -
    if parameter.efficiencyTemperature[1] >= 1 {

      let (_, MaxDCLoad) = DryCooling.update(
        Tamb: Plant.ambientTemperature, steamTurbine: &status.steamTurbine)

      if status.steamTurbine.load > MaxDCLoad {
        status.steamTurbine.load = MaxDCLoad
      }
    }
    // Dependency of Heat Rate on Ambient Temperature  - DRY COOLING -
    // now a polynom offourth degree -
    var efficiency = parameter.efficiency[status.steamTurbine.load]
    var correcture = 0.0
    if !parameter.efficiencyTemperature.coefficients.isEmpty {
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
    let adjustmentFactor = Simulation.parameter.adjustmentFactor.efficiencyTurbine
    if parameter.efficiencyTemperature[1] >= 1 {
      efficiency *= maxEfficiency * adjustmentFactor //  / DCFactor
    } else {
      efficiency *= maxEfficiency * adjustmentFactor * correctionWetBulbTemperature
    }
    return efficiency
  }
}
