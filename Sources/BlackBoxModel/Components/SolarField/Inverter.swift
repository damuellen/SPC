//
//  Copyright 2021 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

struct Inverter {
  var powers: [Double] = [
    12e3, 132.302e3, 260.896e3, 518.503e3, 776.492e3, 1293.49e3, 1941.82e3,
    2591.46e3,
  ]
  var voltages: [Double] = [1200, 990, 915]

  var highVoltage: [Double] = [
    80, 95.7, 97.35, 98.13, 98.33, 98.44, 98.38, 98.31,
  ]
  var mediumVoltage: [Double] = [
    80, 96.37, 97.74, 98.36, 98.52, 98.57, 98.49, 98.4,
  ]
  var lowVoltage: [Double] = [
    80, 96.82, 98.01, 98.53, 98.67, 98.7, 98.62, 98.54,
  ]

  func callAsFunction(power: Double, voltage: Double) -> Double {
    func biInterpolate(
      _ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double, _ v11: Double,
      _ v12: Double, _ v21: Double, _ v22: Double, _ x: Double, _ y: Double
    ) -> Double {
      let fxy1 = (x2 - x) / (x2 - x1) * v11 + (x - x1) / (x2 - x1) * v21
      let fxy2 = (x2 - x) / (x2 - x1) * v12 + (x - x1) / (x2 - x1) * v22
      return (y2 - y) / (y2 - y1) * fxy1 + (y - y1) / (y2 - y1) * fxy2
    }
    guard let p1 = powers.lastIndex(where: { $0 < power }),
      let p2 = powers.firstIndex(where: {  $0 > power }),
      let v = voltages.firstIndex(where: { voltage < $0 })
    else { return 0.0 }

    let v1: [Double]
    let v2: [Double]

    if v == 0 {
      v1 = highVoltage
      v2 = mediumVoltage
    } else {
      v1 = mediumVoltage
      v2 = lowVoltage
    }

    let eff = biInterpolate(
      powers[p1], voltages[v],
      powers[p2], voltages[v + 1],
      v1[p1], v1[p2],
      v2[p1], v2[p2],
      power, voltage
    )
    return eff
  }
}
