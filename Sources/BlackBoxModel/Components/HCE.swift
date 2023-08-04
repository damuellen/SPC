// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import Meteo
import Utilities

/**
  Modes of operation for the Heat Collector Element (HCE).
  
  - Mode 1: Calculates the right mass-flow to get the maximum allowed HTF (Heat Transfer Fluid) outlet temperature of the HCE-loop.
    The time of HTF being in the HCE-loop is calculated, and defocus is automatically applied to prevent overheating HCEs.
  
  - Mode 2: Mass-flow is fixed externally. It calculates the HTF outlet temperature of the HCE-loop and the time of HTF being in the HCE-loop.
    If mass-flow is set to 0, it calculates, by heat losses, the HTF temperature in the HCE after the specified Actime minutes.
  
  - Actime: The time duration for certain calculations.
    - If Mode 1 is active, Actime has no meaning.
    - If Mode 2 is active and massFlow == 0, SF (Solar Field) calculates Actime based on the heat losses in the HCEs.
    - If Actime > 0 and Mode 2 is active, HCE calculates the time of HTF being in HCEs minus Actime.
  */
enum HCE {
  /**
   Calculates the radiation losses per square meter of Aperture considering the percentage of HCE that are broken, lost vacuum, and fluorescent.

   - Parameters:
     - temperatures: A tuple containing the temperatures (inlet, outlet, ambient) in Kelvin.
     - insolation: The insolation in W/m2.

   - Returns: The radiation losses per square meter of Aperture in W/m2.
   */
  static func radiationLossesOld(
    _ temperatures: (Temperature, Temperature, Temperature), insolation: Double)
    -> Double // [W/m2]
  {
    let (t1, t2) = (temperatures.0.kelvin, temperatures.1.kelvin)
    /// Design parameter of collector
    let col = Collector.parameter
    /// Aperture width of the collector
    let aperture = col.aperture
    /// Absorber emittance
    let emissionHCE = Collector.parameter.emissionHCE
    /// Current availability values
    let value = Availability.current.value
    /// Average share of Broken HCEs
    let breakHCE = value.breakHCE.quotient
    /// Average share of HCEs with Lost Vacuum
    let airHCE = value.airHCE.quotient
    /// Average share of Flourescent HCE
    let fluorHCE = value.fluorHCE.quotient

    let dT = t1 - t2 + 10.0

    var vacuumHeatLoss: Double
    let endLossFactor: Double

    let sigma = 0.00000005667
    let circumference = 2 * .pi * col.rabsOut
    let dT2 = dT * dT

    if col.name.hasPrefix("SKAL-ET") {
      // temperature.0+10 considers that average loop temperature is higher than (T_in + T_out)/2
      vacuumHeatLoss = sigma * circumference * (t1 * t1 * t1 * t1 - t2 * t2 * t2 * t2)
      vacuumHeatLoss *= (emissionHCE[0] + emissionHCE[1] * t1) / aperture
      let al = 0.7 * circumference * (t1 - t1) / aperture
      vacuumHeatLoss = vacuumHeatLoss + al // added here and not for LS2 collector
      endLossFactor = 1 // added in order to differenciate with LS2 collector
    } else if col.name.hasPrefix("LS2") {
      vacuumHeatLoss = 0.081 - 0.04752 * dT + 0.0006787 * dT2 + 0.0007403 * insolation
      vacuumHeatLoss += 0.00003582 * dT * insolation + 0.00000014125 * dT2 * insolation
      endLossFactor = 1.3
    } else if col.name.hasPrefix("PCT_validation") { // test
      vacuumHeatLoss = sigma * circumference * (t1 * t1 * t1 * t1 - t2 * t2 * t2 * t2)
      vacuumHeatLoss *= (emissionHCE[0] + emissionHCE[1] * (t1 + 10)) / aperture
      endLossFactor = 1.3 // added in order to differenciate with LS2 collector
    } else {
      // other types than LS-2!!
      // old RadLoss as from LUZ Model
      // temperature.0+10 considers that average loop temperature is higher than (T_in + T_out)/2
      switch col.absorber {
      case .schott:
        vacuumHeatLoss = sigma * circumference * (t1 ** 4 - t2 * t2 * t2 * t2)
        vacuumHeatLoss *= (emissionHCE[0] + emissionHCE[1] * (t1 + 10)) / aperture
      case .rio:
        vacuumHeatLoss = (0.00001242 * t1 * t1 * t1 - 0.01864091
          * t1 * t1 + 9.76467705 * t1 - 1714.03)
        vacuumHeatLoss *= circumference / aperture
      }
      // these losses were somehow lower than vacuumHeatLoss used below, but only about 10%
      let al = 0.7 * circumference * (t1 - t2) / aperture
      vacuumHeatLoss += al // added here and not for LS2 collector
      endLossFactor = 1
    }

    var RLHP: Double = 0.081 - 0.04752 * dT + 0.0006787 * dT2 + 0.0007403 * insolation
    RLHP += 3.582e-05 * dT2 * insolation + 1.4125e-07 * dT2 * insolation

    var addHLAir: Double = -0.114 + 0.1396 * dT + 0.000006823 * dT2 - 0.002074 * insolation
    addHLAir += 0.0000602 * dT * insolation - 0.0000001624 * dT2 * insolation

    let addHLBare: Double = 0.416 * dT - 0.000056 * dT2 + 0.0666 * dT // * windSpeed

    var losses = vacuumHeatLoss
    losses += addHLAir * (airHCE + fluorHCE)
    losses += addHLBare * breakHCE 

    return losses * endLossFactor
  }
  
