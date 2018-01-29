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
  
  public struct HTFstatus: Equatable, CustomStringConvertible {
    var massFlow: MassFlow 
    var temperature: (inlet: Temperature, outlet: Temperature)
    
    var averageTemperature: Temperature {
      return Temperature((temperature.inlet + temperature.outlet).kelvin / 2)
    }
    
    init() {
      self.massFlow = 0.0
      let temperature = Simulation.initialValues.temperatureOfHTFinPipes
      self.temperature = (inlet: temperature, outlet: temperature)
    }
    
    public var description: String {
      return String(format:"(Mfl: %.2f ", massFlow.rate)
        + String(format:"Inlet: %.1f ", temperature.inlet.celsius)
        + String(format:"Outlet: %.1f)", temperature.outlet.celsius)
    }
    
    public static func ==(lhs: HTFstatus, rhs: HTFstatus) -> Bool {
      return lhs.massFlow == rhs.massFlow
        && lhs.temperature.inlet == rhs.temperature.inlet
        && lhs.temperature.outlet == rhs.temperature.outlet
    }
  }
  
  /// a struct for operation-relevant data of the steam turbine
  public struct PerformanceData: Equatable, HeatTransfer, WorkingConditions {
    var operationMode: OperationMode
    var isMaintained: Bool
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
    var massFlow: MassFlow { return header.massFlow }
    var temperature: (inlet: Temperature, outlet: Temperature) {
      return header.temperature
    }
    
    public enum OperationMode: String, CustomStringConvertible {
      case startUp, freezeProtection, operating,
      noOperation, scheduledMaintenance, unknown, ph, fixed
      
      public var description: String {
        return self.rawValue
      }
    }
    
    public static func ==(lhs: PerformanceData, rhs: PerformanceData) -> Bool {
      return lhs.operationMode == rhs.operationMode
        && lhs.isMaintained == rhs.isMaintained
        && lhs.header == rhs.header
        && lhs.ITA == rhs.ITA
        && lhs.ETA == rhs.ETA
        && lhs.HL == rhs.HL
        && lhs.heatLossHeader == rhs.heatLossHeader
        && lhs.heatLossHCE == rhs.heatLossHCE
        && lhs.inFocus == rhs.inFocus
        && lhs.designLoop == rhs.designLoop
        && lhs.nearLoop == rhs.nearLoop
        && lhs.averageLoop == rhs.averageLoop
        && lhs.farLoop == rhs.farLoop
        && lhs.loopEta == rhs.loopEta
    }
  }
  
  static let initialState = PerformanceData(
    operationMode: .scheduledMaintenance,
    isMaintained: false,
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
      if Instance.shared.workingConditions.current != newValue {
        Log.debugMessage("Solarfield \(Instance.shared.workingConditions.current)")
        Instance.shared.workingConditions =
          (Instance.shared.workingConditions.current, newValue)
      }
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
  private static func parasitics(massFlow: MassFlow) -> Double {
    let load = massFlow.share(of: parameter.massFlow.max).ratio
    return parameter.pumpParasticsFullLoad
      * (parameter.pumpParastics[0] + parameter.pumpParastics[1]
      * load + parameter.pumpParastics[2] * load ** 2)
  }
  
  public static func pipeHeatLoss(
    _ temperature: Temperature, ambient: Temperature) -> Double {
    return ((temperature - ambient).kelvin / 333) ** 1 * parameter.pipeHL
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
      if designLoop.now.massFlow.isZero {
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
  public static func outletTemperature(solarField: inout SolarField.PerformanceData,
                                       meteo: MeteoData, timeRemain: Double) {
	let last = SolarField.status
    let mode = solarField.operationMode.collector
    HCE.calculation(&solarField.designLoop, mode: mode, meteo: meteo)
    // debugPrint(solarField.designLoop)
    solarField.nearLoop.massFlow = MassFlow(solarField.header.massFlow.rate
      * ((solarField.header.massFlow - parameter.massFlow.min).rate
        * (parameter.imbalanceDesign.near - parameter.imbalanceMin.near)
        / (parameter.massFlow.max - parameter.massFlow.min).rate
        + parameter.imbalanceMin.near))
    solarField.nearLoop.temperature.inlet = last.header.temperature.inlet
    
    HCE.calculation(&solarField.nearLoop, mode: mode, meteo: meteo)
    // debugPrint(solarField.nearLoop)
    solarField.averageLoop.massFlow = MassFlow(solarField.header.massFlow.rate
      * ((solarField.header.massFlow - parameter.massFlow.min).rate
        * (parameter.imbalanceDesign.average - parameter.imbalanceMin.average)
        / (parameter.massFlow.max - parameter.massFlow.min).rate
        + parameter.imbalanceMin.average))
    solarField.averageLoop.temperature.inlet = last.averageLoop.temperature.inlet
    
    HCE.calculation(&solarField.averageLoop, mode: mode, meteo: meteo)
    // debugPrint(solarField.averageLoop)
    solarField.farLoop.massFlow = MassFlow(solarField.header.massFlow.rate
      * ((solarField.header.massFlow - parameter.massFlow.min).rate
        * (parameter.imbalanceDesign.far - parameter.imbalanceMin.far)
        / (parameter.massFlow.max - parameter.massFlow.min).rate
        + parameter.imbalanceMin.far))
    solarField.farLoop.temperature.inlet = last.farLoop.temperature.inlet
    
    HCE.calculation(&solarField.farLoop, mode: mode, meteo: meteo)
    // debugPrint(solarField.farLoop)
    solarField.header.massFlow = MassFlow((solarField.nearLoop.massFlow
      + solarField.averageLoop.massFlow
      + solarField.farLoop.massFlow).rate / 3)
    
    if !solarField.header.massFlow.isNearZero {
      var OneMinusTR: Double
      var OneMinusTRN: Double
      var OneMinusTRA: Double
      var OneMinusTRF: Double
      let designFlowVelocity: Double = 2.7
      
      if timeRemain < parameter.loopWay / (designFlowVelocity
        * solarField.header.massFlow.rate / parameter.massFlow.max.rate) {
        
        let timeRatio = timeRemain / (parameter.loopWay
          / (designFlowVelocity * solarField.header.massFlow.rate / parameter.massFlow.max.rate)) // Correct the loop outlet temperatures
        OneMinusTR = 1 - timeRatio
        solarField.nearLoop.temperature.outlet = Temperature(timeRatio
          * solarField.nearLoop.temperature.outlet.kelvin
          + OneMinusTR * SolarField.previous!.nearLoop.temperature.outlet.kelvin)
        solarField.averageLoop.temperature.outlet = Temperature(timeRatio
          * solarField.averageLoop.temperature.outlet.kelvin
          + OneMinusTR * SolarField.previous!.averageLoop.temperature.outlet.kelvin)
        solarField.farLoop.temperature.outlet = Temperature(timeRatio
          * solarField.farLoop.temperature.outlet.kelvin
          + OneMinusTR * SolarField.previous!.farLoop.temperature.outlet.kelvin)
      } // - IF timeRemain < dtime -
      
      var timeRatioNear = timeRemain / (parameter.nearWay /
        (designFlowVelocity * solarField.nearLoop.massFlow.rate / parameter.massFlow.max.rate))
      if timeRatioNear > 1 {
        timeRatioNear = 1
        OneMinusTRN = 0
      } else {
        OneMinusTRN = 1 - timeRatioNear
      }
      var timeRatioAvg = timeRemain / (parameter.avgWay /
        (designFlowVelocity * solarField.averageLoop.massFlow.rate / parameter.massFlow.max.rate))
      if timeRatioAvg > 1 {
        timeRatioAvg = 1
        OneMinusTRA = 0
      } else {
        OneMinusTRA = 1 - timeRatioAvg
      }
      var timeRatioFar = timeRemain / (parameter.farWay /
        (designFlowVelocity * solarField.farLoop.massFlow.rate / parameter.massFlow.max.rate))
      if timeRatioFar > 1 {
        timeRatioFar = 1
        OneMinusTRF = 0
      } else {
        OneMinusTRF = 1 - timeRatioFar
      }
      
      let T0 = timeRatioNear * solarField.nearLoop.temperature.outlet.kelvin
        + OneMinusTRN * last.nearLoop.temperature.outlet.kelvin
      // check .last?.temperature.outlet  is too high 507K! therefore solarField.htf.temperature.outlet  is high too!
      let T1 = timeRatioAvg * solarField.averageLoop.temperature.outlet.kelvin
        + OneMinusTRA * last.averageLoop.temperature.outlet.kelvin
      let T2 = timeRatioFar * solarField.farLoop.temperature.outlet.kelvin
        + OneMinusTRF * last.farLoop.temperature.outlet.kelvin
      
      solarField.header.temperature.outlet = Temperature(
        (T0 * solarField.nearLoop.massFlow.rate
        + T1 * solarField.averageLoop.massFlow.rate
        + T2 * solarField.farLoop.massFlow.rate)
        / (3 * solarField.header.massFlow.rate)) // check, example 504 K
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
  
  static func operate(demand: Ratio, timeRemain: Double, meteo: MeteoData) {
    var solarField = SolarField.status
    defer { SolarField.status = solarField }
    if Design.hasStorage {
      switch Storage.status.operationMode {
      case .freezeProtection:
        if Storage.parameter.tempInCst[1] > 0 {
          solarField.header.temperature.inlet = solarField.header.temperature.outlet
        } else {
          solarField.header.temperature.inlet = Temperature(Storage.status.StoTcoldTout)
        }
      case .sc:
        solarField.header.temperature.inlet = Storage.status.temperatureTank.cold
      case .charging where Plant.heatFlow.production == 0:
        solarField.header.temperature.inlet = solarField.header.temperature.outlet
      default:
        solarField.header.temperature.inlet = PowerBlock.status.temperature.outlet
      }
    } else {
      solarField.header.temperature.inlet = PowerBlock.status.temperature.outlet
    }
    
    Plant.heatFlow.dump = 0
    
    solarField.header.massFlow = SolarField.parameter.massFlow.max
    
    if demand.ratio < 1 { // added to reduced SOF massflow with electrical demand
      
      solarField.header.massFlow = MassFlow(demand.ratio
        * (SteamTurbine.parameter.power.max
        / SteamTurbine.parameter.efficiencyNominal
        / HeatExchanger.parameter.efficiency)
        / (htf.heatDelta(
          HeatExchanger.parameter.temperature.htf.inlet.max,
          HeatExchanger.parameter.temperature.htf.outlet.max) / 1_000))
      
      solarField.header.massFlow = max(
        MassFlow(1180), solarField.header.massFlow + Storage.parameter.massFlow)
    }
    
    if Design.hasStorage,
      Storage.status.heatrel >= Storage.parameter.chargeTo {
      if Design.hasGasTurbine {
        solarField.header.massFlow = HeatExchanger.parameter.SCCHTFmassFlow
      } else {
        // changed to reduced SOF massflow with electrical demand
        solarField.header.massFlow = MassFlow(demand.ratio
          * (SteamTurbine.parameter.power.max
            / SteamTurbine.parameter.efficiencyNominal
            / HeatExchanger.parameter.efficiency)
          / (htf.heatDelta(
            HeatExchanger.parameter.temperature.htf.inlet.max,
            HeatExchanger.parameter.temperature.htf.outlet.max) / 1_000))
      }
    }
    
    SolarField.calculate(meteo: meteo, timeRemain: timeRemain,
                         solarField: &solarField)
    
    // the next is added to determine temperature drop in hot header
    var temperatureNow = solarField.header.temperature.outlet
    var temperatureLast = temperatureNow
    
    for _ in 1 ... 10 {
      
      solarField.heatLossHeader *= SolarField.parameter.heatLossHeader[0]
      // FIXME  + SolarField.parameter.heatLossHeader
      // FIXME  * (temperatureNow - meteo.temperature) // [MWt]
      solarField.heatLossHeader *= 1_000_000
        / (Design.layout.solarField * Double(SolarField.parameter.numberOfSCAsInRow)
          * 2 * Collector.parameter.areaSCAnet)
      // for hourly results and night cooldown [W/m2 ap.]
      let temp = temperatureLast
      temperatureLast = temperatureNow
      temperatureNow = temp
      
      if solarField.header.massFlow.rate > 0 {
        let dQHL = solarField.heatLossHeader * 1_000 / solarField.header.massFlow.rate // [kJ/kg]
        temperatureNow = htf.temperatureDelta(-dQHL, solarField.header.temperature.outlet)
      } else {
        let averageTemperature = Temperature(
          (temperatureNow + solarField.header.temperature.outlet).kelvin / 2)
        // Calculate average Temp. and Areadens
        let areadens = htf.density(averageTemperature) * .pi
          * Collector.parameter.rabsInner ** 2 / Collector.parameter.aperture // kg/m2
        let dQperSqm = solarField.heatLossHeader  // FIXME * dtime / 1_000
        // Heat collected or lost during the flow through a whole loop [kJ/sqm]
        let dQperkg = dQperSqm / areadens // Change kJ/sqm to kJ/kg:
        let Qperkg = htf.heatDelta(
          solarField.header.temperature.outlet, Temperature(celsius: meteo.temperature))
        temperatureNow = htf.temperatureDelta(
          Qperkg - dQperkg, Temperature(celsius: meteo.temperature))
      }
      
      temperatureNow = min(htf.maxTemperature, temperatureNow)
      temperatureLast = min(htf.maxTemperature, temperatureLast)
      let temperatureDifference = abs(temperatureNow.kelvin - temperatureLast.kelvin)
      if temperatureDifference < Simulation.parameter.HLtempTolerance {
        break
      }
    }
    solarField.header.temperature.outlet = temperatureNow
  }
  
  public static func calculate(meteo: MeteoData, timeRemain: Double,
                               solarField: inout SolarField.PerformanceData) {
    
    if solarField.isMaintained { 
      Plant.electricalParasitics.solarField = 0
      if case .scheduledMaintenance = solarField.operationMode { return }
      // First Day of Maintenance
      solarField = SolarField.initialState
      return
    }
    
    if case .freezeProtection = solarField.operationMode {
      solarField.nearLoop.temperature.inlet = solarField.header.temperature.inlet
      solarField.averageLoop.temperature.inlet = solarField.header.temperature.inlet
      solarField.farLoop.temperature.inlet = solarField.header.temperature.inlet
      solarField.designLoop.temperature.inlet = solarField.header.temperature.inlet
    }
    
    solarField.operationMode = .unknown
    HCE.calculation(&solarField.nearLoop, mode: .variable, meteo: meteo)
    // CalcnearLoop  // which gives the basic values for further decisions.
    
    switch solarField.operationMode { // Check HCE and decide what to do
    case .operating:  // OPERATING
      outletTemperature(solarField: &solarField, meteo: meteo, timeRemain: 0)
      Plant.electricalParasitics.solarField = parasitics(massFlow: solarField.header.massFlow)
    case .freezeProtection: // Freeze Protection (Pumping)
      outletTemperature(solarField: &solarField, meteo: meteo, timeRemain: 0)
      Plant.electricalParasitics.solarField = parameter.antiFreezeParastics // Account for parasitic heatFlow
    case .noOperation: // does not neccessary mean no operation, see:
      if solarField.header.temperature.outlet > HeatExchanger.parameter.temperature.htf.inlet.min,
        solarField.header.temperature.outlet > solarField.header.temperature.inlet {
        // AND NOT (Heater.solarField.OPmode = "OP" OR Boiler.solarField.OPmode = "OP") THEN
        // Force operation at massFlow.min: the last SF Tout > HeatExchanger.parameter.HTFinTmin: a fraction of
        // timeRemain can be produced now, even if the new SF Tout drops under Tminop.
        solarField.operationMode = .operating
        // CalcnearLoop
        outletTemperature(solarField: &solarField, meteo: meteo, timeRemain: 0)
        Plant.electricalParasitics.solarField = parasitics(massFlow: solarField.header.massFlow)
      } else { // NO operation: The heat losses in HCEs for the rest of IMet.period
        // were calculated. NOTE: dtime might be shorter than IMet.period, if
        // HTFinHCE.temperature.outlet  dropped beyond T(freeze prot.) during that period.
        outletTemperature(solarField: &solarField, meteo: meteo, timeRemain: 0)
        Plant.electricalParasitics.solarField =  0
      }
      
    default: // HCE returns with solarField.OPmode = unknown
      //  if solarField.htf.temperature.outlet > HeatExchanger.parameter.temperature.htf.inlet.min && Not (Heater.solarField.operationMode = "OP" || Boiler.solarField.operationMode = "OP") {
      if solarField.header.temperature.outlet > HeatExchanger.parameter.temperature.htf.inlet.min {
        // Boiler wurde hier rausgenommen, wegen nachrechenen von SEGS VI
        solarField.operationMode = .operating // Operation at minimum mass flow
        outletTemperature(solarField: &solarField, meteo: meteo, timeRemain: 0)
        Plant.electricalParasitics.solarField = parasitics(massFlow: solarField.massFlow)
      } else if Double(meteo.dni) > Simulation.parameter.minInsolationRaiseStartUp {
        //avgins > lastavgins + Simulation.parameter.minInsolationRaiseStartUp,
        // HTFinHCE.temperature.outlet > HTFinHCE.temperature.inlet + Simulation.parameter.minTemperatureRaiseStartUp {
        solarField.operationMode = .startUp
        outletTemperature(solarField: &solarField, meteo: meteo, timeRemain: 0)
        Plant.electricalParasitics.solarField = parasitics(massFlow: solarField.massFlow)
      } else { // Force No Operation: Calc. the heat losses in HCEs for the rest of IMet.period
        solarField.operationMode = .noOperation
        // CalcnearLoop
        // NOTE: dtime after next calculation might be shorter than oldTime,
        // if HTFinHCE,Tout drops beyond freeze protection Temp. during that period.
        outletTemperature(solarField: &solarField, meteo: meteo, timeRemain: 0)
        Plant.electricalParasitics.solarField = 0
      } // solarField.htf.temperature.outlet > HeatExchanger.parameter.HTFinTmin
    }
  }
}

