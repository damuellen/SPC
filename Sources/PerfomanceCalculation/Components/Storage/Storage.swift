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
  public struct PerformanceData: MassFlow, WorkingConditions {
    var operationMode: OperationMode
    var heatFlow: Double
    var temperature: (inlet: Temperature, outlet: Temperature)
    var temperatureTank: (cold: Temperature, hot: Temperature)
    var massFlow, heatrel: Double
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
    operationMode: .noOperation, heatFlow: 0.0,
    temperature: (0.0, 0.0), temperatureTank: (0.0, 0.0),
    massFlow: 0, heatrel: 0,
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
  
  public static var minmass: Double {
    switch parameter.definedBy {
    case .hours:
      let minmass = Design.layout.storage * parameter.dischargeToTurbine
        * HeatExchanger.parameter.SCCHTFheatFlow * 1_000 * 3_600
        / (status.hSalt.hot - status.hSalt.cold)
      HeatExchanger.parameter.temperature.h2o.inlet.max = Temperature(parameter.startLoad.hot
        * Design.layout.storage * HeatExchanger.parameter.SCCHTFheatFlow * 1_000 * 3_600
        / (status.hSalt.hot - status.hSalt.cold) + minmass) // Factor 1.1
      HeatExchanger.parameter.temperature.h2o.inlet.min = Temperature(parameter.startLoad.cold
        * Design.layout.storage * HeatExchanger.parameter.SCCHTFheatFlow * 1_000 * 3_600
        / (status.hSalt.hot - status.hSalt.cold) + minmass)
      return minmass
    case .cap:
      let minmass = Design.layout.storage_cap
        * parameter.dischargeToTurbine * 1_000 * 3_600
        / (status.hSalt.hot - status.hSalt.cold)
      HeatExchanger.parameter.temperature.h2o.inlet.max = Temperature(parameter.startLoad.hot
        * Design.layout.storage_cap * 1_000 * 3_600
        / (status.hSalt.hot - status.hSalt.cold) + minmass) // Factor 1.1
      HeatExchanger.parameter.temperature.h2o.inlet.min = Temperature(parameter.startLoad.cold
        * Design.layout.storage_cap * 1_000 * 3_600
        / (status.hSalt.hot - status.hSalt.cold) + minmass)
      return minmass
    case .ton:
      let minmass = Design.layout.storage_ton * parameter.dischargeToTurbine * 1_000 // OK
      HeatExchanger.parameter.temperature.h2o.inlet.max = Temperature(parameter.startLoad.hot
        * Design.layout.storage_ton * 1_000 + minmass)
      HeatExchanger.parameter.temperature.h2o.inlet.min = Temperature(parameter.startLoad.cold
        * Design.layout.storage_ton * 1_000 + minmass)
      return minmass
    }
  }
  
  /// Calculates the parasitics of the gas turbine which only depends on the current load
  private static func parasitics(at status: inout PerformanceData) -> Double {
    
    var parasitics = 0.0
    var timeminutessum = 0
    var timeminutesold = 0
    let time = PerformanceCalculator.dateTime
    
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
      let rohmean = htf.density(Temperature((status.temperature.inlet + status.temperature.outlet).value / 2))
      let rohDP = htf.density(Temperature((HeatExchanger.parameter.temperature.htf.inlet.max
        + HeatExchanger.parameter.temperature.htf.outlet.max).value / 2))
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
  func prepare() {
    if Design.hasStorage {

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
        * Storage.parameter.designTemperature.hot.value
        + 0.5 * salt.heatCapacity[1]
        * Storage.parameter.designTemperature.hot.value ** 2 - 350.5536
      Storage.status.hSalt.cold = salt.heatCapacity[0]
        * Storage.parameter.designTemperature.cold.value
        + 0.5 * salt.heatCapacity[1]
        * Storage.parameter.designTemperature.cold.value ** 2 - 350.5536
      
      HeatExchanger.parameter.temperature.h2o.inlet.max = Temperature(
        Storage.parameter.startTemperature.hot.toKelvin)
      HeatExchanger.parameter.temperature.h2o.inlet.min = Temperature(
        Storage.parameter.startTemperature.cold.toKelvin)
      
      if Storage.parameter.tempInCst[1] == 0 {
        Storage.status.dTHTF_HotSalt = Temperature(Storage.parameter.tempExC0to1[0])
        Storage.status.dTHTF_ColdSalt = Temperature(-Storage.parameter.tempInCst[0])
        Storage.parameter.tempExC0to1[0] = Storage.parameter.designTemperature.hot.value
          - Storage.parameter.tempExC0to1[0] // meaning is HTFTout(EX) = HotTankDes - dT
        Storage.parameter.tempExCst[0] = Storage.parameter.tempExC0to1[0]
        Storage.parameter.tempInCst[0] = Storage.parameter.designTemperature.cold.value
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
  public static func operate(_ storage: inout Storage.PerformanceData,
                             mode _: PerformanceData.OperationMode,
                             solarField: inout SolarField.PerformanceData,
                             heatFlow: inout HeatFlow) {
    
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
    let time = PerformanceCalculator.dateTime
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
      solarField.header.massFlow = 0
    }
    
    switch status.operationMode { // = status.OPmode
      
    case .charging: // heat can be stored
      
      // status.operationMode = "IN"
      status.temperature.inlet = solarField.temperature.outlet
      // the PowerBlock.status.massFlow is only an ideal value, for maximal dT, isnt it wrong?
      status.massFlow = solarField.massFlow - PowerBlock.status.massFlow
      status.massFlow *= parameter.heatExchangerEfficiency
      // * Plant.availability[dateTime].storage taken out of the formula and included in TES capacity calculation
      
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
            - (parameter.designTemperature.cold - status.temperatureTank.cold).value
        } else {
          // adjust of HTF outlet temp. with status cold tank temp.
          StoFit += parameter.tempInCst[0]
            - (parameter.designTemperature.cold - status.temperatureTank.cold).value
        }
      }
      status.temperature.outlet = Temperature(StoFit)
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
            - HeatExchanger.parameter.SCCHTFheatFlow + status.heatFlow
        } else {
          heatFlow.dump = heatFlow.dump + heatFlow.production
            - heatFlow.demand + status.heatFlow
        }
        solarField.header.massFlow = PowerBlock.status.massFlow + status.massFlow
        // reduce HTF massflow in SF
        heatFlow.solar = solarField.massFlow * htf.heatTransfered(
          solarField.temperature.outlet, solarField.temperature.inlet) / 1_000
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
            - (parameter.designTemperature.cold - status.temperatureTank.cold).value
        } else {
          StoFit += parameter.tempInCst[0]
            - (parameter.designTemperature.cold - status.temperatureTank.cold).value
        }
      }
      status.temperature.outlet = Temperature(StoFit)
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
      if time.hour >= SSetTime && time.hour < (SSetTime + 1) && parameter.isVariable {
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
            * (parameter.designTemperature.hot - parameter.designTemperature.cold).value / 3_600
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
            * (parameter.designTemperature.hot - parameter.designTemperature.cold).value
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
      
      switch solarField.operationMode {
      case .freezeProtection:
        // reduction of HTF Mass flow during strorage discharging due to results of AndaSol-1 Heat Balance
        status.massFlow = QoutLoad * PowerBlock.status.massFlow
          / parameter.heatExchangerEfficiency
        // - solarField.massFlow
        
      case .operating where solarField.massFlow > 0:
        // Mass flow is correctd by parameter.Hx this factor is new
        status.massFlow = PowerBlock.status.massFlow
          / parameter.heatExchangerEfficiency - solarField.massFlow
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
            htf.temperatureDelta(status.temperature.outlet.value,
                                 status.temperature.inlet).value * 1_000
          if case .freezeProtection = solarField.operationMode {
            // reduction of HTF Mass flow during storage discharging due to results of AndaSol-1 Heat Balance
            PowerBlock.status.massFlow = status.massFlow
              * parameter.heatExchangerEfficiency / 0.97 // - solarField.massFlow
            
          } else {
            // Mass flow is correctd by new factor
            PowerBlock.status.massFlow = (status.massFlow + solarField.massFlow)
              * parameter.heatExchangerEfficiency / 0.97
          }
        }
        
        SteamTurbine.status.load = Ratio((heatFlow.solar + status.heatFlow)
          / (SteamTurbine.parameter.power.max
            / SteamTurbine.efficiencyFor(load: Ratio(1), Lmax: Ratio(Lmax))))
        MixTemp = htf.mixingTemperature(outlet: solarField, with: status)
        MinTBTemp = Temperature(310.0.toKelvin) // TurbineTempLoad(SteamTurbine.status.load)
        
        if MixTemp.value > MinTBTemp.value - Simulation.parameter.tempTolerance.value * 2 {
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
      status.massFlow = PowerBlock.status.massFlow - solarField.massFlow
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
      
      let splitfactor: Double = 0.4
      status.massFlow = splitfactor * SolarField.parameter.antiFreezeFlow
      solarField.header.massFlow = SolarField.parameter.antiFreezeFlow
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
          status.temperature.outlet = Temperature(
            StoFit * parameter.designTemperature.hot.toKelvin)
        }
        status.temperature.outlet = Temperature(splitfactor * status.temperature.outlet.value
          + (1 - splitfactor) * status.temperature.inlet.value)
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
          - (parameter.designTemperature.hot.value - status.temperatureTank.hot.value)
      } else {
        StoFit += parameter.tempExC0to1[0]
          - (parameter.designTemperature.hot.value - status.temperatureTank.hot.value)
        // adjust of HTF outlet temp. with status hot tank temp.
      }
    }
    status.temperature.outlet = Temperature(StoFit) // independent from massFlow !!!
  }
  
  static func prepareStorage() {
    if Design.hasStorage { // keep track of the filling of the storage
      
      let ColdTankQverl = parameter.heatLoss.cold
        * (status.temperatureTank.cold.value - 300.0)
        / (parameter.designTemperature.cold.value - 27)
      let HotTankQverl = parameter.designTemperature.cold.value
        * (status.temperatureTank.hot.value - 300.0)
        / (parameter.designTemperature.hot.value - 27)
      status.hSalt.hot = salt.heatCapacity[0]
        * (parameter.designTemperature.hot.toCelsius) + 0.5 * salt.heatCapacity[1]
        * (parameter.designTemperature.hot.toCelsius) ** 2 - 350.5536
      status.hSalt.cold = salt.heatCapacity[0]
        * (parameter.designTemperature.cold.toCelsius) + 0.5 * salt.heatCapacity[1]
        * (parameter.designTemperature.cold.toCelsius) ** 2 - 350.5536
      
      switch parameter.definedBy {
      case .hours:
        // Plant.availability[currentDate.month].storage added here to apply TES availability on capacity and not on charge load
        status.massSalt = Design.layout.storage
          * Plant.availability[PerformanceCalculator.dateTime].storage.value
          * (1 + parameter.dischargeToTurbine)
        status.massSalt *= HeatExchanger.parameter.SCCHTFheatFlow * 1_000 * 3_600
          / (status.hSalt.hot - status.hSalt.cold)
      case .cap:
        status.massSalt = Design.layout.storage_cap
          * Plant.availability[PerformanceCalculator.dateTime].storage.value
          * (1 + parameter.dischargeToTurbine)
        status.massSalt *= 1_000 * 3_600 / (status.hSalt.hot - status.hSalt.cold)
      case .ton:
        status.massSalt = Design.layout.storage_ton
          * Plant.availability[PerformanceCalculator.dateTime].storage.value
        status.massSalt *= 1_000 * (1 + parameter.dischargeToTurbine)
      }
      
      //   Saltmass = parameter.heatLossConstants0[3]
      
      if parameter.tempInCst[1] > 0 { // it doesnt get in here usually, therefore not updated yet
        status.heatStored = status.heatStored - status.heatLossStorage
          * hourFraction - Plant.heatFlow.storage * hourFraction
        status.heatrel = status.heatStored
          / (Design.layout.storage * HeatExchanger.parameter.SCCHTFheatFlow)
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
              * (parameter.designTemperature.hot - parameter.designTemperature.cold).value
              / (status.massSalt * (parameter.designTemperature.hot
                - parameter.designTemperature.cold).value)
          }
          if status.mass.hot > 0 {
            status.temperatureTank.hot = Temperature((status.massSalt
              * (status.temperature.inlet - status.dTHTF_HotSalt).value
              + status.mass.hot * status.temperatureTank.hot.value)
              / (status.massSalt + status.mass.hot))
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
            * (parameter.designTemperature.hot - parameter.designTemperature.cold).value
            / (status.massSalt * (parameter.designTemperature.hot.value
              - parameter.designTemperature.cold.value))
          if status.mass.hot > 0 {
            status.temperatureTank.hot = Temperature((status.massSalt
              * parameter.designTemperature.hot.value
              + status.mass.hot * status.temperatureTank.hot.value)
              / (status.massSalt + status.mass.hot))
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
          if status.massSalt < 10 {
            status.massSalt = 0
            Plant.heatFlow.storage = status.massSalt
              * (status.hSalt.hot - status.hSalt.cold) / hourFraction / 3_600 / 1_000
            status.mass.hot = minmass
            
            status.mass.cold = status.mass.cold + status.massSalt
            status.heatrel = parameter.dischargeToTurbine
          } else {
            status.mass.cold = status.mass.cold + status.massSalt
            status.heatrel = status.mass.hot * (parameter.designTemperature.hot
              - parameter.designTemperature.cold).value / (status.massSalt *
                (parameter.designTemperature.hot
                  - parameter.designTemperature.cold).value)
          }
          if status.mass.cold > 0 {
            // cold salt is status.temperature.inlet + dTHTF_ColdSalt
            status.temperatureTank.cold = Temperature((status.massSalt
              * (status.temperature.inlet + status.dTHTF_ColdSalt).value
              + status.mass.cold * status.temperatureTank.cold.value)
              / (status.massSalt + status.mass.cold))
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
            * (parameter.designTemperature.hot - parameter.designTemperature.cold).value
            / (status.massSalt * (parameter.designTemperature.hot
              - parameter.designTemperature.cold).value)
          
          status.temperatureTank.cold = Temperature(
            (status.massSalt * parameter.designTemperature.cold.value
            + status.mass.cold * status.temperatureTank.cold.value)
            / (status.massSalt + status.mass.cold))
          
        case .freezeProtection:
          let splitfactor = parameter.HTF == .hiXL ? 0.4 : 1
          
          status.massSalt = SolarField.parameter.antiFreezeFlow * hourFraction * 3_600
          status.temperatureTank.cold = Temperature(
            (splitfactor * status.massSalt
            * PowerBlock.status.temperature.outlet.value
            + status.mass.cold * status.temperatureTank.cold.value)
            / (splitfactor * status.massSalt + status.mass.cold))
          status.StoTcoldTout = splitfactor * status.temperatureTank.cold.value
            + (1 - splitfactor) * PowerBlock.status.temperature.outlet.value
          // PowerBlock.status.temperature.outlet  = storage.temperatureTank.cold
          
        case .no:
          if parameter.TturbIterate < -90,
            status.temperatureTank.cold < parameter.designTemperature.cold,
            PowerBlock.status.temperature.outlet > status.temperatureTank.cold,
            status.mass.cold > 0 {
            status.massSalt = PowerBlock.status.massFlow * hourFraction * 3_600
            status.temperatureTank.cold = Temperature(
              (status.massSalt * PowerBlock.status.temperature.outlet.value
              + status.mass.cold * status.temperatureTank.cold.value)
              / (status.massSalt + status.mass.cold))
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
            status.temperatureTank.hot = Temperature((-salt.heatCapacity[0]
              + (salt.heatCapacity[0] ** 2
              - 4 * (salt.heatCapacity[1] * 0.5)
                * (-350.5536 - status.hSalt.hot)) ** 0.5)
              / (2 * salt.heatCapacity[1] * 0.5).toKelvin)
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
            status.temperatureTank.cold = Temperature((-salt.heatCapacity[0]
              + (salt.heatCapacity[0] ** 2
              - 4 * (salt.heatCapacity[1] * 0.5)
                * (-350.5536 - status.hSalt.cold)) ** 0.5)
              / (2 * salt.heatCapacity[1] * 0.5).toKelvin)
          }
        }
      }
      
      if Plant.heatFlow.storage < 0 {
        if case .freezeProtection = status.operationMode {
          // FIXME PowerBlock.status.temperature.outlet // = PowerBlock.status.temperature.outlet
        } else if case .charging = status.operationMode {
          // if status.operationMode = "IN" added to avoid Tmix during TES discharge (valid for indirect storage), check!
          PowerBlock.status.temperature.outlet = htf.mixingTemperature(
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
  static func operate(_ storage: inout Storage.PerformanceData,
                      powerBlock: inout PowerBlock.PerformanceData,
                      heater: inout Heater.PerformanceData,
                      solarField: inout SolarField.PerformanceData,
                      availableFuel: inout Double,
                      fuel: inout FuelConsumption,
                      heatFlow: inout HeatFlow) {
    
    var heatdiff = 0.0
    let time = PerformanceCalculator.dateTime
    if Design.hasGasTurbine {
      powerBlock.massFlow = HeatExchanger.parameter.SCCHTFheatFlow /
        (htf.heatTransfered(
          HeatExchanger.parameter.temperature.htf.inlet.max,
          HeatExchanger.parameter.temperature.htf.outlet.max) / 1_000)
      heatdiff = heatFlow.production - HeatExchanger.parameter.SCCHTFheatFlow
    } else {
      
      if case .always = Storage.parameter.strategy {
        // if demand is selected, variable is called Alw but calculation is done as demand, error comes from older version // "Dem"
        powerBlock.massFlow = heatFlow.demand
          / (htf.heatTransfered(
            HeatExchanger.parameter.temperature.htf.inlet.max,
            HeatExchanger.parameter.temperature.htf.outlet.max) / 1_000)
        
        if powerBlock.massFlow < 0 { // to avoid negative massfows
          heatdiff = 0
          powerBlock.massFlow = solarField.header.massFlow
        }
      } else {
        heatdiff = heatFlow.production - heatFlow.demand // [MW]
        if Storage.parameter.heatExchangerRestrictedMin {
          // added to avoid input to storage lower than minimal HX// s capacity
          heatFlow.toStorageMin = Storage.parameter.heatExchangerMinCapacity
            * HeatExchanger.parameter.SCCHTFheatFlow
            * (1 - Storage.parameter.massFlow / SolarField.parameter.massFlow.max)
            / (Storage.parameter.massFlow / SolarField.parameter.massFlow.max)
          
          if heatdiff > 0 && heatdiff < heatFlow.toStorageMin {
            heatFlow.demand = heatFlow.demand - (heatFlow.toStorageMin - heatdiff)
            powerBlock.massFlow = heatFlow.demand
              / htf.heatTransfered(
                HeatExchanger.parameter.temperature.htf.inlet.max,
                HeatExchanger.parameter.temperature.htf.outlet.max) / 1_000
            heatdiff = heatFlow.toStorageMin
          }
        }
      }
      if case .demand = Storage.parameter.strategy {
        // if Always is selected, variable is called "Dem" but calculation is done as "Always", error comes from older version // "Alw" {
        powerBlock.massFlow = HeatExchanger.parameter.SCCHTFheatFlow
          / (htf.heatTransfered(
            HeatExchanger.parameter.temperature.htf.inlet.max,
            HeatExchanger.parameter.temperature.htf.outlet.max) / 1_000)
        
        if powerBlock.massFlow < 0.0 { // to avoid negative massfows
          heatdiff = 0
          powerBlock.massFlow = solarField.header.massFlow
        } else {
          heatdiff = heatFlow.production - HeatExchanger.parameter.SCCHTFheatFlow
          // changed back as heatFlow.production - HeatExchanger.parameter.SCCHTFheat// heatFlow.demand     // [MW]
          if Storage.parameter.heatExchangerRestrictedMin {
            // added to avoid input to storage lower than minimal HX// s capacity
            heatFlow.toStorageMin = HeatExchanger.parameter.SCCHTFheatFlow
              * (1 - Storage.parameter.massFlow / SolarField.parameter.massFlow.max)
              / (Storage.parameter.massFlow / SolarField.parameter.massFlow.max)
            
            if heatdiff > 0 && heatdiff < heatFlow.toStorageMin {
              powerBlock.massFlow = (HeatExchanger.parameter.SCCHTFheatFlow
                - (heatFlow.toStorageMin - heatdiff))
                / (htf.heatTransfered(
                  HeatExchanger.parameter.temperature.htf.inlet.max,
                  HeatExchanger.parameter.temperature.htf.outlet.max) / 1_000)
              heatdiff = heatFlow.toStorageMin
            }
          }
        }
      }

      if case .shifter = Storage.parameter.strategy { // Storage.parameter.strategy = "Ful" // Booster or Shifter
        // new calculation of shifter, old kept and commented below this:
        if time.month < Storage.parameter.startexcep
          || time.month > Storage.parameter.endexcep {
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
            time.hour < 17 {
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
            solarField.header.massFlow >= powerBlock.massFlow {
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
                * Plant.availability[time].powerBlock.value / SteamTurbine.efficiency // limit HX capacity?
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
        solarField.header.massFlow >= powerBlock.massFlow {

        Storage.operate(&storage, mode: .charging, solarField: &solarField, heatFlow: &heatFlow)
        //Storage.operate(mode: .charging, Storage.parameter.heatExchanger * heatdiff, powerBlock.massFlow, hourFraction, heatFlow.storage, electricalParasitics.storage, storage.mass.hot, storage.temperatureTank.cold, storage.mass.cold, XZ)
        powerBlock.temperature.inlet = solarField.header.temperature.outlet
        // FIXME powerBlock.massFlow = powerBlock.massFlow
      } else { // heat cannot be stored
        Storage.operate(&storage, mode: .noOperation, solarField: &solarField, heatFlow: &heatFlow)
        //Storage.operate(mode: .noOperation, heatdiff, powerBlock.massFlow, heatFlow.storage, electricalParasitics.storage, storage.mass.hot, storage.temperatureTank.cold, storage.mass.cold, XZ)
        powerBlock.temperature.inlet = solarField.header.temperature.outlet
      }
      
    } else { // Energy deficit
      var peakTariff: Bool
      // check when to discharge TES
      if case .shifter = Storage.parameter.strategy { // only for Shifter
        if time.month < Storage.parameter.startexcep || time.month > Storage.parameter.endexcep { // Oct to March
          peakTariff = time.hour >= Storage.parameter.dischrgWinter
        } else { // April to Sept
          peakTariff = time.hour >= Storage.parameter.dischrgSummer
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
        if powerBlock.massFlow < solarField.header.massFlow { // there are cases, during cloudy days when OpMode is "EX" although massflow in SOF is higher that in PB.
        }
        Storage.operate(&storage, mode: .ex, solarField: &solarField, heatFlow: &heatFlow)
        //Storage.operate(mode: .ex, heatdiff, powerBlock.massFlow, heatFlow.storage, heatLossStorage, electricalParasitics.storage, storage.mass.hot, storage.temperatureTank.cold, storage.mass.cold, XZ)
        if case .freezeProtection = solarField.operationMode {
          powerBlock.temperature.inlet = htf.mixingTemperature(
            outlet: solarField, with: storage)
          powerBlock.massFlow = Storage.parameter.heatExchangerEfficiency
            * storage.massFlow + solarField.header.massFlow //
        } else if case .operating = solarField.operationMode { // eingefügt  IF-abrage eingefügt
          powerBlock.temperature.inlet = htf.mixingTemperature(
            outlet: solarField, with: storage)
          powerBlock.massFlow = Storage.parameter.heatExchangerEfficiency
            * storage.massFlow + solarField.header.massFlow //
        } else if storage.massFlow > 0 {
          powerBlock.temperature.inlet = storage.temperature.outlet
          powerBlock.massFlow = Storage.parameter.heatExchangerEfficiency * storage.massFlow
        } else {
          powerBlock.massFlow = 0
        }
        
      } else { // heat can only be provided with heater on
        let time = PerformanceCalculator.dateTime
        if (Storage.parameter.FC == 0 && Collector.status.parabolicElevation < 0.011
          && storage.heatrel < Storage.parameter.chargeTo
          && !(powerBlock.temperature.inlet.value > 665)
          && SteamTurbine.status.isMaintained
          && (time.month < Storage.parameter.FCstopM
            || (time.month == Storage.parameter.FCstopM
              && time.day < Storage.parameter.FCstopD)
            || ((time.month == Storage.parameter.FCstartM
              && time.day > Storage.parameter.FCstartD)
              || time.month > Storage.parameter.FCstartM)
            && (time.month < Storage.parameter.FCstopM2
              || (time.month == Storage.parameter.FCstopM2
                && time.day < Storage.parameter.FCstopD2)
              || (time.month > Storage.parameter.FCstartM2
                || (time.month == Storage.parameter.FCstartM2
                  && time.day > Storage.parameter.FCstartD2))))
          && Fuelmode != "predefined") || (Fuelmode == "predefined" && availableFuel > 0) {
          Heater.status.operationMode = .freezeProtection
          if Fuelmode != "predefined" {
            let availableFuel = Double.greatestFiniteMagnitude
            heatFlow.heater = Heater.operate(&heater, demand: 0,
                                             availableFuel: availableFuel,
                                             fuelFlow: &fuel.heater)
            Plant.electricalParasitics.heater = Heater.parasitics
            powerBlock.massFlow = Heater.status.massFlow
            Storage.operate(&storage, mode: .freezeProtection, solarField: &solarField, heatFlow: &heatFlow)
            // FIXME powerBlock.massFlow = powerBlock.massFlow
            powerBlock.temperature.inlet = storage.temperature.outlet
            // check why to circulate HTF in SF
            Plant.electricalParasitics.solarField = SolarField.parameter.antiFreezeParastics
          } else if case .freezeProtection = solarField.operationMode,
            storage.heatrel > -0.35 && Storage.parameter.FP == 0 {
            
            Storage.operate(&storage, mode: .freezeProtection, solarField: &solarField, heatFlow: &heatFlow)
            //Storage.operate(mode: .freezeProtection, date: heatdiff, heatFlow: powerBlock.massFlow, status: heatFlow.storage)
          } else {
            Storage.operate(&storage, mode: .noOperation, solarField: &solarField, heatFlow: &heatFlow)
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
          + 0.5 * salt.heatCapacity[1] * (storage.temperature.inlet.value
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
          * (storage.temperature.inlet.value
          - storage.dTHTF_HotSalt.toCelsius) + 0.5
          * salt.heatCapacity[1] * (storage.temperature.inlet.value
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
          solarField.header.massFlow >= powerBlock.massFlow { // 1.1
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
