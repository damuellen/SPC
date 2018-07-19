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

public struct Storage: Component {
  
  /// a struct for operation-relevant data of the storage
  public struct PerformanceData: HeatCycle {
    var name = ""
    var operationMode: OperationMode
    var temperature: (inlet: Temperature, outlet: Temperature)
    var temperatureTanks: (cold: Temperature, hot: Temperature)
    var massFlow: MassFlow
    var heatRelease: Double
    var mass: (cold: Double, hot: Double)
    var dTHTF_HotSalt, dTHTF_ColdSalt: Temperature
    var massSaltRatio: Double
    var StoTcoldTout: Double
    var minMass: Double
    var hSalt: (cold: Double, hot: Double)
    var massSalt: Double
    var heatStored: Double
    var heatLossStorage: Double
    var heatProductionLoad: Double
    
    public enum OperationMode: String, CustomStringConvertible {
      case noOperation, discharge, freezeProtection, ph, charging, no, ex, sc, fc
      
      public var description: String {
        return rawValue
      }
    }
  }
  
  static let initialState = PerformanceData(
    name: "",
    operationMode: .noOperation,
    temperature: (Simulation.initialValues.temperatureOfHTFinPipes,
                  Simulation.initialValues.temperatureOfHTFinPipes),
    temperatureTanks: (566.0, 666.0),
    massFlow: 0.0, heatRelease: 0,
    mass: (0,0),
    dTHTF_HotSalt: 0.0, dTHTF_ColdSalt: 0.0,
    massSaltRatio: 0,
    StoTcoldTout: 0,
    minMass: 0,
    hSalt: (0,0),
    massSalt: 0,
    heatStored: 0,
    heatLossStorage: 0,
    heatProductionLoad: 0
  )

  static var parameter: Parameter = ParameterDefaults.st
  
  public static func minmass(storage: Storage.PerformanceData) -> Double {
    switch parameter.definedBy {
      
    case .hours:
      let minmass = Design.layout.storage * parameter.dischargeToTurbine
        * heatExchanger.SCCHTFthermal * 1_000 * 3_600
        / (storage.hSalt.hot - storage.hSalt.cold)
      heatExchanger.temperature.h2o.inlet.max = Temperature(
        parameter.startLoad.hot * Design.layout.storage
          * heatExchanger.SCCHTFthermal * 1_000 * 3_600
          / (storage.hSalt.hot - storage.hSalt.cold) + minmass) // Factor 1.1
      heatExchanger.temperature.h2o.inlet.min = Temperature(
        parameter.startLoad.cold * Design.layout.storage
          * heatExchanger.SCCHTFthermal * 1_000 * 3_600
          / (storage.hSalt.hot - storage.hSalt.cold) + minmass)
      return minmass
      
    case .cap:
      let minmass = Design.layout.storage_cap
        * parameter.dischargeToTurbine * 1_000 * 3_600
        / (storage.hSalt.hot - storage.hSalt.cold)
      heatExchanger.temperature.h2o.inlet.max = Temperature(
        parameter.startLoad.hot * Design.layout.storage_cap * 1_000 * 3_600
          / (storage.hSalt.hot - storage.hSalt.cold) + minmass) // Factor 1.1
      heatExchanger.temperature.h2o.inlet.min = Temperature(
        parameter.startLoad.cold * Design.layout.storage_cap * 1_000 * 3_600
          / (storage.hSalt.hot - storage.hSalt.cold) + minmass)
      return minmass
      
    case .ton:
      let minmass = Design.layout.storage_ton * parameter.dischargeToTurbine * 1_000
      heatExchanger.temperature.h2o.inlet.max = Temperature(
        parameter.startLoad.hot * Design.layout.storage_ton * 1_000 + minmass)
      heatExchanger.temperature.h2o.inlet.min = Temperature(
        parameter.startLoad.cold * Design.layout.storage_ton * 1_000 + minmass)
      return minmass
    }
  }
  
  /// Calculates the parasitics of the gas turbine which only depends on the current load
  private static func parasitics(_ storage: inout PerformanceData) -> Double {
    
    var parasitics = 0.0
    var timeminutessum = 0
    var timeminutesold = 0

    var DesAuxIN = 0.0
    var DesAuxEX = 0.0
    // variables added to calculate TES aux. consumption :
    let Expn: Double
    let level: Double
    let level2: Double
    let lowCh: Double
    let lowDc: Double
    let time = TimeStep.zero
    if parameter.auxConsCurve {
      // old model:
      let rohMean = htf.density(storage.averageTemperature)
      let rohDP = htf.density(Temperature(
        (heatExchanger.temperature.htf.inlet.max
          + heatExchanger.temperature.htf.outlet.max).kelvin / 2))
      let PrL = parameter.pressureLoss * rohDP / rohMean
        * (storage.massFlow.share(of: parameter.massFlow).ratio) ** 2
      parasitics = PrL * storage.massFlow.rate / rohMean / parameter.pumpEfficiency / 10E6
      
      if case .ex = storage.operationMode {
        //   parasitics = 2 * parasitics * 2.463 // 3 Änderung Indien // * 2.463 for Andasol-3
        parasitics = parasitics * parameter.DischrgParFac // added as user input, by no input stoc.DischrgParFac = 2
        timeminutessum = 0
      } else if case .no = storage.operationMode {
        if time.minute != timeminutesold { // formula changed
          if time.minute == 0 { // new hour
            timeminutessum += 60 + time.minute - timeminutesold // timeminutessum + 5
          } else {
            timeminutessum += time.minute - timeminutesold
          }
        }
        for (_, power) in zip(parameter.heatTracingTime, parameter.heatTracingPower) {
          // FIXME if timeminutessum > time * 60 {
          parasitics += power / 1_000
          // }
        }
      } else {
        // parasitics = parasitics // Indien 1.5
        timeminutessum = 0
      }
      timeminutesold = time.minute
    } else { // new model
      // all this shall be done only one time
      // definedBy internal parameters
      Expn = 3 // exponent for nth order decay of aux power consumption
      level = 0.35 // accounting for different head for certain charge levels (e.g. charge mode 0% level -> 35 % less Aux. Power)
      level2 = 0.2 // accounting for a reduction in Aux. Power for low charge level and low flow ->20% less
      lowCh = 0.12 // minimal aux. power consumption for very low salt flows in charge mode
      lowDc = 0.25 // minimal aux. power consumption for very low salt flows in discharge mode
      DesAuxEX = 0.29 // user input TES parasitics for design case during discharge
      DesAuxIN = 0.57 // user input TES parasitics for design case during charge
      
      // calculate design salt massflows:
      storage.hSalt.hot = salt.enthalpy(parameter.designTemperature.hot)
      
      storage.hSalt.cold = salt.enthalpy(parameter.designTemperature.cold)
      // charge:
      let designChargingthermal = (parameter.massFlow.rate * htf.heatDelta(
        parameter.designTemperature.hot + storage.dTHTF_HotSalt,
        parameter.designTemperature.cold + storage.dTHTF_ColdSalt) / 1_000)
        * parameter.heatExchangerEfficiency
      
      var DesINmassSalt = designChargingthermal
        / (storage.hSalt.hot - storage.hSalt.cold) * 1_000 // kg/s
      DesINmassSalt *= hourFraction * 3_600 // kg in time step (5 minutes)
      // discharge:
      let QoutLoad = parameter.fixedLoadDischarge == 0
        ? Ratio(0.97)
        : Ratio(parameter.fixedLoadDischarge)
      
      let heatexDes = (((solarField.massFlow.max - parameter.massFlow)
        .adjusted(with: QoutLoad).rate
        / parameter.heatExchangerEfficiency) * htf.heatDelta(
          parameter.designTemperature.hot - storage.dTHTF_HotSalt,
          parameter.designTemperature.cold - storage.dTHTF_ColdSalt) / 1_000)
        * parameter.heatExchangerEfficiency // design charging power

      var DesEXmassSalt = heatexDes / (storage.hSalt.hot - storage.hSalt.cold) // kg/s
      DesEXmassSalt *= hourFraction * 3_600 * 1_000// kg in time step (5 minutes)
      // all this shall be done only one time_____________________________________________________
      
      if case .ex = storage.operationMode {
        storage.massSaltRatio = (storage.massSalt / DesEXmassSalt)
        // if storage.massSaltRatio > 1, case .charging = previous?.operationMode {
        // storage.massSaltRatio = 1
        // has to be check in detail how to determine salt mass flow if it's the first discharge after charging!!
        // }
        parasitics = ((1 - lowDc) * DesAuxEX
          * storage.massSaltRatio ** Expn + lowDc * DesAuxEX)
          * (1 - level * storage.heatRelease)
          * ((1 - level2) + level2 * storage.massSaltRatio)
        timeminutessum = 0
        
      } else if case .charging = storage.operationMode {
        storage.massSaltRatio = (storage.massSalt / DesINmassSalt)
        // has to be check in detail how to determine salt mass flow if it's the first charge after discharging!!
        //if let previousMode = Storage.previous?.operationMode,
        //  case .ex = previousMode {
        //  storage.massSaltRatio = 1
        //}
        parasitics = ((1 - lowCh) * DesAuxIN
          * storage.massSaltRatio ** Expn + lowCh * DesAuxIN)
          * ((1 - level) + level * storage.heatRelease)
          * ((1 - level2) + level2 * storage.massSaltRatio)
        timeminutessum = 0
        // FIXME storage.OldOpMode = .in
      } else if case .noOperation = storage.operationMode {
        parasitics = 0
        let timeminutessum = 0.0
        if time.minute != timeminutesold {
          if time.minute == 0 { // new hour
            // FIXME timeminutessum = timeminutessum + 60 + time.minutes! - timeminutesold // timeminutessum + 5
          } else {
            // FIXME  timeminutessum = timeminutessum + time.minutes! - timeminutesold
          }
        }
        // new heat tracing defined by user:
        for (time, pow) in zip(parameter.heatTracingTime, parameter.heatTracingPower) {
          if timeminutessum > time * 60 {
            parasitics += pow / 1_000
          }
        }
      }
      timeminutesold = time.minute
    }
    
    return parasitics
  }
  
