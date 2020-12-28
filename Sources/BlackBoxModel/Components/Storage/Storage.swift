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
public struct Storage: Parameterizable, HeatCycle {
  
  var operationMode: OperationMode

  var dT_HTFsalt: (cold: Double, hot: Double)
  
  var temperatureTank: Temperatures
  
  var cycle: HeatTransfer = .init(name: Storage.parameter.name)

  var antiFreezeTemperature: Double = 270.0
  
  var heat: Double = 0.0
  
  var charge: Ratio = 0.0

  var massFlows: MassFlows = .init(
    need: .init(), minimum: .init(), cold: .init(), hot: .init()
  )
  
  struct MassFlows { // [kg/s]
    var need, minimum, cold, hot: MassFlow
  }
  
  var heatInSalt: Heat = .init(cold: 0, hot: 0)
  
  struct Heat { // [kJ/kg]
    var cold: Double
    var hot: Double
    var available: Double {
      return hot - cold
    }
  }

  var storedHeat: Double = 0.0

 // var heatLossStorage: Double = 0.0

  var heatProductionLoad: Ratio = 0.0

 // var dischargeLoad: Ratio = 0.0

  var massOfSalt: Double = 0.0
  
  public enum OperationMode  {
    case noOperation, discharge
    case preheat, charging, fossilCharge, freezeProtection
  }

  static let initialState = Storage(
    operationMode: .noOperation,
    temperature: (566.0, 666.0),
    temperatureTanks: (566.0, 666.0)
  )
  
  public static var parameter: Parameter = ParameterDefaults.st
  
  static func update(
    storage: inout Storage,
    solarField: inout SolarField,
    steamTurbine: inout SteamTurbine,
    powerBlock: inout PowerBlock,
    heater: inout Heater,
    fuelAvailable: Double,
    heat: inout ThermalPower)
    -> PerformanceData<Storage>
  {    
    // **************************  Energy surplus  *****************************
    if storage.heat > 0 {
      var supply: Double
      var parasitics: Double

      if storage.charge.ratio < parameter.chargeTo,
        solarField.massFlow >= SolarField.parameter.maxMassFlow
      {
        storage.operationMode = .charging
      } else { // heat cannot be stored
        storage.operationMode = .noOperation
      }
      (supply, parasitics) = Storage.perform(
        storage: &storage,
        solarField: &solarField,
        steamTurbine: &steamTurbine,
        powerBlock: &powerBlock,
        heat: &heat
      )
      powerBlock.inletTemperature(outlet: solarField)
      return PerformanceData(heat: supply, electric: parasitics, fuel: 0)
    }
    
    // **************************  Energy deficit  *****************************
    var peakTariff: Bool
    let time = DateTime.current
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
      peakTariff = false // dont care about time to discharge
    }

    //#warning("The implementation here differs from PCT")
    if peakTariff,// status.storage.operationMode = .freezeProtection,
      storage.charge.ratio > parameter.dischargeToTurbine,
      storage.heat < 1 * parameter.heatdiff * heat.demand.megaWatt
    { // added dicharge only after peak hours
      // previous discharge condition commented:
      // if storage.heatrel > parameter.dischargeToTurbine
      // && storage.operationMode != .freezeProtection
      // && heatdiff < -1 * parameter.heatdiff * thermal.demand {
      // Discharge directly!! // 04.07.0 -0.25&& heatdiff < -0.25 * thermal.dem
      if powerBlock.massFlow < solarField.massFlow {
        // there are cases, during cloudy days when mode .discharge although
        // massflow in SOF is higher that in PB.
      }
      var supply: Double
      var parasitics: Double
      storage.operationMode = .discharge
      (supply, parasitics) = Storage.perform(
        storage: &storage,
        solarField: &solarField,
        steamTurbine: &steamTurbine,
        powerBlock: &powerBlock,
        heat: &heat
      )
      
      if [.operating, .freezeProtection]
        .contains(solarField.operationMode)
      {
        powerBlock.temperature.inlet =
          SolarField.parameter.HTF.mixingTemperature(solarField, storage)

        powerBlock.massFlow = solarField.massFlow
        powerBlock.massFlow += storage.massFlow
        powerBlock.massFlow.adjust(factor: parameter.heatExchangerEfficiency)
        
      } else if storage.massFlow.isNearZero == false {
        
        powerBlock.inletTemperature(outlet: storage)

        powerBlock.massFlow = storage.massFlow
        powerBlock.massFlow.adjust(factor: parameter.heatExchangerEfficiency)
      } else {
        powerBlock.massFlow = .init() // set to zero
      }
      return PerformanceData(heat: supply, electric: parasitics, fuel: 0)
    }

