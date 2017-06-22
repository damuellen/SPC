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

extension Storage.Instance: CustomDebugStringConvertible {
  var debugDescription: String { return "\(workingConditions.current)" }
}

public struct Storage: Model {
  
  final class Instance {
    // A singleton class holding the state of the storage
    static let shared = Instance()
    var parameter: Storage.Parameter!
    var workingConditions: (previous: PerformanceData?, current: PerformanceData)
    
    private init() {
      workingConditions = (nil, initialState)
    }
  }
  
  /// a struct for operation-relevant data of the storage
  public struct PerformanceData: MassFlow {
    var operationMode: OperationMode
    var heatFlow: Double
    var temperature: (inlet: Double, outlet: Double)
    var temperatureTank: (cold: Double, hot: Double)
    var massFlow, heatrel: Double
    var mass: (cold: Double, hot: Double)
    var dTHTF_HotSalt, dTHTF_ColdSalt: Double
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
    operationMode: .noOperation, heatFlow: 0.0,
    temperature: (0,0), temperatureTank: (0,0),
    massFlow: 0, heatrel: 0,
    mass: (0,0),
    dTHTF_HotSalt: 0, dTHTF_ColdSalt: 0,
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
  
  public static var minmass: Double {
    switch parameter.definedBy {
    case .hours:
      let minmass = Design.layout.storage * parameter.dischargeToTurbine
        * HeatExchanger.parameter.SCCHTFheat * 1_000 * 3_600
        / (status.hSalt.hot - status.hSalt.cold)
      HeatExchanger.parameter.temperature.h2o.inlet.max = parameter.startLoad.hot
        * Design.layout.storage * HeatExchanger.parameter.SCCHTFheat * 1_000 * 3_600
        / (status.hSalt.hot - status.hSalt.cold) + minmass // Factor 1.1
      HeatExchanger.parameter.temperature.h2o.inlet.min = parameter.startLoad.cold
        * Design.layout.storage * HeatExchanger.parameter.SCCHTFheat * 1_000 * 3_600
        / (status.hSalt.hot - status.hSalt.cold) + minmass
      return minmass
    case .cap:
      let minmass = Design.layout.storage_cap
        * parameter.dischargeToTurbine * 1_000 * 3_600
        / (status.hSalt.hot - status.hSalt.cold)
      HeatExchanger.parameter.temperature.h2o.inlet.max = parameter.startLoad.hot
        * Design.layout.storage_cap * 1_000 * 3_600
        / (status.hSalt.hot - status.hSalt.cold) + minmass // Factor 1.1
      HeatExchanger.parameter.temperature.h2o.inlet.min = parameter.startLoad.cold
        * Design.layout.storage_cap * 1_000 * 3_600
        / (status.hSalt.hot - status.hSalt.cold) + minmass
      return minmass
    case .ton:
      let minmass = Design.layout.storage_ton * parameter.dischargeToTurbine * 1_000 // OK
      HeatExchanger.parameter.temperature.h2o.inlet.max = parameter.startLoad.hot
        * Design.layout.storage_ton * 1_000 + minmass
      HeatExchanger.parameter.temperature.h2o.inlet.min = parameter.startLoad.cold
        * Design.layout.storage_ton * 1_000 + minmass
      return minmass
    }
  }
  
