//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

public struct OperationRestriction {
  static var fuelStrategy: FuelStrategy = .predefined
  enum FuelStrategy: CustomStringConvertible {
    case predefined, strategy

    var isPredefined: Bool {
      self ~= .predefined
    }

    public var description: String {
      switch self {
        case .predefined: return "Predefined"
        case .strategy: return "Strategy"
      }
    }
  }
}