  /**
   Calculates the radiation losses per square meter of Aperture considering the percentage of HCE that are broken, lost vacuum, and fluorescent.

   - Parameters:
     - temperatures: A tuple containing the temperatures (inlet, outlet, ambient) in Kelvin.
     - insolation: The insolation in W/m2.

   - Returns: The radiation losses per square meter of Aperture in W/m2.
   */
  static func radiationLossesNew(
    _ temperatures: (Temperature, Temperature, Temperature), insolation: Double)
    -> Double // [W/m2]
  {
    var (t1, t2) = (temperatures.0.kelvin, temperatures.1.kelvin)
    let avgT = (t1 + t2) / 2.0
    let ambT = temperatures.2.kelvin + 20

    let dT = (t1 + t2) / 2 - ambT
    /// Outer radius of HCE
    let rabsOut = Collector.parameter.rabsOut
    /// Radius of glass cover tube
    let rglas = Collector.parameter.rglas
    /// Coating emittance coefficient
    let glassEmission = Collector.parameter.glassEmission
    /// Aperture width of the collector
    let aperture = Collector.parameter.aperture
    /// Absorber emittance
    let emissionHCE = Collector.parameter.emissionHCE
    /// Current availability
    let value = Availability.current.value
    /// Average share of Broken HCEs
    let breakHCE = value.breakHCE.quotient
    /// Average share of HCEs with Lost Vacuum
    let airHCE = value.airHCE.quotient
    /// Average share of Flourescent HCE
    let fluorHCE = value.fluorHCE.quotient

    var vacuumHeatLoss: Double
    let endLossFactor: Double

    let sigma = 0.00000005667
    let circumference = 2 * .pi * rabsOut 

    if t1 == t2 { t2 *= 0.999 }
    let Ebs_HCE = 
      ( 1 / 3 * emissionHCE[2] * (t1 * t1 * t1 - t2 * t2 * t2) 
      + 1 / 2 * emissionHCE[1] * (t1 * t1 - t2 * t2)
      + emissionHCE[0] * (t1 - t2) ) / (t1 - t2)

    if t1 != t2 {
      vacuumHeatLoss = sigma / (1 / Ebs_HCE + rabsOut / rglas 
        * (1 / glassEmission - 1)) * circumference / aperture 
        * (1 / 5 * (t1 * t1 * t1 * t1 * t1 - t2 * t2 * t2 * t2 * t2)
          + ambT * ambT * ambT * ambT * (t2 - t1)) / (t1 - t2)
    } else {
      vacuumHeatLoss = sigma * circumference
      vacuumHeatLoss *= avgT * avgT * avgT * avgT - ambT * ambT * ambT * ambT
      vacuumHeatLoss *= (emissionHCE[0] + emissionHCE[1] * t2) / aperture
    }

    let al = 0.7 * circumference * (avgT - ambT) / aperture
    vacuumHeatLoss += al
    endLossFactor = 1

    let dT2 = dT * dT
    var RLHP: Double = 0.081 - 0.04752 * dT + 0.0006787 * dT2 + 0.0007403 * insolation
    RLHP += 3.582e-05 * dT * insolation + 1.4125e-07 * dT2 * insolation

    var addHLAir: Double = -0.114 + 0.1396 * dT + 0.000006823 * dT2 - 0.002074 * insolation
    addHLAir += 0.0000602 * dT * insolation - 0.0000001624 * dT2 * insolation

    let addHLBare: Double = 0.416 * dT - 0.000056 * dT2 + 0.0666 * dT * 3// * windSpeed

    var losses = vacuumHeatLoss
    losses += addHLAir * (airHCE + fluorHCE)
    losses += addHLBare * breakHCE 

    return losses * endLossFactor
  }

