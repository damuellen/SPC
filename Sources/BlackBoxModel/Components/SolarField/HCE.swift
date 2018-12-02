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
 if Actime < 0 then HCE calculates the time of HTF being in HCEs minus Actime
 
 ## Actime: [sec]
 if massFlow > 0 then Actime is the time the HTF was in the HCEs.
 if Mode 2 and massFlow == 0 then Actime is the time the losses were
 calculated. Not necessary equal to Actime from input, cause calculation
 stops when temperature at outlet goes under
 freezeTemperature + Sim.deltaTemperaturefrzPump
 */
enum HCE {
  @discardableResult
  static func calculation(_ solarField: inout SolarField.PerformanceData,
                          collector: Collector.PerformanceData,
                          loop: SolarField.Loop, mode: Collector.OperationMode,
                          meteo: MeteoData) -> (Double, Double)
  {
    switch mode {
    case .fixed:
      return mode2(&solarField, collector, loop, meteo)
    case .noOperation:
      //period = 300
      freezeProtectionCheck(&solarField)
      return mode2(&solarField, collector, loop, meteo)
    case .operating:
      //period = 300
      if meteo.windSpeed > SolarField.parameter.maxWind {
        solarField.inFocus = 0.0
      }
      return mode1(&solarField, collector, loop, meteo)

    case .freezeProtection, .variable:
      if meteo.windSpeed > SolarField.parameter.maxWind
        || solarField.insolationAbsorber < Simulation.parameter.minInsolation
      {
        freezeProtectionCheck(&solarField)
        return mode2(&solarField, collector, loop, meteo)
      } else {
        return mode1(&solarField, collector, loop, meteo)
      }
    }
    
  }

  static func freezeProtectionCheck(
    _ solarField: inout SolarField.PerformanceData) {
    let freezingTemperature = SolarField.parameter.HTF.freezeTemperature
      + Simulation.parameter.dfreezeTemperaturePump
      + Simulation.parameter.tempTolerance

    if solarField.header.temperature.inlet < freezingTemperature
      || solarField.header.temperature.outlet < freezingTemperature
    {
      solarField.header.massFlow = SolarField.parameter.antiFreezeFlow
      solarField.operationMode = .freezeProtection
    } else {
      solarField.operationMode = .noOperation
      // status = LastHTF
      solarField.header.massFlow = 0.0
    }
    solarField.inFocus = 0.0
  }
  /// Memory to speed up the calculation
  static private let memorizedRadiationLosses = Cache<Double>()

