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

public struct PV_Array {
  var panelsPerString: Int = 27
  var strings: Int = 295
  var inverters: Int = 1
  var panel: Panel = Panel()

  public func pmp(radiation: Double, ambient: Temperature, windSpeed: Double) -> Cell.PowerPoint {
    let pmp = panel.maxPowerPoint(radiation: radiation, ambient: ambient, windSpeed: windSpeed)
    return Cell.PowerPoint(
      current: pmp.current * Double(strings) * Double(inverters),
      voltage: pmp.voltage * Double(panelsPerString)
    )
  }

  func pmp(radiation: Double, cell: Temperature) -> Cell.PowerPoint {
    if radiation < 10 { return .zero }
    return panel.maxPowerPoint(radiation: radiation, temperature: cell)
  }

  public init() {

  }
}

struct Transformer {
  var injectionLossFractionAtST: Double = 0.006
  var resistiveLossAtSTC: Double = 0.01
  var ironLoss: Double = 14.83E3

  func callAsFunction(acPower: Double) -> Double {
    if acPower > .zero {
      return acPower * (1 - resistiveLossAtSTC) * (1 - injectionLossFractionAtST)
        - ironLoss
    } else {
      return -ironLoss
    }
  }
}