  /// Initial state of storage
  static func prepare(storage: inout Storage.PerformanceData) {
    if Design.hasStorage {
      
      storage.heatStored = Design.layout.storage * parameter.heatStoredrel // check if needed!
      
      solarField.massFlow.max = MassFlow(
        100 / parameter.massFlow.rate * solarField.massFlow.max.rate) // 1.05 commented
      
      parameter.massFlow = MassFlow(
        (1 - parameter.massFlow.rate / 100) * solarField.massFlow.max.rate) // Change in Formula FR
    }
    
    solarField.massFlow.min = MassFlow(
      solarField.massFlow.min.rate / 100 * solarField.massFlow.max.rate)
    
    solarField.antiFreezeFlow = MassFlow(
      solarField.antiFreezeFlow.rate / 100 * solarField.massFlow.max.rate)
    
    if solarField.pumpParastics.isEmpty {
      if solarField.massFlow.max.rate < 900 {
        // calculation of solar field parasitics with empirical correlation derived from solar field model
        solarField.pumpParasticsFullLoad = (
          0.000000047327 * Design.layout.solarField ** 4
            - 0.000020044 * Design.layout.solarField ** 3
            + 0.0032862 * Design.layout.solarField ** 2
            - 0.24086 * Design.layout.solarField + 8.2152)
          * (0.7103 * (solarField.massFlow.max.rate / 597) ** 3
            - 0.8236 * (solarField.massFlow.max.rate / 597) ** 2
            + 1.464 * (solarField.massFlow.max.rate / 597) - 0.3508)
      } else {
        solarField.pumpParasticsFullLoad = (
          0.0000055 * solarField.massFlow.max.rate ** 2
            - 0.0074 * solarField.massFlow.max.rate + 4.4)
          * (-0.000001656 * Design.layout.solarField ** 3 + 0.0007981
            * Design.layout.solarField ** 2 - 0.1322
            * Design.layout.solarField + 8.428)
      }
      solarField.HTFmass = (93300 + 11328 * Design.layout.solarField)
        * (0.63 * (solarField.massFlow.max.rate / 597) + 0.38)
    }
    // check if it should be left so or changed to the real achieved temp. ( < 393 °C)
    // heatExchanger.temperature.htf.inlet.max = heatExchanger.HTFinTmax
    // heatExchanger.temperature.htf.inlet.min = heatExchanger.HTFinTmin
    // heatExchanger.temperature.htf.outlet.max = heatExchanger.HTFoutTmax
    // HeatExchanger.storage.HTFoutTmin = heatExchanger.HTFoutTmin never used
    
    if parameter.TturbIterate == -99.99 {
      storage.hSalt.hot = salt.enthalpy(parameter.designTemperature.hot)
      
      storage.hSalt.cold = salt.enthalpy(parameter.designTemperature.cold)
      
      heatExchanger.temperature.h2o.inlet.max = Temperature(
        parameter.startTemperature.hot.kelvin)
      
      heatExchanger.temperature.h2o.inlet.min = Temperature(
        parameter.startTemperature.cold.kelvin)
      
      if parameter.tempInCst[1] == 0 {
        storage.dTHTF_HotSalt = Temperature(celsius: parameter.tempExC0to1[0])
        storage.dTHTF_ColdSalt = Temperature(celsius: parameter.tempInCst[0])
        parameter.tempExC0to1[0] = parameter.designTemperature.hot.kelvin
          - parameter.tempExC0to1[0] // meaning is HTFTout(EX) = HotTankDes - dT
        parameter.tempExCst[0] = parameter.tempExC0to1[0]
        parameter.tempInCst[0] = parameter.designTemperature.cold.kelvin
          - parameter.tempInCst[0] // meaning is HTFTout(IN) = ColdTankDes + dT
        parameter.tempInCst[0] = parameter.tempInCst[0]
      }
    }
  }
  
/*
 This Subroutine simulates the TES, thermal storage
 storage.thermal  - if to storage, + if drawn from storage!!!
 This subroutine does not change the filling of the storage
 LISTING OF INPUT parameter.S
 hourFraction =  fraction of hour for this hourFraction
 storage.OPmode = "FP" freeze protection,
             -not analyzed- to store heat
             "PH" if heater could be switched on if necessary (PreHeat)
             "EX" discharge solar only, heater cannot be switched on
 powerBlock.massFlow =  is powerBlock.massFlow, the mass flow of 390øC which is used for
             charging and is reduced while charging
             or to calculate the max discharge massFlow for correct T at Turb
 LISTING OF OUTPUT parameter.S
 storage.thermal =   heat from storage (discharging positive, charging negative)
 heatLossStorage =       Loss of Heat during this hourFraction
 parasitics =  parasitic electric heat (pump)
 storage.OPmode = "FP" freeze protection,
             "IN" while charging storage
             "PH" discharging, preheater has to be switched on
             "EX" discharging, heater not needed
 storage.massFlow  mass flow through in storage, add this to other massFlow
 storage.temperature.outlet  discharging temperatur of storage
 powerBlock.massFlow = is reduced while charging
  */
  static func update(_ status: inout Plant.PerformanceData,
                     mode: PerformanceData.OperationMode,
                     thermal: inout ThermalEnergy) {
    
    let parameter = self.parameter
    
    enum Properties {
      static var SSetTime = 0
      static var i = 0.0
      static var StoFit = 0.0
      static var Lmax = 0.0
      static var MixTemp: Temperature = 0.0
      static var MinTBTemp: Temperature = 0.0
      static var Rohmean = 0.0
      static var RohDP = 0.0
      static var PrL = 0.0
      
      static var QoutLoad = 0.0
    }
    /*
     //calculate sunrise time for status day
     if date.hour = 16 && currentDate.minutes! = 0 && parameter.isVariable {
     // restricted in order to calculate times only once per day
     EvalDay = date.Day + 1
     SEval = "SR"
     // go SunElevZero
     SRiseTime = SPosTime
     //calculate sunset time for next day:
     EvalDay = date.Day
     SEval = "SS"
     // go SunElevZero
     SSetTime = SPosTime
     nightHour = 24 - SSetTime + SRiseTime + parameter.dSRise
     // night length in hours plus or minus hours selected by user (parameter.dSRise)
     }
     */
    var nightHour = 1.0
    
    if thermal.solar > 0 {
      status.solarField.header.massFlow = status.solarField.massFlow
    } else if case .freezeProtection = status.solarField.operationMode {
      status.solarField.header.massFlow = status.solarField.massFlow
    } else {
      status.solarField.header.massFlow = 0.0
    }
    
    switch status.storage.operationMode { // = storage.OPmode
      
    case .charging: // heat can be stored
      
      // storage.operationMode = "IN"
      status.storage.temperature.inlet = status.solarField.temperature.outlet
      // the powerBlock.massFlow is only an ideal value, for maximal dT, isnt it wrong?
      status.storage.massFlow = status.solarField.massFlow - status.powerBlock.massFlow
      status.storage.massFlow.adjust(with: parameter.heatExchangerEfficiency)
      // * Plant.availability[calendar].storage taken out of the formula and included in TES capacity calculation
      
      if parameter.tempInCst[1] > 0 { // usually = 0
        if status.storage.heatRelease < 0.5 {
          Properties.StoFit = 1
        } else {
          for i in 0 ..< 3 {
            Properties.StoFit += parameter.tempInCst[i] * status.storage.heatRelease ** Double(i)
          }
        }
        Properties.StoFit *= parameter.designTemperature.cold.kelvin - parameter.tempInCst[2]
      } else {
        Properties.StoFit = Properties.StoFit.toKelvin
        if status.storage.heatRelease < 0 {
          Properties.StoFit += parameter.tempInCst[0]
            - (parameter.designTemperature.cold
              - status.storage.temperatureTanks.cold).kelvin
        } else {
          // adjust of HTF outlet temp. with status cold tank temp.
          Properties.StoFit += parameter.tempInCst[0]
            - (parameter.designTemperature.cold
              - status.storage.temperatureTanks.cold).kelvin
        }
      }
      status.storage.temperature.outlet = Temperature(Properties.StoFit)
      thermal.storage = status.storage.massFlow.rate
        * htf.heatDelta(status.storage.temperature.outlet,
                        status.storage.temperature.inlet) / 1_000
      
      if parameter.heatExchangerRestrictedMax,
        abs(thermal.storage) > parameter.heatExchangerCapacity {
        thermal.storage *= parameter.heatExchangerCapacity
        status.storage.massFlow = MassFlow(thermal.storage / htf.heatDelta(
          status.storage.temperature.outlet, status.storage.temperature.inlet) * 1_000)
        // FIXME    powerBlock.massFlow = powerBlock.massFlow
        // added to avoid increase in PB massFlow
        if case .demand = parameter.strategy { // (always)
          // too much power from sun, dump
          thermal.dump += thermal.production
            - heatExchanger.SCCHTFthermal + thermal.storage
        } else {
          thermal.dump = thermal.dump + thermal.production
            - thermal.demand + thermal.storage
        }
        status.solarField.header.massFlow = status.powerBlock.massFlow + status.storage.massFlow
        // reduce HTF massflow in SF
        
        thermal.solar = status.solarField.heatTransfered(with: htf)
        thermal.production = thermal.solar
      }

      Plant.electricalParasitics.storage = Storage.parasitics(&status.storage)
    case .fc: // heat can be stored
      
      status.storage.temperature.inlet = Heater.parameter.nominalTemperatureOut
      status.storage.massFlow = status.powerBlock.massFlow
      
      if parameter.tempInCst[1] > 0 {
        if status.storage.heatRelease < 0.5 {
          Properties.StoFit = 1
        } else {
          for i in 0 ..< 3 {
            Properties.StoFit += parameter.tempInCst[i] * status.storage.heatRelease ** Double(i)
          }
        }
        Properties.StoFit *= parameter.designTemperature.cold.kelvin - parameter.tempInCst[2]
      } else {
        Properties.StoFit = Properties.StoFit.toKelvin
        if status.storage.heatRelease < 0 {
          Properties.StoFit += parameter.tempInCst[0]
            - (parameter.designTemperature.cold
              - status.storage.temperatureTanks.cold).kelvin
        } else {
          Properties.StoFit += parameter.tempInCst[0]
            - (parameter.designTemperature.cold
              - status.storage.temperatureTanks.cold).kelvin
        }
      }
      status.storage.temperature.outlet = Temperature(Properties.StoFit)
      thermal.storage = -status.storage.heatTransfered(with: htf) // [MW]
      // limit the size of the salt-oil heat exchanger
      if parameter.heatExchangerRestrictedMax,
        abs(thermal.storage) > parameter.heatExchangerCapacity {
        thermal.storage *= parameter.heatExchangerCapacity
        
        status.storage.massFlow = MassFlow(thermal.storage / htf.heatDelta(
          status.storage.temperature.outlet, status.storage.temperature.inlet) * 1_000)
        
        status.powerBlock.massFlow = status.storage.massFlow
      }
      
      Plant.electricalParasitics.storage = Storage.parasitics(&status.storage)
      
    case .ex: // heat can be released
      var time = TimeStep.zero
      // calculate discharge rate only once per day, directly after sunset
      if time.hour >= Properties.SSetTime && time.hour < (Properties.SSetTime + 1) && parameter.isVariable {
        switch parameter.definedBy {
        case .hours:
          status.storage.heatStored = status.storage.heatRelease * Design.layout.storage
            * steamTurbine.power.max / steamTurbine.efficiencyNominal
        case .cap:
          status.storage.heatStored = status.storage.heatRelease * Design.layout.storage_cap
        case .ton:
          status.storage.hSalt.hot = salt.enthalpy(parameter.designTemperature.hot)
          
          status.storage.hSalt.cold = salt.enthalpy(parameter.designTemperature.cold)
          
          status.storage.heatStored = status.storage.heatRelease * Design.layout.storage_ton
            * (status.storage.hSalt.hot - status.storage.hSalt.cold)
            * (parameter.designTemperature.hot - parameter.designTemperature.cold).kelvin / 3_600
        }
        
        if nightHour == 0 {
          // added to avoid division by zero if calculation doesn//t begin at Jan 1st
          nightHour = 12 // assumed night duration of the first day
        }
        
        // QoutLoad controls the load of the TES during discharge. Before was fixed to 0.97
        Properties.QoutLoad = status.storage.heatStored / nightHour
          / (steamTurbine.power.max
            / steamTurbine.efficiencyNominal)
        
        if Properties.QoutLoad < parameter.MinDis {
          Properties.QoutLoad = parameter.MinDis
        } else if Properties.QoutLoad > 1 {
          Properties.QoutLoad = 1
        }
      }
      // if no previous calculation has been done and TES must be discharged
      if Properties.QoutLoad == 0 && parameter.isVariable {
        switch parameter.definedBy {
        case .hours:
          status.storage.heatStored = status.storage.heatRelease * Design.layout.storage
            * steamTurbine.power.max
            / steamTurbine.efficiencyNominal
        case .cap:
          status.storage.heatStored = status.storage.heatRelease * Design.layout.storage_cap
        case .ton:
          status.storage.hSalt.hot = salt.enthalpy(parameter.designTemperature.hot)
          
          status.storage.hSalt.cold = salt.enthalpy(parameter.designTemperature.cold)
          
          status.storage.heatStored = status.storage.heatRelease * Design.layout.storage_ton
            * (status.storage.hSalt.hot - status.storage.hSalt.cold)
            * (parameter.designTemperature.hot
              - parameter.designTemperature.cold).kelvin / 3_600
        }
        
        if nightHour == 0 {
          // added to avoid division by zero if calculation doesn't begin at Jan 1st
          nightHour = 12 // assumed night duration of the first day
        }
        // QoutLoad controls the load of the TES during discharge.
        Properties.QoutLoad = status.storage.heatStored / nightHour / (steamTurbine.power.max
          / steamTurbine.efficiencyNominal)
        
        if Properties.QoutLoad < parameter.MinDis {
          Properties.QoutLoad = parameter.MinDis
        } else if Properties.QoutLoad > 1 {
          Properties.QoutLoad = 1
        }
      }
      // fixed discharge
      if !parameter.isVariable {
        // avoid user error by no input
        Properties.QoutLoad = parameter.fixedLoadDischarge == 0
          ? 0.97 : parameter.fixedLoadDischarge
      }
      
      switch status.solarField.operationMode {
      case .freezeProtection:
        // reduction of HTF Mass flow during strorage discharging due to results of AndaSol-1 Heat Balance
        status.storage.massFlow = MassFlow(Properties.QoutLoad
          * status.powerBlock.massFlow.rate / parameter.heatExchangerEfficiency)
        // - solarField.massFlow
        
      case .operating where status.solarField.massFlow.rate > 0:
        // Mass flow is correctd by parameter.Hx this factor is new
        status.storage.massFlow = MassFlow(status.powerBlock.massFlow.rate
          / parameter.heatExchangerEfficiency - status.solarField.massFlow.rate)
      // * 0.97 deleted after separating combined from storage only operation
      default:
        //if demand < 1 { // only for OU1!?
        //  storage.massFlow = powerBlock.massFlow * 1.3
        //    / parameter.heatExchangerEfficiency
        // for OU1 adjust to demand file and not TES design parameter.s. CHECK! 1.3 to get right results
        // } else {
        // added to control TES discharge during night
        status.storage.massFlow = MassFlow(Properties.QoutLoad
          * status.powerBlock.massFlow.rate / parameter.heatExchangerEfficiency)
        // }
      }
      
      status.storage.temperature.inlet = status.powerBlock.temperature.outlet // used for parasitics
      
      // go StorageOutletTemp   // STOoutTemp remains constant, whatever MassFlow
      
      while true {
        defer { status.storage.massFlow.adjust(with: 0.97) } // reduce 5%
        thermal.storage = status.storage.massFlow.rate
          * htf.heatDelta(status.storage.temperature.outlet,
                          status.storage.temperature.inlet) / 1_000
        
        if parameter.heatExchangerRestrictedMax,
          abs(thermal.storage) > parameter.heatExchangerCapacity {
          thermal.storage = thermal.storage * parameter.heatExchangerCapacity
          status.storage.massFlow = MassFlow(thermal.storage /
            htf.temperatureDelta(status.storage.temperature.outlet.kelvin,
                                 status.storage.temperature.inlet).kelvin * 1_000)
          if case .freezeProtection = status.solarField.operationMode {
            // reduction of HTF Mass flow during storage discharging due to results of AndaSol-1 Heat Balance
            status.powerBlock.massFlow = MassFlow(status.storage.massFlow.rate
              * parameter.heatExchangerEfficiency / 0.97) // - solarField.massFlow
            
          } else {
            // Mass flow is correctd by new factor
            status.powerBlock.massFlow = MassFlow(
              (status.storage.massFlow + status.solarField.massFlow).rate
              * parameter.heatExchangerEfficiency / 0.97)
          }
        }
        
        status.steamTurbine.load = Ratio((thermal.solar + thermal.storage)
          / (steamTurbine.power.max
            / SteamTurbine.efficiency(&status, Lmax: 1.0)))
        
        Properties.MixTemp = htf.mixingTemperature(outlet: status.solarField, with: status.storage)
        
        Properties.MinTBTemp = Temperature(310.0.toKelvin) // TurbineTempLoad(SteamTurbine.storage.load)
        
        if Properties.MixTemp.kelvin > Properties.MinTBTemp.kelvin - Simulation.parameter.tempTolerance.kelvin * 2 {
          thermal.storage = status.storage.massFlow.rate
            * htf.heatDelta(status.storage.temperature.outlet,
                            status.storage.temperature.inlet) / 1_000
          Plant.electricalParasitics.storage = Storage.parasitics(&status.storage)
          break
        } else if status.storage.massFlow.rate <= 0.05 * status.powerBlock.massFlow.rate {
          thermal.storage = 0
          status.storage.operationMode = .noOperation
          // parasitics = 0
          status.storage.massFlow = 0.0
          break
        }
      }
      
    case .ph: // the rest is heated by SF to 391øC
      // FIXME storage.operationMode = "PH"
      status.storage.massFlow = status.powerBlock.massFlow - status.solarField.massFlow
      status.storage.temperature.inlet = status.powerBlock.temperature.outlet
      // go StorageOutletTemp
      thermal.storage = status.storage.massFlow.rate
        * htf.heatDelta(status.storage.temperature.outlet,
                        status.storage.temperature.inlet) / 1_000
      // limit the size of the salt-oil heat exchanger
      if parameter.heatExchangerRestrictedMax,
        abs(thermal.storage) > parameter.heatExchangerCapacity {
        thermal.storage = thermal.storage * parameter.heatExchangerCapacity
        status.storage.massFlow = MassFlow(thermal.storage
          / htf.heatDelta(status.storage.temperature.outlet,
                          status.storage.temperature.inlet) * 1_000)
        // go StorageOutletTemp
        thermal.storage = -status.storage.heatTransfered(with: htf)
      }
      
    Plant.electricalParasitics.storage = Storage.parasitics(&status.storage)
    case .freezeProtection:
      
      let splitfactor: Ratio = 0.4
      status.storage.massFlow = solarField.antiFreezeFlow.adjusted(with: splitfactor)
      
      status.solarField.header.massFlow = solarField.antiFreezeFlow
      // used for parasitics
      status.storage.temperature.inlet = status.powerBlock.temperature.outlet
      
      if parameter.tempInCst[1] > 0 {
        
        if parameter.tempExCst.indices.contains(2) {
          status.storage.temperature.outlet = status.storage.temperature.inlet
        } else {
          if status.storage.heatRelease > 0.5 {
            //for i in 0 ..< 3 {
            Properties.StoFit = 1
            //}
          } else {
            for i in 0 ..< 3 {
              Properties.StoFit += parameter.tempExC0to1[i]
                * status.storage.heatRelease ** Double(i)
            }
          }
          status.storage.temperature.outlet = Temperature(
            Properties.StoFit * parameter.designTemperature.hot.kelvin)
        }
        status.storage.temperature.outlet = Temperature(
          splitfactor.ratio * status.storage.temperature.outlet.kelvin
            + (1 - splitfactor.ratio) * status.storage.temperature.inlet.kelvin)
      } else {
        status.storage.temperature.outlet =
          status.storage.temperatureTanks.cold
      }
      Plant.electricalParasitics.storage = Storage.parasitics(&status.storage)
      
    case .no:
      status.storage.operationMode = .noOperation // Temperatures remain constant
      Plant.electricalParasitics.storage = Storage.parasitics(&status.storage)
      thermal.storage = 0
      status.storage.massFlow = MassFlow() // parasitics = 0:
    default: break
    }
    
    // Storage Heat Losses: Check calculation
    if parameter.tempInCst[1] > 0 {
      // it does not get in here usually.
      if parameter.tempInCst[2] > 0 {
        Properties.StoFit = 0
        if status.storage.heatRelease < 0 {
         // for i in 0 ..< 3 {
           // StoFit += parameter.heatLossConstants[i] * status.storage.heatrel ** Double(i)
        // }
        } else {
        //  for i in 0 ..< 3 {
           // StoFit += parameter.heatLossConstants[i] * status.storage.heatrel ** Double(i)
       //   }
        }
        
        status.storage.heatLossStorage = Properties.StoFit
          * 3_600 * 0.0000001 * Design.layout.storage // [MW]
      } else {
        // FIXME  heatLossStorage = parameter.heatLossConstants[0] / 1_000 * (storage.heatrel
        // * (parameter.designTemperature.hot - parameter.designTemperature.cold)
        // + parameter.designTemperature.cold)
        // / parameter.designTemperature.hot
      }
    } else {
      status.storage.heatLossStorage = 0
    }
    
    // StorageOutletTemp
      if parameter.tempInCst[1] > 0 {
      if status.storage.heatRelease > 0.5 {
        //for i in 0 ..< 3 {
        Properties.StoFit = 1
        //}
      } else {
        for i in 0 ..< 3 {
          Properties.StoFit += parameter.tempExC0to1[i]
            * status.storage.heatRelease ** Double(i)
        }
      }
      Properties.StoFit *= parameter.designTemperature.hot.kelvin
        - parameter.tempExCst[1]
    } else {
      Properties.StoFit = Properties.StoFit.toKelvin
      if status.storage.heatRelease < 0 {
        Properties.StoFit += parameter.tempExCst[0]
          - (parameter.designTemperature.hot.kelvin
            - status.storage.temperatureTanks.hot.kelvin)
      } else {
        Properties.StoFit += parameter.tempExC0to1[0]
          - (parameter.designTemperature.hot.kelvin
            - status.storage.temperatureTanks.hot.kelvin)
        // adjust of HTF outlet temp. with status hot tank temp.
      }
    }
    status.storage.temperature.outlet = Temperature(celsius: abs(Properties.StoFit)) // independent from massFlow !!!
  }
  
