//
//  Copyright (c) 2017 Daniel Müllenborn. All rights reserved.
//  Distributed under the The Non-Profit Open Software License version 3.0
//  http://opensource.org/licenses/NPOSL-3.0
//
//  This project is NOT free software. It is open source, you are allowed to
//  modify it (if you keep the license), but it may not be commercially
//  distributed other than under the conditions noted above.
//

enum Control {
  
  static var whichOptimization: OptimizationMode = .fuel
  
  enum OptimizationMode {
    case solarOnly, baseLoad, demand, demand_fuel, fuel
  }
}