  // Radiation losses per m2 Aperture; now with the new losses that take into
  // account the percentage of HCE that are broken, lost vacuum and fluorescent
  private static func radiationLosses(
    _ temperature1: Temperature, _ temperature2: Temperature,
    collector: Collector.PerformanceData, meteo: MeteoData
    ) -> Double
  {
    let irradianceCosTheta = Double(meteo.dni) * collector.cosTheta
    /// Insolation to Absorber!
    let insolation = irradianceCosTheta * collector.efficiency
/*
    var hasher = Hasher()
    hasher.combine(meteo.temperature)
    hasher.combine(temperature1.kelvin)
    hasher.combine(temperature2.kelvin)
    hasher.combine(insolation)
    let hash = hasher.finalize()
    
    if let result = memorizedRadiationLosses.lookupResult(for: hash) {
      return result
    }*/

    let (t1, t2) = (temperature1.kelvin, temperature2.kelvin)
    let col = Collector.parameter
    let ambientTemperature = Double(meteo.temperature)
    let averageTemperature = (t1 + t2) / 2
    let availability = Availability.current.value
    let breakHCE = availability.breakHCE.ratio
    let airHCE = availability.airHCE.ratio
    let fluorHCE = availability.fluorHCE.ratio

    let deltaT: Double
    if col.newFunction {
      deltaT = ((t1 + t2) / 2)
        - (ambientTemperature + 30.0) + 10.0
    } else {
      deltaT = t1 - t2 + 10.0
    }

    var vacuumHeatLoss: Double
    let endLossFactor: Double

    let sigma = 0.00000005667

    if col.newFunction == false {
      if col.name.hasPrefix("SKAL-ET") {
        // temperature.0+10 considers that average loop temperature is higher than (T_in + T_out)/2
        vacuumHeatLoss = sigma * 2 * .pi * col.rabsOut
          * (t1 ** 4 - t2 ** 4)
        vacuumHeatLoss *= (col.emissionHCE[0]
          + col.emissionHCE[1] * t1) / col.aperture
        let al = 0.7 * 2 * .pi * col.rabsOut
          * (t1 - t1) / col.aperture
        vacuumHeatLoss = vacuumHeatLoss + al // added here and not for LS2 collector
        endLossFactor = 1 // added in order to differenciate with LS2 collector
      } else if col.name.hasPrefix("LS2") {
        vacuumHeatLoss = 0.081 - 0.04752 * deltaT
          + 0.0006787 * deltaT ** 2 + 0.0007403 * insolation
        vacuumHeatLoss += 0.00003582 * deltaT * insolation
          + 0.00000014125 * deltaT ** 2 * insolation
        endLossFactor = 1.3
      } else if col.name.hasPrefix("PCT_validation") { // test
        vacuumHeatLoss = sigma * 2 * .pi * col.rabsOut
          * (t1 ** 4 - t2 ** 4)
        vacuumHeatLoss *= (col.emissionHCE[0] + col.emissionHCE[1]
          * (t1 + 10)) / col.aperture
        endLossFactor = 1.3 // added in order to differenciate with LS2 collector
      } else {
        // other types than LS-2!!
        // old RadLoss as from LUZ Model
        // temperature.0+10 considers that average loop temperature is higher than (T_in + T_out)/2
        switch col.absorber {
        case .schott:
          vacuumHeatLoss = sigma * 2 * .pi * col.rabsOut
            * (t1 ** 4 - t2 ** 4)
          vacuumHeatLoss *= (col.emissionHCE[0]
            + col.emissionHCE[1] * (t1 + 10)) / col.aperture
        case .rio:
          vacuumHeatLoss = (0.00001242 * t1 ** 3 - 0.01864091
            * t1 ** 2 + 9.76467705 * t1 - 1714.03)
          vacuumHeatLoss *= 2 * .pi * col.rabsOut / col.aperture
        }
        // these losses were somehow lower than vacuumHeatLoss used below, but only about 10%
        let al = 0.7 * 2 * .pi * col.rabsOut * (t1 - t2) / col.aperture
        vacuumHeatLoss += al // added here and not for LS2 collector
        endLossFactor = 1
      }
    } else {
      // new formula from Jan Felinks.
      // IMPORTANT: definition of temperature.0 and temperature.1
      // changed to use new radiation loss formula
      // E_a = 0.0000002: E_b = -0.0001: E_c = 0.0769
      let Ebs_HCE: Double
      if temperature1 != temperature2 {
        // check what if temperature.1 < temperature.0?!
        Ebs_HCE = (1 / 3 * col.emissionHCE[1]
          * (t1 ** 3 - t2 ** 3) + 1 / 2
          * col.emissionHCE[1] * (t1 ** 2 - t2 ** 2)
          + col.emissionHCE[0] * (t1 - t2)) / (t1 - t2)
      } else { // during FP?
        // check, resulting emissivity too low without c2!
        Ebs_HCE = col.emissionHCE[0]
          + col.emissionHCE[1] * t1
      }

      if temperature1 != temperature2 {
        vacuumHeatLoss = sigma / (1 / Ebs_HCE + col.rabsOut
          / col.rglas * (1 / col.glassEmission - 1))
          * 2 * .pi * col.rabsOut / col.aperture
          * (1 / 5 * (t1 ** 5 - t2 ** 5) + (ambientTemperature + 30) ** 4
            * (t2 - t1)) / (t1 - t2)
      } else {
        vacuumHeatLoss = sigma * 2 * .pi * col.rabsOut
        vacuumHeatLoss *= averageTemperature ** 4
          - (ambientTemperature + 30) ** 4
        vacuumHeatLoss *= (col.emissionHCE[0]
          + col.emissionHCE[1] * t2) / col.aperture
      }
      var al = 0.7 * 2 * .pi * col.rabsOut
      al *= (averageTemperature - (ambientTemperature + 30))
        / col.aperture
      vacuumHeatLoss += al
      endLossFactor = 1
    }

    var RLHP: Double = 0.081 - 0.04752 * deltaT
      + 0.0006787 * deltaT ** 2 + 0.0007403 * insolation
    RLHP += 3.582e-05 * deltaT * insolation
      + 1.4125e-07 * deltaT ** 2 * insolation

    var addHLAir: Double = -0.114 + 0.1396 * deltaT
      + 0.000006823 * deltaT ** 2 - 0.002074 * insolation
    addHLAir += 0.0000602 * deltaT * insolation
      - 0.0000001624 * deltaT ** 2 * insolation

    let addHLBare: Double = 0.416 * deltaT
      - 0.000056 * deltaT ** 2
      + 0.0666 * deltaT // * windSpeed
    let losses = (vacuumHeatLoss + addHLAir * (airHCE + fluorHCE)
      + addHLBare * breakHCE) * endLossFactor
  //  memorizedRadiationLosses.update(hash: hash, result: losses)
    return losses
    // * 1.3
    // Faktor 1.3 due to end HCE end losses
    // "* endLossFactor" added in order to differenciate with LS2 collector
  }

