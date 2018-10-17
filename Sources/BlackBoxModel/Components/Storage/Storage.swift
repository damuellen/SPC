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

public enum Storage: Component {
  /// Contains all data needed to simulate the operation of the storage
  public struct PerformanceData: HeatCycle {
    var operationMode: OperationMode
    var temperature: (inlet: Temperature, outlet: Temperature)
    var dT_HTFsalt: (cold: Double, hot: Double)
    var temperatureTank: (cold: Temperature, hot: Temperature)
    var massFlow: MassFlow
    var minMassFlow: MassFlow = 0.0
    var salt: Salt = Salt()
    
    struct Salt {
      var massFlow: MassFlows = .init()
      var heat: Heat = .init()
      struct MassFlows {
        var calculated: MassFlow = .zero
        var cold: MassFlow = .zero
        var hot: MassFlow = .zero
      }
      struct Heat {
        var cold: Double = 0
        var hot: Double = 0
        var available: Double {
          return hot - cold
        }
      }
      
      fileprivate mutating func calculateFlow(
        cold: Temperature, hot: Temperature, thermal: Double)
      {
        heat.cold = parameter.HTF.properties.specificHeat(cold)
        heat.hot = parameter.HTF.properties.specificHeat(hot)
        
        massFlow.calculated.rate = thermal
          / heat.available * hourFraction * 3_600 * 1_000
      }
    }
    
    var antiFreezeTemperature: Double = 0.0
    var heat: Double = 0.0
    var charge: Ratio = 0.0
    var energyStored: Double = 0.0
    var heatLossStorage: Double = 0.0
    var heatProductionLoad: Double = 0.0
    var dischargeLoad: Double = 0.0
    
    public enum OperationMode: String, CustomStringConvertible {
      case noOperation, discharge
      case preheat, charging, fossilCharge, freezeProtection
      
      public var description: String {
        return rawValue
      }
      
      var isFreezeProtection: Bool {
        return self ~= .freezeProtection
      }
    }
    
    mutating func calculateMassFlow(
      thermalPower: Double,
      htf: HeatTransferFluid = SolarField.parameter.HTF) {
      adjust(massFlow: thermalPower / htf.heatAdded(
        temperature.outlet, temperature.inlet) * 1_000)
    }
  }
  static var maxLoad = Ratio(1)
  
  static let initialState = Storage.PerformanceData(
    operationMode: .noOperation,
    temperature: (Simulation.initialValues.temperatureOfHTFinPipes,
                  Simulation.initialValues.temperatureOfHTFinPipes),
    dT_HTFsalt: (0.0, 0.0), temperatureTank: (566.0, 666.0),
    massFlow: 0.0,  minMassFlow: 0.0,
    salt: Storage.PerformanceData.Salt(),
    antiFreezeTemperature: 0, heat: 0, charge: 0.0, energyStored: 0,
    heatLossStorage: 0, heatProductionLoad: 0, dischargeLoad: 0)
  
  public static var parameter: Parameter = ParameterDefaults.st
  
  private static func minMassFlow(
    _ storage: Storage.PerformanceData
    ) -> MassFlow {
    switch Storage.parameter.definedBy {
    case .hours:
      let minMassFlow = Design.layout.storage * parameter.dischargeToTurbine
        * HeatExchanger.parameter.sccHTFheat * 1_000 * 3_600
        / storage.salt.heat.available
      
      HeatExchanger.parameter.temperature.h2o.inlet.max = Temperature(
        parameter.startLoad.hot * Design.layout.storage
          * HeatExchanger.parameter.sccHTFheat * 1_000 * 3_600
          / storage.salt.heat.available + minMassFlow
      ) // Factor 1.1
      HeatExchanger.parameter.temperature.h2o.inlet.min = Temperature(
        parameter.startLoad.cold * Design.layout.storage
          * HeatExchanger.parameter.sccHTFheat * 1_000 * 3_600
          / storage.salt.heat.available + minMassFlow
      )
      return MassFlow(minMassFlow / 1000)
      
    case .cap:
      let minMassFlow = Design.layout.storage_cap
        * parameter.dischargeToTurbine * 1_000 * 3_600
        / storage.salt.heat.available
      
      HeatExchanger.parameter.temperature.h2o.inlet.max = Temperature(
        parameter.startLoad.hot * Design.layout.storage_cap * 1_000 * 3_600
          / storage.salt.heat.available + minMassFlow
      ) // Factor 1.1
      HeatExchanger.parameter.temperature.h2o.inlet.min = Temperature(
        parameter.startLoad.cold * Design.layout.storage_cap * 1_000 * 3_600
          / storage.salt.heat.available + minMassFlow
      )
      return MassFlow(minMassFlow / 1000)
      
    case .ton:
      let minMassFlow = Design.layout.storage_ton * parameter.dischargeToTurbine
      HeatExchanger.parameter.temperature.h2o.inlet.max = Temperature(1_000 *
        (parameter.startLoad.hot * Design.layout.storage_ton + minMassFlow)
      )
      HeatExchanger.parameter.temperature.h2o.inlet.min = Temperature(1_000 *
        (parameter.startLoad.cold * Design.layout.storage_ton + minMassFlow)
      )
      return MassFlow(minMassFlow / 1000)
    }
  }
  
