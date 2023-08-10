// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import Units

extension Storage {
  /// The operation mode options for the storage system.
  enum OperationMode {
    case noOperation
    case discharge(load: Ratio)
    case charge(load: Ratio)
    case preheat
    case fossilCharge
    case freezeProtection

    /// The discharge load ratio associated with the operation mode. It returns zero if the mode is not `discharge`.
    var dischargeLoad: Ratio {
      if case .discharge(let load) = self { return load } else { return .zero }
    }
  }

  /// Perform the thermal power and parasitics calculation for the storage system.
  ///
  /// This function calculates the thermal power and parasitics for the storage system based on its current operation mode.
  ///
  /// - Parameters:
  ///   - storage: The storage system. (inout)
  ///   - solarField: The solar field supplying heat to the storage system. (inout)
  ///   - steamTurbine: The steam turbine in the system. (inout)
  ///   - powerBlock: The power block in the system. (inout)
  ///   - nightHour: The hour of the night. Default is 12.0. (Default: 12.0)
  ///   - heatFlow: The thermal energy flow in the system. (inout)
  /// - Returns: A tuple containing the thermal power and parasitics for the storage system.
  static func perform(
    storage: inout Storage, solarField: inout SolarField,
    steamTurbine: inout SteamTurbine, powerBlock: inout PowerBlock,
    nightHour: Double = 12.0, heatFlow: inout ThermalEnergy
  ) -> (Power, Power) {
    let thermalPower: Power
    let parasitics: Power
    // Switch based on the storage system's operation mode.
    switch storage.operationMode {
    case .noOperation:
      // No operation mode, so the temperatures remain constant.
      storage.massFlow.rate = .zero
      thermalPower = .zero
      parasitics = Storage.parasitics(storage)
    case .charge:
      // Charge operation mode, calculate the thermal power and parasitics for charging the storage.
      thermalPower = storageCharge(
        storage: &storage, solarField: &solarField, heatFlow: &heatFlow)
      parasitics = Storage.parasitics(storage)
    case .fossilCharge:
      // Fossil charge operation mode, calculate the thermal power and parasitics for fossil charging the storage.
      thermalPower = storageFossilCharge(
        storage: &storage, powerBlock: &powerBlock)
      parasitics = Storage.parasitics(storage)
    case .discharge(let load):
      // Discharge operation mode, calculate the thermal power and parasitics for discharging the storage.
      if load.isZero {
        // The load is zero, so calculate it only once a day.
        let l = storage.dischargeLoad(nightHour)
        storage.operationMode = .discharge(load: l)
      }
      // Calculate the thermal power and parasitics for discharging the storage.
      (thermalPower, parasitics) = storageDischarge(
        storage: &storage, powerBlock: &powerBlock,
        steamTurbine: &steamTurbine, solarField: solarField,
        heatSolar: heatFlow.production.megaWatt, outletTemperature)
    case .preheat:
      // Preheat operation mode, calculate the thermal power and parasitics for preheating the storage.
      (thermalPower, parasitics) = storagePreheat(
        storage: &storage, powerBlock: powerBlock, solarField: solarField,
        outletTemperature)
    case .freezeProtection:
      // Freeze protection operation mode, adjust the storage system for freeze protection.
      storageFreezeProtection(
        storage: &storage, solarField: &solarField, powerBlock: powerBlock)
      thermalPower = .zero
      parasitics = Storage.parasitics(storage)
    }
    return (thermalPower, parasitics)
  }

  /// Calculate the outlet temperature of the storage system based on its operation mode.
  ///
  /// This function calculates the outlet temperature of the storage system based on its current operation mode.
  ///
  /// - Parameter status: The status of the storage system.
  /// - Returns: The calculated outlet temperature.
  static func outletTemperature(_ status: Storage) -> Temperature {
    if case .charge = status.operationMode {
      return status.temperatureTank.cold + 7
    } else if case .discharge = status.operationMode {
      return status.temperatureTank.hot - 7
    }
    return status.temperature.inlet
  }

