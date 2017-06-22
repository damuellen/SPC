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

/*
 The solar field is specified by the total number of loops, number of collectors
 per loop, distance between collectors in a row, distance between rows,
 azimuth angle and elevation angle of solar field, heat losses in piping,
 maximum wind speed for tracking, nominal HTF flow, “freeze protection” HTF flow
 and minimal HTF flow, and parasitic power as a function of HTF flow.
 */
extension SolarField.Instance: CustomDebugStringConvertible {
  var debugDescription: String { return "\(workingConditions.current)" }
}

var timeRemain = 0.0

public final class SolarField: Model {
  
  final class Instance {
    // A singleton class holding the state of the steam turbine
    static let shared = Instance()
    var parameter: SolarField.Parameter!
    var workingConditions: (previous: PerformanceData?, current: PerformanceData)
    
    private init() {
      workingConditions = (nil, initialState)
    }
  }
  
  /// a struct for operation-relevant data of the steam turbine
  public struct PerformanceData: MassFlow {
    var operationMode: OperationMode
    let isMaintained: Bool
    var heatFlow: Double
    var massFlow: Double
    var ITA: Double
    var ETA: Double
    var HL: Double
    var heatLossHeader: Double
    var heatLossHCE: Double
    var inFocus: Ratio
    var temperature: (inlet: Double, outlet: Double)
    
    public enum OperationMode: String {
      case startUp, freezeProtection, operating,
      noOperation, scheduledMaintenance, unknown, ph
    }
  }
  
  static let initialState = PerformanceData(
    operationMode: .freezeProtection,
    isMaintained: false,
    heatFlow: 0.0,
    massFlow: 0.0,
    ITA: 0,
    ETA: 0,
    HL: 0,
    heatLossHeader: 0,
    heatLossHCE: 0,
    inFocus: 0.0,
    temperature: (200, 200))
  
  /// Returns the current working conditions of the steam turbine
  public static var status: PerformanceData {
    get { return Instance.shared.workingConditions.current }
    set {
      Instance.shared.workingConditions =
        (Instance.shared.workingConditions.current, newValue)
    }
  }
  
  /// Returns the previous working conditions of the steam
  public static var previous: PerformanceData? {
    return Instance.shared.workingConditions.previous
  }
  
  public static var parameter: SolarField.Parameter {
    get { return Instance.shared.parameter }
    set { Instance.shared.parameter = newValue }
  }
  
  /// Calculates the parasitics
  private static func parasitics(at load: Ratio) -> Double {
    // solarField.massFlow / parameter.massFlow.max  // Account for parasitic heatFlow
    
    return parameter.pumpParasticsFullLoad
      * (parameter.pumpParastics[0] + parameter.pumpParastics[1]
      * load.value + parameter.pumpParastics[2] * load.value ** 2)
  }
  
  public static func pipeHeatLoss(_ temperature: Double, ambient: Double) -> Double {
    return ((temperature - ambient) / 333) ** 1 * parameter.pipeHL
  }
  
