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
  
  var massFlow: MassFlow { get set }
  var temperature: (inlet: Temperature, outlet: Temperature) { get set }
}

extension HeatCycle {
  var averageTemperature: Temperature {
    return Temperature.average(temperature.inlet, temperature.outlet)
  }

  var inletTemperature: Double { temperature.inlet.kelvin }

  var outletTemperature: Double { temperature.outlet.kelvin }

  var values: [String] {
    return [
      String(format: "%.1f", massFlow.rate),
      String(format: "%.1f", temperature.inlet.celsius),
      String(format: "%.1f", temperature.outlet.celsius),
    ]
  }

  func subtractingMassFlow(_ other: HeatCycle) -> MassFlow {
    massFlow - other.massFlow
  }

  mutating func setMassFlow(rate: Double) {
    massFlow = MassFlow(rate)
  }

  mutating func setTemperaturOutletEqualToOwnInlet() {
    temperature.outlet = temperature.inlet
  }

  mutating func setTemperature(inlet: Temperature) {
    temperature.inlet = inlet
  }

  mutating func setTemperature(outlet: Temperature) {
    temperature.outlet = outlet
  }

  mutating func setInletTemperature(inKelvin: Double) {
    temperature.inlet = Temperature(inKelvin)
  }

  mutating func setOutletTemperature(inKelvin: Double) {
    temperature.outlet = Temperature(inKelvin)
  }

  mutating func setInletTemperature(equalToInlet other: HeatCycle) {
    temperature.inlet = other.temperature.inlet
  }

  mutating func setInletTemperature(equalToOutlet other: HeatCycle) {
    temperature.inlet = other.temperature.outlet
  }

  mutating func setOutletTemperature(equalToOutlet other: HeatCycle) {
    temperature.outlet = other.temperature.outlet
  }
  
  static func columns(name: String) -> [(String, String)] {
    [("\(name)|Massflow", "kg/s"), ("\(name)|Tin", "°C"), ("\(name)|Tout", "°C")]
  }
}
