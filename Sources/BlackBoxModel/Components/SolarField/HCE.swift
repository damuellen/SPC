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
  static func radiationLossesOld(
    _ temperatures: (Temperature, Temperature, Temperature), insolation: Double)
    -> Double // [W/m2]
  {
    let (t1, t2) = (temperatures.0.kelvin, temperatures.1.kelvin)
    let col = Collector.parameter
    let aperture = col.aperture
    let emissionHCE = col.emissionHCE
    let availability = Availability.current.value
    let breakHCE = availability.breakHCE.quotient
    let airHCE = availability.airHCE.quotient
    let fluorHCE = availability.fluorHCE.quotient

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
    let ambT = temperatures.2.kelvin + 30
    
    let dT = (t1 + t2) / 2 - ambT + 10

    let rabsOut = Collector.parameter.rabsOut
    let rglas = Collector.parameter.rglas
    let glassEmission = Collector.parameter.glassEmission
    let aperture = Collector.parameter.aperture
    let emissionHCE = Collector.parameter.emissionHCE
    let value = Availability.current.value
    let breakHCE = value.breakHCE.quotient
    let airHCE = value.airHCE.quotient
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

  //  MARK: - Mode 1
  /// Vary mass-flow to maintain optimum HTF-temp.
  static func mode1(
    _ solarField: inout SolarField,
    _ collector: Collector,
    _ loop: SolarField.Loop,
    _ ambient: Temperature
  ) -> (Double, Double) {
    let numberOfSCAsInRow = SolarField.parameter.numberOfSCAsInRow
    let minFlow = SolarField.parameter.minFlow.quotient
    let maxMassFlow = SolarField.parameter.maxMassFlow.rate
    let massFlowMin = MassFlow(minFlow * maxMassFlow)
    
    let htf = SolarField.parameter.HTF
    
    let useIntegralRadialoss = Collector.parameter.useIntegralRadialoss
    
    var time = 300.0
    
    var dumping = 0.0
    
    var hce = solarField.loops[loop.rawValue]
    defer { solarField.loops[loop.rawValue] = hce }
    
    // Average HTF temp. in loop [K]
    var avgT = Temperature.average(
      htf.maxTemperature, hce.temperature.inlet
    )

    let temperatures = useIntegralRadialoss
      ? (htf.maxTemperature + 10.0, hce.temperature.inlet + 10.0, ambient) 
      : (avgT, ambient + 20.0, 0.0)
      
    let radiaLoss = useIntegralRadialoss
      ? HCE.radiationLossesNew : HCE.radiationLossesOld

    solarField.heatLossesHCE = radiaLoss(temperatures, collector.insolationAbsorber)
    
    solarField.heatLossesHCE *= Simulation.adjustmentFactor.heatLossHCE
    
    solarField.heatLosses = solarField.heatLossesHCE
    solarField.heatLosses += SolarField.pipeHeatLoss(pipe: avgT, ambient: ambient)
    solarField.heatLosses *= Simulation.adjustmentFactor.heatLossHTF

    var deltaHeat = collector.insolationAbsorber
    deltaHeat *= Availability.current.value.solarField.quotient
    deltaHeat -= solarField.heatLosses
    
    /// Calculate appropriate mass-flow [kg/(sec sqm)]
    let ratio = abs(deltaHeat) / 1_000 / htf.heatContent(
      htf.maxTemperature, hce.temperature.inlet
    )
    let area = Design.layout.solarField 
      * Double(numberOfSCAsInRow) * 2 * Collector.parameter.areaSCAnet

    hce.massFlow.rate = ratio * area

    func calculateTime() -> Double {
      assert(avgT > 20.0, "Temperature too low.")
      let areaDensity = htf.density(hce.average) * .pi 
        * Collector.parameter.rabsOut ** 2 / Collector.parameter.aperture      
      return areaDensity * area / hce.massFlow.rate
    }
    
    switch hce.massFlow { // Check if mass-flow is within acceptable limits
    case let massFlow where massFlow.rate <= .zero: // HCE loses heat

      if case .freezeProtection = solarField.operationMode {
        hce.massFlow = massFlowMin
        (time, dumping) = mode2(&solarField, collector, loop, ambient)
      } else {    
        solarField.operationMode = solarField.antiFreezeCheck(loop: loop)
        (time, dumping) = mode2(&solarField, collector, loop, ambient)
      }

    case let massFlow where massFlow > solarField.maxMassFlow:
      // Damped heat: The HL have to be added because they are independent from
      // the SCAs in focus. HL must be subtracted afterwards again.
      solarField.inFocus = Ratio(solarField.maxMassFlow.rate / massFlow.rate)
      // [MW] added to calculate Q_dump with instantaneous irradiation

      dumping = deltaHeat * area * (1 - solarField.inFocus.quotient)

      // changed to htf.maxTemperature to reach max temp possible
      hce.temperature.outlet = htf.maxTemperature

      hce.massFlow = solarField.maxMassFlow
      time = calculateTime() // [sec]
      time = 300.0

    case let massFlow where massFlow < massFlowMin:

      if case .normal = solarField.operationMode,
        massFlow.rate > solarField.maxMassFlow.rate * 0.05 {
        // pumps are working over massFlow.min
        solarField.inFocus = 1.0
        // changed to htf.maxTemperature to reach max temp possible
        hce.temperature.outlet = htf.maxTemperature
        hce.massFlow = massFlow

        time = calculateTime() // [sec]

        time = 300.0
      } else if case .normal = solarField.operationMode {
        solarField.inFocus = 1.0
        hce.massFlow.rate = solarField.maxMassFlow.rate * 0.05
        (time, dumping) = mode2(&solarField, collector, loop, ambient)
      } else {
        solarField.inFocus = 1.0
        hce.massFlow = massFlowMin
        (time, dumping) = mode2(&solarField, collector, loop, ambient)
      }

    default: // MassFlow is within acceptable limits and Tout is as required
      solarField.inFocus = 1.0

      hce.temperature.outlet = SolarField.parameter.HTF.maxTemperature
      avgT = hce.average

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
    let htf = SolarField.parameter.HTF
    let numberOfSCAsInRow = SolarField.parameter.numberOfSCAsInRow   
    let rabsInner = Collector.parameter.rabsInner
    let aperture = Collector.parameter.aperture
    let useIntegralRadialoss = Collector.parameter.useIntegralRadialoss

    let area = Design.layout.solarField
      * Double(numberOfSCAsInRow) * 2 * Collector.parameter.areaSCAnet

    var time = 300.0
    
    var dumping = 0.0
    
    let availability = Availability.current.value.solarField.quotient
    
    let minTemp = htf.freezeTemperature
      + Simulation.parameter.dfreezeTemperaturePump
    
    var interval = 1
    
    var zoom = 1

    var hce = solarField.loops[loop.rawValue]
    defer { solarField.loops[loop.rawValue] = hce }

    let maxTemp = htf.maxTemperature
    var newTemp = hce.temperature.inlet
    var oldTemp = hce.temperature.inlet
   
    outerIteration: for o in 1...5 {
      newTemp = hce.temperature.inlet
      var inFocusLoop = 0.0
     // print("O", o, newTemp, oldTemp)
      innerIteration: for _ in 1...10 {
      //  print("I", innerIteration)
        let avgT = Temperature.average(newTemp, hce.temperature.inlet)

        assert(avgT > ambient, "Temperature too low.")

        let areaDensity = htf.density(avgT) * .pi * rabsInner ** 2 / aperture        

        if hce.massFlow > .zero {
          time = (areaDensity * area) / hce.massFlow.rate
        } else {
          time = 300.0
        }

        if newTemp.kelvin < 0.997 * maxTemp.kelvin {
          // solarField.InFocus > 0, solarField.InFocus < 0.95 {
          inFocusLoop = min(1, inFocusLoop * 1.01)

          // reduce dumping in 1%  limit it to 1
          var deltaHeat = collector.insolationAbsorber
          deltaHeat *= availability
          deltaHeat -= solarField.heatLosses
          deltaHeat *= area * (1 - inFocusLoop)
          
          dumping = deltaHeat > 0 ? deltaHeat : 0.0
        }

        let heatInput = collector.insolationAbsorber * inFocusLoop * availability
        // Net deltaHeat (+)=in or (-)=out HCE
        
        let temperatures = useIntegralRadialoss
          ? (newTemp + 10.0, hce.temperature.inlet + 10.0, ambient)
          : (avgT, ambient + (heatInput > 0 ? 30.0 : 20.0), 0.0)

        let radiaLoss = useIntegralRadialoss
          ? HCE.radiationLossesNew : HCE.radiationLossesOld

        solarField.heatLossesHCE = radiaLoss(temperatures, collector.insolationAbsorber)
        solarField.heatLossesHCE *= Simulation.adjustmentFactor.heatLossHCE
        
        solarField.heatLosses = solarField.heatLossesHCE

        solarField.heatLosses += SolarField.pipeHeatLoss(pipe: avgT, ambient: ambient)
        solarField.heatLosses *= Simulation.adjustmentFactor.heatLossHTF

        if heatInput > .zero {      
          let sof = SolarField.parameter  
          let factorHeatLossHTF = Simulation.adjustmentFactor.heatLossHTF
          if sof.HLDump == false, sof.HLDumpQuad == false {
            solarField.heatLosses *= factorHeatLossHTF * inFocusLoop
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
        }

        let deltaHeat = heatInput - solarField.heatLosses

        /// Heat collected or lost during the flow through a whole loop [kJ/sqm]
        let deltaHeatPerSqm = deltaHeat * time / 1_000
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
          let heatPerKg = htf.heatContent(hce.temperature.inlet, ambient)
          newTemp = htf.temperature(heatPerKg + deltaHeatPerKg, ambient)
        }
                
        // Flow is to low, dumping required
        dumping = newTemp > maxTemp
          ? (hce.massFlow.rate / 3 * htf.heatContent(newTemp, maxTemp) * 1_000)
          : 0.0 // MWt

        newTemp.limit(to: maxTemp)
        oldTemp.limit(to: maxTemp)
        let inTolerance = abs(newTemp.kelvin - oldTemp.kelvin) 
          < Simulation.parameter.tempTolerance
        if inTolerance, newTemp.kelvin > maxTemp.kelvin * 0.997 || inFocusLoop.isZero
        {
          break innerIteration
        }
      } // innerLoop
      solarField.inFocus = Ratio(inFocusLoop)

      if hce.massFlow > .zero { break }

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
