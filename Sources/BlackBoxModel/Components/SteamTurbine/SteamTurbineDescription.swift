//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

extension SteamTurbine.PerformanceData: CustomStringConvertible {  
  public var description: String {
    return "\(operationMode), "
      + String(format: "Load: %.2f, ", load.ratio)
      + String(format: "Efficiency: %.2f %, ", efficiency * 100)
      + String(format: "Back pressure: %.2f, ", backPressure)
  }
}