  /// Calculates the parasitics of the TES
  private static func parasitics(_ status: inout PerformanceData) -> Double {
    var parasitics = 0.0
    var timeminutessum = 0
    var timeminutesold = 0
    let solarField = SolarField.parameter
    let heatExchanger = HeatExchanger.parameter
    let storage = Storage.parameter
    
    let time = TimeStep.current
    if storage.auxConsumptionCurve {
      // old model:
      let rohMean = solarField.HTF.density(status.averageTemperature)
      let rohDP = solarField.HTF.density(
        Temperature.average(heatExchanger.temperature.htf.inlet.max,
                            heatExchanger.temperature.htf.outlet.max)
      )
      let pressureLoss = parameter.pressureLoss * rohDP / rohMean
        * (status.massFlow.share(of: parameter.massFlow).ratio) ** 2
      
      parasitics = pressureLoss * status.massFlow.rate / rohMean
        / parameter.pumpEfficiency / 10e6
      
      if case .discharge = status.operationMode {
        // added as user input, by no input stoc.DischrgParFac = 2
        parasitics = parasitics * parameter.DischrgParFac
        timeminutessum = 0
      } else if case .noOperation = status.operationMode {
        
        if time.minute != timeminutesold { // formula changed
          if time.minute == 0 { // new hour
            timeminutessum += 60 + time.minute - timeminutesold
            // timeminutessum + 5
          } else {
            timeminutessum += time.minute - timeminutesold
          }
        }
        let ht = zip(parameter.heatTracingTime, parameter.heatTracingPower)
        for (_, power) in ht {
           // FIXME: if timeminutessum > time * 60 {
           parasitics += power / 1_000
                // }
        }
      } else {
        // parasitics = parasitics // Indien 1.5
        timeminutessum = 0
      }
      timeminutesold = time.minute
      return parasitics
    } else { // new model
      // all this shall be done only one time
      // definedBy internal parameters
      /// exponent for nth order decay of aux power consumption
      let expn = 3.0
      /// accounting for different head for certain charge levels
      /// (e.g. charge mode 0% level -> 35 % less Aux. Power)
      let level = 0.35
      /// Aux. Power for low charge level and low flow ->20% less
      let level2 = 0.2
      /// min aux. power consumption for very low salt flows in charge mode
      let lowCh = 0.12
      /// min aux. power consumption for very low salt flows in discharge mode
      let lowDc = 0.25
      /// TES parasitics for design case during discharge
      let designAuxEX = 0.29
      /// TES parasitics for design case during charge
      let designAuxIN = 0.57
      

      if case .noOperation = status.operationMode {
        parasitics = 0
        let timeminutessum = 0.0
        if time.minute != timeminutesold {
          if time.minute == 0 { // new hour
// FIXME: timeminutessum = timeminutessum + 60 + time.minutes! - timeminutesold // timeminutessum + 5
          } else {
// FIXME: timeminutessum = timeminutessum + time.minutes! - timeminutesold
          }
        }
        // new heat tracing defined by user:
        let ht = zip(parameter.heatTracingTime, parameter.heatTracingPower)
        for (time, pow) in ht {
          if timeminutessum > time * 60 {
            parasitics += pow / 1_000
          }
        }
        return parasitics
      }
      
      // calculate design salt massflows:
      status.salt.heat.cold = parameter.HTF.properties.specificHeat(
        parameter.designTemperature.cold
      )
      status.salt.heat.hot = parameter.HTF.properties.specificHeat(
        parameter.designTemperature.hot
      )

      if case .discharge = status.operationMode {
        
        let QoutLoad = parameter.fixedDischargeLoad == 0
          ? 0.97 : parameter.fixedDischargeLoad
        let htf = SolarField.parameter.HTF
        let designDischarge = (((
          (solarField.massFlow.max - parameter.massFlow).rate * QoutLoad)
          / parameter.heatExchangerEfficiency) * htf.heatAdded(
            parameter.designTemperature.hot - status.dT_HTFsalt.hot,
            parameter.designTemperature.cold - status.dT_HTFsalt.cold) / 1_000)
          * parameter.heatExchangerEfficiency // design charging power
        
        let massFlowDischarging = designDischarge
          / status.salt.heat.available * hourFraction * 3_600 * 1_000
        
        let saltFlowRatio = status.salt.massFlow.calculated.rate
          / massFlowDischarging
        parasitics = ((1 - lowDc) * designAuxEX
          * saltFlowRatio ** expn + lowDc * designAuxEX)
          * ((1 - level) + level * status.charge.ratio)
          * ((1 - level2) + level2 * saltFlowRatio)
      } else if case .charging = status.operationMode {
        
        let htf = SolarField.parameter.HTF
        let designCharge = (parameter.massFlow.rate * htf.heatAdded(
          parameter.designTemperature.hot + status.dT_HTFsalt.hot,
          parameter.designTemperature.cold + status.dT_HTFsalt.cold) / 1_000)
          * parameter.heatExchangerEfficiency
        
        let massFlowCharging = designCharge
          / status.salt.heat.available * hourFraction * 3_600 * 1_000
        
        let saltFlowRatio = status.salt.massFlow.calculated.rate
          / massFlowCharging
        parasitics = ((1 - lowCh) * designAuxIN
          * saltFlowRatio ** expn + lowCh * designAuxIN)
          * ((1 - level) + level * status.charge.ratio)
          * ((1 - level2) + level2 * saltFlowRatio)
      }
      
      timeminutessum = 0
      
      timeminutesold = time.minute
      return parasitics
    }
  }
  
  private static func tankTemperature(_ specificHeat: Double) -> Temperature {
    return Temperature((-parameter.HTF.properties.heatCapacity[0]
      + (parameter.HTF.properties.heatCapacity[0] ** 2
        - 4 * (parameter.HTF.properties.heatCapacity[1] * 0.5)
        * (-350.5536 - specificHeat)) ** 0.5)
      / (2 * parameter.HTF.properties.heatCapacity[1] * 0.5))
  }
  
  private static func heatlosses(storage: inout Storage.PerformanceData) {
    
    if storage.salt.massFlow.cold.rate
      > parameter.dischargeToTurbine * storage.salt.massFlow.calculated.rate
    {
      // enthalpy before cooling down
      storage.salt.heat.cold = parameter.HTF.properties.specificHeat(
        storage.temperatureTank.cold
      )

      let coldTankHeatLoss = parameter.heatLoss.cold
        * (storage.temperatureTank.cold.kelvin)
        / (parameter.designTemperature.cold.kelvin - 27)
      // enthalpy after cooling down
      storage.salt.heat.cold -= coldTankHeatLoss * Double(period)
        / storage.salt.massFlow.cold.rate
      // temp after cool down
      storage.temperatureTank.cold = tankTemperature(storage.salt.heat.cold)
    }
    
    if storage.salt.massFlow.hot.rate > 0 {
      // parameter.dischargeToTurbine * Saltmass {
      // enthalpy before cooling down
      storage.salt.heat.hot = parameter.HTF.properties.specificHeat(
        storage.temperatureTank.hot
      )

      let hotTankHeatLoss = parameter.heatLoss.hot
        * (storage.temperatureTank.hot.kelvin)
        / (parameter.designTemperature.hot.kelvin - 27)
      // enthalpy after cooling down
      storage.salt.heat.hot -= hotTankHeatLoss * Double(period)
        / storage.salt.massFlow.hot.rate
      // temp after cool down
      storage.temperatureTank.hot = tankTemperature(storage.salt.heat.hot)
    }
  }
  
