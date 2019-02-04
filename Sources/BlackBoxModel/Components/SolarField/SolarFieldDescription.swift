//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

extension SolarField.PerformanceData: CustomStringConvertible {
  public var description: String {
    return "\(operationMode), "
      + "Maintenance: \(isMaintained ? "Yes" : "No"), "
      + "Header: \(header),\n"
      + String(format: "insolationAbsorber: %.1f, ", insolationAbsorber)
      + String(format: "ETA: %.1f, ", ETA)
      + String(format: "HL: %.1f, ", heatLosses)
      + String(format: "HL Header: %.1f, ", heatLossHeader)
      + String(format: "HL HCE: %.1f, ", heatLossHCE)
      + "Focus: \(inFocus), "
      + String(format: "Loop Eta: %.1f, \n", loopEta)
      + "Loops: \n\(loops[0])\n\(loops[1])\n\(loops[2])\n\(loops[3])"
  }
}
