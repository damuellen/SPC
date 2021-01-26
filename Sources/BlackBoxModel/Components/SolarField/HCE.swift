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
  static func radiationLosses(
    _ temperatures: (Temperature, Temperature),
    insolationAbsorber: Double, ambient: Temperature)
    -> Double
  {
    let ambientT = ambient.celsius
    let (t1, t2) = (temperatures.0.kelvin, temperatures.1.kelvin)
    let avgT = (t1 + t2) / 2
    let col = Collector.parameter
    let aperture = col.aperture
    let emissionHCE = col.emissionHCE
    let availability = Availability.current.value
    let breakHCE = availability.breakHCE.ratio
    let airHCE = availability.airHCE.ratio
    let fluorHCE = availability.fluorHCE.ratio

    let deltaT: Double
    if col.useIntegralRadialoss {
      deltaT = ((t1 + t2) / 2) - (ambientT + 30.0) + 10.0
    } else {
      deltaT = t1 - t2 + 10.0
    }

    var vacuumHeatLoss: Double
    let endLossFactor: Double

    let sigma = 0.00000005667
    let circumference = 2 * .pi * 0.04445//col.rabsOut
    let deltaT2 = deltaT * deltaT

    if col.useIntegralRadialoss == false {
      if col.name.hasPrefix("SKAL-ET") {
        // temperature.0+10 considers that average loop temperature is higher than (T_in + T_out)/2
        vacuumHeatLoss = sigma * circumference * (t1 * t1 * t1 * t1 - t2 * t2 * t2 * t2)
        vacuumHeatLoss *= (emissionHCE[0] + emissionHCE[1] * t1) / aperture
        let al = 0.7 * circumference * (t1 - t1) / aperture
        vacuumHeatLoss = vacuumHeatLoss + al // added here and not for LS2 collector
        endLossFactor = 1 // added in order to differenciate with LS2 collector
      } else if col.name.hasPrefix("LS2") {
        vacuumHeatLoss = 0.081 - 0.04752 * deltaT
          + 0.0006787 * deltaT2 + 0.0007403 * insolationAbsorber
        vacuumHeatLoss += 0.00003582 * deltaT * insolationAbsorber
          + 0.00000014125 * deltaT2 * insolationAbsorber
        endLossFactor = 1.3
      } else if col.name.hasPrefix("PCT_validation") { // test
        vacuumHeatLoss = sigma * circumference
          * (t1 * t1 * t1 * t1 - t2 * t2 * t2 * t2)
        vacuumHeatLoss *= (emissionHCE[0] + emissionHCE[1] * (t1 + 10)) / aperture
        endLossFactor = 1.3 // added in order to differenciate with LS2 collector
      } else {
        // other types than LS-2!!
        // old RadLoss as from LUZ Model
        // temperature.0+10 considers that average loop temperature is higher than (T_in + T_out)/2
        switch col.absorber {
        case .schott:
          vacuumHeatLoss = sigma * circumference
            * (t1 ** 4 - t2 * t2 * t2 * t2)
          vacuumHeatLoss *= (emissionHCE[0] + emissionHCE[1] * (t1 + 10)) / aperture
        case .rio:
          vacuumHeatLoss = (0.00001242 * t1 * t1 * t1 - 0.01864091
            * t1 * t1 + 9.76467705 * t1 - 1714.03)
          vacuumHeatLoss *= circumference / aperture
        }
        // these losses were somehow lower than vacuumHeatLoss used below, but only about 10%
        let al = 0.7 * circumference * (t1 - t2) / col.aperture
        vacuumHeatLoss += al // added here and not for LS2 collector
        endLossFactor = 1
      }
      
    } else {
      // IMPORTANT: definition of temperature.0 and temperature.1
      // changed to use new radiation loss formula
      // E_a = 0.0000002: E_b = -0.0001: E_c = 0.0769
      let Ebs_HCE: Double
      if t1 != t2 {
        // check what if temperature.1 < temperature.0?!
        Ebs_HCE = (1 / 3 * emissionHCE[2]
          * (t1 * t1 * t1 - t2 * t2 * t2) + 1 / 2
          * emissionHCE[1] * (t1 * t1 - t2 * t2)
          + emissionHCE[0] * (t1 - t2)) / (t1 - t2)
      } else { // during FP?
        // check, resulting emissivity too low without c2!
        Ebs_HCE = emissionHCE[0] + emissionHCE[1] * t1
      }

      if t1 != t1 {
        vacuumHeatLoss = sigma / (1 / Ebs_HCE + col.rabsOut
          / col.rglas * (1 / col.glassEmission - 1))
          * circumference / aperture * (1 / 5
            * (t1 * t1 * t1 * t1 * t1 - t2 * t2 * t2 * t2 * t2)
           + (ambientT + 30) ** 4 * (t2 - t1)) / (t1 - t2)
      } else {
        let t = (ambientT + 30)
        vacuumHeatLoss = sigma * circumference
        vacuumHeatLoss *= avgT * avgT * avgT * avgT - t * t * t * t
        vacuumHeatLoss *= (emissionHCE[0] + emissionHCE[1] * t2) / aperture
      }
      var al = 0.7 * circumference
      al *= (avgT - (ambientT + 30)) / aperture
      vacuumHeatLoss += al
      endLossFactor = 1
    }    

    var RLHP: Double = 0.081 - 0.04752 * deltaT
      + 0.0006787 * deltaT2 + 0.0007403 * insolationAbsorber
    RLHP += 3.582e-05 * deltaT * insolationAbsorber
      + 1.4125e-07 * deltaT2 * insolationAbsorber

    var addHLAir: Double = -0.114 + 0.1396 * deltaT
      + 0.000006823 * deltaT2 - 0.002074 * insolationAbsorber
    addHLAir += 0.0000602 * deltaT * insolationAbsorber
      - 0.0000001624 * deltaT2 * insolationAbsorber

    let addHLBare: Double = 0.416 * deltaT
      - 0.000056 * deltaT2 + 0.0666 * deltaT // * windSpeed
    let losses = (vacuumHeatLoss + addHLAir * (airHCE + fluorHCE)
      + addHLBare * breakHCE) * endLossFactor

    return losses
    // * 1.3
    // Faktor 1.3 due to end HCE end losses
    // "* endLossFactor" added in order to differenciate with LS2 collector
  }
  
  //  MARK: - Mode 1
  /// Vary mass-flow to maintain optimum HTF-temp.
  static func mode1(
    _ solarField: inout SolarField,
    _ collector: Collector,
    _ loop: SolarField.Loop,
    _ ambient: Temperature
  ) -> (Double, Double) {
    let sof = SolarField.parameter
    
    let area = Design.layout.solarField
      * Double(sof.numberOfSCAsInRow)
      * 2 * Collector.parameter.areaSCAnet
    
    let massFlowMin = MassFlow(sof.minFlow.ratio * sof.maxMassFlow.rate)
    let massFlowMax = sof.maxMassFlow.rate

    let htf = sof.HTF
    
    let col = Collector.parameter
    
    var time = 0.0
    
    var dumping = 0.0
    
    var hce = solarField.loops[loop.rawValue]
    defer { solarField.loops[loop.rawValue] = hce }
    
    // Average HTF temp. in loop [K]
    var avgT = Temperature.average(
      htf.maxTemperature, hce.temperature.inlet
    )

    let temperatures = col.useIntegralRadialoss
      ? (avgT, ambient + 20.0)
      : (htf.maxTemperature + 10.0, hce.temperature.inlet + 10.0)
      
    solarField.heatLossesHCE = HCE.radiationLosses(temperatures,
      insolationAbsorber: collector.insolationAbsorber, ambient: ambient
    )
    
    solarField.heatLossesHCE *= Simulation.adjustmentFactor.heatLossHCE
    
    solarField.heatLosses = solarField.heatLossesHCE
    solarField.heatLosses += SolarField.pipeHeatLoss(
      pipe: avgT, ambient: ambient
    )
    solarField.heatLosses *= Simulation.adjustmentFactor.heatLossHTF

    var deltaHeat = collector.insolationAbsorber
    deltaHeat *= Availability.current.value.solarField.ratio
    deltaHeat -= solarField.heatLosses
    
    if collector.insolationAbsorber > 0 {
      solarField.loopEta = collector.efficiency.ratio - solarField.heatLossesHCE
        / collector.insolationAbsorber / collector.efficiency.ratio
      solarField.ETA = collector.efficiency.ratio - solarField.heatLosses
        / collector.insolationAbsorber / collector.efficiency.ratio
    } else {
      solarField.loopEta = 0
      solarField.ETA = 0
    }
    
    /// Calculate appropriate mass-flow [kg/(sec sqm)]
    let ratio = abs(deltaHeat) / 1_000 / htf.deltaHeat(
      htf.maxTemperature, hce.temperature.inlet
    )

    hce.massFlow.rate = ratio * area

    func calculateTime() -> Double {
      if hce.averageTemperature.celsius < 20 { 
        print("Temperature too low.")
        return 0
      }
      let areaDensity = htf.density(hce.averageTemperature)
        * .pi * col.rabsOut ** 2 / col.aperture      
      return areaDensity * area / hce.massFlow.rate
    }
    
    switch hce.massFlow { // Check if mass-flow is within acceptable limits
    case let massFlow where massFlow.rate <= 0: // HCE loses heat

      if case .freezeProtection = solarField.operationMode {
        hce.massFlow = massFlowMin
        (time, dumping) = mode2(&solarField, collector, loop, ambient)
      } else {
    
        (solarField.massFlow, solarField.operationMode) = 
          solarField.antiFreezeCheck(loop: loop)
        (time, dumping) = mode2(&solarField, collector, loop, ambient)
      }

    case let massFlow where massFlow > sof.maxMassFlow:
      // Damped heat: The HL have to be added because they are independent from
      // the SCAs in focus. HL must be subtracted afterwards again.
      solarField.inFocus = Ratio(massFlowMax / massFlow.rate)
      // [MW] added to calculate Q_dump with instantaneous irradiation

      dumping = deltaHeat * area * (1 - solarField.inFocus.ratio)

      // changed to htf.maxTemperature to reach max temp possible
      hce.temperature.outlet = htf.maxTemperature

      hce.massFlow = sof.maxMassFlow
      time = calculateTime() // [sec]
     // time = period

    case let massFlow where massFlow < massFlowMin:

      if case .normal = solarField.operationMode,
        massFlow.rate > massFlowMax * 0.05 {
        // pumps are working over massFlow.min
        solarField.inFocus = 1.0
        // changed to htf.maxTemperature to reach max temp possible
        hce.temperature.outlet = htf.maxTemperature
        hce.massFlow = massFlow

        time = calculateTime() // [sec]

      //  time = period
      } else if case .normal = solarField.operationMode {
        solarField.inFocus = 1.0
        hce.massFlow = sof.maxMassFlow.adjusted(withFactor: 0.05)
        (time, dumping) = mode2(&solarField, collector, loop, ambient)
      } else {
        solarField.inFocus = 1.0
        hce.massFlow = massFlowMin
        (time, dumping) = mode2(&solarField, collector, loop, ambient)
      }

    default: // MassFlow is within acceptable limits and Tout is as required
      solarField.inFocus = 1.0
      // FIXME: status.massFlow = massFlow
      // changed to htf.maxTemperature to reach max temp possible
      hce.temperature.outlet = SolarField.parameter.HTF.maxTemperature
      avgT = hce.averageTemperature

      solarField.operationMode = .operating

      time = calculateTime() // [sec]
    }
    /// Residence time [sec]
    return (time, dumping)
  }
  
  //  MARK: - Mode 2
  /// HTF-temp. dependent on constant mass-flow
  static func mode2(
    _ solarField: inout SolarField,
    _ collector: Collector,
    _ loop: SolarField.Loop,
    _ ambient: Temperature
  ) -> (Double, Double) {
    let sof = SolarField.parameter
    
    let area = Design.layout.solarField
      * Double(sof.numberOfSCAsInRow)
      * 2 * Collector.parameter.areaSCAnet
    
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
    var oldTemp = hce.temperature.inlet
   
    outerIteration: for o in 1...5 {
      swap(&oldTemp, &newTemp)
      var inFocusLoop = 0.1
     // print("O", o, newTemp, oldTemp)
      innerIteration: for innerIteration in 1...10 {
      //  print("I", innerIteration)
        let avgT = Temperature.average(
          newTemp, hce.temperature.inlet
        )
        let areaDensity: Double
        if avgT.celsius < 20 {
          print(o, innerIteration, newTemp, hce, solarField,
                "Temperature too low.")
          areaDensity = 1
        } else {
          areaDensity = htf.density(avgT) * .pi
          * col.rabsInner ** 2 / col.aperture
        }
         
        // Calculate time HTF needs to pass through HCE loop
        //if hce.massFlow <= sof.massFlow.min {
        if hce.massFlow.isNearZero {
          // mass flow is reduced to almost zero due to no demand and full storage
          //  time = period
        } else {
          time = (areaDensity * area / hce.massFlow.rate)
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
          var deltaHeat = collector.insolationAbsorber
          deltaHeat *= availability
          deltaHeat -= solarField.heatLosses
          deltaHeat *= area * (1 - inFocusLoop)
          
          dumping = deltaHeat > 0 ? deltaHeat : 0.0
        }

        let heatInput = collector.insolationAbsorber * inFocusLoop * availability
        // Net deltaHeat (+)=in or (-)=out HCE
        
        if heatInput > 0 {
          let temperatures = col.useIntegralRadialoss
            ? (avgT, ambient + 30.0)
            : (newTemp + 10.0, hce.temperature.inlet + 10.0)

          solarField.heatLossesHCE = HCE.radiationLosses(temperatures,
            insolationAbsorber: collector.insolationAbsorber, ambient: ambient
          )

          solarField.heatLossesHCE *= Simulation.adjustmentFactor.heatLossHCE
          
          solarField.heatLosses = solarField.heatLossesHCE
          solarField.heatLosses += SolarField.pipeHeatLoss(
            pipe: avgT, ambient: ambient
          )
          
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
          let temperatures = col.useIntegralRadialoss
            ? (avgT, ambient + 20.0)
            : (newTemp + 10.0, hce.temperature.inlet + 10.0)
          print(avgT.kelvin, ambient.kelvin + 20.0)

          solarField.heatLossesHCE = HCE.radiationLosses(temperatures,
            insolationAbsorber: collector.insolationAbsorber, ambient: ambient
          )

          solarField.heatLossesHCE *= Simulation.adjustmentFactor.heatLossHCE
          
          solarField.heatLosses = solarField.heatLossesHCE
          solarField.heatLosses += SolarField.pipeHeatLoss(
            pipe: avgT, ambient: ambient
          )
          solarField.heatLosses *= Simulation.adjustmentFactor.heatLossHTF
        }

        let deltaHeat = heatInput - solarField.heatLosses

        if collector.insolationAbsorber > 0 {
          solarField.loopEta = collector.efficiency.ratio

          let (t1, t2) = col.useIntegralRadialoss
            ? (avgT, ambient + 30.0)
            : (newTemp + 10.0, hce.temperature.inlet + 10.0)

          solarField.heatLossesHCE = HCE.radiationLosses((t1, t2),
            insolationAbsorber: collector.insolationAbsorber, ambient: ambient
          )
          
          solarField.loopEta *= Simulation.adjustmentFactor.heatLossHCE
            / collector.insolationAbsorber / collector.efficiency.ratio

          solarField.ETA = collector.efficiency.ratio - solarField.heatLosses
            / collector.insolationAbsorber / collector.efficiency.ratio

        } else {
          solarField.loopEta = 0
          solarField.ETA = 0
        }
        /// Heat collected or lost during the flow through a whole loop [kJ/sqm]
        let deltaHeatPerSqm = deltaHeat * Double(time) / 1_000
        // Change kJ/sqm to kJ/kg:
        let deltaHeatPerKg = deltaHeatPerSqm / areaDensity
        
        swap(&oldTemp, &newTemp)
        
        switch deltaHeatPerKg {
        // Calc. new Temp.
        case let Q where Q > 0:
          newTemp = htf.temperature(deltaHeatPerKg, hce.temperature.inlet)
        case 0:
          newTemp = oldTemp
        default:
          let heatPerKg = htf.deltaHeat(hce.temperature.inlet, ambient)
          
          newTemp = htf.temperature(heatPerKg + deltaHeatPerKg, ambient)
        }
        
        let maxTemp = htf.maxTemperature
        // Flow is to low, dumping required
        dumping = newTemp > maxTemp
          ? (hce.massFlow.rate / 3 * htf.deltaHeat(newTemp, maxTemp) * 1_000)
          : 0.0 // MWt

        newTemp.limit(to: maxTemp)
        oldTemp.limit(to: maxTemp)

        if abs(newTemp.kelvin - oldTemp.kelvin)
          < Simulation.parameter.tempTolerance,
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
        if o == 1 { break }
        interval /= 2
        zoom += interval // Elongate interval
      }
      //#warning("The implementation here differs from PCT")
      if newTemp == oldTemp { break }
    }
    hce.temperature.outlet = newTemp

    return (time, dumping)
  }
}