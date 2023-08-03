//
//  Copyright 2023 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import DateExtensions
import Units

/// A struct representing the state and functions for mapping the storage.
struct Storage: Parameterizable, HeatTransfer {
  let name = Storage.parameter.name

  /// The temperature of the storage system (inlet and outlet).
  var temperature: (inlet: Temperature, outlet: Temperature)

  /// The mass flow rate in the storage system.
  var massFlow: MassFlow = .zero

  /// The current operation mode of the storage system.
  var operationMode: OperationMode

  /// The temperature differences between HTF and salt (cold and hot).
  var dT_HTFsalt: (cold: Double, hot: Double)

  /// The temperatures of the hot and cold tanks in the storage system.
  var temperatureTank: Temperatures

  /// The anti-freeze temperature used in freeze protection.
  var antiFreezeTemperature: Double = 270.0

  /// The salt properties and masses in the storage system.
  var salt = Salt()

  /// The relative charge in the storage system.
  var relativeCharge: Ratio

  /// Returns the fixed initial state of the storage system.
  static let initialState = Storage(
    operationMode: .noOperation,
    temperature: (560.0, 660.0),
    temperatureTanks: (566.0, 666.0)
  )

  /// The static parameters for the storage system.
  public static var parameter: Parameter = Parameters.st

  // Functions

  /// Restricts the heat flow to the heat exchanger based on certain conditions.
  ///
  /// - Parameter heatFlow: The thermal power flowing into the storage system.
  fileprivate static func heatExchangerRestrictedMax(heatFlow: inout Power) {
    // Calculate the threshold based on parameters.
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
    // Restrict the heat flow to the threshold if needed.
    heatFlow.megaWatt = min(heatFlow.megaWatt, threshold)
  }