  /// Vary mass-flow to maintain optimum HTF-temp.
  private static func mode1(_ solarField: inout SolarField.PerformanceData,
                            _ collector: Collector.PerformanceData,
                            _ loop: SolarField.Loop,
                            _ meteo: MeteoData) -> (Double, Double)
  {
    let sof = SolarField.parameter
    let htf = sof.HTF
    let col = Collector.parameter
    var time = 0.0
    var dumping = 0.0
    var hce = solarField.loops[loop.rawValue]
    defer { solarField.loops[loop.rawValue] = hce }

    let ambientTemperature = Plant.ambientTemperature
    // Average HTF temp. in loop [K]
    var averageTemperature = Temperature.average(
      htf.maxTemperature, hce.temperature.inlet
    )
    solarField.heatLossHCE = col.useIntegralRadialoss
      ? radiationLosses(averageTemperature, ambientTemperature + 20.0,
                        collector: collector, meteo: meteo)
      : radiationLosses(htf.maxTemperature + 10.0, hce.temperature.inlet + 10.0,
                        collector: collector, meteo: meteo)
    
    solarField.heatLossHCE *= Simulation.adjustmentFactor.heatLossHCE
    solarField.heatLosses = solarField.heatLossHCE
      + SolarField.pipeHeatLoss(pipe: averageTemperature,
                                ambient: ambientTemperature)
    solarField.heatLosses *= Simulation.adjustmentFactor.heatLossHTF

    var deltaHeat = solarField.insolationAbsorber
    deltaHeat *= Availability.current.value.solarField.ratio
    deltaHeat -= solarField.heatLosses
    let irradianceCosTheta = collector.cosTheta * Double(meteo.dni)
    if irradianceCosTheta > 0 {
      solarField.loopEta = collector.efficiency - solarField.heatLossHCE
        / irradianceCosTheta
      solarField.ETA = collector.efficiency - solarField.heatLosses
        / irradianceCosTheta
    } else {
      solarField.loopEta = 0
      solarField.ETA = 0
    }
    
    /// Calculate appropriate mass-flow [kg/(sec sqm)]
    let ratio = abs(deltaHeat) / 1_000 / htf.addedHeat(
      htf.maxTemperature, hce.temperature.inlet
    )

    hce.massFlow(rate: ratio * solarField.area)

    switch hce.massFlow { // Check if mass-flow is within acceptable limits
    case let massFlow where massFlow.rate <= 0: // HCE loses heat

      if case .freezeProtection = solarField.operationMode {
        hce.massFlow = sof.massFlow.min
        (time, dumping) = mode2(&solarField, collector, loop, meteo)
      } else {
        // status = LastHTF
        freezeProtectionCheck(&solarField)
        (time, dumping) = mode2(&solarField, collector, loop, meteo)
      }

    case let massFlow where massFlow > sof.massFlow.max:
      // Damped heat: The HL have to be added because they are independent from
      // the SCAs in focus. HL must be subtracted afterwards again.
      solarField.inFocus = Ratio(sof.massFlow.max.rate / massFlow.rate)
      // [MW] added to calculate Q_dump with instantaneous irradiation

      dumping = deltaHeat * solarField.area * (1 - solarField.inFocus.ratio)

      hce.massFlow = sof.massFlow.max
      hce.temperature.outlet = htf.maxTemperature

      let areaDensity = htf.density(hce.averageTemperature)
        * .pi * col.rabsOut ** 2 / col.aperture

      time = (areaDensity * solarField.area / hce.massFlow.rate)

     // time = period

    case let massFlow where massFlow < sof.massFlow.min:

      if case .normal = solarField.operationMode,
        massFlow.rate > sof.massFlow.max.rate * 0.05 {
        // pumps are working over massFlow.min
        solarField.inFocus = 1.0
        hce.massFlow = massFlow
        hce.temperature.outlet = htf.maxTemperature
        // changed to htf.maxTemperature to reach max temp possible
        averageTemperature = hce.averageTemperature

        let areaDensity = htf.density(averageTemperature)
          * .pi * col.rabsOut ** 2 / col.aperture

        time = (areaDensity * solarField.area / hce.massFlow.rate) // [sec]

      //  time = period
      } else if case .normal = solarField.operationMode {
        solarField.inFocus = 1.0
        hce.massFlow = sof.massFlow.max.adjusted(withFactor: 0.05)
        (time, dumping) = mode2(&solarField, collector, loop, meteo)
      } else {
        solarField.inFocus = 1.0
        hce.massFlow = sof.massFlow.min
        (time, dumping) = mode2(&solarField, collector, loop, meteo)
      }

    default: // MassFlow is within acceptable limits and Tout is as required
      solarField.inFocus = 1.0
      // FIXME: status.massFlow = massFlow
      // changed to htf.maxTemperature to reach max temp possible
      hce.temperature.outlet = SolarField.parameter.HTF.maxTemperature
      averageTemperature = hce.averageTemperature

      solarField.operationMode = .operating

      let areaDensity = htf.density(averageTemperature)
        * .pi * col.rabsOut ** 2 / col.aperture
      time = (areaDensity * solarField.area / hce.massFlow.rate)
    }
    /// Residence time [sec]
    return (time, dumping)
  }

