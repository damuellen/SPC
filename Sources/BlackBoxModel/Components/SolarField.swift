//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Libc
import Meteo
import Utilities
import Units

extension SolarField: CustomStringConvertible {
  public var description: String {
    "  Mode:".padding(30) + "\(operationMode)\n" + formatting(
      [heatLosses, heatLossesHotHeader, heatLossesHCE],
      ["Heat losses:", "Heat losses header:", "Heat losses HCE:"]      
    ) + "\n" + cycle.description 
      + "\nDesign\n\(loops[0])\nNear\n\(loops[1])\nAverage\n\(loops[2])\nFar\n\(loops[3])"
  }
}

extension SolarField.OperationMode: CustomStringConvertible {
  public var description: String {
    switch self {      
    case .startUp: return "Start up"
    case .shutdown: return "Shut down"   
    case .follow: return "Follow"
    case .track: return "Track"
    case .defocus(let r): return "Dumping \(Ratio(1-r.quotient).singleBar)"
    case .stow: return "Stow"
    case .freeze: return "Freeze protection"
    case .maintenance: return "Maintenance"
    }
  }
}

/// This struct contains the state as well as the functions for mapping the solar field
public struct SolarField: Parameterizable, HeatTransfer {

  public let name = "Solar field"

  public enum Loop: Int {
    case design = 0
    case near, average, far
    static let indices: [Int] = [1,2,3]
    static var names: [String] { ["Design", "Near", "Average", "Far"] }
  }

  /// Returns the operating state
  public internal(set) var operationMode: OperationMode

  public internal(set) var eta: Double = 0.0
  public internal(set) var loopEta: Double = 0.0
  public internal(set) var heatLosses: Double = 0.0
  public internal(set) var heatLossesHotHeader: Double = 0.0
  public internal(set) var heatLossesHCE: Double = 0.0

  var header: HeatTransfer
  public internal(set) var loops: [Cycle]

  public var inFocus: Ratio {
    switch operationMode {
      case .defocus(let ratio): return ratio
      case .startUp, .track: return 1.0
      default: return 0.0
    }
  }

  public internal(set) var temperature: (inlet: Temperature, outlet: Temperature) {
    get { header.temperature }
    set { header.temperature = newValue }
  }

  public internal(set) var massFlow: MassFlow {
    get { header.massFlow }
    set { header.massFlow = newValue }
  }

  let area = Design.layout.solarField * Collector.parameter.areaSCAnet
    * 2 * Double(SolarField.parameter.numberOfSCAsInRow)

  let minMassFlow = MassFlow(
    SolarField.parameter.minFlow.quotient * SolarField.parameter.maxMassFlow.rate
  )

  let antiFreezeFlow = MassFlow(
      SolarField.parameter.antiFreezeFlow.quotient * SolarField.parameter.maxMassFlow.rate
  )

  var requiredMassFlow: MassFlow = .zero

  public enum OperationMode {
    case startUp
    case shutdown
    case follow
    case track
    case defocus(Ratio)
    case stow
    case freeze(Double)
    case maintenance

    var isFreezeProtection: Bool {
      if case .freeze = self { return true }
      return false
    }
  }
  /// Returns the fixed initial state.
  static let initialState = SolarField(
    operationMode: .stow,
    header: Cycle(name: "Header"),
    loops: Loop.names.map { name in Cycle(loop: name) }
  )
  /// Returns the static parameters.
  public static var parameter: Parameter = Parameters.sf

  mutating func requiredMassFlow(from storage: Storage) {
    if storage.relativeCharge < Storage.parameter.chargeTo {
      requiredMassFlow += MassFlow(
      (1 - Storage.parameter.massFlowShare.quotient)
        * SolarField.parameter.maxMassFlow.rate
      )
    } else if Design.hasGasTurbine {
      requiredMassFlow = HeatExchanger.parameter.massFlowHTF
    }
    if massFlow > requiredMassFlow {
      massFlow = requiredMassFlow
    }
    assert(requiredMassFlow <= SolarField.parameter.maxMassFlow)
  }

