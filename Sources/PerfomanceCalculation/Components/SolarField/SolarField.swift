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

public enum SolarField: Component {
  
  final class Instance {
    // A singleton class holding the state of the steam turbine
    fileprivate static let shared = Instance()
    var parameter: SolarField.Parameter!
    var workingConditions: (previous: PerformanceData?, current: PerformanceData)
    
    private init() {
      workingConditions = (nil, initialState)
    }
  }
  
  public struct HTFstatus {
    var massFlow: Double
    var temperature: (inlet: Double, outlet: Double)
    
    init() {
      self.massFlow = 0
      let temperature = Simulation.initialValues.temperatureOfHTFinPipes
      self.temperature = (inlet: temperature, outlet: temperature)
    }
  }
  
  /// a struct for operation-relevant data of the steam turbine
  public struct PerformanceData: MassFlow, WorkingConditions {
    var operationMode: OperationMode
    let isMaintained: Bool
    var heatFlow: Double
    var header: HTFstatus
    var ITA: Double
    var ETA: Double
    var HL: Double
    var heatLossHeader: Double
    var heatLossHCE: Double
    var inFocus: Ratio
    var designLoop: HTFstatus
    var nearLoop: HTFstatus
    var averageLoop: HTFstatus
    var farLoop: HTFstatus
    var loopEta: Double
    var massFlow: Double { return header.massFlow }
    var temperature: (inlet: Double, outlet: Double) { return header.temperature }
    
    public enum OperationMode: String {
      case startUp, freezeProtection, operating,
      noOperation, scheduledMaintenance, unknown, ph
    }
  }
  
  static let initialState = PerformanceData(
    operationMode: .scheduledMaintenance,
    isMaintained: false,
    heatFlow: 0.0,
    header: HTFstatus(),
    ITA: 0,
    ETA: 0,
    HL: 0,
    heatLossHeader: 0,
    heatLossHCE: 0,
    inFocus: 0.0,
    designLoop: HTFstatus(),
    nearLoop: HTFstatus(),
    averageLoop: HTFstatus(),
    farLoop: HTFstatus(),
    loopEta: 0
    )
  
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
  private static func parasitics(massFlow: Double) -> Double {
    let load = massFlow / parameter.massFlow.max
    return parameter.pumpParasticsFullLoad
      * (parameter.pumpParastics[0] + parameter.pumpParastics[1]
      * load + parameter.pumpParastics[2] * load ** 2)
  }
  
