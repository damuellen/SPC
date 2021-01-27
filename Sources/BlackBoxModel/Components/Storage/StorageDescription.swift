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
      temperatureTank.cold.celsius, temperatureTank.hot.celsius,
      massOfSalt, salt.active.kg, salt.minimum.kg, salt.cold.kg, salt.hot.kg,      
      antiFreezeTemperature, charge.percentage , storedHeat, heatProductionLoad.quotient],
     ["Mass flow rate:", "T inlet:", "T outlet:",
      "Temperature tank cold:", "Temperature tank hot:",  
      "Mass of salt:", "Salt active:", "Salt min:", "Salt cold:", "Salt hot:",      
      "Anti freeze temperature:", "Charge:", "Stored Heat:", "Heat production Load:"]
    )
  }
}