  static func calculate(storage: inout Storage.PerformanceData,
                        powerBlock: inout PowerBlock.PerformanceData,
                        steamTurbine: SteamTurbine.PerformanceData) {
    
    let coldTankHeatLoss = parameter.heatLoss.cold
      * (storage.temperatureTanks.cold.kelvin )
      / (parameter.designTemperature.cold.kelvin - 27)
    
    let hotTankHeatLoss = parameter.heatLoss.hot
      * (storage.temperatureTanks.hot.kelvin)
      / (parameter.designTemperature.hot.kelvin - 27)
    
    storage.hSalt.cold = salt.enthalpy(parameter.designTemperature.cold)

    storage.hSalt.hot = salt.enthalpy(parameter.designTemperature.hot)
    
    switch parameter.definedBy {
    case .hours:
      // Plant.availability[currentDate.month].storage added here to apply TES availability on capacity and not on charge load
      storage.massSalt = Design.layout.storage
        * Plant.availability.value.storage.ratio
        * (1 + parameter.dischargeToTurbine)
      storage.massSalt *= heatExchanger.SCCHTFthermal * 3_600 * 1_000
        / (storage.hSalt.hot - storage.hSalt.cold)
    case .cap:
      storage.massSalt = Design.layout.storage_cap
        * Plant.availability.value.storage.ratio
        * (1 + parameter.dischargeToTurbine)
      storage.massSalt *= 1_000 * 3_600 / (storage.hSalt.hot - storage.hSalt.cold)
    case .ton:
      storage.massSalt = Design.layout.storage_ton
        * Plant.availability.value.storage.ratio
      storage.massSalt *= 1_000 * (1 + parameter.dischargeToTurbine)
    }
    
    //   Saltmass = parameter.heatLossConstants0[3]
    
    if parameter.tempInCst[1] > 0 { // it doesnt get in here usually, therefore not updated yet
      storage.heatStored = storage.heatStored - storage.heatLossStorage
        * hourFraction - Plant.thermal.storage * hourFraction
      storage.heatRelease = storage.heatStored
        / (Design.layout.storage * heatExchanger.SCCHTFthermal)
    } else {
      
      switch storage.operationMode {
        
      case .charging:
        // Hot salt is storage.temperature.inlet - dTHTF_HotSalt
        storage.hSalt.hot = salt.enthalpy(storage.temperature.inlet - storage.dTHTF_HotSalt)
        
        storage.hSalt.cold = salt.enthalpy(storage.temperatureTanks.cold)
        
        storage.massSalt = -Plant.thermal.storage
          / (storage.hSalt.hot - storage.hSalt.cold) * hourFraction * 3_600 * 1_000
        
        storage.mass.cold = storage.mass.cold - storage.massSalt
        
        if storage.mass.cold < minmass(storage: storage) { // added to avoid negative or too low mass and therefore no heat losses.
          storage.massSalt = storage.massSalt
            - (minmass(storage: storage) - storage.mass.cold) }
        if storage.massSalt < 10 { storage.massSalt = 0
          storage.mass.cold = minmass(storage: storage)
          storage.mass.hot = storage.massSalt + storage.mass.hot
          storage.heatRelease = parameter.chargeTo
        } else {
          storage.mass.hot = storage.massSalt + storage.mass.hot
          storage.heatRelease = storage.mass.hot * (parameter.designTemperature.hot
            - parameter.designTemperature.cold).kelvin
            / (storage.massSalt * (parameter.designTemperature.hot
              - parameter.designTemperature.cold).kelvin)
        }
        if storage.mass.hot > 0 {
          storage.temperatureTanks.hot = Temperature((storage.massSalt
            * (storage.temperature.inlet - storage.dTHTF_HotSalt).kelvin
            + storage.mass.hot * storage.temperatureTanks.hot.kelvin)
            / (storage.massSalt + storage.mass.hot))
        } else {
          storage.temperatureTanks.hot = storage.temperatureTanks.hot
        }
        
      case .fc:
        // check if changes have to be done related to salt temperature
        storage.hSalt.hot = salt.enthalpy(parameter.designTemperature.hot)
        
        storage.hSalt.cold = salt.enthalpy(storage.temperatureTanks.cold)
        
        storage.massSalt = -Plant.thermal.storage
          / (storage.hSalt.hot - storage.hSalt.cold)
          * hourFraction * 3_600 * 1_000
        
        storage.mass.cold = storage.mass.cold - storage.massSalt
        
        storage.mass.hot = storage.massSalt + storage.mass.hot
        
        storage.heatRelease = storage.mass.hot * (parameter.designTemperature.hot
          - parameter.designTemperature.cold).kelvin
          / (storage.massSalt * (parameter.designTemperature.hot
            - parameter.designTemperature.cold).kelvin)
        
        if storage.mass.hot > 0 {
          storage.temperatureTanks.hot = Temperature((storage.massSalt
            * parameter.designTemperature.hot.kelvin
            + storage.mass.hot * storage.temperatureTanks.hot.kelvin)
            / (storage.massSalt + storage.mass.hot))
        } else {
          storage.temperatureTanks.hot = storage.temperatureTanks.hot
        }
        
      case .ex:
        storage.hSalt.hot = salt.enthalpy(storage.temperatureTanks.hot)
        
        storage.hSalt.cold = salt.enthalpy(
          storage.temperature.inlet + storage.dTHTF_ColdSalt)
        
        storage.massSalt = Plant.thermal.storage
          / (storage.hSalt.hot - storage.hSalt.cold)
          * hourFraction * 3_600 * 1_000
        storage.mass.hot = -storage.massSalt + storage.mass.hot
        
        if storage.mass.hot < minmass(storage: storage) {
          // added to avoid negative or too low mass and therefore no heat losses
          storage.massSalt = storage.massSalt
            - (minmass(storage: storage) - storage.mass.hot)
        }
        if storage.massSalt < 10 {
          
          storage.massSalt = 0
          Plant.thermal.storage = storage.massSalt
            * (storage.hSalt.hot - storage.hSalt.cold)
            / hourFraction / 3_600 / 1_000
          storage.mass.hot = minmass(storage: storage)
          
          storage.mass.cold = storage.mass.cold + storage.massSalt
          storage.heatRelease = parameter.dischargeToTurbine
        } else {
          
          storage.mass.cold = storage.mass.cold + storage.massSalt
          storage.heatRelease = storage.mass.hot * (parameter.designTemperature.hot
            - parameter.designTemperature.cold).kelvin / (storage.massSalt *
              (parameter.designTemperature.hot
                - parameter.designTemperature.cold).kelvin)
        }
        if storage.mass.cold > 0 {
          // cold salt is storage.temperature.inlet + dTHTF_ColdSalt
          storage.temperatureTanks.cold = Temperature((storage.massSalt
            * (storage.temperature.inlet + storage.dTHTF_ColdSalt).kelvin
            + storage.mass.cold * storage.temperatureTanks.cold.kelvin)
            / (storage.massSalt + storage.mass.cold))
        }
        
      case .ph:
        storage.hSalt.hot = salt.enthalpy(storage.temperatureTanks.hot)
        
        storage.hSalt.cold = salt.enthalpy(parameter.designTemperature.cold)
        
        storage.massSalt = Plant.thermal.storage
          / (storage.hSalt.hot - storage.hSalt.cold)
          * hourFraction * 3_600 * 1_000
        
        storage.mass.hot = -storage.massSalt + storage.mass.hot
        
        storage.mass.cold = storage.mass.cold + storage.massSalt
        
        storage.heatRelease = storage.mass.hot * (parameter.designTemperature.hot
          - parameter.designTemperature.cold).kelvin
          / (storage.massSalt * (parameter.designTemperature.hot
            - parameter.designTemperature.cold).kelvin)
        
        storage.temperatureTanks.cold = Temperature(
          (storage.massSalt * parameter.designTemperature.cold.kelvin
            + storage.mass.cold * storage.temperatureTanks.cold.kelvin)
            / (storage.massSalt + storage.mass.cold))
        
      case .freezeProtection:
        let splitfactor = parameter.HTF == .hiXL ? 0.4 : 1
        
        storage.massSalt = solarField.antiFreezeFlow.rate * hourFraction * 3_600
        
        storage.temperatureTanks.cold = Temperature(
          (splitfactor * storage.massSalt
            * powerBlock.temperature.outlet.kelvin
            + storage.mass.cold * storage.temperatureTanks.cold.kelvin)
            / (splitfactor * storage.massSalt + storage.mass.cold))
        
        storage.StoTcoldTout = splitfactor * storage.temperatureTanks.cold.kelvin
          + (1 - splitfactor) * powerBlock.temperature.outlet.kelvin
        // powerBlock.temperature.outlet = storage.temperatureTank.cold
        
      case .no:
        if parameter.TturbIterate < -90,
          storage.temperatureTanks.cold < parameter.designTemperature.cold,
          powerBlock.temperature.outlet > storage.temperatureTanks.cold,
          storage.mass.cold > 0 {
          
          storage.massSalt = powerBlock.massFlow.rate * hourFraction * 3_600
          
          storage.temperatureTanks.cold = Temperature(
            (storage.massSalt * powerBlock.temperature.outlet.kelvin
              + storage.mass.cold * storage.temperatureTanks.cold.kelvin)
              / (storage.massSalt + storage.mass.cold))
          
          storage.operationMode = .sc
        }
      default: break
      }
      
      // Storage Heat Losses:
      if steamTurbine.isMaintained {
      } else {
        if storage.mass.hot > 0 {
          // parameter.dischargeToTurbine * Saltmass {
          // enthalpy before cooling down
          storage.hSalt.hot = salt.enthalpy(storage.temperatureTanks.hot)
          // enthalpy after cooling down
          storage.hSalt.hot = storage.hSalt.hot - hotTankHeatLoss
            * Double(period) / storage.mass.hot
          // temp after cool down
          storage.temperatureTanks.hot = Temperature(celsius:
            (-salt.heatCapacity[0] + (salt.heatCapacity[0] ** 2
              - 4 * (salt.heatCapacity[1] * 0.5)
              * (-350.5536 - storage.hSalt.hot)) ** 0.5)
            / (2 * salt.heatCapacity[1] * 0.5))
        }
        if storage.mass.cold > parameter.dischargeToTurbine * storage.massSalt {
          // enthalpy before cooling down
          storage.hSalt.cold = salt.enthalpy(storage.temperatureTanks.cold)
          // enthalpy after cooling down
          storage.hSalt.cold = storage.hSalt.cold - coldTankHeatLoss
            * Double(period) / storage.mass.cold
          // temp after cool down
          storage.temperatureTanks.cold = Temperature(celsius:
            (-salt.heatCapacity[0] + (salt.heatCapacity[0] ** 2
              - 4 * (salt.heatCapacity[1] * 0.5)
              * (-350.5536 - storage.hSalt.cold)) ** 0.5)
            / (2 * salt.heatCapacity[1] * 0.5))
        }
      }
    }
    
    if Plant.thermal.storage < 0 {
      if case .freezeProtection = storage.operationMode {
        // FIXME powerBlock.temperature.outlet // = powerBlock.temperature.outlet
      } else if case .charging = storage.operationMode {
        // if storage.operationMode = "IN" added to avoid Tmix during TES discharge (valid for indirect storage), check!
        powerBlock.temperature.outlet = htf.mixingTemperature(
          outlet: powerBlock, with: storage)
      } else { // for indirect TES discharge added, check!
        // FIXME powerBlock.temperature.outlet // = powerBlock.temperature.outlet
      }
    }
    // FIXME HeatExchanger.storage.H2OinTmax = storage.mass.hot
    // FIXME HeatExchanger.storage.H2OinTmin = storage.mass.cold
    // FIXME HeatExchanger.storage.H2OoutTmax = storage.temperatureTank.hot
    // FIXME HeatExchanger.storage.H2OoutTmin = storage.temperatureTank.cold
  }
  
