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

extension Storage.Instance: CustomDebugStringConvertible {
  var debugDescription: String { return "\(workingConditions.current)" }
}

public struct Storage: Component {
  
  final class Instance {
    // A singleton class holding the state of the storage
    fileprivate static let shared = Instance()
    var parameter: Storage.Parameter!
    var workingConditions: (previous: PerformanceData?, current: PerformanceData)
    
    private init() {
      workingConditions = (nil, initialState)
    }
  }
  
  /// a struct for operation-relevant data of the storage
  public struct PerformanceData: HeatTransfer, WorkingConditions {
    var operationMode: OperationMode
    var temperature: (inlet: Temperature, outlet: Temperature)
    var averageTemperature: Temperature {
      return Temperature((temperature.inlet + temperature.outlet).kelvin / 2)
    }
    var temperatureTank: (cold: Temperature, hot: Temperature)
    var massFlow: MassFlow
    var heatrel: Double
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
    public enum OperationMode {
      case noOperation, discharge, freezeProtection, ph, charging, no, ex, sc, fc
    }
  }
  
  fileprivate static let initialState = PerformanceData(
    operationMode: .noOperation,
    temperature: (0.0, 0.0), temperatureTank: (0.0, 0.0),
    massFlow: 0.0, heatrel: 0,
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
  
  /// Returns the current working conditions of the steam turbine
  public static var status: PerformanceData {
    get { return Instance.shared.workingConditions.current }
    set {
      Instance.shared.workingConditions =
        (Instance.shared.workingConditions.current, newValue)
    }
  }
  
  /// Returns the previous working conditions of the steam
  public static var previous: PerformanceData? {
    return Instance.shared.workingConditions.previous
  }
  
  public static var parameter: Storage.Parameter {
    get { return Instance.shared.parameter }
    set { Instance.shared.parameter = newValue }
  }
  
  public static func minmass(storage: Storage.PerformanceData) -> Double {
    switch parameter.definedBy {
    case .hours:
      let minmass = Design.layout.storage * parameter.dischargeToTurbine
        * HeatExchanger.parameter.SCCHTFheatFlow * 1_000 * 3_600
        / (storage.hSalt.hot - storage.hSalt.cold)
      HeatExchanger.parameter.temperature.h2o.inlet.max = Temperature(
        parameter.startLoad.hot * Design.layout.storage
          * HeatExchanger.parameter.SCCHTFheatFlow * 1_000 * 3_600
          / (storage.hSalt.hot - storage.hSalt.cold) + minmass) // Factor 1.1
      HeatExchanger.parameter.temperature.h2o.inlet.min = Temperature(
        parameter.startLoad.cold * Design.layout.storage
          * HeatExchanger.parameter.SCCHTFheatFlow * 1_000 * 3_600
          / (storage.hSalt.hot - storage.hSalt.cold) + minmass)
      return minmass
    case .cap:
      let minmass = Design.layout.storage_cap
        * parameter.dischargeToTurbine * 1_000 * 3_600
        / (storage.hSalt.hot - storage.hSalt.cold)
      HeatExchanger.parameter.temperature.h2o.inlet.max = Temperature(
        parameter.startLoad.hot * Design.layout.storage_cap * 1_000 * 3_600
          / (storage.hSalt.hot - storage.hSalt.cold) + minmass) // Factor 1.1
      HeatExchanger.parameter.temperature.h2o.inlet.min = Temperature(
        parameter.startLoad.cold * Design.layout.storage_cap * 1_000 * 3_600
          / (storage.hSalt.hot - storage.hSalt.cold) + minmass)
      return minmass
    case .ton:
      let minmass = Design.layout.storage_ton * parameter.dischargeToTurbine * 1_000 // OK
      HeatExchanger.parameter.temperature.h2o.inlet.max = Temperature(
        parameter.startLoad.hot * Design.layout.storage_ton * 1_000 + minmass)
      HeatExchanger.parameter.temperature.h2o.inlet.min = Temperature(
        parameter.startLoad.cold * Design.layout.storage_ton * 1_000 + minmass)
      return minmass
    }
  }
  
  /// Calculates the parasitics of the gas turbine which only depends on the current load
  private static func parasitics(_ storage: inout PerformanceData) -> Double {
    
    var parasitics = 0.0
    var timeminutessum = 0
    var timeminutesold = 0
    let time = PerformanceCalculator.calendar
    
    var DesAuxIN = 0.0
    var DesAuxEX = 0.0
    // variables added to calculate TES aux. consumption :
    let Expn: Double
    let level: Double
    let level2: Double
    let lowCh: Double
    let lowDc: Double
    
    if parameter.auxConsCurve {
      // old model:
      let rohMean = htf.density(storage.averageTemperature)
      let rohDP = htf.density(Temperature(
        (HeatExchanger.parameter.temperature.htf.inlet.max
          + HeatExchanger.parameter.temperature.htf.outlet.max).kelvin / 2))
      let PrL = parameter.pressureLoss * rohDP / rohMean
        * (storage.massFlow.share(of: parameter.massFlow).ratio) ** 2
      parasitics = PrL * storage.massFlow.rate / rohMean / parameter.pumpEfficiency / 10E6
      if parasitics > 5 {
        var i = 0
      }
      
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
        for (time, power) in zip(parameter.heatTracingTime, parameter.heatTracingPower) {
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
      storage.hSalt.hot = salt.heatCapacity[0] * (parameter.designTemperature.hot.celsius) + 0.5
        * salt.heatCapacity[1] * (parameter.designTemperature.hot.celsius) ** 2 - 350.5536
      storage.hSalt.cold = salt.heatCapacity[0] * (parameter.designTemperature.cold.celsius) + 0.5
        * salt.heatCapacity[1] * (parameter.designTemperature.cold.celsius) ** 2 - 350.5536
      // charge:
      let designChargingHeatFlow = (parameter.massFlow.rate * htf.heatDelta(
        parameter.designTemperature.hot + storage.dTHTF_HotSalt,
        parameter.designTemperature.cold + storage.dTHTF_ColdSalt) / 1_000)
        * parameter.heatExchangerEfficiency
      
      var DesINmassSalt = designChargingHeatFlow
        / (storage.hSalt.hot - storage.hSalt.cold) * 1_000 // kg/s
      DesINmassSalt *= hourFraction * 3_600 // kg in time step (5 minutes)
      // discharge:
      let QoutLoad = parameter.fixedLoadDischarge == 0
        ? Ratio(0.97)
        : Ratio(parameter.fixedLoadDischarge)
      
      let heatexDes = (((SolarField.parameter.massFlow.max - parameter.massFlow)
        .adjusted(with: QoutLoad).rate
        / parameter.heatExchangerEfficiency) * htf.heatDelta(
          parameter.designTemperature.hot - storage.dTHTF_HotSalt,
          parameter.designTemperature.cold - storage.dTHTF_ColdSalt) / 1_000)
        * parameter.heatExchangerEfficiency // design charging power
      
      
      var DesEXmassSalt = heatexDes / (storage.hSalt.hot - storage.hSalt.cold) * 1_000 // kg/s
      DesEXmassSalt *= hourFraction * 3_600 // kg in time step (5 minutes)
      // all this shall be done only one time_____________________________________________________
      
      if case .ex = storage.operationMode {
        storage.massSaltRatio = (storage.massSalt / DesEXmassSalt)
        // if storage.massSaltRatio > 1, case .charging = previous?.operationMode {
        // storage.massSaltRatio = 1
        // has to be check in detail how to determine salt mass flow if it's the first discharge after charging!!
        // }
        parasitics = ((1 - lowDc) * DesAuxEX
          * storage.massSaltRatio ** Expn + lowDc * DesAuxEX)
          * (1 - level * storage.heatrel)
          * ((1 - level2) + level2 * storage.massSaltRatio)
        timeminutessum = 0
        
      } else if case .charging = storage.operationMode {
        storage.massSaltRatio = (storage.massSalt / DesINmassSalt)
        // has to be check in detail how to determine salt mass flow if it's the first charge after discharging!!
        if let previousMode = Storage.previous?.operationMode,
          case .ex = previousMode {
          storage.massSaltRatio = 1
        }
        parasitics = ((1 - lowCh) * DesAuxIN
          * storage.massSaltRatio ** Expn + lowCh * DesAuxIN)
          * ((1 - level) + level * storage.heatrel)
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
  
  /// initial state of storage
  static func prepare(_ storage: inout Storage.PerformanceData) {
    if Design.hasStorage {
      
      storage.heatStored = Design.layout.storage * parameter.heatStoredrel // check if needed!
      
      SolarField.parameter.massFlow.max = MassFlow(
        100 / parameter.massFlow.rate
          * SolarField.parameter.massFlow.max.rate) // 1.05 commented
      parameter.massFlow = MassFlow(
        (1 - parameter.massFlow.rate / 100)
          * SolarField.parameter.massFlow.max.rate) // Change in Formula FR
    }
    
    SolarField.parameter.massFlow.min = MassFlow(SolarField.parameter.massFlow.min.rate
      / 100 * SolarField.parameter.massFlow.max.rate)
    SolarField.parameter.antiFreezeFlow = MassFlow(SolarField.parameter.antiFreezeFlow.rate
      / 100 * SolarField.parameter.massFlow.max.rate)
    
    if SolarField.parameter.pumpParastics.isEmpty {
      if SolarField.parameter.massFlow.max.rate < 900 {
        // calculation of solar field parasitics with empirical correlation derived from solar field model
        SolarField.parameter.pumpParasticsFullLoad = (
          0.000000047327 * Design.layout.solarField ** 4
            - 0.000020044 * Design.layout.solarField ** 3
            + 0.0032862 * Design.layout.solarField ** 2
            - 0.24086 * Design.layout.solarField + 8.2152)
          * (0.7103 * (SolarField.parameter.massFlow.max.rate / 597) ** 3
            - 0.8236 * (SolarField.parameter.massFlow.max.rate / 597) ** 2
            + 1.464 * (SolarField.parameter.massFlow.max.rate / 597) - 0.3508)
      } else {
        SolarField.parameter.pumpParasticsFullLoad = (
          0.0000055 * SolarField.parameter.massFlow.max.rate ** 2
            - 0.0074 * SolarField.parameter.massFlow.max.rate + 4.4)
          * (-0.000001656 * Design.layout.solarField ** 3 + 0.0007981
            * Design.layout.solarField ** 2 - 0.1322
            * Design.layout.solarField + 8.428)
      }
      SolarField.parameter.HTFmass = (93300 + 11328 * Design.layout.solarField)
        * (0.63 * (SolarField.parameter.massFlow.max.rate / 597) + 0.38)
    }
    // check if it should be left so or changed to the real achieved temp. ( < 393 °C)
    // HeatExchanger.parameter.temperature.htf.inlet.max = HeatExchanger.parameter.HTFinTmax
    // HeatExchanger.parameter.temperature.htf.inlet.min = HeatExchanger.parameter.HTFinTmin
    // HeatExchanger.parameter.temperature.htf.outlet.max = HeatExchanger.parameter.HTFoutTmax
    // HeatExchanger.storage.HTFoutTmin = HeatExchanger.parameter.HTFoutTmin never used
    
    if parameter.TturbIterate == -99.99 {
      storage.hSalt.hot = salt.heatCapacity[0]
        * parameter.designTemperature.hot.kelvin
        + 0.5 * salt.heatCapacity[1]
        * parameter.designTemperature.hot.kelvin ** 2 - 350.5536
      storage.hSalt.cold = salt.heatCapacity[0]
        * parameter.designTemperature.cold.kelvin
        + 0.5 * salt.heatCapacity[1]
        * parameter.designTemperature.cold.kelvin ** 2 - 350.5536
      
      HeatExchanger.parameter.temperature.h2o.inlet.max = Temperature(
        parameter.startTemperature.hot.kelvin)
      HeatExchanger.parameter.temperature.h2o.inlet.min = Temperature(
        parameter.startTemperature.cold.kelvin)
      
      if parameter.tempInCst[1] == 0 {
        storage.dTHTF_HotSalt = Temperature(parameter.tempExC0to1[0])
        storage.dTHTF_ColdSalt = Temperature(-parameter.tempInCst[0])
        parameter.tempExC0to1[0] = parameter.designTemperature.hot.kelvin
          - parameter.tempExC0to1[0] // meaning is HTFTout(EX) = HotTankDes - dT
        parameter.tempExCst[0] = parameter.tempExC0to1[0]
        parameter.tempInCst[0] = parameter.designTemperature.cold.kelvin
          - parameter.tempInCst[0] // meaning is HTFTout(IN) = ColdTankDes + dT
        parameter.tempInCst[0] = parameter.tempInCst[0]
      }
    }
  }
  
  // This Subroutine simulates the TES, thermal storage
  // storage.heatFlow  - if to storage, + if drawn from storage!!!
  // This subroutine does not change the filling of the storage
  // LISTING OF INPUT parameter.S:::::::::::::::::::::::::::::::::::::::::::::::::
  // hourFraction =  fraction of hour for this hourFraction
  // storage.OPmode = "FP" freeze protection,  ********passed as shared*************
  //             -not analyzed- to store heat
  //             "PH" if heater could be switched on if necessary (PreHeat)
  //             "EX" discharge solar only, heater cannot be switched on
  // powerBlock.massFlow =  is powerBlock.massFlow, the mass flow of 390øC which is used for
  //             charging and is reduced while charging
  //             or to calculate the max discharge massFlow for correct T at Turb
  // LISTING OF OUTPUT parameter.S::::::::::::::::::::::::::::::::::::::::::::::::
  // storage.heatFlow =   heat from storage (discharging positive, charging negative)
  // heatLossStorage =       Loss of Heat during this hourFraction
  // parasitics =  parasitic electric heat (pump)
  // storage.OPmode = "FP" freeze protection,
  //             "IN" while charging storage
  //             "PH" discharging, preheater has to be switched on
  //             "EX" discharging, heater not needed
  // storage.massFlow  mass flow through in storage, add this to other massFlow   *shared*
  // storage.temperature.outlet  discharging temperatur of storage                     *shared*
  // powerBlock.massFlow = is !!!!!!!!!!!REDUCED!!!!!!!!!!!! while charging
  public static func operate(_ storage: inout Storage.PerformanceData,
                             mode _: PerformanceData.OperationMode,
                             boiler: Boiler.PerformanceData,
                             gasTurbine: GasTurbine.PerformanceData,
                             heatExchanger: HeatExchanger.PerformanceData,
                             powerBlock: inout PowerBlock.PerformanceData,
                             steamTurbine: inout SteamTurbine.PerformanceData,
                             solarField: inout SolarField.PerformanceData,
                             heatFlow: inout HeatFlow) {
    
    let parameter = self.parameter
    var SSetTime = 0
    var i = 0.0
    var StoFit = 0.0
    var Lmax = 0.0
    var MixTemp: Temperature = 0.0
    var MinTBTemp: Temperature = 0.0
    var Rohmean = 0.0
    var RohDP = 0.0
    var PrL = 0.0
    
    var QoutLoad = 0.0
    var jT = 0.0
    var kT = 0.0
    let time = PerformanceCalculator.calendar
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
    
    if heatFlow.solar > 0 {
      solarField.header.massFlow = solarField.massFlow
    } else if case .freezeProtection = solarField.operationMode {
      solarField.header.massFlow = solarField.massFlow
    } else {
      solarField.header.massFlow = 0.0
    }
    
    switch storage.operationMode { // = storage.OPmode
      
    case .charging: // heat can be stored
      
      // storage.operationMode = "IN"
      storage.temperature.inlet = solarField.temperature.outlet
      // the powerBlock.massFlow is only an ideal value, for maximal dT, isnt it wrong?
      storage.massFlow = solarField.massFlow - powerBlock.massFlow
      storage.massFlow.adjust(with: parameter.heatExchangerEfficiency)
      // * Plant.availability[calendar].storage taken out of the formula and included in TES capacity calculation
      
      if parameter.tempInCst[1] > 0 { // usually = 0
        if storage.heatrel < 0.5 {
          StoFit = 1
        } else {
          for i in 0 ..< 3 {
            StoFit += parameter.tempInCst[i] * storage.heatrel ** Double(i)
          }
        }
        StoFit *= parameter.designTemperature.cold.kelvin - parameter.tempInCst[2]
      } else {
        StoFit = StoFit.toKelvin
        if storage.heatrel < 0 {
          StoFit += parameter.tempInCst[0]
            - (parameter.designTemperature.cold - storage.temperatureTank.cold).kelvin
        } else {
          // adjust of HTF outlet temp. with status cold tank temp.
          StoFit += parameter.tempInCst[0]
            - (parameter.designTemperature.cold - storage.temperatureTank.cold).kelvin
        }
      }
      storage.temperature.outlet = Temperature(StoFit)
      heatFlow.storage = storage.massFlow.rate
        * htf.heatDelta(storage.temperature.outlet,
                        storage.temperature.inlet) / 1_000
      
      // storage.heatFlow hat hier die Einheit MW
      // limit the size of the salt-oil heat exchanger
      if parameter.heatExchangerRestrictedMax,
        abs(heatFlow.storage) > parameter.heatExchangerCapacity {
        heatFlow.storage *= parameter.heatExchangerCapacity
        storage.massFlow = MassFlow(heatFlow.storage / htf.heatDelta(
          storage.temperature.outlet, storage.temperature.inlet) * 1_000)
        // FIXME    powerBlock.massFlow = powerBlock.massFlow
        // added to avoid increase in PB massFlow
        if case .demand = parameter.strategy { // (always)
          // too much power from sun, dump
          heatFlow.dump += heatFlow.production
            - HeatExchanger.parameter.SCCHTFheatFlow + heatFlow.storage
        } else {
          heatFlow.dump = heatFlow.dump + heatFlow.production
            - heatFlow.demand + heatFlow.storage
        }
        solarField.header.massFlow = powerBlock.massFlow + storage.massFlow
        // reduce HTF massflow in SF
        heatFlow.solar = solarField.massFlow.rate * htf.heatDelta(
          solarField.temperature.outlet, solarField.temperature.inlet) / 1_000
        heatFlow.production = heatFlow.solar
      }
      
      // go Storageparasitics
      
    case .freezeProtection: // heat can be stored
      
      storage.temperature.inlet = Heater.parameter.nominalTemperatureOut
      storage.massFlow = powerBlock.massFlow
      
      if parameter.tempInCst[1] > 0 {
        if storage.heatrel < 0.5 {
          StoFit = 1
        } else {
          for i in 0 ..< 3 {
            StoFit += parameter.tempInCst[i] * storage.heatrel ** Double(i)
          }
        }
        StoFit *= parameter.designTemperature.cold.kelvin - parameter.tempInCst[2]
      } else {
        StoFit = StoFit.toKelvin
        if storage.heatrel < 0 {
          StoFit += parameter.tempInCst[0]
            - (parameter.designTemperature.cold - storage.temperatureTank.cold).kelvin
        } else {
          StoFit += parameter.tempInCst[0]
            - (parameter.designTemperature.cold - storage.temperatureTank.cold).kelvin
        }
      }
      storage.temperature.outlet = Temperature(StoFit)
      heatFlow.storage = storage.massFlow.rate * htf.heatDelta(
        storage.temperature.outlet, storage.temperature.inlet) / 1_000 // [MW]
      // limit the size of the salt-oil heat exchanger
      if parameter.heatExchangerRestrictedMax,
        abs(heatFlow.storage) > parameter.heatExchangerCapacity {
        heatFlow.storage *= parameter.heatExchangerCapacity
        storage.massFlow = MassFlow(heatFlow.storage / htf.heatDelta(
          storage.temperature.outlet, storage.temperature.inlet) * 1_000)
        powerBlock.massFlow = storage.massFlow
      }
      
      // go Storageparasitics
      
    case .ex: // heat can be released
      // calculate discharge rate only once per day, directly after sunset
      if time.hour >= SSetTime && time.hour < (SSetTime + 1) && parameter.isVariable {
        switch parameter.definedBy {
        case .hours:
          storage.heatStored = storage.heatrel * Design.layout.storage
            * SteamTurbine.parameter.power.max / SteamTurbine.parameter.efficiencyNominal
        case .cap:
          storage.heatStored = storage.heatrel * Design.layout.storage_cap
        case .ton:
          storage.hSalt.hot = salt.heatCapacity[0]
            * (parameter.designTemperature.hot.celsius) + 0.5 * salt.heatCapacity[1]
            * (parameter.designTemperature.hot.celsius) ** 2 - 350.5536
          storage.hSalt.cold = salt.heatCapacity[0]
            * (parameter.designTemperature.cold.celsius) + 0.5 * salt.heatCapacity[1]
            * (parameter.designTemperature.cold.celsius) ** 2 - 350.5536
          storage.heatStored = storage.heatrel * Design.layout.storage_ton
            * (storage.hSalt.hot - storage.hSalt.cold)
            * (parameter.designTemperature.hot - parameter.designTemperature.cold).kelvin / 3_600
        }
        
        if nightHour == 0 { // added to avoid division by zero if calculation doesn//t begin at Jan 1st
          nightHour = 12 // assumed night duration of the first day
        }
        
        // QoutLoad controls the load of the TES during discharge. Before was fixed to 0.97
        QoutLoad = storage.heatStored / nightHour
          / (SteamTurbine.parameter.power.max
            / SteamTurbine.parameter.efficiencyNominal)
        
        if QoutLoad < parameter.MinDis {
          QoutLoad = parameter.MinDis
        } else if QoutLoad > 1 {
          QoutLoad = 1
        }
      }
      // if no previous calculation has been done and TES must be discharged
      if QoutLoad == 0 && parameter.isVariable {
        switch parameter.definedBy {
        case .hours:
          storage.heatStored = storage.heatrel * Design.layout.storage
            * SteamTurbine.parameter.power.max
            / SteamTurbine.parameter.efficiencyNominal
        case .cap:
          storage.heatStored = storage.heatrel * Design.layout.storage_cap
        case .ton:
          storage.hSalt.hot = salt.heatCapacity[0]
            * (parameter.designTemperature.hot.celsius) + 0.5
            * salt.heatCapacity[1]
            * (parameter.designTemperature.hot.celsius) ** 2 - 350.5536
          storage.hSalt.cold = salt.heatCapacity[0]
            * (parameter.designTemperature.cold.celsius) + 0.5
            * salt.heatCapacity[1]
            * (parameter.designTemperature.cold.celsius) ** 2 - 350.5536
          storage.heatStored = storage.heatrel * Design.layout.storage_ton
            * (storage.hSalt.hot - storage.hSalt.cold)
            * (parameter.designTemperature.hot
              - parameter.designTemperature.cold).kelvin / 3_600
        }
        
        if nightHour == 0 { // added to avoid division by zero if calculation doesn't begin at Jan 1st
          nightHour = 12 // assumed night duration of the first day
        }
        // QoutLoad controls the load of the TES during discharge.
        QoutLoad = storage.heatStored / nightHour / (SteamTurbine.parameter.power.max
          / SteamTurbine.parameter.efficiencyNominal)
        
        if QoutLoad < parameter.MinDis {
          QoutLoad = parameter.MinDis
        } else if QoutLoad > 1 {
          QoutLoad = 1
        }
      }
      // fixed discharge
      if !parameter.isVariable {
        // avoid user error by no input
        QoutLoad = parameter.fixedLoadDischarge == 0
          ? 0.97 : parameter.fixedLoadDischarge
      }
      
      switch solarField.operationMode {
      case .freezeProtection:
        // reduction of HTF Mass flow during strorage discharging due to results of AndaSol-1 Heat Balance
        storage.massFlow = MassFlow(QoutLoad * powerBlock.massFlow.rate
          / parameter.heatExchangerEfficiency)
        // - solarField.massFlow
        
      case .operating where solarField.massFlow.rate > 0:
        // Mass flow is correctd by parameter.Hx this factor is new
        storage.massFlow = MassFlow(powerBlock.massFlow.rate
          / parameter.heatExchangerEfficiency - solarField.massFlow.rate)
      // * 0.97 deleted after separating combined from storage only operation
      default:
        //if demand < 1 { // only for OU1!?
        //  storage.massFlow = powerBlock.massFlow * 1.3
        //    / parameter.heatExchangerEfficiency
        // for OU1 adjust to demand file and not TES design parameter.s. CHECK! 1.3 to get right results
        // } else {
        // added to control TES discharge during night
        storage.massFlow = MassFlow(QoutLoad * powerBlock.massFlow.rate
          / parameter.heatExchangerEfficiency)
        // }
      }
      
      storage.temperature.inlet = powerBlock.temperature.outlet // used for parasitics
      
      // go StorageOutletTemp   // STOoutTemp remains constant, whatever MassFlow
      
      while true {
        defer { storage.massFlow.adjust(with: 0.97) } // reduce 5%
        heatFlow.storage = storage.massFlow.rate
          * htf.heatDelta(storage.temperature.outlet,
                          storage.temperature.inlet) / 1_000
        
        if parameter.heatExchangerRestrictedMax,
          abs(heatFlow.storage) > parameter.heatExchangerCapacity {
          heatFlow.storage = heatFlow.storage * parameter.heatExchangerCapacity
          storage.massFlow = MassFlow(heatFlow.storage /
            htf.temperatureDelta(storage.temperature.outlet.kelvin,
                                 storage.temperature.inlet).kelvin * 1_000)
          if case .freezeProtection = solarField.operationMode {
            // reduction of HTF Mass flow during storage discharging due to results of AndaSol-1 Heat Balance
            powerBlock.massFlow = MassFlow(storage.massFlow.rate
              * parameter.heatExchangerEfficiency / 0.97) // - solarField.massFlow
            
          } else {
            // Mass flow is correctd by new factor
            powerBlock.massFlow = MassFlow((storage.massFlow + solarField.massFlow).rate
              * parameter.heatExchangerEfficiency / 0.97)
          }
        }
        
        steamTurbine.load = Ratio((heatFlow.solar + heatFlow.storage)
          / (SteamTurbine.parameter.power.max
            / SteamTurbine.efficiency(at: steamTurbine.load, Lmax: 1.0,
                                      boiler: boiler,
                                      gasTurbine: gasTurbine,
                                      heatExchanger: heatExchanger)))
        MixTemp = htf.mixingTemperature(outlet: solarField, with: status)
        MinTBTemp = Temperature(310.0.toKelvin) // TurbineTempLoad(SteamTurbine.storage.load)
        
        if MixTemp.kelvin > MinTBTemp.kelvin - Simulation.parameter.tempTolerance.kelvin * 2 {
          heatFlow.storage = storage.massFlow.rate
            * htf.heatDelta(storage.temperature.outlet,
                            storage.temperature.inlet) / 1_000
          // go Storageparasitics
          break
        } else if storage.massFlow.rate <= 0.05 * powerBlock.massFlow.rate {
          heatFlow.storage = 0
          storage.operationMode = .noOperation
          // parasitics = 0
          storage.massFlow = 0.0
          break
        }
      }
      //   }
      
    case .ph: // the rest is heated by SF to 391øC
      // FIXME storage.operationMode = "PH"
      storage.massFlow = powerBlock.massFlow - solarField.massFlow
      storage.temperature.inlet = powerBlock.temperature.outlet
      // go StorageOutletTemp
      heatFlow.storage = storage.massFlow.rate
        * htf.heatDelta(storage.temperature.outlet,
                        storage.temperature.inlet) / 1_000
      // limit the size of the salt-oil heat exchanger
      if parameter.heatExchangerRestrictedMax,
        abs(heatFlow.storage) > parameter.heatExchangerCapacity {
        heatFlow.storage = heatFlow.storage * parameter.heatExchangerCapacity
        storage.massFlow = MassFlow(heatFlow.storage /
          htf.heatDelta(storage.temperature.outlet,
                        storage.temperature.inlet) * 1_000)
        // go StorageOutletTemp
        heatFlow.storage = storage.massFlow.rate *
          htf.heatDelta(storage.temperature.outlet,
                        storage.temperature.inlet) / 1_000
      }
      
    // go Storageparasitics
    case .freezeProtection:
      
      let splitfactor: Ratio = 0.4
      storage.massFlow = SolarField.parameter.antiFreezeFlow
        .adjusted(with: splitfactor)
      solarField.header.massFlow = SolarField.parameter.antiFreezeFlow
      storage.temperature.inlet = powerBlock.temperature.outlet // used for parasitics
      if parameter.tempInCst[1] > 0 {
        if parameter.tempExCst.indices.contains(2) {
          storage.temperature.outlet = storage.temperature.inlet
        } else {
          if storage.heatrel > 0.5 {
            //for i in 0 ..< 3 {
            StoFit = 1
            //}
          } else {
            for i in 0 ..< 3 {
              StoFit += parameter.tempExC0to1[i] * storage.heatrel ** Double(i)
            }
          }
          storage.temperature.outlet = Temperature(
            StoFit * parameter.designTemperature.hot.kelvin)
        }
        storage.temperature.outlet = Temperature(
          splitfactor.ratio * storage.temperature.outlet.kelvin
            + (1 - splitfactor.ratio) * storage.temperature.inlet.kelvin)
      } else {
        // storage.temperature.outlet = parameter.storage.temperatureTank.cold
      }
      // go Storageparasitics
      
    case .no:
      storage.operationMode = .noOperation // Temperatures remain constant
      // go Storageparasitics
      heatFlow.storage = 0
      storage.massFlow = MassFlow() // parasitics = 0:
    default: break
    }
    
    // Storage Heat Losses: Check calculation!!!
    if parameter.tempInCst[1] > 0 { // it doesn//t get in here usually.
      if parameter.tempInCst[2] > 0 {
        StoFit = 0
        if storage.heatrel < 0 {
          for i in 0 ..< 3 {
            // FIXME StoFit += parameter.heatLossConstants[i] * storage.heatrel ** Double(i)
          }
        } else {
          for i in 0 ..< 3 {
            // FIXME StoFit += parameter.heatLossConstants[i] * storage.heatrel ** Double(i)
          }
        }
        
        storage.heatLossStorage = StoFit * 3_600 * 0.0000001 * Design.layout.storage // [MW] !!!!
      } else {
        // FIXME  heatLossStorage = parameter.heatLossConstants[0] / 1_000 * (storage.heatrel
        // * (parameter.designTemperature.hot - parameter.designTemperature.cold)
        // + parameter.designTemperature.cold)
        // / parameter.designTemperature.hot
      }
    } else {
      storage.heatLossStorage = 0
    }
    
    // Exit Sub
    
    StorageOutletTemp:
      if parameter.tempInCst[1] > 0 {
      if storage.heatrel > 0.5 {
        //for i in 0 ..< 3 {
        StoFit = 1
        //}
      } else {
        for i in 0 ..< 3 {
          StoFit += parameter.tempExC0to1[i] * storage.heatrel ** Double(i)
        }
      }
      StoFit *= parameter.designTemperature.hot.kelvin - parameter.tempExCst[1]
    } else {
      StoFit = StoFit.toKelvin
      if storage.heatrel < 0 {
        StoFit += parameter.tempExCst[0]
          - (parameter.designTemperature.hot.kelvin - storage.temperatureTank.hot.kelvin)
      } else {
        StoFit += parameter.tempExC0to1[0]
          - (parameter.designTemperature.hot.kelvin - storage.temperatureTank.hot.kelvin)
        // adjust of HTF outlet temp. with status hot tank temp.
      }
    }
    storage.temperature.outlet = Temperature(StoFit) // independent from massFlow !!!
  }
  
  static func prepare(storage: inout Storage.PerformanceData,
                      powerBlock: inout PowerBlock.PerformanceData,
                      steamTurbine: SteamTurbine.PerformanceData) {
    if Design.hasStorage { // keep track of the filling of the storage
      
      let ColdTankQverl = parameter.heatLoss.cold
        * (storage.temperatureTank.cold.kelvin - 300.0)
        / (parameter.designTemperature.cold.kelvin - 27)
      let HotTankQverl = parameter.designTemperature.cold.kelvin
        * (storage.temperatureTank.hot.kelvin - 300.0)
        / (parameter.designTemperature.hot.kelvin - 27)
      storage.hSalt.hot = salt.heatCapacity[0]
        * (parameter.designTemperature.hot.celsius) + 0.5 * salt.heatCapacity[1]
        * (parameter.designTemperature.hot.celsius) ** 2 - 350.5536
      storage.hSalt.cold = salt.heatCapacity[0]
        * (parameter.designTemperature.cold.celsius) + 0.5 * salt.heatCapacity[1]
        * (parameter.designTemperature.cold.celsius) ** 2 - 350.5536
      
      switch parameter.definedBy {
      case .hours:
        // Plant.availability[currentDate.month].storage added here to apply TES availability on capacity and not on charge load
        storage.massSalt = Design.layout.storage
          * Plant.availability[PerformanceCalculator.calendar].storage.ratio
          * (1 + parameter.dischargeToTurbine)
        storage.massSalt *= HeatExchanger.parameter.SCCHTFheatFlow * 1_000 * 3_600
          / (storage.hSalt.hot - storage.hSalt.cold)
      case .cap:
        storage.massSalt = Design.layout.storage_cap
          * Plant.availability[PerformanceCalculator.calendar].storage.ratio
          * (1 + parameter.dischargeToTurbine)
        storage.massSalt *= 1_000 * 3_600 / (storage.hSalt.hot - storage.hSalt.cold)
      case .ton:
        storage.massSalt = Design.layout.storage_ton
          * Plant.availability[PerformanceCalculator.calendar].storage.ratio
        storage.massSalt *= 1_000 * (1 + parameter.dischargeToTurbine)
      }
      
      //   Saltmass = parameter.heatLossConstants0[3]
      
      if parameter.tempInCst[1] > 0 { // it doesnt get in here usually, therefore not updated yet
        storage.heatStored = storage.heatStored - storage.heatLossStorage
          * hourFraction - Plant.heatFlow.storage * hourFraction
        storage.heatrel = storage.heatStored
          / (Design.layout.storage * HeatExchanger.parameter.SCCHTFheatFlow)
      } else {
        
        switch storage.operationMode {
          
        case .charging:
          // Hot salt is storage.temperature.inlet - dTHTF_HotSalt
          storage.hSalt.hot = salt.heatCapacity[0]
            * ((storage.temperature.inlet - storage.dTHTF_HotSalt).celsius)
            + 0.5 * salt.heatCapacity[1]
            * ((storage.temperature.inlet - storage.dTHTF_HotSalt).celsius) ** 2 - 350.5536
          storage.hSalt.cold = salt.heatCapacity[0]
            * (storage.temperatureTank.cold.celsius)
            + 0.5 * salt.heatCapacity[1]
            * (storage.temperatureTank.cold.celsius) ** 2 - 350.5536
          storage.massSalt = -Plant.heatFlow.storage
            / (storage.hSalt.hot - storage.hSalt.cold) * hourFraction * 3_600 * 1_000
          storage.mass.cold = storage.mass.cold - storage.massSalt
          
          if storage.mass.cold < minmass(storage: storage) { // added to avoid negative or too low mass and therefore no heat losses.
            storage.massSalt = storage.massSalt
              - (minmass(storage: storage) - storage.mass.cold) }
          if storage.massSalt < 10 { storage.massSalt = 0
            storage.mass.cold = minmass(storage: storage)
            storage.mass.hot = storage.massSalt + storage.mass.hot
            storage.heatrel = parameter.chargeTo
          } else {
            storage.mass.hot = storage.massSalt + storage.mass.hot
            storage.heatrel = storage.mass.hot
              * (parameter.designTemperature.hot - parameter.designTemperature.cold).kelvin
              / (storage.massSalt * (parameter.designTemperature.hot
                - parameter.designTemperature.cold).kelvin)
          }
          if storage.mass.hot > 0 {
            storage.temperatureTank.hot = Temperature((storage.massSalt
              * (storage.temperature.inlet - storage.dTHTF_HotSalt).kelvin
              + storage.mass.hot * storage.temperatureTank.hot.kelvin)
              / (storage.massSalt + storage.mass.hot))
          } else {
            storage.temperatureTank.hot = storage.temperatureTank.hot
          }
          
        case .fc:
          // check if changes have to be done related to salt temperature
          storage.hSalt.hot = salt.heatCapacity[0]
            * (parameter.designTemperature.hot.celsius)
            + 0.5 * salt.heatCapacity[1]
            * (parameter.designTemperature.hot.celsius) ** 2 - 350.5536
          storage.hSalt.cold = salt.heatCapacity[0]
            * (storage.temperatureTank.cold.celsius)
            + 0.5 * salt.heatCapacity[1]
            * (storage.temperatureTank.cold.celsius) ** 2 - 350.5536
          storage.massSalt = -Plant.heatFlow.storage
            / (storage.hSalt.hot - storage.hSalt.cold)
            * hourFraction * 3_600 * 1_000
          storage.mass.cold = storage.mass.cold - storage.massSalt
          storage.mass.hot = storage.massSalt + storage.mass.hot
          storage.heatrel = storage.mass.hot
            * (parameter.designTemperature.hot - parameter.designTemperature.cold).kelvin
            / (storage.massSalt * (parameter.designTemperature.hot
              - parameter.designTemperature.cold).kelvin)
          if storage.mass.hot > 0 {
            storage.temperatureTank.hot = Temperature((storage.massSalt
              * parameter.designTemperature.hot.kelvin
              + storage.mass.hot * storage.temperatureTank.hot.kelvin)
              / (storage.massSalt + storage.mass.hot))
          } else {
            storage.temperatureTank.hot = storage.temperatureTank.hot
          }
          
        case .ex:
          storage.hSalt.hot = salt.heatCapacity[0]
            * (storage.temperatureTank.hot.celsius)
            + 0.5 * salt.heatCapacity[1]
            * (storage.temperatureTank.hot.celsius) ** 2 - 350.5536
          storage.hSalt.cold = salt.heatCapacity[0]
            * ((storage.temperature.inlet + storage.dTHTF_ColdSalt).celsius)
          storage.hSalt.cold += 0.5 * salt.heatCapacity[1]
            * ((storage.temperature.inlet
              + storage.dTHTF_ColdSalt).celsius) ** 2 - 350.5536
          
          storage.massSalt = Plant.heatFlow.storage
            / (storage.hSalt.hot - storage.hSalt.cold) * hourFraction * 3_600 * 1_000
          storage.mass.hot = -storage.massSalt + storage.mass.hot
          
          if storage.mass.hot < minmass(storage: storage) {
            // added to avoid negative or too low mass and therefore no heat losses
            storage.massSalt = storage.massSalt - (minmass(storage: storage) - storage.mass.hot) }
          if storage.massSalt < 10 {
            storage.massSalt = 0
            Plant.heatFlow.storage = storage.massSalt
              * (storage.hSalt.hot - storage.hSalt.cold) / hourFraction / 3_600 / 1_000
            storage.mass.hot = minmass(storage: storage)
            
            storage.mass.cold = storage.mass.cold + storage.massSalt
            storage.heatrel = parameter.dischargeToTurbine
          } else {
            storage.mass.cold = storage.mass.cold + storage.massSalt
            storage.heatrel = storage.mass.hot * (parameter.designTemperature.hot
              - parameter.designTemperature.cold).kelvin / (storage.massSalt *
                (parameter.designTemperature.hot
                  - parameter.designTemperature.cold).kelvin)
          }
          if storage.mass.cold > 0 {
            // cold salt is storage.temperature.inlet + dTHTF_ColdSalt
            storage.temperatureTank.cold = Temperature((storage.massSalt
              * (storage.temperature.inlet + storage.dTHTF_ColdSalt).kelvin
              + storage.mass.cold * storage.temperatureTank.cold.kelvin)
              / (storage.massSalt + storage.mass.cold))
          }
          
        case .ph:
          storage.hSalt.hot = salt.heatCapacity[0]
            * (storage.temperatureTank.hot.celsius)
            + 0.5 * salt.heatCapacity[1]
            * (storage.temperatureTank.hot.celsius) ** 2 - 350.5536
          storage.hSalt.cold = salt.heatCapacity[0]
            * (parameter.designTemperature.cold.celsius)
            + 0.5 * salt.heatCapacity[1]
            * (parameter.designTemperature.cold.celsius) ** 2 - 350.5536
          storage.massSalt = Plant.heatFlow.storage
            / (storage.hSalt.hot - storage.hSalt.cold)
            * hourFraction * 3_600 * 1_000
          storage.mass.hot = -storage.massSalt + storage.mass.hot
          
          storage.mass.cold = storage.mass.cold + storage.massSalt
          storage.heatrel = storage.mass.hot
            * (parameter.designTemperature.hot - parameter.designTemperature.cold).kelvin
            / (storage.massSalt * (parameter.designTemperature.hot
              - parameter.designTemperature.cold).kelvin)
          
          storage.temperatureTank.cold = Temperature(
            (storage.massSalt * parameter.designTemperature.cold.kelvin
              + storage.mass.cold * storage.temperatureTank.cold.kelvin)
              / (storage.massSalt + storage.mass.cold))
          
        case .freezeProtection:
          let splitfactor = parameter.HTF == .hiXL ? 0.4 : 1
          
          storage.massSalt = SolarField.parameter.antiFreezeFlow.rate * hourFraction * 3_600
          storage.temperatureTank.cold = Temperature(
            (splitfactor * storage.massSalt
              * powerBlock.temperature.outlet.kelvin
              + storage.mass.cold * storage.temperatureTank.cold.kelvin)
              / (splitfactor * storage.massSalt + storage.mass.cold))
          storage.StoTcoldTout = splitfactor * storage.temperatureTank.cold.kelvin
            + (1 - splitfactor) * powerBlock.temperature.outlet.kelvin
          // powerBlock.temperature.outlet  = storage.temperatureTank.cold
          
        case .no:
          if parameter.TturbIterate < -90,
            storage.temperatureTank.cold < parameter.designTemperature.cold,
            powerBlock.temperature.outlet > storage.temperatureTank.cold,
            storage.mass.cold > 0 {
            storage.massSalt = powerBlock.massFlow.rate * hourFraction * 3_600
            storage.temperatureTank.cold = Temperature(
              (storage.massSalt * powerBlock.temperature.outlet.kelvin
                + storage.mass.cold * storage.temperatureTank.cold.kelvin)
                / (storage.massSalt + storage.mass.cold))
            storage.operationMode = .sc
          }
        default: break
        }
        
        // Storage Heat Losses:
        if steamTurbine.isMaintained {
        } else {
          if storage.mass.hot > 0 { // parameter.dischargeToTurbine * Saltmass {
            // enthalpy before cooling down
            storage.hSalt.hot = salt.heatCapacity[0]
              * (storage.temperatureTank.hot.celsius)
              + 0.5 * salt.heatCapacity[1]
              * (storage.temperatureTank.hot.celsius) ** 2 - 350.5536
            // enthalpy after cooling down
            storage.hSalt.hot = storage.hSalt.hot - HotTankQverl
              * Double(period) / storage.mass.hot
            // temp after cool down
            storage.temperatureTank.hot = Temperature((-salt.heatCapacity[0]
              + (salt.heatCapacity[0] ** 2
                - 4 * (salt.heatCapacity[1] * 0.5)
                * (-350.5536 - storage.hSalt.hot)) ** 0.5)
              / (2 * salt.heatCapacity[1] * 0.5).toKelvin)
          }
          if storage.mass.cold > parameter.dischargeToTurbine * storage.massSalt {
            // enthalpy before cooling down
            storage.hSalt.cold = salt.heatCapacity[0]
              * (storage.temperatureTank.cold.celsius)
              + 0.5 * salt.heatCapacity[1]
              * (storage.temperatureTank.cold.celsius) ** 2 - 350.5536
            // enthalpy after cooling down
            storage.hSalt.cold = storage.hSalt.cold - ColdTankQverl
              * Double(period) / storage.mass.cold
            // temp after cool down
            storage.temperatureTank.cold = Temperature((-salt.heatCapacity[0]
              + (salt.heatCapacity[0] ** 2
                - 4 * (salt.heatCapacity[1] * 0.5)
                * (-350.5536 - storage.hSalt.cold)) ** 0.5)
              / (2 * salt.heatCapacity[1] * 0.5).toKelvin)
          }
        }
      }
      
      if Plant.heatFlow.storage < 0 {
        if case .freezeProtection = storage.operationMode {
          // FIXME powerBlock.temperature.outlet // = powerBlock.temperature.outlet
        } else if case .charging = storage.operationMode {
          // if storage.operationMode = "IN" added to avoid Tmix during TES discharge (valid for indirect storage), check!
          powerBlock.temperature.outlet = htf.mixingTemperature(
            outlet: PowerBlock.status, with: status)
        } else { // for indirect TES discharge added, check!
          // FIXME powerBlock.temperature.outlet // = powerBlock.temperature.outlet
        }
      }
      
      // FIXME HeatExchanger.storage.H2OinTmax = storage.mass.hot
      // FIXME HeatExchanger.storage.H2OinTmin = storage.mass.cold
      // FIXME HeatExchanger.storage.H2OoutTmax = storage.temperatureTank.hot
      // FIXME HeatExchanger.storage.H2OoutTmin = storage.temperatureTank.cold
      
    }
  }
  static func operate(_ storage: inout Storage.PerformanceData,
                      powerBlock: inout PowerBlock.PerformanceData,
                      steamTurbine: inout SteamTurbine.PerformanceData,
                      heater: inout Heater.PerformanceData,
                      solarField: inout SolarField.PerformanceData,
                      boiler: Boiler.PerformanceData,
                      gasTurbine: GasTurbine.PerformanceData,
                      heatExchanger: HeatExchanger.PerformanceData,
                      availableFuel: inout Double,
                      fuel: inout FuelConsumption,
                      heatFlow: inout HeatFlow) {
    
    var heatFlowDiff = 0.0
    let time = PerformanceCalculator.calendar
    if Design.hasGasTurbine {
      powerBlock.massFlow = MassFlow(HeatExchanger.parameter.SCCHTFheatFlow /
        (htf.heatDelta(
          HeatExchanger.parameter.temperature.htf.inlet.max,
          HeatExchanger.parameter.temperature.htf.outlet.max) / 1_000))
      heatFlowDiff = heatFlow.production - HeatExchanger.parameter.SCCHTFheatFlow
    } else {
      
      if case .always = parameter.strategy {
        // if demand is selected, variable is called Alw but calculation is done as demand, error comes from older version // "Dem"
        powerBlock.massFlow = MassFlow(heatFlow.demand
          / (htf.heatDelta(
            HeatExchanger.parameter.temperature.htf.inlet.max,
            HeatExchanger.parameter.temperature.htf.outlet.max) / 1_000))
        
        if !powerBlock.massFlow.isNearZero { // to avoid negative massfows
          heatFlowDiff = 0
          powerBlock.massFlow = solarField.header.massFlow
        }
      } else {
        heatFlowDiff = heatFlow.production - heatFlow.demand // [MW]
        if parameter.heatExchangerRestrictedMin {
          // added to avoid input to storage lower than minimal HX// s capacity
          heatFlow.toStorageMin = parameter.heatExchangerMinCapacity
            * HeatExchanger.parameter.SCCHTFheatFlow
            * (1 - parameter.massFlow.rate / SolarField.parameter.massFlow.max.rate)
            / (parameter.massFlow.rate / SolarField.parameter.massFlow.max.rate)
          
          if heatFlowDiff > 0 && heatFlowDiff < heatFlow.toStorageMin {
            heatFlow.demand = heatFlow.demand - (heatFlow.toStorageMin - heatFlowDiff)
            powerBlock.massFlow = MassFlow(heatFlow.demand
              / htf.heatDelta(
                HeatExchanger.parameter.temperature.htf.inlet.max,
                HeatExchanger.parameter.temperature.htf.outlet.max) / 1_000)
            heatFlowDiff = heatFlow.toStorageMin
          }
        }
      }
      if case .demand = parameter.strategy {
        // if Always is selected, variable is called "Dem" but calculation is done as "Always", error comes from older version // "Alw" {
        powerBlock.massFlow = MassFlow(HeatExchanger.parameter.SCCHTFheatFlow
          / (htf.heatDelta(
            HeatExchanger.parameter.temperature.htf.inlet.max,
            HeatExchanger.parameter.temperature.htf.outlet.max) / 1_000))
        
        if powerBlock.massFlow < 0.0 { // to avoid negative massfows
          heatFlowDiff = 0
          powerBlock.massFlow = solarField.header.massFlow
        } else {
          heatFlowDiff = heatFlow.production - HeatExchanger.parameter.SCCHTFheatFlow
          // changed back as heatFlow.production - HeatExchanger.parameter.SCCHTFheat// heatFlow.demand     // [MW]
          if parameter.heatExchangerRestrictedMin {
            // added to avoid input to storage lower than minimal HX// s capacity
            heatFlow.toStorageMin = HeatExchanger.parameter.SCCHTFheatFlow
              * (1 - parameter.massFlow.rate / SolarField.parameter.massFlow.max.rate)
              / (parameter.massFlow.rate / SolarField.parameter.massFlow.max.rate)
            
            if heatFlowDiff > 0 && heatFlowDiff < heatFlow.toStorageMin {
              powerBlock.massFlow = MassFlow((HeatExchanger.parameter.SCCHTFheatFlow
                - (heatFlow.toStorageMin - heatFlowDiff))
                / (htf.heatDelta(
                  HeatExchanger.parameter.temperature.htf.inlet.max,
                  HeatExchanger.parameter.temperature.htf.outlet.max) / 1_000))
              heatFlowDiff = heatFlow.toStorageMin
            }
          }
        }
      }
      
      if case .shifter = parameter.strategy { // parameter.strategy = "Ful" // Booster or Shifter
        // new calculation of shifter, old kept and commented below this:
        
        if time.month < parameter.startexcep
          || time.month > parameter.endexcep {
          storage.heatProductionLoad = parameter.heatProductionLoadWinter
          if DNIdaysum > parameter.badDNIwinter * 1_000 {
            // sunny day, TES can be fully charged also by running TB at full load
            storage.heatProductionLoad = 1
          }
        } else {
          storage.heatProductionLoad = parameter.heatProductionLoadSummer
          if DNIdaysum > parameter.badDNIsummer * 1_000 {
            // sunny day, TES can be fully charged also by running TB at full load
            storage.heatProductionLoad = 1
          }
        }
        
        if heatFlow.production > 0 { // Qsol > 0
          
          if heatFlow.production < heatFlow.demand,
            storage.heatrel < parameter.chargeTo,
            time.hour < 17 {
            // Qsol not enough for POB demand load (e.g. at the beginning of the day)
            powerBlock.massFlow = MassFlow(min(
              storage.heatProductionLoad * heatFlow.demand,
              heatFlow.production)
              / (htf.heatDelta(
                HeatExchanger.parameter.temperature.htf.inlet.max,
                HeatExchanger.parameter.temperature.htf.outlet.max) / 1_000))
            
            heatFlowDiff = heatFlow.production - min(
              storage.heatProductionLoad * heatFlow.demand,
              heatFlow.production)
            // TES gets the rest available
            if parameter.heatExchangerRestrictedMax {
              heatFlowDiff = min(heatFlowDiff, parameter.heatExchangerCapacity)
            } else {
              let value = SteamTurbine.parameter.power.max
                / SteamTurbine.parameter.efficiencyNominal
                / HeatExchanger.parameter.efficiency
              if heatFlowDiff > value {
                heatFlowDiff = value
              }
            }
          } else if heatFlow.production < heatFlow.demand,
            storage.heatrel >= parameter.chargeTo {
            // Qsol not enough for POB demand load (e.g. at the end of the day) and TES is full
            powerBlock.massFlow = MassFlow(heatFlow.demand / (htf.heatDelta(
              HeatExchanger.parameter.temperature.htf.inlet.max,
              HeatExchanger.parameter.temperature.htf.outlet.max) / 1_000))
            // send all to POB and if needed discharge TES
            
            heatFlowDiff = heatFlow.production - heatFlow.demand
            // TES provides the rest available
            // check what if TES is full and POB could get more than 50% of design!!
            if parameter.heatExchangerRestrictedMax {
              heatFlowDiff = max(heatFlowDiff, -parameter.heatExchangerCapacity)
            } else { // signs below changed
              let value = SteamTurbine.parameter.power.max
                / SteamTurbine.parameter.efficiencyNominal
                / HeatExchanger.parameter.efficiency
              if heatFlowDiff > -value {
                heatFlowDiff = -value
              }
            }
          } else if heatFlow.production > heatFlow.demand,
            storage.heatrel < parameter.chargeTo,
            solarField.header.massFlow >= powerBlock.massFlow {
            // more Qsol than needed by POB and TES is not full
            powerBlock.massFlow = MassFlow(
              (storage.heatProductionLoad * heatFlow.demand)
                / (htf.heatDelta(
                  HeatExchanger.parameter.temperature.htf.inlet.max,
                  HeatExchanger.parameter.temperature.htf.outlet.max) / 1_000))
            // from avail heat cover first 50% of POB demand
            heatFlowDiff = heatFlow.production - (storage.heatProductionLoad * heatFlow.demand)
            // TES gets the rest available
            if parameter.heatExchangerRestrictedMax {
              if heatFlowDiff > parameter.heatExchangerCapacity {
                // rest heat to TES is too high, use more heat to POB
                powerBlock.massFlow = MassFlow(
                  (heatFlow.production - parameter.heatExchangerCapacity)
                    / (htf.heatDelta(
                      HeatExchanger.parameter.temperature.htf.inlet.max,
                      HeatExchanger.parameter.temperature.htf.outlet.max) / 1_000))
                // from avail heat cover first 50% of POB demand
                
                heatFlowDiff = parameter.heatExchangerCapacity
                // TES gets max heat input
              }
            }
          }
        } else {
          var i = 0
          if case .hours = parameter.definedBy {
            // condition added. It usually doesn't get in here. therefore, not correctly programmed yet
            if heatFlow.production > heatFlow.demand,
              storage.heatrel > 1 * SteamTurbine.parameter.power.max
                / SteamTurbine.parameter.efficiencyNominal / Design.layout.storage {
              i = -1
              //   } else if parameter.definedBy = "cap" {
              //       if heatFlow.production > heatFlow.demand && storage.heatrel > 1 * SteamTurbine.parameter.power.max / SteamTurbine.parameter.efficiencyNominal / Design.layout.storage_cap { i = -1
              //   } else if parameter.definedBy = "ton" {
              //       if heatFlow.production > heatFlow.demand && storage.heatrel > 1 * SteamTurbine.parameter.power.max / SteamTurbine.parameter.efficiencyNominal / Design.layout.storage_ton { i = -1
            }
            if i == -1 {
              heatFlow.demand = SteamTurbine.parameter.power.max
                * Plant.availability[time].powerBlock.ratio
                / SteamTurbine.efficiency(at: steamTurbine.load, Lmax: 1.0,
                                          boiler: boiler,
                                          gasTurbine: gasTurbine,
                                          heatExchanger: heatExchanger) // limit HX capacity?
              var heatFlowDiff = heatFlow.production - heatFlow.demand // [MW]
              // power to charge TES rest after operation POB at full load commented
              //  heatdiff = max(heatFlow.production, heatFlow.demand) // maximal power to TES desing POB thermal input (just to check how it works)
              let heat = SteamTurbine.parameter.power.max
                / SteamTurbine.parameter.efficiencyNominal
                / HeatExchanger.parameter.efficiency
              if heatFlowDiff > heat {
                heatFlowDiff = heat // commented in case of degradated powerblock
                // if heatdiff > SteamTurbine.parameter.power.max / SteamTurbine.parameter.efficiencyNominalOriginal / HeatExchanger.parameter.efficiency {
                // heatdiff = SteamTurbine.parameter.power.max / SteamTurbine.parameter.efficiencyNominalOriginal / HeatExchanger.parameter.efficiency
                // in case of degradated powerblock
                powerBlock.massFlow = MassFlow((heatFlow.production - heatFlowDiff)
                  / (htf.heatDelta(
                    HeatExchanger.parameter.temperature.htf.inlet.max,
                    HeatExchanger.parameter.temperature.htf.outlet.max) / 1_000))
              }
            }
          }
        }
      }
    }
    if heatFlowDiff > 0 {
      
      // Energy surplus
      if storage.heatrel < parameter.chargeTo,
        solarField.header.massFlow >= powerBlock.massFlow {
        
        Storage.operate(&storage, mode: .charging, boiler: boiler,
                        gasTurbine: gasTurbine, heatExchanger: heatExchanger,
                        powerBlock: &powerBlock, steamTurbine: &steamTurbine,
                        solarField: &solarField, heatFlow: &heatFlow)
        //Storage.operate(mode: .charging, parameter.heatExchanger * heatdiff, powerBlock.massFlow, hourFraction, heatFlow.storage, electricalParasitics.storage, storage.mass.hot, storage.temperatureTank.cold, storage.mass.cold, XZ)
        powerBlock.temperature.inlet = solarField.header.temperature.outlet
        // FIXME powerBlock.massFlow = powerBlock.massFlow
      } else { // heat cannot be stored
        Storage.operate(&storage, mode: .noOperation, boiler: boiler,
                        gasTurbine: gasTurbine, heatExchanger: heatExchanger,
                        powerBlock: &powerBlock, steamTurbine: &steamTurbine,
                        solarField: &solarField, heatFlow: &heatFlow)
        //Storage.operate(mode: .noOperation, heatdiff, powerBlock.massFlow, heatFlow.storage, electricalParasitics.storage, storage.mass.hot, storage.temperatureTank.cold, storage.mass.cold, XZ)
        powerBlock.temperature.inlet = solarField.header.temperature.outlet
      }
      
    } else { // Energy deficit
      var peakTariff: Bool
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
      if case .freezeProtection = storage.operationMode {
        noFreezeProtection = false
      }
      if peakTariff, noFreezeProtection,
        storage.heatrel > parameter.dischargeToTurbine,
        heatFlowDiff < -1 * parameter.heatdiff * heatFlow.demand { // added dicharge only after peak hours
        // previous discharge condition commented:
        // if storage.heatrel > parameter.dischargeToTurbine && storage.operationMode != .freezeProtection && heatdiff < -1 * parameter.heatdiff * heatFlow.demand { // Discharge directly!! // 04.07.0 -0.25&& heatdiff < -0.25 * heatFlow.dem
        if powerBlock.massFlow < solarField.header.massFlow { // there are cases, during cloudy days when OpMode is "EX" although massflow in SOF is higher that in PB.
        }
        Storage.operate(&storage, mode: .ex, boiler: boiler,
                        gasTurbine: gasTurbine, heatExchanger: heatExchanger,
                        powerBlock: &powerBlock, steamTurbine: &steamTurbine,
                        solarField: &solarField, heatFlow: &heatFlow)
        //Storage.operate(mode: .ex, heatdiff, powerBlock.massFlow, heatFlow.storage, heatLossStorage, electricalParasitics.storage, storage.mass.hot, storage.temperatureTank.cold, storage.mass.cold, XZ)
        if case .freezeProtection = solarField.operationMode {
          powerBlock.temperature.inlet = htf.mixingTemperature(
            outlet: solarField, with: storage)
          powerBlock.massFlow = storage.massFlow + solarField.header.massFlow //
          powerBlock.massFlow.adjust(with: parameter.heatExchangerEfficiency)
        } else if case .operating = solarField.operationMode { // eingefügt  IF-abrage eingefügt
          powerBlock.temperature.inlet = htf.mixingTemperature(
            outlet: solarField, with: storage)
          powerBlock.massFlow = storage.massFlow + solarField.header.massFlow
          powerBlock.massFlow.adjust(with: parameter.heatExchangerEfficiency)
        } else if !storage.massFlow.isNearZero {
          powerBlock.temperature.inlet = storage.temperature.outlet
          powerBlock.massFlow = storage.massFlow
          powerBlock.massFlow.adjust(with: parameter.heatExchangerEfficiency)
        } else {
          powerBlock.massFlow = MassFlow()
        }
        
      } else { // heat can only be provided with heater on

        if (parameter.FC == 0 && Collector.status.parabolicElevation < 0.011
          && storage.heatrel < parameter.chargeTo
          && !(powerBlock.temperature.inlet.kelvin > 665)
          && steamTurbine.isMaintained
          && isFossilChargingAllowed(at: PerformanceCalculator.calendar)
          && Fuelmode != "predefined") || (Fuelmode == "predefined" && availableFuel > 0) {
          heater.operationMode = .freezeProtection
          if Fuelmode != "predefined" {
            let availableFuel = Double.greatestFiniteMagnitude
            Heater.operate(&heater, powerBlock: &powerBlock,
                           steamTurbine: steamTurbine, storage: storage,
                           solarField: solarField,
                           demand: 0,
                           availableFuel: availableFuel,
                           heatFlow: &heatFlow,
                           fuelFlow: &fuel.heater)
            Plant.electricalParasitics.heater = Heater.parasitics(at: heater.load)
            powerBlock.massFlow = heater.massFlow
            Storage.operate(&storage, mode: .freezeProtection, boiler: boiler,
                            gasTurbine: gasTurbine, heatExchanger: heatExchanger,
                            powerBlock: &powerBlock, steamTurbine: &steamTurbine,
                            solarField: &solarField, heatFlow: &heatFlow)
            // FIXME powerBlock.massFlow = powerBlock.massFlow
            powerBlock.temperature.inlet = storage.temperature.outlet
            // check why to circulate HTF in SF
            Plant.electricalParasitics.solarField = SolarField.parameter.antiFreezeParastics
          } else if case .freezeProtection = solarField.operationMode,
            storage.heatrel > -0.35 && parameter.FP == 0 {
            
            Storage.operate(&storage, mode: .freezeProtection, boiler: boiler,
                            gasTurbine: gasTurbine, heatExchanger: heatExchanger,
                            powerBlock: &powerBlock, steamTurbine: &steamTurbine,
                            solarField: &solarField, heatFlow: &heatFlow)
            //Storage.operate(mode: .freezeProtection, date: heatdiff, heatFlow: powerBlock.massFlow, status: heatFlow.storage)
          } else {
            Storage.operate(&storage, mode: .noOperation, boiler: boiler,
                            gasTurbine: gasTurbine, heatExchanger: heatExchanger,
                            powerBlock: &powerBlock, steamTurbine: &steamTurbine,
                            solarField: &solarField, heatFlow: &heatFlow)
            //Storage.operate(mode: .noOperation, date: heatdiff, heatFlow: powerBlock.massFlow, status: heatFlow.storage)
          }
        }
      }
      
      heatFlow.storage = storage.massFlow.rate
        * htf.heatDelta(storage.temperature.outlet,
                        storage.temperature.inlet) / 1_000
      
      // Check if the required heat is contained in TES, if not recalculate heatFlow.storage
      
      switch storage.operationMode {
        
      case .ex:
        storage.hSalt.hot = salt.heatCapacity[0]
          * (storage.temperatureTank.hot.celsius)
          + 0.5 * salt.heatCapacity[1]
          * (storage.temperatureTank.hot.celsius) ** 2 - 350.5536
        storage.hSalt.cold = salt.heatCapacity[0] * ((storage.temperature.inlet
          + storage.dTHTF_ColdSalt).celsius)
          + 0.5 * salt.heatCapacity[1] * (storage.temperature.inlet.kelvin
            + storage.dTHTF_ColdSalt.celsius) ** 2 - 350.5536
        storage.massSalt = heatFlow.storage / (storage.hSalt.hot
          - storage.hSalt.cold) * hourFraction * 3_600 * 1_000
        if (storage.mass.hot - storage.massSalt) < storage.minMass {
          // added to avoid negative or too low salt mass
          storage.massSalt = storage.massSalt
            - (-storage.minMass + storage.mass.hot)
        }
        if storage.massSalt < 10 { storage.massSalt = 0
          // recalculate thermal power given by TES:
          heatFlow.storage = storage.massSalt
            * (storage.hSalt.hot - storage.hSalt.cold)
            / hourFraction / 3_600 / 1_000
        }
        
      case .charging:
        storage.hSalt.hot = salt.heatCapacity[0]
          * (storage.temperature.inlet.kelvin
            - storage.dTHTF_HotSalt.celsius) + 0.5 // FIXME
          * salt.heatCapacity[1] * (storage.temperature.inlet.kelvin
            - storage.dTHTF_HotSalt.celsius) ** 2 - 350.5536 //
        storage.hSalt.cold = salt.heatCapacity[0]
          * (storage.temperatureTank.cold.celsius)
          + 0.5 * salt.heatCapacity[1]
          * (storage.temperatureTank.cold.celsius) ** 2 - 350.5536
        storage.massSalt = -heatFlow.storage
          / (storage.hSalt.hot - storage.hSalt.cold)
          * hourFraction * 3_600 * 1_000
        
        if (storage.mass.cold - storage.massSalt) < storage.minMass {
          storage.massSalt = storage.massSalt
            - (-storage.minMass + storage.mass.cold)
          if storage.massSalt < 10 { storage.massSalt = 0
            // recalculate thermal power given by TES:
            heatFlow.storage = -storage.massSalt
              * (storage.hSalt.hot - storage.hSalt.cold)
              / hourFraction / 3_600 / 1_000
          }
        }
      default: break
      }
      
      if heatFlowDiff > 0 { // Energy surplus
        if storage.heatrel < parameter.chargeTo,
          solarField.header.massFlow >= powerBlock.massFlow { // 1.1
          heatFlow.production = heatFlow.solar + heatFlow.storage
        } else { // heat cannot be stored
          heatFlow.production = heatFlow.solar - heatFlowDiff
          // surplus is dumped (?) and not sent to PB
        }
      } else {
        heatFlow.production = heatFlow.solar + heatFlow.storage
      }
    }
  }
  
  static func isFossilChargingAllowed(at time : CalendarDay) -> Bool {
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
