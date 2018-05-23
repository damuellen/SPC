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

protocol HeatFlow {
  var massFlow: MassFlow { get }
  var temperature: (inlet: Temperature, outlet: Temperature) { get }
}

extension HeatFlow {
  var averageTemperature: Temperature {
    return temperature.inlet.median(temperature.outlet)
  }
  
  func thermal(fluid: HeatTransferFluid) -> Double {
    return massFlow.rate * abs(fluid.heatDelta(temperature.inlet, temperature.outlet))
  }
}

public struct ThermalFlow: HeatFlow, Equatable, CustomStringConvertible {
  var massFlow: MassFlow
  var temperature: (inlet: Temperature, outlet: Temperature)
  
  init() {
    self.massFlow = 0.0
    let temperature = Simulation.initialValues.temperatureOfHTFinPipes
    self.temperature = (inlet: temperature, outlet: temperature)
  }
  
  public var description: String {
    return String(format:"(Mfl: %.1fkg/s, ", massFlow.rate)
      + String(format:"In: %.1f°C, ", temperature.inlet.celsius)
      + String(format:"Out: %.1f°C)", temperature.outlet.celsius)
  }
  
  public static func ==(lhs: ThermalFlow, rhs: ThermalFlow) -> Bool {
    return lhs.massFlow == rhs.massFlow
      && lhs.temperature.inlet == rhs.temperature.inlet
      && lhs.temperature.outlet == rhs.temperature.outlet
  }
}
