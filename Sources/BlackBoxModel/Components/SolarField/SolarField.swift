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

public enum SolarField: Component {
  
  enum Loop: Int {
    case design = 0, near, average, far    
  }
  
  /// a struct for operation-relevant data of the steam turbine
  public struct PerformanceData: Equatable, HeatFlow {
    var operationMode: OperationMode
    var isMaintained: Bool
    var header: ThermalFlow
    var ITA: Double
    var ETA: Double
    var HL: Double
    var heatLossHeader: Double
    var heatLossHCE: Double
    var inFocus: Ratio
    var loops: [ThermalFlow]
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
        && lhs.loopEta == rhs.loopEta
    }
  }
  
  static let initialState = PerformanceData(
    operationMode: .scheduledMaintenance,
    isMaintained: false,
    header: ThermalFlow(),
    ITA: 0,
    ETA: 0,
    HL: 0,
    heatLossHeader: 0,
    heatLossHCE: 0,
    inFocus: 0.0,
    loops: Array(repeating: ThermalFlow(), count: 4),
    loopEta: 0
    )
  
  static var parameter: Parameter = ParameterDefaults.sf
  
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
    Plant.status.solarField.htf.massFlow = designLoop.now.massFlow
  }
   
  */
  /// Calc. loop-outlet temp. gradient / Near loop was already calculated.
  @inline(__always)
  static func outletTemperature(_ status: inout Plant.PerformanceData,
                                meteo: MeteoData, timeRemain: Double) {
	let last = status.solarField.loops
    
    HCE.calculation(&status, loop: .design, mode: status.solarField.operationMode.collector, meteo: meteo)

    for (n, loop) in zip(0..., [Loop.near, .average, .far]) {
      status.solarField.loops[loop.rawValue].massFlow =
        MassFlow(status.solarField.header.massFlow.rate
        * ((status.solarField.header.massFlow - parameter.massFlow.min).rate
          * (parameter.imbalanceDesign[n] - parameter.imbalanceMin[n])
          / (parameter.massFlow.max - parameter.massFlow.min).rate
          + parameter.imbalanceMin[n]))
      HCE.calculation(&status, loop: loop, mode: status.solarField.operationMode.collector, meteo: meteo)
    }

    status.solarField.header.massFlow = MassFlow(status.solarField.loops
      .dropFirst().reduce(0) { sum, loop in sum + loop.massFlow.rate } / 3)
    
    if !status.solarField.header.massFlow.isNearZero {
      var OneMinusTR: Double = 0

      let designFlowVelocity: Double = 2.7

      if timeRemain < parameter.loopWays[0] / (designFlowVelocity
        * status.solarField.header.massFlow.rate / parameter.massFlow.max.rate) {
        
        let timeRatio = timeRemain / (parameter.loopWays[0] / (designFlowVelocity
          * status.solarField.header.massFlow.rate / parameter.massFlow.max.rate))
        // Correct the loop outlet temperatures
        OneMinusTR = 1 - timeRatio
        
        for n in status.solarField.loops.indices.dropFirst() {
          status.solarField.loops[n].temperature.outlet = Temperature(timeRatio
            * status.solarField.loops[n].temperature.outlet.kelvin
            + OneMinusTR * last[n].temperature.outlet.kelvin)
        }
      } // - IF timeRemain < dtime -
      
      let temps: [Double] = status.solarField.loops.indices.dropFirst().map { n in
        var timeRatio = timeRemain / (parameter.loopWays[n] / (designFlowVelocity
          * status.solarField.loops[n].massFlow.rate / parameter.massFlow.max.rate))
        
        if timeRatio > 1 {
          timeRatio = 1
          OneMinusTR = 0
        } else {
          OneMinusTR = 1 - timeRatio
        }
        return timeRatio * status.solarField.loops[n].temperature.outlet.kelvin
          + OneMinusTR * last[n].temperature.outlet.kelvin
      }
      
      // check .last?.temperature.outlet  is too high 507K! therefore solarField.htf.temperature.outlet  is high too!
     
      status.solarField.header.temperature.outlet = Temperature(
        (temps[0] * status.solarField.loops[1].massFlow.rate
        + temps[1] * status.solarField.loops[2].massFlow.rate
        + temps[2] * status.solarField.loops[3].massFlow.rate)
        / (3 * status.solarField.header.massFlow.rate))
      // check, example 504 K
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
  
  static func update(_ status: inout Plant.PerformanceData,
    demand: Ratio, timeRemain: Double, meteo: MeteoData) {

    if Design.hasStorage {
      switch status.storage.operationMode {
      case .freezeProtection:
        if Storage.parameter.tempInCst[1] > 0 {
          status.solarField.header.temperature.inlet = status.solarField.header.temperature.outlet
        } else {
          status.solarField.header.temperature.inlet = Temperature(status.storage.StoTcoldTout)
        }
      case .sc:
        status.solarField.header.temperature.inlet = status.storage.temperatureTanks.cold
      case .charging where Plant.thermal.production == 0:
        status.solarField.header.temperature.inlet = status.solarField.header.temperature.outlet
      default:
        status.solarField.header.temperature.inlet = status.powerBlock.temperature.outlet
      }
    } else {
      status.solarField.header.temperature.inlet = status.powerBlock.temperature.outlet
    }
    
    Plant.thermal.dump = 0
    
    status.solarField.header.massFlow = SolarField.parameter.massFlow.max
    
    if demand.ratio < 1 { // added to reduced SOF massflow with electrical demand
      
      status.solarField.header.massFlow = MassFlow(demand.ratio
        * (SteamTurbine.parameter.power.max
        / SteamTurbine.parameter.efficiencyNominal
        / HeatExchanger.parameter.efficiency)
        / (htf.heatDelta(
          HeatExchanger.parameter.temperature.htf.inlet.max,
          HeatExchanger.parameter.temperature.htf.outlet.max) / 1_000))
      
      status.solarField.header.massFlow = max(
        MassFlow(1500), status.solarField.header.massFlow + Storage.parameter.massFlow)
    }
    
    if Design.hasStorage,
      status.storage.heatrel >= Storage.parameter.chargeTo {
      if Design.hasGasTurbine {
        status.solarField.header.massFlow = HeatExchanger.parameter.SCCHTFmassFlow
      } else {
        // changed to reduced SOF massflow with electrical demand
        status.solarField.header.massFlow = MassFlow(demand.ratio
          * (SteamTurbine.parameter.power.max
            / SteamTurbine.parameter.efficiencyNominal
            / HeatExchanger.parameter.efficiency)
          / (htf.heatDelta(
            HeatExchanger.parameter.temperature.htf.inlet.max,
            HeatExchanger.parameter.temperature.htf.outlet.max) / 1_000))
      }
    }
    
    SolarField.calculate(&status, meteo: meteo, timeRemain: timeRemain)
    
    // the next is added to determine temperature drop in hot header
    var temperatureNow = status.solarField.header.temperature.outlet
    var temperatureLast = temperatureNow
    //let ambientTemperature = Temperature(celsius: meteo.temperature)
    for _ in 1 ... 10 {
      
      status.solarField.heatLossHeader *= SolarField.parameter.heatLossHeader[0]
      //  + SolarField.parameter.heatLossHeader
      // * (temperatureNow - ambientTemperature).kelvin // [MWt]
      status.solarField.heatLossHeader *= 1_000_000
        / (Design.layout.solarField * Double(SolarField.parameter.numberOfSCAsInRow)
          * 2 * Collector.parameter.areaSCAnet)
      // for hourly results and night cooldown [W/m2 ap.]
      let temp = temperatureLast
      temperatureLast = temperatureNow
      temperatureNow = temp
      
      if status.solarField.header.massFlow.rate > 0 {
        let dQHL = status.solarField.heatLossHeader * 1_000 / status.solarField.header.massFlow.rate // [kJ/kg]
        temperatureNow = htf.temperatureDelta(-dQHL, status.solarField.header.temperature.outlet)
      } else {
        let averageTemperature = Temperature(
          (temperatureNow + status.solarField.header.temperature.outlet).kelvin / 2)
        // Calculate average Temp. and Areadens
        let areadens = htf.density(averageTemperature) * .pi
          * Collector.parameter.rabsInner ** 2 / Collector.parameter.aperture // kg/m2
        let dQperSqm = status.solarField.heatLossHeader  // FIXME * dtime / 1_000
        // Heat collected or lost during the flow through a whole loop [kJ/sqm]
        let dQperkg = dQperSqm / areadens // Change kJ/sqm to kJ/kg:
        let Qperkg = htf.heatDelta(
          status.solarField.header.temperature.outlet, Temperature(celsius: meteo.temperature))
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
    status.solarField.header.temperature.outlet = temperatureNow
  }
  
  static func calculate(_ status: inout Plant.PerformanceData,
                        meteo: MeteoData, timeRemain: Double) {
    
    if status.solarField.isMaintained {
      Plant.electricalParasitics.solarField = 0
      if case .scheduledMaintenance = status.solarField.operationMode { return }
      // First Day of Maintenance
      status.solarField = SolarField.initialState
      return
    }
    
    if case .freezeProtection = status.solarField.operationMode {
      status.solarField.loops = status.solarField.loops.map { status in
        var status = status
        //status.temperature.inlet = status.solarField.header.temperature.inlet
        return status
      }
    }
    
    status.solarField.operationMode = .unknown
    HCE.calculation(&status, loop: .design, mode: .variable, meteo: meteo)

    switch status.solarField.operationMode { // Check HCE and decide what to do
    case .operating:
      outletTemperature(&status, meteo: meteo, timeRemain: timeRemain)
      Plant.electricalParasitics.solarField = parasitics(massFlow: status.solarField.header.massFlow)
    case .freezeProtection:
      outletTemperature(&status, meteo: meteo, timeRemain: timeRemain)
      Plant.electricalParasitics.solarField = parameter.antiFreezeParastics
    case .noOperation: // does not neccessary mean no operation, see:
      if status.solarField.header.temperature.outlet > HeatExchanger.parameter.temperature.htf.inlet.min,
        status.solarField.header.temperature.outlet > status.solarField.header.temperature.inlet {
        // AND NOT (Heater.solarField.OPmode = "OP" OR Boiler.solarField.OPmode = "OP") THEN
        // Force operation at massFlow.min: the last SF Tout > HeatExchanger.parameter.HTFinTmin: a fraction of
        // timeRemain can be produced now, even if the new SF Tout drops under Tminop.
        status.solarField.operationMode = .operating
        // CalcnearLoop
        outletTemperature(&status, meteo: meteo, timeRemain: timeRemain)
        Plant.electricalParasitics.solarField = parasitics(massFlow: status.solarField.header.massFlow)
      } else { // NO operation: The heat losses in HCEs for the rest of IMet.period
        // were calculated. NOTE: dtime might be shorter than IMet.period, if
        // HTFinHCE.temperature.outlet  dropped beyond T(freeze prot.) during that period.
        outletTemperature(&status, meteo: meteo, timeRemain: timeRemain)
        Plant.electricalParasitics.solarField =  0
      }
      
    default: // HCE returns with solarField.OPmode = unknown
      //  if solarField.htf.temperature.outlet > HeatExchanger.parameter.temperature.htf.inlet.min && Not (Heater.solarField.operationMode = "OP" || Boiler.solarField.operationMode = "OP") {
      if status.solarField.header.temperature.outlet > HeatExchanger.parameter.temperature.htf.inlet.min {
        // Boiler wurde hier rausgenommen, wegen nachrechenen von SEGS VI
        status.solarField.operationMode = .operating // Operation at minimum mass flow
        outletTemperature(&status, meteo: meteo, timeRemain: timeRemain)
        Plant.electricalParasitics.solarField = parasitics(massFlow: status.solarField.header.massFlow)
      } else if Double(meteo.dni) > Simulation.parameter.minInsolationRaiseStartUp {
        //avgins > lastavgins + Simulation.parameter.minInsolationRaiseStartUp,
        // HTFinHCE.temperature.outlet > HTFinHCE.temperature.inlet + Simulation.parameter.minTemperatureRaiseStartUp {
        status.solarField.operationMode = .startUp
        outletTemperature(&status, meteo: meteo, timeRemain: timeRemain)
        Plant.electricalParasitics.solarField = parasitics(massFlow: status.solarField.header.massFlow)
      } else { // Force No Operation: Calc. the heat losses in HCEs for the rest of IMet.period
        status.solarField.operationMode = .noOperation
        // CalcnearLoop
        // NOTE: dtime after next calculation might be shorter than oldTime,
        // if HTFinHCE,Tout drops beyond freeze protection Temp. during that period.
        outletTemperature(&status, meteo: meteo, timeRemain: timeRemain)
        Plant.electricalParasitics.solarField = 0
      } // solarField.htf.temperature.outlet > HeatExchanger.parameter.HTFinTmin
    }
  }
}

extension SolarField.PerformanceData: CustomStringConvertible {
  public var description: String {
    return "\(operationMode), "
      + "Maintenance: \(isMaintained ? "Yes" : "No"), "
      + "Header: \(header), "
      + String(format:"ITA: %.1f, ", ITA)
      + String(format:"ETA: %.1f, ", ETA)
      + String(format:"HL: %.1f, ", HL)
      + String(format:"HL Header: %.1f, ", heatLossHeader)
      + String(format:"HL HCE: %.1f, ", heatLossHCE)
      + "Focus: \(inFocus), "
      + String(format:"Loop Eta: %.1f, ", loopEta)
      + "\nLoops: \(loops)"
  }
}
