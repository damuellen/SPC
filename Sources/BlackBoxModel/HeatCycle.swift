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
  var massFlow: MassFlow { get }
  var temperature: (inlet: Temperature, outlet: Temperature) { get }
}

extension HeatCycle {
  var averageTemperature: Temperature {
    return Temperature.median((temperature.inlet, temperature.outlet))
  }

  func heatTransfered(with fluid: HeatTransferFluid) -> Double {
    return massFlow.rate * abs(fluid.heatDelta(temperature.inlet, temperature.outlet))
  }

  var values: [String] {
    return [
      String(format: "%.1f", massFlow.rate),
      String(format: "%.1f", temperature.inlet.celsius),
      String(format: "%.1f", temperature.outlet.celsius),
    ]
  }

  func columns(name: String) -> [(String, String)] {
    return [
      ("\(name)|Massflow", "kg/s"), ("\(name)|Tin", "°C"), ("\(name)|Tout", "°C"),
    ]
  }
}