  public static func calculate(date: Date, meteo: MeteoData,
                               solarField: inout SolarField.PerformanceData,
                               heatFlow: inout HeatFlow) {
    
    var nearLoop = (now: status, last: status)
    var avgLoop = (now: status, last: status)
    var farLoop = (now: status, last: status)
    var designLoop = (now: status, last: status)
 
    if solarField.isMaintained { // Check if maintained
      /*
       if solarField.operationMode != "SM" { // First Day of Maintenance
       
       solarField.operationMode = scheduledMaintenance
       solarField.massFlow = 0 // Set initial values
       PipeTemperature.SF = InitVals.TofHTFinPipes
       PipeTemperature.PB = InitVals.TofHTFinPipes
       solarField.temperature.inlet = PipeTemperature.SF
       solarField.temperature.outlet  = PipeTemperature.PB
       avgLoop.now = nearLoop.now
       farLoop.now = nearLoop.now
       
       }
       */
      heatFlow.solar = 0
      // Exit Sub  // - IF solarField.isMaintained -
    }
    
    // SWAP last, now  // What can be expected from SF with new Temp. in near loop
    var swap = designLoop.last
    designLoop.last = designLoop.now
    designLoop.now = swap
    
    swap = avgLoop.last
    avgLoop.last = avgLoop.now
    avgLoop.now = swap
    
    swap = nearLoop.last
    nearLoop.last = nearLoop.now
    nearLoop.now = swap
    
    swap = farLoop.last
    farLoop.last = farLoop.now
    farLoop.now = swap
    
    if case .freezeProtection = solarField.operationMode {
      nearLoop.last.temperature.inlet = solarField.temperature.inlet
      avgLoop.last.temperature.inlet = solarField.temperature.inlet
      farLoop.last.temperature.inlet = solarField.temperature.inlet
      designLoop.last.temperature.inlet = solarField.temperature.inlet
    }
    
    //solarField.operationMode = .unknown
    // CalcnearLoop  // which gives the basic values for further decisions.
    
    switch solarField.operationMode { // Check HCE and decide what to do
    case .operating: break // OPERATING
      // CalcTempSF
    // ParPowSF
    case .freezeProtection: // Freeze Protection (Pumping)
      // CalcTempSF
      heatFlow.solar = parameter.antiFreezeParastics // Account for parasitic heatFlow
    case .noOperation: // does not neccessary mean no operation, see:
      if solarField.temperature.outlet > HeatExchanger.parameter.temperature.htf.inlet.min,
        solarField.temperature.outlet > solarField.temperature.inlet {
        // AND NOT (Heater.solarField.OPmode = "OP" OR Boiler.solarField.OPmode = "OP") THEN
        // Force operation at massFlow.min: the last SF Tout > HeatExchanger.parameter.HTFinTmin: a fraction of
        // timeRemain can be produced now, even if the new SF Tout drops under Tminop.
        solarField.operationMode = .operating
        // CalcnearLoop
        // CalcTempSF
        // ParPowSF
      } else { // NO operation: The heat losses in HCEs for the rest of IMet.period
        // were calculated. NOTE: dtime might be shorter than IMet.period, if
        // HTFinHCE.temperature.outlet  dropped beyond T(freeze prot.) during that period.
        // CalcTempSF
        heatFlow.solar = 0
      }
      
    default: // HCE returns with solarField.OPmode = unknown
      //  if solarField.temperature.outlet > HeatExchanger.parameter.temperature.htf.inlet.min && Not (Heater.solarField.operationMode = "OP" || Boiler.solarField.operationMode = "OP") {
      if solarField.temperature.outlet > HeatExchanger.parameter.temperature.htf.inlet.min {
        // Boiler wurde hier rausgenommen, wegen nachrechenen von SEGS VI
        solarField.operationMode = .operating // Operation at minimum mass flow
        // CalcTempSF
        // ParPowSF
        //FIXME } else if avgins > lastavgins + Simulation.parameter.minInsolationRaiseStartUp {
        // AND HTFinHCE.temperature.outlet > HTFinHCE.temperature.inlet + Simulation.parameter.minTemperatureRaiseStartUp
        solarField.operationMode = .startUp
        // CalcTempSF
        // ParPowSF
      } else { // Force No Operation: Calc. the heat losses in HCEs for the rest of IMet.period
        solarField.operationMode = .noOperation
        // CalcnearLoop
        // NOTE: dtime after next calculation might be shorter than oldTime,
        // if HTFinHCE,Tout drops beyond freeze protection Temp. during that period.
        // CalcTempSF
        heatFlow.solar = 0
      } // solarField.temperature.outlet > HeatExchanger.parameter.HTFinTmin
    }
    
    // Exit Sub
    
    // CalcnearLoop:
    /*
     while true {
     designLoop.now.temperature.inlet = nearLoop.last.temperature.inlet // - Collect solar -
     //FIXME HCE(solarField.operationMode, designLoop.now, time, designLoop.last?)
     if designLoop.now.massFlow == 0 { // $$$P
     //FIXME timeRemain = dtime // normally IMet.period, but not always in FP mode.
     designLoop.now.temperature.inlet = designLoop.now.temperature.outlet //
     // Hierdurch soll Freeze Protection aktiviert werden, bisherige Version tat dieses nicht
     } else {
     //FIXME timeRemain = dtime // * parameter.DistRatio
     }
     // .. Check CalcTime% and repeat solar collection if neccessary ...
     //FIXME if timeRemain > imet.period {
     // AvgMeteodata(timeRemain)
     // if NoRecsLeft { break }
     //} else {
     // break
     //}
     }
     */
    solarField.massFlow = designLoop.now.massFlow
    
    // CalcTempSF:   // (only called when massFlow > 0)
    // Calc. loop-outlet temp. gradient / Near loop was already calculated.
    nearLoop.now.massFlow = solarField.massFlow
      * ((solarField.massFlow - parameter.massFlow.min)
        * (parameter.imbalanceDesign.near - parameter.imbalanceMin.near)
        / (parameter.massFlow.max - parameter.massFlow.min)
        + parameter.imbalanceMin.near) // new, based on user inputs.
    nearLoop.now.temperature.inlet = nearLoop.last.temperature.inlet // avgLoop.now.Tout
    //HCE.operate(mode: .fixed, solarField: nearLoop.now, collector: nearLoop.last?, heatFlow: &heatFlow, date: date, meteo: meteo)
    
    avgLoop.now.massFlow = solarField.massFlow
      * ((solarField.massFlow - parameter.massFlow.min)
        * (parameter.imbalanceDesign.average - parameter.imbalanceMin.average)
        / (parameter.massFlow.max - parameter.massFlow.min)
        + parameter.imbalanceMin.average) // new, based on user inputs.
    avgLoop.now.temperature.inlet = avgLoop.last.temperature.inlet // avgLoop.now.Tout
    
    farLoop.now.massFlow = solarField.massFlow
      * ((solarField.massFlow - parameter.massFlow.min)
        * (parameter.imbalanceDesign.far - parameter.imbalanceDesign.far)
        / (parameter.massFlow.max - parameter.massFlow.min)
        + parameter.imbalanceMin.far) // new, based on user inputs.
    farLoop.now.temperature.inlet = farLoop.last.temperature.inlet // farLoop.now.temperature.inlet
    
    //HCE.operate(mode: .fixed, solarField: farLoop.now, collector: farLoop.last?, heatFlow: &heatFlow, date: date, meteo: meteo)
    HCE.operate(mode: .operating, solarField: &solarField,
                collector: &Collector.status, heatFlow: &heatFlow,
                date: date, meteo: meteo)
    
    solarField.massFlow = (nearLoop.now.massFlow + avgLoop.now.massFlow + farLoop.now.massFlow) / 3
    if solarField.massFlow > 0 {
      var OneMinusTR: Double
      var OneMinusTRN: Double
      var OneMinusTRA: Double
      var OneMinusTRF: Double
      let designFlowVelocity = 2.7
      
      if timeRemain < parameter.loopWay / (designFlowVelocity
        * solarField.massFlow / parameter.massFlow.max) {
        
        let timeRatio = timeRemain / (parameter.loopWay
          / (designFlowVelocity * solarField.massFlow / parameter.massFlow.max)) // Correct the loop outlet temperatures
        OneMinusTR = 1 - timeRatio
        nearLoop.now.temperature.outlet = timeRatio
          * nearLoop.now.temperature.outlet
          + OneMinusTR * nearLoop.last.temperature.outlet
        avgLoop.now.temperature.outlet = timeRatio
          * avgLoop.now.temperature.outlet
          + OneMinusTR * avgLoop.last.temperature.outlet
        farLoop.now.temperature.outlet = timeRatio
          * farLoop.now.temperature.outlet
          + OneMinusTR * farLoop.last.temperature.outlet
      } // - IF timeRemain < dtime -
      
      var timeRatioNear = timeRemain / (parameter.nearWay /
        (designFlowVelocity * nearLoop.now.massFlow / parameter.massFlow.max))
      if timeRatioNear > 1 {
        timeRatioNear = 1
        OneMinusTRN = 0
      } else {
        OneMinusTRN = 1 - timeRatioNear
      }
      var timeRatioAvg = timeRemain / (parameter.avgWay /
        (designFlowVelocity * avgLoop.now.massFlow / parameter.massFlow.max))
      if timeRatioAvg > 1 {
        timeRatioAvg = 1
        OneMinusTRA = 0
      } else {
        OneMinusTRA = 1 - timeRatioAvg
      }
      var timeRatioFar = timeRemain / (parameter.farWay /
        (designFlowVelocity * farLoop.now.massFlow / parameter.massFlow.max))
      if timeRatioFar > 1 {
        timeRatioFar = 1
        OneMinusTRF = 0
      } else {
        OneMinusTRF = 1 - timeRatioFar
      }
      
      let T0 = timeRatioNear * nearLoop.now.temperature.outlet
        + OneMinusTRN * nearLoop.last.temperature.outlet
      // check .last?.temperature.outlet  is too high 507K! therefore solarField.temperature.outlet  is high too!
      let T1 = timeRatioAvg * avgLoop.now.temperature.outlet
        + OneMinusTRA * avgLoop.last.temperature.outlet
      let T2 = timeRatioFar * farLoop.now.temperature.outlet
        + OneMinusTRF * farLoop.last.temperature.outlet
      
      solarField.temperature.outlet = (T0 * nearLoop.now.massFlow
        + T1 * avgLoop.now.massFlow
        + T2 * farLoop.now.massFlow)
        / (3 * solarField.massFlow) // check, example 504 K
      // PipeTemperature.PB = solarField.temperature.outlet
      
      // farLoop.now.temperature.inlet = PipeTemperature.SF
      
      // PipeTemperature.SF = solarField.temperature.inlet
      
      // Now calc. the linear inlet temperature gradient:
      /* var WayRatio = parameter.avgWay / parameter.pipeWay
       avgLoop.now.temperature.inlet = farLoop.now.temperature.inlet + WayRatio
       * (PipeTemperature.SF - farLoop.now.temperature.inlet)
       nearLoop.now.temperature.inlet = farLoop.now.temperature.inlet + 2 * WayRatio
       * (PipeTemperature.SF - farLoop.now.temperature.inlet)
       
       nearLoop.now.temperature.inlet = timeRatioNear * solarField.temperature.inlet
       + OneMinusTRN * nearLoop.last.temperature.inlet
       avgLoop.now.temperature.inlet = timeRatioAvg * solarField.temperature.inlet
       + OneMinusTRA * avgLoop.last.temperature.inlet
       farLoop.now.temperature.inlet = timeRatioFar * solarField.temperature.inlet
       + OneMinusTRF * farLoop.last.temperature.inlet
       PipeTemperature.SF = solarField.temperature.inlet
       */
    }
  }
}