  /**
   Calculates the heat losses through the Heat Collector Element (HCE).

   - Parameters:
     - inlet: The inlet temperature of the HCE in Kelvin.
     - outlet: The outlet temperature of the HCE in Kelvin (default value: maximum allowed HTF temperature).
     - insolation: The insolation in W/m2.
     - ambient: The ambient temperature in Kelvin.

   - Returns: The heat losses through the HCE in W/m2.
   */
  static func heatLosses(
    inlet: Temperature,
    outlet: Temperature = SolarField.parameter.HTF.maxTemperature,
    insolation: Double,
    ambient: Temperature
  ) -> Double {
    // Check if the integral radial loss is being used
    let useIntegralRadialoss = Collector.parameter.useIntegralRadialoss
    
    // Define the temperatures based on whether integral radial loss is used or not
    let temperatures = useIntegralRadialoss
      ? (outlet, inlet, ambient)
      : (Temperature.average(outlet, inlet), ambient + 20.0, 0.0)

    // Choose the appropriate radiation loss function based on the integral radial loss
    let radiaLoss = useIntegralRadialoss
      ? HCE.radiationLossesNew
      : HCE.radiationLossesOld

    // Calculate heat losses using the selected radiation loss function
    var heatLossesHCE = radiaLoss(temperatures, insolation)
    heatLossesHCE *= Simulation.adjustmentFactor.heatLossHCE
    return heatLossesHCE
  }