  public static func pipeHeatLoss(_ temperature: Double, ambient: Double) -> Double {
    return ((temperature - ambient) / 333) ** 1 * parameter.pipeHL
  }
  /*
  fileprivate static func calculateNear(
    _ designLoop: inout (now: SolarField.HTFstatus, last: SolarField.HTFstatus),
    _ nearLoop: (now: SolarField.HTFstatus, last: SolarField.HTFstatus)) {
    // Exit Sub
    
    // CalcnearLoop:
    
    while true {
      designLoop.now.temperature.inlet = nearLoop.last.temperature.inlet // - Collect solar -
      //FIXME HCE(solarField.operationMode, designLoop, time, designLoop.last?)
      if designLoop.now.massFlow == 0 {
        //FIXME timeRemain = dtime // normally IMet.period, but not always in FP mode.
        designLoop.now.temperature.inlet = designLoop.last.temperature.outlet //
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
    SolarField.status.htf.massFlow = designLoop.now.massFlow
  }
   
  */
  /// Calc. loop-outlet temp. gradient / Near loop was already calculated.
  public static func temperature(solarField: inout SolarField.PerformanceData,
                               date: Date, meteo: MeteoData, timeRemain: Double) {
	let last = SolarField.status

    solarField.nearLoop.massFlow = solarField.header.massFlow
      * ((solarField.header.massFlow - parameter.massFlow.min)
        * (parameter.imbalanceDesign.near - parameter.imbalanceMin.near)
        / (parameter.massFlow.max - parameter.massFlow.min)
        + parameter.imbalanceMin.near) // new, based on user inputs.
    solarField.nearLoop.temperature.inlet = last.header.temperature.inlet // averageLoop.Tout
    //HCE.operate(mode: .fixed, solarField: nearLoop, collector: nearLoop.last?, heatFlow: &heatFlow, date: date, meteo: meteo)
    HCE.calculation(&solarField.nearLoop, mode: .fixed, date: date, meteo: meteo)
    solarField.averageLoop.massFlow = solarField.header.massFlow
      * ((solarField.header.massFlow - parameter.massFlow.min)
        * (parameter.imbalanceDesign.average - parameter.imbalanceMin.average)
        / (parameter.massFlow.max - parameter.massFlow.min)
        + parameter.imbalanceMin.average) // new, based on user inputs.
    solarField.averageLoop.temperature.inlet = last.averageLoop.temperature.inlet // averageLoop.Tout
    HCE.calculation(&solarField.averageLoop, mode: .fixed, date: date, meteo: meteo)
    
    solarField.farLoop.massFlow = solarField.header.massFlow
      * ((solarField.header.massFlow - parameter.massFlow.min)
        * (parameter.imbalanceDesign.far - parameter.imbalanceDesign.far)
        / (parameter.massFlow.max - parameter.massFlow.min)
        + parameter.imbalanceMin.far) // new, based on user inputs.
    solarField.farLoop.temperature.inlet = last.farLoop.temperature.inlet // farLoop.temperature.inlet
    
    //HCE.operate(mode: .fixed, solarField: farLoop, collector: farLoop.last?, heatFlow: &heatFlow, date: date, meteo: meteo)
    HCE.calculation(&solarField.farLoop, mode: .fixed, date: date, meteo: meteo)
    
    solarField.header.massFlow = (solarField.nearLoop.massFlow
      + solarField.averageLoop.massFlow
      + solarField.farLoop.massFlow) / 3
    
    if solarField.header.massFlow > 0 {
      var OneMinusTR: Double
      var OneMinusTRN: Double
      var OneMinusTRA: Double
      var OneMinusTRF: Double
      let designFlowVelocity = 2.7
      
      if timeRemain < parameter.loopWay / (designFlowVelocity
        * solarField.header.massFlow / parameter.massFlow.max) {
        
        let timeRatio = timeRemain / (parameter.loopWay
          / (designFlowVelocity * solarField.header.massFlow / parameter.massFlow.max)) // Correct the loop outlet temperatures
        OneMinusTR = 1 - timeRatio
        solarField.nearLoop.temperature.outlet = timeRatio
          * solarField.nearLoop.temperature.outlet
          + OneMinusTR * SolarField.previous!.nearLoop.temperature.outlet
        solarField.averageLoop.temperature.outlet = timeRatio
          * solarField.averageLoop.temperature.outlet
          + OneMinusTR * SolarField.previous!.averageLoop.temperature.outlet
        solarField.farLoop.temperature.outlet = timeRatio
          * solarField.farLoop.temperature.outlet
          + OneMinusTR * SolarField.previous!.farLoop.temperature.outlet
      } // - IF timeRemain < dtime -
      
      var timeRatioNear = timeRemain / (parameter.nearWay /
        (designFlowVelocity * solarField.nearLoop.massFlow / parameter.massFlow.max))
      if timeRatioNear > 1 {
        timeRatioNear = 1
        OneMinusTRN = 0
      } else {
        OneMinusTRN = 1 - timeRatioNear
      }
      var timeRatioAvg = timeRemain / (parameter.avgWay /
        (designFlowVelocity * solarField.averageLoop.massFlow / parameter.massFlow.max))
      if timeRatioAvg > 1 {
        timeRatioAvg = 1
        OneMinusTRA = 0
      } else {
        OneMinusTRA = 1 - timeRatioAvg
      }
      var timeRatioFar = timeRemain / (parameter.farWay /
        (designFlowVelocity * solarField.farLoop.massFlow / parameter.massFlow.max))
      if timeRatioFar > 1 {
        timeRatioFar = 1
        OneMinusTRF = 0
      } else {
        OneMinusTRF = 1 - timeRatioFar
      }
      
      let T0 = timeRatioNear * solarField.nearLoop.temperature.outlet
        + OneMinusTRN * last.nearLoop.temperature.outlet
      // check .last?.temperature.outlet  is too high 507K! therefore solarField.htf.temperature.outlet  is high too!
      let T1 = timeRatioAvg * solarField.averageLoop.temperature.outlet
        + OneMinusTRA * last.averageLoop.temperature.outlet
      let T2 = timeRatioFar * solarField.farLoop.temperature.outlet
        + OneMinusTRF * last.farLoop.temperature.outlet
      
      solarField.header.temperature.outlet = (T0 * solarField.nearLoop.massFlow
        + T1 * solarField.averageLoop.massFlow
        + T2 * solarField.farLoop.massFlow)
        / (3 * solarField.header.massFlow) // check, example 504 K
      // PipeTemperature.PB = solarField.htf.temperature.outlet
      
      // farLoop.temperature.inlet = PipeTemperature.SF
      
      // PipeTemperature.SF = solarField.htf.temperature.inlet
      
      // Now calc. the linear inlet temperature gradient:
      /* var WayRatio = parameter.avgWay / parameter.pipeWay
       averageLoop.temperature.inlet = farLoop.temperature.inlet + WayRatio
       * (PipeTemperature.SF - farLoop.temperature.inlet)
       nearLoop.temperature.inlet = farLoop.temperature.inlet + 2 * WayRatio
       * (PipeTemperature.SF - farLoop.temperature.inlet)
       
       nearLoop.temperature.inlet = timeRatioNear * solarField.htf.temperature.inlet
       + OneMinusTRN * nearLoop.last.temperature.inlet
       averageLoop.temperature.inlet = timeRatioAvg * solarField.htf.temperature.inlet
       + OneMinusTRA * avgLoop.last.temperature.inlet
       farLoop.temperature.inlet = timeRatioFar * solarField.htf.temperature.inlet
       + OneMinusTRF * farLoop.last.temperature.inlet
       PipeTemperature.SF = solarField.htf.temperature.inlet
       */
    }
  }
  
