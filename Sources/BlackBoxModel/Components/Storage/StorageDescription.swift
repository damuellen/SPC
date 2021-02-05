//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

extension Storage: CustomStringConvertible {
  public var description: String {
    "  Mode:".padding(30) + "\(operationMode)\n" 
    + String(format: "  Mass flow: %3.1f kg/s", massFlow.rate).padding(28) 
    + String(format: " T in: %3.1f degC", temperature.inlet.celsius).padding(20) 
    + String(format: "T out: %3.1f degC", temperature.outlet.celsius).padding(20) 
    + "\n\n  Temperature tanks".padding(28)
    + String(format: " cold: %3.1f degC", temperatureTank.cold.celsius).padding(20)
    + String(format: "  hot: %3.1f degC", temperatureTank.hot.celsius).padding(20)
    + String(format: "\n\n  massOfSalt: %3.0f", massOfSalt).padding(28)
    + String(format: "  active: %3.0f", salt.active.kg).padding(20)
    + String(format: "  min: %3.0f", salt.minimum.kg) .padding(20)
    + .lineBreak + "".padding(28)
    + String(format: "  cold: %3.0f",salt.cold.kg).padding(20)
    + String(format: "  hot: %3.0f", salt.hot.kg).padding(20)
    + .lineBreak + .lineBreak + formatting(
     [antiFreezeTemperature, relativeCharge.percentage , storedHeat, heatProductionLoad.quotient],
     ["Anti freeze temperature:", "Charge:", "Stored Heat:", "Heat production Load:"]
    )
  }
}
