//
//  Copyright 2023 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

/// Structure representing all parameters used in a simulation.
struct Parameters: Codable {
  /// Availability configuration used in the simulation.
  var availability = Availability.current
  /// Simulation configuration parameters.
  var simulation = Simulation.parameter
  /// Initial values used in the simulation.
  var initialValues = Simulation.initialValues
  /// Time-related parameters used in the simulation.
  var time = Simulation.time
  /// Tariff configuration used in the simulation.
  var tariff = Simulation.tariff
  /// Design layout configuration used in the simulation.
  var layout = Design.layout
  /// Heat transfer fluid configurations used in the simulation.
  var heatTransferFluid = [SolarField.parameter.HTF, Storage.parameter.HTF.properties]
  /// Solar field configuration used in the simulation.
  var solarField = SolarField.parameter
  /// Collector configuration used in the simulation.
  var collector = Collector.parameter
  /// Heater configuration used in the simulation.
  var heater = Heater.parameter
  /// Heat exchanger configuration used in the simulation.
  var heatExchanger = HeatExchanger.parameter
  /// Boiler configuration used in the simulation.
  var boiler = Boiler.parameter
  /// Waste heat recovery configuration used in the simulation.
  var wasteHeatRecovery = WasteHeatRecovery.parameter
  /// Gas turbine configuration used in the simulation.
  var gasTurbine = GasTurbine.parameter
  /// Steam turbine configuration used in the simulation.
  var steamTurbine = SteamTurbine.parameter
  /// Power block configuration used in the simulation.
  var powerBlock = PowerBlock.parameter
  /// Storage configuration used in the simulation.
  var storage = Storage.parameter

  /// Default initializer that creates a new `Parameters` instance with default values.
  public init() {}
  
  /// Function call to update the simulation parameters with the values from this `Parameters` instance.
  /// 
  /// This function assigns the current property values to their corresponding global simulation parameters.
  func callAsFunction() {
    Availability.current = availability
    Simulation.parameter = simulation
    Simulation.initialValues = initialValues
    Simulation.time = time
    Simulation.tariff = tariff
    Design.layout = layout
    SolarField.parameter = solarField
    Collector.parameter = collector
    Heater.parameter = heater
    HeatExchanger.parameter = heatExchanger
    Boiler.parameter = boiler
    WasteHeatRecovery.parameter = wasteHeatRecovery
    GasTurbine.parameter = gasTurbine
    SteamTurbine.parameter = steamTurbine
    PowerBlock.parameter = powerBlock
    Storage.parameter = storage
    SolarField.parameter.HTF = heatTransferFluid[0]
  }
}

extension Parameters: CustomStringConvertible {
  /// Computed property that provides a textual description of the `Parameters` instance.
  public var description: String {
    """
    \(layout)
    \(simulation)
    \(initialValues)
    \(time)
    \(tariff)
    \(availability)
    \(solarField)
    \(collector)
    \(heater)
    \(heatExchanger)
    \(boiler)
    \(wasteHeatRecovery)
    \(gasTurbine)
    \(steamTurbine)
    \(powerBlock)
    \(storage)
    \(heatTransferFluid[0])
    \(heatTransferFluid[1])
    """
  }
}
