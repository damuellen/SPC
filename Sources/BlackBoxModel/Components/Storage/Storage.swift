//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import DateGenerator
/// Contains all data needed to simulate the operation of the storage
public struct Storage: Parameterizable, HeatTransfer {
  
  let name = Storage.parameter.name

  var temperature: (inlet: Temperature, outlet: Temperature)

  var massFlow: MassFlow = .zero
  
  var operationMode: OperationMode

  var dT_HTFsalt: (cold: Double, hot: Double)
  
  var temperatureTank: Temperatures

  var antiFreezeTemperature: Double = 270.0
  
  var heat: Double = 0.0 {
    willSet {
      if newValue > 0 {
     //   print(newValue)
      }
    }
  }
  
  var charge: Ratio = 0.0

  var salt = Salt()

  var storedHeat: Double = 0.0

 // var heatLossStorage: Double = 0.0

  var heatProductionLoad: Ratio = 1.0

 // var dischargeLoad: Ratio = 0.0

  var massOfSalt: Double = Storage.defineSaltMass()

  public enum OperationMode: String  {
    case noOperation, discharge
    case preheat, charging, fossilCharge, freezeProtection
  }

  static let initialState = Storage(
    operationMode: .noOperation,
    temperature: (560.0, 660.0),
    temperatureTanks: (566.0, 666.0)
  )
  
  public static var parameter: Parameter = ParameterDefaults.st
  
  static func demandStrategy(
    storage: inout Storage,
    powerBlock: inout PowerBlock,
    demand: Power,
    production: Power) -> Double
  {
   // var demand = DateTime.current.isDaytime ? 0.5 : heat.demand.megaWatt
    let massFlow = Plant.requiredMassFlow()

    switch parameter.strategy {
    case .always: return strategyAlways(
      storage: &storage,
      powerBlock: &powerBlock,
      massFlow: massFlow,
      production: production,
      demand: demand)
    case .demand: strategyDemand(
      storage: &storage,
      powerBlock: &powerBlock,
      massFlow: massFlow,
      production: production)
      return demand.megaWatt
    // parameter.strategy = "Ful" // Booster or Shifter
    case .shifter: return strategyShifter(
      storage: &storage, 
      powerBlock: &powerBlock,
      massFlow: massFlow,
      production: production,
      demand: demand)
    }
  }
  
  private static func strategyAlways(
    storage: inout Storage,
    powerBlock: inout PowerBlock,
    massFlow: MassFlow,
    production: Power,
    demand: Power) -> Double
  {  
    powerBlock.designMassFlow.rate = 
      demand.kiloWatt / powerBlock.heatExchangerCapacity
    assert(powerBlock.designMassFlow.rate > 0)
    
    storage.heat = production.megaWatt - demand.megaWatt  // [MW]

    if parameter.heatExchangerRestrictedMin {
      // added to avoid input to storage lower than minimal HX's capacity
      let maxMassFlow = SolarField.parameter.maxMassFlow.rate
      let toStorageMin = parameter.heatExchangerMinCapacity
        * HeatExchanger.parameter.sccHTFheat
        * (1 - parameter.designMassFlow.rate / maxMassFlow)
        / (parameter.designMassFlow.rate / maxMassFlow)
      
      if case 0..<toStorageMin = storage.heat {
        var demand = demand
        demand -= Power(toStorageMin - storage.heat)
        powerBlock.designMassFlow.rate = demand.kiloWatt / powerBlock.heatExchangerCapacity
        storage.heat = toStorageMin
      }
    }
    return demand.megaWatt
  }
  
  private static func strategyDemand(
    storage: inout Storage,
    powerBlock: inout PowerBlock,
    massFlow: MassFlow,
    production: Power)
  {
    let maxMassFlow = SolarField.parameter.maxMassFlow.rate

    let sccHTFheat = HeatExchanger.parameter.sccHTFheat

    powerBlock.designMassFlow.rate = sccHTFheat * 1_000 
      / powerBlock.heatExchangerCapacity
   
    storage.heat = production.megaWatt - sccHTFheat // [MW]
   // print(storage.heat)
    if (storage.heat != -sccHTFheat) {

    }
    if parameter.heatExchangerRestrictedMin {
      // avoiding input to storage lower than minimal HXs capacity
      let toStorageMin = sccHTFheat
        * (1 - parameter.designMassFlow.rate / maxMassFlow)
        / (parameter.designMassFlow.rate / maxMassFlow)
      
      if case 0..<toStorageMin = storage.heat {
        powerBlock.massFlow.rate = (sccHTFheat
          - (toStorageMin - storage.heat)) * 1_000 
          / powerBlock.heatExchangerCapacity
        
        storage.heat = toStorageMin
      }
    }
  }
  
