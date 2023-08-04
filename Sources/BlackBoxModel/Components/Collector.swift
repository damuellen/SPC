// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import DateExtensions
import Libc
import Helpers
import Meteo
import SolarPosition

/// A struct representing the state and functions for mapping the collector of a solar power plant.
struct Collector: Parameterizable, CustomStringConvertible {

  /// The parabolic elevation in degrees.
  private(set) var parabolicElevation, theta, cosTheta: Double

  /// The efficiency of the parabolic trough.
  private(set) var efficiency: Double

  /// Instantaneous irradiation on the absorber tube in W/sqm.
  private(set) var insolationAbsorber: Double
  
  /// The last recorded value of irradiation on the absorber tube.
  private(set) var lastInsolation: Double = 0

  /// A description of the `Collector` instance.
  public var description: String {
    formatting(
      [insolationAbsorber, parabolicElevation, cosTheta, efficiency * 100],
      ["Insolation absorber:", "PE:", "cos(Theta):", "Efficiency:"]
    )
  }

  /// Creates a `Collector` instance with the fixed initial state.
  static let initialState = Collector(
    parabolicElevation: 0, theta: 0, cosTheta: 0,
    efficiency: 0.0, insolationAbsorber: 0
  )

  /// The static parameters for the `Collector`.
  public static var parameter: Parameter = Parameters.NT_PRO

  /// Calculates the shading of the HCEs (Heat Collector Elements).
  static func shadingHCE(cosTheta: Double) -> Double {
    let shadingHCE = parameter.shadingHCE
    switch cosTheta {
    case ...0.03:
      return shadingHCE[0]
    case ...0.09:
      let x = (cosTheta - 0.03) / 0.06
      return x * shadingHCE[1] + (1 - x) * shadingHCE[0]
    case ...0.24:
      let x = (cosTheta - 0.09) / 0.15
      return x * shadingHCE[2] + (1 - x) * shadingHCE[1]
    case ...0.33:
      let x = (cosTheta - 0.24) / 0.09
      return x * shadingHCE[3] + (1 - x) * shadingHCE[2]
    default:
      return shadingHCE[3]
    }
  }

