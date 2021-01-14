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
import Libc
import Meteo
import SolarPosition
/// Contains all data needed to simulate the operation of the collector
public struct Collector: Parameterizable, CustomStringConvertible {
    
  public var parabolicElevation, theta, cosTheta, efficiency: Double
  public var insolationAbsorber: Double

  public var description: String {
    formatting(
      [insolationAbsorber, parabolicElevation, theta, cosTheta, efficiency],
      ["Insolation absorber:", "PE:", "Theta:", "cos(Theta):", "Efficiency:"]
    ) 
  }

  static let initialState = Collector(
    parabolicElevation: 0, theta: 0, cosTheta: 0,
    efficiency: 0, insolationAbsorber: 0
  )

  public static var parameter: Parameter = ParameterDefaults.LS3

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

  /// This function calculates the efficiency of the parabolic trough
  /// which is depending on: incidence angle (theta), elevation angle,
  /// edge factors of the solarfield and the optical efficiency
  public static func efficiency(_ collector: inout Collector, ws: Float) {
    guard case 1...179 = collector.parabolicElevation else { return }
    
    let IAM = parameter.factorIAM(collector.theta.toRadians)
    
    let solarField = SolarField.parameter
    
    let shadlength = parameter.avgFocus * tan(collector.theta.toRadians)

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

    var shadingSCA = abs(sin(collector.parabolicElevation.toRadians))
      * solarField.rowDistance / parameter.aperture
    shadingSCA = min(1, shadingSCA)
    if shadingSCA < 0.01 {
      shadingSCA = 1
    }
    /// Angle of wind attack
    let AW: Double
    let direction = 1
    if direction < 180 { AW = collector.parabolicElevation }
    else { AW = 180 - collector.parabolicElevation }

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
    /// Effective wind speed
    let v_wind_eff = Double(ws) * abs(sin(Double(direction) * .pi / 180))
    // Torsion due to bearing friction
    let T_R = -(939_549e-10 * parameter.lengthSCA ** 2
      + 939_549e-10 * parameter.lengthSCA)
    /// Torsion due to wind and friction
    let torsion = abs(T_14 * (v_wind_eff / 14) ** 2 + T_R)
    /// Correction factor due to torsion
    let k_torsion = max(0.2, (-0.0041 * torsion ** 3 - 0.0605
        * torsion ** 2 - 0.0354 * torsion + 99.997) / 100)
    
    let shadingHCE = self.shadingHCE(cosTheta: collector.cosTheta)
    
    let wind = solarField.windCoefficients(Double(ws))

    let eff = shadingSCA * shadingHCE * IAM * edge * k_torsion * wind
      * Simulation.adjustmentFactor.efficiencySolarField
    collector.efficiency = eff
  }

  public static func tracking(sun: SolarPosition.OutputValues) -> Collector {
    var collector = Collector.initialState
    guard sun.zenith < 90.0 else { return collector }

    collector.parabolicElevation = 90 - (atan(tan(sun.zenith.toRadians)
        * cos(((sun.azimuth > 0.0 ? 90.0 : -90.0)
          - sun.azimuth).toRadians))).toDegrees

    let az: Double = sun.azimuth.toRadians
    let el: Double = sun.elevation.toRadians
    let beta: Double = SolarField.parameter.elevation.toRadians
    let sfaz: Double = SolarField.parameter.azimut.toRadians
 
    let theta: Double = (cos(az - sfaz) / abs(cos(az - sfaz)) * 180
      / .pi * acos(sqrt(1 - (cos(el - beta) - cos(beta) * cos(el)
        * (1 - cos(az - sfaz))) ** 2))) * (-1)

    collector.theta = theta
    collector.cosTheta = cos(theta.toRadians)
   
    return collector
  }
}

extension Collector: MeasurementsConvertible {
  
  var numericalForm: [Double] {
    [theta, cosTheta, efficiency, parabolicElevation]
  }
  
  static var columns: [(name: String, unit: String)] {
    [("Collector|theta", "degree"), ("Collector|cosTheta", "Ratio"),
     ("Collector|Eff", "%"), ("Collector|Position", "degree")]
  }
}