  static func update(_ status: inout Plant.PerformanceData,
                     demand: Double, fuelAvailable: Double,
                     result: (Status<PerformanceData>) -> ())
  {
    var demand = demand
    let production = Plant.thermal.production.megaWatt
    switch parameter.strategy {
    case .always:
      strategyAlways(&status.storage, &status.powerBlock,
                     solarFieldMassFlow: status.solarField.massFlow,
                     production: production, demand: &demand)
    case .demand :
      strategyDemand(&status.storage, &status.powerBlock,
                     solarFieldMassFlow: status.solarField.massFlow,
                     production: production)
    // parameter.strategy = "Ful" // Booster or Shifter
    case .shifter:
      strategyShifter(&status.storage, &status.powerBlock,
                      solarFieldMassFlow: status.solarField.massFlow,
                      production: production, demand: &demand)
    }
    
    // **************************  Energy surplus  *****************************
    if status.storage.heat > 0 {
      var supply: Double
      var parasitics: Double
      if status.storage.charge.ratio < parameter.chargeTo
      //  status.solarField.massFlow.rate >= status.powerBlock.massFlow.rate
      {
        (supply, parasitics) = Storage.update(&status, mode: .charging)
      } else { // heat cannot be stored
        (supply, parasitics) = Storage.update(&status, mode: .noOperation)
      }
      status.powerBlock.setTemperature(inlet:
        status.solarField.temperature.outlet
      )
      result((supply, demand, parasitics, 0, status.storage))
      return
    }
    
    // **************************  Energy deficit  *****************************
    var peakTariff: Bool
    let time = TimeStep.current
    // check when to discharge TES
    if case .shifter = parameter.strategy { // only for Shifter
      if time.month < parameter.startexcep
        || time.month > parameter.endexcep
      { // Oct to March
        peakTariff = time.hour >= parameter.dischrgWinter
      } else { // April to Sept
        peakTariff = time.hour >= parameter.dischrgSummer
      }
    } else { // not shifter
      peakTariff = true // dont care about time to discharge
    }
    #warning("The implementation here differs from PCT")
    if peakTariff, status.storage.operationMode.isFreezeProtection == false,
      status.storage.charge.ratio > parameter.dischargeToTurbine,
      status.storage.heat < 1 * parameter.heatdiff * demand
    { // added dicharge only after peak hours
      // previous discharge condition commented:
      // if storage.heatrel > parameter.dischargeToTurbine
      // && storage.operationMode != .freezeProtection
      // && heatdiff < -1 * parameter.heatdiff * thermal.demand {
      // Discharge directly!! // 04.07.0 -0.25&& heatdiff < -0.25 * thermal.dem
      if status.powerBlock.massFlow < status.solarField.massFlow {
        // there are cases, during cloudy days when mode .discharge although
        // massflow in SOF is higher that in PB.
      }
      var supply: Double
      var parasitics: Double
      (supply, parasitics) = Storage.update(&status, mode: .discharge)
      
      if [.operating, .freezeProtection]
        .contains(status.solarField.operationMode)
      {
        status.powerBlock.temperature.inlet =
          SolarField.parameter.HTF.mixingTemperature(
            outlet: status.solarField, with: status.storage
        )
        status.powerBlock.merge(massFlows: status.solarField, status.storage)
        status.powerBlock.massFlow.adjust(with:
          parameter.heatExchangerEfficiency
        )
      } else if status.storage.massFlow.isNearZero == false {
        status.powerBlock.setTemperature(inlet:
          status.storage.temperature.outlet
        )
        status.powerBlock.massFlow = status.storage.massFlow
        status.powerBlock.massFlow.adjust(with:
          parameter.heatExchangerEfficiency
        )
      } else {
        status.powerBlock.massFlow = .init() // set to zero
      }
      result((supply, demand, parasitics, 0, status.storage))
      return
    }

    // heat can only be provided with heater on
    if (parameter.FC == 0 && status.collector.parabolicElevation < 0.011
      && status.storage.charge.ratio < parameter.chargeTo
      && status.powerBlock.inletTemperature > 665
      && Storage.isFossilChargingAllowed(at: time)
      && Fuelmode.isPredefined == false)
      || (Fuelmode.isPredefined && fuelAvailable > 0)
    {
      status.heater.operationMode = .freezeProtection
      var supply: Double
      var parasitics: Double
      var fuel = 0.0
      if Fuelmode.isPredefined == false {
        
        Heater.update(status, demand: demand, fuelAvailable: fuelAvailable)
        { result in
          status.heater = result.status
          fuel = result.fuel
          Plant.thermal.heater.megaWatt = result.supply
          //electricalParasitics.heater = result.parasitics
        }

        #warning("Storage.parasitics")
        // Plant.electricalParasitics.heater = result.parasitics
        
        status.powerBlock.massFlow = status.heater.massFlow
        
        (supply, parasitics) = Storage.update(&status, mode: .freezeProtection)
        
        status.powerBlock.setTemperature(inlet:
          status.storage.temperature.outlet
        )
        // check why to circulate HTF in SF
        #warning("Storage.parasitics")
// FIXME: Plant.electricalParasitics.solarField = solarField.antiFreezeParastics
      } else if case .freezeProtection = status.solarField.operationMode,
        status.storage.charge > -0.35 && parameter.FP == 0
      {
        (supply, parasitics) = Storage.update(&status, mode: .freezeProtection)
      } else {
        (supply, parasitics) = Storage.update(&status, mode: .noOperation)
      }
      result((supply, demand, parasitics, fuel, status.storage))
      return
    }
    fatalError()
  }
  
  private static func strategyAlways(
    _ storage: inout PerformanceData,
    _ powerBlock: inout PowerBlock.PerformanceData,
    solarFieldMassFlow: MassFlow,
    production: Double,
    demand: inout Double)
  {
    let solarField = SolarField.parameter
    let heatExchanger = HeatExchanger.parameter
    
    let heatTransfer = SolarField.parameter.HTF.heatAdded(
      heatExchanger.temperature.htf.inlet.max,
      heatExchanger.temperature.htf.outlet.max) / 1_000

    powerBlock.adjust(massFlow: demand / heatTransfer)
    
    if powerBlock.massFlow.rate < 0 { // to avoid negative massflows
      storage.heat = 0
      powerBlock.massFlow = solarFieldMassFlow
      return
    }
    
    storage.heat = production  // - demand [MW]
    
    if parameter.heatExchangerRestrictedMin {
      // added to avoid input to storage lower than minimal HX's capacity
      let toStorageMin = parameter.heatExchangerMinCapacity
        * heatExchanger.sccHTFheat
        * (1 - parameter.massFlow.rate / solarField.massFlow.max.rate)
        / (parameter.massFlow.rate / solarField.massFlow.max.rate)
      
      if case 0..<toStorageMin = storage.heat {
        demand -= (toStorageMin - storage.heat)
        powerBlock.adjust(massFlow: demand / heatTransfer)
        storage.heat = toStorageMin
      }
    }
  }
  
  private static func strategyDemand(
    _ storage: inout PerformanceData,
    _ powerBlock: inout PowerBlock.PerformanceData,
    solarFieldMassFlow: MassFlow,
    production: Double)
  {
    let solarField = SolarField.parameter
    let heatExchanger = HeatExchanger.parameter

    let heatTransfer = SolarField.parameter.HTF.heatAdded(
      heatExchanger.temperature.htf.inlet.max,
      heatExchanger.temperature.htf.outlet.max) / 1_000

    powerBlock.adjust(massFlow: heatExchanger.sccHTFheat / heatTransfer)
    
    if powerBlock.massFlow < 0.0 { // to avoid negative massflows
      storage.heat = 0
      powerBlock.massFlow = solarFieldMassFlow
      return
    }
    
    storage.heat = production - heatExchanger.sccHTFheat
    
    if parameter.heatExchangerRestrictedMin {
      // added to avoid input to storage lower than minimal HXs capacity
      let toStorageMin = heatExchanger.sccHTFheat
        * (1 - parameter.massFlow.rate / solarField.massFlow.max.rate)
        / (parameter.massFlow.rate / solarField.massFlow.max.rate)
      
      if case 0..<toStorageMin = storage.heat {
        powerBlock.adjust(massFlow: (heatExchanger.sccHTFheat
          - (toStorageMin - storage.heat)) * 1_000 / heatTransfer
        )
        storage.heat = toStorageMin
      }
    }
  }
  