    // heat can only be provided with heater on
    if (parameter.FC == 0 && DateTime.current.isNighttime
      && storage.charge.ratio < parameter.chargeTo
      && powerBlock.inletTemperature > 665
      && Storage.isFossilChargingAllowed(at: time)
      && OperationRestriction.fuelStrategy.isPredefined == false)
 //     || (OperationRestriction.fuelStrategy.isPredefined && fuelAvailable > 0)
    {
      //#warning("Check this")
      heater.operationMode = .freezeProtection(.zero)
      var supply: Double
      var parasitics: Double

      var fuel = 0.0

      if OperationRestriction.fuelStrategy.isPredefined == false {

        let energy = heater(
          temperatureOutlet: solarField.temperature.outlet,
          temperatureInlet: powerBlock.temperature.inlet,
          massFlowStorage: storage.massFlow,
          modeStorage: storage.operationMode, 
          demand: heat.demand.megaWatt,
          fuelAvailable: fuelAvailable, heat: heat
        )
        fuel = energy.fuel
        heat.heater.megaWatt = energy.heat
     // FIXME   plant.electricalParasitics.heater = energy.electric
        
        powerBlock.massFlow = heater.massFlow

        storage.operationMode = .freezeProtection
      } else if case .freezeProtection = solarField.operationMode,
        storage.charge > -0.35 && parameter.FP == 0
      {
        storage.operationMode = .freezeProtection
      } else {
        storage.operationMode = .noOperation
      }
      
      (supply, parasitics) = Storage.perform(
        storage: &storage,
        solarField: &solarField,
        steamTurbine: &steamTurbine,
        powerBlock: &powerBlock,
        heat: &heat
      )
      
      powerBlock.inletTemperature(outlet: storage)

      // check why to circulate HTF in SF
      //#warning("Storage.parasitics")
    // FIXME  plant.electricalParasitics.solarField = SolarField.parameter.antiFreezeParastics
      
      return PerformanceData(heat: supply, electric: parasitics, fuel: fuel)
    }
    return PerformanceData(heat: 0, electric: 0, fuel: 0)
  }
  
  static func demandStrategy(
    storage: inout Storage,
    powerBlock: inout PowerBlock,
    heat: ThermalPower)
  {
   // var demand = DateTime.current.isDaytime ? 0.5 : heat.demand.megaWatt
    var demand = heat.demand.megaWatt
    let production = heat.solar.megaWatt
    
    switch parameter.strategy {
    case .always: strategyAlways(
      storage: &storage, powerBlock: &powerBlock,
      massFlow: Plant.requiredMassFlow(),
      production: production, demand: &demand)
    case .demand : strategyDemand(
      storage: &storage, powerBlock: &powerBlock,
      massFlow: Plant.requiredMassFlow(),
      production: production)
    // parameter.strategy = "Ful" // Booster or Shifter
    case .shifter: strategyShifter(
      storage: &storage, powerBlock: &powerBlock,
      massFlow: Plant.requiredMassFlow(),
      production: production, demand: &demand)
    }
  }
  
  private static func strategyAlways(
    storage: inout Storage,
    powerBlock: inout PowerBlock,
    massFlow: MassFlow,
    production: Double,
    demand: inout Double)
  {
    let solarField = SolarField.parameter

    let heatExchanger = HeatExchanger.parameter
    
    let heatTransfer = solarField.HTF.deltaHeat(
      heatExchanger.temperature.htf.inlet.max,
      heatExchanger.temperature.htf.outlet.max) / 1_000 // [MW]

    powerBlock.setMassFlow(rate: demand / heatTransfer)
    
    if powerBlock.massFlow.rate < 0 { // to avoid negative massflows
      storage.heat = 0
      powerBlock.massFlow = massFlow
      return
    }

    storage.heat = production  // - demand [MW]
    
    if parameter.heatExchangerRestrictedMin {
      // added to avoid input to storage lower than minimal HX's capacity
      let toStorageMin = parameter.heatExchangerMinCapacity
        * heatExchanger.sccHTFheat
        * (1 - parameter.designMassFlow.rate / solarField.maxMassFlow.rate)
        / (parameter.designMassFlow.rate / solarField.maxMassFlow.rate)
      
      if case 0..<toStorageMin = storage.heat {
        demand -= (toStorageMin - storage.heat)
        powerBlock.setMassFlow(rate: demand / heatTransfer)
        storage.heat = toStorageMin
      }
    }
  }
  
  private static func strategyDemand(
    storage: inout Storage,
    powerBlock: inout PowerBlock,
    massFlow: MassFlow,
    production: Double)
  {
    let solarField = SolarField.parameter

    let heatExchanger = HeatExchanger.parameter

    let heatTransfer = SolarField.parameter.HTF.deltaHeat(
      heatExchanger.temperature.htf.inlet.max,
      heatExchanger.temperature.htf.outlet.max) / 1_000

    //powerBlock.setMassFlow(rate: )
    powerBlock.designMassFlow.rate = heatExchanger.sccHTFheat / heatTransfer
    if powerBlock.massFlow < 0.0 { // to avoid negative massflows
      storage.heat = 0
      powerBlock.massFlow = massFlow
      return
    }
    
    storage.heat = production - heatExchanger.sccHTFheat
    
    if parameter.heatExchangerRestrictedMin {
      // avoiding input to storage lower than minimal HXs capacity
      let toStorageMin = heatExchanger.sccHTFheat
        * (1 - parameter.designMassFlow.rate / solarField.maxMassFlow.rate)
        / (parameter.designMassFlow.rate / solarField.maxMassFlow.rate)
      
      if case 0..<toStorageMin = storage.heat {
        powerBlock.setMassFlow(rate: (heatExchanger.sccHTFheat
          - (toStorageMin - storage.heat)) * 1_000 / heatTransfer
        )
        storage.heat = toStorageMin
      }
    }
  }
  
  private static func strategyShifter(
    storage: inout Storage,
    powerBlock: inout PowerBlock,
    massFlow: MassFlow,
    production: Double,
    demand: inout Double)
  {
    let steamTurbine = SteamTurbine.parameter

    let heatExchanger = HeatExchanger.parameter
    
    let heatTransfer = SolarField.parameter.HTF.deltaHeat(
      heatExchanger.temperature.htf.inlet.max,
      heatExchanger.temperature.htf.outlet.max) / 1_000

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
    
    if production > 0 { // Qsol > 0
      if production < demand,
        storage.charge.ratio < parameter.chargeTo,
        time.hour < 17
      {
        // Qsol not enough for POB demand load (e.g. at the beginning of the day)
        powerBlock.setMassFlow(rate:
          min(storage.heatProductionLoad.ratio * demand, production) / heatTransfer
        )
        storage.heat = production/* - min(
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
        storage.charge.ratio >= parameter.chargeTo
      {
        // Qsol not enough for POB demand load (e.g. at the end of the day) and TES is full
        powerBlock.setMassFlow(rate: demand / heatTransfer)
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
        massFlow >= powerBlock.massFlow
      {
        // more Qsol than needed by POB and TES is not full
        let powerBlockDemand = storage.heatProductionLoad.ratio * demand
        powerBlock.setMassFlow(rate: powerBlockDemand / heatTransfer)
        // from avail heat cover first 50% of POB demand
        storage.heat = production - powerBlockDemand
        // TES gets the rest available
        if parameter.heatExchangerRestrictedMax,
          storage.heat > parameter.heatExchangerCapacity {
          // rest heat to TES is too high, use more heat to POB
          powerBlock.setMassFlow(rate:
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
          * Availability.current.value.powerBlock.ratio / eff

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
          powerBlock.setMassFlow(rate: (production - heatDiff) / heatTransfer)
        }
      }
    }
  }
}

extension HeatTransferFluid {
  func specificHeat(_ temperature: Temperature) -> Double {
    heatCapacity[0] * temperature.celsius
      + 0.5 * heatCapacity[1] * temperature.celsius ** 2 - 350.5536
  }
}
