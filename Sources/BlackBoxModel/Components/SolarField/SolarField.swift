//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Meteo

public struct SolarField: Component, HeatCycle {

  public enum Loop: Int {
    case design = 0
    case near, average, far

    static var names: [String] {
      return ["Design", "Near", "Average", "Far"]
    }
  }

  /// Contains all data needed to simulate the operation of the solar field
  var operationMode: OperationMode
  var isMaintained: Bool
  var header: HeatTransfer
  var ETA: Double
  public var heatLosses: Double
  public var heatLossHeader: Double
  public var heatLossHCE: Double
  public var inFocus: Ratio
  var loops: [HeatTransfer]
  var loopEta: Double

  var cycle: HeatTransfer {
    get { header }
    set { header = newValue }
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

  static let initialState = SolarField(
    operationMode: .scheduledMaintenance,
    isMaintained: false,
    header: HeatTransfer(name: "Header"),
    ETA: 0,
    heatLosses: 0, heatLossHeader: 0, heatLossHCE: 0,
    inFocus: 0.0,
    loops: Loop.names.map { name in HeatTransfer(loop: name) },
    loopEta: 0
  )

  public static var parameter: Parameter = ParameterDefaults.sf
  static var last: [HeatTransfer] = initialState.loops

  static func pipeHeatLoss(pipe: Temperature, ambient: Temperature) -> Double {
    return ((pipe - ambient).kelvin / 333) ** 1 * parameter.pipeHeatLosses
  }

  /// Calculates the parasitics
  func parasitics() -> Double {
    let parameter = SolarField.parameter
    if operationMode == .freezeProtection {
      return parameter.antiFreezeParastics
    }
    let load = massFlow.share(of: parameter.massFlow).ratio
    return massFlow.rate > 0
      ? parameter.pumpParasticsFullLoad
        * (parameter.pumpParastics[0] + parameter.pumpParastics[1]
          * load + parameter.pumpParastics[2] * load ** 2)
      : 0
  }

  /// Determines the inlet temperature of the solar field
  /// depending on the operating mode of the storage
  mutating func inletTemperature(storage: Storage, heat: ThermalEnergy) {
    switch storage.operationMode {
    case .freezeProtection:
      if Storage.parameter.temperatureCharge[1] > 0 {
        inletTemperature(outlet: storage)
      } else {
        inletTemperature(kelvin: storage.antiFreezeTemperature)
      }
    case .preheat:
      temperature.inlet = storage.temperatureTank.cold
    case .charging where heat.production.watt == 0:
      inletTemperatureOutlet()
    default: break
    }
  }

  /// Calc. loop-outlet temp. gradient
  private mutating func outletTemperature(
    _ collector: Collector,
    _ ambient: Temperature,
    _ timeRemain: Double
  ) {
    let parameter = SolarField.parameter
    let minFlow = MassFlow(parameter.minFlow.ratio * parameter.massFlow.rate)
    HCE.freezeProtectionCheck(&self)
    SolarField.last = loops
    let m1 = (header.massFlow - minFlow).rate
    let m2 = (parameter.massFlow - minFlow).rate
    for (n, loop) in zip(0..., [Loop.near, .average, .far]) {
      let massFlow =
        header.massFlow.rate == 0
        ? 0
        : header.massFlow.rate
          * (m1 * (parameter.imbalanceDesign[n] - parameter.imbalanceMin[n])
            / m2 + parameter.imbalanceMin[n])
      loops[loop.rawValue].massFlow.rate = massFlow

      HCE.calculation(
        &self, collector: collector, loop: loop,
        mode: .variable, ambient: ambient)
    }

    header.massFlow.rate =
      loops.dropFirst().reduce(0.0) { sum, loop in
        sum + loop.massFlow.rate
      } / 3.0

    if header.massFlow.isNearZero {
      loops.dropFirst().indices.forEach { n in
        loops[n].constantTemperature()
      }
    } else {
      let designFlowVelocity: Double = 2.7

      if timeRemain < parameter.loopWays[0]
        / (designFlowVelocity
          * header.massFlow.rate / parameter.massFlow.rate)
      {
        let timeRatio =
          timeRemain
          / (parameter.loopWays[0]
            / (designFlowVelocity * header.massFlow.rate
              / parameter.massFlow.rate))
        // Correct the loop outlet temperatures
        let oneMinusTR = 1.0 - timeRatio

        for n in loops.indices.dropFirst() {
          loops[n].temperature.outlet.kelvin =
            timeRatio * loops[n].outletTemperature
            + oneMinusTR * SolarField.last[n].outletTemperature
        }
      }

      let temps = loops.indices.dropFirst().map {
        n -> (Double, Double, Double) in
        var timeRatio =
          timeRemain
          / (parameter.loopWays[n]
            / (designFlowVelocity * loops[n].massFlow.rate
              / parameter.massFlow.rate))

        let oneMinusTR: Double
        if timeRatio > 1.0 {
          timeRatio = 1.0
          oneMinusTR = 0.0
        } else {
          oneMinusTR = 1.0 - timeRatio
        }

        let temp =
          timeRatio * loops[n].outletTemperature
          + oneMinusTR * SolarField.last[n].outletTemperature

        return (timeRatio, oneMinusTR, temp)
      }

      header.temperature.outlet.kelvin =
        (temps[0].2 * loops[1].massFlow.rate
          + temps[1].2 * loops[2].massFlow.rate
          + temps[2].2 * loops[3].massFlow.rate)
        / (3.0 * header.massFlow.rate)

      // Now calc. the linear inlet temperature gradient:
      let wayRatio: Double = parameter.loopWays[2] / parameter.pipeWay

      loops[2].temperature.inlet = Temperature(
        celsius:
          loops[3].temperature.inlet.celsius + wayRatio
          * (temperature.inlet.celsius - loops[3].temperature.inlet.celsius))

      loops[1].temperature.inlet = Temperature(
        celsius:
          loops[3].temperature.inlet.celsius + 2 * wayRatio
          * (temperature.inlet.celsius - loops[3].temperature.inlet.celsius))

      loops[1].temperature.inlet.kelvin =
        temps[0].0 * inletTemperature
        + temps[0].1 * loops[1].inletTemperature

      loops[2].temperature.inlet.kelvin =
        temps[1].0 * inletTemperature
        + temps[1].1 * loops[2].inletTemperature

      loops[3].temperature.inlet.kelvin =
        temps[2].0 * inletTemperature
        + temps[2].1 * loops[3].inletTemperature
    }
  }

  mutating func heatLossesHotHeader(ambient: Temperature) -> Temperature {
    let parameter = SolarField.parameter
    let heatLoss = parameter.heatLossHeader
    let htf = parameter.HTF
    let area =
      Design.layout.solarField
      * Double(parameter.numberOfSCAsInRow)
      * 2 * Collector.parameter.areaSCAnet

    var oldTemp: Temperature
    var newTemp: Temperature

    newTemp = header.temperature.outlet

    repeat {
      oldTemp = newTemp

      heatLossHeader =
        heatLoss[0] * (heatLoss[1] + heatLoss[2] * (newTemp - ambient).kelvin) // [MWt]

      if header.massFlow.rate > 0 {
        let deltaHeatPerKg = heatLossHeader * 1_000 / header.massFlow.rate // [kJ/kg]
        newTemp = htf.temperature(-deltaHeatPerKg, header.temperature.outlet)
      } else {
        let averageTemperature = Temperature.average(
          newTemp, header.temperature.outlet
        )
        /// Calculate average Temp. and areaDensity
        let collector = Collector.parameter
        if averageTemperature.celsius < 20 {
          print("Temperature too low.")
          break
        }
        let areaDensity =
          htf.density(averageTemperature) * .pi
          * collector.rabsInner ** 2 / collector.aperture  // kg/m2

        /// Heat collected or lost during the flow through a whole loop [kJ/sqm]
        let deltaHeatPerSqm =
          heatLossHeader * 1_000_000  // [MW]
          / area * 300 / 1_000
        /// Change kJ/sqm to kJ/kg:
        let deltaHeatPerKg = deltaHeatPerSqm / areaDensity

        let heatPerKg = htf.deltaHeat(header.temperature.outlet, ambient)
        newTemp = htf.temperature(heatPerKg - deltaHeatPerKg, ambient)
      }
      newTemp.limit(to: parameter.HTF.maxTemperature)
    } while abs(newTemp.kelvin - oldTemp.kelvin)
      > Simulation.parameter.HLtempTolerance
    return newTemp
  }

  mutating func calculate(
    dumping: inout Double,
    collector: Collector,
    ambient: Temperature
  ) {
    let heatExchanger = HeatExchanger.parameter
    var time = 0.0
    if isMaintained {
      if case .scheduledMaintenance = operationMode {
        return
      }
      // First Day of Maintenance
      self = SolarField.initialState
    }

    if case .freezeProtection = operationMode {
      loops = loops.map { loop in
        var loop = loop
        loop.temperature.inlet = temperature.inlet
        return loop
      }
    }

    operationMode = .unknown
    //#warning("The implementation here differs from PCT")
    loops[0].massFlow = header.massFlow
    loops[0].temperature.inlet = loops[1].temperature.inlet

    (time, dumping) = HCE.calculation(
      &self, collector: collector, loop: .design,
      mode: operationMode.collector, ambient: ambient
    )

    header.massFlow = loops[0].massFlow
    header.temperature.outlet = loops[0].temperature.outlet

    if loops[0].massFlow.isNearZero {
      loops[0].constantTemperature()
    }

    switch operationMode {  // Check HCE and decide what to do
    case .operating, .freezeProtection:
      outletTemperature(collector, ambient, time)
    case .noOperation:  // does not neccessary mean no operation, see:
      if header.temperature.outlet
        > max(
          heatExchanger.temperature.htf.inlet.min,
          header.temperature.inlet)
      {
        operationMode = .operating
      }
      //GoSub CalcNearLoop
      outletTemperature(collector, ambient, time)

    default:  // HCE returns with solarField.OPmode = unknown
      // if solarField.htf.temperature.outlet > heatExchanger.temperature.htf.inlet.min
      // && Not (Heater.solarField.operationMode = "OP" || Boiler.solarField.operationMode = "OP") {
      if header.temperature.outlet > heatExchanger.temperature.htf.inlet.min {
        // Boiler wurde hier rausgenommen, wegen nachrechenen von SEGS VI
        operationMode = .operating  // Operation at minimum mass flow

      } else if collector.insolationAbsorber
        > SolarField.oldInsolation + Simulation.parameter.minInsolationRaiseStartUp,
        header.temperature.outlet
          > header.temperature.inlet
          + Simulation.parameter.minTemperatureRaiseStartUp
      {
        SolarField.oldInsolation = collector.insolationAbsorber
        operationMode = .startUp
      } else {
        // Force No Operation: Calc. the heat losses in HCEs for the rest of IMet.period
        operationMode = .noOperation
        // CalcnearLoop
        // NOTE: dtime after next calculation might be shorter than oldTime,
        // if HTFinHCE,Tout drops beyond freeze protection Temp. during that period.
      }  // solarField.htf.temperature.outlet > heatExchanger.HTFinTmin
      outletTemperature(collector, ambient, time)
    }
  }

  static private var oldInsolation = 0.0
}
