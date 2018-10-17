//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation
import Meteo

public enum DryCooling {
  // here Tamb is in [øC], whereas in Psat it is in [K] !!    Psat is in [MPa]
  // DCFactor, MaxDCLoad are between 0 and 1

  /// Calculates the saturation pressure
  private static func Psat(_ temperature: Temperature) -> Pressure {
    // Units: T in deg K, psat in MPa !!!

    let coefficients = [
      10.4592, -0.00404897, -0.000041752,
      3.6851e-07, -1.0152e-09, 8.6531e-13,
      9.03668e-16, -1.9969e-18, 7.79287e-22,
      1.91482e-25, -3968.06, 39.5735,
    ]

    var fit = 0.0

    for i in 0 ... 9 {
      fit += coefficients[i] * temperature.kelvin ** Double(i)
    }

    let logpsat = fit + coefficients[10]
      / (temperature.kelvin - coefficients[11])

    return exp(logpsat)
  }

  static func update(
    steamTurbineLoad: Double, temperature: Temperature
  ) -> (DCFactor: Ratio, MaxDCLoad: Ratio, backPressure: Double) {
    let coefficientHR: Coefficients = [92.13, 28.73, 18.62, -15.42]
    let pressureCondMin = 0.179, pressureCondMax = 0.421 // [bar]
    let HRFmin = 98.0, HRFmax = 106.8 // [%] of design
    let TambMin = 42.2 // [øC]
    let aLoad = 2.25, cLoad = -0.03
    let inTempDiff = 32.778 // [øC]  (=59øF)
    let Tamb = temperature.kelvin
    let TCond = Temperature(steamTurbineLoad ** 0.91 * inTempDiff + Tamb)
    let Pcond = Psat(TCond) * 10

    var dcFactor = 0.0
    var maxDCLoad = 0.0

    if Pcond <= pressureCondMin {
      dcFactor = HRFmin / 100
    } else if Pcond >= pressureCondMax {
      dcFactor = HRFmax / 100
    } else {
      dcFactor = coefficientHR[Pcond] / 100
    }

    if Tamb < TambMin {
      maxDCLoad = 1.0
    } else {
      maxDCLoad = aLoad + cLoad * Tamb
    }
    return (Ratio(dcFactor), Ratio(maxDCLoad), Pcond)
  }
}
