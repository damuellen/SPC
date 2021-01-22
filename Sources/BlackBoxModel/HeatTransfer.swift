//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

protocol HeatTransfer: CustomStringConvertible {
  var name: String { get }
  var massFlow: MassFlow { get set }
  var temperature: (inlet: Temperature, outlet: Temperature) { get set }
}

public struct Cycle: HeatTransfer {
  public var name: String
  public var massFlow: MassFlow
  public var temperature: (inlet: Temperature, outlet: Temperature)
}

extension Cycle {
    init(loop: String) {
    self.name = loop
    self.massFlow = 0.0
    let temperature = Simulation.initialValues.temperatureOfHTFinHCE
    self.temperature = (inlet: temperature, outlet: temperature)
  }

  init(name: String) {
    self.name = name
    self.massFlow = 0.0
    let temperature = Simulation.initialValues.temperatureOfHTFinPipes
    self.temperature = (inlet: temperature, outlet: temperature)
  }
}

extension HeatTransfer {
  var cycle: Cycle {
    Cycle(name: name, massFlow: massFlow, temperature: temperature)
  }

  var averageTemperature: Temperature {
    Temperature.average(temperature.inlet, temperature.outlet)
  }

  var minTemperature: Double {
    min(inletTemperature, outletTemperature)
  }

  var inletTemperature: Double { temperature.inlet.kelvin }

  var outletTemperature: Double { temperature.outlet.kelvin }

  var medium: HeatTransferFluid {
    SolarField.parameter.HTF
  }

  var deltaHeat: Heat {
    medium.deltaHeat(temperature.outlet, temperature.inlet)
  }

  public var description: String {  
    "  Mass flow rate:".padding(32) 
      + String(format: "%3.1f\n", massFlow.rate)
      + "  Temperatures:".padding(32) 
      + String(format: "%3.1f / %3.1f", temperature.inlet.celsius, temperature.outlet.celsius)
  }

  var values: [String] {
    [
      massFlow.rate.description,
      temperature.inlet.celsius.description,
      temperature.outlet.celsius.description,
    ]
  }

  var numericalForm: [Double] {
    [massFlow.rate, temperature.inlet.celsius, temperature.outlet.celsius]
  }

  mutating func formJoint(_ c1: HeatTransfer, _ c2: HeatTransfer) {
    temperature.inlet = medium.mixingTemperature(c1, c2)
    massFlow = c1.massFlow + c2.massFlow
  }

  mutating func merge(_ c1: HeatTransfer) {
    temperature.inlet = medium.mixingTemperature(self, c1)
    massFlow += c1.massFlow
  }

  mutating func inletTemperatureFromOutlet() {
    temperature.inlet = temperature.outlet
  }

  mutating func outletTemperatureFromInlet() {
    temperature.outlet = temperature.inlet
  }

  mutating func setTemperature(inlet: Temperature) {
    temperature.inlet = inlet
  }

  mutating func setTemperature(outlet: Temperature) {
    temperature.outlet = outlet
  }

  mutating func inletTemperature(kelvin: Double) {
    temperature.inlet = Temperature(kelvin)
  }

  mutating func outletTemperature(kelvin: Double) {
    temperature.outlet = Temperature(kelvin)
  }

  mutating func inletTemperature(outlet other: HeatTransfer) {
    temperature.inlet = other.temperature.outlet
  }

  mutating func inletTemperature(_ other: HeatTransfer) {
    temperature.inlet = other.temperature.inlet
  }

  mutating func outletTemperature(_ other: HeatTransfer) {
    temperature.outlet = other.temperature.outlet
  }
}

extension Collection where Element == HeatTransfer {
  var values: [String] {
    reduce(into: []) { $0.append(contentsOf: $1.values) }
  }
}
