// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

enum Control {
  static var whichOptimization: OptimizationMode = .demand

  enum OptimizationMode {
    case solarOnly, baseLoad, demand, demand_fuel, fuel
  }
}
