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
import DateGenerator
import SolarPosition
import Meteo
/*
 The collector model contains the following: net collector surface area, length,
 parabola aperture, average distance from focus, optical efficiency,
 absorber extension beyond collector, absorber tube outer radius, inner radius
 and coating emittance coefficient as a function of temperature,
 radius of glass cover tube, bellow shadowing, and optical efficiency
 as a function of incident angle (incident angle modifier).
 */
public enum Collector: Model {
  
  static let cosLatitude = cos(Plant.location.latitude.toRadians)
  static let sinLatitude = sin(Plant.location.latitude.toRadians)
  
  final class Instance {
    // A singleton class holding the state of the collector
    fileprivate static let shared = Instance()
    var parameter: Collector.Parameter!
    var workingConditions: (previous: PerformanceData?, current: PerformanceData)
    
    private init() {
      workingConditions = (nil, initialState)
    }
  }

  /// a struct for operation-relevant data of the collector
  public struct PerformanceData {
    var operationMode: OperationMode
    var theta, parabolicElevation, elevation, azimuth, massFlow, LoopEta: Double
    var temperature: (inlet: Double, outlet: Double)

    public enum OperationMode {
      case variable, freezeProtection, fixed, noOperation, operating
    }
  }

  private static let initialState = PerformanceData(
    operationMode: .operating,
    theta: 0,
    parabolicElevation: 0,
    elevation: 0,
    azimuth: 0,
    massFlow: 0.0,
    LoopEta: 0.0,
    temperature: (200, 200))

  /// Returns the current working conditions of the collector
  public static var status: PerformanceData {
    get { return Instance.shared.workingConditions.current }
    set {
      Instance.shared.workingConditions =
       (Instance.shared.workingConditions.current, newValue) 
    }
  }

  public static var parameter: Collector.Parameter {
    get { return Instance.shared.parameter }
    set { Instance.shared.parameter = newValue }
  }

  public static var position: Double { return status.parabolicElevation }

  public static var theta: Double { return status.theta }

  static var shadingHCE: Double {
    let collector = Collector.parameter
    switch theta {
    case 0 ..< 0.03:
      return collector.shadingHCE[0]
    case 0 ..< 0.09:
      let x = (theta - 0.03) / 0.06
    return x * collector.shadingHCE[1] + (1 - x) * collector.shadingHCE[0]
    case 0 ..< 0.24:
      let x = (theta - 0.09) / 0.15
    return x * collector.shadingHCE[2] + (1 - x) * collector.shadingHCE[1]
    case 0 ..< 0.33:
      let x = (theta - 0.24) / 0.09
    return x * collector.shadingHCE[3] + (1 - x) * collector.shadingHCE[2]
    default:
      return collector.shadingHCE[3]
    }
  }

