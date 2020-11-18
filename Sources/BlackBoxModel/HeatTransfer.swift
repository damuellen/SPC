//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

public struct HeatTransfer: CustomStringConvertible {

  var name = ""

  var massFlow: MassFlow

  var temperature: (inlet: Temperature, outlet: Temperature)

  var averageTemperature: Temperature {
    return Temperature.average(temperature.inlet, temperature.outlet)
  }

  var inletTemperature: Double { temperature.inlet.kelvin }

  var outletTemperature: Double { temperature.outlet.kelvin }

  init(name: String) {
    self.name = name
    self.massFlow = 0.0
    let temperature = Simulation.initialValues.temperatureOfHTFinPipes
    self.temperature = (inlet: temperature, outlet: temperature)
  }

  init(loop: String) {
    self.name = loop
    self.massFlow = 0.0
    let temperature = Simulation.initialValues.temperatureOfHTFinHCE
    self.temperature = (inlet: temperature, outlet: temperature)
  }

  public var description: String {
    String(format: "\(name): Mfl: %.1fkg/s, ", massFlow.rate)
      + String(format: "Tin: %.1f°C, ", temperature.inlet.celsius)
      + String(format: "Tout: %.1f°C", temperature.outlet.celsius)
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

  public mutating func constantTemperature() {
    temperature.inlet = temperature.outlet
  }
}

extension Collection where Element == HeatTransfer {
  var values: [String] {
    reduce(into: []) { $0.append(contentsOf: $1.values) }
  }
}