  public static func calculate(date: Date, meteo: MeteoData, timeRemain: Double,
                               solarField: inout SolarField.PerformanceData) {
    
    if solarField.isMaintained { // Check if maintained
      Plant.electricalParasitics.solarField = 0
      if case .scheduledMaintenance = solarField.operationMode  { // First Day of Maintenance
        return
      }
      solarField = SolarField.initialState
      return
    }
    
    if case .freezeProtection = solarField.operationMode {
      solarField.nearLoop.temperature.inlet = solarField.header.temperature.inlet
      solarField.averageLoop.temperature.inlet = solarField.header.temperature.inlet
      solarField.farLoop.temperature.inlet = solarField.header.temperature.inlet
      solarField.designLoop.temperature.inlet = solarField.header.temperature.inlet
    }
    
    //solarField.operationMode = .unknown
    // CalcnearLoop  // which gives the basic values for further decisions.
    
    switch solarField.operationMode { // Check HCE and decide what to do
    case .operating:  // OPERATING
      temperature(solarField: &solarField, date: date, meteo: meteo, timeRemain: 0)
      Plant.electricalParasitics.solarField = parasitics(massFlow: solarField.header.massFlow)
    case .freezeProtection: // Freeze Protection (Pumping)
      temperature(solarField: &solarField, date: date, meteo: meteo, timeRemain: 0)
      Plant.electricalParasitics.solarField = parameter.antiFreezeParastics // Account for parasitic heatFlow
    case .noOperation: // does not neccessary mean no operation, see:
      if solarField.header.temperature.outlet > HeatExchanger.parameter.temperature.htf.inlet.min,
        solarField.header.temperature.outlet > solarField.header.temperature.inlet {
        // AND NOT (Heater.solarField.OPmode = "OP" OR Boiler.solarField.OPmode = "OP") THEN
        // Force operation at massFlow.min: the last SF Tout > HeatExchanger.parameter.HTFinTmin: a fraction of
        // timeRemain can be produced now, even if the new SF Tout drops under Tminop.
        solarField.operationMode = .operating
        // CalcnearLoop
        temperature(solarField: &solarField, date: date, meteo: meteo, timeRemain: 0)
        Plant.electricalParasitics.solarField = parasitics(massFlow: solarField.header.massFlow)
      } else { // NO operation: The heat losses in HCEs for the rest of IMet.period
        // were calculated. NOTE: dtime might be shorter than IMet.period, if
        // HTFinHCE.temperature.outlet  dropped beyond T(freeze prot.) during that period.
        temperature(solarField: &solarField, date: date, meteo: meteo, timeRemain: 0)
        Plant.electricalParasitics.solarField =  0
      }
      
    default: // HCE returns with solarField.OPmode = unknown
      //  if solarField.htf.temperature.outlet > HeatExchanger.parameter.temperature.htf.inlet.min && Not (Heater.solarField.operationMode = "OP" || Boiler.solarField.operationMode = "OP") {
      if solarField.header.temperature.outlet > HeatExchanger.parameter.temperature.htf.inlet.min {
        // Boiler wurde hier rausgenommen, wegen nachrechenen von SEGS VI
        solarField.operationMode = .operating // Operation at minimum mass flow
        temperature(solarField: &solarField, date: date, meteo: meteo, timeRemain: 0)
        Plant.electricalParasitics.solarField = parasitics(massFlow: solarField.massFlow)
       /* } else if avgins > lastavgins + Simulation.parameter.minInsolationRaiseStartUp,
         HTFinHCE.temperature.outlet > HTFinHCE.temperature.inlet + Simulation.parameter.minTemperatureRaiseStartUp {
        solarField.operationMode = .startUp
        temperature(solarField: &solarField, date: date, meteo: meteo, timeRemain: 0)
        Plant.electricalParasitics.solarField = parasitics(massFlow: solarField.massFlow)*/
      } else { // Force No Operation: Calc. the heat losses in HCEs for the rest of IMet.period
        solarField.operationMode = .noOperation
        // CalcnearLoop
        // NOTE: dtime after next calculation might be shorter than oldTime,
        // if HTFinHCE,Tout drops beyond freeze protection Temp. during that period.
        temperature(solarField: &solarField, date: date, meteo: meteo, timeRemain: 0)
        Plant.electricalParasitics.solarField = 0
      } // solarField.htf.temperature.outlet > HeatExchanger.parameter.HTFinTmin
    }
    
    // calculateNear(&designLoop, nearLoop)
    

  }
}
