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
/// Contains all data needed to simulate the operation of the solar field
public struct SolarField: Parameterizable, HeatTransfer {

  public let name = "Solar field"

  public enum Loop: Int {
    case design = 0
    case near, average, far
    static let indices: [Int] = [1,2,3] 
    static var names: [String] {
      ["Design", "Near", "Average", "Far"]
    }
  }
  
  var operationMode: OperationMode
  var isMaintained: Bool
  var header: HeatTransfer
  var ETA: Double
  public var heatLosses: Double
  public var heatLossesHotHeader: Double
  public var heatLossesHCE: Double
  public var inFocus: Ratio
  public var loops: [Cycle]
  var loopEta: Double

  public var temperature: (inlet: Temperature, outlet: Temperature) {
    get { header.temperature }
    set { header.temperature = newValue }
  }

  public var massFlow: MassFlow {
    get { header.massFlow }
    set { header.massFlow = newValue }
  }

  public enum OperationMode: String, CustomStringConvertible {
    case startUp
    case freezeProtection
    case operating
    case noOperation
    case scheduledMaintenance
    case unknown
    case normal

    public var description: String {
      return rawValue
    }

    var isFreezeProtection: Bool {
      return self ~= .freezeProtection
    }
  }

  static let initialState = SolarField(
    operationMode: .noOperation,
    isMaintained: false,
    header: Cycle(name: "Header"),
    ETA: 0,
    heatLosses: 0, heatLossesHotHeader: 0, heatLossesHCE: 0,
    inFocus: 0.0,
    loops: Loop.names.map { name in Cycle(loop: name) },
    loopEta: 0
  )

  public static var parameter: Parameter = ParameterDefaults.sf

  static func pipeHeatLoss(pipe: Temperature, ambient: Temperature) -> Double {
    ((pipe.kelvin - ambient.kelvin) / 333) ** 1 * parameter.pipeHeatLosses
  }

  /// Calculates the parasitics
  func parasitics() -> Double {
    let parameter = SolarField.parameter
    if operationMode.isFreezeProtection {
      return parameter.antiFreezeParastics
    }
    let load = massFlow.share(of: parameter.maxMassFlow).quotient
    if header.massFlow > .zero { 
      return parameter.pumpParasticsFullLoad
        * (parameter.pumpParastics[0] + parameter.pumpParastics[1]
          * load + parameter.pumpParastics[2] * load ** 2)
    } else {
      return 0
    }
  }

  /// Determines the inlet temperature of the solar field
  /// depending on the operating mode of the storage
  mutating func inletTemperature(storage: Storage, heat: ThermalPower) {
    switch storage.operationMode {
    case .freezeProtection:
      if Storage.parameter.temperatureCharge[1] > 0 {
        inletTemperature(outlet: storage)
      } else {
        temperature.inlet.kelvin = storage.antiFreezeTemperature
      }
    case .preheat:
      temperature.inlet = storage.temperatureTank.cold
    case .charging where heat.production.watt == 0:
      inletTemperatureFromOutlet()
    default: break
    }
  }

  private func imbalanceLoops(massFlow: MassFlow) -> [MassFlow] {
    let maxMassFlow = SolarField.parameter.maxMassFlow
    let design = SolarField.parameter.imbalanceDesign
    let minimum = SolarField.parameter.imbalanceMin
    let minFlowRatio = SolarField.parameter.minFlow.quotient
    let minFlow = MassFlow(minFlowRatio * maxMassFlow.rate)
    let m1 = (massFlow - minFlow).rate
    let m2 = (maxMassFlow - minFlow).rate
    return zip(design, minimum).map { d, m in   
      MassFlow(massFlow.rate * (m1 * (d - m) / m2 + m))
    }
  }

