// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import Foundation
import Utilities

/// A struct representing the state and functions for mapping the BESS
struct BESS {

  /// Energy stored in the system in Wh
  private(set) var energy: Double
  /// Maxmimum energy that the system can store in Wh
  static var capacity: Double = .zero

  /// Maximimum discharge charge power that you the system can handle in W
  static var maximumPower: Double = .zero

  /// Efficiency of the system
  static var efficiency: Ratio = .zero

  init() { self.energy = 0 }

  /// Stores energy in the battery
  /// - Parameter energy: Amount of energy in Wh
  /// - Returns: Dumped energy in Wh
  mutating func store(energy: Double) -> Double {
    var energyDumped = 0.0
    // Apply efficiency to the energy to be stored
    var energy = energy * BESS.efficiency.quotient
    // If the new energy will exceed the capacity
    if self.energy + energy >= BESS.capacity {
      energyDumped =
        (energy / BESS.efficiency.quotient) - (BESS.capacity - self.energy)
      energy = BESS.capacity - self.energy
    }
    self.energy += energy
    return energyDumped
  }

  /// Stores the energy defined by a power during a period of time
  /// - Parameter power: Power used in W
  /// - Parameter time: Time period over which the electrical power is applied
  /// - Returns: Dumped energy in Wh
  mutating func store(power: Double, span: TimeInterval) -> Double {
    let energy = power * (span / 3_600)
    return store(energy: energy)
  }

  /// Retrieve energy from the storage
  /// - Parameter energy: Energy to retrieve</param>
  /// - Returns: Retrieved energy in Wh
  mutating func retrieve(energy: Double) -> Double {
    var energyRetrieved = energy
    // There is not that much energy available
    if energy > self.energy {
      energyRetrieved = self.energy
      self.energy = 0
    } else {
      //Substract energy
      self.energy -= energyRetrieved
    }
    return energyRetrieved
  }

  mutating func retrieve(power: Double, span: TimeInterval) -> Double {
    let energyRequested = power * (span / 3_600)
    return retrieve(energy: energyRequested)
  }
}