  /// Calculates the parasitics of the gas turbine which only depends on the current load
  private static func parasitics(at status: inout PerformanceData, date: Date, hourFraction: Double) -> Double {
    
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
    
    if parameter.auxConsCurve {
      // old model:
      let rohmean = htf.density((status.temperature.inlet + status.temperature.outlet) / 2)
      let rohDP = htf.density((HeatExchanger.parameter.temperature.htf.inlet.max
        + HeatExchanger.parameter.temperature.htf.outlet.max) / 2)
      let PrL = parameter.pressureLoss * rohDP / rohmean
        * (status.massFlow / parameter.massFlow) ** 2
      parasitics = PrL * status.massFlow / rohmean / parameter.pumpEfficiency / 10E6
      if parasitics > 5 {
        var i = 0
      }
      
      if case .ex = status.operationMode {
        //   parasitics = 2 * parasitics * 2.463 // 3 Änderung Indien // * 2.463 for Andasol-3
        parasitics = parasitics * parameter.DischrgParFac // added as user input, by no input stoc.DischrgParFac = 2
        timeminutessum = 0
      } else if case .no = status.operationMode {
        if date.minutes != timeminutesold { // formula changed
          if date.minutes == 0 { // new hour
            timeminutessum += 60 + date.minutes - timeminutesold // timeminutessum + 5
          } else {
            timeminutessum += date.minutes - timeminutesold
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
      timeminutesold = date.minutes
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
      status.hSalt.hot = salt.heatCapacity[0] * (parameter.designTemperature.hot.toCelsius) + 0.5
        * salt.heatCapacity[1] * (parameter.designTemperature.hot.toCelsius) ** 2 - 350.5536
      status.hSalt.cold = salt.heatCapacity[0] * (parameter.designTemperature.cold.toCelsius) + 0.5
        * salt.heatCapacity[1] * (parameter.designTemperature.cold.toCelsius) ** 2 - 350.5536
      // charge:
      let designChargingHeatFlow = (parameter.massFlow * htf.heatTransfered(
        parameter.designTemperature.hot + status.dTHTF_HotSalt,
        parameter.designTemperature.cold + status.dTHTF_ColdSalt) / 1_000)
        * parameter.heatExchangerEfficiency
      
      var DesINmassSalt = designChargingHeatFlow
        / (status.hSalt.hot - status.hSalt.cold) * 1_000 // kg/s
      DesINmassSalt *= hourFraction * 3_600 // kg in time step (5 minutes)
      // discharge:
      let QoutLoad = parameter.fixedLoadDischarge == 0 ? 0.97 : parameter.fixedLoadDischarge
      
      let heatexDes = ((QoutLoad * (SolarField.parameter.massFlow.max - parameter.massFlow)
        / parameter.heatExchangerEfficiency) * htf.heatTransfered(
          parameter.designTemperature.hot - status.dTHTF_HotSalt,
          parameter.designTemperature.cold - status.dTHTF_ColdSalt) / 1_000)
        * parameter.heatExchangerEfficiency // design charging power
      
      
      var DesEXmassSalt = heatexDes / (status.hSalt.hot - status.hSalt.cold) * 1_000 // kg/s
      DesEXmassSalt *= hourFraction * 3_600 // kg in time step (5 minutes)
      // all this shall be done only one time_____________________________________________________
      
      if case .ex = status.operationMode {
        status.massSaltRatio = (status.massSalt / DesEXmassSalt)
        // if status.massSaltRatio > 1, case .charging = previous?.operationMode {
        // status.massSaltRatio = 1
        // has to be check in detail how to determine salt mass flow if it's the first discharge after charging!!
        // }
        parasitics = ((1 - lowDc) * DesAuxEX
          * status.massSaltRatio ** Expn + lowDc * DesAuxEX)
          * (1 - level * status.heatrel)
          * ((1 - level2) + level2 * status.massSaltRatio)
        timeminutessum = 0
        
      } else if case .charging = status.operationMode {
        status.massSaltRatio = (status.massSalt / DesINmassSalt)
        // has to be check in detail how to determine salt mass flow if it's the first charge after discharging!!
        if let previousMode = Storage.previous?.operationMode, case .ex = previousMode {
          status.massSaltRatio = 1
        }
        parasitics = ((1 - lowCh) * DesAuxIN
          * status.massSaltRatio ** Expn + lowCh * DesAuxIN)
          * ((1 - level) + level * status.heatrel)
          * ((1 - level2) + level2 * status.massSaltRatio)
        timeminutessum = 0
        // FIXME status.OldOpMode = .in
      } else if case .noOperation = status.operationMode {
        parasitics = 0
        let timeminutessum = 0.0
        if date.minutes != timeminutesold {
          if date.minutes == 0 { // new hour
            // FIXME timeminutessum = timeminutessum + 60 + date.minutes - timeminutesold // timeminutessum + 5
          } else {
            // FIXME  timeminutessum = timeminutessum + date.minutes - timeminutesold
          }
        }
        // new heat tracing defined by user:
        for (time, pow) in zip(parameter.heatTracingTime, parameter.heatTracingPower) {
          if timeminutessum > time * 60 {
            parasitics += pow / 1_000
          }
        }
      }
      timeminutesold = date.minutes
    }
    
    return parasitics
  }
  
  func prepare() {
    if Design.hasStorage {
      // initial state of storage
      
      Storage.status.heatStored = Design.layout.storage * Storage.parameter.heatStoredrel // check if needed!
      
      SolarField.parameter.massFlow.max = 100 / Storage.parameter.massFlow
        * SolarField.parameter.massFlow.max // 1.05 commented
      Storage.parameter.massFlow = (1 - Storage.parameter.massFlow / 100)
        * SolarField.parameter.massFlow.max // Change in Formula FR
    }
    
    SolarField.parameter.massFlow.min = SolarField.parameter.massFlow.min
      / 100 * SolarField.parameter.massFlow.max
    SolarField.parameter.antiFreezeFlow = SolarField.parameter.antiFreezeFlow
      / 100 * SolarField.parameter.massFlow.max
    
    if SolarField.parameter.pumpParastics.isEmpty {
      if SolarField.parameter.massFlow.max < 900 {
        // calculation of solar field parasitics with empirical correlation derived from solar field model
        SolarField.parameter.pumpParasticsFullLoad = (
          0.000000047327 * Design.layout.solarField ** 4
          - 0.000020044 * Design.layout.solarField ** 3
          + 0.0032862 * Design.layout.solarField ** 2
          - 0.24086 * Design.layout.solarField + 8.2152)
          * (0.7103 * (SolarField.parameter.massFlow.max / 597) ** 3
            - 0.8236 * (SolarField.parameter.massFlow.max / 597) ** 2
            + 1.464 * (SolarField.parameter.massFlow.max / 597) - 0.3508)
      } else {
        SolarField.parameter.pumpParasticsFullLoad = (
          0.0000055 * SolarField.parameter.massFlow.max ** 2
          - 0.0074 * SolarField.parameter.massFlow.max + 4.4)
          * (-0.000001656 * Design.layout.solarField ** 3 + 0.0007981
            * Design.layout.solarField ** 2 - 0.1322 * Design.layout.solarField + 8.428)
      }
      SolarField.parameter.HTFmass = (93300 + 11328 * Design.layout.solarField)
        * (0.63 * (SolarField.parameter.massFlow.max / 597) + 0.38)
    }
    // check if it should be left so or changed to the real achieved temp. ( < 393 °C)
    // HeatExchanger.parameter.temperature.htf.inlet.max = HeatExchanger.parameter.HTFinTmax
    // HeatExchanger.parameter.temperature.htf.inlet.min = HeatExchanger.parameter.HTFinTmin
    // HeatExchanger.parameter.temperature.htf.outlet.max = HeatExchanger.parameter.HTFoutTmax
    // HeatExchanger.status.HTFoutTmin = HeatExchanger.parameter.HTFoutTmin never used
    
    if Storage.parameter.TturbIterate == -99.99 {
      Storage.status.hSalt.hot = salt.heatCapacity[0]
        * (Storage.parameter.designTemperature.hot)
        + 0.5 * salt.heatCapacity[1]
        * (Storage.parameter.designTemperature.hot) ** 2 - 350.5536
      Storage.status.hSalt.cold = salt.heatCapacity[0]
        * (Storage.parameter.designTemperature.cold)
        + 0.5 * salt.heatCapacity[1]
        * (Storage.parameter.designTemperature.cold) ** 2 - 350.5536
      
      HeatExchanger.parameter.temperature.h2o.inlet.max = Storage.parameter.startTemperature.hot.toKelvin
      HeatExchanger.parameter.temperature.h2o.inlet.min = Storage.parameter.startTemperature.cold.toKelvin
      
      if Storage.parameter.tempInCst[1] == 0 {
        Storage.status.dTHTF_HotSalt = Storage.parameter.tempExC0to1[0] // added
        Storage.status.dTHTF_ColdSalt = -Storage.parameter.tempInCst[0] // added
        Storage.parameter.tempExC0to1[0] = Storage.parameter.designTemperature.hot
          - Storage.parameter.tempExC0to1[0] // meaning is HTFTout(EX) = HotTankDes - dT
        Storage.parameter.tempExCst[0] = Storage.parameter.tempExC0to1[0]
        Storage.parameter.tempInCst[0] = Storage.parameter.designTemperature.cold
          - Storage.parameter.tempInCst[0] // meaning is HTFTout(IN) = ColdTankDes + dT
        Storage.parameter.tempInCst[0] = Storage.parameter.tempInCst[0]
      }
    }
  }
  
  // This Subroutine simulates the TES, thermal storage
  // status.heatFlow  - if to storage, + if drawn from storage!!!
  // This subroutine does not change the filling of the storage
  // LISTING OF INPUT parameter.S:::::::::::::::::::::::::::::::::::::::::::::::::
  // hourFraction =  fraction of hour for this hourFraction
  // status.OPmode = "FP" freeze protection,  ********passed as shared*************
  //             -not analyzed- to store heat
  //             "PH" if heater could be switched on if necessary (PreHeat)
  //             "EX" discharge solar only, heater cannot be switched on
  // PowerBlock.status.massFlow =  is PowerBlock.status.massFlow, the mass flow of 390øC which is used for
  //             charging and is reduced while charging
  //             or to calculate the max discharge massFlow for correct T at Turb
  // LISTING OF OUTPUT parameter.S::::::::::::::::::::::::::::::::::::::::::::::::
  // status.heatFlow =   heat from storage (discharging positive, charging negative)
  // heatLossStorage =       Loss of Heat during this hourFraction
  // parasitics =  parasitic electric heat (pump)
  // status.OPmode = "FP" freeze protection,
  //             "IN" while charging storage
  //             "PH" discharging, preheater has to be switched on
  //             "EX" discharging, heater not needed
  // status.massFlow  mass flow through in storage, add this to other massFlow   *shared*
  // status.temperature.outlet  discharging temperatur of storage                     *shared*
  // PowerBlock.status.massFlow = is !!!!!!!!!!!REDUCED!!!!!!!!!!!! while charging
  public static func operate(mode _: PerformanceData.OperationMode,
                             date: Date, heatFlow: inout HeatFlow) {
    var storage = status
    defer { status = storage }
    var SSetTime = 0
    var i = 0.0
    var StoFit = 0.0
    var Lmax = 0.0
    var MixTemp = 0.0
    var MinTBTemp = 0.0
    var Rohmean = 0.0
    var RohDP = 0.0
    var PrL = 0.0
    
    var QoutLoad = 0.0
    var jT = 0.0
    var kT = 0.0
    
    /*
     //calculate sunrise time for status day
     if date.hour = 16 && date.minutes = 0 && parameter.isVariable {
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
      SolarField.status.massFlow = SolarField.status.massFlow
    } else if case .freezeProtection = SolarField.status.operationMode {
      SolarField.status.massFlow = SolarField.status.massFlow
    } else {
      SolarField.status.massFlow = 0
    }
    
    switch status.operationMode { // = status.OPmode
      
    case .charging: // heat can be stored
      
      // status.operationMode = "IN"
      status.temperature.inlet = SolarField.status.temperature.outlet
      // the PowerBlock.status.massFlow is only an ideal value, for maximal dT, isnt it wrong?
      status.massFlow = SolarField.status.massFlow - PowerBlock.status.massFlow
      status.massFlow *= parameter.heatExchangerEfficiency
      // * Plant.availability[date.month].storage taken out of the formula and included in TES capacity calculation
      
      if parameter.tempInCst[1] > 0 { // usually = 0
        if status.heatrel < 0.5 {
          StoFit = 1
        } else {
          for i in 0 ..< 3 {
            StoFit += parameter.tempInCst[i] * status.heatrel ** Double(i)
          }
        }
        StoFit *= parameter.designTemperature.cold.toKelvin - parameter.tempInCst[2]
      } else {
        StoFit = StoFit.toKelvin
        if status.heatrel < 0 {
          StoFit += parameter.tempInCst[0]
            - (parameter.designTemperature.cold - status.temperatureTank.cold)
        } else {
          // adjust of HTF outlet temp. with status cold tank temp.
          StoFit += parameter.tempInCst[0]
            - (parameter.designTemperature.cold - status.temperatureTank.cold)
        }
      }
      status.temperature.outlet = StoFit
      status.heatFlow = status.massFlow
        * htf.heatTransfered(status.temperature.outlet,
                             status.temperature.inlet) / 1_000
      
      // status.heatFlow hat hier die Einheit MW
      // limit the size of the salt-oil heat exchanger
      if parameter.heatExchangerRestrictedMax,
        abs(status.heatFlow) > parameter.heatExchangerCapacity {
        status.heatFlow *= parameter.heatExchangerCapacity
        status.massFlow = status.heatFlow / htf.heatTransfered(
          status.temperature.outlet, status.temperature.inlet) * 1_000
        // FIXME    PowerBlock.status.massFlow = PowerBlock.status.massFlow // added to avoid increase in PB massFlow
        if case .demand = parameter.strategy { // (always)
          // too much power from sun, dump
          heatFlow.dump += heatFlow.production
            - HeatExchanger.parameter.SCCHTFheat + status.heatFlow
        } else {
          heatFlow.dump = heatFlow.dump + heatFlow.production
            - heatFlow.demand + status.heatFlow
        }
        SolarField.status.massFlow = PowerBlock.status.massFlow + status.massFlow
        // reduce HTF massflow in SF
        heatFlow.solar = SolarField.status.massFlow * htf.heatTransfered(
          SolarField.status.temperature.outlet, SolarField.status.temperature.inlet) / 1_000
        heatFlow.production = heatFlow.solar
      }
      
      // go Storageparasitics
      
    case .freezeProtection: // heat can be stored
      
      status.temperature.inlet = Heater.parameter.nomTemperatureOut
      status.massFlow = PowerBlock.status.massFlow
      
      if parameter.tempInCst[1] > 0 {
        if status.heatrel < 0.5 {
          StoFit = 1
        } else {
          for i in 0 ..< 3 {
            StoFit += parameter.tempInCst[i] * status.heatrel ** Double(i)
          }
        }
        StoFit *= parameter.designTemperature.cold.toKelvin - parameter.tempInCst[2]
      } else {
        StoFit = StoFit.toKelvin
        if status.heatrel < 0 {
          StoFit += parameter.tempInCst[0]
            - (parameter.designTemperature.cold - status.temperatureTank.cold)
        } else {
          StoFit += parameter.tempInCst[0]
            - (parameter.designTemperature.cold - status.temperatureTank.cold)
        }
      }
      status.temperature.outlet = StoFit
      status.heatFlow = status.massFlow * htf.heatTransfered(
        status.temperature.outlet, status.temperature.inlet) / 1_000 // [MW]
      // limit the size of the salt-oil heat exchanger
      if parameter.heatExchangerRestrictedMax,
        abs(status.heatFlow) > parameter.heatExchangerCapacity {
        status.heatFlow *= parameter.heatExchangerCapacity
        status.massFlow = status.heatFlow / htf.heatTransfered(
          status.temperature.outlet, status.temperature.inlet) * 1_000
        PowerBlock.status.massFlow = status.massFlow
      }
      
      // go Storageparasitics
      
    case .ex: // heat can be released
      // calculate discharge rate only once per day, directly after sunset
      if date.hour >= SSetTime && date.hour < (SSetTime + 1) && parameter.isVariable {
        switch parameter.definedBy {
        case .hours:
          status.heatStored = status.heatrel * Design.layout.storage
            * SteamTurbine.parameter.power.max / SteamTurbine.parameter.efficiencyNominal
        case .cap:
          status.heatStored = status.heatrel * Design.layout.storage_cap
        case .ton:
          status.hSalt.hot = salt.heatCapacity[0]
            * (parameter.designTemperature.hot.toCelsius) + 0.5
            * salt.heatCapacity[1] * (parameter.designTemperature.hot.toCelsius) ** 2 - 350.5536
          status.hSalt.cold = salt.heatCapacity[0]
            * (parameter.designTemperature.cold.toCelsius) + 0.5
            * salt.heatCapacity[1]
            * (parameter.designTemperature.cold.toCelsius) ** 2 - 350.5536
          status.heatStored = status.heatrel * Design.layout.storage_ton
            * (status.hSalt.hot - status.hSalt.cold)
            * (parameter.designTemperature.hot - parameter.designTemperature.cold) / 3_600
        }
        
        if nightHour == 0 { // added to avoid division by zero if calculation doesn//t begin at Jan 1st
          nightHour = 12 // assumed night duration of the first day
        }
        
        // QoutLoad controls the load of the TES during discharge. Before was fixed to 0.97
        QoutLoad = status.heatStored / nightHour
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
          status.heatStored = status.heatrel * Design.layout.storage
            * SteamTurbine.parameter.power.max
            / SteamTurbine.parameter.efficiencyNominal
        case .cap:
          status.heatStored = status.heatrel * Design.layout.storage_cap
        case .ton:
          status.hSalt.hot = salt.heatCapacity[0]
            * (parameter.designTemperature.hot.toCelsius) + 0.5
            * salt.heatCapacity[1]
            * (parameter.designTemperature.hot.toCelsius) ** 2 - 350.5536
          status.hSalt.cold = salt.heatCapacity[0]
            * (parameter.designTemperature.cold.toCelsius) + 0.5
            * salt.heatCapacity[1]
            * (parameter.designTemperature.cold.toCelsius) ** 2 - 350.5536
          status.heatStored = status.heatrel * Design.layout.storage_ton
            * (status.hSalt.hot - status.hSalt.cold)
            * (parameter.designTemperature.hot - parameter.designTemperature.cold)
            / 3_600
        }
        
        if nightHour == 0 { // added to avoid division by zero if calculation doesn't begin at Jan 1st
          nightHour = 12 // assumed night duration of the first day
        }
        // QoutLoad controls the load of the TES during discharge.
        QoutLoad = status.heatStored / nightHour / (SteamTurbine.parameter.power.max
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
      
      switch SolarField.status.operationMode {
      case .freezeProtection:
        // reduction of HTF Mass flow during strorage discharging due to results of AndaSol-1 Heat Balance
        status.massFlow = QoutLoad * PowerBlock.status.massFlow
          / parameter.heatExchangerEfficiency
        // - SolarField.status.massFlow
        
      case .operating where SolarField.status.massFlow > 0:
        // Mass flow is correctd by parameter.Hx this factor is new
        status.massFlow = PowerBlock.status.massFlow
          / parameter.heatExchangerEfficiency - SolarField.status.massFlow
      // * 0.97 deleted after separating combined from storage only operation
      default:
        //if demand < 1 { // only for OU1!?
        //  status.massFlow = PowerBlock.status.massFlow * 1.3
        //    / parameter.heatExchangerEfficiency
          // for OU1 adjust to demand file and not TES design parameter.s. CHECK! 1.3 to get right results
       // } else {
          // added to control TES discharge during night
          status.massFlow = QoutLoad * PowerBlock.status.massFlow
            / parameter.heatExchangerEfficiency
       // }
      }
      
      status.temperature.inlet = PowerBlock.status.temperature.outlet // used for parasitics
      
      // go StorageOutletTemp   // STOoutTemp remains constant, whatever MassFlow
      
      while true {
        defer { status.massFlow *= 0.97 } // reduce 5%
        status.heatFlow = status.massFlow
          * htf.heatTransfered(status.temperature.outlet,
                               status.temperature.inlet) / 1_000
        
        if parameter.heatExchangerRestrictedMax,
          abs(status.heatFlow) > parameter.heatExchangerCapacity {
          status.heatFlow = status.heatFlow * parameter.heatExchangerCapacity
          status.massFlow = status.heatFlow /
            htf.temperature(status.temperature.outlet,
                            status.temperature.inlet) * 1_000
          if case .freezeProtection = SolarField.status.operationMode {
            // reduction of HTF Mass flow during storage discharging due to results of AndaSol-1 Heat Balance
            PowerBlock.status.massFlow = status.massFlow
              * parameter.heatExchangerEfficiency / 0.97 // - SolarField.status.massFlow
            
          } else {
            // Mass flow is correctd by new factor
            PowerBlock.status.massFlow = (status.massFlow + SolarField.status.massFlow)
              * parameter.heatExchangerEfficiency / 0.97
          }
        }
        
        SteamTurbine.status.load = Ratio((heatFlow.solar + status.heatFlow)
          / (SteamTurbine.parameter.power.max
            / SteamTurbine.efficiencyFor(load: Ratio(1), Lmax: Ratio(Lmax))))
        MixTemp = htf.mixing(outlet: SolarField.status, with: status)
        MinTBTemp = 310.toKelvin // TurbineTempLoad(SteamTurbine.status.load)
        
        if MixTemp > MinTBTemp - Simulation.parameter.tempTolerance * 2 {
          status.heatFlow = status.massFlow
            * htf.heatTransfered(status.temperature.outlet,
                                 status.temperature.inlet) / 1_000
          // go Storageparasitics
          break
        } else if status.massFlow <= 0.05 * PowerBlock.status.massFlow {
          status.heatFlow = 0
          status.operationMode = .noOperation
          // parasitics = 0
          status.massFlow = 0
          break
        }
      }
      //   }
      
    case .ph: // the rest is heated by SF to 391øC
      // FIXME status.operationMode = "PH"
      status.massFlow = PowerBlock.status.massFlow - SolarField.status.massFlow
      status.temperature.inlet = PowerBlock.status.temperature.outlet
      // go StorageOutletTemp
      status.heatFlow = status.massFlow
        * htf.heatTransfered(status.temperature.outlet,
                             status.temperature.inlet) / 1_000
      // limit the size of the salt-oil heat exchanger
      if parameter.heatExchangerRestrictedMax,
        abs(status.heatFlow) > parameter.heatExchangerCapacity {
        status.heatFlow = status.heatFlow * parameter.heatExchangerCapacity
        status.massFlow = status.heatFlow /
          htf.heatTransfered(status.temperature.outlet,
                             status.temperature.inlet) * 1_000
        // go StorageOutletTemp
        status.heatFlow = status.massFlow *
          htf.heatTransfered(status.temperature.outlet,
                             status.temperature.inlet) / 1_000
      }
      
    // go Storageparasitics
    case .freezeProtection:
      
      let splitfactor = 0.4
      status.massFlow = splitfactor * SolarField.parameter.antiFreezeFlow
      SolarField.status.massFlow = SolarField.parameter.antiFreezeFlow
      status.temperature.inlet = PowerBlock.status.temperature.outlet // used for parasitics
      if parameter.tempInCst[1] > 0 {
        if parameter.tempExCst.indices.contains(2) {
          status.temperature.outlet = status.temperature.inlet
        } else {
          if status.heatrel > 0.5 {
            //for i in 0 ..< 3 {
            StoFit = 1
            //}
          } else {
            for i in 0 ..< 3 {
              StoFit += parameter.tempExC0to1[i] * status.heatrel ** Double(i)
            }
          }
          status.temperature.outlet = StoFit * parameter.designTemperature.hot.toKelvin
        }
        status.temperature.outlet = splitfactor * status.temperature.outlet
          + (1 - splitfactor) * status.temperature.inlet
      } else {
        // status.temperature.outlet = parameter.storage.temperatureTank.cold
      }
      // go Storageparasitics
      
    case .no:
      status.operationMode = .noOperation // Temperatures remain constant
      // go Storageparasitics
      status.heatFlow = 0
      status.massFlow = 0 // parasitics = 0:
    default: break
    }
    
    // Storage Heat Losses: Check calculation!!!
    if parameter.tempInCst[1] > 0 { // it doesn//t get in here usually.
      if parameter.tempInCst[2] > 0 {
        StoFit = 0
        if status.heatrel < 0 {
          for i in 0 ..< 3 {
            // FIXME StoFit += parameter.heatLossConstants[i] * status.heatrel ** Double(i)
          }
        } else {
          for i in 0 ..< 3 {
            // FIXME StoFit += parameter.heatLossConstants[i] * status.heatrel ** Double(i)
          }
        }
        
        status.heatLossStorage = StoFit * 3_600 * 0.0000001 * Design.layout.storage // [MW] !!!!
      } else {
        // FIXME  heatLossStorage = parameter.heatLossConstants[0] / 1_000 * (status.heatrel
        // * (parameter.designTemperature.hot - parameter.designTemperature.cold)
        // + parameter.designTemperature.cold)
        // / parameter.designTemperature.hot
      }
    } else {
      status.heatLossStorage = 0
    }
    
    // Exit Sub
    
    StorageOutletTemp:
      if parameter.tempInCst[1] > 0 {
      if status.heatrel > 0.5 {
        for i in 0 ..< 3 {
          StoFit = 1
        }
      } else {
        for i in 0 ..< 3 {
          StoFit += parameter.tempExC0to1[i] * status.heatrel ** Double(i)
        }
      }
      StoFit *= parameter.designTemperature.hot.toKelvin - parameter.tempExCst[1]
    } else {
      StoFit = StoFit.toKelvin
      if status.heatrel < 0 {
        StoFit += parameter.tempExCst[0]
          - (parameter.designTemperature.hot - status.temperatureTank.hot)
      } else {
        StoFit += parameter.tempExC0to1[0]
          - (parameter.designTemperature.hot - status.temperatureTank.hot)
        // adjust of HTF outlet temp. with status hot tank temp.
      }
    }
    status.temperature.outlet = StoFit // independent from massFlow !!!
  }
  
  static func prepareStorage(date: Date, hourFraction: Double) {
    if Design.hasStorage { // keep track of the filling of the storage
      
      let ColdTankQverl = parameter.heatLoss.cold
        * (status.temperatureTank.cold - 300)
        / (parameter.designTemperature.cold - 27)
      let HotTankQverl = parameter.designTemperature.cold
        * (status.temperatureTank.hot - 300)
        / (parameter.designTemperature.hot - 27)
      status.hSalt.hot = salt.heatCapacity[0]
        * (parameter.designTemperature.hot.toCelsius) + 0.5 * salt.heatCapacity[1]
        * (parameter.designTemperature.hot.toCelsius) ** 2 - 350.5536
      status.hSalt.cold = salt.heatCapacity[0]
        * (parameter.designTemperature.cold.toCelsius) + 0.5 * salt.heatCapacity[1]
        * (parameter.designTemperature.cold.toCelsius) ** 2 - 350.5536
      
      switch parameter.definedBy {
      case .hours:
        // Plant.availability[date.month].storage added here to apply TES availability on capacity and not on charge load
        status.massSalt = Design.layout.storage
          * Plant.availability[date.month].storage.value
          * (1 + parameter.dischargeToTurbine)
        status.massSalt *= HeatExchanger.parameter.SCCHTFheat * 1_000 * 3_600
          / (status.hSalt.hot - status.hSalt.cold)
      case .cap:
        status.massSalt = Design.layout.storage_cap
          * Plant.availability[date.month].storage.value
          * (1 + parameter.dischargeToTurbine)
        status.massSalt *= 1_000 * 3_600 / (status.hSalt.hot - status.hSalt.cold)
      case .ton:
        status.massSalt = Design.layout.storage_ton
          * Plant.availability[date.month].storage.value
        status.massSalt *= 1_000 * (1 + parameter.dischargeToTurbine)
      }
      
      //   Saltmass = parameter.heatLossConstants0[3]
      
      if parameter.tempInCst[1] > 0 { // it doesnt get in here usually, therefore not updated yet
        status.heatStored = status.heatStored - status.heatLossStorage
          * hourFraction - Plant.heatFlow.storage * hourFraction
        status.heatrel = status.heatStored
          / (Design.layout.storage * HeatExchanger.parameter.SCCHTFheat)
      } else {
        
        switch status.operationMode {
          
        case .charging:
          // Hot salt is status.temperature.inlet - dTHTF_HotSalt
          status.hSalt.hot = salt.heatCapacity[0]
            * ((status.temperature.inlet - status.dTHTF_HotSalt).toCelsius)
            + 0.5 * salt.heatCapacity[1]
            * ((status.temperature.inlet - status.dTHTF_HotSalt).toCelsius) ** 2 - 350.5536
          status.hSalt.cold = salt.heatCapacity[0]
            * (status.temperatureTank.cold.toCelsius)
            + 0.5 * salt.heatCapacity[1]
            * (status.temperatureTank.cold.toCelsius) ** 2 - 350.5536
          status.massSalt = -Plant.heatFlow.storage
            / (status.hSalt.hot - status.hSalt.cold) * hourFraction * 3_600 * 1_000
          status.mass.cold = status.mass.cold - status.massSalt
          
          if status.mass.cold < minmass { // added to avoid negative or too low mass and therefore no heat losses.
            status.massSalt = status.massSalt - (minmass - status.mass.cold) }
          if status.massSalt < 10 { status.massSalt = 0
            status.mass.cold = minmass
            status.mass.hot = status.massSalt + status.mass.hot
            status.heatrel = parameter.chargeTo
          } else {
            status.mass.hot = status.massSalt + status.mass.hot
            status.heatrel = status.mass.hot
              * (parameter.designTemperature.hot - parameter.designTemperature.cold)
              / (status.massSalt * (parameter.designTemperature.hot
                - parameter.designTemperature.cold))
          }
          if status.mass.hot > 0 {
            status.temperatureTank.hot = (status.massSalt
              * (status.temperature.inlet - status.dTHTF_HotSalt)
              + status.mass.hot * status.temperatureTank.hot)
              / (status.massSalt + status.mass.hot)
          } else {
            status.temperatureTank.hot = status.temperatureTank.hot
          }
          
        case .fc:
          // check if changes have to be done related to salt temperature
          status.hSalt.hot = salt.heatCapacity[0]
            * (parameter.designTemperature.hot.toCelsius)
            + 0.5 * salt.heatCapacity[1]
            * (parameter.designTemperature.hot.toCelsius) ** 2 - 350.5536
          status.hSalt.cold = salt.heatCapacity[0]
            * (status.temperatureTank.cold.toCelsius)
            + 0.5 * salt.heatCapacity[1]
            * (status.temperatureTank.cold.toCelsius) ** 2 - 350.5536
          status.massSalt = -Plant.heatFlow.storage
            / (status.hSalt.hot - status.hSalt.cold)
            * hourFraction * 3_600 * 1_000
          status.mass.cold = status.mass.cold - status.massSalt
          status.mass.hot = status.massSalt + status.mass.hot
          status.heatrel = status.mass.hot
            * (parameter.designTemperature.hot - parameter.designTemperature.cold)
            / (status.massSalt * (parameter.designTemperature.hot
              - parameter.designTemperature.cold))
          if status.mass.hot > 0 {
            status.temperatureTank.hot = (status.massSalt
              * parameter.designTemperature.hot
              + status.mass.hot * status.temperatureTank.hot)
              / (status.massSalt + status.mass.hot)
          } else {
            status.temperatureTank.hot = status.temperatureTank.hot
          }
          
        case .ex:
          status.hSalt.hot = salt.heatCapacity[0]
            * (status.temperatureTank.hot.toCelsius)
            + 0.5 * salt.heatCapacity[1]
            * (status.temperatureTank.hot.toCelsius) ** 2 - 350.5536
          status.hSalt.cold = salt.heatCapacity[0]
            * ((status.temperature.inlet + status.dTHTF_ColdSalt).toCelsius)
          status.hSalt.cold += 0.5 * salt.heatCapacity[1]
            * ((status.temperature.inlet
              + status.dTHTF_ColdSalt).toCelsius) ** 2 - 350.5536
          
          status.massSalt = Plant.heatFlow.storage
            / (status.hSalt.hot - status.hSalt.cold) * hourFraction * 3_600 * 1_000
          status.mass.hot = -status.massSalt + status.mass.hot
          
          if status.mass.hot < minmass {
            // added to avoid negative or too low mass and therefore no heat losses
            status.massSalt = status.massSalt - (minmass - status.mass.hot) }
          if status.massSalt < 10 { status.massSalt = 0
            
            Plant.heatFlow.storage = status.massSalt
              * (status.hSalt.hot - status.hSalt.cold) / hourFraction / 3_600 / 1_000
            status.mass.hot = minmass
            
            status.mass.cold = status.mass.cold + status.massSalt
            status.heatrel = parameter.dischargeToTurbine
          } else {
            status.mass.cold = status.mass.cold + status.massSalt
            status.heatrel = status.mass.hot * (parameter.designTemperature.hot
              - parameter.designTemperature.cold) / (status.massSalt *
                (parameter.designTemperature.hot
                  - parameter.designTemperature.cold))
          }
          if status.mass.cold > 0 {
            // cold salt is status.temperature.inlet + dTHTF_ColdSalt
            status.temperatureTank.cold = (status.massSalt
              * (status.temperature.inlet + status.dTHTF_ColdSalt)
              + status.mass.cold * status.temperatureTank.cold)
              / (status.massSalt + status.mass.cold)
          }
          
        case .ph:
          status.hSalt.hot = salt.heatCapacity[0]
            * (status.temperatureTank.hot.toCelsius)
            + 0.5 * salt.heatCapacity[1]
            * (status.temperatureTank.hot.toCelsius) ** 2 - 350.5536
          status.hSalt.cold = salt.heatCapacity[0]
            * (parameter.designTemperature.cold.toCelsius)
            + 0.5 * salt.heatCapacity[1]
            * (parameter.designTemperature.cold.toCelsius) ** 2 - 350.5536
          status.massSalt = Plant.heatFlow.storage
            / (status.hSalt.hot - status.hSalt.cold)
            * hourFraction * 3_600 * 1_000
          status.mass.hot = -status.massSalt + status.mass.hot
          
          status.mass.cold = status.mass.cold + status.massSalt
          status.heatrel = status.mass.hot
            * (parameter.designTemperature.hot - parameter.designTemperature.cold)
            / (status.massSalt * (parameter.designTemperature.hot
              - parameter.designTemperature.cold))
          
          status.temperatureTank.cold = (status.massSalt * parameter.designTemperature.cold
            + status.mass.cold * status.temperatureTank.cold)
            / (status.massSalt + status.mass.cold)
          
        case .freezeProtection:
          let splitfactor = parameter.HTF == .hiXL ? 0.4 : 1
          
          status.massSalt = SolarField.parameter.antiFreezeFlow * hourFraction * 3_600
          status.temperatureTank.cold = (splitfactor * status.massSalt
            * PowerBlock.status.temperature.outlet
            + status.mass.cold * status.temperatureTank.cold)
            / (splitfactor * status.massSalt + status.mass.cold)
          status.StoTcoldTout = splitfactor * status.temperatureTank.cold
            + (1 - splitfactor) * PowerBlock.status.temperature.outlet
          // PowerBlock.status.temperature.outlet  = storage.temperatureTank.cold
          
        case .no:
          if parameter.TturbIterate < -90,
            status.temperatureTank.cold < parameter.designTemperature.cold,
            PowerBlock.status.temperature.outlet > status.temperatureTank.cold,
            status.mass.cold > 0 {
            status.massSalt = PowerBlock.status.massFlow * hourFraction * 3_600
            status.temperatureTank.cold = (status.massSalt
              * PowerBlock.status.temperature.outlet
              + status.mass.cold * status.temperatureTank.cold)
              / (status.massSalt + status.mass.cold)
            status.operationMode = .sc
          }
        default: break
        }
        
        // Storage Heat Losses:
        if SteamTurbine.status.isMaintained {
        } else {
          if status.mass.hot > 0 { // parameter.dischargeToTurbine * Saltmass {
            // enthalpy before cooling down
            status.hSalt.hot = salt.heatCapacity[0]
              * (status.temperatureTank.hot.toCelsius)
              + 0.5 * salt.heatCapacity[1]
              * (status.temperatureTank.hot.toCelsius) ** 2 - 350.5536
            // enthalpy after cooling down
            status.hSalt.hot = status.hSalt.hot - HotTankQverl
              * Double(period) / status.mass.hot
            // temp after cool down
            status.temperatureTank.hot = (-salt.heatCapacity[0]
              + (salt.heatCapacity[0] ** 2
              - 4 * (salt.heatCapacity[1] * 0.5)
                * (-350.5536 - status.hSalt.hot)) ** 0.5)
              / (2 * salt.heatCapacity[1] * 0.5).toKelvin
          }
          if status.mass.cold > parameter.dischargeToTurbine * status.massSalt {
            // enthalpy before cooling down
            status.hSalt.cold = salt.heatCapacity[0]
              * (status.temperatureTank.cold.toCelsius)
              + 0.5 * salt.heatCapacity[1]
              * (status.temperatureTank.cold.toCelsius) ** 2 - 350.5536
            // enthalpy after cooling down
            status.hSalt.cold = status.hSalt.cold - ColdTankQverl
              * Double(period) / status.mass.cold
            // temp after cool down
            status.temperatureTank.cold = (-salt.heatCapacity[0]
              + (salt.heatCapacity[0] ** 2
              - 4 * (salt.heatCapacity[1] * 0.5)
                * (-350.5536 - status.hSalt.cold)) ** 0.5)
              / (2 * salt.heatCapacity[1] * 0.5).toKelvin
          }
        }
      }
      
      if Plant.heatFlow.storage < 0 {
        if case .freezeProtection = status.operationMode {
          // FIXME PowerBlock.status.temperature.outlet // = PowerBlock.status.temperature.outlet
        } else if case .charging = status.operationMode {
          // if status.operationMode = "IN" added to avoid Tmix during TES discharge (valid for indirect storage), check!
          PowerBlock.status.temperature.outlet = htf.mixing(
            outlet: PowerBlock.status, with: status)
        } else { // for indirect TES discharge added, check!
          // FIXME PowerBlock.status.temperature.outlet // = PowerBlock.status.temperature.outlet
        }
      }
      
      // FIXME HeatExchanger.status.H2OinTmax = status.mass.hot
      // FIXME HeatExchanger.status.H2OinTmin = status.mass.cold
      // FIXME HeatExchanger.status.H2OoutTmax = status.temperatureTank.hot
      // FIXME HeatExchanger.status.H2OoutTmin = status.temperatureTank.cold
      
    }
  }
  static func operate(powerBlock: inout PowerBlock.PerformanceData,
                      solarField: inout SolarField.PerformanceData,
                      availableFuel: inout Double,
                      fuel: inout FuelConsumption,
                      heatFlow: inout HeatFlow,
                      date: Date) {
    var storage = status
    defer { status = storage }
    
    var heatdiff = 0.0
    
    if Design.hasGasTurbine {
      powerBlock.massFlow = HeatExchanger.parameter.SCCHTFheat /
        (htf.heatTransfered(
          HeatExchanger.parameter.temperature.htf.inlet.max,
          HeatExchanger.parameter.temperature.htf.outlet.max) / 1_000)
      heatdiff = heatFlow.production - HeatExchanger.parameter.SCCHTFheat
    } else {
      
      if case .always = Storage.parameter.strategy {
        // if demand is selected, variable is called Alw but calculation is done as demand, error comes from older version // "Dem"
        powerBlock.massFlow = heatFlow.demand
          / (htf.heatTransfered(
            HeatExchanger.parameter.temperature.htf.inlet.max,
            HeatExchanger.parameter.temperature.htf.outlet.max) / 1_000)
        
        if powerBlock.massFlow < 0 { // to avoid negative massfows
          heatdiff = 0
          powerBlock.massFlow = solarField.massFlow
        }
      } else {
        heatdiff = heatFlow.production - heatFlow.demand // [MW]
        if Storage.parameter.heatExchangerRestrictedMin {
          // added to avoid input to storage lower than minimal HX// s capacity
          heatFlow.toSTOmin = Storage.parameter.heatExchangerMinCapacity
            * HeatExchanger.parameter.SCCHTFheat
            * (1 - Storage.parameter.massFlow / SolarField.parameter.massFlow.max)
            / (Storage.parameter.massFlow / SolarField.parameter.massFlow.max)
          
          if heatdiff > 0 && heatdiff < heatFlow.toSTOmin {
            heatFlow.demand = heatFlow.demand - (heatFlow.toSTOmin - heatdiff)
            powerBlock.massFlow = heatFlow.demand
              / htf.temperature(
                HeatExchanger.parameter.temperature.htf.inlet.max,
                HeatExchanger.parameter.temperature.htf.outlet.max) / 1_000
            heatdiff = heatFlow.toSTOmin
          }
        }
      }
      if case .demand = Storage.parameter.strategy {
        // if Always is selected, variable is called "Dem" but calculation is done as "Always", error comes from older version // "Alw" {
        powerBlock.massFlow = HeatExchanger.parameter.SCCHTFheat
          / (htf.temperature(
            HeatExchanger.parameter.temperature.htf.inlet.max,
            HeatExchanger.parameter.temperature.htf.outlet.max) / 1_000)
        
        if powerBlock.massFlow < 0.0 { // to avoid negative massfows
          heatdiff = 0
          powerBlock.massFlow = solarField.massFlow
        } else {
          heatdiff = heatFlow.production - HeatExchanger.parameter.SCCHTFheat
          // changed back as heatFlow.production - HeatExchanger.parameter.SCCHTFheat// heatFlow.demand     // [MW]
          if Storage.parameter.heatExchangerRestrictedMin {
            // added to avoid input to storage lower than minimal HX// s capacity
            heatFlow.toSTOmin = HeatExchanger.parameter.SCCHTFheat
              * (1 - Storage.parameter.massFlow / SolarField.parameter.massFlow.max)
              / (Storage.parameter.massFlow / SolarField.parameter.massFlow.max)
            
            if heatdiff > 0 && heatdiff < heatFlow.toSTOmin {
              powerBlock.massFlow = (HeatExchanger.parameter.SCCHTFheat
                - (heatFlow.toSTOmin - heatdiff))
                / (htf.heatTransfered(
                  HeatExchanger.parameter.temperature.htf.inlet.max,
                  HeatExchanger.parameter.temperature.htf.outlet.max) / 1_000)
              heatdiff = heatFlow.toSTOmin
            }
          }
        }
      }
      
      
      if case .shifter = Storage.parameter.strategy { // Storage.parameter.strategy = "Ful" // Booster or Shifter
        // new calculation of shifter, old kept and commented below this:
        if date.month < Storage.parameter.startexcep || date.month > Storage.parameter.endexcep {
          storage.heatProductionLoad = Storage.parameter.heatProductionLoadWinter
          if DNIdaysum > Storage.parameter.badDNIwinter * 1_000 {
            // sunny day, TES can be fully charged also by running TB at full load
            storage.heatProductionLoad = 1
          }
        } else {
          storage.heatProductionLoad = Storage.parameter.heatProductionLoadSummer
          if DNIdaysum > Storage.parameter.badDNIsummer * 1_000 {
            // sunny day, TES can be fully charged also by running TB at full load
            storage.heatProductionLoad = 1
          }
        }
        
        if heatFlow.production > 0 { // Qsol > 0
          
          if heatFlow.production < heatFlow.demand,
            storage.heatrel < Storage.parameter.chargeTo,
            date.hour < 17 {
            // Qsol not enough for POB demand load (e.g. at the beginning of the day)
            powerBlock.massFlow = min(
              storage.heatProductionLoad * heatFlow.demand,
              heatFlow.production)
              / (htf.heatTransfered(
                HeatExchanger.parameter.temperature.htf.inlet.max,
                HeatExchanger.parameter.temperature.htf.outlet.max) / 1_000)
            
            heatdiff = heatFlow.production - min(
              storage.heatProductionLoad * heatFlow.demand,
              heatFlow.production)
            // TES gets the rest available
            if Storage.parameter.heatExchangerRestrictedMax {
              heatdiff = min(heatdiff, Storage.parameter.heatExchangerCapacity)
            } else {
              let value = SteamTurbine.parameter.power.max
                / SteamTurbine.parameter.efficiencyNominal
                / HeatExchanger.parameter.efficiency
              if heatdiff > value {
                heatdiff = value
              }
            }
          } else if heatFlow.production < heatFlow.demand,
            storage.heatrel >= Storage.parameter.chargeTo {
            // Qsol not enough for POB demand load (e.g. at the end of the day) and TES is full
            powerBlock.massFlow = heatFlow.demand / (htf.heatTransfered(
              HeatExchanger.parameter.temperature.htf.inlet.max,
              HeatExchanger.parameter.temperature.htf.outlet.max) / 1_000)
            // send all to POB and if needed discharge TES
            
            heatdiff = heatFlow.production - heatFlow.demand
            // TES provides the rest available
            // check what if TES is full and POB could get more than 50% of design!!
            if Storage.parameter.heatExchangerRestrictedMax {
              heatdiff = max(heatdiff, -Storage.parameter.heatExchangerCapacity)
            } else { // signs below changed
              let value = SteamTurbine.parameter.power.max
                / SteamTurbine.parameter.efficiencyNominal
                / HeatExchanger.parameter.efficiency
              if heatdiff > -value {
                heatdiff = -value
              }
            }
          } else if heatFlow.production > heatFlow.demand,
            storage.heatrel < Storage.parameter.chargeTo,
            solarField.massFlow >= powerBlock.massFlow {
            // more Qsol than needed by POB and TES is not full
            powerBlock.massFlow = (storage.heatProductionLoad * heatFlow.demand)
              / (htf.heatTransfered(
                HeatExchanger.parameter.temperature.htf.inlet.max,
                HeatExchanger.parameter.temperature.htf.outlet.max) / 1_000)
            // from avail heat cover first 50% of POB demand
            heatdiff = heatFlow.production - (storage.heatProductionLoad * heatFlow.demand)
            // TES gets the rest available
            if Storage.parameter.heatExchangerRestrictedMax {
              if heatdiff > Storage.parameter.heatExchangerCapacity {
                // rest heat to TES is too high, use more heat to POB
                powerBlock.massFlow =
                  (heatFlow.production - Storage.parameter.heatExchangerCapacity)
                  / (htf.heatTransfered(
                    HeatExchanger.parameter.temperature.htf.inlet.max,
                    HeatExchanger.parameter.temperature.htf.outlet.max) / 1_000)
                // from avail heat cover first 50% of POB demand
                
                heatdiff = Storage.parameter.heatExchangerCapacity
                // TES gets max heat input
              }
            }
          }
        } else {
          var i = 0
          if case .hours = Storage.parameter.definedBy {
            // condition added. It usually doesn't get in here. therefore, not correctly programmed yet
            if heatFlow.production > heatFlow.demand,
              storage.heatrel > 1 * SteamTurbine.parameter.power.max
                / SteamTurbine.parameter.efficiencyNominal / Design.layout.storage {
              i = -1
              //   } else if Storage.parameter.definedBy = "cap" {
              //       if heatFlow.production > heatFlow.demand && storage.heatrel > 1 * SteamTurbine.parameter.power.max / SteamTurbine.parameter.efficiencyNominal / Design.layout.storage_cap { i = -1
              //   } else if Storage.parameter.definedBy = "ton" {
              //       if heatFlow.production > heatFlow.demand && storage.heatrel > 1 * SteamTurbine.parameter.power.max / SteamTurbine.parameter.efficiencyNominal / Design.layout.storage_ton { i = -1
            }
            if i == -1 {
              heatFlow.demand = SteamTurbine.parameter.power.max
                * Plant.availability[date.month].powerBlock.value / SteamTurbine.efficiency // limit HX capacity?
              var heatdiff = heatFlow.production - heatFlow.demand // [MW]
              // power to charge TES rest after operation POB at full load commented
              //  heatdiff = max(heatFlow.production, heatFlow.demand) // maximal power to TES desing POB thermal input (just to check how it works)
              let heat = SteamTurbine.parameter.power.max
                / SteamTurbine.parameter.efficiencyNominal / HeatExchanger.parameter.efficiency
              if heatdiff > heat {
                heatdiff = heat // commented in case of degradated powerblock
                // if heatdiff > SteamTurbine.parameter.power.max / SteamTurbine.parameter.efficiencyNominalOriginal / HeatExchanger.parameter.efficiency {
                // heatdiff = SteamTurbine.parameter.power.max / SteamTurbine.parameter.efficiencyNominalOriginal / HeatExchanger.parameter.efficiency
                // in case of degradated powerblock
                powerBlock.massFlow = (heatFlow.production - heatdiff)
                  / (htf.heatTransfered(
                    HeatExchanger.parameter.temperature.htf.inlet.max,
                    HeatExchanger.parameter.temperature.htf.outlet.max) / 1_000)
              }
            }
          }
        }
      }
    }
    if heatdiff > 0 {
      
      // Energy surplus
      if storage.heatrel < Storage.parameter.chargeTo,
        solarField.massFlow >= powerBlock.massFlow {
        Storage.operate(mode: .charging,
                        date: date,
                        heatFlow: &heatFlow)
        Storage.operate(mode: .charging, date: date, heatFlow: &heatFlow)
        //Storage.operate(mode: .charging, Storage.parameter.heatExchanger * heatdiff, powerBlock.massFlow, hourFraction, heatFlow.storage, electricalParasitics.storage, storage.mass.hot, storage.temperatureTank.cold, storage.mass.cold, XZ)
        powerBlock.temperature.inlet = solarField.temperature.outlet
        // FIXME powerBlock.massFlow = powerBlock.massFlow
      } else { // heat cannot be stored
        Storage.operate(mode: .noOperation, date: date, heatFlow: &heatFlow)
        //Storage.operate(mode: .noOperation, heatdiff, powerBlock.massFlow, heatFlow.storage, electricalParasitics.storage, storage.mass.hot, storage.temperatureTank.cold, storage.mass.cold, XZ)
        powerBlock.temperature.inlet = solarField.temperature.outlet
      }
      
    } else { // Energy deficit
      var peakTariff: Bool
      // check when to discharge TES
      if case .shifter = Storage.parameter.strategy { // only for Shifter
        if date.month < Storage.parameter.startexcep || date.month > Storage.parameter.endexcep { // Oct to March
          peakTariff = date.hour >= Storage.parameter.dischrgWinter
        } else { // April to Sept
          peakTariff = date.hour >= Storage.parameter.dischrgSummer
        }
      } else { // not shifter
        peakTariff = true // dont care about time to discharge
      }
      var noFreezeProtection = true
      if case .freezeProtection = storage.operationMode {
        noFreezeProtection = false
      }
      if peakTariff, noFreezeProtection,
        storage.heatrel > Storage.parameter.dischargeToTurbine,
        heatdiff < -1 * Storage.parameter.heatdiff * heatFlow.demand { // added dicharge only after peak hours
        // previous discharge condition commented:
        // if storage.heatrel > Storage.parameter.dischargeToTurbine && storage.operationMode != .freezeProtection && heatdiff < -1 * Storage.parameter.heatdiff * heatFlow.demand { // Discharge directly!! // 04.07.0 -0.25&& heatdiff < -0.25 * heatFlow.dem
        if powerBlock.massFlow < solarField.massFlow { // there are cases, during cloudy days when OpMode is "EX" although massflow in SOF is higher that in PB.
        }
        Storage.operate(mode: .ex, date: date, heatFlow: &heatFlow)
        //Storage.operate(mode: .ex, heatdiff, powerBlock.massFlow, heatFlow.storage, heatLossStorage, electricalParasitics.storage, storage.mass.hot, storage.temperatureTank.cold, storage.mass.cold, XZ)
        if case .freezeProtection = solarField.operationMode {
          powerBlock.temperature.inlet = htf.mixing(
            outlet: solarField, with: storage)
          powerBlock.massFlow = Storage.parameter.heatExchangerEfficiency
            * storage.massFlow + solarField.massFlow //
        } else if case .operating = solarField.operationMode { // eingefügt  IF-abrage eingefügt
          powerBlock.temperature.inlet = htf.mixing(
            outlet: solarField, with: storage)
          powerBlock.massFlow = Storage.parameter.heatExchangerEfficiency
            * storage.massFlow + solarField.massFlow //
        } else if storage.massFlow > 0 {
          powerBlock.temperature.inlet = storage.temperature.outlet
          powerBlock.massFlow = Storage.parameter.heatExchangerEfficiency * storage.massFlow
        } else {
          powerBlock.massFlow = 0
        }
        
      } else { // heat can only be provided with heater on
        
        if (Storage.parameter.FC == 0 && Collector.status.parabolicElevation < 0.011
          && storage.heatrel < Storage.parameter.chargeTo
          && !(powerBlock.temperature.inlet > 665)
          && SteamTurbine.status.isMaintained
          && (date.month < Storage.parameter.FCstopM
            || (date.month == Storage.parameter.FCstopM
            && date.day < Storage.parameter.FCstopD)
            || ((date.month == Storage.parameter.FCstartM
              && date.day > Storage.parameter.FCstartD)
              || date.month > Storage.parameter.FCstartM)
            && (date.month < Storage.parameter.FCstopM2
              || (date.month == Storage.parameter.FCstopM2
              && date.day < Storage.parameter.FCstopD2)
              || (date.month > Storage.parameter.FCstartM2
                || (date.month == Storage.parameter.FCstartM2
                && date.day > Storage.parameter.FCstartD2))))
          && Fuelmode != "predefined") || (Fuelmode == "predefined" && availableFuel > 0) {
          Heater.status.operationMode = .freezeProtection
          if Fuelmode != "predefined" {
            let availableFuel = Double.greatestFiniteMagnitude
            heatFlow.heater = Heater.operate(demand: 0,
                                             availableFuel: availableFuel,
                                             fuelFlow: &fuel.heater)
            Plant.electricalParasitics.heater = Heater.parasitics
            powerBlock.massFlow = Heater.status.massFlow
            Storage.operate(mode: .freezeProtection, date: date, heatFlow: &heatFlow)
            // FIXME powerBlock.massFlow = powerBlock.massFlow
            powerBlock.temperature.inlet = storage.temperature.outlet
            // check why to circulate HTF in SF
            Plant.electricalParasitics.solarField = SolarField.parameter.antiFreezeParastics
          } else if case .freezeProtection = solarField.operationMode,
            storage.heatrel > -0.35 && Storage.parameter.FP == 0 {
            
            Storage.operate(mode: .freezeProtection, date: date, heatFlow: &heatFlow)
            //Storage.operate(mode: .freezeProtection, date: heatdiff, heatFlow: powerBlock.massFlow, status: heatFlow.storage)
          } else {
            Storage.operate(mode: .noOperation, date: date, heatFlow: &heatFlow)
            //Storage.operate(mode: .noOperation, date: heatdiff, heatFlow: powerBlock.massFlow, status: heatFlow.storage)
          }
        }
      }
      
      heatFlow.storage = storage.massFlow
        * htf.heatTransfered(storage.temperature.outlet,
                             storage.temperature.inlet) / 1_000
      
      // Check if the required heat is contained in TES, if not recalculate heatFlow.storage
      
      switch storage.operationMode {
        
      case .ex:
        storage.hSalt.hot = salt.heatCapacity[0] * (storage.temperatureTank.hot.toCelsius)
          + 0.5 * salt.heatCapacity[1]
          * (storage.temperatureTank.hot.toCelsius) ** 2 - 350.5536
        storage.hSalt.cold = salt.heatCapacity[0] * ((storage.temperature.inlet
          + storage.dTHTF_ColdSalt).toCelsius)
          + 0.5 * salt.heatCapacity[1] * (storage.temperature.inlet
            + storage.dTHTF_ColdSalt.toCelsius) ** 2 - 350.5536
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
          * (storage.temperature.inlet
          - storage.dTHTF_HotSalt.toCelsius) + 0.5
          * salt.heatCapacity[1] * (storage.temperature.inlet
            - storage.dTHTF_HotSalt.toCelsius) ** 2 - 350.5536 //
        storage.hSalt.cold = salt.heatCapacity[0]
          * (storage.temperatureTank.cold.toCelsius)
          + 0.5 * salt.heatCapacity[1]
          * (storage.temperatureTank.cold.toCelsius) ** 2 - 350.5536
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
      
      if heatdiff > 0 { // Energy surplus
        if storage.heatrel < Storage.parameter.chargeTo,
          solarField.massFlow >= powerBlock.massFlow { // 1.1
          heatFlow.production = heatFlow.solar + heatFlow.storage
        } else { // heat cannot be stored
          heatFlow.production = heatFlow.solar - heatdiff
          // surplus is dumped (?) and not sent to PB
        }
      } else {
        heatFlow.production = heatFlow.solar + heatFlow.storage
      }
    }
  }
}



