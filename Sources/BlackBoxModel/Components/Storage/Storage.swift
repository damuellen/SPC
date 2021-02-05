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

  var salt = Salt()

  var storedHeat: Double = 0.0

  var relativeCharge: Ratio = 0.0

 // var heatLossStorage: Double = 0.0

  var heatProductionLoad: Ratio = 1.0

  var dischargeLoad: Ratio = 1.0

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
  
  mutating func chargeOrDischarge(_ heat: Power) {
    let chargeTo = Storage.parameter.chargeTo
    let dischargeToTurbine = Storage.parameter.dischargeToTurbine
    operationMode = .noOperation
    if heat > .zero { // Energy surplus
      if relativeCharge < chargeTo { 
        operationMode = .charging
      }
    } else if heat < .zero { // Energy deficit 
      if relativeCharge > dischargeToTurbine { 
        operationMode = .discharge 
      }
    }
  }

  static func demandStrategy(
    storage: inout Storage,
    powerBlock: inout PowerBlock,
    heatFlow: ThermalEnergy) -> ThermalEnergy
  {
   // var demand = DateTime.current.isDaytime ? 0.5 : heatFlow.demand.megaWatt

    switch parameter.strategy {
    case .always: return strategyAlways(
      storage: &storage,
      powerBlock: &powerBlock,
      heatFlow: heatFlow)      
    case .demand: return strategyDemand(
      storage: &storage,
      powerBlock: &powerBlock,
      heatFlow: heatFlow)      
    // parameter.strategy = "Ful" // Booster or Shifter
    case .shifter: return strategyShifter(
      storage: &storage, 
      powerBlock: &powerBlock,
      heatFlow: heatFlow)
    }
  }
  
  private static func strategyAlways(
    storage: inout Storage,
    powerBlock: inout PowerBlock,
    heatFlow: ThermalEnergy) -> ThermalEnergy
  {  
    var heatFlow = heatFlow
    powerBlock.designMassFlow.rate = 
      heatFlow.demand.kiloWatt / HeatExchanger.capacity
    assert(powerBlock.designMassFlow.rate > 0)
    
    heatFlow.storage = heatFlow.production - heatFlow.demand  // [MW]

    if parameter.heatExchangerRestrictedMin {
      // added to avoid input to storage lower than minimal HX's capacity
      let maxMassFlow = SolarField.parameter.maxMassFlow.rate
      heatFlow.toStorageMin.megaWatt = parameter.heatExchangerMinCapacity
        * HeatExchanger.parameter.heatFlowHTF
        * (1 - parameter.designMassFlow.rate / maxMassFlow)
        / (parameter.designMassFlow.rate / maxMassFlow)
      
      if case 0..<heatFlow.toStorageMin.megaWatt = heatFlow.storage.megaWatt {
        heatFlow.demand -= heatFlow.toStorageMin - heatFlow.storage
        powerBlock.massFlow.rate = heatFlow.demand.kiloWatt / HeatExchanger.capacity
        heatFlow.storage = heatFlow.toStorageMin
      }
    }
    return heatFlow
  }
  
  private static func strategyDemand(
    storage: inout Storage,
    powerBlock: inout PowerBlock,
    heatFlow: ThermalEnergy) -> ThermalEnergy
  {
    var heatFlow = heatFlow
    let maxMassFlow = SolarField.parameter.maxMassFlow.rate

    let heatFlowRate = HeatExchanger.parameter.heatFlowHTF

    powerBlock.designMassFlow.rate = heatFlowRate * 1_000 
      / HeatExchanger.capacity
   
    heatFlow.storage = heatFlow.production - heatFlow.demand // [MW]

    if (heatFlow.storage.megaWatt != -heatFlowRate) {

    }
    if parameter.heatExchangerRestrictedMin {
      // avoiding input to storage lower than minimal HXs capacity
      heatFlow.toStorageMin.megaWatt = heatFlowRate
        * (1 - parameter.designMassFlow.rate / maxMassFlow)
        / (parameter.designMassFlow.rate / maxMassFlow)
      
      if case 0..<heatFlow.toStorageMin.megaWatt = heatFlow.storage.megaWatt {
        powerBlock.massFlow.rate = (heatFlowRate
          - (heatFlow.toStorageMin - heatFlow.storage).megaWatt) * 1_000 
          / HeatExchanger.capacity
        
        heatFlow.storage = heatFlow.toStorageMin
      }
    }
    return heatFlow
  }
  
  private static func strategyShifter(
    storage: inout Storage,
    powerBlock: inout PowerBlock,
    heatFlow: ThermalEnergy) -> ThermalEnergy
  {
    var heatFlow = heatFlow
    let steamTurbine = SteamTurbine.parameter

    let heatExchanger = HeatExchanger.parameter

    let time = DateTime.current
    let dniDay = BlackBoxModel.meteoData!.currentDay.sum
    
    if parameter.exception.contains(time.month) {
      storage.heatProductionLoad = parameter.heatProductionLoadSummer
      if dniDay > parameter.badDNIsummer * 1_000 {
        // sunny day, TES can be fully charged also by running TB at full load
        storage.heatProductionLoad = 1.0
      }
    } else {
      storage.heatProductionLoad = parameter.heatProductionLoadWinter
      if dniDay > parameter.badDNIwinter * 1_000 {
        // sunny day, TES can be fully charged also by running TB at full load
        storage.heatProductionLoad = 1.0
      }
    }
    
    if heatFlow.production > .zero { // heatFlow.solar > 0
      if heatFlow.production < heatFlow.demand,
        storage.relativeCharge < parameter.chargeTo,
        time.hour < 17
      {
        // Qsol not enough for POB demand load (e.g. at the beginning of the day)
        powerBlock.designMassFlow.rate = 
          min(storage.heatProductionLoad.quotient * heatFlow.demand.kiloWatt, heatFlow.production.kiloWatt) 
           / HeatExchanger.capacity

        heatFlow.storage = heatFlow.production /* - min(
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
        heatFlow.storage.megaWatt = min(heatFlow.storage.megaWatt, threshold)
      } else if heatFlow.production < heatFlow.demand,
        storage.relativeCharge >= parameter.chargeTo
      {
        // Qsol not enough for POB demand load (e.g. at the end of the day) and TES is full
        powerBlock.designMassFlow.rate = heatFlow.demand.kiloWatt / HeatExchanger.capacity
        // send all to POB and if needed discharge TES
        heatFlow.storage = heatFlow.production - heatFlow.demand  // [MW]
        // TES provides the rest available
        // check what if TES is full and POB could get more than 50% of design!!
        if parameter.heatExchangerRestrictedMax {
          heatFlow.storage.megaWatt = max(heatFlow.storage.megaWatt, -parameter.heatExchangerCapacity)
        } else { // signs below changed
          let value = steamTurbine.power.max
            / steamTurbine.efficiencyNominal
            / heatExchanger.efficiency
          if heatFlow.storage.megaWatt > -value { heatFlow.storage.megaWatt = -value }
        }
      } else if heatFlow.production > heatFlow.demand,
        storage.relativeCharge < parameter.chargeTo,
        powerBlock.massFlow >= powerBlock.designMassFlow
      {
        // more Qsol than needed by POB and TES is not full
        heatFlow.demand *= storage.heatProductionLoad.quotient
        powerBlock.designMassFlow.rate = heatFlow.demand.kiloWatt / HeatExchanger.capacity
        // from avail heat cover first 50% of POB demand
        heatFlow.storage = heatFlow.production - heatFlow.demand  // [MW]
        // TES gets the rest available
        if parameter.heatExchangerRestrictedMax,
          heatFlow.storage.megaWatt > parameter.heatExchangerCapacity {
          // rest heat to TES is too high, use more heat to POB
          powerBlock.designMassFlow.rate =
            (heatFlow.production.megaWatt - parameter.heatExchangerCapacity)
              / HeatExchanger.capacity
          
          // from avail heat cover first 50% of POB demand
          // TES gets max heat input
          heatFlow.storage.megaWatt = parameter.heatExchangerCapacity
        }
      }
      return heatFlow
    }
    if case .hours = parameter.definedBy {
      // It usually doesn't get in here. therefore, not correctly programmed yet
      if heatFlow.production > heatFlow.demand,
        storage.relativeCharge > Ratio(steamTurbine.power.max
          / steamTurbine.efficiencyNominal / Design.layout.storage) {
        
// FIXME:  let (eff, st) = SteamTurbine.efficiency(status, maxLoad: &maxLoad)
//  status.steamTurbine = st
        let eff = 0.39//FIXME
        heatFlow.demand.megaWatt = steamTurbine.power.max
          * Availability.current.value.powerBlock.quotient / eff

        var heatDiff = heatFlow.production - heatFlow.demand // [MW]
        // power to charge TES rest after operation POB at full load commented
        // heatdiff = max(thermal.production, thermal.demand)
        // maximal power to TES desing POB thermal input (just to check how it works)
        let design = Power(megaWatt: SteamTurbine.parameter.power.max 
          / SteamTurbine.parameter.efficiencyNominal
          / heatExchanger.efficiency)
        
        if heatDiff > design {
          heatDiff = design // commented in case of degradated powerblock
          // in case of degradated powerblock
          powerBlock.designMassFlow.rate = 
            (heatFlow.production - heatDiff).kiloWatt / HeatExchanger.capacity          
        }
      }
    }
    return heatFlow
  }
}

extension HeatTransferFluid {
  func specificHeat(_ temperature: Temperature) -> Double {
    let c = heatCapacity
    let t = temperature.celsius
    let cp = c[0] * t + 0.5 * c[1] * t ** 2 - 350.5536
    return cp
  }
}