  /// Decides whether to charge or discharge the storage system based on the heat balance.
  ///
  /// - Parameter heat: The thermal power available for charging or discharging.
  /// - Returns: The remaining thermal power after charging or discharging.
  mutating func chargeOrDischarge(_ heat: Power) -> Power {
    let chargeTo = Storage.parameter.chargeTo
    let dischargeToTurbine = Storage.parameter.dischargeToTurbine

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

  /// Adjusts the design mass flow in the power block and determines the heat flow to the storage.
  ///
  /// - Parameters:
  ///   - powerBlock: The power block in the system.
  ///   - heatFlow: The thermal energy flow in the system.
  /// - Returns: The thermal energy flow after adjustment.
  func demandStrategy(
    powerBlock: inout PowerBlock,
    heatFlow: ThermalEnergy) -> ThermalEnergy
  {
    // var demand = DateTime.current.isDaytime ? 0.5 : heatFlow.demand.megaWatt
    switch Storage.parameter.strategy {
    case .always: return strategyAlways(
      powerBlock: &powerBlock,
      heatFlow: heatFlow)
    case .demand: return strategyDemand(
      powerBlock: &powerBlock,
      heatFlow: heatFlow)
    // parameter.strategy = "Ful" // Booster or Shifter
    case .shifter: return strategyShifter(
      powerBlock: &powerBlock,
      heatFlow: heatFlow)
    }
  }

  /// Adjusts the heat flow to the storage system based on the demand strategy (delivers power according to demand in the grid).
  ///
  /// - Parameters:
  ///   - powerBlock: The power block in the system.
  ///   - heatFlow: The thermal energy flow in the system.
  /// - Returns: The thermal energy flow after adjustment.
  func strategyDemand(
    powerBlock: inout PowerBlock,
    heatFlow: ThermalEnergy) -> ThermalEnergy
  {
    var heatFlow = heatFlow

    // Set the storage power to the heat balance.
    heatFlow.storage = heatFlow.balance // [MW]

    if Storage.parameter.heatExchangerRestrictedMin {
      // Avoiding input to storage lower than minimal HXs capacity.
      let maxMassFlow = SolarField.parameter.maxMassFlow.rate
      let massFlow = MassFlow(
        (1 - Storage.parameter.massFlowShare.quotient)
          * SolarField.parameter.maxMassFlow.rate
      )
      heatFlow.toStorageMin.megaWatt = Storage.parameter.heatExchangerMinCapacity
        * HeatExchanger.parameter.heatFlowHTF
        * (1 - massFlow.rate / maxMassFlow)
        / (massFlow.rate / maxMassFlow)

      if case 0..<heatFlow.toStorageMin.megaWatt = heatFlow.storage.megaWatt {
        heatFlow.demand -= heatFlow.toStorageMin - heatFlow.storage
        powerBlock.massFlow.rate = heatFlow.demand.kiloWatt / HeatExchanger.capacity
        heatFlow.storage = heatFlow.toStorageMin
      }
    }
    return heatFlow
  }

  /// Adjusts the heat flow to the storage system based on the demand strategy (always delivers design power).
  ///
  /// - Parameters:
  ///   - powerBlock: The power block in the system.
  ///   - heatFlow: The thermal energy flow in the system.
  /// - Returns: The thermal energy flow after adjustment.
  func strategyAlways(
    powerBlock: inout PowerBlock,
    heatFlow: ThermalEnergy) -> ThermalEnergy
  {
    var heatFlow = heatFlow
    // Set the storage power to the heat balance.
    heatFlow.storage = heatFlow.balance // [MW]

    if Storage.parameter.heatExchangerRestrictedMin {
      // Avoiding input to storage lower than minimal HXs capacity.
      let maxMassFlow = SolarField.parameter.maxMassFlow.rate
      let heatFlowRate = HeatExchanger.parameter.heatFlowHTF
      let massFlow = MassFlow(
        (1 - Storage.parameter.massFlowShare.quotient)
          * SolarField.parameter.maxMassFlow.rate
      )
      heatFlow.toStorageMin.megaWatt = heatFlowRate
        * (1 - massFlow.rate / maxMassFlow)
        / (massFlow.rate / maxMassFlow)

      if case 0..<heatFlow.toStorageMin.megaWatt = heatFlow.storage.megaWatt {
        powerBlock.massFlow.rate = (heatFlowRate
          - (heatFlow.toStorageMin - heatFlow.storage).megaWatt) * 1_000
          / HeatExchanger.capacity

        heatFlow.storage = heatFlow.toStorageMin
      }
    }
    return heatFlow
  }

  /// Adjusts the heat flow to the storage system based on the demand strategy (power block delivers power to the grid).
  ///
  /// - Parameters:
  ///   - powerBlock: The power block in the system.
  ///   - heatFlow: The thermal energy flow in the system.
  /// - Returns: The thermal energy flow after adjustment.
  func strategyShifter(
    powerBlock: inout PowerBlock,
    heatFlow: ThermalEnergy) -> ThermalEnergy
  {
    var heatFlow = heatFlow
    let steamTurbine = SteamTurbine.parameter
    let heatExchanger = HeatExchanger.parameter

    // Calculate DNI and heat production load for different seasons.
    let dniDay = 0.0 //BlackBoxModel.meteoData!.currentDay.sum
    var heatProductionLoad: Ratio = 0.0

    if Storage.parameter.exception.contains(DateTime.current.month) {
      heatProductionLoad = Storage.parameter.heatProductionLoadSummer
      if dniDay > Storage.parameter.badDNIsummer * 1_000 {
        // sunny day, TES can be fully charged also by running TB at full load
        heatProductionLoad = 1.0
      }
    } else {
      heatProductionLoad = Storage.parameter.heatProductionLoadWinter
      if dniDay > Storage.parameter.badDNIwinter * 1_000 {
        // sunny day, TES can be fully charged also by running TB at full load
        heatProductionLoad = 1.0
      }
    }

    if heatFlow.production > .zero { // heatFlow.solar > 0
      // More solar production than needed by power block.
      if heatFlow.production < heatFlow.demand,
        relativeCharge < Storage.parameter.chargeTo,
        DateTime.isDaytime
      {
        // Calculate the mass flow rate for charging the storage.
        powerBlock.massFlow.rate = min(
          heatProductionLoad.quotient * heatFlow.demand.kiloWatt,
          heatFlow.production.kiloWatt
        ) / HeatExchanger.capacity

        // Store the remaining thermal energy in the storage.
        heatFlow.storage.megaWatt = heatFlow.production.megaWatt - min(
          heatProductionLoad.quotient * heatFlow.demand.megaWatt,
          heatFlow.production.megaWatt
        )

        Storage.heatExchangerRestrictedMax(heatFlow: &heatFlow.storage)

      } else if heatFlow.production < heatFlow.demand,
        relativeCharge >= Storage.parameter.chargeTo
      {
        // Qsol not enough for power block demand load and storage is full.
        // Send all power to power block and discharge storage if needed.
        powerBlock.massFlow.rate = heatFlow.demand.kiloWatt / HeatExchanger.capacity
        heatFlow.storage = heatFlow.balance // [MW]

        if Storage.parameter.heatExchangerRestrictedMax {
          heatFlow.storage.megaWatt = max(
            heatFlow.storage.megaWatt,
            -Storage.parameter.heatExchangerCapacity
          )
        } else {
          let value = steamTurbine.power.max
            / steamTurbine.efficiencyNominal
            / heatExchanger.efficiency
          // Signs below changed
          if heatFlow.storage.megaWatt > -value {
            heatFlow.storage.megaWatt = -value
          }
        }

      } else if heatFlow.production > heatFlow.demand,
        relativeCharge < Storage.parameter.chargeTo,
        powerBlock.massFlow >= HeatExchanger.designMassFlow
      {
        // More Qsol than needed by power block and storage is not full.
        heatFlow.demand *= heatProductionLoad.quotient
        powerBlock.massFlow.rate = heatFlow.demand.kiloWatt / HeatExchanger.capacity

        heatFlow.storage = heatFlow.balance // [MW]
        // Store the remaining thermal energy in the storage.

        if Storage.parameter.heatExchangerRestrictedMax,
          heatFlow.storage.megaWatt > Storage.parameter.heatExchangerCapacity
        {
          // Rest heat to storage is too high, use more heat for power block.
          powerBlock.massFlow.rate = (heatFlow.production.megaWatt - Storage.parameter.heatExchangerCapacity)
            / HeatExchanger.capacity

          heatFlow.storage.megaWatt = Storage.parameter.heatExchangerCapacity
        }
      }
    }
    return heatFlow
  }
}
