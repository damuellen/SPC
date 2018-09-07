//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import DateGenerator
import Foundation
import Meteo
import SolarPosition

public enum Collector: Component {
  public enum OperationMode {
    case variable, freezeProtection, noOperation, operating, fixed
  }

  /// Contains all data needed to simulate the operation of the collector
  public struct PerformanceData: Encodable, CustomStringConvertible {
    public var parabolicElevation, theta, cosTheta, efficiency: Double

    static var headers: String {
      return "Parabolic Elevation, elevation, azimuth, theta, efficiency"
    }

    public var commaSeparatedValues: String {
      return String(format: ", %.1f", parabolicElevation)
        + String(format: ", %.2f", theta)
        + String(format: ", %.2f ", theta)
        + String(format: ", %.2f", efficiency)
    }

    public var description: String {
      return String(format: "PE: %.1f°, ", parabolicElevation)
        + String(format: "θ: %.2f°, ", theta)
        + String(format: "cos(θ): %.2f, ", cosTheta)
        + String(format: "η: %.1f", efficiency * 100) + "%"
    }
  }

  static let initialState = PerformanceData(
    parabolicElevation: 0,
    theta: 0,
    cosTheta: 0,
    efficiency: 0
  )

  public static var parameter: Parameter = ParameterDefaults.LS3

  static func shadingHCE(cosTheta: Double) -> Double {
    let shadingHCE = parameter.shadingHCE
    switch cosTheta {
    case 0 ... 0.03:
      return shadingHCE[0]
    case 0 ... 0.09:
      let x = (cosTheta - 0.03) / 0.06
      return x * shadingHCE[1] + (1 - x) * shadingHCE[0]
    case 0 ... 0.24:
      let x = (cosTheta - 0.09) / 0.15
      return x * shadingHCE[2] + (1 - x) * shadingHCE[1]
    case 0 ... 0.33:
      let x = (cosTheta - 0.24) / 0.09
      return x * shadingHCE[3] + (1 - x) * shadingHCE[2]
    default:
      return shadingHCE[3]
    }
  }

  /// This function calculates the efficiency of the Collector in the
  /// solar field which is depending on: incidence angle (theta), elevation angle
  /// of parabolic trough, edge factors of the solarfield and the optical efficiency
  public static func update(_ status: inout Collector.PerformanceData,
                            meteo: MeteoData, direction: Float = 0) {
    let solarField = SolarField.parameter

    let shadlength = parameter.avgFocus * tan(status.theta.toRadians)

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

    let IAM = parameter.IAMfac[status.theta.toRadians]

    var shadingSCA = abs(sin(status.parabolicElevation.toRadians))
      * solarField.rowDistance / parameter.aperture
    shadingSCA = min(1, shadingSCA)
    if shadingSCA < 0.01 {
      shadingSCA = 1
    }
    /// Angle of wind attack
    let AW: Double

    if direction < 180 { AW = status.parabolicElevation }
    else { AW = 180 - status.parabolicElevation }

    var T_14: Double

    if AW < 15 {
      T_14 = (197_441e-9 * parameter.lengthSCA ** 2
        + 197_441e-9 * parameter.lengthSCA)
    } else if AW < 45 {
      T_14 = -(264_485e-9 * parameter.lengthSCA ** 2
        + 264_485e-9 * parameter.lengthSCA)
    } else if AW < 75 {
      T_14 = (388_307e-9 * parameter.lengthSCA ** 2
        + 388_307e-9 * parameter.lengthSCA)
    } else if AW < 105 {
      T_14 = (709_175e-9 * parameter.lengthSCA ** 2
        + 709_175e-9 * parameter.lengthSCA)
    } else if AW < 135 {
      T_14 = (591_045e-9 * parameter.lengthSCA ** 2
        + 591_045e-9 * parameter.lengthSCA)
    } else if AW < 165 {
      T_14 = (517_083e-9 * parameter.lengthSCA ** 2
        + 517_083e-9 * parameter.lengthSCA)
    } else {
      T_14 = (354_672e-9 * parameter.lengthSCA ** 2
        + 354_672e-9 * parameter.lengthSCA)
    }
    if direction > 180 { T_14 = -T_14 }
    /// Effective wind speed
    let v_wind_eff = Double(meteo.windSpeed)
      * abs(sin(Double(direction) * .pi / 180))
    // Torsion due to bearing friction
    let T_R = -(939_549e-10 * parameter.lengthSCA ** 2
      + 939_549e-10 * parameter.lengthSCA)
    /// Torsion due to wind and friction
    let torsion = abs(T_14 * (v_wind_eff / 14) ** 2 + T_R)
    /// Correction factor due to torsion
    let k_torsion = max(0.2, (-0.0041 * pow(torsion, 3) - 0.0605
        * pow(torsion, 2) - 0.0354 * torsion + 99.997) / 100)
    let shadingHCE = self.shadingHCE(cosTheta: status.cosTheta)
    let eff = shadingSCA * shadingHCE * IAM * edge * k_torsion
    status.efficiency = eff * Simulation.adjustmentFactor.efficiencySolarField
  }

  public static func tracking(sun: SolarPosition.OutputValues) -> Collector.PerformanceData {
    var collector = Collector.initialState
    guard sun.zenith < 90 else { return collector }

    collector.parabolicElevation = 90 - (atan(tan(sun.zenith.toRadians)
        * cos(((sun.azimuth > 0 ? 90.0 : -90.0) - sun.azimuth).toRadians))).toDegrees

    let az = sun.azimuth.toRadians,
      el = sun.elevation.toRadians,
      beta = SolarField.parameter.elevation.toRadians,
      sfaz = SolarField.parameter.azimut.toRadians

    let theta = (cos(az - sfaz) / abs(cos(az - sfaz)) * 180 / .pi
      * acos(sqrt(1 - (cos(el - beta) - cos(beta) * cos(el)
          * (1 - cos(az - sfaz))) ** 2))) * (-1)

    collector.theta = theta
    collector.cosTheta = cos(theta.toRadians)
    return collector
  }
}

extension SolarField.PerformanceData.OperationMode {
  var collector: Collector.OperationMode {
    switch self {
    case .fixed:
      return .fixed
    case .startUp:
      return .operating
    case .freezeProtection:
      return .freezeProtection
    case .operating:
      return .operating
    case .noOperation:
      return .noOperation
    case .scheduledMaintenance:
      return .noOperation
    case .unknown:
      return .variable
    case .ph:
      return .variable
    case .normal:
      return .operating
    }
  }
}
