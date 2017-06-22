//
//  Copyright (c) 2017 Daniel Müllenborn. All rights reserved.
//  Distributed under the The Non-Profit Open Software License version 3.0
//  http://opensource.org/licenses/NPOSL-3.0
//
//  This project is NOT free software. It is open source, you are allowed to
//  modify it (if you keep the license), but it may not be commercially
//  distributed other than under the conditions noted above.
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
var period = 0
var dheat_now = 0.0

enum HCE {
  
  public static func operate(mode: Collector.PerformanceData.OperationMode,
                             solarField: inout SolarField.PerformanceData,
                             collector: inout Collector.PerformanceData,
                             heatFlow: inout HeatFlow,
                             date: Date,
                             meteo: MeteoData) {
    
    let ICosTheta = Double(meteo.dni) * cos(collector.theta)
    
    switch mode {

    case .noOperation:
      period = 300
      freezeProtectionCheck(status: &solarField)

    case .operating:
      period = 300
      if meteo.windSpeed > SolarField.parameter.maxWind {
        solarField.inFocus = 0.0
      }
      mode1(solarField: &solarField,
            collector: &collector,
            heatFlow: &heatFlow,
            date: date,
            meteo: meteo)

    case .variable, .freezeProtection:

      if meteo.windSpeed > SolarField.parameter.maxWind
        || ICosTheta * Collector.efficiency(meteo: meteo, direction: 0) < Simulation.parameter.minInsolation {
        freezeProtectionCheck(status: &solarField) // on first call
      } else {
        mode1(solarField: &solarField,
              collector: &collector,
              heatFlow: &heatFlow,
              date: date,
              meteo: meteo)
      }

    case .fixed:
      mode2(solarField: &solarField,
            collector: &collector,
            heatFlow: &heatFlow,
            date: date,
            meteo: meteo)
    }
  }

  public static func freezeProtectionCheck(status: inout SolarField.PerformanceData) {
    status.inFocus = 0.0

    let TempFP = htf.freezeTemperature
      + Simulation.parameter.dfreezeTemperaturePump
      + Simulation.parameter.tempTolerance
    if status.temperature.inlet < TempFP || status.temperature.outlet < TempFP {
      status.massFlow = SolarField.parameter.antiFreezeFlow
      status.operationMode = .freezeProtection
    } else {
      status.operationMode = .noOperation
      // status = LastHTF
      status.massFlow = 0
    }
  }