  /// Calculate the mass flow rate for the storage system based on the solar field's operation mode.
  ///
  /// This function calculates the mass flow rate for the storage system based on the solar field's operation mode and heat exchanger efficiency.
  ///
  /// - Parameter solarField: The solar field supplying heat to the storage system.
  private mutating func massFlow(solarField: SolarField) {
    let dischargeLoad = operationMode.dischargeLoad.quotient
    let eff = Storage.parameter.heatExchangerEfficiency
    // Calculate the mass flow rate based on the solar field's operation mode.
    switch solarField.operationMode {
    case .track, .defocus(_):
      massFlow.rate =
        (HeatExchanger.designMassFlow.rate / eff) - solarField.massFlow.rate
    default:
      massFlow.rate = dischargeLoad * HeatExchanger.designMassFlow.rate / eff
    }
  }

  /// Charges the storage system with heat from the solar field.
  ///
  /// This function charges the storage system by adjusting the mass flow and outlet temperature. It calculates the thermal power required for the charging process.
  ///
  /// - Parameters:
  ///   - storage: The storage system to charge. (inout)
  ///   - solarField: The solar field supplying heat to the storage system. (inout)
  ///   - heatFlow: The thermal energy flow in the system. (inout)
  /// - Returns: The thermal power for charging the storage system.
  private static func storageCharge(
    storage: inout Storage, solarField: inout SolarField,
    heatFlow: inout ThermalEnergy
  ) -> Power {
    // Calculate the mass flow in the storage system based on the solar field.
    storage.massFlow = solarField.massFlow
    storage.massFlow -= HeatExchanger.designMassFlow
    storage.inletTemperature(outlet: solarField)
    // Adjust the mass flow based on the heat exchanger efficiency.
    storage.massFlow.adjust(factor: parameter.heatExchangerEfficiency)
    // Initialize variables to store the thermal power and fitted temperature.
    var thermalPower: Power = .zero
    var fittedTemperature: Double

    // Check if the second coefficient of temperatureCharge is greater than 0 (usually = 0).
    if parameter.temperatureCharge.coefficients[1] > 0 {
      // Calculate the fitted temperature based on the relative charge of the storage system.
      fittedTemperature =
        storage.relativeCharge < 0.5
        ? 1 : parameter.temperatureCharge2(storage.relativeCharge)
      // Adjust the fitted temperature based on the design temperature and temperatureCharge coefficients.
      fittedTemperature *=
        parameter.designTemperature.cold.kelvin
        - parameter.temperatureCharge.coefficients[2]
    } else {
      if case .indirect = parameter.type {
        // Calculate the fitted temperature for the indirect storage type.
        fittedTemperature = -Temperature.absoluteZeroCelsius
        fittedTemperature +=
          parameter.temperatureCharge.coefficients[0]
          - (parameter.designTemperature.cold.kelvin
            - storage.temperatureTank.cold.kelvin)
      } else {
        // For other storage types, set the fitted temperature to the current cold temperature of the storage tank.
        fittedTemperature = storage.temperatureTank.cold.kelvin
      }
    }

    // Set the outlet temperature of the storage system based on the calculated fitted temperature.
    storage.outletTemperature(kelvin: fittedTemperature)

    // Calculate the thermal power based on the mass flow rate and specific heat capacity of the storage material.
    thermalPower.kiloWatt = storage.massFlow.rate * -storage.heat

    // Check if the storage type is indirect, the heat exchanger size is restricted, and the thermal power exceeds the heat exchanger capacity.
    if case .indirect = parameter.type, parameter.heatExchangerRestrictedMax,
      abs(thermalPower.megaWatt) > parameter.heatExchangerCapacity
    {
      // Limit the thermal power to the heat exchanger capacity.
      thermalPower *= parameter.heatExchangerCapacity
      // Update the mass flow rate based on the limited thermal power and specific heat capacity.
      storage.massFlow.rate = thermalPower.kiloWatt / storage.heat
      // FIXME: powerBlock.massFlow = powerBlock.massFlow
      // added to avoid an increase in PB massFlow
      if case .demand = parameter.strategy {
        // Too much power from the sun, dump the excess heat.
        heatFlow.dumping.megaWatt +=
          heatFlow.production.megaWatt - HeatExchanger.parameter.heatFlowHTF
          + thermalPower.megaWatt
      } else {
        // Adjust the heat flow for charging the storage system and reduce the HTF mass flow in the solar field.
        heatFlow.dumping +=
          heatFlow.production - heatFlow.demand + thermalPower
      }

      // Update the solar field mass flow based on the heat exchanger design mass flow and storage mass flow.
      solarField.massFlow = HeatExchanger.designMassFlow + storage.massFlow

      // Calculate the heat flow from the solar field based on the updated mass flow rate.
      heatFlow.solar.kiloWatt = solarField.massFlow.rate * solarField.heat

      // Set the heat production in the system to the heat flow from the solar field.
      heatFlow.production = heatFlow.solar
    }

    return thermalPower
  }
  private static func storageFossilCharge(
    storage: inout Storage, powerBlock: inout PowerBlock
  ) -> Power {
    storage.massFlow = powerBlock.massFlow
    storage.setTemperature(inlet: Heater.parameter.nominalTemperatureOut)

    var fittedTemperature: Double
    if parameter.temperatureCharge.coefficients[1] > 0 {  // usually = 0
      fittedTemperature =
        storage.relativeCharge < 0.5
        ? 1 : parameter.temperatureCharge2(storage.relativeCharge)
      fittedTemperature *=
        parameter.designTemperature.cold.kelvin
        - parameter.temperatureCharge.coefficients[2]
    } else {
      fittedTemperature = -Temperature.absoluteZeroCelsius
      fittedTemperature +=
        parameter.temperatureCharge.coefficients[0]
        - (parameter.designTemperature.cold.kelvin
          - storage.temperatureTank.cold.kelvin)
    }
    storage.outletTemperature(kelvin: fittedTemperature)

    var thermalPower: Power = .zero
    // heat can be stored
    thermalPower.kiloWatt = -storage.massFlow.rate * storage.heat
    // limit the size of the salt-oil heat exchanger
    if parameter.heatExchangerRestrictedMax,
      abs(thermalPower.megaWatt) > parameter.heatExchangerCapacity
    {
      thermalPower *= parameter.heatExchangerCapacity
      storage.massFlow.rate = thermalPower.kiloWatt / storage.heat
      powerBlock.massFlow = storage.massFlow
    }
    return thermalPower
  }
  /// Discharges the storage system, adjusting the mass flow and outlet temperature.
  ///
  /// This function discharges the storage system by adjusting the mass flow and outlet temperature. It calculates the thermal power and parasitic power required for the discharge process.
  ///
  /// - Parameters:
  ///   - storage: The storage system to discharge. (inout)
  ///   - powerBlock: The power block associated with the system. (inout)
  ///   - steamTurbine: The steam turbine associated with the system. (inout)
  ///   - solarField: The solar field supplying heat to the storage system. (input)
  ///   - heatSolar: The amount of heat supplied by the solar field. (input)
  ///   - outletTemperature: A function that calculates the outlet temperature of the storage system. (input)
  /// - Returns: A tuple containing the thermal power and parasitic power for discharging the storage system.
  private static func storageDischarge(
    storage: inout Storage, powerBlock: inout PowerBlock,
    steamTurbine: inout SteamTurbine, solarField: SolarField,
    heatSolar: Double, _ outletTemperature: (Storage) -> Temperature
  ) -> (Power, Power) {
    // Set the inlet temperature of the storage system from the power block output.
    storage.inletTemperature(outlet: powerBlock)
    // Calculate the mass flow in the storage system based on the design mass flow and power block mass flow.
    storage.massFlow = HeatExchanger.designMassFlow - powerBlock.massFlow
    // Adjust the mass flow based on the discharge load quotient of the storage system.
    storage.massFlow.rate *= storage.operationMode.dischargeLoad.quotient
    // Calculate and set the outlet temperature of the storage system using the provided function.
    storage.temperature.outlet = outletTemperature(storage)
    // Initialize variables to store the thermal power and parasitic power.
    var thermalPower: Power = .zero
    var parasitics: Power = .zero
    // Loop until the outlet temperature of the mixing outlets is above the minimum temperature.
    while true {
      // Calculate the thermal power based on the mass flow rate and specific heat capacity of the storage material.
      thermalPower.kiloWatt = storage.massFlow.rate * storage.heat
      // Check if the size of the salt-oil heat exchanger is restricted, and if the thermal power exceeds the capacity of the heat exchanger.
      if parameter.heatExchangerRestrictedMax,
        abs(thermalPower.megaWatt) > parameter.heatExchangerCapacity
      {
        // If the thermal power exceeds the capacity, limit it to the heat exchanger capacity.
        thermalPower *= parameter.heatExchangerCapacity
        // Update the mass flow rate based on the limited thermal power and specific heat capacity.
        storage.massFlow.rate = thermalPower.kiloWatt / storage.heat
        // Check the operation mode of the solar field to determine how to adjust the power block mass flow.
        if case .freeze = solarField.operationMode {
          powerBlock.massFlow.rate =
            storage.massFlow.rate * parameter.heatExchangerEfficiency / 0.97  // - solarField.massFlow
        } else {
          // Adjust the power block mass flow based on the new mass flow rate and heat exchanger efficiency.
          powerBlock.massFlow.rate =
            (storage.massFlow + solarField.massFlow).rate
            * parameter.heatExchangerEfficiency / 0.97
        }
      }
      // Calculate the maximum load and efficiency of the steam turbine.
      let maxLoad: Double = 1

      let efficiency = steamTurbine.perform(
        heatExchanger: solarField.temperature.outlet,
        ambient: Temperature(celsius: 20))

      // Calculate the ratio of heat supplied by the solar field and thermal power to the maximum power of the steam turbine.
      let ratio =
        (heatSolar + thermalPower.megaWatt)
        / (SteamTurbine.parameter.power.max / efficiency.quotient)
      // Adjust the steam turbine load based on the calculated ratio and the maximum load.
      steamTurbine.adjust(load: Ratio(abs(ratio), cap: maxLoad))
      // Calculate the outlet temperature of the mixing outlets of the solar field and storage system.
      let mixingOutlets = SolarField.parameter.HTF
        .calculateMixedOutletTemperature
      let mixTemp = mixingOutlets(solarField, storage)
      // Define the minimum allowable outlet temperature.
      let minTemp = Temperature(celsius: 310.0)
      // Check if the mixing outlet temperature is above the minimum temperature with some tolerance.
      if mixTemp.kelvin > minTemp.kelvin - Simulation.parameter.tempTolerance
        * 2
      {
        // The outlet temperature is acceptable, break out of the loop.
        thermalPower.kiloWatt = storage.massFlow.rate * storage.heat
        parasitics = Storage.parasitics(storage)
        break
      } else if storage.massFlow.rate <= 0.05
        * HeatExchanger.designMassFlow.rate
      {
        // The mass flow rate is too low, set the thermal power and mass flow rate to zero, and set the storage operation mode to no operation.
        thermalPower = 0.0
        storage.operationMode = .noOperation
        parasitics = .zero
        storage.massFlow = 0.0
        break
      }
      // Reduce the mass flow rate by 3% (factor of 0.97) and continue the loop.
      storage.massFlow.adjust(factor: 0.97)
    }
    return (thermalPower, parasitics)  // [MW]
  }
  /// Preheats the storage system and calculates the thermal power and parasitic power.
  ///
  /// This function preheats the storage system by adjusting the mass flow and outlet temperature. It calculates the thermal power and parasitic power required for preheating.
  ///
  /// - Parameters:
  ///   - storage: The storage system to preheat. (inout)
  ///   - powerBlock: The power block associated with the system. (input)
  ///   - solarField: The solar field supplying heat to the storage system. (input)
  ///   - outletTemperature: A function that calculates the outlet temperature of the storage system. (input)
  /// - Returns: A tuple containing the thermal power and parasitic power for preheating the storage system.
  private static func storagePreheat(
    storage: inout Storage, powerBlock: PowerBlock, solarField: SolarField,
    _ outletTemperature: (Storage) -> Temperature
  ) -> (Power, Power) {
    // Calculate the mass flow in the storage system from the power block output.
    storage.massFlow = powerBlock.massFlow
    storage.inletTemperature(inlet: powerBlock)
    // Subtract the mass flow supplied by the solar field from the storage system's mass flow.
    storage.massFlow -= solarField.massFlow
    // Calculate and set the outlet temperature of the storage system using the provided function.
    storage.temperature.outlet = outletTemperature(storage)
    // Initialize variables to store the thermal power and parasitic power.
    var thermalPower: Power = .zero
    var parasitics: Power = .zero

    // Calculate the thermal power based on the mass flow rate and specific heat capacity of the storage material.
    thermalPower.kiloWatt = storage.massFlow.rate * storage.heat
    // Check if the size of the salt-oil heat exchanger is restricted, and if the thermal power exceeds the capacity of the heat exchanger.
    if parameter.heatExchangerRestrictedMax,
      abs(thermalPower.megaWatt) > parameter.heatExchangerCapacity
    {
      // If the thermal power exceeds the capacity, limit it to the heat exchanger capacity.
      thermalPower *= parameter.heatExchangerCapacity
      // Update the mass flow rate based on the limited thermal power and specific heat capacity.
      storage.massFlow.rate = thermalPower.kiloWatt / storage.heat
      // Recalculate and set the outlet temperature of the storage system with the updated mass flow rate.
      storage.temperature.outlet = outletTemperature(storage)
      // Recalculate the thermal power based on the updated mass flow rate and specific heat capacity.
      thermalPower.kiloWatt = -storage.massFlow.rate * storage.heat
    }
    // Calculate the parasitic power required for preheating the storage system.
    parasitics = Storage.parasitics(storage)

    return (thermalPower, parasitics)
  }
  /// Protects the storage system from freezing by adjusting the mass flow and outlet temperature.
  ///
  /// This function adjusts the mass flow in the solar field and sets the outlet temperature of the storage system to prevent freezing.
  ///
  /// - Parameters:
  ///   - storage: The storage system to protect from freezing. (inout)
  ///   - solarField: The solar field supplying the anti-freeze fluid. (inout)
  ///   - powerBlock: The power block associated with the system. (input)
  private static func storageFreezeProtection(
    storage: inout Storage, solarField: inout SolarField,
    powerBlock: PowerBlock
  ) {
    // Calculate the anti-freeze flow based on the specified quotient and the maximum mass flow rate.
    let antiFreeze = SolarField.parameter.antiFreezeFlow.quotient
    let maxMassFlow = SolarField.parameter.maxMassFlow.rate
    let antiFreezeFlow = MassFlow(antiFreeze * maxMassFlow)
    let splitfactor: Ratio = 0.4
    // Set the mass flow in the storage system and solar field header to the anti-freeze flow.
    storage.massFlow = antiFreezeFlow.adjusted(withFactor: splitfactor)
    solarField.header.massFlow = antiFreezeFlow

    storage.inletTemperature(inlet: powerBlock)
    var fittedTemperature = 0.0
    if Storage.parameter.temperatureCharge[1] > 0 {
      if Storage.parameter.temperatureDischarge.indices.contains(2) {
        // If temperatureDischarge contains an element at index 2, set the outlet temperature to a uniform temperature.
        storage.uniformTemperature()
      } else {
        // If temperatureDischarge does not contain an element at index 2, calculate the fitted temperature based on the relative charge.
        fittedTemperature =
          storage.relativeCharge > 0.5
          ? 1 : Storage.parameter.temperatureCharge2(storage.relativeCharge)
        // Set the outlet temperature based on the fitted temperature and the design hot temperature.
        storage.outletTemperature(
          kelvin: fittedTemperature
            * Storage.parameter.designTemperature.hot.kelvin)
      }
      // Set the outlet temperature based on the split factor and the inlet and outlet temperatures.
      storage.outletTemperature(
        kelvin: splitfactor.quotient * storage.outlet
          + (1 - splitfactor.quotient) * storage.inlet)
    } else {
      // If temperatureCharge at index 1 is not greater than 0, set the outlet temperature to the cold temperature of the storage tank.
      storage.temperature.outlet = storage.temperatureTank.cold
    }
  }
}

extension Storage.OperationMode: CustomStringConvertible {
  public var description: String {
    switch self {
    case .noOperation: return "No operation"
    case .charge(_): return "Charging"
    case .discharge(let load): return "Discharge \(load.singleBar)"
    case .freezeProtection: return "Freeze protection"
    default: return "No description"
    }
  }
}
