// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import Libc
import Meteo
import Utilities
import Units

extension SolarField: CustomStringConvertible {
  /// A textual representation of the SolarField instance.
  public var description: String {
    "  Mode:".padding(30) + "\(operationMode)\n" + formatting(
      [heatLosses, heatLossesHotHeader, heatLossesHCE],
      ["Heat losses:", "Heat losses header:", "Heat losses HCE:"]      
    ) + "\n" + cycle.description 
      + "\nDesign\n\(loops[0])\nNear\n\(loops[1])\nAverage\n\(loops[2])\nFar\n\(loops[3])"
  }
}

extension SolarField.OperationMode: CustomStringConvertible {
  /// A textual representation of the OperationMode enum cases.
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

/// A struct representing the state and functions for mapping the solar field
struct SolarField: Parameterizable, ThermalProcess {
  /// The name of the solar field.
  let name = "Solar field"

  public enum Loop: Int {
    case design = 0
    case near, average, far
    static let indices: [Int] = [1,2,3]
    static var names: [String] { ["Design", "Near", "Average", "Far"] }
  }

  /// The current operating mode of the solar field
  private(set) var operationMode: OperationMode

  private(set) var eta: Double = 0.0
  private(set) var loopEta: Double = 0.0
  private(set) var heatLosses: Double = 0.0
  private(set) var heatLossesHotHeader: Double = 0.0
  private(set) var heatLossesHCE: Double = 0.0

  var header: ThermalProcess
  var loops: [HeatTransferCycle]

  var inFocus: Ratio {
    switch operationMode {
      case .defocus(let ratio): return ratio
      case .startUp, .track: return 1.0
      default: return 0.0
    }
  }

  /// The temperature at the inlet and outlet of the solar field.
  var temperature: (inlet: Temperature, outlet: Temperature) {
    get { header.temperature }
    set { header.temperature = newValue }
  }
  
