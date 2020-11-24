//
//  Model.swift
//  SolarField
//
//  Created by Daniel Muellenborn on 23/03/2015.
//  Copyright © 2015 Daniel Muellenborn. All rights reserved.
//

import Libc

extension Branch {

  static func lambda(_ designTemperature: Double,
                     _ ambientTemperature: Double) -> Double {

    var lambda = -2.0 / 4.0 * pow(10, -22)
      * (pow(designTemperature, 4) - pow(ambientTemperature, 4))
    lambda += 4.0 / 3.0 * pow(10, -7)
      * (pow(designTemperature, 3) - pow(ambientTemperature, 3))
    lambda += 7.0 * pow(10, -5) / 2
      * (pow(designTemperature, 2) - pow(ambientTemperature, 2))
    lambda += 0.0336 * (designTemperature - ambientTemperature)
    lambda /= designTemperature - ambientTemperature
    return lambda
  }

  static func heatLossPerMeter(outsideDiameter: Double,
                               insulationThickness: Double,
                               designTemperature: Double,
                               ambientTemperature: Double) -> Double {

    let insulatedDiameter = (outsideDiameter + (2 * insulationThickness)) / 1000.0
    let outsideDiameter = outsideDiameter / 1000.0
    let alpha = 20.0
    let u = 1.0 / (2.0 * Branch.lambda(designTemperature, ambientTemperature)) *
      log(insulatedDiameter / outsideDiameter) + 1.0 / (insulatedDiameter * alpha)
    let heatLossesPerMeter = .pi * (designTemperature - ambientTemperature) / u
    return heatLossesPerMeter / 1000.0
  }
}