  // Radiation losses per m2 Aperture; now with the new losses that take into
  // account the percentage of HCE that are broken, lost vacuum and fluorescent
  public static func radiationLosses(_ temperature: (Double, Double),
                                     date: Date,
                                     meteo: MeteoData) -> Double {
    let collector = Collector.parameter
    let month = date.month
    let BreakHCE = Plant.availability[month].breakHCE.value // Percent /100 in LoadAvlMaintnc
    let AirHCE = Plant.availability[month].airHCE.value // Percent /100 in LoadAvlMaintnc
    let FluorHCE = Plant.availability[month].fluorHCE.value // Percent /100 in LoadAvlMaintnc
    
    let deltaTemperature: Double
    if !collector.newFunction {
      deltaTemperature = temperature.0 - temperature.1 + 10
    } else {
      deltaTemperature = (temperature.0 + temperature.1) / 2 - (Double(meteo.temperature) + 30) + 10
    }

    var vacuumHeatLoss: Double
    let endLossFactor: Double

    let insulation = 1.0 // ICosTheta * Collector.efficiency  // Insulation to Absorber!
    let sigma = 0.00000005667

    if !collector.newFunction {
      if collector.name.contains("LS2") {
        vacuumHeatLoss = 0.081 - 0.04752 * deltaTemperature + 0.0006787
          * deltaTemperature ** 2 + 0.0007403 * insulation
        vacuumHeatLoss += 0.00003582 * deltaTemperature * insulation
          + 0.00000014125 * deltaTemperature ** 2 * insulation
        endLossFactor = 1.3 // added in order to differenciate with LS2 collector
      } else if collector.name.contains("SKAL-ET") {
        // temperature.0+10 considers that average loop temperature is higher than (T_in + T_out)/2
        vacuumHeatLoss = sigma * 2 * .pi * collector.rabsOut
          * (temperature.0 ** 4 - temperature.1 ** 4)
        vacuumHeatLoss *= (collector.emissionHCE[0]
          + collector.emissionHCE[1] * temperature.0) / collector.aperture
        let al = 0.7 * 2 * .pi * collector.rabsOut
          * (temperature.0 - temperature.1) / collector.aperture
        vacuumHeatLoss = vacuumHeatLoss + al // added here and not for LS2 collector
        endLossFactor = 1 // added in order to differenciate with LS2 collector
      } else if collector.name.contains("PCT_validation") { // test
        vacuumHeatLoss = sigma * 2 * .pi * collector.rabsOut
          * (temperature.0 ** 4 - temperature.1 ** 4)
        vacuumHeatLoss *= (collector.emissionHCE[0] + collector.emissionHCE[1]
          * (temperature.0 + 10)) / collector.aperture
        endLossFactor = 1.3 // added in order to differenciate with LS2 collector
      } else {
        // other types than LS-2!!
        // old RadLoss as from LUZ Model
        // temperature.0+10 considers that average loop temperature is higher than (T_in + T_out)/2
        switch collector.absorber {
        case .schott:
          vacuumHeatLoss = sigma * 2 * .pi * collector.rabsOut
            * (temperature.0 ** 4 - temperature.1 ** 4)
          vacuumHeatLoss *= (collector.emissionHCE[0]
            + collector.emissionHCE[1] * (temperature.0 + 10)) / collector.aperture
        case .rio:
          vacuumHeatLoss = (0.00001242 * temperature.0 ** 3 - 0.01864091
            * temperature.0 ** 2 + 9.76467705 * temperature.0 - 1714.03)
          vacuumHeatLoss *= 2 * .pi * collector.rabsOut / collector.aperture
        }
        // these losses were somehow lower than vacuumHeatLoss used below, but only about 10%
        let al = 0.7 * 2 * .pi * collector.rabsOut
          * (temperature.0 - temperature.1) / collector.aperture
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
          * (temperature.0 ** 3 - temperature.1 ** 3) + 1 / 2
          * collector.emissionHCE[1] * (temperature.0 ** 2 - temperature.1 ** 2)
          + collector.emissionHCE[0] * (temperature.0 - temperature.1))
          / (temperature.0 - temperature.1)
      } else { // during FP?
        // check, resulting emissivity too low without c2!
        Ebs_HCE = collector.emissionHCE[0]
          + collector.emissionHCE[1] * (temperature.0)
      }

      if temperature.1 != temperature.0 {
        // check what if temperature.1 < temperature.0!
        vacuumHeatLoss = sigma / (1 / Ebs_HCE + collector.rabsOut
          / collector.rglas * (1 / collector.glassEmission - 1))
          * 2 * .pi * collector.rabsOut / collector.aperture
          * (1 / 5 * (temperature.0 ** 5 - temperature.1 ** 5)
            + (Double(meteo.temperature) + 30) ** 4
            * (temperature.1 - temperature.0)) / (temperature.0 - temperature.1)
      } else {
        vacuumHeatLoss = sigma * 2 * .pi * collector.rabsOut
        vacuumHeatLoss *= (((temperature.1 + temperature.0) / 2) ** 4
          - (Double(meteo.temperature) + 30) ** 4)
        vacuumHeatLoss *= (collector.emissionHCE[0]
          + collector.emissionHCE[1] * temperature.1) / collector.aperture
      }
      var al = 0.7 * 2 * .pi * collector.rabsOut
      al *= ((temperature.1 + temperature.0) / 2
        - (Double(meteo.temperature) + 30)) / collector.aperture
      vacuumHeatLoss += al
      endLossFactor = 1
    }

    var RLHP = 0.081 - 0.04752 * deltaTemperature + 0.0006787
      * deltaTemperature ** 2 + 0.0007403 * insulation
    RLHP += 0.00003582 * deltaTemperature * insulation
      + 0.00000014125 * deltaTemperature ** 2 * insulation

    var AddHLAir = -0.114 + 0.1396 * deltaTemperature
      + 0.000006823 * deltaTemperature ** 2 - 0.002074 * insulation
    AddHLAir += 0.0000602 * deltaTemperature * insulation
      - 0.0000001624 * deltaTemperature ** 2 * insulation

    let AddHLBare = 0.416 * deltaTemperature - 0.000056
      * deltaTemperature ** 2 + 0.0666 * deltaTemperature // * windSpeed

