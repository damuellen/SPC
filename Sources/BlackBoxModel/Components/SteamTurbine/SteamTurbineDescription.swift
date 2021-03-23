//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

extension SteamTurbine: CustomStringConvertible {  
  public var description: String {
    "  Mode:".padding(20) + "\(operationMode)".padding(30) + "\(efficiency)"
  }
}

extension SteamTurbine.OperationMode: CustomStringConvertible {  
  public var description: String {
    switch self {
      case .noOperation(let minutes): return "No Operation \(minutes)min "
      case .operating(let load): return "Operation \(load.singleBar)"
      case .startUp(let minutes, energy: let energy):
       return "Start up \(minutes)min"
      case .scheduledMaintenance: return "Scheduled Maintenance"
    }
  }
}
