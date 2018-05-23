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
// +==========================================================================+
// HCE  Heat Collecting Element
// +==========================================================================+
// TASK: if operationMode="?": Calculate the right mass-flow to get maximum allowed
//      HTF-outlet temp. of the HCE-loop, and the time of HTF being in the
//      HCE-loop. defocus automatically not to overheat HCEs.
//      if operationMode="!": Mass-flow is fixed outside. Calculate the HTF-outlet
//      temp. of the HCE-loop and the time of HTF being in the HCE-loop. If
//      mass-flow is set to 0, calculate by heat losses the HTF-temp. in the
//      HCE after Actime minutes.
// ++
// INPUT: Actime: [minutes]
//       if operationMode="?" then Actime has no meaning. if operationMode="!" and
//       Fluid.parameter.massFlow=0 { SF calculates Actime the heat losses in the HCEs.
//       if Actime<0 then HCE calculates the time of HTF being in HCEs
//       minus abs(Actime)
// ++
// OUTPUT: Actime: [sec]
//        if Fluid.parameter.massFlow>0 then Actime is the time the HTF was in the HCEs.
//        if operationMode="!" and Fluid.parameter.massFlow=0 then Actime is the time the losses
//        were calculated. Not necessary equal to Actime from input, cause
//        calculation stops when Fluid.parameter.temperature.outlet  goes under freezeTemperature+Sim.deltaTemperaturefrzPump
// ++

var Actime = 0
var period = 300
var dheat_now = 0.0

enum HCE {
  
  public static func calculation(_ status: inout Plant.PerformanceData,
                                 loop: SolarField.Loop,
                                 mode: Collector.OperationMode,
                                 meteo: MeteoData) {
    
    let ICosTheta = Double(meteo.dni) * status.collector.cosTheta
    status.solarField.ITA = 0

    switch mode {
      
    case .noOperation:
      period = 300
      freezeProtectionCheck(&status.solarField)
      
    case .operating:
      period = 300
      if meteo.windSpeed > SolarField.parameter.maxWind {
        status.solarField.inFocus = 0.0
      }
      mode1(&status, loop: loop, mode: mode, meteo: meteo)
      
    case .variable, .freezeProtection:
      
      if meteo.windSpeed > SolarField.parameter.maxWind
        || ICosTheta * status.collector.efficiency < Simulation.parameter.minInsolation {
        freezeProtectionCheck(&status.solarField) // on first call
      } else {
        mode1(&status, loop: loop, mode: mode, meteo: meteo)
      }
      
    case .fixed:
      mode2(&status, loop: loop, mode: mode, meteo: meteo)
    }
  }
  
  public static func freezeProtectionCheck(_ solarField: inout SolarField.PerformanceData) {
    solarField.inFocus = 1.0
    
    let TempFP = htf.freezeTemperature
      + Simulation.parameter.dfreezeTemperaturePump
      + Simulation.parameter.tempTolerance
    if solarField.header.temperature.inlet < TempFP
      || solarField.header.temperature.outlet < TempFP {
      solarField.header.massFlow = SolarField.parameter.antiFreezeFlow
      solarField.operationMode = .freezeProtection
    } else {
      solarField.operationMode = .noOperation
      // status = LastHTF
      solarField.header.massFlow = 0.0
    }
  }
  
