//
//  Copyright (c) 2017 Daniel Müllenborn. All rights reserved.
//  Distributed under the The Non-Profit Open Software License version 3.0
//  http://opensource.org/licenses/NPOSL-3.0
//
//  This project is NOT free software. It is open source, you are allowed to
//  modify it (if you keep the license), but it may not be commercially
//  distributed other than under the conditions noted above.
//

import Foundation
import Meteo

extension PowerBlock.Instance: CustomDebugStringConvertible {
  var debugDescription: String { return "\(workingConditions.current)" }
}

public enum PowerBlock: Component {
  
  final class Instance {
    // A singleton class holding the state of the power block
    fileprivate static let shared = Instance()
    var parameter: PowerBlock.Parameter!
    var indexLocation = 0
    var workingConditions: (previous: PerformanceData?, current: PerformanceData)
    
    private init() {
      workingConditions = (nil, initialState)
    }
  }
  
  /// a struct for operation-relevant data of the gas turbine
  public struct PerformanceData: Equatable, MassFlow, WorkingConditions {
    var operationMode: OperationMode
    var load: Double
    var temperature: (inlet: Double, outlet: Double)
    var massFlow, totalMassFlow, hin: Double
    
    public enum OperationMode {
      case SM
    }
    
    public static func ==(lhs: PerformanceData, rhs: PerformanceData) -> Bool {
      return lhs.operationMode == rhs.operationMode && lhs.load == rhs.load
    }
  }
  
  fileprivate static let initialState = PerformanceData(
    operationMode: .SM,
    load: 1.0,
    temperature: (200, 200),
    massFlow: 0,
    totalMassFlow: 0,
    hin: 0)
  
  /// Returns the current working conditions of the power block
  public static var status: PerformanceData {
    get { return Instance.shared.workingConditions.current }
    set {
      Instance.shared.workingConditions =
        (Instance.shared.workingConditions.current, newValue)
    }
  }
  
  /// Returns the previous working conditions of the power block
  public static var previous: PerformanceData? {
    return Instance.shared.workingConditions.previous
  }
  
  public static var parameter: PowerBlock.Parameter {
    get { return Instance.shared.parameter }
    set { Instance.shared.parameter = newValue }
  }
  
  /// Calculates the parasitics of the gas turbine which only depends on the current load
  private static func parasitics(at _: Ratio) -> Double { // Calc. parasitic power in PB: -
    var electricalParasitics = 0.0
    var heat = 0.0
    
    let parameter = PowerBlock.parameter
    if SteamTurbine.status.load.value >= 0.01 {
      // changed to > 0 and not >= 0.01 as before. set back to >= 0.01, it seems to have no effect
      electricalParasitics = parameter.fixelectricalParasitics
      electricalParasitics += parameter.nominalElectricalParasitics
        * (parameter.electricalParasitics[0] + parameter.electricalParasitics[1]
          * SteamTurbine.status.load.value + parameter.electricalParasitics[2]
          * SteamTurbine.status.load.value ** 2)
    } else if heat > 0, SteamTurbine.status.load.isZero {
      // parasitics during start-up sequence
      // Strange effect of this function over gross output!!"strange effect" is due to interation "Abs(electricalParasiticsAssumed - electricEnergy.parasitics) < Simulation.parameter.electricalTolerance"
      electricalParasitics = parameter.startUpelectricalParasitics
    }
    
    // if Heater.parameter.operationMode { //if variable exist, then project Shams-1 is calculated. commented, same for shams as for any project. check!
    switch SteamTurbine.status.load.value { // Step function for Cooling Towers -
    case 0.5 ... 1:
      electricalParasitics += parameter.electricalParasiticsStep[1]
    case 0 ... 0.5:
      electricalParasitics += parameter.electricalParasiticsStep[0]
    case 0:
      if SteamTurbine.status.isMaintained {
        electricalParasitics = 0 // add sched. maint. parasitics as a parameter
      } else if heat == 0 { // night TEST
        electricalParasitics = parameter.fixElectricalParasitics0
      }
    default: break
    }
    
    // parasitics for ACC:
    if SteamTurbine.status.load.value >= 0.01 {
      // only during operation
      var electricalParasiticsACC = 0.0
      for i in 0 ... 4 {
        electricalParasiticsACC += (parameter.electricalParasiticsACC[i]
          * (SteamTurbine.status.load.value ** Double(i)))
      }
      if !parameter.electricalParasiticsACCTamb.coefficients.isEmpty {
        var electricalParasiticsACCkor = 0.0
        for i in 0 ... 4 {
          electricalParasiticsACCkor += (parameter.electricalParasiticsACCTamb[i]
            * Plant.ambientTemperature ** Double(i))
        }
        // ambient temp is larger than design, ACC max. consumption fixed to nominal
        if electricalParasiticsACCkor > 1 {
          electricalParasiticsACCkor = 1
        }
        electricalParasiticsACC = electricalParasiticsACC * electricalParasiticsACCkor
      }
    }
    
    electricalParasitics += parameter.nominalElectricalParasiticsACC
    return electricalParasitics // + 0.005 * steamTurbine.load * parameter.power.max
    
    return parameter.fixelectricalParasitics
    // electricalParasitics += parameter.nominalElectricalParasitics * (parameter.electricalParasitics[0] + parameter.electricalParasitics[1] * steamTurbine.load + parameter.electricalParasitics[2] * steamTurbine.load ** 2)
  }
  
