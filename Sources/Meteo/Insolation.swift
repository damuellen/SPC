//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import DateExtensions
import Libc
import SolarPosition

public struct Insolation {
  /// The direct normal irradiance in watts per square meter (W/m2).
  public var direct: Double
  /// The global horizontal irradiance in watts per square meter (W/m2).
  public var global: Double
  /// The diffuse horizontal irradiance in watts per square meter (W/m2).
  public var diffuse: Double

  public var values: [Double] { [direct / 1000, global / 1000, diffuse / 1000] }

  public static var measurements: [(name: String, unit: String)] {
    [
      ("Solar|DNI", "kWh/m2"), ("Solar|GHI", "kWh/m2"),
      ("Solar|DHI", "kWh/m2")
    ]
  }
  
  public static func zero() -> Insolation {
    Insolation(direct: 0, global: 0, diffuse: 0)
  }
}


extension RangeReplaceableCollection where Element==Insolation {
  public func hourly(fraction: Double) -> Insolation {
    var result = Insolation.zero()
    for radiation in self {
      result.direct += radiation.direct * fraction
      result.global += radiation.global * fraction
      result.diffuse += radiation.diffuse * fraction
    }
    return result
  }
}

/// Perez’s model coefficient sets
public struct PerezCoefficients {
  var f11: Double
  var f12: Double
  var f13: Double
  var f21: Double
  var f22: Double
  var f23: Double

  static subscript(e: Double) -> PerezCoefficients? {
    if e >= 1 && e < 1.065 {
      return coefficients[0]
    } else if e >= 1.065 && e < 1.23 {
      return coefficients[1]
    } else if e >= 1.23 && e < 1.5 {
      return coefficients[2]
    } else if e >= 1.5 && e < 1.95 {
      return coefficients[3]
    } else if e >= 1.95 && e < 2.8 {
      return coefficients[4]
    } else if e >= 2.8 && e < 4.5 {
      return coefficients[5]
    } else if e >= 4.5 && e < 6.2 {
      return coefficients[6]
    } else if e >= 6.2 {
      return coefficients[7]
    }
    return nil
  }

  static var coefficients: [PerezCoefficients] = [
    .init(f11: -0.20243899, f12: 0.50790876, f13: 0.0652646, f21: 0.79045571, f22: -6.99209098, f23: -0.52584641),
    .init(f11: 0.10269176, f12: 0.61222848, f13: -0.16136271, f21: -0.00416345, f22: 0.03055801, f23: -0.02112441),
    .init(f11: 0.34058838, f12: 0.38396973, f13: -0.22165044, f21: 0.04439868, f22: -0.03696354, f23: -0.02151291),
    .init(f11: 0.56885968, f12: 0.15584773, f13: -0.29598951, f21: 0.10813387, f22: -0.1268434, f23: -0.01281842),
    .init(f11: 0.87828309, f12: -0.33247141, f13: -0.36673704, f21: 0.222606, f22: -0.38054449, f23: 0.00317743),
    .init(f11: 1.14107187, f12: -1.04239894, f13: -0.42056735, f21: 0.28577048, f22: -0.691566, f23: 0.05845997),
    .init(f11: 1.06485619, f12: -1.35585772, f13: -0.36283319, f21: 0.27149949, f22: -1.07256116, f23: 0.13011048),
    .init(f11: 0.67017638, f12: -0.40277878, f13: -0.24185731, f21: 0.14280012, f22: -0.66867527, f23: 0.25427543)
  ]
}

public enum Albedo: Double {
  case urban_situation = 0.17
  case grass = 0.2
  case fresh_grass = 0.26
  case fresh_snow = 0.82
  case wet_snow = 0.65
  case dry_asphalt = 0.12
  case wet_asphalt = 0.18
  case concrete = 0.3
  case red_tiles = 0.33
  case aluminium = 0.85
  case new_galvanised_steel = 0.35
  case very_dirty_galvanised_site = 0.08
}

extension Insolation {
  /// Calculates the global tilted irradiance in watts per square meter (W/m2).
  public func effective(
    surfTilt: Double, incidence: Double, zenith: Double, doy: Int
  ) -> Double {
    var radiation = self
    if incidence >= 90 || incidence <= 0 { if global < 10.0 { return 0 } }
    if zenith < 90 {
      radiation.direct = normal(zenith: zenith)
    }

    let hExtra = extra(doy: doy)

    let AM = Atmosphere.relativeAirMass(zenith: zenith, model: .kastenyoung1989)

    radiation.diffuse = radiation.perez(
      surfaceTilt: surfTilt, incidence: incidence,
      hExtra: hExtra, sunZenith: zenith, AM: AM)

    //var albedoInc = groundDiffuse(angles.SurfTilt, context.Albedo)
    return radiation.beam(incidence: incidence, zenith: zenith) + radiation.diffuse
  }

  /// Determine diffuse irradiance from the sky on a tilted surface using the Perez model
  /// - Parameter surfaceTilt: Surf tilted angle in degrees
  /// - Parameter incidence: Angle of incidence of the sun to the surface in degrees
  /// - Parameter diffuse: Diffuse horizontal irradiance
  /// - Parameter direct: Direct normal irradiance
  /// - Parameter hExtra: Extraterrestial normal irradiance
  /// - Parameter sunZenith: Sun zenith angle in degrees
  /// - Parameter AM: Relative airmass
  func perez(surfaceTilt: Angle, incidence: Angle, hExtra: Double, sunZenith: Angle, AM: Double
  ) -> Double {
    let k = 5.535e-6
    let e = diffuse > .zero
      ? (((diffuse + direct) / diffuse) + (k * pow(sunZenith, 3))) / (1 + (k * pow(sunZenith, 3)))
      : 0.0

    guard let filter = PerezCoefficients[e] else { return 0 }

    let delta = diffuse * AM / hExtra

    let F1 = max(0.0,
      filter.f11 + (filter.f12 * delta) + (.pi * sunZenith / 180.0 * filter.f13))
    let F2 = max(0.0,
      filter.f21 + (filter.f22 * delta) + (.pi * sunZenith / 180.0 * filter.f23))

    let a = max(0.0, cos(incidence.toRadians))
    let b = max(cos(85.0.toRadians), cos(sunZenith.toRadians))

    return diffuse
      * ((1 - F1) * ((1 + cos(surfaceTilt.toRadians)) / 2) + F1 * (a / b) + F2
        * sin(surfaceTilt.toRadians))
  }

  func beam(incidence: Double, zenith: Double) -> Double {
    if incidence > 89 { return 0.0 }
    let beam = global - diffuse
    return beam * cos(incidence * .pi / 180) / cos(zenith * .pi / 180)
  }

  func normal(zenith: Double) -> Double {
    let beam = global - diffuse
    return beam / cos(zenith * .pi / 180)
  }

  /// Extraterrestrial radiation from day of year
  /// - Parameter date: Date whose extraterrestial radiation will be calculated
  /// - Returns: Extraterrestial radiation
  func extra(doy: Int) -> Double {
    let B = 2.0 * .pi * Double(doy) / 365.0
    let roverR0sqrd = 1.00011
      + 0.034221 * cos(B)
      + 0.00128 * sin(B)
      + 0.000719 * cos(2 * B)
      + 0.000077 * sin(2 * B)

    return 1367.0 * roverR0sqrd
  }

  func groundDiffuse(surfTilt: Double, albedo: Double) -> Double {
    global * albedo * (1 - cos(surfTilt.toRadians)) * 0.5
  }
}
