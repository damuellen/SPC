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
    public var inFocus: Ratio
    var loops: [HeatFlow]
    var loopEta: Double
    var area: Double
    
    public var massFlow: MassFlow {
      get { return self.header.massFlow }
      set { self.header.massFlow = newValue }
    }

    public var temperature: (inlet: Temperature, outlet: Temperature) {
      get { return self.header.temperature }
      set { self.header.temperature = newValue }
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
    insolationAbsorber: 0, ETA: 0,
    heatLosses: 0, heatLossHeader: 0, heatLossHCE: 0,
    inFocus: 0.0,
    loops: Loop.names.map { name in HeatFlow(loop: name) },
    loopEta: 0,
    area: {
      return Design.layout.solarField
        * Double(SolarField.parameter.numberOfSCAsInRow)
        * 2 * Collector.parameter.areaSCAnet }()
  )

  public static var parameter: Parameter = ParameterDefaults.sf
  static var last: [HeatFlow] = initialState.loops

  /// Calculates the parasitics
  static func parasitics(_ status: PerformanceData) -> Double {
    if status.operationMode == .freezeProtection {
      return parameter.antiFreezeParastics
    }
    let load = status.massFlow.share(of: parameter.massFlow.max).ratio
    return status.massFlow.rate > 0
      ? parameter.pumpParasticsFullLoad
        * (parameter.pumpParastics[0] + parameter.pumpParastics[1]
          * load + parameter.pumpParastics[2] * load ** 2)
      : 0
  }

  static func pipeHeatLoss(
    pipe temperature: Temperature, ambient: Temperature) -> Double {
    return ((temperature - ambient).kelvin / 333) ** 1 * parameter.pipeHeatLosses
  }

  /// Calc. loop-outlet temp. gradient / Near loop was already calculated.
  private static func outletTemperature(
    _ solarField: inout SolarField.PerformanceData,
    _ collector: Collector.PerformanceData,
    meteo: MeteoData, timeRemain: Double)
  {
    HCE.freezeProtectionCheck(&solarField)
    last = solarField.loops
    for (n, loop) in zip(0..., [Loop.near, .average, .far]) {
      solarField.loops[loop.rawValue].massFlow(rate:
        solarField.header.massFlow.rate
          * ((solarField.header.massFlow - parameter.massFlow.min).rate
            * (parameter.imbalanceDesign[n] - parameter.imbalanceMin[n])
            / (parameter.massFlow.max - parameter.massFlow.min).rate
            + parameter.imbalanceMin[n]))

      HCE.calculation(&solarField, collector: collector, loop: loop,
                      mode: .variable, meteo: meteo)
    }

    solarField.header.massFlow(rate:
      solarField.loops.dropFirst().reduce(0) { sum, loop in
        sum + loop.massFlow.rate } / 3
    )

    if solarField.header.massFlow.isNearZero {
      solarField.loops.dropFirst().indices.forEach { n in
        solarField.loops[n].constantTemperature()
      }
    } else {
      let designFlowVelocity: Double = 2.7

      if timeRemain < parameter.loopWays[0] / (designFlowVelocity
        * solarField.header.massFlow.rate / parameter.massFlow.max.rate)
      {
        let timeRatio = timeRemain / (parameter.loopWays[0]
          / (designFlowVelocity * solarField.header.massFlow.rate
            / parameter.massFlow.max.rate))
        // Correct the loop outlet temperatures
        let oneMinusTR = 1 - timeRatio

        for n in solarField.loops.indices.dropFirst() {
          solarField.loops[n].outletTemperature(kelvin:
            timeRatio * solarField.loops[n].outletTemperature
            + oneMinusTR * last[n].outletTemperature)
        }
      }

      let temps: [(Double, Double, Double)] =
        solarField.loops.indices.dropFirst().map { n in
          var timeRatio = timeRemain / (parameter.loopWays[n]
            / (designFlowVelocity * solarField.loops[n].massFlow.rate
              / parameter.massFlow.max.rate))
          
          let oneMinusTR: Double

          if timeRatio > 1 {
            timeRatio = 1
            oneMinusTR = 0
          } else {
            oneMinusTR = 1 - timeRatio
          }

          let temp = timeRatio * solarField.loops[n].outletTemperature
            + oneMinusTR * last[n].outletTemperature

          return (timeRatio, oneMinusTR, temp)
        }

      solarField.header.outletTemperature(kelvin:
        (temps[0].2 * solarField.loops[1].massFlow.rate
          + temps[1].2 * solarField.loops[2].massFlow.rate
          + temps[2].2 * solarField.loops[3].massFlow.rate)
          / (3 * solarField.header.massFlow.rate)
      )

      // Now calc. the linear inlet temperature gradient:
      let wayRatio = parameter.loopWays[2] / parameter.pipeWay

      solarField.loops[2].temperature.inlet = Temperature(celsius:
        solarField.loops[3].temperature.inlet.celsius + wayRatio
          * (solarField.temperature.inlet.celsius
            - solarField.loops[3].temperature.inlet.celsius))

      solarField.loops[1].temperature.inlet = Temperature(celsius:
        solarField.loops[3].temperature.inlet.celsius + 2 * wayRatio
          * (solarField.temperature.inlet.celsius
            - solarField.loops[3].temperature.inlet.celsius))

      solarField.loops[1].temperature.inlet = Temperature(
        temps[0].0 * solarField.inletTemperature
          + temps[0].1 * solarField.loops[1].inletTemperature
      )

      solarField.loops[2].temperature.inlet = Temperature(
        temps[1].0 * solarField.inletTemperature
          + temps[1].1 * solarField.loops[2].inletTemperature
      )

      solarField.loops[3].temperature.inlet = Temperature(
        temps[2].0 * solarField.inletTemperature
          + temps[2].1 * solarField.loops[3].inletTemperature
      )
    }
  }

  private static func heatLossesHotHeader(
    _ solarField: inout SolarField.PerformanceData, _ meteo: MeteoData) {
    var newTemp = solarField.header.temperature.outlet
    defer { solarField.header.temperature.outlet = newTemp }
    var oldTemp = newTemp
    let ambientTemperature = Temperature(celsius: meteo.temperature)

    repeat {      
      swap(&newTemp, &oldTemp)
      
      solarField.heatLossHeader = parameter.heatLossHeader[0]
        * (parameter.heatLossHeader[1] + parameter.heatLossHeader[2]
          * (newTemp - ambientTemperature).kelvin) // [MWt]
      
      if solarField.header.massFlow.rate > 0 {
        let deltaHeatPerKg = solarField.heatLossHeader * 1_000
          / solarField.header.massFlow.rate // [kJ/kg]
        newTemp = parameter.HTF.temperature(
          -deltaHeatPerKg, solarField.header.temperature.outlet
        )
      } else {
        let averageTemperature = Temperature.average(
          newTemp, solarField.header.temperature.outlet
        )
        /// Calculate average Temp. and areaDensity
        let collector = Collector.parameter
        let areaDensity = parameter.HTF.density(averageTemperature) * .pi
          * collector.rabsInner ** 2 / collector.aperture // kg/m2

        /// Heat collected or lost during the flow through a whole loop [kJ/sqm]
        let deltaHeatPerSqm = solarField.heatLossHeader * 1_000_000 // [MW]
          / solarField.area * 300 / 1_000
        /// Change kJ/sqm to kJ/kg:
        let deltaHeatPerKg = deltaHeatPerSqm / areaDensity
        
        let heatPerKg = parameter.HTF.deltaHeat(
          solarField.header.temperature.outlet, ambientTemperature
        )
        newTemp = parameter.HTF.temperature(
          heatPerKg - deltaHeatPerKg, ambientTemperature
        )
      }
      newTemp = newTemp.limited(by: parameter.HTF.maxTemperature)
    } while abs(newTemp.kelvin - oldTemp.kelvin)
      > Simulation.parameter.HLtempTolerance
  }
  
  static func update(
    _ status: Plant.PerformanceData,
    timeRemain: inout Double,
    dumping: inout Double,
    meteo: MeteoData
    ) -> PerformanceData
  {
    let heatExchanger = HeatExchanger.parameter,
    steamTurbine = SteamTurbine.parameter
    
    let storage = status.storage
    
    var solarField = status.solarField
    
    solarField.insolationAbsorber = Double(meteo.dni)
      * status.collector.cosTheta
      * status.collector.efficiency
    
    solarField.header.temperature.inlet =
      status.powerBlock.temperature.outlet

    if Design.hasStorage {
      switch status.storage.operationMode {
      case .freezeProtection:
        if Storage.parameter.temperatureCharge[1] > 0 {
          solarField.temperature.inlet = status.storage.temperature.outlet
        } else {
          solarField.inletTemperature(kelvin:
            status.storage.antiFreezeTemperature)
        }
      case .preheat:
        solarField.temperature.inlet = status.storage.temperatureTank.cold
      case .charging where Plant.heat.production.watt == 0:
        solarField.header.temperature.inlet =
          solarField.header.temperature.outlet
      default: break
      }
    }

    if GridDemand.current.ratio < 1 {
      // added to reduced SOF massflow with electrical demand
      solarField.massFlow(rate: GridDemand.current.ratio
        * (steamTurbine.power.max / steamTurbine.efficiencyNominal
          / heatExchanger.efficiency) * 1_000
        / parameter.HTF.deltaHeat(heatExchanger.temperature.htf.inlet.max,
                                  heatExchanger.temperature.htf.outlet.max)
      )
      
      solarField.massFlow.rate = (solarField.massFlow + storage.massFlow).rate
        .limited(by: parameter.massFlow.max.rate)
    } else {
      solarField.massFlow = parameter.massFlow.max
    }
    
    if Design.hasStorage,
      status.storage.charge.ratio >= Storage.parameter.chargeTo {
      if Design.hasGasTurbine {
        solarField.massFlow = heatExchanger.sccHTFmassFlow
      }
    }
    
    solarField = calculate(solarField, collector: status.collector,
                           time: &timeRemain, dumping: &dumping, meteo: meteo)
    heatLossesHotHeader(&solarField, meteo)

    return solarField
  }

  private static func calculate(
    _ solarField: PerformanceData, collector: Collector.PerformanceData,
    time: inout Double, dumping: inout Double, meteo: MeteoData
    ) -> PerformanceData
  {
    let heatExchanger = HeatExchanger.parameter
    var solarField = solarField
    
    if solarField.isMaintained {
      if case .scheduledMaintenance = solarField.operationMode {
        return solarField
      }
      // First Day of Maintenance
      solarField = SolarField.initialState
    }

    if case .freezeProtection = solarField.operationMode {
      solarField.loops = solarField.loops.map { loop in
        var loop = loop
        loop.temperature.inlet = solarField.header.temperature.inlet
        return loop
      }
    }

    solarField.operationMode = .unknown
    #warning("The implementation here differs from PCT")
    solarField.loops[0].massFlow = solarField.header.massFlow
    solarField.loops[0].setTemperature(inlet:
      solarField.loops[1].temperature.inlet
    )
    (time, dumping) = HCE.calculation(
      &solarField, collector: collector,
      loop: .design, mode: solarField.operationMode.collector, meteo: meteo
    )

    solarField.header.massFlow = solarField.loops[0].massFlow
    solarField.header.setTemperature(outlet:
      solarField.loops[0].temperature.outlet
    )

    if solarField.loops[0].massFlow.isNearZero {
      solarField.loops[0].constantTemperature()
    }

    switch solarField.operationMode { // Check HCE and decide what to do
    case .operating:
      outletTemperature(&solarField, collector, meteo: meteo, timeRemain: time)
    case .freezeProtection:
      outletTemperature(&solarField, collector, meteo: meteo, timeRemain: time)
    case .noOperation: // does not neccessary mean no operation, see:
      if solarField.header.temperature.outlet
        > max(heatExchanger.temperature.htf.inlet.min,
              solarField.header.temperature.inlet)
      {
        solarField.operationMode = .operating
      }
      outletTemperature(&solarField, collector, meteo: meteo, timeRemain: time)

    default: // HCE returns with solarField.OPmode = unknown
      // if solarField.htf.temperature.outlet > heatExchanger.temperature.htf.inlet.min
      // && Not (Heater.solarField.operationMode = "OP" || Boiler.solarField.operationMode = "OP") {
      if solarField.header.temperature.outlet
        > heatExchanger.temperature.htf.inlet.min
      {
        // Boiler wurde hier rausgenommen, wegen nachrechenen von SEGS VI
        solarField.operationMode = .operating // Operation at minimum mass flow
        
      } else if Double(meteo.dni)
        > self.lastDNI + Simulation.parameter.minInsolationRaiseStartUp,
        solarField.header.temperature.outlet
          > solarField.header.temperature.inlet
          + Simulation.parameter.minTemperatureRaiseStartUp
      {
        self.lastDNI = Double(meteo.dni)
        solarField.operationMode = .startUp
      } else {
        // Force No Operation: Calc. the heat losses in HCEs for the rest of IMet.period
        solarField.operationMode = .noOperation
        // CalcnearLoop
        // NOTE: dtime after next calculation might be shorter than oldTime,
        // if HTFinHCE,Tout drops beyond freeze protection Temp. during that period.
      } // solarField.htf.temperature.outlet > heatExchanger.HTFinTmin
      outletTemperature(&solarField, collector, meteo: meteo, timeRemain: time)
    }
    return solarField
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
      + "Loops: \n\(loops[0])\n\(loops[1])\n\(loops[2])\n\(loops[3])"
  }
}
