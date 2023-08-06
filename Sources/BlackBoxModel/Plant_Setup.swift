// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import Utilities

extension Plant {
  /// Sets up the parameters for the plant components.
  ///
  /// This function is responsible for initializing and configuring the parameters of various plant components in the power plant or energy system. It ensures that the components are set up properly with appropriate values for their maximum power, mass flow rates, and other relevant parameters. Once the setup is complete, it returns an instance of the `Plant` class, representing the power plant with all its configured components.
  ///
  /// - Returns: An instance of the `Plant` class representing the power plant after setting up the parameters.
  ///
  /// The setup process involves the following steps:
  /// 1. Sets the maximum power of the steam turbine if not already set. The maximum power is determined based on the layout of the power block and various electrical parasitics associated with the power block.
  /// 2. Calculates the way lengths in the solar field based on the configuration of the solar collectors.
  /// 3. Sets the heat flow in the heat exchanger using the current heat flow value.
  /// 4. Adjusts waste heat recovery parameters if a gas turbine is present. The heat flow rate and recovery ratio are adjusted accordingly.
  /// 5. Sets the maximum mass flow rate in the solar field based on the heat flow rate of the heat exchanger.
  /// 6. Calculates edge factors for the solar field based on the arrangement of solar collectors.
  /// 7. Adjusts the maximum mass flow rate in the solar field if storage is present. The mass flow rate is adjusted to account for the presence of the storage system.
  static func setup() -> Plant {
    let steamTurbine = SteamTurbine.parameter
    let powerBlock = PowerBlock.parameter

    // Set maximum power of the steam turbine if not already set
    if steamTurbine.power.max == .zero {
      SteamTurbine.parameter.power.max =
        Design.layout.powerBlock
        + powerBlock.fixElectricalParasitics
        + powerBlock.nominalElectricalParasitics
        + powerBlock.electricalParasiticsStep[1]
    }

    // Calculate way lengths in the solar field
    SolarField.parameter.calculateWayLengths()

    // Set heat flow in the heat exchanger using the current heat flow
    HeatExchanger.parameter.heatFlowHTF = HeatExchanger.parameter.heatFlow()

    // Adjust waste heat recovery parameters if a gas turbine is present
    if Design.hasGasTurbine {
      let heatFlowRate = HeatExchanger.parameter.heatFlowHTF
      WasteHeatRecovery.parameter.ratioHTF =
        heatFlowRate / (steamTurbine.power.max - heatFlowRate)
    }

    // Set the maximum mass flow rate in the solar field
    let heatFlowRate = HeatExchanger.parameter.heatFlowHTF * 1_000
    SolarField.parameter.maxMassFlow = MassFlow(
      heatFlowRate / HeatExchanger.capacity
    )

    // Calculate edge factors for the solar field
    if Design.hasSolarField {
      let numberOfSCAsInRow = Double(SolarField.parameter.numberOfSCAsInRow)
      let edgeFactor1 =
        SolarField.parameter.distanceSCA / 2
        * (1 - 1 / numberOfSCAsInRow)
        / Collector.parameter.lengthSCA
      let edgeFactor2 =
        (1 + 1 / numberOfSCAsInRow)
        / Collector.parameter.lengthSCA / 2
      SolarField.parameter.edgeFactor = [edgeFactor1, edgeFactor2]

      // Adjust the maximum mass flow rate in the solar field if storage is present
      if Design.hasStorage {
        SolarField.parameter.maxMassFlow = MassFlow(
          SolarField.parameter.maxMassFlow.rate / Storage.parameter.massFlowShare.quotient
        )
      }
    }
    return Plant()
  }

  /// Returns a string containing descriptions of the fixed parameters for each component of the plant.
  ///
  /// - Returns: A string containing descriptions of fixed parameters for each component.
  static var parameterDescriptions: String {
    decorated("Fixed Parameter") + "\n"
    + "HEAT TRANSFER FLUID\n\n\(SolarField.parameter.HTF)\n\n"
    + "HEATER\n\n\(Heater.parameter)\n"
    + "HEAT EXCHANGER\n\n\(HeatExchanger.parameter)\n"
    + "STEAM TURBINE\n\n\(SteamTurbine.parameter)\n"
    + "STORAGE\n\n\(Storage.parameter)\n"
    + "SOLAR FIELD\n\n\(SolarField.parameter)\n"
    + "COLLECTOR\n\n\(Collector.parameter)\n"
  }
}
