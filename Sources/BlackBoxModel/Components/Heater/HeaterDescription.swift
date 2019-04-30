//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

extension Heater.PerformanceData: CustomStringConvertible {  
  public var description: String {
    return "\(operationMode), "
      + String(format: "Load: %.1f\n", load.percentage)
      + String(format: "\tMfl: %.1fkg/s, ", massFlow.rate)
      + String(format: "Tin: %.1f°C, ", temperature.inlet.celsius)
      + String(format: "Tout: %.1f°C", temperature.outlet.celsius)
  }
}