    return (vacuumHeatLoss + AddHLAir * (AirHCE + FluorHCE)
      + AddHLBare * BreakHCE) * endLossFactor
    // * 1.3
    // Faktor 1.3 due to end HCE end losses
    // "* endLossFactor" added in order to differenciate with LS2 collector
  }

  public static func mode1(
    solarField: inout SolarField.PerformanceData,
    collector: inout Collector.PerformanceData,
    heatFlow: inout HeatFlow,
    date: Date, meteo: MeteoData) {
    
    // Average HTF temp. in loop [K]
    var averageTemperture = (htf.maxTemperature + collector.temperature.inlet) / 2
    // Delta heat in HCE[W/m2]
    let heatin = collector.theta
      * Collector.efficiency(meteo: meteo, direction: 0)
      * Plant.availability[date.month].solarField.value
    // Delta heat in HCE[W/m2] // added to calculate Q_dump
    let heatin_now = cos(collector.theta)
      * Collector.efficiency(meteo: meteo, direction: 0)
      * Plant.availability[date.month].solarField.value

    if Collector.parameter.IntradiationLosses {
      solarField.heatLossHCE = HCE.radiationLosses(
        (averageTemperture + 10, Double(meteo.temperature) + 30),
        date: date, meteo: meteo)
        * Simulation.parameter.adjustmentFactor.heatLossHCE
    } else { // 120126: new formula added
      solarField.heatLossHCE = HCE.radiationLosses(
        (htf.maxTemperature + 10, collector.temperature.inlet + 10),
        date: date, meteo: meteo)
        * Simulation.parameter.adjustmentFactor.heatLossHCE
    }

    solarField.HL = solarField.heatLossHCE + SolarField.pipeHeatLoss(
      averageTemperture, ambient: Double(meteo.temperature))
    solarField.HL *= Simulation.parameter.adjustmentFactor.heatLossHTF // Adjustment Parameter

    // FIXME solarField.ITA = ICosThetaMax * Collector.efficiency

    let dheat = heatin - solarField.HL
    let dheat_now = heatin_now - solarField.HL
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

    collector.massFlow = dheat / 1_000 / htf.heatTransfered(
      htf.maxTemperature, collector.temperature.inlet)
    // [kg/(sec sqm)] = [J/(sec sqm)/1000] / [kJ/kg]
    collector.massFlow = collector.massFlow * Design.layout.solarField
      * Double(SolarField.parameter.numberOfSCAsInRow) * 2
      * Collector.parameter.areaSCAnet // - [kg/s] -

    switch collector.massFlow { // Check if mass-flow is within acceptable limits

    case 0: // HCE loses heat
      heatFlow.dump = 0
      heatFlow.overtemp_dump = 0
      if case .operating = collector.operationMode {
        collector.massFlow = SolarField.parameter.massFlow.min
        // mode2()
      } else {
       // status = LastHTF
       freezeProtectionCheck(status: &solarField)
      }

    case let massFlow where massFlow > SolarField.parameter.massFlow.min:
      heatFlow.dump = 0
      heatFlow.overtemp_dump = 0
      if case .normal = Heater.status.operationMode,
        massFlow > SolarField.parameter.massFlow.max * 0.05 {
        // pumps are working over massFlow.min
        solarField.inFocus = 1.0
        collector.massFlow = massFlow
        collector.temperature.outlet = htf.maxTemperature
        // changed to htf.maxTemperature to reach max temp possible
        averageTemperture = (collector.temperature.outlet
          + collector.temperature.inlet) / 2
        let areadens = htf.density(averageTemperture) * .pi
          * Collector.parameter.rabsOut ** 2 / Collector.parameter.aperture
        Actime = Int(areadens * Design.layout.solarField
          * Double(SolarField.parameter.numberOfSCAsInRow) * 2
          * Collector.parameter.areaSCAnet / collector.massFlow) // [sec]

        Actime = period
      } else if case .normal = Heater.status.operationMode {
        solarField.inFocus = 1.0
        collector.massFlow = SolarField.parameter.massFlow.max * 0.05
        mode2(solarField: &solarField, collector: &collector,
              heatFlow: &heatFlow, date: date, meteo: meteo)
      } else {
        solarField.inFocus = 1.0
        collector.massFlow = SolarField.parameter.massFlow.min
        mode2(solarField: &solarField, collector: &collector,
              heatFlow: &heatFlow, date: date, meteo: meteo)
      }
    // defocus SCAs to prevent overheating
    case let massFlow where massFlow > SolarField.parameter.massFlow.max:
      // Damped heat: The HL have to be added because they are independent from
      // the SCAs in focus. HL must be subtracted afterwards again.
      solarField.inFocus = Ratio(SolarField.parameter.massFlow.max / massFlow)
      // [MW] added to calculate Q_dump with instantaneous irradiation
      heatFlow.dump = dheat_now * Design.layout.solarField
        * Double(SolarField.parameter.numberOfSCAsInRow) * 2
        * Collector.parameter.areaSCAnet
        * (1 - solarField.inFocus.value) / 1_000_000
      
      heatFlow.overtemp_dump = 0
      collector.massFlow = SolarField.parameter.massFlow.max
      collector.temperature.outlet = htf.maxTemperature // changed to htf.maxTemperature to reach max temp possible
      collector.operationMode = .operating
      // The density [kg/cubm] must be changed to area-density [kg/sqm]:
      // (1)  Dens(T)[kg/cubm] * 1m *  .pi * Rabsout[m]^2 =: M[kg]   and
      // (2)  M[kg] / (Aperture[m] * 1m) =: Area-density[Kg/sqm]    ==>

      averageTemperture = (collector.temperature.outlet
        + collector.temperature.inlet) / 2
      let areadens = htf.density(averageTemperture) * .pi
        * Collector.parameter.rabsOut ** 2 / Collector.parameter.aperture
      Actime = Int(areadens * Design.layout.solarField
        * Double(SolarField.parameter.numberOfSCAsInRow)
        * 2 * Collector.parameter.areaSCAnet / collector.massFlow)
      // [sec] calculation of Actime below commented, not needed ince is set to abd in next step

      Actime = period

    default: // massFlow is within acceptable limits and Tout is as required

      solarField.inFocus = 1.0
      // FIXME  status.massFlow = massFlow
      collector.temperature.outlet = htf.maxTemperature // changed to htf.maxTemperature to reach max temp possible
      heatFlow.dump = 0
      heatFlow.overtemp_dump = 0
      collector.operationMode = .operating
      averageTemperture = (collector.temperature.outlet
        + collector.temperature.inlet) / 2
      let areadens = htf.density(averageTemperture) * .pi
        * Collector.parameter.rabsOut ** 2 / Collector.parameter.aperture
      Actime = Int(areadens * Design.layout.solarField
        * Double(SolarField.parameter.numberOfSCAsInRow) * 2
        * Collector.parameter.areaSCAnet / collector.massFlow) // [sec]
    }
  }

  /// HTF-temp. dependent on constant mass-flow
  public static func mode2(
    solarField: inout SolarField.PerformanceData,
    collector: inout Collector.PerformanceData,
    heatFlow: inout HeatFlow,
    date: Date, meteo: MeteoData) {
    
    let ICosTheta = Double(meteo.dni) * cos(collector.theta)
    
    var Interval = 1
    var Zoom = 1
    
    var timePast = 0
    
    var temperatureNow = collector.temperature.inlet
    var temperatureLast = collector.temperature.outlet
    
    outerIteration: for _ in 1 ... 3000 {
      
      temperatureNow = collector.temperature.inlet
      var inFocusLoop = 0.0
      innerIteration: for innerIteration in 1 ... 100 {
        
        let averageTemperture = (temperatureNow + collector.temperature.inlet) / 2 // - Calc. avg Temp. and Areadens
        let areadens = htf.density(averageTemperture) * .pi
          * Collector.parameter.rabsInner ** 2 / Collector.parameter.aperture
        
        // Calculate time HTF needs to pass through HCE loop
        if collector.massFlow == 0 {

          if Collector.parameter.name.contains("PCT_validation") {
            timePast = period // meteo.period * Zoom // as it was on validated version 2.2
          } else {
            timePast = period // was wrong before imet.period * Zoom / [sec] HTF is in HCE for Actime minutes
          }
          
        } else {
          // means mass flow is reduced to almost zero due to no demand and full storage
          if solarField.massFlow <= 0.001 * SolarField.parameter.massFlow.max {
            timePast = period
          } else {
            timePast = Int(areadens * Design.layout.solarField
              * Double(SolarField.parameter.numberOfSCAsInRow) * 2
              * Collector.parameter.areaSCAnet / collector.massFlow) // [sec]
          }

          if Actime < 0 { timePast += Actime }
        }
        
        if innerIteration == 1 {
        inFocusLoop = solarField.inFocus.value
        // Reduce dumping in order to reach design temperature.
        // I.e. dumping happens on first collector(s) and not last on loop
        }
        
        if temperatureNow < 0.9974 * htf.maxTemperature {
           // solarField.InFocus > 0, solarField.InFocus < 0.95 {

          inFocusLoop = Ratio(inFocusLoop * 1.01).value
          // reduce dumping in 1%  limit it to 1
          heatFlow.dump = dheat_now * Design.layout.solarField
            * Double(SolarField.parameter.numberOfSCAsInRow) * 2
            * Collector.parameter.areaSCAnet
            * (1 - inFocusLoop) / 1_000_000 // [MW]
        }

        let heatin = ICosTheta * Collector.efficiency(meteo: meteo, direction: 0)
          * inFocusLoop * Plant.availability[date.month].solarField.value
        // Net dheat (+)=in or (-)=out HCE

        if heatin > 0 {
          
          solarField.heatLossHCE = Collector.parameter.IntradiationLosses
            ? HCE.radiationLosses(
              (temperatureNow + 10, collector.temperature.inlet + 10),
              date: date, meteo: meteo)
            : HCE.radiationLosses(
              (averageTemperture + 10, Double(meteo.temperature) + 30),
              date: date, meteo: meteo)
          
          solarField.heatLossHCE *= Simulation.parameter.adjustmentFactor.heatLossHCE
          
          solarField.HL = solarField.heatLossHCE + SolarField.pipeHeatLoss(
            averageTemperture, ambient: Double(meteo.temperature))

          if !SolarField.parameter.HLDump && !SolarField.parameter.HLDumpQuad {
            solarField.HL *= Simulation.parameter.adjustmentFactor.heatLossHTF // FIXME * solarField.InFocus
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
          
          solarField.heatLossHCE = Collector.parameter.IntradiationLosses
            ? HCE.radiationLosses(
              (averageTemperture, Double(meteo.temperature) + 20),
              date: date, meteo: meteo)
              * Simulation.parameter.adjustmentFactor.heatLossHCE
            : HCE.radiationLosses(
              (temperatureNow + 10, collector.temperature.inlet + 10),
              date: date, meteo: meteo)
          solarField.heatLossHCE *= Simulation.parameter.adjustmentFactor.heatLossHCE
          
          solarField.HL = solarField.heatLossHCE
          solarField.HL += SolarField.pipeHeatLoss(
            averageTemperture, ambient: Double(meteo.temperature))
            * Simulation.parameter.adjustmentFactor.heatLossHTF
        }
        
        solarField.ITA = ICosTheta * Collector.efficiency(meteo: meteo, direction: 0)
        let dheat = heatin - solarField.HL
        if ICosTheta > 0 {
          collector.LoopEta = Collector.efficiency(meteo: meteo, direction: 0)
          collector.LoopEta -= Collector.parameter.IntradiationLosses
            ? HCE.radiationLosses(
              (averageTemperture + 10.0, Double(meteo.temperature) + 30),
              date: date, meteo: meteo)
            : HCE.radiationLosses(
              (temperatureNow + 10.0, collector.temperature.inlet + 10),
              date: date, meteo: meteo)
          collector.LoopEta *= Simulation.parameter.adjustmentFactor.heatLossHCE / ICosTheta
          solarField.ETA = Collector.efficiency(meteo: meteo, direction: 0)
            - solarField.HL / ICosTheta
        } else {
          collector.LoopEta = 0
          solarField.ETA = 0
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
          temperatureNow = htf.temperature(dQperkg, collector.temperature.inlet)
        case 0:
          temperatureNow = temperatureLast
        default:
          let Qperkg = htf.heatTransfered(collector.temperature.inlet,
                                          Double(meteo.temperature))
          temperatureNow = htf.temperature(Qperkg + dQperkg,
                                           Double(meteo.temperature))
        }

        // Flow is to low, dumping required
        heatFlow.overtemp_dump = temperatureNow > htf.maxTemperature
          ? (collector.massFlow / 3 * htf.heatTransfered(
            temperatureNow, htf.maxTemperature) / 1_000) // MWt
          : 0.0

        temperatureNow = min(htf.maxTemperature, temperatureNow)
        temperatureLast = min(htf.maxTemperature, temperatureLast)
        
        
        if abs(temperatureNow - temperatureLast) < Simulation.parameter.tempTolerance,
          temperatureNow > 0.9974 * htf.maxTemperature && solarField.inFocus.value < 0.95
          || solarField.inFocus.value > 0.95 || solarField.inFocus.value == 0 {
          break innerIteration
        }
      } // innerLoop 

      if collector.massFlow > 0 { break }

      if temperatureNow < htf.freezeTemperature + Simulation.parameter.dfreezeTemperaturePump {
        if (htf.freezeTemperature + Simulation.parameter.dfreezeTemperaturePump
          - temperatureNow) < Simulation.parameter.tempTolerance * 100 { break }
        Interval = Interval / 2
        Zoom = Zoom - Interval
        // Shorten interval
      } else {
        Interval = Interval / 2
        Zoom = Zoom + Interval // Elongate interval
      }
    }

    collector.temperature.outlet = temperatureNow

    heatFlow.dump += heatFlow.overtemp_dump
  }
}
