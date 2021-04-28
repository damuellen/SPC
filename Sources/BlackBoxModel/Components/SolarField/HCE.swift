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
import PhysicalQuantities

let period = 300
/**
 # HCE  Heat Collecting Element
 
 - Mode 1:
 Calculate the right mass-flow to get maximum allowed HTF-outlet temp.
 of the HCE-loop, and the time of HTF being in the HCE-loop. defocus
 automatically not to overheat HCEs.
 
 - Mode 2:
 Mass-flow is fixed outside. Calculate the HTF-outlet temp. of the HCE-loop
 and the time of HTF being in the HCE-loop. If mass-flow is set to 0,
 calculate by heat losses the HTF-temp. in the HCE after Actime minutes.
 
 ## Actime: [minutes]
 if Mode 1 then Actime has no meaning.
 if Mode 2 and massFlow == 0 SF calculates Actime the heat losses in the HCEs.
 if Actime > 0 then HCE calculates the time of HTF being in HCEs minus Actime
 
 ## Actime: [sec]
 if massFlow > 0 then Actime is the time the HTF was in the HCEs.
 if Mode 2 and massFlow == 0 then Actime is the time the losses were
 calculated. Not necessary equal to Actime from input, cause calculation
 stops when temperature at outlet goes under
 freezeTemperature + Sim.deltaTemperaturefrzPump
 */
enum HCE {
  // Radiation losses per m2 Aperture; now with the new losses that take into
  // account the percentage of HCE that are broken, lost vacuum and fluorescent
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
  // Radiation losses per m2 Aperture; now with the new losses that take into
  // account the percentage of HCE that are broken, lost vacuum and fluorescent
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

  static func heatLosses(
    inlet: Temperature,
    outlet: Temperature = SolarField.parameter.HTF.maxTemperature,
    insolation: Double,
    ambient: Temperature
  ) -> Double {
    let useIntegralRadialoss = Collector.parameter.useIntegralRadialoss

    let temperatures = useIntegralRadialoss
      ? (outlet, inlet, ambient)
      : (Temperature.average(outlet, inlet), ambient + 20.0, 0.0)

    let radiaLoss = useIntegralRadialoss
      ? HCE.radiationLossesNew : HCE.radiationLossesOld

    var heatLossesHCE = radiaLoss(temperatures, insolation)
    heatLossesHCE *= Simulation.adjustmentFactor.heatLossHCE
    return heatLossesHCE
  }

