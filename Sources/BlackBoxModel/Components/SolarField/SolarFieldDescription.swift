//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

extension SolarField: CustomStringConvertible {
  public var description: String {
    return "\(operationMode), "
      + String(format: "Focus: %.1f%, ", inFocus.percentage)
      + String(format: "ETA: %.1f, ", ETA)
      + String(format: "HL: %.1f, ", heatLosses)
      + String(format: "HL Header: %.1f, ", heatLossHeader)
      + String(format: "HL HCE: %.1f", heatLossHCE)
      + "\n\t\(header)\n"      
      + "Loops: \n\t\(loops[0])\n\t\(loops[1])\n\t\(loops[2])\n\t\(loops[3])"
  }
}