  // Radiation losses per m2 Aperture; now with the new losses that take into
  // account the percentage of HCE that are broken, lost vacuum and fluorescent
  public static func radiationLosses(_ status: Plant.PerformanceData,
                                     temperature: (Temperature, Temperature),
                                     meteo: MeteoData) -> Double {
    let collector = Collector.parameter

    let breakHCE = Plant.availability.value.breakHCE.ratio // Percent /100 in LoadAvlMaintnc
    let airHCE = Plant.availability.value.airHCE.ratio // Percent /100 in LoadAvlMaintnc
    let fluorHCE = Plant.availability.value.fluorHCE.ratio // Percent /100 in LoadAvlMaintnc
    
    let (t1, t2) = (temperature.0.kelvin, temperature.1.kelvin)
    let deltaT: Double
    if !collector.newFunction {
      deltaT = (t1 - t2 + Temperature(10.0).kelvin)
    } else {
      deltaT = (temperature.0).median(temperature.1).kelvin
         - (Double(meteo.temperature) + 30.0) + 10.0
    }
    
    var vacuumHeatLoss: Double
    let endLossFactor: Double
    let ICosTheta = Double(meteo.dni) * status.collector.cosTheta
    let insulation = ICosTheta * status.collector.efficiency  // Insulation to Absorber!
    let sigma = 0.00000005667
    
    if !collector.newFunction {
      if collector.name.hasPrefix("SKAL-ET") {
        // temperature.0+10 considers that average loop temperature is higher than (T_in + T_out)/2
        vacuumHeatLoss = sigma * 2 * .pi * collector.rabsOut
          * (t1 ** 4 - t2 ** 4)
        vacuumHeatLoss *= (collector.emissionHCE[0]
          + collector.emissionHCE[1] * t1) / collector.aperture
        let al = 0.7 * 2 * .pi * collector.rabsOut
          * (t1 - t1) / collector.aperture
        vacuumHeatLoss = vacuumHeatLoss + al // added here and not for LS2 collector
        endLossFactor = 1 // added in order to differenciate with LS2 collector
      } else if collector.name.hasPrefix("LS2") {
        vacuumHeatLoss = 0.081 - 0.04752 * deltaT + 0.0006787
          * deltaT ** 2 + 0.0007403 * insulation
        vacuumHeatLoss += 0.00003582 * deltaT * insulation
          + 0.00000014125 * deltaT ** 2 * insulation
        endLossFactor = 1.3 // added in order to differenciate with LS2 collector
      } else if collector.name.hasPrefix("PCT_validation") { // test
        vacuumHeatLoss = sigma * 2 * .pi * collector.rabsOut
          * (t1 ** 4 - t2 ** 4)
        vacuumHeatLoss *= (collector.emissionHCE[0] + collector.emissionHCE[1]
          * (t1 + 10)) / collector.aperture
        endLossFactor = 1.3 // added in order to differenciate with LS2 collector
      } else {
        // other types than LS-2!!
        // old RadLoss as from LUZ Model
        // temperature.0+10 considers that average loop temperature is higher than (T_in + T_out)/2
        switch collector.absorber {
        case .schott:
          vacuumHeatLoss = sigma * 2 * .pi * collector.rabsOut
            * (t1 ** 4 - t2 ** 4)
          vacuumHeatLoss *= (collector.emissionHCE[0]
            + collector.emissionHCE[1] * (t1 + 10)) / collector.aperture
        case .rio:
          vacuumHeatLoss = (0.00001242 * t1 ** 3 - 0.01864091
            * t1 ** 2 + 9.76467705 * t1 - 1714.03)
          vacuumHeatLoss *= 2 * .pi * collector.rabsOut / collector.aperture
        }
        // these losses were somehow lower than vacuumHeatLoss used below, but only about 10%
        let al = 0.7 * 2 * .pi * collector.rabsOut
          * (t1 - t2) / collector.aperture
        vacuumHeatLoss = vacuumHeatLoss + al // added here and not for LS2 collector
        endLossFactor = 1 // added in order to differenciate with LS2 collector
      }
    } else {
      // new formula from Jan Felinks.
      // IMPORTANT: definition of temperature.0 and temperature.1
      // changed to use new radiation loss formula
      // E_a = 0.0000002: E_b = -0.0001: E_c = 0.0769
      let Ebs_HCE: Double
      if temperature.1 != temperature.0 { // check what if temperature.1 < temperature.0?!
        Ebs_HCE = (1 / 3 * collector.emissionHCE[1]
          * (t1 ** 3 - t2 ** 3) + 1 / 2
          * collector.emissionHCE[1] * (t1 ** 2 - t2 ** 2)
          + collector.emissionHCE[0] * (t1 - t2))
          / (temperature.0 - temperature.1).kelvin
      } else { // during FP?
        // check, resulting emissivity too low without c2!
        Ebs_HCE = collector.emissionHCE[0]
          + collector.emissionHCE[1] * t1
      }
      
      if temperature.1 != temperature.0 {
        // check what if temperature.1 < temperature.0!
        vacuumHeatLoss = sigma / (1 / Ebs_HCE + collector.rabsOut
          / collector.rglas * (1 / collector.glassEmission - 1))
          * 2 * .pi * collector.rabsOut / collector.aperture
          * (1 / 5 * (t1 ** 5 - t2 ** 5)
            + (Double(meteo.temperature) + 30) ** 4
            * (temperature.1 - temperature.0).kelvin)
          / (temperature.0 - temperature.1).kelvin
      } else {
        vacuumHeatLoss = sigma * 2 * .pi * collector.rabsOut
        vacuumHeatLoss *= (((temperature.1 + temperature.0).kelvin / 2) ** 4
          - (Double(meteo.temperature) + 30) ** 4)
        vacuumHeatLoss *= (collector.emissionHCE[0]
          + collector.emissionHCE[1] * t2) / collector.aperture
      }
      var al = 0.7 * 2 * .pi * collector.rabsOut
      al *= ((temperature.1 + temperature.0).kelvin / 2
        - (Double(meteo.temperature) + 30)) / collector.aperture
      vacuumHeatLoss += al
      endLossFactor = 1
    }
    
    var RLHP: Double = 0.081 - 0.04752 * deltaT + 0.0006787
      * deltaT ** 2 + 0.0007403 * insulation
    RLHP += 0.00003582 * deltaT * insulation
      + 0.00000014125 * deltaT ** 2 * insulation
    
    var addHLAir: Double = -0.114 + 0.1396 * deltaT
      + 0.000006823 * deltaT ** 2 - 0.002074 * insulation
    addHLAir += 0.0000602 * deltaT * insulation
      - 0.0000001624 * deltaT ** 2 * insulation
    
    let addHLBare: Double = 0.416 * deltaT - 0.000056
      * deltaT ** 2 + 0.0666 * deltaT // * windSpeed
    return (vacuumHeatLoss + addHLAir * (airHCE + fluorHCE)
      + addHLBare * breakHCE) * endLossFactor
    // * 1.3
    // Faktor 1.3 due to end HCE end losses
    // "* endLossFactor" added in order to differenciate with LS2 collector
  }
  