  public static func operate(heat: inout Double,
                             electricalParasitics _: inout Double,
                             steamTurbine: inout SteamTurbine.PerformanceData,
                             Qsto: Double, meteo: MeteoData) -> Double {
    
    var timeold = 0
    let minutes = 0 // date.minutes
    var lastavgins = 0.0
    var timeold_b = 0
    
    // Calculates the Electric gross, Parasitic
    
    let parameter = SteamTurbine.parameter
    var simBegin = true
    var turbineStandStillTime = 0.0
    if parameter.hotStartUpTime == 0 {
      // parameter.hotStartUpTime = 75 // default value
    }
    var turbineStartUpTime = 0.0
    var turbineStartUpEnergy = 0.0
    var qneu = 0.0
    // new startup is only necessary, if turbine is out of operation for more than 20 minutes
    if heat <= 0 || (steamTurbine.Op == 0 && simBegin) {
      // no heat to turbine !!! // || (steamTurbine.Op = 0 && SimBegin) added for BL1 black box model
      if case .noOperation = steamTurbine.operationMode, simBegin {
        turbineStandStillTime = parameter.hotStartUpTime + 5
      }
      simBegin = false
      // added and variable declared global, still to be checked!!
      
      // if date.minutes != timeold {
      turbineStandStillTime = turbineStandStillTime + hourFraction * 60 // 5 minutes steps usually
      // }
      
      timeold = minutes
      steamTurbine.load = 0.0
      return 0
    } else {
      // Energy is coming to the Turbine
      if (turbineStartUpTime >= parameter.startUpTime
        && turbineStartUpEnergy >= parameter.startUpEnergy)
        || turbineStandStillTime < parameter.hotStartUpTime
        || simBegin {
        simBegin = false // added for  black box model
        // modification due to turbine degradation
        steamTurbine.load = Ratio(heat / (parameter.power.max / parameter.efficiencyNominal))
        
        
        steamTurbine.load = Ratio(heat * SteamTurbine.efficiency / parameter.power.max)
        
      } else {
        // Start Up sequence: Energy is lost / Dumped
        steamTurbine.load = 0.0
        let startUpeff = cos(Collector.theta) * Collector.efficiency(meteo: meteo, direction: 0)
        qneu = (lastavgins * startUpeff - SolarField.status.HL)
          * Design.layout.solarField * Double(SolarField.parameter.numberOfSCAsInRow)
          * 2 * Collector.parameter.areaSCAnet / 1_000_000
        
        if Qsto > 0 {
          qneu = qneu + Qsto
        }
        if Heater.status.massFlow > 0 {
          qneu = heat
        }
        // if dateminutes != timeold_b { // added to sum startup time only when time changes,
        // effect: reduction of approx. 3% net output! turbineStartUpTime
        // must be reduced to about the half for projects older than this version
        turbineStartUpTime = turbineStartUpTime + hourFraction * 60
        turbineStartUpEnergy = turbineStartUpEnergy + qneu * hourFraction
        // added to sum startup heat only when time changes, effect: reduction of approx.
        // 1% net output! turbineStartUpEnergy must be reduced to about the
        // half for projects older than this version to obtain similar results
        // }
        timeold_b = minutes
        // turbineStartUpTime = turbineStartUpTime + hourFraction * 60
        // commented and replaced as shown above
        // turbineStartUpEnergy = turbineStartUpEnergy + qneu * hourFraction
        // qneu stat heat,commented and placed above after comparing date.minutes to avoid summing up inside an iteration
      }
      return heat 
    }
  }
}
