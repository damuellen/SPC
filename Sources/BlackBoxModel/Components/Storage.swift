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

extension Storage: CustomStringConvertible {
  public var description: String {
    "  Mode:".padding(20) + "\(operationMode)".padding(20)
    + relativeCharge.multiBar + "\n\n"
    + String(format: "  Mass flow: %3.1f kg/s", massFlow.rate).padding(28) 
    + String(format: " T in: %3.1f degC", temperature.inlet.celsius).padding(20) 
    + String(format: "T out: %3.1f degC", temperature.outlet.celsius).padding(20) 
    + "," + "  Temperature tanks".padding(28)
    + String(format: " cold: %3.1f degC", temperatureTank.cold.celsius).padding(20)
    + String(format: "  hot: %3.1f degC", temperatureTank.hot.celsius).padding(20)
    + "," + "  Salt mass".padding(28)
    + String(format: " cold: %3.0f t", salt.cold.kg / 1000).padding(20)
    + String(format: "  hot: %3.0f t", salt.hot.kg / 1000 ).padding(20)
    + ","
    + String(format: "  total: %3.0f t", salt.total.kg / 1000).padding(27)
    + String(format: "  active: %3.0f t", salt.active.kg / 1000).padding(21)
    + String(format: "  min: %3.0f t", salt.minimum.kg / 1000) .padding(20)
  }
}

extension Storage: MeasurementsConvertible {
  static var measurements: [(name: String, unit: String)] {
    [
      ("Storage|TankCold", "degC"), ("Storage|TankHot", "degC"),
      ("Storage|Charge", "percent")
    ]
  }

  var values: [Double] {
    [temperatureTank.cold.celsius, temperatureTank.hot.celsius, relativeCharge.percentage]
  }
}

/// This struct contains the state as well as the functions for mapping the storage
public struct Storage: Parameterizable, HeatTransfer {

  let name = Storage.parameter.name

  public internal(set) var temperature: (inlet: Temperature, outlet: Temperature)

  public internal(set) var massFlow: MassFlow = .zero

  /// Returns the operating state
  public internal(set) var operationMode: OperationMode

  public internal(set) var dT_HTFsalt: (cold: Double, hot: Double)

  public internal(set) var temperatureTank: Temperatures

  public internal(set) var antiFreezeTemperature: Double = 270.0

  public internal(set) var salt = Salt()

  public internal(set) var relativeCharge: Ratio

  /// Returns the fixed initial state.
  static let initialState = Storage(
    operationMode: .noOperation,
    temperature: (560.0, 660.0),
    temperatureTanks: (566.0, 666.0)
  )
  /// Returns the static parameters.
  public static var parameter: Parameter = Parameters.st

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
  /// Power Block delivers Power to Grid according to Demand in Grid
  func strategyDemand(
    powerBlock: inout PowerBlock,
    heatFlow: ThermalEnergy) -> ThermalEnergy
  {
    var heatFlow = heatFlow
    heatFlow.storage = heatFlow.balance  // [MW]

    if Storage.parameter.heatExchangerRestrictedMin {
      // avoiding input to storage lower than minimal HXs capacity
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

  /// Power Block delivers always design Power to Grid
  func strategyAlways(
    powerBlock: inout PowerBlock,
    heatFlow: ThermalEnergy) -> ThermalEnergy
  {
    var heatFlow = heatFlow

    heatFlow.storage = heatFlow.balance // [MW]

    if Storage.parameter.heatExchangerRestrictedMin {
      // avoiding input to storage lower than minimal HXs capacity
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

  func strategyShifter(
    powerBlock: inout PowerBlock,
    heatFlow: ThermalEnergy) -> ThermalEnergy
  {
    var heatFlow = heatFlow
    let steamTurbine = SteamTurbine.parameter

    let heatExchanger = HeatExchanger.parameter

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
    // Not enough production for POB demand load (e.g. at the beginning of the day)
    if heatFlow.production > .zero { // heatFlow.solar > 0
      if heatFlow.production < heatFlow.demand,
        relativeCharge < Storage.parameter.chargeTo,
        DateTime.isDaytime
      {
        powerBlock.massFlow.rate =
          min(heatProductionLoad.quotient * heatFlow.demand.kiloWatt, heatFlow.production.kiloWatt)
           / HeatExchanger.capacity

        // TES gets the rest available
        heatFlow.storage.megaWatt = heatFlow.production.megaWatt - min(
          heatProductionLoad.quotient * heatFlow.demand.megaWatt,
          heatFlow.production.megaWatt
        )

        Storage.heatExchangerRestrictedMax(heatFlow: &heatFlow.storage)

      } else if heatFlow.production < heatFlow.demand,
        relativeCharge >= Storage.parameter.chargeTo
      {
        // Qsol not enough for POB demand load (e.g. at the end of the day) and TES is full
        powerBlock.massFlow.rate = heatFlow.demand.kiloWatt / HeatExchanger.capacity
        // send all to POB and if needed discharge TES
        heatFlow.storage = heatFlow.balance // [MW]

        if Storage.parameter.heatExchangerRestrictedMax {
          heatFlow.storage.megaWatt = max(
            heatFlow.storage.megaWatt, -Storage.parameter.heatExchangerCapacity
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
        relativeCharge < Storage.parameter.chargeTo,
        powerBlock.massFlow >= HeatExchanger.designMassFlow
      {
        // more Qsol than needed by POB and TES is not full
        heatFlow.demand *= heatProductionLoad.quotient
        powerBlock.massFlow.rate = heatFlow.demand.kiloWatt / HeatExchanger.capacity

        heatFlow.storage = heatFlow.balance  // [MW]
        // TES gets the rest available

        if Storage.parameter.heatExchangerRestrictedMax,
          heatFlow.storage.megaWatt > Storage.parameter.heatExchangerCapacity {
          // rest heat to TES is too high, use more heat to POB
          powerBlock.massFlow.rate =
            (heatFlow.production.megaWatt - Storage.parameter.heatExchangerCapacity)
              / HeatExchanger.capacity

          heatFlow.storage.megaWatt = Storage.parameter.heatExchangerCapacity
        }
      }
    }
    return heatFlow
  }
}
