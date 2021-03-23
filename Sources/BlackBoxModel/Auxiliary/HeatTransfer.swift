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
    let inlet = Simulation.initialValues.temperatureOfHTFinPipes
    let outlet = Simulation.initialValues.temperatureOfHTFinHCE
    self.temperature = (inlet: inlet, outlet: outlet)
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

  var average: Temperature {
    Temperature.average(temperature.inlet, temperature.outlet)
  }

  var minTemperature: Double {
    min(inlet, outlet)
  }

  var inlet: Double { temperature.inlet.kelvin }

  var outlet: Double { temperature.outlet.kelvin }

  var flow: Double { massFlow.rate }

  var medium: HeatTransferFluid { SolarField.parameter.HTF }

  var heat: Heat {
    medium.heatContent(temperature.outlet, temperature.inlet)
  }

  public var description: String {  
       String(format: "  Mass flow: %3.1f kg/s", massFlow.rate).padding(28) 
      + String(format: " T in: %3.1f degC", temperature.inlet.celsius).padding(20) 
      + String(format: "T out: %3.1f degC", temperature.outlet.celsius).padding(20) 
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

  mutating func connectTo(_ c1: HeatTransfer, _ c2: HeatTransfer) {
    temperature.inlet = medium.mixingOutlets(c1, c2)
    massFlow = c1.massFlow + c2.massFlow
  }

  mutating func merge(_ c1: HeatTransfer) {
    temperature.inlet = medium.mixingOutlets(self, c1)
    massFlow += c1.massFlow
  }

  mutating func temperatureFromOutlet() {
    temperature.inlet = temperature.outlet
  }

  mutating func temperatureFromInlet() {
    temperature.outlet = temperature.inlet
  }

  mutating func setTemperature(inlet: Temperature) {
    temperature.inlet = inlet
  }

  mutating func setTemperature(outlet: Temperature) {
    temperature.outlet = outlet
  }

  mutating func outletTemperature(kelvin: Double) {
    temperature.outlet = Temperature(kelvin)
    assert(temperature.outlet > medium.freezeTemperature,
      "\(temperature) is below freezing point of the htf")
  }

  mutating func massFlow(inlet other: HeatTransfer) {
    massFlow = other.massFlow
    temperature.inlet = other.temperature.inlet
  }

  mutating func massFlow(outlet other: HeatTransfer) {
    massFlow = other.massFlow
    temperature.inlet = other.temperature.outlet
  }

  mutating func inletTemperature(outlet other: HeatTransfer) {
    temperature.inlet = other.temperature.outlet
  }

  mutating func inletTemperature(inlet other: HeatTransfer) {
    temperature.inlet = other.temperature.inlet
  }

  mutating func outletTemperature(outlet other: HeatTransfer) {
    temperature.outlet = other.temperature.outlet
  }
}

extension Collection where Element == HeatTransfer {
  var values: [String] {
    reduce(into: []) { $0.append(contentsOf: $1.values) }
  }
}