  /// This function calculates the efficiency of the Collector in the
  /// solar field which is depending on: incidence angle (theta), elevation angle
  /// of parabolic trough, edge factors of the solarfield and the optical efficiency
  public static func efficiency(meteo: MeteoData, direction: Float) -> Double {
    // guard let status = Instance.shared.workingConditions.last else { return 0.0 }
    let collector = Collector.parameter

    let shadlength = collector.avgFocus * tan(status.theta)

    let edge: Double

    switch shadlength {
    case _ where shadlength <= collector.extensionHCE:
      edge = 1
    case _ where shadlength <= SolarField.parameter.distanceSCA:
      edge = 1 - (shadlength - collector.extensionHCE) / collector.lengthSCA
    default:
      edge = 1 - SolarField.parameter.EdgeFac[0]
        - (shadlength - collector.extensionHCE) * SolarField.parameter.EdgeFac[1]
    }

    var IAM = 0.0
    for i in collector.IAMfac.indices {
      IAM += collector.IAMfac[i] * status.theta ** Double(i)
    }

    var shadingSCA = abs(sin(.pi / 2.0 + status.parabolicElevation))
      * SolarField.parameter.rowDistance / collector.aperture
    shadingSCA = min(1,shadingSCA)

    let AW: Double

    if direction < 180 { AW = status.parabolicElevation.toDegress }
    else { AW = 180 - status.parabolicElevation.toDegress }

    var T_14: Double

    if AW < 15 {
      T_14 = (197_441e-9 * collector.lengthSCA ** 2
        + 197_441e-9 * collector.lengthSCA)
    } else if AW < 45 {
      T_14 = -(264_485e-9 * collector.lengthSCA ** 2
        + 264_485e-9 * collector.lengthSCA)
    } else if AW < 75 {
      T_14 = (388_307e-9 * collector.lengthSCA ** 2
        + 388_307e-9 * collector.lengthSCA)
    } else if AW < 105 {
      T_14 = (709_175e-9 * collector.lengthSCA ** 2
        + 709_175e-9 * collector.lengthSCA)
    } else if AW < 135 {
      T_14 = (591_045e-9 * collector.lengthSCA ** 2
        + 591_045e-9 * collector.lengthSCA)
    } else if AW < 165 {
      T_14 = (517_083e-9 * collector.lengthSCA ** 2
        + 517_083e-9 * collector.lengthSCA)
    } else {
      T_14 = (354_672e-9 * collector.lengthSCA ** 2
        + 354_672e-9 * collector.lengthSCA)
    }
    if direction > 180 { T_14 = -T_14 }

    let v_wind_eff = Double(meteo.windSpeed)
      * abs(sin(Double(direction) * .pi / 180))
    // Torsion due to bearing friction
    let T_R = -(939_549e-10 * collector.lengthSCA ** 2
      + 939_549e-10 * collector.lengthSCA)
    let torsion = abs(T_14 * (v_wind_eff / 14) ** 2 + T_R)

    let k_torsion = max(0.2, (-0.0041 * pow(torsion, 3) - 0.0605
        * pow(torsion, 2) - 0.0354 * torsion + 99.997) / 100)

    return shadingSCA * shadingHCE * IAM * edge * k_torsion
  }

  public static func tracking(_ collector: inout Collector.PerformanceData,
                              sun: SolarPosition.OutputValues) {

    let cosDeclination = cos(sun.declination.toRadians)
    let sinDeclination = sin(sun.declination.toRadians)
    
    let cosHourAngle = cos(sun.hourAngle.toRadians)
    let sinHourAngle = sin(sun.hourAngle.toRadians)
    
    let cosAA = cos(.pi / 180.0 * SolarField.parameter.azim) // = 1
    let cosAE = cos(.pi / 180.0 * 31.79181) // = 1
    let sinAA = sin(.pi / 180.0 * SolarField.parameter.azim) // = 0
    let sinAE = sin(.pi / 180.0 * 31.79181) // = 0

    var A = sinHourAngle * cosDeclination * cosAA
    A += cosLatitude * sinDeclination * sinAA // + 0
    A -= sinLatitude * cosHourAngle * cosDeclination * sinAA // - 0

    var B = sinHourAngle * cosDeclination * sinAA * sinAE // = 0
    B -= cosLatitude * sinDeclination * cosAA * sinAE // = 0
    B += sinLatitude * cosHourAngle * cosDeclination * cosAA * sinAE // = 0
    B += sinLatitude * sinDeclination * cosAE
      + cosLatitude * cosHourAngle * cosDeclination * cosAE
    
    // Parabolic Elevation
    if abs(B) < 0.0001 {
      let signA = A.sign == .plus ? 1.0 : -1.0
      let signB = B.sign == .plus ? 1.0 : -1.0
      collector.parabolicElevation = signA * signB * .pi / 2.0
    } else {
      collector.parabolicElevation = atan(A / B)
    }
    
    var cosTheta = sin(collector.parabolicElevation)
      * A + cos(collector.parabolicElevation) * B
    
    // For Tracking collector North-south horizontal:
    collector.elevation = sinLatitude * sinDeclination
      + cosLatitude * cosDeclination * cosHourAngle
    
    let asin = atan(collector.elevation
      / pow(1 - pow(collector.elevation, 2), 0.5))

    collector.azimuth = -sinHourAngle * cosDeclination / cos(asin)
    if collector.azimuth >= 1 {
      collector.azimuth = 0.9999999
      
    }
    if collector.azimuth <= -1 {
      collector.azimuth = -0.9999999
      
    }

    collector.azimuth = atan(collector.azimuth
      / pow(1 - pow(collector.azimuth, 2), 0.5))

    if abs(cosTheta) >= 1 {
      cosTheta = sqrt(collector.elevation + pow(cosDeclination, 2)
        * pow(sinHourAngle, 2))
    }
    collector.theta = atan(sqrt(1 - pow(cosTheta, 2)) / cosTheta)
  }
}