  private static func strategyShifter(
    _ storage: inout PerformanceData,
    _ powerBlock: inout PowerBlock.PerformanceData,
    solarFieldMassFlow: MassFlow,
    production: Double,
    demand: inout Double)
  {
    let steamTurbine = SteamTurbine.parameter
    let heatExchanger = HeatExchanger.parameter
    
    let heatTransfer = SolarField.parameter.HTF.heatAdded(
      heatExchanger.temperature.htf.inlet.max,
      heatExchanger.temperature.htf.outlet.max) / 1_000

    let time = TimeStep.current
    if time.month < parameter.startexcep || time.month > parameter.endexcep {
      storage.heatProductionLoad = parameter.heatProductionLoadWinter
      if dniDay > parameter.badDNIwinter * 1_000 {
        // sunny day, TES can be fully charged also by running TB at full load
        storage.heatProductionLoad = 1
      }
    } else {
      storage.heatProductionLoad = parameter.heatProductionLoadSummer
      if dniDay > parameter.badDNIsummer * 1_000 {
        // sunny day, TES can be fully charged also by running TB at full load
        storage.heatProductionLoad = 1
      }
    }
    
    if production > 0 { // Qsol > 0
      if production < demand,
        storage.charge.ratio < parameter.chargeTo,
        time.hour < 17
      {
        // Qsol not enough for POB demand load (e.g. at the beginning of the day)
        powerBlock.adjust(massFlow: min(
          storage.heatProductionLoad * demand, production) / heatTransfer
        )
        storage.heat = production - min(
          storage.heatProductionLoad * demand,
          production
        )
        // TES gets the rest available
        if parameter.heatExchangerRestrictedMax {
          storage.heat = min(storage.heat, parameter.heatExchangerCapacity)
        } else {
          let value = steamTurbine.power.max / steamTurbine.efficiencyNominal
            / heatExchanger.efficiency
          if storage.heat > value { storage.heat = value }
        }
      } else if production < demand,
        storage.charge.ratio >= parameter.chargeTo
      {
        // Qsol not enough for POB demand load (e.g. at the end of the day) and TES is full
        powerBlock.adjust(massFlow: demand / heatTransfer)
        // send all to POB and if needed discharge TES
        storage.heat = production - demand
        // TES provides the rest available
        // check what if TES is full and POB could get more than 50% of design!!
        if parameter.heatExchangerRestrictedMax {
          storage.heat = max(storage.heat, -parameter.heatExchangerCapacity)
        } else { // signs below changed
          let value = steamTurbine.power.max
            / steamTurbine.efficiencyNominal
            / heatExchanger.efficiency
          if storage.heat > -value { storage.heat = -value }
        }
      } else if production > demand,
        storage.charge.ratio < parameter.chargeTo,
        solarFieldMassFlow >= powerBlock.massFlow
      {
        // more Qsol than needed by POB and TES is not full
        powerBlock.adjust(massFlow:
          (storage.heatProductionLoad * demand)
            / heatTransfer
        )
        // from avail heat cover first 50% of POB demand
        storage.heat = production - (storage.heatProductionLoad * demand)
        // TES gets the rest available
        if parameter.heatExchangerRestrictedMax,
          storage.heat > parameter.heatExchangerCapacity {
          // rest heat to TES is too high, use more heat to POB
          powerBlock.adjust(massFlow:
            (production - parameter.heatExchangerCapacity)
              / heatTransfer
          )
          // from avail heat cover first 50% of POB demand
          // TES gets max heat input
          storage.heat = parameter.heatExchangerCapacity
        }
      }
      return
    }
    if case .hours = parameter.definedBy {
      // It usually doesn't get in here. therefore, not correctly programmed yet
      if production > demand,
        storage.charge.ratio > SteamTurbine.parameter.power.max
          / steamTurbine.efficiencyNominal / Design.layout.storage {
// FIXME:  let (eff, st) = SteamTurbine.efficiency(status, maxLoad: &maxLoad)
//  status.steamTurbine = st
        let eff = 1.0//FIXME
        demand = steamTurbine.power.max
          * Plant.availability.value.powerBlock.ratio / eff
        var heatDiff = production - demand // [MW]
        // power to charge TES rest after operation POB at full load commented
        // heatdiff = max(thermal.production, thermal.demand)
        // maximal power to TES desing POB thermal input (just to check how it works)
        let heat = SteamTurbine.parameter.power.max
          / SteamTurbine.parameter.efficiencyNominal
          / heatExchanger.efficiency
        
        if heatDiff > heat {
          heatDiff = heat // commented in case of degradated powerblock
          // in case of degradated powerblock
          powerBlock.adjust(massFlow:
            (production - heatDiff) / heatTransfer)
        }
      }
    }
  }
  
  /// Calculate thermal power given by TES
  static func calculate(_ tes: PerformanceData) -> (Double, PerformanceData) {
    var storage = tes
    var thermal = storage.massFlow.rate * SolarField.parameter.HTF.heatAdded(
      storage.temperature.outlet, storage.temperature.inlet) / 1_000
    
    // Check if the required heat is contained in TES, if not recalculate
    
    if case .discharge = storage.operationMode {
      storage.salt.calculateFlow(
        cold: storage.temperature.inlet + storage.dT_HTFsalt.cold,
        hot: storage.temperatureTank.hot,
        thermal: thermal)

      if (storage.salt.massFlow.hot - storage.salt.massFlow.calculated)
        < storage.minMassFlow
      {
        // added to avoid negative or too low salt mass
        storage.salt.massFlow.calculated -= storage.salt.massFlow.hot
          - storage.minMassFlow
        
        if storage.salt.massFlow.calculated.rate < 10 {
          storage.salt.massFlow.calculated.rate = 0
        }
        // recalculate thermal power given by TES
        thermal = storage.salt.massFlow.calculated.rate
          * storage.salt.heat.available / hourFraction / 3_600 / 1_000
      }
    }
    
    if case .charging = storage.operationMode {
      storage.salt.calculateFlow(
        cold: storage.temperatureTank.cold,
        hot: storage.temperature.inlet - storage.dT_HTFsalt.hot,
        thermal: -thermal)
      
      if (storage.salt.massFlow.cold - storage.salt.massFlow.calculated)
        < storage.minMassFlow
      {
        storage.salt.massFlow.calculated = storage.salt.massFlow.calculated
          - (-storage.minMassFlow + storage.salt.massFlow.cold)
        
        if storage.salt.massFlow.calculated.rate < 10 {
          storage.salt.massFlow.calculated.rate = 0
        }
        // recalculate thermal power given by TES
        thermal = -storage.salt.massFlow.calculated.rate
          * storage.salt.heat.available / hourFraction / 3_600 / 1_000
      }
    }
    return (thermal, storage)
  }

  static func update(_ status: inout Plant.PerformanceData,
                     mode: PerformanceData.OperationMode,
                     nightHour: Double = 12.0) -> (Double, Double) {
    if status.storage.operationMode != mode {
      let oldMode = status.storage.operationMode
      💬.infoMessage("\(TimeStep.current) Storage mode \(oldMode) -> \(mode)")
      status.storage.operationMode = mode
    }

    func outletTemperature(_ status: Storage.PerformanceData) -> Temperature {
      var temp: Double
      if parameter.temperatureDischarge2[1] > 0 {
        temp = status.charge > 0.5
          ? 1 : parameter.temperatureDischarge2[status.charge]
        temp *= parameter.designTemperature.hot.kelvin
          - parameter.temperatureDischarge[1]
      } else {
        temp = -Temperature.absoluteZeroCelsius
        if status.charge.ratio < 0 {
          temp += parameter.temperatureDischarge[0]
            - (parameter.designTemperature.hot.kelvin
              - status.temperatureTank.hot.kelvin)
        } else {
          temp += parameter.temperatureCharge[0]
            - (parameter.designTemperature.hot.kelvin
              - status.temperatureTank.hot.kelvin)
          // adjust of HTF outlet temp. with status hot tank temp.
        }
      }
      return Temperature(temp)
    }
    /* FIXME: Is this useless code ???
    if Plant.thermal.solar > 0 {
      status.solarField.header.massFlow = status.solarField.massFlow
    } else if case .freezeProtection = status.solarField.operationMode {
      status.solarField.header.massFlow = status.solarField.massFlow
    } else {
      status.solarField.header.massFlow = 0.0
    }
     */
    let thermalPower, parasitics: Double
    switch status.storage.operationMode {
    case .charging:
      thermalPower = storageCharging(
        storage: &status.storage,
        solarField: &status.solarField,
        powerBlock: status.powerBlock
      )
      parasitics = Storage.parasitics(&status.storage)
    case .fossilCharge:
      thermalPower = storageFossilCharge(
        storage: &status.storage,
        powerBlock: &status.powerBlock
      )
      parasitics = Storage.parasitics(&status.storage)
    case .discharge:
      (thermalPower, parasitics) = storageDischarge(
        storage: &status.storage,
        steamTurbine: &status.steamTurbine,
        powerBlock: &status.powerBlock,
        solarField: status.solarField,
        collector: status.collector,
        nightHour: nightHour,
        outletTemperature
      )
    case .preheat:
      (thermalPower, parasitics) =  storagePreheat(
        storage: &status.storage,
        powerBlock: status.powerBlock,
        solarField: status.solarField,
        outletTemperature
      )
    case .freezeProtection:
      storageFreezeProtection(&status)
      thermalPower = 0
      parasitics = Storage.parasitics(&status.storage)
    case .noOperation:
      // Temperatures remain constant
      status.storage.adjust(massFlow: 0)
      thermalPower = 0
      parasitics = 0
    }
    return (thermalPower, parasitics)
    /*Storage Heat Losses:
    if parameter.temperatureCharge.coefficients[1] > 0 {
      if parameter.temperatureCharge.coefficients[2] > 0 {
        let fittedHeatLoss = status.storage.charge.ratio <= 0
          ? parameter.heatlossCst[status.storage.charge]
          : parameter.heatlossC0to1[status.storage.charge]
        
        status.storage.heatLossStorage = fittedHeatLoss
          * 3_600 * 1e-07 * Design.layout.storage // [MW]
      } else {
        status.storage.heatLossStorage = parameter.heatlossCst[0] / 1_000
          * (status.storage.charge.ratio * (parameter.designTemperature.hot
            - parameter.designTemperature.cold).kelvin
            + parameter.designTemperature.cold.kelvin)
          / parameter.designTemperature.hot.kelvin
      }
    } else {
      status.storage.heatLossStorage = 0
    }*/
  }
  
