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

    let logpsat = fit + coefficients[10] / (temperature.kelvin - coefficients[11])

    return exp(logpsat)
  }

  public static func update(
    Tamb: Temperature, steamTurbine: SteamTurbine.PerformanceData
  )
    -> (DCFactor: Ratio, MaxDCLoad: Ratio, backPressure: Double) {
    let coefficientHR: Coefficients = [92.13, 28.73, 18.62, -15.42]
    let PCondMin = 0.179, PCondMax = 0.421 // [bar]
    let HRFmin = 98.0, HRFmax = 106.8 // [%] of design
    let TambMin = 42.2 // [øC]
    let aLoad = 2.25, cLoad = -0.03
    let InTempDiff = 32.778 // [øC]  (=59øF)

    let TCond = Temperature(steamTurbine.load.ratio ** 0.91 * InTempDiff + Tamb.kelvin)
    let Pcond = Psat(TCond) * 10

    var DCFactor = 0.0
    var MaxDCLoad = 0.0

    if Pcond <= PCondMin {
      DCFactor = HRFmin / 100
    } else if Pcond >= PCondMax {
      DCFactor = HRFmax / 100
    } else {
      DCFactor = coefficientHR[Pcond] / 100
    }

    if Tamb.kelvin < TambMin {
      MaxDCLoad = 1.0
    } else {
      MaxDCLoad = aLoad + cLoad * Tamb.kelvin
    }
    return (Ratio(DCFactor), Ratio(MaxDCLoad), Pcond)
  }
}
