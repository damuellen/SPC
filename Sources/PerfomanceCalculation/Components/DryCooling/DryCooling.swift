//
//  Copyright (c) 2017 Daniel Müllenborn. All rights reserved.
//  Distributed under the The Non-Profit Open Software License version 3.0
//  http://opensource.org/licenses/NPOSL-3.0
//
//  This project is NOT free software. It is open source, you are allowed to
//  modify it (if you keep the license), but it may not be commercially
//  distributed other than under the conditions noted above.
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
      0.00000036851, -0.0000000010152, 8.6531e-13,
      9.03668e-16, -1.9969e-18, 7.79287e-22,
      1.91482e-25, -3968.06, 39.5735,
    ]

    var fit = 0.0

    for i in 0 ... 9 {
      fit += coefficients[i] * temperature.toKelvin ** Double(i)
    }

    let logpsat = fit + coefficients[10] / (temperature.toKelvin - coefficients[11])

    return exp(logpsat)
  }

  public static func operate(Tamb: Temperature, steamTurbine: inout SteamTurbine.PerformanceData)
    -> (DCFactor: Ratio, MaxDCLoad: Ratio) {
    let coefficientHR = [92.13, 28.73, 18.62, -15.42]
    let PCondMin = 0.179, PCondMax = 0.421 // [bar]
    let HRFmin = 98.0, HRFmax = 106.8 // [%] of design
    let TambMin = 42.2 // [øC]
    let aLoad = 2.25, cLoad = -0.03
    let InTempDiff = 32.778 // [øC]  (=59øF)

    let TCond = Temperature(steamTurbine.load.value ** 0.91 * InTempDiff + Tamb.value)
    let Pcond = Psat(TCond) * 10

    var DCFactor = 0.0
    var MaxDCLoad = 0.0
    steamTurbine.backPressure = Pcond

    if Pcond <= PCondMin {
      DCFactor = HRFmin / 100
    } else if Pcond >= PCondMax {
      DCFactor = HRFmax / 100
    } else {
      DCFactor = 0.0
      for i in 0 ... 3 {
        DCFactor = DCFactor + coefficientHR[i] * pow(Pcond, Double(i))
      }
      DCFactor = DCFactor / 100
    }

    if Tamb.value < TambMin {
      MaxDCLoad = 1.0
    } else {
      MaxDCLoad = aLoad + cLoad * Tamb.value
    }
    return (Ratio(DCFactor), Ratio(MaxDCLoad))
  }
}