  /// Calculates the efficiency of the parabolic trough, depending on various parameters.
  public mutating func efficiency(ws: Double) {
    let parameter = Collector.parameter
    guard case 1...179 = parabolicElevation else { return }

    /// Current availability values
    let value = Availability.current.value
    let breakHCE = value.breakHCE.quotient
    let fluorHCE = value.fluorHCE.quotient
    let reflMirror = value.reflMirror.quotient
    let missgMirror = value.missgMirror.quotient
    let goodHCE = 1 - breakHCE - fluorHCE

    // Adjust Optical Efficiency for Missing Mirrors and Mirror Reflectivity
    var opticalEfficiency = parameter.opticalEfficiency
      * (goodHCE + breakHCE * 1.037 + fluorHCE * 0.458)
    opticalEfficiency *= reflMirror / 0.93 * (1 - missgMirror)

    let IAM = parameter.factorIAM(theta.toRadians)

    let solarField = SolarField.parameter

    let shadlength = parameter.avgFocus * tan(theta.toRadians)

    let edge: Double

    switch shadlength {
    case _ where shadlength <= parameter.extensionHCE:
      edge = 1
    case _ where shadlength <= solarField.distanceSCA:
      edge = 1 - (shadlength - parameter.extensionHCE) / parameter.lengthSCA
    default:
      edge = 1 - solarField.edgeFactor[0]
        - (shadlength - parameter.extensionHCE)
        * solarField.edgeFactor[1]
    }

    var shadingSCA = abs(sin(parabolicElevation.toRadians))
      * solarField.rowDistance / parameter.aperture
    shadingSCA = min(1, shadingSCA)
    if shadingSCA < 0.01 {
      shadingSCA = 1
    }
    /// Angle of wind attack
    let AW: Double
    let direction = 1
    if direction < 180 { AW = parabolicElevation }
    else { AW = 180 - parabolicElevation }

    var T_14: Double

    let lengthSCA = parameter.lengthSCA
    if AW < 15 {
      T_14 = (197_441e-9 * lengthSCA * lengthSCA + 197_441e-9 * lengthSCA)
    } else if AW < 45 {
      T_14 = -(264_485e-9 * lengthSCA * lengthSCA + 264_485e-9 * lengthSCA)
    } else if AW < 75 {
      T_14 = (388_307e-9 * lengthSCA * lengthSCA + 388_307e-9 * lengthSCA)
    } else if AW < 105 {
      T_14 = (709_175e-9 * lengthSCA * lengthSCA  + 709_175e-9 * lengthSCA)
    } else if AW < 135 {
      T_14 = (591_045e-9 * lengthSCA * lengthSCA  + 591_045e-9 * lengthSCA)
    } else if AW < 165 {
      T_14 = (517_083e-9 * lengthSCA * lengthSCA + 517_083e-9 * lengthSCA)
    } else {
      T_14 = (354_672e-9 * lengthSCA * lengthSCA + 354_672e-9 * lengthSCA)
    }

    if direction > 180 { T_14 = -T_14 }
    // Effective wind speed
    let v_wind_eff = ws * abs(sin(Double(direction) * .pi / 180))
    // Torsion due to bearing friction
    let T_R = -(939_549e-10 * parameter.lengthSCA ** 2 + 939_549e-10 * parameter.lengthSCA)
    // Torsion due to wind and friction
    let torsion = abs(T_14 * (v_wind_eff / 14) ** 2 + T_R)
    // Correction factor due to torsion
    let k_torsion = max(0.2, (-0.0041 * torsion ** 3 - 0.0605 * torsion ** 2 - 0.0354 * torsion + 99.997) / 100)

    let shadingHCE = Collector.shadingHCE(cosTheta: cosTheta)

    let wind = solarField.windCoefficients(ws)

    let eff = shadingSCA * shadingHCE * IAM * edge * k_torsion * wind * opticalEfficiency * Simulation.adjustmentFactor.efficiencySolarField
    efficiency = eff
  }
  /// Calculates the elevation and incidence angle for tracking the sun.
  public mutating func tracking(sun: SolarPosition.Output) {
    guard sun.zenith < 90.0 else { return }

    parabolicElevation = 90 - (atan(tan(sun.zenith.toRadians)
        * cos(((sun.azimuth > 0.0 ? 90.0 : -90.0)
          - sun.azimuth).toRadians))).toDegrees

    let az: Double = sun.azimuth.toRadians
    let el: Double = sun.elevation.toRadians
    let beta: Double = SolarField.parameter.elevation.toRadians
    let sfaz: Double = SolarField.parameter.azimut.toRadians

    theta = (cos(az - sfaz) / abs(cos(az - sfaz)) * 180
      / .pi * acos(sqrt(1 - pow(cos(el - beta) - cos(beta) * cos(el)
        * (1 - cos(az - sfaz)), 2)))) * (-1)

    cosTheta = cos(theta.toRadians)
  }

  /// Calculates the irradiation on the absorber taking into account the angle of incidence and optical efficiency.
  public mutating func irradiation(dni: Double) {
    lastInsolation = insolationAbsorber
    insolationAbsorber = dni * cosTheta * efficiency
  }
}

extension Collector: MeasurementsConvertible {

  /// An array of `Collector` instance's values.
  var values: [Double] {
    [insolationAbsorber, cosTheta, efficiency, parabolicElevation]
  }

  /// An array of tuples representing the measurements for `Collector`.
  static var measurements: [(name: String, unit: String)] {
    [("Insolation", "W/sqm"), ("Collector|cosTheta", "Ratio"),
     ("Collector|Eff", "%"), ("Collector|Position", "degree")]
  }
}
