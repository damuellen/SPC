//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation

protocol HeatCycle {
  var cycle: HeatTransfer { get set }
}

extension HeatCycle {

  var medium: HeatTransferFluid {
    SolarField.parameter.HTF
  }

  var temperature: (inlet: Temperature, outlet: Temperature) {
    get { cycle.temperature }
    set { cycle.temperature = newValue }
  }

  var massFlow: MassFlow {
    get { cycle.massFlow }
    set { cycle.massFlow = newValue }
  }

  var averageTemperature: Temperature {
    return Temperature.average(temperature.inlet, temperature.outlet)
  }

  var inletTemperature: Double { temperature.inlet.kelvin }

  var outletTemperature: Double { temperature.outlet.kelvin }

  var deltaHeat: Heat {
    medium.deltaHeat(temperature.outlet, temperature.inlet)
  }

  func massFlow(subtracted other: HeatCycle) -> MassFlow {
    massFlow - other.massFlow
  }

  mutating func setMassFlow(rate: Double) {
    massFlow = MassFlow(rate)
  }

  mutating func merge(_ c1: HeatCycle, _ c2: HeatCycle) {
    temperature.inlet = medium.mixingTemperature(c1, c2)
    massFlow = c1.massFlow + c2.massFlow
  }

  mutating func add(_ c1: HeatCycle) {
    temperature.inlet = medium.mixingTemperature(self, c1)
    massFlow += c1.massFlow
  }

  mutating func outletTemperatureInlet() {
    temperature.outlet = temperature.inlet
  }

  mutating func inletTemperatureOutlet() {
    temperature.inlet = temperature.outlet
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

  mutating func inletTemperature(_ other: HeatCycle) {
    temperature.inlet = other.temperature.inlet
  }

  mutating func inletTemperature(outlet other: HeatCycle) {
    temperature.inlet = other.temperature.outlet
  }

  mutating func outletTemperature(_ other: HeatCycle) {
    temperature.outlet = other.temperature.outlet
  }
}
