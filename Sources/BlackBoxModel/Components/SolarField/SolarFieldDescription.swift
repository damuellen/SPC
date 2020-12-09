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
    "  Mode:".padding(30) + "\(operationMode)\n" + formatting(
      [inFocus.percentage, ETA, heatLosses, heatLossesHotHeader, heatLossesHCE],
      ["Focus:", "ETA:", "Heat losses:", "Heat losses header:", "Heat losses HCE:"]      
    ) + "\n" + cycle.description + "\nLoops:\nDesign\n\(loops[0])\nNear\n\(loops[1])\nAverage\n\(loops[2])\nFar\n\(loops[3])"
  }
}
