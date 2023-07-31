//
//  Copyright 2023 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

public struct Parameters: Codable {

  var availability = Availability.current
  var simulation = Simulation.parameter
  var initialValues = Simulation.initialValues
  var time = Simulation.time
  var tariff = Simulation.tariff
  var layout = Design.layout
  var heatTransferFluid = [SolarField.parameter.HTF, Storage.parameter.HTF.properties]
  var solarField = SolarField.parameter
  var collector = Collector.parameter
  var heater = Heater.parameter
  var heatExchanger = HeatExchanger.parameter
  var boiler = Boiler.parameter
  var wasteHeatRecovery = WasteHeatRecovery.parameter
  var gasTurbine = GasTurbine.parameter
  var steamTurbine = SteamTurbine.parameter
  var powerBlock = PowerBlock.parameter
  var storage = Storage.parameter

  public init() {}
  
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
