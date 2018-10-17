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

public enum PowerBlock: Component {
  /// Contains all data needed to simulate the operation of the power block
  public struct PerformanceData: Equatable, HeatCycle,
  CustomStringConvertible {
    var operationMode: OperationMode
    var load: Ratio
    var massFlow: MassFlow
    var temperature: (inlet: Temperature, outlet: Temperature)
    var totalMassFlow: MassFlow
    var heatIn: Double
    
    public enum OperationMode {
      case scheduledMaintenance
    }
    
    public static func == (lhs: PerformanceData, rhs: PerformanceData) -> Bool {
      return lhs.operationMode == rhs.operationMode && lhs.load == rhs.load
    }
    
    public var description: String {
      return "\(operationMode), "
        + "Load: \(load), "
        + String(format: "Mfl: %.1fkg/s, ", massFlow.rate)
        + String(format: "In: %.1f°C ", temperature.inlet.celsius)
        + String(format: "Out: %.1f°C", temperature.outlet.celsius)
    }
  }
  
  static let initialState = PerformanceData(
    operationMode: .scheduledMaintenance,
    load: 0.0,
    massFlow: 0.0,
    temperature: (inlet: Simulation.initialValues.temperatureOfHTFinPipes,
                  outlet: Simulation.initialValues.temperatureOfHTFinPipes),
    totalMassFlow: 0.0,
    heatIn: 0
  )
  
  public static var parameter: Parameter = ParameterDefaults.pb
  
  /// Calculate parasitic power in PB
  static func parasitics(
    heat: Double, steamTurbine: SteamTurbine.PerformanceData) -> Double {
    var electricalParasitics = 0.0
    
    if steamTurbine.load.ratio >= 0.01 {
      electricalParasitics = parameter.fixelectricalParasitics
      electricalParasitics += parameter.nominalElectricalParasitics
        * parameter.electricalParasitics[steamTurbine.load]
    } else if heat > 0, steamTurbine.load.isZero {
      // parasitics during start-up sequence
      // Strange effect of this function over gross output!!
      // "strange effect" is due to interation "Abs(electricalParasiticsAssumed
      // - electricEnergy.parasitics) < Simulation.parameter.electricalTolerance"
      electricalParasitics = parameter.startUpelectricalParasitics
    }
    
    // if Heater.parameter.operationMode {
    // if variable exist, then project Shams-1 is calculated. commented,
    // same for shams as for any project. check!
    switch steamTurbine.load.ratio { // Step function for Cooling Towers -
    case 0:
      if case .scheduledMaintenance = steamTurbine.operationMode {
        electricalParasitics = 0 // add sched. maint. parasitics as a parameter
      } else if heat == 0 { // night TEST
        electricalParasitics = parameter.fixElectricalParasitics0
      }
    case 0 ... 0.5:
      electricalParasitics += parameter.electricalParasiticsStep[0]
    case 0.5 ... 1:
      electricalParasitics += parameter.electricalParasiticsStep[1]
    default: break
    }
    
    // parasitics for ACC:
    if steamTurbine.load.ratio >= 0.01 {
      // only during operation
      var electricalParasiticsACC = parameter.electricalParasiticsACC[steamTurbine.load]
      
      if parameter.electricalParasiticsACCTamb.coefficients.isEmpty == false {
        var adjustmentACC = parameter.electricalParasiticsACCTamb
          .apply(Plant.ambientTemperature.celsius)
        // ambient temp is larger than design, ACC max. consumption fixed to nominal
        if adjustmentACC > 1 {
          adjustmentACC = 1
        }
        electricalParasiticsACC *= adjustmentACC
      }
    }
    
    electricalParasitics += parameter.nominalElectricalParasiticsACC
    return electricalParasitics // + 0.005 * steamTurbine.load * parameter.power.max
    
    // return parameter.fixelectricalParasitics
    // electricalParasitics += parameter.nominalElectricalParasitics
    // * (parameter.electricalParasitics[0] + parameter.electricalParasitics[1]
    // * steamTurbine.load + parameter.electricalParasitics[2] * steamTurbine.load ** 2)
  }
  
  static func heatExchangerBypass(
    _ status: Plant.PerformanceData
    ) -> (heatOut: Double, heatToTES: Double, powerBlock: PowerBlock.PerformanceData) {
    let heatExchanger = HeatExchanger.parameter
    let htf = SolarField.parameter.HTF
    var powerBlock = status.powerBlock
    var heatOut = 0.0
    var heatToTES = 0.0
    
    // added to simulate a bypass on the PB-HX if the expected
    // outlet temperature is so low that the salt to TES could freeze
    powerBlock.totalMassFlow = powerBlock.massFlow
  
    repeat {
      
      powerBlock.setTemperature(outlet:
        HeatExchanger.outletTemperature(powerBlock, powerBlock)
      )
      heatOut = htf.enthalpyFrom(powerBlock.temperature.outlet)
      
      let bypassMassFlow = powerBlock.totalMassFlow
        - powerBlock.massFlow
      let Bypass_h = htf.enthalpyFrom(powerBlock.temperature.inlet)
      
      heatToTES = (bypassMassFlow.rate * Bypass_h
        + powerBlock.massFlow.rate * heatOut)
        / (bypassMassFlow + powerBlock.massFlow).rate
      
    } while heatToTES > h_261
    
    powerBlock.setTemperature(outlet:
      htf.temperatureFrom(heatToTES)
    )    
    return (heatOut, heatToTES, powerBlock)
  }
}

let h_261 = 1.51129 * 261 + 1.2941 / 1_000 * 261 ** 2
  + 1.23697 / 10 ** 7 * 261 ** 3 - 0.62677 // kJ/kg