  static func operate(storage: inout Storage.PerformanceData,
                      powerBlock: inout PowerBlock.PerformanceData,
                      steamTurbine: SteamTurbine.PerformanceData,
                      thermal: Double,
                      availability: Availability) -> Double
  {
    let solarField = SolarField.parameter
    
    let htf = solarField.HTF
    var thermalPower = thermal
    storage.salt.heat.cold = parameter.HTF.properties.specificHeat(
      parameter.designTemperature.cold
    )
    storage.salt.heat.hot = parameter.HTF.properties.specificHeat(
      parameter.designTemperature.hot
    )
    
    switch parameter.definedBy {
    case .hours:
      storage.salt.massFlow.calculated.rate = Design.layout.storage
        * availability.value.storage.ratio
        * (1 + parameter.dischargeToTurbine)
        * HeatExchanger.parameter.sccHTFheat * 1_000 * 3_600
        / storage.salt.heat.available
    case .cap:
      storage.salt.massFlow.calculated.rate = Design.layout.storage_cap
        * availability.value.storage.ratio
        * (1 + parameter.dischargeToTurbine) * 1_000 * 3_600
        / storage.salt.heat.available
    case .ton:
      storage.salt.massFlow.calculated.rate = Design.layout.storage_ton
        * availability.value.storage.ratio
        * (1 + parameter.dischargeToTurbine) * 1_000
    }
    //   Saltmass = parameter.heatLossConstants0[3]
    
    if parameter.temperatureCharge[1] > 0 {
      // it doesnt get in here usually, therefore not updated yet
      storage.energyStored -= storage.heatLossStorage
        - thermalPower * hourFraction
      storage.charge.ratio = storage.energyStored
        / (Design.layout.storage * HeatExchanger.parameter.sccHTFheat)
    } else {

      switch storage.operationMode {
      case .charging:
        charging(storage: &storage, thermal: thermalPower)
      case .fossilCharge:
        fossilCharging(storage: &storage, thermal: thermalPower)
      case .discharge:
        thermalPower = discharging(storage: &storage, thermal: thermalPower)
      case .preheat:
        preheating(storage: &storage, thermal: thermalPower)
      case .freezeProtection:
        freezeProtection(storage: &storage, powerBlock)
      // powerBlock.temperature.outlet = storage.temperatureTank.cold
      case .noOperation:
        noOperation(storage: &storage, powerBlock)
      }
      heatlosses(storage: &storage)
    }
    
    if thermalPower < 0 {
      if case .freezeProtection = storage.operationMode {
        // FIXME: powerBlock.temperature.outlet // = powerBlock.temperature.outlet
      } else if case .charging = storage.operationMode {
        // added to avoid Tmix during TES discharge (valid for indirect storage), check!
        powerBlock.temperature.outlet = htf.mixingTemperature(
          outlet: powerBlock, with: storage
        )
      }
    }
    return thermalPower
    // FIXME: HeatExchanger.storage.H2OinTmax = storage.mass.hot
    // HeatExchanger.storage.H2OinTmin = storage.mass.cold
    // HeatExchanger.storage.H2OoutTmax = storage.temperatureTank.hot
    // HeatExchanger.storage.H2OoutTmin = storage.temperatureTank.cold
  }

  private static func charging(
    storage: inout Storage.PerformanceData, thermal: Double)
  {
    storage.salt.calculateFlow(
      cold: storage.temperatureTank.cold,
      hot: storage.temperature.inlet - storage.dT_HTFsalt.hot,
      thermal: -thermal)
    
    storage.salt.massFlow.cold -= storage.salt.massFlow.calculated
    storage.minMassFlow = minMassFlow(storage)
    // avoids negative or too low mass and therefore no heat losses.
    if storage.salt.massFlow.cold < storage.minMassFlow {
      storage.salt.massFlow.calculated -=
        storage.minMassFlow - storage.salt.massFlow.cold
    }
    
    if storage.salt.massFlow.calculated.rate < 10 {
      storage.salt.massFlow.calculated.rate = 0
      
      storage.salt.massFlow.cold = storage.minMassFlow
      storage.salt.massFlow.hot += storage.salt.massFlow.calculated
      
      storage.charge.ratio = parameter.chargeTo
    } else {
      storage.salt.massFlow.hot += storage.salt.massFlow.calculated
      
      let designDeltaT = (parameter.designTemperature.hot
        - parameter.designTemperature.cold).kelvin
      storage.charge.ratio = storage.salt.massFlow.hot.rate * designDeltaT
        / (storage.salt.massFlow.calculated.rate * designDeltaT)
    }
    if storage.salt.massFlow.hot.rate > 0 {
      storage.temperatureTank.hot = Temperature.calculate(
        massFlow1: storage.salt.massFlow.calculated,
        massFlow2: storage.salt.massFlow.hot,
        temperature1: storage.temperature.inlet - storage.dT_HTFsalt.hot,
        temperature2: storage.temperatureTank.hot
      )
    }
  }
  /// - Remark: Only called by: `Storage.update(_:mode:nightHour:)`
  private static func storageCharging(
    storage: inout PerformanceData,
    solarField: inout SolarField.PerformanceData,
    powerBlock: PowerBlock.PerformanceData
    ) -> Double
  {
    let heatExchanger = HeatExchanger.parameter
    let htf = SolarField.parameter.HTF
    
    var thermalPower = 0.0
    storage.setTemperature(inlet: solarField.temperature.outlet)

    storage.massFlow = solarField.massFlow - powerBlock.massFlow
    storage.massFlow.adjust(with: parameter.heatExchangerEfficiency)

    var fittedTemperature: Double
    if parameter.temperatureCharge.coefficients[1] > 0 { // usually = 0
      fittedTemperature = storage.charge < 0.5
        ? 1 : parameter.temperatureCharge2[storage.charge]
      fittedTemperature *= parameter.designTemperature.cold.kelvin
        - parameter.temperatureCharge.coefficients[2]
    } else {
      fittedTemperature = -Temperature.absoluteZeroCelsius
      fittedTemperature += parameter.temperatureCharge.coefficients[0]
        - (parameter.designTemperature.cold
          - storage.temperatureTank.cold).kelvin
    }
    storage.setOutletTemperature(kelvin: fittedTemperature)
    
    thermalPower = storage.massFlow.rate * htf.heatAdded(
      storage.temperature.outlet, storage.temperature.inlet) / 1_000
    
    if parameter.heatExchangerRestrictedMax,
      abs(thermalPower) > parameter.heatExchangerCapacity
    {
      thermalPower *= parameter.heatExchangerCapacity
      
      storage.calculateMassFlow(thermalPower: thermalPower)
      
      // FIXME: powerBlock.massFlow = powerBlock.massFlow
      // added to avoid increase in PB massFlow
      if case .demand = parameter.strategy {
        // too much power from sun, dump
        Plant.thermal.dump.megaWatt += Plant.thermal.production.megaWatt
          - heatExchanger.sccHTFheat + thermalPower
      } else {
        Plant.thermal.dump.megaWatt += Plant.thermal.production.megaWatt
          - Plant.thermal.demand.megaWatt + thermalPower
      }
      solarField.merge(massFlows: powerBlock, storage)
      // reduce HTF massflow in SF
      
      Plant.thermal.solar.megaWatt = solarField.massFlow.rate
        * SolarField.parameter.HTF.heatAdded(
          solarField.temperature.outlet, solarField.temperature.inlet) / 1_000
      Plant.thermal.production = Plant.thermal.solar
    }
    return thermalPower
  }
  