  private func ratios(_ timeRemain: Double)  -> [(Double, Double)] {
    let maxMassFlow = SolarField.parameter.maxMassFlow.rate
    let loopWays = SolarField.parameter.loopWays
    let flowVelocity: Double = 3.2
    return loopWays.indices.map { i -> (Double, Double) in
      let time = (loopWays[i] / (flowVelocity 
        * loops[i].massFlow.rate / maxMassFlow))
      var timeRatio = timeRemain / time

      let oneMinusTR: Double
      if timeRatio > 1.0 {
        timeRatio = 1.0
        oneMinusTR = 0.0
      } else {
        oneMinusTR = 1.0 - timeRatio
      }
      return (timeRatio, oneMinusTR)
    }
  }

  /// Calc. loop-outlet temp. gradient
  private mutating func outletTemperature(
    _ collector: Collector,
    _ ambient: Temperature,
    _ timeRemain: Double
  ) {
    let last = loops
    header.massFlow.rate = SolarField.parameter.maxMassFlow.rate * SolarField.parameter.minFlow.quotient
    if header.massFlow > .zero {
      let massFlows = imbalanceLoops(massFlow: header.massFlow)
      zip(Loop.indices, massFlows).forEach { i, massFlow in
        loops[i].massFlow = massFlow
      }
    }
    
    if header.massFlow == .zero {
      Loop.indices.forEach { loops[$0].massFlow = .zero }
    }

    [Loop.near, .average, .far].forEach { loop in
      calculation(
        collector: collector, loop: loop,
        mode: operationMode, ambient: ambient
      )
    }

    header.massFlow.rate = loops.dropFirst().reduce(0.0)
      { sum, loop in sum + loop.massFlow.rate } / 3.0
    
    if header.massFlow.isNearZero {
      Loop.indices.forEach { loops[$0].inletTemperatureFromOutlet() }
    } else {
      let maxMassFlow = SolarField.parameter.maxMassFlow.rate
      let pipeWay = SolarField.parameter.pipeWay      
      let loopWays = SolarField.parameter.loopWays
      
      let flowVelocity: Double = 3.2
      
      let timeRatios =  ratios(timeRemain)
      
      if timeRemain < loopWays[0] 
        / (flowVelocity * header.massFlow.rate / maxMassFlow)
      {
        for i in Loop.indices {
          loops[i].temperature.outlet.kelvin =
            timeRatios[0].0 * loops[i].outletTemperature
            + timeRatios[0].1 * last[i].outletTemperature
        }
      }
      // Now calc. the linear inlet temperature gradient:
      let wayRatio: Double = loopWays[2] / pipeWay
      
      loops[2].temperature.inlet.kelvin =
        loops[3].inletTemperature + wayRatio
        * (inletTemperature - loops[3].inletTemperature)
      
      loops[1].temperature.inlet.kelvin =
        loops[3].inletTemperature + 2 * wayRatio
        * (inletTemperature - loops[3].inletTemperature)
      
      var sum = 0.0
      zip(Loop.indices, timeRatios).forEach { i, tr in
        loops[i].temperature.inlet.kelvin = tr.0 * inletTemperature
          + tr.1 * last[i].inletTemperature
        sum += (tr.0 * loops[i].outletTemperature
          + tr.1 * last[i].outletTemperature) * loops[i].massFlow.rate
      }
      
      header.temperature.outlet.kelvin = sum / (3.0 * header.massFlow.rate)
    }
  }

  @discardableResult
  mutating func calculation(
    collector: Collector,
    loop: SolarField.Loop,
    mode: OperationMode,
    ambient: Temperature
  ) -> (Double, Double) {
    switch mode {
    case .noOperation, .freezeProtection:
      return HCE.mode2(&self, collector, loop, ambient)
    case .operating:
      //period = 300
      if /*meteo.windSpeed*/0 > SolarField.parameter.maxWind {
        inFocus = 0.0
      }
      return HCE.mode1(&self, collector, loop, ambient)

    default:
      if /*meteo.windSpeed*/0 > SolarField.parameter.maxWind
        || collector.insolationAbsorber < Simulation.parameter.minInsolation
      { 
        return HCE.mode2(&self, collector, loop, ambient)
      } else {
        return HCE.mode1(&self, collector, loop, ambient)
      }
    }    
  }