  static func update(_ status: inout Plant.PerformanceData,
                     availableFuel: inout Double,
                     fuel: inout FuelConsumption,
                     thermal: inout ThermalEnergy) {
    
    var thermalDiff = 0.0

    if Design.hasGasTurbine {
      status.powerBlock.massFlow = MassFlow(
        heatExchanger.SCCHTFthermal / (htf.heatDelta(
          heatExchanger.temperature.htf.inlet.max,
          heatExchanger.temperature.htf.outlet.max) / 1_000))
      thermalDiff = thermal.production - heatExchanger.SCCHTFthermal
    } else {
      
      if case .always = parameter.strategy {
        // if demand is selected, variable is called Alw but calculation is done as demand, error comes from older version // "Dem"
        status.powerBlock.massFlow = MassFlow(thermal.demand
          / (htf.heatDelta(
            heatExchanger.temperature.htf.inlet.max,
            heatExchanger.temperature.htf.outlet.max) / 1_000))
        
        if !status.powerBlock.massFlow.isNearZero { // to avoid negative massfows
          thermalDiff = 0
          status.powerBlock.massFlow = status.solarField.header.massFlow
        }
      } else {
        thermalDiff = thermal.production - thermal.demand // [MW]
        if parameter.heatExchangerRestrictedMin {
          // added to avoid input to storage lower than minimal HX// s capacity
          thermal.toStorageMin = parameter.heatExchangerMinCapacity
            * heatExchanger.SCCHTFthermal
            * (1 - parameter.massFlow.rate / solarField.massFlow.max.rate)
            / (parameter.massFlow.rate / solarField.massFlow.max.rate)
          
          if thermalDiff > 0 && thermalDiff < thermal.toStorageMin {
            thermal.demand = thermal.demand - (thermal.toStorageMin - thermalDiff)
            
            status.powerBlock.massFlow = MassFlow(thermal.demand / htf.heatDelta(
                heatExchanger.temperature.htf.inlet.max,
                heatExchanger.temperature.htf.outlet.max) / 1_000)
            
            thermalDiff = thermal.toStorageMin
          }
        }
      }
      if case .demand = parameter.strategy {
        // if Always is selected, variable is called "Dem" but calculation is done as "Always", error comes from older version // "Alw" {
        status.powerBlock.massFlow = MassFlow(heatExchanger.SCCHTFthermal
          / (htf.heatDelta(
            heatExchanger.temperature.htf.inlet.max,
            heatExchanger.temperature.htf.outlet.max) / 1_000))
        
        if status.powerBlock.massFlow < 0.0 { // to avoid negative massfows
          thermalDiff = 0
          status.powerBlock.massFlow = status.solarField.header.massFlow
        } else {
          thermalDiff = thermal.production - heatExchanger.SCCHTFthermal
          // changed back as thermal.production - heatExchanger.SCCHTFheat// thermal.demand     // [MW]
          if parameter.heatExchangerRestrictedMin {
            // added to avoid input to storage lower than minimal HX// s capacity
            thermal.toStorageMin = heatExchanger.SCCHTFthermal
              * (1 - parameter.massFlow.rate / solarField.massFlow.max.rate)
              / (parameter.massFlow.rate / solarField.massFlow.max.rate)
            
            if thermalDiff > 0 && thermalDiff < thermal.toStorageMin {
              status.powerBlock.massFlow = MassFlow((heatExchanger.SCCHTFthermal
                - (thermal.toStorageMin - thermalDiff)) / (htf.heatDelta(
                  heatExchanger.temperature.htf.inlet.max,
                  heatExchanger.temperature.htf.outlet.max) / 1_000))
              thermalDiff = thermal.toStorageMin
            }
          }
        }
      }
      
      if case .shifter = parameter.strategy { // parameter.strategy = "Ful" // Booster or Shifter
        // new calculation of shifter, old kept and commented below this:
        let time = TimeStep.zero
        if time.month < parameter.startexcep
          || time.month > parameter.endexcep {
          status.storage.heatProductionLoad = parameter.heatProductionLoadWinter
          if dniDay > parameter.badDNIwinter * 1_000 {
            // sunny day, TES can be fully charged also by running TB at full load
            status.storage.heatProductionLoad = 1
          }
        } else {
          status.storage.heatProductionLoad = parameter.heatProductionLoadSummer
          if dniDay > parameter.badDNIsummer * 1_000 {
            // sunny day, TES can be fully charged also by running TB at full load
            status.storage.heatProductionLoad = 1
          }
        }
        
        if thermal.production > 0 { // Qsol > 0
          
          if thermal.production < thermal.demand,
            status.storage.heatRelease < parameter.chargeTo,
            time.hour < 17 {
            // Qsol not enough for POB demand load (e.g. at the beginning of the day)
            status.powerBlock.massFlow = MassFlow(min(
              status.storage.heatProductionLoad * thermal.demand,
              thermal.production)
              / (htf.heatDelta(
                heatExchanger.temperature.htf.inlet.max,
                heatExchanger.temperature.htf.outlet.max) / 1_000))
            
            thermalDiff = thermal.production - min(
              status.storage.heatProductionLoad * thermal.demand,
              thermal.production)
            // TES gets the rest available
            if parameter.heatExchangerRestrictedMax {
              thermalDiff = min(thermalDiff, parameter.heatExchangerCapacity)
            } else {
              let value = steamTurbine.power.max
                / steamTurbine.efficiencyNominal
                / heatExchanger.efficiency
              if thermalDiff > value {
                thermalDiff = value
              }
            }
          } else if thermal.production < thermal.demand,
            status.storage.heatRelease >= parameter.chargeTo {
            // Qsol not enough for POB demand load (e.g. at the end of the day) and TES is full
            status.powerBlock.massFlow = MassFlow(thermal.demand / (htf.heatDelta(
              heatExchanger.temperature.htf.inlet.max,
              heatExchanger.temperature.htf.outlet.max) / 1_000))
            // send all to POB and if needed discharge TES
            
            thermalDiff = thermal.production - thermal.demand
            // TES provides the rest available
            // check what if TES is full and POB could get more than 50% of design!!
            if parameter.heatExchangerRestrictedMax {
              thermalDiff = max(thermalDiff, -parameter.heatExchangerCapacity)
            } else { // signs below changed
              let value = steamTurbine.power.max
                / steamTurbine.efficiencyNominal
                / heatExchanger.efficiency
              if thermalDiff > -value {
                thermalDiff = -value
              }
            }
          } else if thermal.production > thermal.demand,
            status.storage.heatRelease < parameter.chargeTo,
            status.solarField.header.massFlow >= status.powerBlock.massFlow {
            // more Qsol than needed by POB and TES is not full
            status.powerBlock.massFlow = MassFlow(
              (status.storage.heatProductionLoad * thermal.demand)
                / (htf.heatDelta(
                  heatExchanger.temperature.htf.inlet.max,
                  heatExchanger.temperature.htf.outlet.max) / 1_000))
            // from avail heat cover first 50% of POB demand
            thermalDiff = thermal.production -
              (status.storage.heatProductionLoad * thermal.demand)
            // TES gets the rest available
            if parameter.heatExchangerRestrictedMax {
              if thermalDiff > parameter.heatExchangerCapacity {
                // rest heat to TES is too high, use more heat to POB
                status.powerBlock.massFlow = MassFlow(
                  (thermal.production - parameter.heatExchangerCapacity)
                    / (htf.heatDelta(
                      heatExchanger.temperature.htf.inlet.max,
                      heatExchanger.temperature.htf.outlet.max) / 1_000))
                // from avail heat cover first 50% of POB demand
                
                thermalDiff = parameter.heatExchangerCapacity
                // TES gets max heat input
              }
            }
          }
        } else {
          var i = 0
          if case .hours = parameter.definedBy {
            // condition added. It usually doesn't get in here. therefore, not correctly programmed yet
            if thermal.production > thermal.demand,
              status.storage.heatRelease > 1 * steamTurbine.power.max
                / steamTurbine.efficiencyNominal / Design.layout.storage {
              i = -1
              //   } else if parameter.definedBy = "cap" {
              //       if thermal.production > thermal.demand && storage.heatrel > 1 * steamTurbine.power.max / steamTurbine.efficiencyNominal / Design.layout.storage_cap { i = -1
              //   } else if parameter.definedBy = "ton" {
              //       if thermal.production > thermal.demand && storage.heatrel > 1 * steamTurbine.power.max / steamTurbine.efficiencyNominal / Design.layout.storage_ton { i = -1
            }
            if i == -1 {
              thermal.demand = steamTurbine.power.max
                * Plant.availability.value.powerBlock.ratio
                / SteamTurbine.efficiency(&status, Lmax: 1.0) // limit HX capacity?
              var thermalDiff = thermal.production - thermal.demand // [MW]
              // power to charge TES rest after operation POB at full load commented
              //  heatdiff = max(thermal.production, thermal.demand) // maximal power to TES desing POB thermal input (just to check how it works)
              let heat = steamTurbine.power.max
                / steamTurbine.efficiencyNominal
                / heatExchanger.efficiency
              
              if thermalDiff > heat {
                thermalDiff = heat // commented in case of degradated powerblock
                // if heatdiff > steamTurbine.power.max / steamTurbine.efficiencyNominalOriginal / heatExchanger.efficiency {
                // heatdiff = steamTurbine.power.max / steamTurbine.efficiencyNominalOriginal / heatExchanger.efficiency
                // in case of degradated powerblock
                status.powerBlock.massFlow = MassFlow((thermal.production - thermalDiff)
                  / (htf.heatDelta(
                    heatExchanger.temperature.htf.inlet.max,
                    heatExchanger.temperature.htf.outlet.max) / 1_000))
              }
            }
          }
        }
      }
    }
    if thermalDiff > 0 {
      
      // Energy surplus
      if status.storage.heatRelease < parameter.chargeTo,
        status.solarField.header.massFlow >= status.powerBlock.massFlow {
        
        Storage.update(&status, mode: .charging, thermal: &thermal)
        //Storage.update(mode: .charging, parameter.heatExchanger * heatdiff, powerBlock.massFlow, hourFraction, thermal.storage, electricalParasitics.storage, storage.mass.hot, storage.temperatureTank.cold, storage.mass.cold, XZ)
        status.powerBlock.temperature.inlet = status.solarField.header.temperature.outlet
        // FIXME powerBlock.massFlow = powerBlock.massFlow
      } else { // heat cannot be stored
        Storage.update(&status, mode: .noOperation, thermal: &thermal)
        //Storage.update(mode: .noOperation, heatdiff, powerBlock.massFlow, thermal.storage, electricalParasitics.storage, storage.mass.hot, storage.temperatureTank.cold, storage.mass.cold, XZ)
        status.powerBlock.temperature.inlet = status.solarField.header.temperature.outlet
      }
      
    } else { // Energy deficit
      var peakTariff: Bool
      let time = TimeStep.zero
      // check when to discharge TES
      if case .shifter = parameter.strategy { // only for Shifter
        if time.month < parameter.startexcep || time.month > parameter.endexcep { // Oct to March
          peakTariff = time.hour >= parameter.dischrgWinter
        } else { // April to Sept
          peakTariff = time.hour >= parameter.dischrgSummer
        }
      } else { // not shifter
        peakTariff = true // dont care about time to discharge
      }
      var noFreezeProtection = true
      if case .freezeProtection = status.storage.operationMode {
        noFreezeProtection = false
      }
      if peakTariff, noFreezeProtection,
        status.storage.heatRelease > parameter.dischargeToTurbine,
        thermalDiff < -1 * parameter.heatdiff * thermal.demand { // added dicharge only after peak hours
        // previous discharge condition commented:
        // if storage.heatrel > parameter.dischargeToTurbine && storage.operationMode != .freezeProtection && heatdiff < -1 * parameter.heatdiff * thermal.demand { // Discharge directly!! // 04.07.0 -0.25&& heatdiff < -0.25 * thermal.dem
        if status.powerBlock.massFlow < status.solarField.header.massFlow { // there are cases, during cloudy days when OpMode is "EX" although massflow in SOF is higher that in PB.
        }
        Storage.update(&status, mode: .ex, thermal: &thermal)
        //Storage.update(mode: .ex, heatdiff, powerBlock.massFlow, thermal.storage, heatLossStorage, electricalParasitics.storage, storage.mass.hot, storage.temperatureTank.cold, storage.mass.cold, XZ)
        if case .freezeProtection = status.solarField.operationMode {
          
          status.powerBlock.temperature.inlet = htf.mixingTemperature(
            outlet: status.solarField, with: status.storage)
          
          status.powerBlock.massFlow = status.storage.massFlow + status.solarField.header.massFlow //
          
          status.powerBlock.massFlow.adjust(with: parameter.heatExchangerEfficiency)
          
        } else if case .operating = status.solarField.operationMode { // eingefügt  IF-abrage eingefügt
          
          status.powerBlock.temperature.inlet = htf.mixingTemperature(
            outlet: status.solarField, with: status.storage)
          
          status.powerBlock.massFlow = status.storage.massFlow + status.solarField.header.massFlow
          
          status.powerBlock.massFlow.adjust(with: parameter.heatExchangerEfficiency)
          
        } else if !status.storage.massFlow.isNearZero {
          
          status.powerBlock.temperature.inlet = status.storage.temperature.outlet
          
          status.powerBlock.massFlow = status.storage.massFlow
          
          status.powerBlock.massFlow.adjust(with: parameter.heatExchangerEfficiency)
          
        } else {
          
          status.powerBlock.massFlow = MassFlow()
        }
        
      } else { // heat can only be provided with heater on

        if (parameter.FC == 0 && status.collector.parabolicElevation < 0.011
          && status.storage.heatRelease < parameter.chargeTo
          && !(status.powerBlock.temperature.inlet.kelvin > 665)
          && status.steamTurbine.isMaintained
          && isFossilChargingAllowed(at: time)
          && Fuelmode != "predefined") || (Fuelmode == "predefined" && availableFuel > 0) {
          status.heater.operationMode = .freezeProtection
          
          if Fuelmode != "predefined" {
            let availableFuel = Double.greatestFiniteMagnitude
            
            Heater.update(&status, demand: 0, availableFuel: availableFuel,
                          thermal: &thermal, fuelFlow: &fuel.heater)
            
            Plant.electricalParasitics.heater = Heater.parasitics(at: status.heater.load)
            
            status.powerBlock.massFlow = status.heater.massFlow
            
            Storage.update(&status, mode: .freezeProtection, thermal: &thermal)
            // FIXME powerBlock.massFlow = powerBlock.massFlow
            status.powerBlock.temperature.inlet = status.storage.temperature.outlet
            // check why to circulate HTF in SF
            Plant.electricalParasitics.solarField = solarField.antiFreezeParastics
          } else if case .freezeProtection = status.solarField.operationMode,
            status.storage.heatRelease > -0.35 && parameter.FP == 0 {
            
            Storage.update(&status, mode: .freezeProtection, thermal: &thermal)
          } else {
            Storage.update(&status, mode: .noOperation, thermal: &thermal)
          }
        }
      }
      
      thermal.storage = status.storage.massFlow.rate
        * htf.heatDelta(status.storage.temperature.outlet,
                        status.storage.temperature.inlet) / 1_000
      
      // Check if the required heat is contained in TES, if not recalculate thermal.storage
      
      switch status.storage.operationMode {
        
      case .ex:
        status.storage.hSalt.hot = salt.enthalpy(status.storage.temperatureTanks.hot)
        
        status.storage.hSalt.cold = salt.enthalpy(
          status.storage.temperature.inlet + status.storage.dTHTF_ColdSalt)
        
        status.storage.massSalt = thermal.storage / (status.storage.hSalt.hot
          - status.storage.hSalt.cold) * hourFraction * 3_600 * 1_000
        
        if (status.storage.mass.hot - status.storage.massSalt) < status.storage.minMass {
          // added to avoid negative or too low salt mass
          status.storage.massSalt = status.storage.massSalt
            - (-status.storage.minMass + status.storage.mass.hot)
        }
        
        if status.storage.massSalt < 10 { status.storage.massSalt = 0
          // recalculate thermal power given by TES:
          thermal.storage = status.storage.massSalt
            * (status.storage.hSalt.hot - status.storage.hSalt.cold)
            / hourFraction / 3_600 / 1_000
        }
        
      case .charging:
        status.storage.hSalt.hot = salt.enthalpy(
          status.storage.temperature.inlet - status.storage.dTHTF_HotSalt)
        
        status.storage.hSalt.cold = salt.enthalpy(status.storage.temperatureTanks.cold)
        
        status.storage.massSalt = -thermal.storage
          / (status.storage.hSalt.hot - status.storage.hSalt.cold)
          * hourFraction * 3_600 * 1_000
        
        if (status.storage.mass.cold - status.storage.massSalt) < status.storage.minMass {
          
          status.storage.massSalt = status.storage.massSalt
            - (-status.storage.minMass + status.storage.mass.cold)
          
          if status.storage.massSalt < 10 { status.storage.massSalt = 0
            // recalculate thermal power given by TES:
            thermal.storage = -status.storage.massSalt
              * (status.storage.hSalt.hot - status.storage.hSalt.cold)
              / hourFraction / 3_600 / 1_000
          }
        }
      default: break
      }
      
      if thermalDiff > 0 { // Energy surplus
        if status.storage.heatRelease < parameter.chargeTo,
          status.solarField.header.massFlow >= status.powerBlock.massFlow { // 1.1
          thermal.production = thermal.solar + thermal.storage
        } else { // heat cannot be stored
          thermal.production = thermal.solar - thermalDiff
          // surplus is dumped (?) and not sent to PB
        }
      } else {
        thermal.production = thermal.solar + thermal.storage
      }
    }
  }
  
  static func isFossilChargingAllowed(at time : TimeStep) -> Bool {
    return (time.month < parameter.FCstopM || (time.month == parameter.FCstopM
        && time.day < parameter.FCstopD) || ((time.month == parameter.FCstartM
        && time.day > parameter.FCstartD) || time.month > parameter.FCstartM)
      && (time.month < parameter.FCstopM2 || (time.month == parameter.FCstopM2
          && time.day < parameter.FCstopD2) || (time.month > parameter.FCstartM2
            || (time.month == parameter.FCstartM2 && time.day > parameter.FCstartD2))
      )
    )
  }
}

extension HeatTransferFluid {
  fileprivate func enthalpy(_ temperature: Temperature)-> Double {
    return heatCapacity[0] * temperature.kelvin
      + 0.5 * heatCapacity[1] * temperature.kelvin ** 2 - 350.5536
  }
}