  private static func fossilCharging(
    storage: inout Storage.PerformanceData,
    thermal: Double)
  {
    storage.salt.calculateFlow(
      cold: storage.temperatureTank.cold,
      hot: parameter.designTemperature.hot,
      thermal: -thermal)
    
    storage.salt.massFlow.cold -= storage.salt.massFlow.calculated
    storage.salt.massFlow.hot += storage.salt.massFlow.calculated
    
    let designDeltaT = (parameter.designTemperature.hot
      - parameter.designTemperature.cold).kelvin
    storage.charge.ratio = storage.salt.massFlow.hot.rate * designDeltaT
      / storage.salt.massFlow.calculated.rate * designDeltaT
    
    if storage.salt.massFlow.hot.rate > 0 {
      storage.temperatureTank.hot = Temperature.calculate(
        massFlow1: storage.salt.massFlow.calculated,
        massFlow2: storage.salt.massFlow.hot,
        temperature1: parameter.designTemperature.hot,
        temperature2: storage.temperatureTank.hot
      )
    }
  }
  /// - Remark: Only called by: `Storage.update(_:mode:nightHour:)`
  private static func storageFossilCharge(
    storage: inout PerformanceData,
    powerBlock: inout PowerBlock.PerformanceData
    ) -> Double
  {
    var thermalPower = 0.0
    // heat can be stored
    
    storage.setTemperature(inlet: Heater.parameter.nominalTemperatureOut)
    storage.massFlow = powerBlock.massFlow
    
    var fittedTemperature: Double
    if parameter.temperatureCharge.coefficients[1] > 0 { // usually = 0
      fittedTemperature = storage.charge < 0.5
        ? 1 : parameter.temperatureCharge2[storage.charge]
      fittedTemperature *= parameter.designTemperature.cold.kelvin
        - parameter.temperatureCharge.coefficients[2]
    } else {
      fittedTemperature = -Temperature.absoluteZeroCelsius
      fittedTemperature += parameter.temperatureCharge.coefficients[0]
        - (parameter.designTemperature.cold
          - storage.temperatureTank.cold).kelvin
    }
    storage.setOutletTemperature(kelvin: fittedTemperature)
    
    thermalPower = -storage.massFlow.rate * SolarField.parameter.HTF.heatAdded(
      storage.temperature.outlet, storage.temperature.inlet) / 1_000
    // limit the size of the salt-oil heat exchanger
    if parameter.heatExchangerRestrictedMax,
      abs(thermalPower) > parameter.heatExchangerCapacity
    {
      thermalPower *= parameter.heatExchangerCapacity
      
      storage.calculateMassFlow(thermalPower: thermalPower)
      
      powerBlock.massFlow = storage.massFlow
    }
    return thermalPower
  }
  
  private static func discharging(
    storage: inout Storage.PerformanceData, thermal: Double) -> Double
  {
    var thermalPower = thermal
    
    storage.salt.calculateFlow(
      cold: storage.temperature.inlet + storage.dT_HTFsalt.cold,
      hot: storage.temperatureTank.hot,
      thermal: -thermalPower)

    storage.salt.massFlow.hot -= storage.salt.massFlow.calculated
    
    storage.minMassFlow = minMassFlow(storage)
    // added to avoid negative or too low mass and therefore no heat losses
    if storage.salt.massFlow.hot < storage.minMassFlow {
      storage.salt.massFlow.calculated -=
        storage.minMassFlow - storage.salt.massFlow.hot
      
      if storage.salt.massFlow.calculated.rate < 10 {
        storage.salt.massFlow.calculated.rate = 0
      }
      thermalPower = storage.salt.massFlow.calculated.rate
        * storage.salt.heat.available / hourFraction / 3_600 / 1_000
      
      storage.salt.massFlow.hot = storage.minMassFlow
      storage.salt.massFlow.cold += storage.salt.massFlow.calculated
      
      storage.charge.ratio = parameter.dischargeToTurbine
      
    } else {
      storage.salt.massFlow.cold += storage.salt.massFlow.calculated
      
      let designDeltaT = (parameter.designTemperature.hot
        - parameter.designTemperature.cold).kelvin
      storage.charge.ratio = storage.salt.massFlow.hot.rate * designDeltaT
        / (storage.salt.massFlow.calculated.rate * designDeltaT)
    }
    
    if storage.salt.massFlow.cold.rate > 0 {
      storage.temperatureTank.cold = Temperature.calculate(
        massFlow1: storage.salt.massFlow.calculated,
        massFlow2: storage.salt.massFlow.cold,
        temperature1: storage.temperature.inlet + storage.dT_HTFsalt.cold,
        temperature2: storage.temperatureTank.cold
      )
    }
    return thermalPower
  }
  /// - Remark: Only called by: `Storage.update(_:mode:nightHour:)`
  private static func storageDischarge(
    storage: inout PerformanceData,
    steamTurbine: inout SteamTurbine.PerformanceData,
    powerBlock: inout PowerBlock.PerformanceData,
    solarField: SolarField.PerformanceData,
    collector: Collector.PerformanceData,
    nightHour: Double,
    _ outletTemperature: (PerformanceData) -> Temperature
    ) -> (Double, Double)
  {
    
    var thermalPower = 0.0
    var parasitics = 0.0
    // calculate discharge rate only once per day, directly after sunset
    
    if collector.parabolicElevation > 0
      && collector.parabolicElevation < 3 && parameter.isVariable
    {
      switch parameter.definedBy {
      case .hours:
        storage.energyStored = storage.charge.ratio
          * Design.layout.storage * SteamTurbine.parameter.power.max
          / SteamTurbine.parameter.efficiencyNominal
      case .cap:
        storage.energyStored = storage.charge.ratio * Design.layout.storage_cap
      case .ton:
        storage.salt.heat.cold = parameter.HTF.properties.specificHeat(
          parameter.designTemperature.cold
        )
        storage.salt.heat.hot = parameter.HTF.properties.specificHeat(
          parameter.designTemperature.hot
        )
        let designDeltaT = (parameter.designTemperature.hot
          - parameter.designTemperature.cold).kelvin
        storage.energyStored = storage.charge.ratio
          * Design.layout.storage_ton * storage.salt.heat.available
          * designDeltaT / 3_600
      }
      storage.dischargeLoad = storage.energyStored / nightHour
        / (SteamTurbine.parameter.power.max
          / SteamTurbine.parameter.efficiencyNominal)
      
      if storage.dischargeLoad < parameter.minDischargeLoad {
        storage.dischargeLoad = parameter.minDischargeLoad
      } else if storage.dischargeLoad > 1 {
        storage.dischargeLoad = parameter.fixedDischargeLoad
      }
    }
    // if no previous calculation has been done and TES must be discharged
    if storage.dischargeLoad == 0 && parameter.isVariable {
      switch parameter.definedBy {
      case .hours:
        storage.energyStored = storage.charge.ratio
          * Design.layout.storage * SteamTurbine.parameter.power.max
          / SteamTurbine.parameter.efficiencyNominal
      case .cap:
        storage.energyStored = storage.charge.ratio * Design.layout.storage_cap
      case .ton:
        storage.salt.heat.cold = parameter.HTF.properties.specificHeat(
          parameter.designTemperature.cold
        )
        
        storage.salt.heat.hot = parameter.HTF.properties.specificHeat(
          parameter.designTemperature.hot
        )
        let designDeltaT = (parameter.designTemperature.hot
          - parameter.designTemperature.cold).kelvin
        storage.energyStored = storage.charge.ratio
          * Design.layout.storage_ton * storage.salt.heat.available
          * designDeltaT / 3_600
      }
      storage.dischargeLoad = storage.energyStored / nightHour
        / (SteamTurbine.parameter.power.max
          / SteamTurbine.parameter.efficiencyNominal)
      
      if storage.dischargeLoad < parameter.minDischargeLoad {
        storage.dischargeLoad = parameter.minDischargeLoad
      } else if storage.dischargeLoad > 1 {
        storage.dischargeLoad = 1
      }
    }
    
    switch solarField.operationMode {
    case .freezeProtection:
      storage.adjust(massFlow: storage.dischargeLoad
        * powerBlock.massFlow.rate / parameter.heatExchangerEfficiency)
      
    case .operating where solarField.massFlow.rate > 0:
      // Mass flow is correctd by parameter.Hx this factor is new
      storage.adjust(massFlow: powerBlock.massFlow.rate
        / parameter.heatExchangerEfficiency - solarField.massFlow.rate)
    // * 0.97 deleted after separating combined from storage only operation
    default:
      // if demand < 1 { // only for OU1!?
      //  storage.massFlow = powerBlock.massFlow * 1.3
      //    / parameter.heatExchangerEfficiency
      // for OU1 adjust to demand file and not TES design parameter
      // } else {
      // added to control TES discharge during night
      storage.adjust(massFlow: storage.dischargeLoad
        * powerBlock.massFlow.rate / parameter.heatExchangerEfficiency)
      // }
    }
    
    // used for parasitics
    storage.setTemperature(inlet: powerBlock.temperature.outlet)
    storage.setTemperature(outlet: outletTemperature(storage))
    let htf = SolarField.parameter.HTF
    while true {
      
      thermalPower = storage.massFlow.rate * SolarField.parameter.HTF.heatAdded(
        storage.temperature.outlet, storage.temperature.inlet) / 1_000
      
      if parameter.heatExchangerRestrictedMax,
        abs(thermalPower) > parameter.heatExchangerCapacity
      {
        thermalPower *= parameter.heatExchangerCapacity
        storage.adjust(massFlow: thermalPower
          / htf.temperatureDelta(storage.outletTemperature,
                                 storage.temperature.inlet).kelvin * 1_000)
        #warning("The implementation here differs from PCT")
        if case .freezeProtection = solarField.operationMode {
          
          powerBlock.adjust(massFlow: storage.massFlow.rate
            * parameter.heatExchangerEfficiency / 0.97) // - solarField.massFlow
        } else {
          // Mass flow is correctd by new factor
          powerBlock.adjust(massFlow:
            (storage.massFlow + solarField.massFlow).rate
              * parameter.heatExchangerEfficiency / 0.97
          )
        }
      }
      var maxLoad = 1.0
// FIXME: let (eff, st) = SteamTurbine.efficiency(steamTurbine, maxLoad: &maxLoad)
//  steamTurbine = st
      let eff = 1.0//FIXME
      steamTurbine.load.ratio = min(
        maxLoad, (Plant.thermal.solar.megaWatt + thermalPower)
          / (SteamTurbine.parameter.power.max / eff)
      )
      
      let mixTemp = htf.mixingTemperature(outlet: solarField, with: storage)
      
      let minTemp = Temperature(celsius: 310.0)
      // TurbineTempLoad(SteamTurbine.storage.load)
      
      if mixTemp.kelvin
        > (minTemp - Simulation.parameter.tempTolerance).kelvin * 2
      {
        thermalPower = storage.massFlow.rate * htf.heatAdded(
          storage.temperature.outlet, storage.temperature.inlet) / 1_000

        parasitics =  Storage.parasitics(&storage)
        break
      } else if storage.massFlow.rate <= 0.05 * powerBlock.massFlow.rate {
        thermalPower = 0.0
        storage.operationMode = .noOperation
        parasitics = 0.0
        storage.massFlow = 0.0
        break
      }
      storage.massFlow.adjust(with: 0.97) // reduce 5%
    }
    return (thermalPower, parasitics) // [MW]
  }
  
