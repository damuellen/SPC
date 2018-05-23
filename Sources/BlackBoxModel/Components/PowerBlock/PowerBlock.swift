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

  /// a struct for operation-relevant data of the gas turbine
  public struct PerformanceData: Equatable, HeatFlow,
  CustomStringConvertible {
    var operationMode: OperationMode
    var load: Ratio
    var massFlow: MassFlow
    var temperature: (inlet: Temperature, outlet: Temperature)
    var totalMassFlow, heatIn: Double
    
    public enum OperationMode {
      case scheduledMaintenance
    }
    
    public static func ==(lhs: PerformanceData, rhs: PerformanceData) -> Bool {
      return lhs.operationMode == rhs.operationMode && lhs.load == rhs.load
    }
    
    public var description: String {
      return "\(operationMode), "
        + "Load: \(load), "
        + String(format:"Mfl: %.1fkg/s, ", massFlow.rate)
        + String(format:"In: %.1f°C ", temperature.inlet.celsius)
        + String(format:"Out: %.1f°C", temperature.outlet.celsius)
    }
  }
  
  static let initialState = PerformanceData(
    operationMode: .scheduledMaintenance,
    load: 1.0,
    massFlow: 0.0,
    temperature: (inlet: Simulation.initialValues.temperatureOfHTFinPipes,
                  outlet: Simulation.initialValues.temperatureOfHTFinPipes),    
    totalMassFlow: 0,
    heatIn: 0
  )
  
  static var parameter: Parameter = ParameterDefaults.pb
  
  /// Calculates the parasitics of the gas turbine which only depends on the current load
  private static func parasitics(
    at load: Ratio, heat: Double,
    steamTurbine: SteamTurbine.PerformanceData) -> Double { // Calc. parasitic power in PB: -
    var electricalParasitics = 0.0
    
    let parameter = PowerBlock.parameter
    if steamTurbine.load.ratio >= 0.01 {
      electricalParasitics = parameter.fixelectricalParasitics
      electricalParasitics += parameter.nominalElectricalParasitics
       * parameter.electricalParasitics[load]
      
    } else if heat > 0, load.isZero {
      // parasitics during start-up sequence
      // Strange effect of this function over gross output!!
      // "strange effect" is due to interation "Abs(electricalParasiticsAssumed
      // - electricEnergy.parasitics) < Simulation.parameter.electricalTolerance"
      electricalParasitics = parameter.startUpelectricalParasitics
    }
    
    // if Heater.parameter.operationMode {
    //if variable exist, then project Shams-1 is calculated. commented, same for shams as for any project. check!
    switch steamTurbine.load.ratio { // Step function for Cooling Towers -
    case 0.5 ... 1:
      electricalParasitics += parameter.electricalParasiticsStep[1]
    case 0 ... 0.5:
      electricalParasitics += parameter.electricalParasiticsStep[0]
    case 0:
      if steamTurbine.isMaintained {
        electricalParasitics = 0 // add sched. maint. parasitics as a parameter
      } else if heat == 0 { // night TEST
        electricalParasitics = parameter.fixElectricalParasitics0
      }
    default: break
    }
    
    // parasitics for ACC:
    if steamTurbine.load.ratio >= 0.01 {
      // only during operation
      var electricalParasiticsACC = parameter.electricalParasiticsACC[load]

      if !parameter.electricalParasiticsACCTamb.coefficients.isEmpty {
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
    
    //return parameter.fixelectricalParasitics
    // electricalParasitics += parameter.nominalElectricalParasitics
    // * (parameter.electricalParasitics[0] + parameter.electricalParasitics[1]
    // * steamTurbine.load + parameter.electricalParasitics[2] * steamTurbine.load ** 2)
  }
  
  static func update(_ status: inout Plant.PerformanceData,
                     heat: inout Double,
                     electricalParasitics: inout Double,
                     Qsto: Double, meteo: MeteoData) -> Double {
    
    // Calculates the Electric gross, Parasitic
    
    let parameter = SteamTurbine.parameter
    var turbineStandStillTime = 0.0
    if parameter.hotStartUpTime == 0 {
      // parameter.hotStartUpTime = 75 // default value
    }
    var turbineStartUpTime = 0.0
    var turbineStartUpEnergy = 0.0
    var qneu = 0.0
    // new startup is only necessary, if turbine is out of operation for more than 20 minutes
    if heat <= 0 || (status.steamTurbine.Op == 0 && Simulation.isStart) {
      // no heat to turbine !!! // || (steamTurbine.Op = 0 && SimBegin) added for BL1 black box model
      if case .noOperation = status.steamTurbine.operationMode, Simulation.isStart {
        turbineStandStillTime = parameter.hotStartUpTime + 5
      }
      Simulation.isStart = false
      // added and variable declared global, still to be checked!!
      
      // if currentDate.minutes! != timeold {
      turbineStandStillTime = turbineStandStillTime + hourFraction * 60 // 5 minutes steps usually
      // }
      
      // timeold = minutes
      status.steamTurbine.load = 0.0
      return 0
    } else {
      // Energy is coming to the Turbine
      if (turbineStartUpTime >= parameter.startUpTime
        && turbineStartUpEnergy >= parameter.startUpEnergy)
        || turbineStandStillTime < parameter.hotStartUpTime
        || Simulation.isStart {
        Simulation.isStart = false // added for  black box model
        // modification due to turbine degradation
        status.steamTurbine.load = Ratio(heat / (parameter.power.max / parameter.efficiencyNominal))

        status.steamTurbine.load = Ratio(heat * SteamTurbine.efficiency(&status, Lmax: 1.0)
          / parameter.power.max)
        
      } else {
        // Start Up sequence: Energy is lost / Dumped
        status.steamTurbine.load = 0.0
        let startUpeff = cos(status.collector.theta) * status.collector.efficiency
        qneu = (Double(meteo.dni) * startUpeff - status.solarField.HL)
          * Design.layout.solarField * Double(SolarField.parameter.numberOfSCAsInRow)
          * 2 * Collector.parameter.areaSCAnet / 1_000_000
        
        if Qsto > 0 {
          qneu = qneu + Qsto
        }
        if status.heater.massFlow.rate > 0 {
          qneu = heat
        }
        // if time.minute != timeold_b {
        // added to sum startup time only when time changes,
        // effect: reduction of approx. 3% net output! turbineStartUpTime
        // must be reduced to about the half for projects older than this version
        turbineStartUpTime = turbineStartUpTime + hourFraction * 60
        turbineStartUpEnergy = turbineStartUpEnergy + qneu * hourFraction
        // added to sum startup heat only when time changes, effect: reduction
        // of approx. 1% net output! turbineStartUpEnergy must be reduced
        // to about the half for projects older than this version to
        // obtain similar results
        // }
        // timeold_b = minutes
        // turbineStartUpTime = turbineStartUpTime + hourFraction * 60
        // commented and replaced as shown above
        // turbineStartUpEnergy = turbineStartUpEnergy + qneu * hourFraction
        // qneu stat heat,commented and placed above after comparing
        // time.minutes! to avoid summing up inside an iteration
      }
      return heat 
    }
  }
}
