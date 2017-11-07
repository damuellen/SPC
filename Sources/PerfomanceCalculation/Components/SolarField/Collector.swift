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
public enum Collector: Component {
  
  static let cosLatitude = cos(Plant.location.latitude.radians)
  static let sinLatitude = sin(Plant.location.latitude.radians)
  
  final class Instance {
    // A singleton class holding the state of the collector
    fileprivate static let shared = Instance()
    var parameter: Collector.Parameter!
    var workingConditions: (previous: PerformanceData?, current: PerformanceData)
    
    private init() {
      workingConditions = (nil, initialState)
    }
  }

  public enum OperationMode {
    case variable, freezeProtection, noOperation, operating, fixed
  }
  
  /// a struct for operation-relevant data of the collector
  public struct PerformanceData: WorkingConditions, CustomDebugStringConvertible {
    var parabolicElevation, elevation, azimuth: Double
    var theta, efficiency: Double
    
    public var debugDescription: String {
      return String(format:"Elev: %.3f ", parabolicElevation.degrees)
      + String(format:"Theta: %.3f ", theta)
      + String(format:"Effi: %.3f", efficiency)
    }
  }

  private static let initialState = PerformanceData(
    parabolicElevation: 0,
    elevation: 0,
    azimuth: 0,
    theta: 0,
    efficiency: 0
  )

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
  public static var efficiency: Double { return status.efficiency }
  
  static var shadingHCE: Double {
    let shadingHCE = Collector.parameter.shadingHCE
    switch theta {
    case 0 ..< 0.03:
      return shadingHCE[0]
    case 0 ..< 0.09:
      let x = (theta - 0.03) / 0.06
    return x * shadingHCE[1] + (1 - x) * shadingHCE[0]
    case 0 ..< 0.24:
      let x = (theta - 0.09) / 0.15
    return x * shadingHCE[2] + (1 - x) * shadingHCE[1]
    case 0 ..< 0.33:
      let x = (theta - 0.24) / 0.09
    return x * shadingHCE[3] + (1 - x) * shadingHCE[2]
    default:
      return shadingHCE[3]
    }
  }

  /// This function calculates the efficiency of the Collector in the
  /// solar field which is depending on: incidence angle (theta), elevation angle
  /// of parabolic trough, edge factors of the solarfield and the optical efficiency
  public static func efficiency(meteo: MeteoData, direction: Float = 0) -> Double {
    // guard let status = Instance.shared.workingConditions.last else { return 0.0 }
    let parameter = Collector.parameter

    let shadlength = parameter.avgFocus * tan(theta)

    let edge: Double

    switch shadlength {
    case _ where shadlength <= parameter.extensionHCE:
      edge = 1
    case _ where shadlength <= SolarField.parameter.distanceSCA:
      edge = 1 - (shadlength - parameter.extensionHCE) / parameter.lengthSCA
    default:
      edge = 1 - SolarField.parameter.edgeFactor[0]
        - (shadlength - parameter.extensionHCE)
        * SolarField.parameter.edgeFactor[1]
    }

    var IAM = 0.0
    for i in parameter.IAMfac.indices {
      IAM += parameter.IAMfac[i] * theta ** Double(i)
    }

    var shadingSCA = abs(sin(.pi / 2.0 + status.parabolicElevation))
      * SolarField.parameter.rowDistance / parameter.aperture
    shadingSCA = min(1,shadingSCA)

    let AW: Double

    if direction < 180 { AW = status.parabolicElevation.degrees }
    else { AW = 180 - status.parabolicElevation.degrees }

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

    let v_wind_eff = Double(meteo.windSpeed)
      * abs(sin(Double(direction) * .pi / 180))
    // Torsion due to bearing friction
    let T_R = -(939_549e-10 * parameter.lengthSCA ** 2
      + 939_549e-10 * parameter.lengthSCA)
    let torsion = abs(T_14 * (v_wind_eff / 14) ** 2 + T_R)

    let k_torsion = max(0.2, (-0.0041 * pow(torsion, 3) - 0.0605
        * pow(torsion, 2) - 0.0354 * torsion + 99.997) / 100)

    return shadingSCA * shadingHCE * IAM * edge * k_torsion
  }

  public static func tracking(_ collector: inout Collector.PerformanceData,
                              sun: SolarPosition.OutputValues)  {
    
    let cosDeclination = cos(sun.declination.radians)
    let sinDeclination = sin(sun.declination.radians)
    
    let cosHourAngle = cos(sun.hourAngle.radians)
    let sinHourAngle = sin(sun.hourAngle.radians)
    
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
    
    if collector.azimuth >= 1 { collector.azimuth = 0.9999999 }
    if collector.azimuth <= -1 { collector.azimuth = -0.9999999 }

    collector.azimuth = atan(collector.azimuth
      / pow(1 - pow(collector.azimuth, 2), 0.5))

    if abs(cosTheta) >= 1 {
      cosTheta = sqrt(collector.elevation + pow(cosDeclination, 2)
        * pow(sinHourAngle, 2))
    }
    collector.theta = atan(sqrt(1 - pow(cosTheta, 2)) / cosTheta)
  }
}