  static func pipeHeatLoss(pipe: Temperature, ambient: Temperature) -> Double {
    ((pipe.kelvin - ambient.kelvin) / 333) ** 1 * parameter.pipeHeatLosses
  }

  /// Calculates the parasitics of pumps
  func parasitics() -> Double {
    let maxMassFlow = SolarField.parameter.maxMassFlow
    if operationMode.isFreezeProtection {
      return SolarField.parameter.antiFreezeParastics
    }
    let load = massFlow.share(of: maxMassFlow).quotient
    if header.massFlow > .zero {
      let fullLoad = SolarField.parameter.pumpParasticsFullLoad
      let p = SolarField.parameter.pumpParastics
      return fullLoad * (p[0] + p[1] * load + p[2] * load ** 2)
    } else {
      return .zero
    }
  }

  mutating func eta(collector: Collector) {
    if collector.insolationAbsorber > .zero {
      loopEta = collector.efficiency - heatLossesHCE
        / collector.insolationAbsorber / collector.efficiency
      eta = collector.efficiency - heatLosses
        / collector.insolationAbsorber / collector.efficiency
    } else {
      loopEta = .zero
      eta = .zero
    }
  }
  /// Determines the inlet temperature of the solar field
  /// depending on the operating mode of the storage
  mutating func inletTemperature(from storage: Storage) {
    switch storage.operationMode {
    case .freezeProtection:
      if Storage.parameter.temperatureCharge[1] > 0 {
        inletTemperature(output: storage)
      } else {
        temperature.inlet.kelvin = storage.antiFreezeTemperature
      }
    case .preheat:
      temperature.inlet = storage.temperatureTank.cold
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

  private func ratios()  -> [(Double, Double)] {
    let timeRemain = Simulation.time.steps.interval
    let maxMassFlow = SolarField.parameter.maxMassFlow.rate
    let loopWays = SolarField.parameter.loopWays
    let flowVelocity: Double = 2.7
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
  private mutating func outletTemperature(last: [Cycle], _ time: Double) {
    let maxMassFlow = SolarField.parameter.maxMassFlow.rate
    let pipeWay = SolarField.parameter.pipeWay
    let loopWays = SolarField.parameter.loopWays

    let flowVelocity: Double = 2.7

    let timeRatios =  ratios()
    let remain = loopWays[0] / (flowVelocity * header.flow / maxMassFlow)
    if time < remain {
      for i in Loop.indices {
        loops[i].temperature.outlet.kelvin =
          timeRatios[0].0 * loops[i].outlet + timeRatios[0].1 * last[i].outlet
      }
    }
    // Now calc. the linear inlet temperature gradient:
    let wayRatio: Double = loopWays[2] / pipeWay

    loops[2].temperature.inlet.kelvin =
      loops[3].inlet + wayRatio * (inlet - loops[3].inlet)

    loops[1].temperature.inlet.kelvin =
      loops[3].inlet + 2 * wayRatio * (inlet - loops[3].inlet)

    var sum = 0.0
    zip(Loop.indices, timeRatios).forEach { i, tr in
      sum += (tr.0 * loops[i].outlet + tr.1 * last[i].outlet) * loops[i].flow
      loops[i].temperature.inlet.kelvin = tr.0 * inlet + tr.1 * last[i].inlet
    }

    header.temperature.outlet.kelvin = sum / (3.0 * header.flow)
  }

  // Check if freeze protection is required for the solar field.
  // - Returns: A boolean indicating whether freeze protection is required or not.
  mutating func isFreezeProtectionRequired() -> Bool {
    // Calculate the freezing temperature considering the HTF freeze temperature,
    // pump temperature tolerance, and simulation temperature tolerance.
    let freezingTemperature = SolarField.parameter.HTF.freezeTemperature
      + Simulation.parameter.deltaFreezeTemperaturePump
      + Simulation.parameter.tempTolerance

    // Get the time interval for the current simulation step.
    let timeRemain = Simulation.time.steps.interval

    // Check if the solar field is currently in the freeze protection mode and has remaining time.
    if case .freeze(let time) = operationMode, time > .zero {
      // Reduce the remaining freeze time and update the operation mode.
      operationMode = .freeze(time - timeRemain)
      return true
    }

    // Check if the minimum temperature of any loop's outlet is below the freezing temperature.
    if loops.dropFirst().min(by: <)!.minTemperature < freezingTemperature.kelvin {
      // Set the inlet temperature of all loops to the current header inlet temperature.
      loops.indices.forEach {
        loops[$0].temperature.inlet = header.temperature.inlet
      }

      // Calculate the remaining time for freeze protection based on flow dynamics.
      let loopWays = SolarField.parameter.loopWays
      let flowVelocity: Double = 2.7
      let maxMassFlow = SolarField.parameter.maxMassFlow.rate
      let remain = loopWays[0] / (flowVelocity * antiFreezeFlow.rate / maxMassFlow)

      // Update the operation mode to freeze with the calculated remaining time.
      operationMode = .freeze(remain - timeRemain)
      return true
    }

    // If freeze protection is not required, return false.
    return false
  }

  /// Calculate heat losses from the header of the solar field.
  /// - Parameters:
  ///   - temperature: The current temperature of the header.
  ///   - ambient: The ambient temperature surrounding the solar field.
  /// - Returns: The new temperature after accounting for heat losses.
  mutating func heatLosses(header temperature: Temperature, ambient: Temperature) -> Temperature {
    let parameter = SolarField.parameter
    let numberOfSCAsInRow = SolarField.parameter.numberOfSCAsInRow
    let areaSCAnet = Collector.parameter.areaSCAnet
    let rabsInner = Collector.parameter.rabsInner
    let aperture = Collector.parameter.aperture
    let c = SolarField.parameter.heatLossHotHeader
    let htf = SolarField.parameter.HTF

    // Calculate the total area of the solar field.
    let area = Design.layout.solarField * Double(numberOfSCAsInRow) * 2 * areaSCAnet

    var oldTemp: Temperature
    var newTemp: Temperature

    // Set the initial temperature for the iterative calculation.
    newTemp = temperature

    // Repeat the calculations until the temperature stabilizes within the heat loss tolerance.
    repeat {
        oldTemp = newTemp

        // Calculate heat losses from the header using predefined coefficients (c).
        heatLossesHotHeader = c[0] * (c[1] + c[2] * (newTemp.kelvin - ambient.kelvin)) // [MWt]

        // Check if there is a mass flow in the system to avoid division by zero.
        if massFlow.rate > 0 {
            // Calculate the change in heat per kilogram of the heat transfer fluid (HTF).
            let deltaHeatPerKg = heatLossesHotHeader * 1_000 / massFlow.rate // [kJ/kg]
            // Update the new temperature based on the change in heat per kilogram.
            newTemp = htf.temperature(-deltaHeatPerKg, temperature)
        } else {
            // Calculate the average temperature between the new and ambient temperatures.
            let avgT = Temperature.average(newTemp, temperature)
            // Calculate the area density of the HTF using the average temperature.
            let areaDensity = htf.density(avgT) * .pi * rabsInner ** 2 / aperture  // kg/m2
            let time = Simulation.time.steps.interval
            // Calculate the change in heat per square meter of the solar field.
            let deltaHeatPerSqm = heatLossesHotHeader * 1_000 / area * time
            // Convert the change in heat per square meter to change in heat per kilogram.
            let deltaHeatPerKg = deltaHeatPerSqm / areaDensity

            // Calculate the heat content of the HTF at the current and ambient temperatures.
            let heatPerKg = htf.heatContent(temperature, ambient)
            // Update the new temperature based on the change in heat content per kilogram.
            newTemp = htf.temperature(heatPerKg - deltaHeatPerKg, ambient)
        }
        // Limit the new temperature to the maximum temperature of the HTF.
        newTemp.limit(to: parameter.HTF.maxTemperature)
    } while abs(newTemp.kelvin - oldTemp.kelvin) > Simulation.parameter.heatlossTempTolerance

    // Return the new temperature after accounting for heat losses.
    return newTemp
}

  mutating func calculate(collector: Collector, ambient: Temperature) {
    let insolation = collector.insolationAbsorber < collector.lastInsolation
      ? collector.lastInsolation : collector.insolationAbsorber
    let elevation = collector.parabolicElevation

    /// The heat that can be absorbed by the HTF
    let heatPerKgHTF = medium.heatContent(
      medium.maxTemperature, header.temperature.inlet
    )

    /// Heat losses of the HCE for maximum outlet temperature
    let heatLossesHCE = HCE.heatLosses(
      inlet: header.temperature.inlet,
      insolation: insolation,
      ambient: ambient
    )

    var heatLosses = heatLossesHCE

    /// Average HTF temperature in loop
    let avgT = Temperature.average(medium.maxTemperature, header.temperature.inlet)

    /// Add heat losses of the connecting pipes
    heatLosses += SolarField.pipeHeatLoss(pipe: avgT, ambient: ambient)
    heatLosses *= Simulation.adjustmentFactor.heatLossHTF

    /// The predefined availability of the solar field
    let availability = Availability.current.value.solarField.quotient
    /// Watts per square metre after taking into account heat losses
    let deltaHeat = insolation * availability - heatLosses // [W/m2]
    /// Calculate appropriate mass flow [kg/(sec sqm)]
    let kgPerSqm = deltaHeat / 1_000 / heatPerKgHTF

    // Check if mass flow is within acceptable limits
    switch MassFlow(kgPerSqm * area) {
    case let massFlow where massFlow.rate <= .zero: // HCE loses heat
      if isFreezeProtectionRequired() {
        header.massFlow = antiFreezeFlow
      } else {
        operationMode = elevation.isZero ? .stow : .follow
        header.massFlow = .zero
      }
    case let massFlow where massFlow > requiredMassFlow:
      let ratio = Ratio(requiredMassFlow.rate / massFlow.rate)
      operationMode = .defocus(ratio)
      // Set maximum flow
      header.massFlow = requiredMassFlow
    case let massFlow where massFlow < minMassFlow:
      operationMode = .follow
      header.massFlow = minMassFlow
    case let massFlow: // MassFlow is within acceptable limits
      operationMode = .track
      header.massFlow = massFlow
    }

    let last = loops

    let minTemp = HeatExchanger.parameter.temperature.htf.inlet.min.kelvin
    if header.massFlow > minMassFlow {
      if header.outlet < minTemp { header.massFlow = minMassFlow }
    }

    loops[0].massFlow = header.massFlow
    loops[0].temperature.inlet = header.temperature.inlet
    // Calculate design loop outlet temperature
    let time = HCE.temperatures(&self, .design, collector.insolationAbsorber, ambient)

    // Check HCE and decide what to do
    if case .follow = operationMode {
      let minRaise = Simulation.parameter.minInsolationRaiseStartUp
      if elevation < 90, insolation > collector.lastInsolation + minRaise,
        insolation > Simulation.parameter.minInsolation {
        operationMode = .startUp
        header.massFlow = minMassFlow
      } else if loops[0].outlet < minTemp, elevation > 90 {
        operationMode = .shutdown
        header.massFlow = .zero
      } else if header.outlet > minTemp, header.outlet > header.inlet {
        operationMode = .track
      } else {
        header.massFlow = .zero
      }
    }

    if header.massFlow > .zero {
      let massFlows = imbalanceLoops(massFlow: header.massFlow)
      zip(Loop.indices, massFlows).forEach { i, massFlow in
        loops[i].massFlow = massFlow
      }
    } else {
      loops.indices.forEach { loops[$0].massFlow = .zero }
    }

    for loop in [Loop.near, .far, .average] {
      _ = HCE.temperatures(&self, loop, collector.insolationAbsorber, ambient)
    }

    header.massFlow.rate = loops.dropFirst().reduce(0.0)
      { sum, loop in sum + loop.massFlow.rate } / 3.0

    if header.massFlow > .zero { outletTemperature(last: last, time) }
  }
}

extension SolarField: MeasurementsConvertible {

  var values: [Double] {
    [heatLossesHotHeader, heatLossesHCE, inFocus.percentage]
  }

  static var measurements: [(name: String, unit: String)] {
    [("SolarField|Header", "MW th"), ("SolarField|HCE", "MW th"),
     ("SolarField|Focus", "Ratio")]
  }
}
