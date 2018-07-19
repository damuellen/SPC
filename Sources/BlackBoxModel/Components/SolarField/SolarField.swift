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
  public struct PerformanceData: Equatable, HeatCycle {
    var name = ""
    var operationMode: OperationMode
    var isMaintained: Bool
    var header: HeatFlow
    var insolationAbsorber: Double
    var ETA: Double
    var HL: Double
    var heatLossHeader: Double
    var heatLossHCE: Double
    var inFocus: Ratio
    var loops: [HeatFlow]
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
  }
 
  static let initialState = PerformanceData(
    name: "",
    operationMode: .scheduledMaintenance,
    isMaintained: false,
    header: HeatFlow(),
    insolationAbsorber: 0,
    ETA: 0,
    HL: 0,
    heatLossHeader: 0,
    heatLossHCE: 0,
    inFocus: 0.0,
    loops: Array(repeating: HeatFlow(), count: 4),
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
    let mode = status.solarField.operationMode.collector
    HCE.calculation(&status, loop: .design, mode: mode, meteo: meteo)

    for (n, loop) in zip(0..., [Loop.near, .average, .far]) {
      status.solarField.loops[loop.rawValue].massFlow =
        MassFlow(status.solarField.header.massFlow.rate
        * ((status.solarField.header.massFlow - parameter.massFlow.min).rate
          * (parameter.imbalanceDesign[n] - parameter.imbalanceMin[n])
          / (parameter.massFlow.max - parameter.massFlow.min).rate
          + parameter.imbalanceMin[n]))
      HCE.calculation(&status, loop: loop, mode: mode, meteo: meteo)
    }

    status.solarField.header.massFlow = MassFlow(status.solarField.loops
      .dropFirst().reduce(0) { sum, loop in sum + loop.massFlow.rate } / 3)
    
    if status.solarField.header.massFlow.isNearZero == false {

      let designFlowVelocity: Double = 2.7

      if timeRemain < parameter.loopWays[0] / (designFlowVelocity
        * status.solarField.header.massFlow.rate / parameter.massFlow.max.rate) {
        
        let timeRatio = timeRemain / (parameter.loopWays[0] / (designFlowVelocity
          * status.solarField.header.massFlow.rate / parameter.massFlow.max.rate))
        // Correct the loop outlet temperatures
        let oneMinusTR = 1 - timeRatio
        
        for n in status.solarField.loops.indices.dropFirst() {
          status.solarField.loops[n].temperature.outlet = Temperature(timeRatio
            * status.solarField.loops[n].temperature.outlet.kelvin
            + oneMinusTR * last[n].temperature.outlet.kelvin)
        }
      }
      
      let temps: [(Double, Double, Double)] =
        status.solarField.loops.indices.dropFirst().map { n in
        var timeRatio = timeRemain / (parameter.loopWays[n] / (designFlowVelocity
          * status.solarField.loops[n].massFlow.rate / parameter.massFlow.max.rate))
        let oneMinusTR: Double
        if timeRatio > 1 {
          timeRatio = 1
          oneMinusTR = 0
        } else {
          oneMinusTR = 1 - timeRatio
        }
        let temp = timeRatio * status.solarField.loops[n].temperature.outlet.kelvin
          + oneMinusTR * last[n].temperature.outlet.kelvin
        return (timeRatio, oneMinusTR, temp)
      }
      
      // check .last?.temperature.outlet  is too high 507K! therefore solarField.htf.temperature.outlet  is high too!
     
      status.solarField.header.temperature.outlet = Temperature(
        (temps[0].2 * status.solarField.loops[1].massFlow.rate
        + temps[1].2 * status.solarField.loops[2].massFlow.rate
        + temps[2].2 * status.solarField.loops[3].massFlow.rate)
        / (3 * status.solarField.header.massFlow.rate))
      
      status.powerBlock.temperature.inlet = status.solarField.header.temperature.outlet

      // PipeTemperature.PB = solarField.htf.temperature.outlet
      
      // farLoop.temperature.inlet = PipeTemperature.SF
      
      // PipeTemperature.SF = solarField.htf.temperature.inlet
      
      // Now calc. the linear inlet temperature gradient:
       let wayRatio = parameter.loopWays[2] / parameter.pipeWay

       status.solarField.loops[2].temperature.inlet = Temperature(celsius:
        status.solarField.loops[3].temperature.inlet.celsius + wayRatio
        * (status.solarField.temperature.inlet.celsius
          - status.solarField.loops[3].temperature.inlet.celsius))
      
       status.solarField.loops[1].temperature.inlet = Temperature(celsius:
        status.solarField.loops[3].temperature.inlet.celsius + 2 * wayRatio
        * (status.solarField.temperature.inlet.celsius
          - status.solarField.loops[3].temperature.inlet.celsius))
      
       status.solarField.loops[1].temperature.inlet = Temperature(
        temps[0].0 * status.solarField.temperature.inlet.kelvin
        + temps[0].1 * status.solarField.loops[1].temperature.inlet.kelvin)
      
       status.solarField.loops[2].temperature.inlet = Temperature(
        temps[1].0 * status.solarField.temperature.inlet.kelvin
        + temps[1].1 * status.solarField.loops[2].temperature.inlet.kelvin)
      
      status.solarField.loops[3].temperature.inlet = Temperature(
        temps[2].0 * status.solarField.temperature.inlet.kelvin
        + temps[2].1 * status.solarField.loops[3].temperature.inlet.kelvin)
      
    } else {
      status.solarField.loops.dropFirst().indices.forEach { n in
        status.solarField.loops[n].constantTemperature()
      }
    }
  }
  
  static func update(_ status: inout Plant.PerformanceData,
    demand: Ratio, timeRemain: Double, meteo: MeteoData) {

    if Design.hasStorage {
      switch status.storage.operationMode {
      case .freezeProtection:
        if storage.tempInCst[1] > 0 {
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
    
    status.solarField.header.massFlow = solarField.massFlow.max
    
    if demand.ratio < 1 { // added to reduced SOF massflow with electrical demand
      
      status.solarField.header.massFlow = MassFlow(demand.ratio
        * (steamTurbine.power.max
        / steamTurbine.efficiencyNominal
        / heatExchanger.efficiency)
        / (htf.heatDelta(
          heatExchanger.temperature.htf.inlet.max,
          heatExchanger.temperature.htf.outlet.max) / 1_000))
      
      status.solarField.header.massFlow = max(
        MassFlow(1500), status.solarField.header.massFlow + storage.massFlow)
    }
    
    if Design.hasStorage,
      status.storage.heatRelease >= storage.chargeTo {
      if Design.hasGasTurbine {
        status.solarField.header.massFlow = heatExchanger.SCCHTFmassFlow
      } else {
        // changed to reduced SOF massflow with electrical demand
        status.solarField.header.massFlow = MassFlow(demand.ratio
          * (steamTurbine.power.max
            / steamTurbine.efficiencyNominal
            / heatExchanger.efficiency)
          / (htf.heatDelta(
            heatExchanger.temperature.htf.inlet.max,
            heatExchanger.temperature.htf.outlet.max) / 1_000))
      }
    }
    
    SolarField.calculate(&status, meteo: meteo, timeRemain: timeRemain)
    
    // the next is added to determine temperature drop in hot header
    var temperatureNow = status.solarField.header.temperature.outlet
    var temperatureLast = temperatureNow
    let ambientTemperature = Temperature(celsius: meteo.temperature)
    for _ in 1 ... 10 {
      
      status.solarField.heatLossHeader *= solarField.heatLossHeader[0]
      //  + solarField.heatLossHeader
      // * (temperatureNow - ambientTemperature).kelvin // [MWt]
      status.solarField.heatLossHeader *= 1_000_000
        / (Design.layout.solarField * Double(solarField.numberOfSCAsInRow)
          * 2 * collector.areaSCAnet)
      // for hourly results and night cooldown [W/m2 ap.]
      let temp = temperatureLast
      temperatureLast = temperatureNow
      temperatureNow = temp
      
      if status.solarField.header.massFlow.rate > 0 {
        let dQHL = status.solarField.heatLossHeader * 1_000
          / status.solarField.header.massFlow.rate // [kJ/kg]
        temperatureNow = htf.temperatureDelta(-dQHL, status.solarField.header.temperature.outlet)
      } else {
        let averageTemperature = temperatureNow.median(
          status.solarField.header.temperature.outlet)
        // Calculate average Temp. and areaDensity
        let areaDensity = htf.density(averageTemperature) * .pi
          * collector.rabsInner ** 2 / collector.aperture // kg/m2
        let deltaHeatPerSqm = status.solarField.heatLossHeader  // FIXME * dtime / 1_000
        // Heat collected or lost during the flow through a whole loop [kJ/sqm]
        let deltaHeatPerKg = deltaHeatPerSqm / areaDensity // Change kJ/sqm to kJ/kg:
        let heatPerKg = htf.heatDelta(
          status.solarField.header.temperature.outlet, ambientTemperature)
        
        temperatureNow = htf.temperatureDelta(
          heatPerKg - deltaHeatPerKg, ambientTemperature)
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
      status.solarField.loops = status.solarField.loops.map { loop in
        var loop = loop
        loop.temperature.inlet = status.solarField.header.temperature.inlet
        return loop
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
      if status.solarField.header.temperature.outlet > heatExchanger.temperature.htf.inlet.min,
        status.solarField.header.temperature.outlet > status.solarField.header.temperature.inlet {
        // AND NOT (Heater.solarField.OPmode = "OP" OR Boiler.solarField.OPmode = "OP") THEN
        // Force operation at massFlow.min: the last SF Tout > heatExchanger.HTFinTmin: a fraction of
        // timeRemain can be produced now, even if the new SF Tout drops under Tminop.
        status.solarField.operationMode = .operating
        // CalcnearLoop
        outletTemperature(&status, meteo: meteo, timeRemain: timeRemain)
        Plant.electricalParasitics.solarField = parasitics(massFlow: status.solarField.header.massFlow)
      } else {
        // NO operation: The heat losses in HCEs for the rest of IMet.period
        // were calculated. NOTE: dtime might be shorter than IMet.period, if
        // HTFinHCE.temperature.outlet dropped beyond T(freeze prot.) during that period.
        outletTemperature(&status, meteo: meteo, timeRemain: timeRemain)
        Plant.electricalParasitics.solarField =  0
      }
      
    default: // HCE returns with solarField.OPmode = unknown
      //  if solarField.htf.temperature.outlet > heatExchanger.temperature.htf.inlet.min && Not (Heater.solarField.operationMode = "OP" || Boiler.solarField.operationMode = "OP") {
      if status.solarField.header.temperature.outlet > heatExchanger.temperature.htf.inlet.min {
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
      } // solarField.htf.temperature.outlet > heatExchanger.HTFinTmin
    }
  }
}

extension SolarField.PerformanceData: CustomStringConvertible {
  public var description: String {
    return "\(operationMode), "
      + "Maintenance: \(isMaintained ? "Yes" : "No"), "
      + "Header: \(header),\n"
      + String(format:"insolationAbsorber: %.1f, ", insolationAbsorber)
      + String(format:"ETA: %.1f, ", ETA)
      + String(format:"HL: %.1f, ", HL)
      + String(format:"HL Header: %.1f, ", heatLossHeader)
      + String(format:"HL HCE: %.1f, ", heatLossHCE)
      + "Focus: \(inFocus), "
      + String(format:"Loop Eta: %.1f, \n", loopEta)
      + "Loops: \(loops)"
  }
}
