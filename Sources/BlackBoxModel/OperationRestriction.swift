// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

/// A struct representing the operation restriction settings.
struct OperationRestriction {
  /// The fuel strategy used for the operation restriction.
  static var fuelStrategy: FuelStrategy = .predefined
  /// The available fuel strategies for the operation restriction.
  enum FuelStrategy: CustomStringConvertible {
    /// A predefined fuel strategy.
    case predefined
    /// A custom strategy for the operation restriction.
    case strategy

    /// Indicates whether the fuel strategy is predefined.
    var isPredefined: Bool { self ~= .predefined }

    /// A textual representation of the fuel strategy.
    public var description: String {
      switch self {
      case .predefined: return "Predefined"
      case .strategy: return "Strategy"
      }
    }
  }
}
