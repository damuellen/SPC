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

public struct HeatFlow: HeatCycle, Equatable, CustomStringConvertible {

  var name = ""
  
  var massFlow: MassFlow

  var temperature: (inlet: Temperature, outlet: Temperature)

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
    return String(format: "\(name): Mfl: %.1fkg/s, ", massFlow.rate)
      + String(format: "Tin: %.1f°C, ", temperature.inlet.celsius)
      + String(format: "Tout: %.1f°C", temperature.outlet.celsius)
  }

  public mutating func constantTemperature() {
    temperature.inlet = temperature.outlet
  }

  public static func == (lhs: HeatFlow, rhs: HeatFlow) -> Bool {
    return lhs.massFlow == rhs.massFlow
      && lhs.temperature.inlet == rhs.temperature.inlet
      && lhs.temperature.outlet == rhs.temperature.outlet
  }
}
