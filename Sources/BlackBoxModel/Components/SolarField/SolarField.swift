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

public enum SolarField: Component {
  static var temperatureLast = Temperature()

  enum Loop: Int {
    case design = 0, near, average, far

    static var names: [String] {
      return ["Design", "Near", "Average", "Far"]
    }
  }

  /// Contains all data needed to simulate the operation of the solar field
  public struct PerformanceData: Equatable, HeatCycle {
    var operationMode: OperationMode
    var isMaintained: Bool
    var header: HeatFlow
    var insolationAbsorber: Double
    var ETA: Double
    var heatLosses: Double
    var heatLossHeader: Double
    var heatLossHCE: Double
    var inFocus: Ratio
    var loops: [HeatFlow]
    var loopEta: Double
    var massFlow: MassFlow { return self.header.massFlow }

    var temperature: (inlet: Temperature, outlet: Temperature) {
      return self.header.temperature
    }

    public enum OperationMode: String, CustomStringConvertible {
      case startUp, freezeProtection, operating,
        noOperation, scheduledMaintenance, unknown, ph, fixed, normal

      public var description: String {
        return rawValue
      }

      var isFreezeProtection: Bool {
        return self ~= .freezeProtection
      }
    }
  }

  static let initialState = PerformanceData(
    operationMode: .scheduledMaintenance,
    isMaintained: false,
    header: HeatFlow(name: "Header"),
    insolationAbsorber: 0,
    ETA: 0,
    heatLosses: 0,
    heatLossHeader: 0,
    heatLossHCE: 0,
    inFocus: 0.0,
    loops: Loop.names.map { name in
      HeatFlow(loop: name) },
    loopEta: 0
  )

  public static var parameter: Parameter = ParameterDefaults.sf
  static var last: [HeatFlow] = initialState.loops

  /// Calculates the parasitics
  private static func parasitics(massFlow: MassFlow) -> Double {
    let load = massFlow.share(of: parameter.massFlow.max).ratio
    return parameter.pumpParasticsFullLoad
      * (parameter.pumpParastics[0] + parameter.pumpParastics[1]
        * load + parameter.pumpParastics[2] * load ** 2)
  }

  public static func pipeHeatLoss(
    average temperature: Temperature, ambient: Temperature
  ) -> Double {
    return ((temperature - ambient).kelvin / 333) ** 1 * parameter.pipeHeatLosses
  }