  /**
   Calculates the temperatures of the Heat Collector Element (HCE) based on fluid properties and other parameters.

   - Parameters:
     - solarField: The solar field instance (inout) to be used for calculations.
     - loop: The loop of the solar field.
     - insolation: The insolation in W/m2.
     - ambient: The ambient temperature in Kelvin.

   - Returns: The time interval for the iteration.
   */
  static func temperatures(
    _ solarField: inout SolarField,
    _ loop: SolarField.Loop,
    _ insolation: Double,
    _ ambient: Temperature
  ) -> Double {
    /// Fluid properties
    let htf = SolarField.parameter.HTF
    
    // Calculate the cross-sectional areas of the HCE
    let areaInner = .pi * Collector.parameter.rabsInner ** 2
    let areaOut = .pi * Collector.parameter.rabsOut ** 2
    
    /// Aperture width of the collector
    let aperture = Collector.parameter.aperture
    
    /// HCE specific heat per kg
    let specificHeatHCE = 0.49
    
    /// Specific mass of steel
    let densityHCE = 7870.0
    
    /// HCE density per square meter
    let areaDensityHCE = densityHCE * (areaOut - areaInner) / aperture
    
    /// The predefined availability of the solar field
    let availability = Availability.current.value.solarField.quotient

    /// Initialize time interval for the iteration
    var time = Simulation.time.steps.interval

    // Retrieve the HCE for the specified loop from the solar field
    var hce = solarField.loops[loop.rawValue]
    defer { solarField.loops[loop.rawValue] = hce }

    // Get the maximum temperature for the HTF (Heat Transfer Fluid)
    let maxTemp = htf.maxTemperature
    var goal = hce.temperature.outlet

    // Get the focus quotient of the solar field
    var inFocus = solarField.inFocus.quotient

    // Function to check the termination conditions for the iteration
    func checkConditions() -> Bool {
      if hce.temperature.outlet.kelvin > 0.997 * maxTemp.kelvin { return true }
      if inFocus.isZero || inFocus > 0.95 { return true }
      return false
    }

    // Iteration loop for the temperature calculation
    Iteration: for _ in 1...10 {
      // Calculate the heat input based on insolation, focus quotient, and solar field availability
      let heatInput = insolation * inFocus * availability

      // Calculate the heat losses of the HCE for the current outlet temperature
      solarField.heatLosses(hce: HCE.heatLosses(
        inlet: hce.temperature.inlet,
        outlet: hce.temperature.outlet,
        insolation: insolation,
        ambient: ambient
      ))

      // If there is mass flow in the HCE, consider additional heat loss through the pipe
      if hce.massFlow > .zero {
        solarField.heatLoss(pipe: hce.average, ambient: ambient)
      }

      // If there is heat input, apply adjustment factor to the solar field heat losses
      if heatInput > .zero {
        solarField.factorHeatLossHTF(inFocus: inFocus)
      }

      // Calculate the net deltaHeat (+ or -) in the HCE
      let deltaHeat = heatInput - solarField.heatLosses

      // Calculate the mass of HTF per square meter
      let areaDensityHTF = htf.density(hce.average) * areaInner / aperture

      // If there is mass flow in the HCE, calculate the time interval for the iteration
      if hce.massFlow > .zero {
        time = (areaDensityHTF * solarField.area) / hce.massFlow.rate
      }

      // Calculate the heat collected or lost during the flow through a whole loop [kJ/sqm]
      let deltaHeatPerSqm = deltaHeat * time / 1_000

      // Change kJ/sqm to kJ/kg
      let deltaHeatPerKgHTF = deltaHeatPerSqm / areaDensityHTF

      // If there is no mass flow in the HCE, perform calculations based on HCE properties
      if hce.massFlow.rate.isZero {
        let cp = specificHeatHCE
        let HCE = (cp * hce.average.kelvin) - (cp * ambient.kelvin)
        let HTF = htf.heatContent(hce.average, ambient)
        let ratio =  1 / ((HTF * areaDensityHTF) / (HCE * areaDensityHCE))
        let deltaHeatPerKgHCE = deltaHeatPerKgHTF * ratio 
        hce.temperature.inlet = htf.temperature(
          deltaHeatPerKgHTF - deltaHeatPerKgHCE, hce.temperature.inlet
        )
        hce.temperature.outlet = htf.temperature(
          deltaHeatPerKgHTF - deltaHeatPerKgHCE, hce.temperature.outlet
        )
        // Exit the iteration loop for mass flow rate is zero
        break Iteration
      } else {
        // If there is mass flow, calculate the outlet temperature of the HCE
        hce.temperature.outlet = htf.temperature(
          deltaHeatPerKgHTF, hce.temperature.inlet
        )
      }

      // Limit the outlet temperature to the maximum temperature allowed
      hce.temperature.outlet.limit(to: maxTemp)

      // Check if the current outlet temperature is within tolerance and termination conditions are met
      let inTolerance = abs(hce.temperature.outlet.kelvin - goal.kelvin) 
        < Simulation.parameter.tempTolerance
      if inTolerance, checkConditions() { break Iteration } 

      // Update the goal temperature for the next iteration
      goal = hce.temperature.outlet

      // If termination conditions are not met, adjust the focus quotient
      if !checkConditions() { inFocus = min(1, inFocus * 1.01) }

      // Optional dumping logic commented out for future reference
      // dumping = hce.temperature.outlet > maxTemp
      //  ? (hce.massFlow.rate / 3 * htf.heatContent(hce.temperature.outlet, maxTemp) * 1_000)
      //  : 0.0 // MWt
    }
    
    // Return the time interval for the iteration
    return time
  }
}