  private static func preheating(
    storage: inout Storage.PerformanceData, thermal: Double)
  {
    storage.salt.calculateFlow(cold: parameter.designTemperature.cold,
                               hot: storage.temperatureTank.hot,
                               thermal: thermal)
    
    storage.salt.massFlow.cold += storage.salt.massFlow.calculated
    storage.salt.massFlow.hot -= storage.salt.massFlow.calculated
    
    let designDeltaT = (parameter.designTemperature.hot
      - parameter.designTemperature.cold).kelvin
    storage.charge.ratio = storage.salt.massFlow.hot.rate * designDeltaT
      / storage.salt.massFlow.calculated.rate * designDeltaT
    
    storage.temperatureTank.cold = Temperature.calculate(
      massFlow1: storage.salt.massFlow.calculated,
      massFlow2: storage.salt.massFlow.cold,
      temperature1: parameter.designTemperature.cold,
      temperature2: storage.temperatureTank.cold
    )
  }
  

  /// - Remark: Only called by: `Storage.update(_:mode:nightHour:)`
  private static func storagePreheat(
    storage: inout PerformanceData,
    powerBlock: PowerBlock.PerformanceData,
    solarField: SolarField.PerformanceData,
    _ outletTemperature: (Storage.PerformanceData) -> Temperature
    ) -> (Double, Double)
  {
    let htf = SolarField.parameter.HTF
    /// the rest is heated by SF
    var thermalPower = 0.0
    storage.massFlow = powerBlock.massFlow
    storage.massFlow -= solarField.massFlow
    storage.setTemperature(inlet: powerBlock.temperature.outlet)
    storage.setTemperature(outlet: outletTemperature(storage))
    
    thermalPower = storage.massFlow.rate * htf.heatAdded(
      storage.temperature.outlet, storage.temperature.inlet) / 1_000
    // limit the size of the salt-oil heat exchanger
    if parameter.heatExchangerRestrictedMax,
      abs(thermalPower) > parameter.heatExchangerCapacity
    {
      thermalPower *= parameter.heatExchangerCapacity
      
      storage.calculateMassFlow(thermalPower: thermalPower)
      
      storage.setTemperature(outlet: outletTemperature(storage))
      thermalPower = -storage.massFlow.rate * htf.heatAdded(
        storage.temperature.outlet, storage.temperature.inlet) / 1_000
    }
    return (thermalPower, Storage.parasitics(&storage))
  }
  
  private static func freezeProtection(
    storage: inout Storage.PerformanceData,
    _ powerBlock: PowerBlock.PerformanceData)
  {
    let splitfactor = parameter.HTF == .hiXL ? 0.4 : 1
    let solarField =  SolarField.parameter
    storage.salt.massFlow.calculated.rate = solarField.antiFreezeFlow.rate
      * hourFraction * 3_600
    
    storage.temperatureTank.cold = Temperature.calculate(
      massFlow1: MassFlow(splitfactor * storage.salt.massFlow.calculated.rate),
      massFlow2: storage.salt.massFlow.cold,
      temperature1: powerBlock.temperature.outlet,
      temperature2: storage.temperatureTank.cold
    )
    
    storage.antiFreezeTemperature = splitfactor
      * storage.temperatureTank.cold.kelvin
      + (1 - splitfactor) * powerBlock.outletTemperature
  }
  
