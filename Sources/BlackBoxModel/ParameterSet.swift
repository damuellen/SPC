//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

public struct ParameterSet: Codable {
  var tariff = Simulation.tariff
  var simulation = Simulation.parameter
  var initialValues = Simulation.initialValues
  var time = Simulation.time
 // var availability = Availability.current
  var layout = Design.layout
  var solarField = SolarField.parameter
  var collector = Collector.parameter
  var heater = Heater.parameter
//  var heatTransferFluid = HeatTransferFluid.parameter
  var heatExchanger = HeatExchanger.parameter
  var boiler = Boiler.parameter
  var wasteHeatRecovery = WasteHeatRecovery.parameter
  var gasTurbine = GasTurbine.parameter
  var steamTurbine = SteamTurbine.parameter
  var powerBlock = PowerBlock.parameter

  public init() {}
  
  func callAsFunction() {
    Simulation.tariff = tariff
    Simulation.parameter = simulation
    Simulation.initialValues = initialValues
    Simulation.time = time
  //  Availability.current = availability
    Design.layout = layout
    SolarField.parameter = solarField
    Collector.parameter = collector
    Heater.parameter = heater
 //   HeatTransferFluid.parameter = heatTransferFluid
    HeatExchanger.parameter = heatExchanger
    Boiler.parameter = boiler
    WasteHeatRecovery.parameter = wasteHeatRecovery
    GasTurbine.parameter = gasTurbine
    SteamTurbine.parameter = steamTurbine
    PowerBlock.parameter = powerBlock
  }
}