  private static func strategyShifter(
    storage: inout Storage,
    powerBlock: inout PowerBlock,
    massFlow: MassFlow,
    production: Power,
    demand: Power) -> Double
  {
    var demand = demand
    let steamTurbine = SteamTurbine.parameter

    let heatExchanger = HeatExchanger.parameter

    let time = DateTime.current
    let dniDay = BlackBoxModel.meteoData!.currentDay.sum
    
    if time.month < parameter.startexcep || time.month > parameter.endexcep {
      storage.heatProductionLoad = parameter.heatProductionLoadWinter
      if dniDay > parameter.badDNIwinter * 1_000 {
        // sunny day, TES can be fully charged also by running TB at full load
        storage.heatProductionLoad = 1.0
      }
    } else {
      storage.heatProductionLoad = parameter.heatProductionLoadSummer
      if dniDay > parameter.badDNIsummer * 1_000 {
        // sunny day, TES can be fully charged also by running TB at full load
        storage.heatProductionLoad = 1.0
      }
    }
    
    if production.watt > 0 { // heat.solar > 0
      if production.watt < demand.watt,
        storage.charge < parameter.chargeTo,
        time.hour < 17
      {
        // Qsol not enough for POB demand load (e.g. at the beginning of the day)
        powerBlock.designMassFlow.rate = 
          min(storage.heatProductionLoad.quotient * demand.kiloWatt, production.kiloWatt) 
           / powerBlock.heatExchangerCapacity

        storage.heat = production.megaWatt /* - min(
          storage.heatProductionLoad * demand,
          production
        )*/
        // TES gets the rest available
        let threshold: Double
        if parameter.heatExchangerRestrictedMax {
          threshold = parameter.heatExchangerCapacity
        } else {
          threshold = steamTurbine.power.max
            / steamTurbine.efficiencyNominal
            / heatExchanger.efficiency
        }
        storage.heat = min(storage.heat, threshold)
      } else if production < demand,
        storage.charge >= parameter.chargeTo
      {
        // Qsol not enough for POB demand load (e.g. at the end of the day) and TES is full
        powerBlock.designMassFlow.rate = demand.kiloWatt / powerBlock.heatExchangerCapacity
        // send all to POB and if needed discharge TES
        storage.heat = production.megaWatt - demand.megaWatt  // [MW]
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
        storage.charge < parameter.chargeTo,
        massFlow >= powerBlock.massFlow
      {
        // more Qsol than needed by POB and TES is not full
        demand = Power(storage.heatProductionLoad.quotient * demand.watt)
        powerBlock.massFlow.rate = demand.kiloWatt / powerBlock.heatExchangerCapacity
        // from avail heat cover first 50% of POB demand
        storage.heat = production.megaWatt - demand.megaWatt  // [MW]
        // TES gets the rest available
        if parameter.heatExchangerRestrictedMax,
          storage.heat > parameter.heatExchangerCapacity {
          // rest heat to TES is too high, use more heat to POB
          powerBlock.massFlow.rate =
            (production.megaWatt - parameter.heatExchangerCapacity)
              / powerBlock.heatExchangerCapacity
          
          // from avail heat cover first 50% of POB demand
          // TES gets max heat input
          storage.heat = parameter.heatExchangerCapacity
        }
      }
      return demand.megaWatt
    }
    if case .hours = parameter.definedBy {
      // It usually doesn't get in here. therefore, not correctly programmed yet
      if production > demand,
        storage.charge > Ratio(steamTurbine.power.max
          / steamTurbine.efficiencyNominal / Design.layout.storage) {
        
// FIXME:  let (eff, st) = SteamTurbine.efficiency(status, maxLoad: &maxLoad)
//  status.steamTurbine = st
        let eff = 0.39//FIXME
        demand.megaWatt = steamTurbine.power.max
          * Availability.current.value.powerBlock.quotient / eff

        var heatDiff = production - demand // [MW]
        // power to charge TES rest after operation POB at full load commented
        // heatdiff = max(thermal.production, thermal.demand)
        // maximal power to TES desing POB thermal input (just to check how it works)
        let heat = Power(megaWatt: SteamTurbine.parameter.power.max 
          / SteamTurbine.parameter.efficiencyNominal
          / heatExchanger.efficiency)
        
        if heatDiff > heat {
          heatDiff = heat // commented in case of degradated powerblock
          // in case of degradated powerblock
          powerBlock.massFlow.rate = 
            (production - heatDiff).kiloWatt / powerBlock.heatExchangerCapacity
          
        }
      }
    }
    return demand.megaWatt
  }
}

extension HeatTransferFluid {
  func specificHeat(_ temperature: Temperature) -> Double {
    let cp = 
      heatCapacity[0] * temperature.celsius + 0.5
      * heatCapacity[1] * temperature.celsius ** 2 - 350.5536
    return cp
  }
}
