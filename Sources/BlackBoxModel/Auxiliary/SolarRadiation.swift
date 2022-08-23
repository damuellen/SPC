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
import Meteo
import SolarPosition

public struct SolarRadiation: MeasurementsConvertible {

  var dni, ghi, dhi, ico: Double

  init() {
    self.dni = 0.0
    self.ghi = 0.0
    self.dhi = 0.0
    self.ico = 0.0
  }

  init(meteo: MeteoData, cosTheta: Double) {
    self.dni = Double(meteo.dni)
    self.ghi = Double(meteo.ghi)
    self.dhi = Double(meteo.dhi)
    self.ico = Double(meteo.dni) * cosTheta
  }

  var numericalForm: [Double] { [dni, ghi, dhi, ico] }

  static var columns: [(name: String, unit: String)] {
    [
      ("Solar|DNI", "Wh/m2"), ("Solar|GHI", "Wh/m2"),
      ("Solar|DHI", "Wh/m2"), ("Solar|ICO", "Wh/m2"),
    ]
  }

  mutating func totalize(_ radiation: SolarRadiation, fraction: Double) {
    dni += radiation.dni * fraction
    ghi += radiation.ghi * fraction
    dhi += radiation.dhi * fraction
    ico += radiation.ico * fraction
  }

  mutating func zero() {
    dni = 0.0
    ghi = 0.0
    dhi = 0.0
    ico = 0.0
  }
}

/// Perez’s model coefficient sets
struct PerezCoefficients {
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

enum Albedo: Double {
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

extension SolarRadiation {
  public static func effective(
    ghi: Double, dhi: Double, surfTilt: Double, incidence: Double,
    zenith: Double, doy: Int
  ) -> Double {
    if incidence >= 90 || incidence <= 0 { if ghi < 10.0 { return 0 } }
    let beam: Double
    let dni: Double
    if zenith > 89 {
      beam = 0
      dni = 0
    } else {
      beam = SolarRadiation.beam(global: ghi, diffuse: dhi, incidence: incidence, zenith: zenith)
      dni = SolarRadiation.normal(global: ghi, diffuse: dhi, zenith: zenith)
    }

    let hExtra = SolarRadiation.extra(doy: doy)

    let AM = Atmosphere.relativeAirMass(
      zenith: zenith, model: .kastenyoung1989)

    let diffuse = SolarRadiation.perez(
      surfaceTilt: surfTilt, incidence: incidence, diffuse: dhi, direct: dni,
      hExtra: hExtra, sunZenith: zenith, AM: AM)

    //var albedoInc = groundDiffuse(angles.SurfTilt, GHI, context.Albedo)
    return beam + diffuse
  }

  /// Determine diffuse irradiance from the sky on a tilted surface using the Perez model
  /// - Parameter surfaceTilt: Surf tilted angle in degrees
  /// - Parameter incidence: Angle of incidence of the sun to the surface in degrees
  /// - Parameter diffuse: Diffuse horizontal irradiance
  /// - Parameter direct: Direct normal irradiance
  /// - Parameter hExtra: Extraterrestial normal irradiance
  /// - Parameter sunZenith: Sun zenith angle in degrees
  /// - Parameter AM: Relative airmass
  static func perez(
    surfaceTilt: Angle, incidence: Angle, diffuse: Double, direct: Double,
    hExtra: Double, sunZenith: Angle, AM: Double
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

  static func beam(global: Double, diffuse: Double, incidence: Double, zenith: Double) -> Double {
    if incidence > 89 { return 0.0 }
    let beam = global - diffuse
    return beam * cos(incidence * .pi / 180) / cos(zenith * .pi / 180)
  }

  static func normal(global: Double, diffuse: Double, zenith: Double) -> Double {
    let beam = global - diffuse
    return beam / cos(zenith * .pi / 180)
  }

  /// Extraterrestrial radiation from day of year
  /// - Parameter date: Date whose extraterrestial radiation will be calculated</param>
  /// - Returns: Extraterrestial radiation
  static func extra(doy: Int) -> Double {
    let B = 2.0 * .pi * Double(doy) / 365.0
    let roverR0sqrd = 1.00011
      + 0.034221 * cos(B)
      + 0.00128 * sin(B)
      + 0.000719 * cos(2 * B)
      + 0.000077 * sin(2 * B)

    return 1367.0 * roverR0sqrd
  }

  static func groundDiffuse(surfTilt: Double, GHI: Double, albedo: Double) -> Double {
    GHI * albedo * (1 - cos(surfTilt.toRadians)) * 0.5
  }
}
