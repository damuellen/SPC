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
import Physics
/// This struct contains the state as well as the functions for mapping the storage
public struct Storage: Parameterizable, HeatTransfer {

  let name = Storage.parameter.name

  public internal(set) var temperature: (inlet: Temperature, outlet: Temperature)

  public internal(set) var massFlow: MassFlow = .zero

  var designMassFlow = MassFlow(
    (1 - Storage.parameter.massFlowShare.quotient)
      * SolarField.parameter.maxMassFlow.rate
  )

  /// Returns the operating state
  public internal(set) var operationMode: OperationMode

  var dT_HTFsalt: (cold: Double, hot: Double)

  public internal(set)  var temperatureTank: Temperatures

  var antiFreezeTemperature: Double = 270.0

  public internal(set) var salt = Salt()

  public internal(set)  var relativeCharge: Ratio

//  var massOfSalt: Double = Storage.defineSaltMass()
  /// Returns the fixed initial state.
  static let initialState = Storage(
    operationMode: .noOperation,
    temperature: (560.0, 660.0),
    temperatureTanks: (566.0, 666.0)
  )
  /// Returns the static parameters.
  public static var parameter: Parameter = ParameterDefaults.st

  fileprivate static func heatExchangerRestrictedMax(heatFlow: inout Power) {
    let steamTurbine = SteamTurbine.parameter
    let heatExchanger = HeatExchanger.parameter

    let threshold: Double
    if parameter.heatExchangerRestrictedMax {
      threshold = parameter.heatExchangerCapacity
    } else {
      threshold = steamTurbine.power.max
        / steamTurbine.efficiencyNominal
        / heatExchanger.efficiency
    }
    heatFlow.megaWatt = min(heatFlow.megaWatt, threshold)
  }

  mutating func chargeOrDischarge(_ heat: Power) -> Power {
    let chargeTo = Storage.parameter.chargeTo
    let dischargeToTurbine = Storage.parameter.dischargeToTurbine

    /// Always zero when not discharging
    let load = operationMode.dischargeLoad
    operationMode = .noOperation
    if heat > .zero { // Energy surplus
      if relativeCharge < chargeTo {
        operationMode = .charge(load: .zero)
        return heat
      }
    } else { // Energy deficit
      if relativeCharge > dischargeToTurbine {
        operationMode = .discharge(load: load)
      }
    }
    return .zero
  }

  /// Adjusts the design mass flow in the power block,
  /// and determines the heat flow to the storage.
  static func demandStrategy(
    storage: Storage,
    powerBlock: inout PowerBlock,
    heatFlow: ThermalEnergy) -> ThermalEnergy
  {
   // var demand = DateTime.current.isDaytime ? 0.5 : heatFlow.demand.megaWatt
    switch parameter.strategy {
    case .always: return strategyAlways(
      storage: storage,
      powerBlock: &powerBlock,
      heatFlow: heatFlow)
    case .demand: return strategyDemand(
      storage: storage,
      powerBlock: &powerBlock,
      heatFlow: heatFlow)
    // parameter.strategy = "Ful" // Booster or Shifter
    case .shifter: return strategyShifter(
      storage: storage,
      powerBlock: &powerBlock,
      heatFlow: heatFlow)
    }
  }
  /// Power Block delivers Power to Grid according to Demand in Grid
  static func strategyDemand(
    storage: Storage,
    powerBlock: inout PowerBlock,
    heatFlow: ThermalEnergy) -> ThermalEnergy
  {
    var heatFlow = heatFlow
    heatFlow.storage = heatFlow.balance  // [MW]

    if parameter.heatExchangerRestrictedMin {
      // avoiding input to storage lower than minimal HXs capacity
      let maxMassFlow = SolarField.parameter.maxMassFlow.rate

      heatFlow.toStorageMin.megaWatt = parameter.heatExchangerMinCapacity
        * HeatExchanger.parameter.heatFlowHTF
        * (1 - storage.designMassFlow.rate / maxMassFlow)
        / (storage.designMassFlow.rate / maxMassFlow)

      if case 0..<heatFlow.toStorageMin.megaWatt = heatFlow.storage.megaWatt {
        heatFlow.demand -= heatFlow.toStorageMin - heatFlow.storage
        powerBlock.massFlow.rate = heatFlow.demand.kiloWatt / HeatExchanger.capacity
        heatFlow.storage = heatFlow.toStorageMin
      }
    }
    return heatFlow
  }