  /*
   fileprivate static func calculateNear(
   _ designLoop: inout (now: SolarField.HTFstatus, last: SolarField.HTFstatus),
   _ nearLoop: (now: SolarField.HTFstatus, last: SolarField.HTFstatus)) {
   // Exit Sub

   // CalcnearLoop:

   while true {
   designLoop.now.temperature.inlet = nearLoop.last.temperature.inlet // - Collect solar -
   HCE(solarField.operationMode, designLoop, time, designLoop.last?)
   if designLoop.now.massFlow.isZero {
   timeRemain = dtime // normally IMet.period, but not always in FP mode.
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
    HCE.freezeProtectionCheck(of: &status.solarField)

    for (n, loop) in zip(0..., [Loop.near, .average, .far]) {
      status.solarField.loops[loop.rawValue].massFlow = MassFlow(
        status.solarField.header.massFlow.rate
          * ((status.solarField.header.massFlow - parameter.massFlow.min).rate
            * (parameter.imbalanceDesign[n] - parameter.imbalanceMin[n])
            / (parameter.massFlow.max - parameter.massFlow.min).rate
            + parameter.imbalanceMin[n]))

      HCE.calculation(solarField: &status.solarField,
                      collector: status.collector,
                      loop: loop, mode: .variable, meteo: meteo)
    }

    status.solarField.header.massFlow = MassFlow(status.solarField.loops
      .dropFirst().reduce(0) { sum, loop in sum + loop.massFlow.rate } / 3)

    if status.solarField.header.massFlow.isNearZero == false {
      let designFlowVelocity: Double = 2.7

      if timeRemain < parameter.loopWays[0] / (designFlowVelocity
        * status.solarField.header.massFlow.rate / parameter.massFlow.max.rate)
      {
        let timeRatio = timeRemain / (parameter.loopWays[0]
          / (designFlowVelocity * status.solarField.header.massFlow.rate
            / parameter.massFlow.max.rate))
        // Correct the loop outlet temperatures
        let oneMinusTR = 1 - timeRatio

        for n in status.solarField.loops.indices.dropFirst() {
          status.solarField.loops[n].temperature.outlet = Temperature(
            timeRatio * status.solarField.loops[n].outletTemperature
            + oneMinusTR * last[n].outletTemperature)
        }
      }

      let temps: [(Double, Double, Double)] =
        status.solarField.loops.indices.dropFirst().map { n in
          var timeRatio = timeRemain / (parameter.loopWays[n]
            / (designFlowVelocity * status.solarField.loops[n].massFlow.rate
              / parameter.massFlow.max.rate))
          
          let oneMinusTR: Double

          if timeRatio > 1 {
            timeRatio = 1
            oneMinusTR = 0
          } else {
            oneMinusTR = 1 - timeRatio
          }

          let temp = timeRatio * status.solarField.loops[n].outletTemperature
            + oneMinusTR * last[n].outletTemperature

          return (timeRatio, oneMinusTR, temp)
        }

      // check .last?.temperature.outlet  is too high 507K! therefore solarField.htf.temperature.outlet  is high too!

      status.solarField.header.temperature.outlet = Temperature(
        (temps[0].2 * status.solarField.loops[1].massFlow.rate
          + temps[1].2 * status.solarField.loops[2].massFlow.rate
          + temps[2].2 * status.solarField.loops[3].massFlow.rate)
          / (3 * status.solarField.header.massFlow.rate)
      )

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
        temps[0].0 * status.solarField.inletTemperature
          + temps[0].1 * status.solarField.loops[1].inletTemperature
      )

      status.solarField.loops[2].temperature.inlet = Temperature(
        temps[1].0 * status.solarField.inletTemperature
          + temps[1].1 * status.solarField.loops[2].inletTemperature
      )

      status.solarField.loops[3].temperature.inlet = Temperature(
        temps[2].0 * status.solarField.inletTemperature
          + temps[2].1 * status.solarField.loops[3].inletTemperature
      )
    } else {
      status.solarField.loops.dropFirst().indices.forEach { n in
        status.solarField.loops[n].constantTemperature()
      }
    }
    last = status.solarField.loops
  }
  /// - Returns: electricalParasitics
  static func update(_ status: inout Plant.PerformanceData,
                     timeRemain: Double, meteo: MeteoData) -> Double {
    let heatExchanger = HeatExchanger.parameter
    let steamTurbine = SteamTurbine.parameter
    let storage = Storage.parameter
    let collector = Collector.parameter

    status.solarField.header.temperature.inlet =
      status.powerBlock.temperature.outlet

    if Design.hasStorage {
      switch status.storage.operationMode {
      case .freezeProtection:
        if storage.temperatureCharge[1] > 0 {
          status.solarField.header.temperature.inlet =
            status.solarField.header.temperature.outlet
        } else {
          status.solarField.header.temperature.inlet =
            Temperature(status.storage.tempertureColdOut)
        }
    //  case .sc:
        status.solarField.header.temperature.inlet =
          status.storage.temperatureTanks.cold
      case .charging where Plant.thermal.production == 0:
        status.solarField.header.temperature.inlet =
          status.solarField.header.temperature.outlet
      default: break
      }
    }

    status.solarField.header.massFlow.rate = 0 // solarField.massFlow.max

    if Plant.demand.ratio < 1 { // added to reduced SOF massflow with electrical demand
      status.solarField.header.massFlow = MassFlow(Plant.demand.ratio
        * (steamTurbine.power.max / steamTurbine.efficiencyNominal
          / heatExchanger.efficiency) / (htf.heatDelta(
            heatExchanger.temperature.htf.inlet.max,
            heatExchanger.temperature.htf.outlet.max) / 1_000))

      status.solarField.header.massFlow = min(
        MassFlow(600), status.solarField.header.massFlow + storage.massFlow
      )
    }

    if Design.hasStorage, status.storage.heatRelease >= storage.chargeTo {
      if Design.hasGasTurbine {
        status.solarField.header.massFlow = heatExchanger.sccHTFmassFlow
      } else {
        // changed to reduced SOF massflow with electrical demand
        status.solarField.header.massFlow = MassFlow(Plant.demand.ratio
          * (steamTurbine.power.max
            / steamTurbine.efficiencyNominal
            / heatExchanger.efficiency)
          / (htf.heatDelta(
            heatExchanger.temperature.htf.inlet.max,
            heatExchanger.temperature.htf.outlet.max) / 1_000))
      }
    }

    let electricalParasitics = SolarField.calculate(
      &status, meteo: meteo, timeRemain: timeRemain
    )

    // the next is added to determine temperature drop in hot header
    var temperatureNow = status.solarField.header.temperature.outlet
    var temperatureLast = temperatureNow
    let ambientTemperature = Temperature(celsius: meteo.temperature)
    
    repeat {
      status.solarField.heatLossHeader *= parameter.heatLossHeader[0]
      //  + solarField.heatLossHeader
      // * (temperatureNow - ambientTemperature).kelvin // [MWt]
      status.solarField.heatLossHeader *= 1_000_000
        / (Design.layout.solarField * Double(parameter.numberOfSCAsInRow)
          * 2 * collector.areaSCAnet)
      // for hourly results and night cooldown [W/m2 ap.]
      let temperatureSwap = temperatureLast
      temperatureLast = temperatureNow
      temperatureNow = temperatureSwap

      status.solarField.heatLossHeader = 0.02

      if status.solarField.header.massFlow.rate > 0 {
        let dQHL = status.solarField.heatLossHeader * 1_000
          / status.solarField.header.massFlow.rate // [kJ/kg]
        temperatureNow = htf.temperatureDelta(-dQHL, status.solarField.header.temperature.outlet)
      } else {
        let averageTemperature = Temperature.average(
          temperatureNow, status.solarField.header.temperature.outlet
        )
        // Calculate average Temp. and areaDensity
        let areaDensity = htf.density(averageTemperature) * .pi
          * collector.rabsInner ** 2 / collector.aperture // kg/m2

        let deltaHeatPerSqm = status.solarField.heatLossHeader // FIXME: * dtime / 1_000
        // Heat collected or lost during the flow through a whole loop [kJ/sqm]
        let deltaHeatPerKg = deltaHeatPerSqm / areaDensity // Change kJ/sqm to kJ/kg:

        let heatPerKg = htf.heatDelta(
          status.solarField.header.temperature.outlet, ambientTemperature
        )
        temperatureNow = htf.temperatureDelta(
          heatPerKg - deltaHeatPerKg, ambientTemperature
        )
      }
      temperatureNow = min(htf.maxTemperature, temperatureNow)
    } while abs(temperatureNow.kelvin - temperatureLast.kelvin)
      > Simulation.parameter.HLtempTolerance

    status.solarField.header.temperature.outlet = temperatureNow
    return electricalParasitics
  }
  /// - Returns: electricalParasitics
  static func calculate(_ status: inout Plant.PerformanceData,
                        meteo: MeteoData, timeRemain: Double) -> Double {
    let heatExchanger = HeatExchanger.parameter
    if status.solarField.isMaintained {
      if case .scheduledMaintenance = status.solarField.operationMode {
        return 0
      }
      // First Day of Maintenance
      status.solarField = SolarField.initialState
      return 0
    }

    if case .freezeProtection = status.solarField.operationMode {
      status.solarField.loops = status.solarField.loops.map { loop in
        var loop = loop
        loop.temperature.inlet = status.solarField.header.temperature.inlet
        return loop
      }
    }

    status.solarField.operationMode = .unknown
    #warning("The implementation here differs from PCT")
    status.solarField.loops[0].massFlow = status.solarField.header.massFlow
    status.solarField.loops[0].temperature.inlet = status.solarField.loops[1].temperature.inlet

    HCE.calculation(solarField: &status.solarField, collector: status.collector,
                    loop: .design, mode: status.solarField.operationMode.collector, meteo: meteo)

    status.solarField.header.massFlow = status.solarField.loops[0].massFlow
    status.solarField.header.temperature.outlet = status.solarField.loops[0].temperature.outlet
    defer { status.powerBlock.temperature.inlet = status.solarField.header.temperature.outlet }
    if status.solarField.loops[0].massFlow.isNearZero {
      status.solarField.loops[0].constantTemperature()
    }

    switch status.solarField.operationMode { // Check HCE and decide what to do
    case .operating:
      SolarField.outletTemperature(&status, meteo: meteo, timeRemain: timeRemain)
      return parasitics(massFlow: status.solarField.header.massFlow)
    case .freezeProtection:
      SolarField.outletTemperature(&status, meteo: meteo, timeRemain: timeRemain)
      return parameter.antiFreezeParastics
    case .noOperation: // does not neccessary mean no operation, see:
      if status.solarField.header.temperature.outlet
        > max(heatExchanger.temperature.htf.inlet.min,
              status.solarField.header.temperature.inlet)
      {
        // AND NOT (Heater.solarField.OPmode = "OP" OR Boiler.solarField.OPmode = "OP") THEN
        // Force operation at massFlow.min: the last SF Tout > heatExchanger.HTFinTmin: a fraction of
        // timeRemain can be produced now, even if the new SF Tout drops under Tminop.
        status.solarField.operationMode = .operating
        // CalcnearLoop
        SolarField.outletTemperature(&status, meteo: meteo, timeRemain: timeRemain)
        return parasitics(massFlow: status.solarField.header.massFlow)
      } else {
        // NO operation: The heat losses in HCEs for the rest of IMet.period
        // were calculated. NOTE: dtime might be shorter than IMet.period, if
        // HTFinHCE.temperature.outlet dropped beyond T(freeze prot.) during that period.
        SolarField.outletTemperature(&status, meteo: meteo, timeRemain: timeRemain)
      }

    default: // HCE returns with solarField.OPmode = unknown
      //  if solarField.htf.temperature.outlet > heatExchanger.temperature.htf.inlet.min && Not (Heater.solarField.operationMode = "OP" || Boiler.solarField.operationMode = "OP") {
      if status.solarField.header.temperature.outlet
        > heatExchanger.temperature.htf.inlet.min
      {
        // Boiler wurde hier rausgenommen, wegen nachrechenen von SEGS VI
        status.solarField.operationMode = .operating // Operation at minimum mass flow
        SolarField.outletTemperature(&status, meteo: meteo, timeRemain: timeRemain)
        
        return parasitics(massFlow: status.solarField.header.massFlow)
      } else if Double(meteo.dni)
        > self.lastDNI + Simulation.parameter.minInsolationRaiseStartUp,
        status.solarField.header.temperature.outlet
          > status.solarField.header.temperature.inlet
          + Simulation.parameter.minTemperatureRaiseStartUp
      {
        self.lastDNI = Double(meteo.dni)
        status.solarField.operationMode = .startUp
        SolarField.outletTemperature(&status, meteo: meteo, timeRemain: timeRemain)

        return parasitics(massFlow: status.solarField.header.massFlow)
      } else { // Force No Operation: Calc. the heat losses in HCEs for the rest of IMet.period
        status.solarField.operationMode = .noOperation
        // CalcnearLoop
        // NOTE: dtime after next calculation might be shorter than oldTime,
        // if HTFinHCE,Tout drops beyond freeze protection Temp. during that period.
        SolarField.outletTemperature(&status, meteo: meteo, timeRemain: timeRemain)
      } // solarField.htf.temperature.outlet > heatExchanger.HTFinTmin
    }

    return 0
  }

  static var lastDNI = 0.0
}

extension SolarField.PerformanceData: CustomStringConvertible {
  public var description: String {
    return "\(operationMode), "
      + "Maintenance: \(isMaintained ? "Yes" : "No"), "
      + "Header: \(header),\n"
      + String(format: "insolationAbsorber: %.1f, ", insolationAbsorber)
      + String(format: "ETA: %.1f, ", ETA)
      + String(format: "HL: %.1f, ", heatLosses)
      + String(format: "HL Header: %.1f, ", heatLossHeader)
      + String(format: "HL HCE: %.1f, ", heatLossHCE)
      + "Focus: \(inFocus), "
      + String(format: "Loop Eta: %.1f, \n", loopEta)
      + "Loops: \(loops)"
  }
}
