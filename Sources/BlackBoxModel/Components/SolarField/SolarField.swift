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

  public enum Loop: Int {
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
    var ETA: Double
    public var heatLosses: Double
    public var heatLossHeader: Double
    public var heatLossHCE: Double
    public var inFocus: Ratio
    var loops: [HeatFlow]
    var loopEta: Double
    
    public var massFlow: MassFlow {
      get { return self.header.massFlow }
      set { self.header.massFlow = newValue }
    }

    public var temperature: (inlet: Temperature, outlet: Temperature) {
      get { return self.header.temperature }
      set { self.header.temperature = newValue }
    }

    public enum OperationMode: String, CustomStringConvertible {
      case startUp
      case freezeProtection
      case operating
      case noOperation
      case scheduledMaintenance
      case unknown
      case fixed
      case normal

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
    ETA: 0,
    heatLosses: 0, heatLossHeader: 0, heatLossHCE: 0,
    inFocus: 0.0,
    loops: Loop.names.map { name in HeatFlow(loop: name) },
    loopEta: 0
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

  static func pipeHeatLoss(pipe: Temperature, ambient: Temperature) -> Double {
    return ((pipe - ambient).kelvin / 333) ** 1 * parameter.pipeHeatLosses
  }

  /// Calc. loop-outlet temp. gradient
  private static func outletTemperature(
    _ solarField: inout SolarField.PerformanceData,
    _ collector: Collector.PerformanceData,
    _ ambient: Temperature,
    _ timeRemain: Double)
  {
    HCE.freezeProtectionCheck(&solarField)
    last = solarField.loops
    for (n, loop) in zip(0..., [Loop.near, .average, .far]) {
      let massFlow = solarField.header.massFlow.rate == 0
        ? 0 : solarField.header.massFlow.rate
        * ( (solarField.header.massFlow - parameter.massFlow.min).rate
          * (parameter.imbalanceDesign[n] - parameter.imbalanceMin[n])
          / (parameter.massFlow.max - parameter.massFlow.min).rate
          + parameter.imbalanceMin[n] )
      solarField.loops[loop.rawValue].setMassFlow(rate: massFlow)

      HCE.calculation(&solarField, collector: collector, loop: loop,
                      mode: .variable, ambient: ambient)
    }
    
    solarField.header.setMassFlow(rate:
      solarField.loops.dropFirst().reduce(0.0) { sum, loop in
        sum + loop.massFlow.rate } / 3.0
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
        let oneMinusTR = 1.0 - timeRatio

        for n in solarField.loops.indices.dropFirst() {
          solarField.loops[n].outletTemperature(kelvin:
            timeRatio * solarField.loops[n].outletTemperature
            + oneMinusTR * last[n].outletTemperature)
        }
      }

      let temps = solarField.loops.indices.dropFirst().map {
        n -> (Double, Double, Double) in
        var timeRatio = timeRemain / (parameter.loopWays[n]
          / (designFlowVelocity * solarField.loops[n].massFlow.rate
            / parameter.massFlow.max.rate))
        
        let oneMinusTR: Double
        if timeRatio > 1.0 {
          timeRatio = 1.0
          oneMinusTR = 0.0
        } else {
          oneMinusTR = 1.0 - timeRatio
        }
        
        let temp = timeRatio * solarField.loops[n].outletTemperature
          + oneMinusTR * last[n].outletTemperature
        
        return (timeRatio, oneMinusTR, temp)
      }

      solarField.header.outletTemperature(kelvin:
        (temps[0].2 * solarField.loops[1].massFlow.rate
          + temps[1].2 * solarField.loops[2].massFlow.rate
          + temps[2].2 * solarField.loops[3].massFlow.rate)
          / (3.0 * solarField.header.massFlow.rate)
      )

      // Now calc. the linear inlet temperature gradient:
      let wayRatio: Double = parameter.loopWays[2] / parameter.pipeWay

      solarField.loops[2].temperature.inlet = Temperature(celsius:
        solarField.loops[3].temperature.inlet.celsius + wayRatio
          * (solarField.temperature.inlet.celsius
            - solarField.loops[3].temperature.inlet.celsius))

      solarField.loops[1].temperature.inlet = Temperature(celsius:
        solarField.loops[3].temperature.inlet.celsius + 2 * wayRatio
          * (solarField.temperature.inlet.celsius
            - solarField.loops[3].temperature.inlet.celsius))

      solarField.loops[1].inletTemperature(kelvin:
        temps[0].0 * solarField.inletTemperature
          + temps[0].1 * solarField.loops[1].inletTemperature
      )

      solarField.loops[2].inletTemperature(kelvin:
        temps[1].0 * solarField.inletTemperature
          + temps[1].1 * solarField.loops[2].inletTemperature
      )

      solarField.loops[3].inletTemperature(kelvin:
        temps[2].0 * solarField.inletTemperature
          + temps[2].1 * solarField.loops[3].inletTemperature
      )
    }
  }

  static func heatLossesHotHeader(
    _ solarField: PerformanceData, ambient: Temperature) -> Temperature
  {
    let area = Design.layout.solarField
      * Double(SolarField.parameter.numberOfSCAsInRow)
      * 2 * Collector.parameter.areaSCAnet
    var solarField = solarField
    var oldTemp, newTemp: Temperature
    
    newTemp = solarField.header.temperature.outlet

    repeat {      
      oldTemp = newTemp
      
      solarField.heatLossHeader = parameter.heatLossHeader[0]
        * (parameter.heatLossHeader[1] + parameter.heatLossHeader[2]
          * (newTemp - ambient).kelvin) // [MWt]
      
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
          / area * 300 / 1_000
        /// Change kJ/sqm to kJ/kg:
        let deltaHeatPerKg = deltaHeatPerSqm / areaDensity
        
        let heatPerKg = parameter.HTF.deltaHeat(
          solarField.header.temperature.outlet, ambient
        )
        newTemp = parameter.HTF.temperature(
          heatPerKg - deltaHeatPerKg, ambient
        )
      }
      newTemp = newTemp.limited(by: parameter.HTF.maxTemperature)
    } while abs(newTemp.kelvin - oldTemp.kelvin)
      > Simulation.parameter.HLtempTolerance
    return newTemp
  }

  static func calculate(
    _ solarField: inout PerformanceData,
    collector: Collector.PerformanceData,
    time: inout Double,
    dumping: inout Double,
    ambient: Temperature)
  {
    let heatExchanger = HeatExchanger.parameter
    
    if solarField.isMaintained {
      if case .scheduledMaintenance = solarField.operationMode {
        return
      }
      // First Day of Maintenance
      solarField = SolarField.initialState
    }

    if case .freezeProtection = solarField.operationMode {
      solarField.loops = solarField.loops.map { loop in
        var loop = loop
        loop.inletTemperature(inlet: solarField)
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
      &solarField, collector: collector, loop: .design,
      mode: solarField.operationMode.collector, ambient: ambient
    )

    solarField.header.massFlow = solarField.loops[0].massFlow
    solarField.header.setTemperature(outlet:
      solarField.loops[0].temperature.outlet
    )

    if solarField.loops[0].massFlow.isNearZero {
      solarField.loops[0].constantTemperature()
    }

    switch solarField.operationMode { // Check HCE and decide what to do
    case .operating, .freezeProtection:
      outletTemperature(&solarField, collector, ambient, time)
    case .noOperation: // does not neccessary mean no operation, see:
      if solarField.header.temperature.outlet
        > max(heatExchanger.temperature.htf.inlet.min,
              solarField.header.temperature.inlet)
      {
        solarField.operationMode = .operating
      }
      //GoSub CalcNearLoop
      outletTemperature(&solarField, collector, ambient, time)

    default: // HCE returns with solarField.OPmode = unknown
      // if solarField.htf.temperature.outlet > heatExchanger.temperature.htf.inlet.min
      // && Not (Heater.solarField.operationMode = "OP" || Boiler.solarField.operationMode = "OP") {
      if solarField.header.temperature.outlet
        > heatExchanger.temperature.htf.inlet.min
      {
        // Boiler wurde hier rausgenommen, wegen nachrechenen von SEGS VI
        solarField.operationMode = .operating // Operation at minimum mass flow
        
      } else if collector.insolationAbsorber
        > self.oldInsolation + Simulation.parameter.minInsolationRaiseStartUp,
        solarField.header.temperature.outlet
          > solarField.header.temperature.inlet
          + Simulation.parameter.minTemperatureRaiseStartUp
      {
        self.oldInsolation = collector.insolationAbsorber
        solarField.operationMode = .startUp
      } else {
        // Force No Operation: Calc. the heat losses in HCEs for the rest of IMet.period
        solarField.operationMode = .noOperation
        // CalcnearLoop
        // NOTE: dtime after next calculation might be shorter than oldTime,
        // if HTFinHCE,Tout drops beyond freeze protection Temp. during that period.
      } // solarField.htf.temperature.outlet > heatExchanger.HTFinTmin
      outletTemperature(&solarField, collector, ambient, time)
    }
  }

  static private var oldInsolation = 0.0
}

