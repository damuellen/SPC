//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Units

extension SolarField: CustomStringConvertible {
  public var description: String {
    "  Mode:".padding(30) + "\(operationMode)\n" + formatting(
      [heatLosses, heatLossesHotHeader, heatLossesHCE],
      ["Heat losses:", "Heat losses header:", "Heat losses HCE:"]      
    ) + "\n" + cycle.description 
      + "\nDesign\n\(loops[0])\nNear\n\(loops[1])\nAverage\n\(loops[2])\nFar\n\(loops[3])"
  }
}

extension SolarField.OperationMode: CustomStringConvertible {
  public var description: String {
    switch self {      
    case .startUp: return "Start up"
    case .shutdown: return "Shut down"   
    case .follow: return "Follow"
    case .track: return "Track"
    case .defocus(let r): return "Dumping \(Ratio(1-r.quotient).singleBar)"
    case .stow: return "Stow"
    case .freeze: return "Freeze protection"
    case .maintenance: return "Maintenance"
    }
  }
}