  /// The mass flow rate of the solar field header.
  var massFlow: MassFlow {
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

  var requiredMassFlow: MassFlow = HeatExchanger.designMassFlow

  /// The operation mode options for the solar field
  enum OperationMode {
    case startUp
    case shutdown
    case follow
    case track
    case defocus(Ratio)
    case stow
    case freeze(Double)
    case maintenance
    /// A computed property that determines if the operation mode is freeze protection.
    var isFreezeProtection: Bool {
      if case .freeze = self { return true }
      return false
    }
  }
  /// Creates a `SolarField` instance with the fixed initial state.
  static let initialState = SolarField(
    operationMode: .stow,
    header: HeatTransferCycle(name: "Header"),
    loops: Loop.names.map { name in HeatTransferCycle(loop: name) }
  )

  /// The static parameters for the `SolarField`.
  public static var parameter: Parameter = Parameters.sf

  /// Calculates the required mass flow rate of the solar field based on the state of the storage.
  ///
  /// The required mass flow rate is determined based on the relative charge of the storage.
  /// If the storage has a relative charge below the specified charge threshold, an additional
  /// mass flow is added to the required mass flow to ensure proper charging.
  ///
  /// - Parameter storage: The `Storage` instance representing the energy storage system.
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

  mutating func heatLoss(pipe: Temperature, ambient: Temperature) {
    heatLosses += ((pipe.kelvin - ambient.kelvin) / 333) ** 1 * SolarField.parameter.pipeHeatLosses
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

  /// Calculates the efficiency (η) of the solar collector loop.
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

  /// Calculates the inlet temperature of the solar field depending on the operating mode of the storage
  mutating func inletTemperature(from storage: Storage) {
    switch storage.operationMode {
    case .freezeProtection:
      if Storage.parameter.temperatureCharge[1] > 0 {
        inletTemperature(outlet: storage)
      } else {
        temperature.inlet.kelvin = storage.antiFreezeTemperature
      }
    case .preheat:
      temperature.inlet = storage.temperatureTank.cold
    default: break
    }
  }

  /// Calculates the imbalance of mass flow rates in the solar collector loops.
  ///
  /// The imbalance is calculated based on the design parameters and minimum values provided in the `SolarField.parameter` struct.
  ///
  /// - Parameter massFlow: The current mass flow rate in the header of the solar field.
  /// - Returns: An array of `MassFlow` representing the adjusted mass flow rates for each loop in the solar collector system.
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

  /// Calculates the time ratios for linear interpolation of the outlet temperature.
  ///
  /// The time ratios are calculated based on the time remaining in the simulation step and the loop way lengths.
  ///
  /// - Returns: An array of tuples containing the time ratios and their complementary ratios for each loop.
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

  /**
   Calculates the outlet temperature gradient in the solar collector loop.
   
   This private method is responsible for computing the outlet temperature gradient across the solar collector loop based on various parameters and conditions. The function uses the provided `last` cycle and the time since the last calculation to determine the current temperature distribution in the loop.
   
   - Parameters:
     - last: An array containing the temperature information from the last cycle for each loop in the solar collector system. The array holds the temperature data for the `Loop` instances.
     - time: The time since the last calculation in the simulation.
   
   The calculation process involves the following steps:
   1. Retrieve the relevant parameters from the `SolarField` instance, including the maximum mass flow rate, pipe way length, and loop way lengths.
   2. Calculate the flow velocity of the Heat Transfer Fluid (HTF) in the solar collector loop.
   3. Calculate the ratios for the time-based linear interpolation for the outlet temperature using the provided time (`time`) and loop way length.
   4. Determine if the current time falls within the time range that allows for linear interpolation of the outlet temperature. If yes, perform the interpolation and update the outlet temperature for all loops accordingly.
   5. Calculate the linear inlet temperature gradient for each loop based on the way ratio between adjacent loops and the pipe way length.
   6. Calculate the average inlet temperature for each loop using the linear interpolation between the inlet temperature of the current cycle (`inlet`) and the inlet temperature from the `last` cycle.
   7. Calculate the outlet temperature of the header using the average temperatures and flow rates of all loops.
   8. Update the outlet temperature of the header and the inlet temperatures of each loop in the `SolarField` instance (self) based on the calculated temperature gradients and interpolation.
   
   The method modifies the state of the `SolarField` instance (self) by updating the `header.temperature.outlet` and `loops.temperature.inlet` properties with the calculated temperature values. It also relies on the information from the previous cycle (`last`) to perform the interpolation calculations.
   */
  private mutating func outletTemperature(last: [HeatTransferCycle], _ time: Double) {
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

  /// Calculates the parameters and behavior of a solar collector loop.
  ///
  /// This method is responsible for calculating and updating various parameters
  /// and behaviors of a solar collector loop in the solar field. The calculation
  /// is based on the characteristics of the collector, ambient temperature, and
  /// other factors related to the solar field. The method adjusts the mass flow
  /// rate, outlet temperature, and operation mode of the solar collector loop
  /// based on the heat losses, insolation, and other constraints.
  ///
  /// - Parameters:
  ///   - collector: The `Collector` instance representing the specific solar
  ///   collector in the loop.
  ///   - ambient: The `Temperature` object representing the ambient temperature
  ///   in the solar field area.
  ///
  /// The calculation process involves the following steps:
  /// 1. Calculate the insolation for the absorber in the collector and determine
  /// whether it has changed since the last calculation.
  /// 2. Get the elevation of the parabolic trough collector.
  /// 3. Calculate the heat that can be absorbed by the Heat Transfer Fluid (HTF)
  /// per unit mass.
  /// 4. Calculate the heat losses of the Heat Collector Element (HCE) for the
  /// maximum outlet temperature.
  /// 5. Add heat losses of the connecting pipes and apply adjustment factors for
  /// heat loss.
  /// 6. Calculate the available heat (delta heat) per square meter of the
  /// collector area after considering heat losses.
  /// 7. Determine the appropriate mass flow rate of the HTF based on the
  /// available heat.
  /// 8. Check if the calculated mass flow rate falls within acceptable limits
  /// for the loop operation.
  /// 9. Depending on the calculated mass flow, update the operation mode of the
  /// solar collector loop to track the sun, defocus, follow, start up, or
  /// shutdown.
  /// 10. Perform additional checks and adjustments related to elevation,
  /// temperature, and operation mode.
  /// 11. Update the mass flow rates of all loops (near, far, average) based on
  /// the calculated header mass flow rate.
  /// 12. Calculate the outlet temperature of the solar collector loop if the
  /// mass flow rate is positive.
  ///
  /// The method modifies the state of the `SolarField` instance (self) by
  /// updating the `header.massFlow`, `loops`, `operationMode`, and other
  /// relevant properties to reflect the calculated values and behaviors of the
  /// solar collector loop.
  mutating func calculate(collector: Collector, ambient: Temperature) {
    let insolation = collector.insolationAbsorber < collector.lastInsolation
      ? collector.lastInsolation : collector.insolationAbsorber
    let elevation = collector.parabolicElevation

    /// The heat that can be absorbed by the HTF
    let heatPerKgHTF = medium.heatContent(
      medium.maxTemperature, header.temperature.inlet
    )

    /// Heat losses of the HCE for maximum outlet temperature
    heatLossesHCE = HCE.heatLosses(
      inlet: header.temperature.inlet,
      insolation: insolation,
      ambient: ambient
    )

    heatLosses = heatLossesHCE

    /// Average HTF temperature in loop
    let avgT = Temperature.average(medium.maxTemperature, header.temperature.inlet)

    /// Add heat losses of the connecting pipes
    heatLoss(pipe: avgT, ambient: ambient)
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

  /// Applies the heat loss factor for the HCE.
  mutating func heatLosses(hce: Double) {
    heatLosses = hce
    heatLossesHCE = hce
  }
  /// Applies the heat loss factor for the Heat Transfer Fluid (HTF) based on the focus quotient and other parameters.
  ///
  /// - Parameters:
  ///   - inFocus: The focus quotient.
  mutating func factorHeatLossHTF(inFocus: Double) {
    let sof = SolarField.parameter
    let factorHeatLossHTF = Simulation.adjustmentFactor.heatLossHTF
    if sof.heatlossDump == false, sof.heatlossDumpQuad == false {
      heatLosses *= factorHeatLossHTF * inFocus
    } else {
      if sof.heatlossDumpQuad == false {
        heatLosses *= factorHeatLossHTF
      } else if case .H = sof.layout {
        if inFocus > 0.75 { // between 0% and 25% dumping
          heatLosses *= factorHeatLossHTF
        } else if inFocus > 0.5 { // between 25% and 50% dumping
          heatLosses *= factorHeatLossHTF * 0.75
          // 25% of the heat losses can be reduced -> 1 quadrant not in operation
        } else if inFocus > 0.25 { // between 50% and 75% dumping
          heatLosses *= factorHeatLossHTF * 0.5
          // 50% of the heat losses can be reduced -> 1 quadrant not in operation
        } else if inFocus > 0 { // between 75% and 100% dumping
          heatLosses *= factorHeatLossHTF * 0.25
          // 75% of the heat losses can be reduced -> 1 quadrant not in operation
        }
      } else if case .I = sof.layout {
        if inFocus > 0.5 {  // between 0% and 50% dumping
          heatLosses *= factorHeatLossHTF
        } else if inFocus > 0 { // between 50% and 100% dumping
          heatLosses *= factorHeatLossHTF * 0.5
          // 50% of the heat losses can be reduced -> 1/2 SF not in operation
        }
      }
    }
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