  mutating func antiFreezeCheck(loop: Loop) -> (MassFlow, OperationMode) {
    let freezingTemperature = SolarField.parameter.HTF.freezeTemperature
      + Simulation.parameter.dfreezeTemperaturePump
      + Simulation.parameter.tempTolerance

    if loops[loop.rawValue].minTemperature < freezingTemperature.kelvin {
      let antiFreeze = SolarField.parameter.antiFreezeFlow.quotient
      let maxMassFlow = SolarField.parameter.maxMassFlow.rate
      let antiFreezeFlow = MassFlow(antiFreeze * maxMassFlow)  
      return (antiFreezeFlow, .unknown)
    } else {
      return (0.0, operationMode)
    }
  }

  mutating func heatLossesHotHeader(ambient: Temperature) -> Temperature {
    let parameter = SolarField.parameter
    let c = parameter.heatLossHotHeader
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

      heatLossesHotHeader = c[0] * (c[1] + c[2] * (newTemp.kelvin - ambient.kelvin)) // [MWt]

      if header.massFlow.rate > 0 {
        let deltaHeatPerKg = heatLossesHotHeader * 1_000 / header.massFlow.rate // [kJ/kg]
        newTemp = htf.temperature(-deltaHeatPerKg, header.temperature.outlet)
      } else {
        let averageTemperature = Temperature.average(
          newTemp, header.temperature.outlet
        )
        assert(averageTemperature.celsius > 20, "Temperature too low.")
        /// Calculate average Temp. and areaDensity
        let collector = Collector.parameter
        
        let areaDensity =
          htf.density(averageTemperature) * .pi
          * collector.rabsInner ** 2 / collector.aperture  // kg/m2

        /// Heat collected or lost during the flow through a whole loop [kJ/sqm]
        let deltaHeatPerSqm = heatLossesHotHeader * 1_000_000 / area * 300 / 1_000 // [MW]
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
    let minTemperature = HeatExchanger.parameter.temperature.htf.inlet.min
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
    loops[0].temperature.inlet = header.temperature.inlet
    (loops[0].massFlow, operationMode) = antiFreezeCheck(loop: .design)

    (time, dumping) = calculation(
      collector: collector, loop: .design,
      mode: operationMode, ambient: ambient
    )

    (header.massFlow, operationMode) = antiFreezeCheck(loop: .design)
    header.temperature.outlet = loops[0].temperature.outlet

    if loops[0].massFlow.isNearZero {
      loops[0].inletTemperatureFromOutlet()
    }

    switch operationMode {  // Check HCE and decide what to do
    case .operating, .freezeProtection:
      outletTemperature(collector, ambient, time)
    case .noOperation:  // does not neccessary mean no operation, see:
      if header.temperature.outlet
        > max(minTemperature, header.temperature.inlet)
      {
        operationMode = .operating
      }
      //GoSub CalcNearLoop
      outletTemperature(collector, ambient, time)

    default:  // HCE returns with solarField.OPmode = unknown
      // if solarField.htf.temperature.outlet > heatExchanger.temperature.htf.inlet.min
      // && Not (Heater.solarField.operationMode = "OP" || Boiler.solarField.operationMode = "OP") {
      if header.temperature.outlet > minTemperature {
        // Boiler wurde hier rausgenommen, wegen nachrechenen von SEGS VI
        operationMode = .operating  // Operation at minimum mass flow

      } else if collector.insolationAbsorber
        > SolarField.oldInsolation + Simulation.parameter.minInsolationRaiseStartUp,
        header.temperature.outlet
          > header.temperature.inlet
          + Simulation.parameter.minTemperatureRaiseStartUp
      {
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
    SolarField.oldInsolation = collector.insolationAbsorber
  }

  static private var oldInsolation = 0.0
}

extension SolarField: MeasurementsConvertible {
  
  var numericalForm: [Double] {
    [heatLossesHotHeader, heatLossesHCE, inFocus.percentage]
  }
  
  static var columns: [(name: String, unit: String)] {
    [("SolarField|Header", "MW th"), ("SolarField|HCE", "MW th"),
     ("SolarField|Focus", "Ratio")]
  }
}