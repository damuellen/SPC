//
//  Copyright 2021 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import DateGenerator
import Libc
import PhysicalQuantities
import SolarPosition

extension PV {
  /// Represents a group of modules with the same orientation and module type.
  public struct Array {
    var panelsPerString: Int = 27
    var strings: Int = 295
    var inverters: Int = 1
    var panel: Panel = Panel()

    func callAsFunction(radiation: Double, ambient: Temperature, windSpeed: Double) -> PowerPoint {
      let pmp = panel.power(radiation: radiation, ambient: ambient, windSpeed: windSpeed)
      return PowerPoint(
        current: pmp.current * Double(strings) * Double(inverters),
        voltage: pmp.voltage * Double(panelsPerString)
      )
    }

    func callAsFunction(voltage: Double, radiation: Double, cell: Temperature) -> PowerPoint
    {
      let current = panel.current(
        voltage: voltage, radiation: radiation, temperature: cell
      )
      return PowerPoint(current: abs(current), voltage: voltage)
    }

    public init() {

    }
  }
  /// Represents a transformer with its losses.
  public struct Transformer {
    var injectionLossFractionAtST: Double = 0.006
    var resistiveLossAtSTC: Double = 0.01
    var ironLoss: Double = 14.83E3

    func callAsFunction(ac power: Double) -> Double {
      if power > .zero {
        return power * (1 - resistiveLossAtSTC) * (1 - injectionLossFractionAtST)
          - ironLoss
      } else {
        return -ironLoss
      }
    }
  }
}