  /// HTF-temp. dependent on constant mass-flow
  private static func mode2(_ solarField: inout SolarField.PerformanceData,
                            _ collector: Collector.PerformanceData,
                            _ loop: SolarField.Loop,
                            _ meteo: MeteoData) -> (Double, Double)
  {
    let sof = SolarField.parameter
    let htf = sof.HTF
    let col = Collector.parameter
    var time = 0.0
    var dumping = 0.0
    
    let availability = Availability.current.value.solarField.ratio
    let minTemp = htf.freezeTemperature
      + Simulation.parameter.dfreezeTemperaturePump
    var interval = 1
    var zoom = 1

    var hce = solarField.loops[loop.rawValue]
    defer { solarField.loops[loop.rawValue] = hce }
    var newTemp = hce.temperature.inlet
    var oldTemp = newTemp
    
    outerIteration: for outerIteration in 1...5 {
      swap(&oldTemp, &newTemp)
      var inFocusLoop = 0.0
     // print("O", outerIteration, newTemp, oldTemp)
      innerIteration: for innerIteration in 1...10 {
      //  print("I", innerIteration)
        let averageTemperature = Temperature.average(
          newTemp, hce.temperature.inlet
        )

        let areaDensity = htf.density(averageTemperature) * .pi
          * col.rabsInner ** 2 / col.aperture

        // Calculate time HTF needs to pass through HCE loop
        //if hce.massFlow <= sof.massFlow.min {
          if hce.massFlow.isNearZero {
          // mass flow is reduced to almost zero due to no demand and full storage
        //  time = period
        } else {
          time = (areaDensity * solarField.area / hce.massFlow.rate)
          //timePast = period
          if time < 0 { time += time }
        }

        if innerIteration == 1 {
          inFocusLoop = solarField.inFocus.ratio
          // Reduce dumping in order to reach design temperature.
          // I.e. dumping happens on first collector(s) and not last on loop
        }

        if newTemp.kelvin < 0.997 * htf.maxTemperature.kelvin {
          // solarField.InFocus > 0, solarField.InFocus < 0.95 {
          inFocusLoop = Ratio(min(1, inFocusLoop * 1.01)).ratio

          // reduce dumping in 1%  limit it to 1
          var deltaHeat = solarField.insolationAbsorber
          deltaHeat *= availability
          deltaHeat -= solarField.heatLosses
          deltaHeat *= solarField.area
            * (1 - inFocusLoop)
          dumping = deltaHeat > 0 ? deltaHeat : 0.0
        }

        let heatInput = solarField.insolationAbsorber
          * inFocusLoop * availability
        // Net deltaHeat (+)=in or (-)=out HCE
        
        let ambient = Plant.ambientTemperature
        
        if heatInput > 0 {
          
          solarField.heatLossHCE = col.useIntegralRadialoss
            ? radiationLosses(averageTemperature, ambient + 30.0,
                              collector: collector, meteo: meteo)
            : radiationLosses(newTemp + 10.0, hce.temperature.inlet + 10.0,
                              collector: collector, meteo: meteo)

          solarField.heatLossHCE *= Simulation.adjustmentFactor.heatLossHCE
          solarField.heatLosses = solarField.heatLossHCE
            + SolarField.pipeHeatLoss(pipe: averageTemperature,
                                      ambient: ambient)
          
          let factorHeatLossHTF = Simulation.adjustmentFactor.heatLossHTF
          if sof.HLDump == false, sof.HLDumpQuad == false {
            solarField.heatLosses *= factorHeatLossHTF
              * inFocusLoop
          } else {
            if sof.HLDumpQuad == false {
              solarField.heatLosses *= factorHeatLossHTF
            } else if case .H = sof.layout {
              if inFocusLoop > 0.75 { // between 0% and 25% dumping
                solarField.heatLosses *= factorHeatLossHTF
              } else if inFocusLoop > 0.5 { // between 25% and 50% dumping
                solarField.heatLosses *= factorHeatLossHTF * 0.75
                // 25% of the heat losses can be reduced -> 1 quadrant not in operation
              } else if inFocusLoop > 0.25 { // between 50% and 75% dumping
                solarField.heatLosses *= factorHeatLossHTF * 0.5
                // 50% of the heat losses can be reduced -> 1 quadrant not in operation
              } else if inFocusLoop > 0 { // between 75% and 100% dumping
                solarField.heatLosses *= factorHeatLossHTF * 0.25
                // 75% of the heat losses can be reduced -> 1 quadrant not in operation
              }
            } else if case .I = sof.layout {
              if inFocusLoop > 0.5 {  // between 0% and 50% dumping
                solarField.heatLosses *= factorHeatLossHTF
              } else if inFocusLoop > 0 { // between 50% and 100% dumping
                solarField.heatLosses *= factorHeatLossHTF * 0.5
                // 50% of the heat losses can be reduced -> 1/2 SF not in operation
              }
            }
          }
        } else { // No Massflow
          solarField.heatLossHCE = col.useIntegralRadialoss
            ? radiationLosses(averageTemperature, ambient + 20.0,
                              collector: collector, meteo: meteo)
            : radiationLosses(newTemp + 10.0, hce.temperature.inlet + 10.0,
                              collector: collector, meteo: meteo)
          
          solarField.heatLossHCE *= Simulation.adjustmentFactor.heatLossHCE
          solarField.heatLosses = solarField.heatLossHCE
          solarField.heatLosses += SolarField.pipeHeatLoss(
            pipe: averageTemperature, ambient: ambient
          )
          solarField.heatLosses *= Simulation.adjustmentFactor.heatLossHTF
        }

        let deltaHeat = heatInput - solarField.heatLosses
        
        let irradianceCosTheta = collector.cosTheta * Double(meteo.dni)
        if irradianceCosTheta > 0 {
          solarField.loopEta = collector.efficiency

          solarField.loopEta -= col.useIntegralRadialoss
            ? radiationLosses(averageTemperature + 10.0, ambient + 30.0,
                              collector: collector, meteo: meteo)
            : radiationLosses(newTemp + 10.0, hce.temperature.inlet + 10.0,
                              collector: collector, meteo: meteo)
          solarField.loopEta *= Simulation.adjustmentFactor.heatLossHCE
            / irradianceCosTheta

          solarField.ETA = collector.efficiency - solarField.heatLosses
            / irradianceCosTheta

        } else {
          solarField.loopEta = 0
          solarField.ETA = 0
        }
        /// Heat collected or lost during the flow through a whole loop [kJ/sqm]
        let deltaHeatPerSqm = deltaHeat * Double(time) / 1_000
        /// Change kJ/sqm to kJ/kg:
        let deltaHeatPerKg = deltaHeatPerSqm / areaDensity
        swap(&oldTemp, &newTemp)
        switch deltaHeatPerKg {
        // Calc. new Temp.
        case let q where q > 0:
          newTemp = htf.resultingTemperature(
            deltaHeatPerKg, hce.temperature.inlet
          )
        case 0:
          newTemp = oldTemp
        default:
          let heatPerKg = htf.addedHeat(
            hce.temperature.inlet, Plant.ambientTemperature
          )
          
          newTemp = htf.resultingTemperature(
            heatPerKg + deltaHeatPerKg, Plant.ambientTemperature
          )
        }
        let maxTemp = htf.maxTemperature
        // Flow is to low, dumping required
        dumping = newTemp > maxTemp
          ? (hce.massFlow.rate / 3 * htf.addedHeat(newTemp, maxTemp) * 1_000)
          : 0.0 // MWt

        newTemp = newTemp.limited(by: maxTemp)
        oldTemp = oldTemp.limited(by: maxTemp)

        if abs(newTemp.kelvin - oldTemp.kelvin)
          < Simulation.parameter.tempTolerance.kelvin,
         newTemp.kelvin > maxTemp.kelvin * 0.995
        // inFocusLoop < 0.95 || inFocusLoop > 0.95 || inFocusLoop == 0
        {
          break innerIteration
        }
      } // innerLoop
      solarField.inFocus = Ratio(inFocusLoop)
    //  if hce.massFlow.rate > 0  {
      if hce.massFlow.isNearZero { break }

      if newTemp < minTemp {
        if (minTemp - newTemp).kelvin < 100 { break }
        interval /= 2
        zoom -= interval // Shorten interval
      } else {
      //  if outerIteration == 1 { break }
        interval /= 2
        zoom += interval // Elongate interval
      }
    }

    hce.temperature.outlet = newTemp

    return (time, dumping)
  }
}
