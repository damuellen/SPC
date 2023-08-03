// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

/// A control mechanism for optimization settings related to a solar power plant.
enum Control {
  /// The current optimization mode being used.
  static var whichOptimization: OptimizationMode = .demand
  /// An enumeration representing different optimization modes for the solar power plant.
  enum OptimizationMode {
    /// Optimize the power plant for solar power generation only.
    case solarOnly

    /// Optimize the power plant for base load power generation.
    case baseLoad

    /// Optimize the power plant based on demand considerations.
    case demand

    /// Optimize the power plant based on demand and fuel considerations.
    case demand_fuel

    /// Optimize the power plant based on fuel considerations only.
    case fuel
  }
}