  private static func storageFreezeProtection(
    _ status: inout Plant.PerformanceData) {
    let solarField = SolarField.parameter
    let storage = Storage.parameter
    let splitfactor: Ratio = 0.4
    status.storage.massFlow = solarField.antiFreezeFlow
      .adjusted(with: splitfactor)
    
    status.solarField.header.massFlow = solarField.antiFreezeFlow
    // used for parasitics
    status.storage.setTemperature(inlet: status.powerBlock.temperature.outlet)
    var fittedTemperature = 0.0
    if storage.temperatureCharge[1] > 0 {
      if storage.temperatureDischarge.indices.contains(2) {
        status.storage.setTemperaturOutletEqualToInlet()
      } else {
        fittedTemperature = status.storage.charge > 0.5
          ? 1 : storage.temperatureCharge2[status.storage.charge]
        status.storage.setOutletTemperature(kelvin:
          fittedTemperature * storage.designTemperature.hot.kelvin
        )
      }
      status.storage.setOutletTemperature(kelvin:
        splitfactor.ratio * status.storage.outletTemperature
          + (1 - splitfactor.ratio) * status.storage.inletTemperature
      )
    } else {
      status.storage.temperature.outlet =
        status.storage.temperatureTank.cold
    }
  }
  
  private static func noOperation(
    storage: inout Storage.PerformanceData,
    _ powerBlock: PowerBlock.PerformanceData)
  {
    if parameter.stepSizeIteration < -90,
      storage.temperatureTank.cold < parameter.designTemperature.cold,
      powerBlock.temperature.outlet > storage.temperatureTank.cold,
      storage.salt.massFlow.cold.rate > 0
    {
      storage.salt.massFlow.calculated.rate = powerBlock.massFlow.rate
        * hourFraction * 3_600
      
      storage.temperatureTank.cold = Temperature.calculate(
        massFlow1: storage.salt.massFlow.calculated,
        massFlow2: storage.salt.massFlow.cold,
        temperature1: powerBlock.temperature.outlet,
        temperature2: storage.temperatureTank.cold
      )
      // status.operationMode = .sc
    }
  }

  private static func isFossilChargingAllowed(at time: TimeStep) -> Bool {
    return (time.month < parameter.FCstopM
      || (time.month == parameter.FCstopM && time.day < parameter.FCstopD)
      || ((time.month == parameter.FCstartM && time.day > parameter.FCstartD)
        || time.month > parameter.FCstartM)
      && (time.month < parameter.FCstopM2 || (time.month == parameter.FCstopM2
        && time.day < parameter.FCstopD2) || (time.month > parameter.FCstartM2
          || (time.month == parameter.FCstartM2
            && time.day > parameter.FCstartD2))))
  }
}

extension HeatTransferFluid {
  fileprivate func specificHeat(_ temperature: Temperature) -> Double {
    return heatCapacity[0] * temperature.kelvin
      + 0.5 * heatCapacity[1] * temperature.kelvin ** 2 - 350.5536
  }
}

extension Storage.PerformanceData {
  init(operationMode: OperationMode,
       temperature: (inlet: Temperature, outlet: Temperature),
       temperatureTanks: (cold: Temperature, hot: Temperature),
       massFlow: MassFlow, minMassFlow: MassFlow, heatRelease: Double,
       tempertureColdOut: Double,  massFlowSalt: Double,
       heatLossStorage: Double, heatProductionLoad: Double)
  {
    self.operationMode = operationMode
    self.temperature = temperature
    self.temperatureTank = temperatureTanks
    self.massFlow = massFlow
    
    self.charge.ratio = heatRelease
    self.dischargeLoad = 0
    self.heat = 0
    
    // self.tempertureColdOut = tempertureColdOut
    self.minMassFlow = minMassFlow
    
    self.heatLossStorage = heatLossStorage
    self.heatProductionLoad = heatProductionLoad
    let storage = Storage.parameter
    let solarField = SolarField.parameter
    /// Initial state of storage
    if Design.hasStorage {
      energyStored = Design.layout.storage * storage.heatStoredrel
      
      SolarField.parameter.massFlow.max = MassFlow(
        100 / storage.massFlow.rate * solarField.massFlow.max.rate
      )
      
      Storage.parameter.massFlow = MassFlow(
        (1 - storage.massFlow.rate / 100) * solarField.massFlow.max.rate
      )
    }
    energyStored = 0
    // solarField.massFlow.min = MassFlow(
    //   solarField.massFlow.min.rate / 100 * solarField.massFlow.max.rate
    // )
    
    // solarField.antiFreezeFlow = MassFlow(
    //   solarField.antiFreezeFlow.rate / 100 * solarField.massFlow.max.rate
    // )
    
    if solarField.pumpParastics.isEmpty {
      let layout = Design.layout.solarField
      let maxFlow = solarField.massFlow.max.rate
      if maxFlow < 900 {
        // calculation of solar field parasitics with empirical correlation
        // derived from solar field model
        SolarField.parameter.pumpParasticsFullLoad =
          (4.7327e-08 * layout ** 4 - 2.0044e-05 * layout ** 3
            + 0.0032862 * layout ** 2 - 0.24086 * layout + 8.2152)
          * (0.7103 * (maxFlow / 597) ** 3 - 0.8236 * (maxFlow / 597) ** 2
            + 1.464 * (maxFlow / 597) - 0.3508)
      } else {
        SolarField.parameter.pumpParasticsFullLoad =
          (5.5e-06 * maxFlow ** 2 - 0.0074 * maxFlow + 4.4)
          * (-1.656e-06 * layout ** 3 + 0.0007981 * layout ** 2
            - 0.1322 * layout + 8.428)
      }
      SolarField.parameter.HTFmass = (93300 + 11328 * layout)
        * (0.63 * (maxFlow / 597) + 0.38)
    }
    // check if it should be left so or changed to the real achieved temp. ( < 393 °C)
    // heatExchanger.temperature.htf.inlet.max = heatExchanger.HTFinTmax
    // heatExchanger.temperature.htf.inlet.min = heatExchanger.HTFinTmin
    // heatExchanger.temperature.htf.outlet.max = heatExchanger.HTFoutTmax
    // HeatExchanger.storage.HTFoutTmin = heatExchanger.HTFoutTmin never used
    self.dT_HTFsalt.cold = 1.0
    self.dT_HTFsalt.hot = 1.0
    
    if storage.stepSizeIteration == -99.99 {
      salt.heat.cold = Storage.parameter.HTF.properties.specificHeat(
        storage.designTemperature.cold
      )
      salt.heat.hot = Storage.parameter.HTF.properties.specificHeat(
        storage.designTemperature.hot
      )
      
      HeatExchanger.parameter.temperature.h2o.inlet.max = Temperature(
        storage.startTemperature.hot.kelvin
      )
      HeatExchanger.parameter.temperature.h2o.inlet.min = Temperature(
        storage.startTemperature.cold.kelvin
      )
      
      if storage.temperatureCharge[1] == 0 {
        /* status.tempertureOffset.hot = Temperature(celsius: storage.temperatureCharge[0])
         status.tempertureOffset.cold = Temperature(celsius: storage.temperatureCharge[0])
         storage.temperatureCharge.coefficients[0] = storage.designTemperature.hot.kelvin
         - storage.temperatureCharge.coefficients[0]
         // meaning is HTFTout(EX) = HotTankDes - dT
         storage.temperatureDischarge.coefficients[0] = storage.temperatureCharge.coefficients[0]
         storage.temperatureCharge.coefficients[0] = storage.designTemperature.cold.kelvin
         - storage.temperatureCharge.coefficients[0]
         // meaning is HTFTout(IN) = ColdTankDes + dT
         storage.temperatureCharge.coefficients[0] = storage.temperatureCharge[0]*/
      }
    }
  }
}