  /// Vary mass-flow to maintain optimum HTF-temp.
  public static func mode1(
    _ status: inout Plant.PerformanceData,
    loop: SolarField.Loop, mode: Collector.OperationMode,
    meteo: MeteoData) {
    
    var hce = status.solarField.loops[loop.rawValue]
    defer { status.solarField.loops[loop.rawValue] = hce }
    
    let ambientTemperature = Temperature(celsius: meteo.temperature)
    // Average HTF temp. in loop [K]
    var averageTemperture = Temperature(
      (htf.maxTemperature.kelvin + hce.temperature.inlet.kelvin) / 2)
    // Delta heat in HCE[W/m2]
    let heatin = Double(meteo.dni) * status.collector.cosTheta
      * status.collector.efficiency
      * Plant.availability.value.solarField.ratio
    // Delta heat in HCE[W/m2] // added to calculate Q_dump
    let heatin_now = Double(meteo.dni) * status.collector.cosTheta
      * status.collector.efficiency
      * Plant.availability.value.solarField.ratio
    
    if Collector.parameter.IntradiationLosses {
      status.solarField.heatLossHCE = HCE.radiationLosses(status, temperature:
        (averageTemperture + 10.0,ambientTemperature + 30.0),
        meteo: meteo) * Simulation.parameter.adjustmentFactor.heatLossHCE
    } else {
      status.solarField.heatLossHCE = HCE.radiationLosses(status, temperature:
        (htf.maxTemperature + 10.0, hce.temperature.inlet + 10.0),
        meteo: meteo) * Simulation.parameter.adjustmentFactor.heatLossHCE
    }
    
    status.solarField.HL = status.solarField.heatLossHCE
      + SolarField.pipeHeatLoss(averageTemperture, ambient: ambientTemperature)
    
    status.solarField.HL *= Simulation.parameter.adjustmentFactor.heatLossHTF
    
    status.solarField.ITA = Double(meteo.dni) * status.collector.cosTheta * status.collector.efficiency

    let dheat = heatin - status.solarField.HL
    let dheat_now = heatin_now - status.solarField.HL
    /*
     if ICosThetaMax > 0 {
     var LoopEta = Collector.efficiency - solarField.heatLossHCE / ICosThetaMax
     var SFEta = Collector.efficiency - HL / ICosThetaMax
     } else {
     var LoopEta = 0
     var SFEta = 0
     }
     */
    // Calculate appropriate mass-flow [kg/(sec sqm)]
    
    hce.massFlow = MassFlow(abs(dheat) / 1_000 / htf.heatDelta(
      htf.maxTemperature, hce.temperature.inlet))
    // [kg/(sec sqm)] = [J/(sec sqm)/1000] / [kJ/kg]
    hce.massFlow = MassFlow(hce.massFlow.rate * Design.layout.solarField
      * Double(SolarField.parameter.numberOfSCAsInRow) * 2
      * Collector.parameter.areaSCAnet) // - [kg/s] -
    
    switch hce.massFlow { // Check if mass-flow is within acceptable limits
      
    case let massFlow where massFlow > SolarField.parameter.massFlow.max:
      // Damped heat: The HL have to be added because they are independent from
      // the SCAs in focus. HL must be subtracted afterwards again.
      status.solarField.inFocus = Ratio(SolarField.parameter.massFlow.max.rate / massFlow.rate)
      // [MW] added to calculate Q_dump with instantaneous irradiation
      Plant.thermal.dump = dheat_now * Design.layout.solarField
        * Double(SolarField.parameter.numberOfSCAsInRow) * 2
        * Collector.parameter.areaSCAnet
        * (1 - status.solarField.inFocus.ratio) / 1_000_000
      
      Plant.thermal.overtemp_dump = 0
      
      hce.massFlow = SolarField.parameter.massFlow.max
      // changed to htf.maxTemperature to reach max temp possible
      hce.temperature.outlet = htf.maxTemperature
      //mode = .operating
      // The density [kg/cubm] must be changed to area-density [kg/sqm]:
      // (1)  Dens(T)[kg/cubm] * 1m *  .pi * Rabsout[m]^2 =: M[kg]   and
      // (2)  M[kg] / (Aperture[m] * 1m) =: Area-density[Kg/sqm]    ==>
      
      averageTemperture = Temperature((hce.temperature.outlet
        + hce.temperature.inlet).kelvin / 2)
      
      let areadens = htf.density(averageTemperture) * .pi
        * Collector.parameter.rabsOut ** 2 / Collector.parameter.aperture
      
      Actime = Int(areadens * Design.layout.solarField
        * Double(SolarField.parameter.numberOfSCAsInRow)
        * 2 * Collector.parameter.areaSCAnet / hce.massFlow.rate)
      // [sec] calculation of Actime below commented, not needed ince is set to abd in next step
      
      Actime = period
      
    case let massFlow where massFlow > SolarField.parameter.massFlow.min:
      Plant.thermal.dump = 0
      Plant.thermal.overtemp_dump = 0
      if case .normal = status.heater.operationMode,
        massFlow.rate > SolarField.parameter.massFlow.max.rate * 0.05 {
        // pumps are working over massFlow.min
        status.solarField.inFocus = 1.0
        hce.massFlow = massFlow
        hce.temperature.outlet = htf.maxTemperature
        // changed to htf.maxTemperature to reach max temp possible
        averageTemperture = Temperature((hce.temperature.outlet
          + hce.temperature.inlet).kelvin / 2.0)
        
        let areadens = htf.density(averageTemperture) * .pi
          * Collector.parameter.rabsOut ** 2 / Collector.parameter.aperture
        
        Actime = Int(areadens * Design.layout.solarField
          * Double(SolarField.parameter.numberOfSCAsInRow) * 2
          * Collector.parameter.areaSCAnet / hce.massFlow.rate) // [sec]
        
        Actime = period
      } else if case .normal = status.heater.operationMode {
        status.solarField.inFocus = 1.0
        hce.massFlow = MassFlow(SolarField.parameter.massFlow.max.rate * 0.05)
        mode2(&status, loop: loop, mode: mode, meteo: meteo)
      } else {
        status.solarField.inFocus = 1.0
        hce.massFlow = SolarField.parameter.massFlow.min
        mode2(&status, loop: loop, mode: mode, meteo: meteo)
      }
    // defocus SCAs to prevent overheating
    
    case let massFlow where massFlow.isNearZero: // HCE loses heat
      Plant.thermal.dump = 0
      Plant.thermal.overtemp_dump = 0
      if case .freezeProtection = status.heater.operationMode {
        hce.massFlow = SolarField.parameter.massFlow.min
        mode2(&status, loop: loop, mode: mode, meteo: meteo)
      } else {
        // status = LastHTF
        freezeProtectionCheck(&status.solarField)
      }
      
    default: // massFlow is witheatIn acceptable limits and Tout is as required
      
      status.solarField.inFocus = 1.0
      // FIXME  status.massFlow = massFlow
      // changed to htf.maxTemperature to reach max temp possible
      hce.temperature.outlet = htf.maxTemperature
      Plant.thermal.dump = 0
      Plant.thermal.overtemp_dump = 0
      //mode = .operating
      averageTemperture = Temperature((hce.temperature.outlet
        + hce.temperature.inlet).kelvin / 2)
      
      let areadens = htf.density(averageTemperture) * .pi
        * Collector.parameter.rabsOut ** 2 / Collector.parameter.aperture
      
      Actime = Int(areadens * Design.layout.solarField
        * Double(SolarField.parameter.numberOfSCAsInRow) * 2
        * Collector.parameter.areaSCAnet / hce.massFlow.rate) // [sec]
    }
  }
  