  /// HTF temperature dependent on constant mass flow
  static func temperatures(
    _ solarField: inout SolarField,
    _ loop: SolarField.Loop,
    _ insolation: Double,
    _ ambient: Temperature
  ) -> Double {
    /// Fluid properties
    let htf = SolarField.parameter.HTF
    /// Inner cross-sectional area of HCE
    let areaInner = .pi * Collector.parameter.rabsInner ** 2
    /// Outer cross-sectional area of HCE
    let areaOut = .pi * Collector.parameter.rabsOut ** 2
    /// Aperture width of the collector
    let aperture = Collector.parameter.aperture
    /// HCE specific heat per kg 
    let specificHeatHCE = 0.49
    /// Specific mass of steel
    let densityHCE = 7870.0
    /// HCE density per square metre 
    let areaDensityHCE = densityHCE * (areaOut - areaInner) / aperture
    /// The predefined availability of the solar field
    let availability = Availability.current.value.solarField.quotient

    var time = Simulation.time.steps.interval

    var hce = solarField.loops[loop.rawValue]
    defer { solarField.loops[loop.rawValue] = hce }

    let maxTemp = htf.maxTemperature
    var goal = hce.temperature.outlet

    var inFocus = solarField.inFocus.quotient

    func checkConditions() -> Bool {
      if hce.temperature.outlet.kelvin > 0.997 * maxTemp.kelvin { return true }
      if inFocus.isZero || inFocus > 0.95 { return true }
      return false
    }

    Iteration: for _ in 1...10 {

      let heatInput = insolation * inFocus * availability

      /// Heat losses of the HCE for current outlet temperature
      solarField.heatLossesHCE = HCE.heatLosses(
        inlet: hce.temperature.inlet,
        outlet: hce.temperature.outlet,
        insolation: insolation,
        ambient: ambient
      )

      solarField.heatLosses = solarField.heatLossesHCE

      if hce.massFlow > .zero {
        solarField.heatLosses += SolarField.pipeHeatLoss(pipe: hce.average, ambient: ambient)
        solarField.heatLosses *= Simulation.adjustmentFactor.heatLossHTF
      }

      if heatInput > .zero {
        factorHeatLossHTF(solarField: &solarField, inFocus: inFocus)
      }

      // Net deltaHeat (+)=in or (-)=out HCE
      let deltaHeat = heatInput - solarField.heatLosses

      /// Mass of HTF per square metre
      let areaDensityHTF = htf.density(hce.average) * areaInner / aperture

      if hce.massFlow > .zero {
        time = (areaDensityHTF * solarField.area) / hce.massFlow.rate
      } 

      /// Heat collected or lost during the flow through a whole loop [kJ/sqm]
      let deltaHeatPerSqm = deltaHeat * time / 1_000

      // Change kJ/sqm to kJ/kg:
      let deltaHeatPerKgHTF = deltaHeatPerSqm / areaDensityHTF

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
        break Iteration
      } else {
        hce.temperature.outlet = htf.temperature(
          deltaHeatPerKgHTF, hce.temperature.inlet
        )
      }

      hce.temperature.outlet.limit(to: maxTemp)
      let inTolerance = abs(hce.temperature.outlet.kelvin - goal.kelvin) 
        < Simulation.parameter.tempTolerance
      if inTolerance, checkConditions() { break Iteration } 
      goal = hce.temperature.outlet

      if !checkConditions() { inFocus = min(1, inFocus * 1.01) }
      // Flow is to low, dumping required
      // dumping = hce.temperature.outlet > maxTemp
      //  ? (hce.massFlow.rate / 3 * htf.heatContent(hce.temperature.outlet, maxTemp) * 1_000)
      //  : 0.0 // MWt
    }
    return time
  }

  static func factorHeatLossHTF(solarField: inout SolarField, inFocus: Double) {
    let sof = SolarField.parameter
    let factorHeatLossHTF = Simulation.adjustmentFactor.heatLossHTF
    if sof.HLDump == false, sof.HLDumpQuad == false {
      solarField.heatLosses *= factorHeatLossHTF * inFocus
    } else {
      if sof.HLDumpQuad == false {
        solarField.heatLosses *= factorHeatLossHTF
      } else if case .H = sof.layout {
        if inFocus > 0.75 { // between 0% and 25% dumping
          solarField.heatLosses *= factorHeatLossHTF
        } else if inFocus > 0.5 { // between 25% and 50% dumping
          solarField.heatLosses *= factorHeatLossHTF * 0.75
          // 25% of the heat losses can be reduced -> 1 quadrant not in operation
        } else if inFocus > 0.25 { // between 50% and 75% dumping
          solarField.heatLosses *= factorHeatLossHTF * 0.5
          // 50% of the heat losses can be reduced -> 1 quadrant not in operation
        } else if inFocus > 0 { // between 75% and 100% dumping
          solarField.heatLosses *= factorHeatLossHTF * 0.25
          // 75% of the heat losses can be reduced -> 1 quadrant not in operation
        }
      } else if case .I = sof.layout {
        if inFocus > 0.5 {  // between 0% and 50% dumping
          solarField.heatLosses *= factorHeatLossHTF
        } else if inFocus > 0 { // between 50% and 100% dumping
          solarField.heatLosses *= factorHeatLossHTF * 0.5
          // 50% of the heat losses can be reduced -> 1/2 SF not in operation
        }
      }
    }
  }
}
