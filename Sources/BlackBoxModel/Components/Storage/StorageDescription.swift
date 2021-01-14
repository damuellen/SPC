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
   "  Mode:".padding(30) + "\(operationMode)\n" + formatting(
     [massFlow.rate, temperature.inlet.celsius, temperature.outlet.celsius,
      saltMass.need, saltMass.minimum, saltMass.cold, saltMass.hot,
      heatInSalt.cold, heatInSalt.hot, temperatureTank.cold.celsius, temperatureTank.hot.celsius,
      antiFreezeTemperature, charge.ratio, storedHeat, heatProductionLoad.ratio, massOfSalt],
     ["Mass flow rate:", "T in:", "T out:", 
      "Salt need:", "Salt min:", "Salt cold:", "Salt hot:",
      "Heat in salt cold:", "Heat in salt hot:", "Temperature tank cold:", "Temperature tank hot:",
      "Anti freeze temperature:", "Charge:", "Stored Heat:", "Heat production Load:",  "Mass of salt:"]
    )
  }
}