  /// Power Block delivers always design Power to Grid
  static func strategyAlways(
    storage: Storage,
    powerBlock: inout PowerBlock,
    heatFlow: ThermalEnergy) -> ThermalEnergy
  {
    var heatFlow = heatFlow

    heatFlow.storage = heatFlow.balance // [MW]

    if parameter.heatExchangerRestrictedMin {
      // avoiding input to storage lower than minimal HXs capacity
      let maxMassFlow = SolarField.parameter.maxMassFlow.rate
      let heatFlowRate = HeatExchanger.parameter.heatFlowHTF

      heatFlow.toStorageMin.megaWatt = heatFlowRate
        * (1 - storage.designMassFlow.rate / maxMassFlow)
        / (storage.designMassFlow.rate / maxMassFlow)

      if case 0..<heatFlow.toStorageMin.megaWatt = heatFlow.storage.megaWatt {
        powerBlock.massFlow.rate = (heatFlowRate
          - (heatFlow.toStorageMin - heatFlow.storage).megaWatt) * 1_000
          / HeatExchanger.capacity

        heatFlow.storage = heatFlow.toStorageMin
      }
    }
    return heatFlow
  }

  static func strategyShifter(
    storage: Storage,
    powerBlock: inout PowerBlock,
    heatFlow: ThermalEnergy) -> ThermalEnergy
  {
    var heatFlow = heatFlow
    let steamTurbine = SteamTurbine.parameter

    let heatExchanger = HeatExchanger.parameter

    let dniDay = BlackBoxModel.meteoData!.currentDay.sum
    var heatProductionLoad: Ratio = 0.0

    if parameter.exception.contains(DateTime.current.month) {
      heatProductionLoad = parameter.heatProductionLoadSummer
      if dniDay > parameter.badDNIsummer * 1_000 {
        // sunny day, TES can be fully charged also by running TB at full load
        heatProductionLoad = 1.0
      }
    } else {
      heatProductionLoad = parameter.heatProductionLoadWinter
      if dniDay > parameter.badDNIwinter * 1_000 {
        // sunny day, TES can be fully charged also by running TB at full load
        heatProductionLoad = 1.0
      }
    }
    // Not enough production for POB demand load (e.g. at the beginning of the day)
    if heatFlow.production > .zero { // heatFlow.solar > 0
      if heatFlow.production < heatFlow.demand,
        storage.relativeCharge < parameter.chargeTo,
        DateTime.isDaytime
      {
        powerBlock.designMassFlow.rate =
          min(heatProductionLoad.quotient * heatFlow.demand.kiloWatt, heatFlow.production.kiloWatt)
           / HeatExchanger.capacity

        // TES gets the rest available
        heatFlow.storage.megaWatt = heatFlow.production.megaWatt - min(
          heatProductionLoad.quotient * heatFlow.demand.megaWatt,
          heatFlow.production.megaWatt
        )

        Storage.heatExchangerRestrictedMax(heatFlow: &heatFlow.storage)

      } else if heatFlow.production < heatFlow.demand,
        storage.relativeCharge >= parameter.chargeTo
      {
        // Qsol not enough for POB demand load (e.g. at the end of the day) and TES is full
        powerBlock.designMassFlow.rate = heatFlow.demand.kiloWatt / HeatExchanger.capacity
        // send all to POB and if needed discharge TES
        heatFlow.storage = heatFlow.balance // [MW]

        if parameter.heatExchangerRestrictedMax {
          heatFlow.storage.megaWatt = max(
            heatFlow.storage.megaWatt, -parameter.heatExchangerCapacity
          )
        } else {
          let value = steamTurbine.power.max
            / steamTurbine.efficiencyNominal
            / heatExchanger.efficiency
            // signs below changed
          if heatFlow.storage.megaWatt > -value {
            heatFlow.storage.megaWatt = -value
          }
        }

      } else if heatFlow.production > heatFlow.demand,
        storage.relativeCharge < parameter.chargeTo,
        powerBlock.massFlow >= powerBlock.designMassFlow
      {
        // more Qsol than needed by POB and TES is not full
        heatFlow.demand *= heatProductionLoad.quotient
        powerBlock.designMassFlow.rate = heatFlow.demand.kiloWatt / HeatExchanger.capacity

        heatFlow.storage = heatFlow.balance  // [MW]
        // TES gets the rest available

        if parameter.heatExchangerRestrictedMax,
          heatFlow.storage.megaWatt > parameter.heatExchangerCapacity {
          // rest heat to TES is too high, use more heat to POB
          powerBlock.designMassFlow.rate =
            (heatFlow.production.megaWatt - parameter.heatExchangerCapacity)
              / HeatExchanger.capacity

          heatFlow.storage.megaWatt = parameter.heatExchangerCapacity
        }
      }
    }
    return heatFlow
  }
}