  /// HTF-temp. dependent on constant mass-flow
  public static func mode2(
    _ status: inout Plant.PerformanceData,
    loop: SolarField.Loop, mode: Collector.OperationMode,
    meteo: MeteoData) {
    
    let ICosTheta = Double(meteo.dni) * status.collector.cosTheta
    let ambientTemperature = Temperature(celsius: meteo.temperature)

    var Interval = 1
    var Zoom = 1
    
    var timePast = 0
    
    var hce = status.solarField.loops[loop.rawValue]
    defer { status.solarField.loops[loop.rawValue] = hce }
    var temperatureNow = hce.temperature.inlet
    var temperatureLast = hce.temperature.outlet
    
    outerIteration: for _ in 1 ... 4 {
      
      temperatureNow = hce.temperature.inlet
      var inFocusLoop = 0.0
      innerIteration: for innerIteration in 1 ... 100 {
        
        let averageTemperture =
          temperatureNow.median(hce.temperature.inlet)
        
        let areadens = htf.density(averageTemperture) * .pi
          * Collector.parameter.rabsInner ** 2 / Collector.parameter.aperture
        
        // Calculate time HTF needs to pass through HCE loop
        if hce.massFlow.isNearZero {
          // means mass flow is reduced to almost zero due to no demand and full storage
          timePast = period
        } else {
          
          timePast = Int(areadens * Design.layout.solarField
            * Double(SolarField.parameter.numberOfSCAsInRow) * 2
            * Collector.parameter.areaSCAnet / hce.massFlow.rate) // [sec]
          
          if Actime < 0 { timePast += Actime }
        }
        
        if innerIteration == 1 {
          inFocusLoop = status.solarField.inFocus.ratio
          // Reduce dumping in order to reach design temperature.
          // I.e. dumping happens on first collector(s) and not last on loop
        }
        
        if temperatureNow.kelvin < 0.9974 * htf.maxTemperature.kelvin {
          // solarField.InFocus > 0, solarField.InFocus < 0.95 {
          
          inFocusLoop = Ratio(min(1, inFocusLoop * 1.01)).ratio
          // reduce dumping in 1%  limit it to 1
          Plant.thermal.dump = dheat_now * Design.layout.solarField
            * Double(SolarField.parameter.numberOfSCAsInRow) * 2
            * Collector.parameter.areaSCAnet
            * (1 - inFocusLoop) / 1_000_000 // [MW]
        }
        
        let heatin = ICosTheta * status.collector.efficiency
          * inFocusLoop * Plant.availability.value.solarField.ratio
        // Net dheat (+)=in or (-)=out HCE
        
        if heatin > 0 {
          
          status.solarField.heatLossHCE = Collector.parameter.IntradiationLosses
            ? HCE.radiationLosses(status, temperature:
              (temperatureNow + 10.0, hce.temperature.inlet + 10.0),
              meteo: meteo)
            : HCE.radiationLosses(status, temperature:
              (averageTemperture + 10.0, ambientTemperature + 30.0),
              meteo: meteo)
          
          status.solarField.heatLossHCE *= Simulation.parameter.adjustmentFactor.heatLossHCE
          
          status.solarField.HL = status.solarField.heatLossHCE + SolarField.pipeHeatLoss(
            averageTemperture, ambient: ambientTemperature)
          
          if !SolarField.parameter.HLDump && !SolarField.parameter.HLDumpQuad {
            status.solarField.HL *= Simulation.parameter.adjustmentFactor.heatLossHTF // FIXME * solarField.InFocus
          } else {
            /* FIXME if !SolarField.parameter.HLDumpQuad {
             solarField.HL *= Simulation.parameter.adjustmentFactor.heatLossHTF
             // solarField.InFocus not considered as on validated version (2.2) if selected by user
             } else if SolarField.parameter.layout == "H"
             && SolarField.parameter.HLDumpQuad
             && solarField.InFocus > 0.75 {
             solarField.HL *= Simulation.parameter.adjustmentFactor.heatLossHTF
             } else if SolarField.parameter.layout == "H"
             && SolarField.parameter.HLDumpQuad
             && solarField.InFocus > 0.5 {
             // between 50% and 75% dumping
             solarField.HL *= Simulation.parameter.adjustmentFactor.heatLossHTF * 0.75
             // 25% of the heat losses can be reduced -> 1 quadrant not in operation
             } else if SolarField.parameter.layout == "H"
             && SolarField.parameter.HLDumpQuad
             && solarField.InFocus > 0.25 {
             // between 25% and 50% dumping
             solarField.HL *= Simulation.parameter.adjustmentFactor.heatLossHTF * 0.5
             // 50% of the heat losses can be reduced -> 1 quadrant not in operation
             } else if SolarField.parameter.layout == "H"
             && SolarField.parameter.HLDumpQuad
             && solarField.InFocus > 0 {
             // between 100% and 75% dumping
             solarField.HL *= Simulation.parameter.adjustmentFactor.heatLossHTF * 0.25
             // 75% of the heat losses can be reduced -> 1 quadrant not in operation
             } else if SolarField.parameter.layout == "I"
             && SolarField.parameter.HLDumpQuad
             && solarField.InFocus > 0.5 {
             solarField.HL *= Simulation.parameter.adjustmentFactor.heatLossHTF
             } else if SolarField.parameter.layout == "I"
             && SolarField.parameter.HLDumpQuad
             && solarField.InFocus > 0 {
             // between 0% and 50% dumping
             solarField.HL *= Simulation.parameter.adjustmentFactor.heatLossHTF * 0.5
             // 50% of the heat losses can be reduced -> 1/2 SF not in operation
             } else {
             fatalError("dumping case not defined")
             }
             */
          }
        } else { // No Massflow
          
          status.solarField.heatLossHCE = Collector.parameter.IntradiationLosses
            ? HCE.radiationLosses(status, temperature:
              (averageTemperture, ambientTemperature + 20.0),
              meteo: meteo)
              * Simulation.parameter.adjustmentFactor.heatLossHCE
            : HCE.radiationLosses(status, temperature:
              (temperatureNow + 10.0, hce.temperature.inlet + 10.0),
              meteo: meteo)
          status.solarField.heatLossHCE *= Simulation.parameter.adjustmentFactor.heatLossHCE
          
          status.solarField.HL = status.solarField.heatLossHCE
          status.solarField.HL += SolarField.pipeHeatLoss(
            averageTemperture, ambient: ambientTemperature)
            * Simulation.parameter.adjustmentFactor.heatLossHTF
        }
        
        status.solarField.ITA = Double(meteo.dni)
          * status.collector.cosTheta * status.collector.efficiency

        let dheat = heatin - status.solarField.HL
        
        if status.collector.cosTheta > 0 {
          status.solarField.loopEta = status.collector.efficiency
          
          status.solarField.loopEta -= Collector.parameter.IntradiationLosses
            ? HCE.radiationLosses(status, temperature:
              (averageTemperture + 10.0, ambientTemperature + 30.0),
              meteo: meteo)
            : HCE.radiationLosses(status, temperature:
              (temperatureNow + 10.0, hce.temperature.inlet + 10.0),
              meteo: meteo)
          
          status.solarField.loopEta *= Simulation.parameter.adjustmentFactor.heatLossHCE / ICosTheta
          
          status.solarField.ETA = status.collector.efficiency
            - status.solarField.HL / ICosTheta
        } else {
          status.solarField.loopEta = 0
          status.solarField.ETA = 0
        }

        let dQperSqm = dheat * hourFraction / 1_000
        // Heat collected or lost during the flow through a whole loop [kJ/sqm]
        let dQperkg = dQperSqm / areadens // Change kJ/sqm to kJ/kg:
        // Inaccuracy: The Areadens has changed caused by higher Temp., but we must
        // take the old in order to calculate the new => iteration
        
        // SWAP Last, now
        let temp = temperatureLast
        temperatureLast = temperatureNow
        temperatureNow = temp
        
        switch dQperkg {
        // Calc. new Temp.
        case let q where q > 0:
          temperatureNow = htf.temperatureDelta(dQperkg, hce.temperature.inlet)
        case 0:
          temperatureNow = temperatureLast
        default:
          let Qperkg = htf.heatDelta(
            hce.temperature.inlet, Temperature(celsius: meteo.temperature))
          
          temperatureNow = htf.temperatureDelta(
            Qperkg + dQperkg, Temperature(celsius: meteo.temperature))
        }
        
        // Flow is to low, dumping required
        Plant.thermal.overtemp_dump = temperatureNow > htf.maxTemperature
          ? (hce.massFlow.rate / 3 * htf.heatDelta(
            temperatureNow, htf.maxTemperature) / 1_000) // MWt
          : 0.0
        
        temperatureNow = min(htf.maxTemperature, temperatureNow)
        temperatureLast = min(htf.maxTemperature, temperatureLast)
        
        
        if abs(temperatureNow.kelvin - temperatureLast.kelvin)
          < Simulation.parameter.tempTolerance.kelvin,
          temperatureNow.kelvin > 0.9974 * htf.maxTemperature.kelvin
            && status.solarField.inFocus.ratio < 0.95
            || status.solarField.inFocus.ratio > 0.95
            || status.solarField.inFocus.ratio == 0 {
          break innerIteration
        }
      } // innerLoop 
      
      if hce.massFlow.rate > 0 {
        break
      }
      
      if temperatureNow < htf.freezeTemperature + Simulation.parameter.dfreezeTemperaturePump {
        if (htf.freezeTemperature.kelvin + Simulation.parameter.dfreezeTemperaturePump.kelvin
          - temperatureNow.kelvin) < Simulation.parameter.tempTolerance.kelvin * 100 { break }
        Interval = Interval / 2
        Zoom = Zoom - Interval
        // Shorten interval
      } else {
        Interval = Interval / 2
        Zoom = Zoom + Interval // Elongate interval
      }
    }
    
    hce.temperature.outlet = temperatureNow

    Plant.thermal.dump += Plant.thermal.overtemp_dump
  }
}
