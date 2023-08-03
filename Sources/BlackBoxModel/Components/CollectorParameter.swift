//
//  Copyright 2023 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Utilities

extension Collector {
/**
 A struct representing the parameters of the collector.

 The collector model contains the following:
   - net collector surface area
   - length
   - parabola aperture
   - average distance from focus
   - optical efficiency
   - absorber extension beyond collector
   - absorber tube outer radius - inner radius
   - coating emittance coefficient as a function of temperature
   - radius of the glass cover tube
   - bellow shadowing
   - optical efficiency as a function of incident angle (incident angle modifier).
 */
  struct Parameter: Codable, Equatable {

    /// The name of the collector parameter set.
    let name: String

    /// The type of absorber material.
    public enum Absorber: String, Codable {
      case schott, rio
    }

    /// A flag indicating whether the collector uses a new function.
    var newFunction: Bool = false
    /// The type of absorber material for the collector.
    let absorber: Absorber
    /// The aperture of the collector in meters.
    let aperture: Double
    /// The length of the collector in meters.
    let lengthSCA: Double
    /// The net collector surface area in square meters.
    let areaSCAnet: Double
    /// The extension of HCE (Heat Collector Element) beyond the collector in meters.
    let extensionHCE: Double
    /// The average distance from the parabola to the focus in meters.
    let avgFocus: Double
    /// The outer radius of the absorber pipe in meters.
    let rabsOut: Double
    /// The inner radius of the absorber pipe in meters.
    let rabsInner: Double
    /// The radius of the glass cover tube in meters.
    let rglas: Double
    /// The emittance coefficient of the coating as a function of temperature.
    let glassEmission: Double
    /// The optical efficiency of the collector.
    let opticalEfficiency: Double
    /// The emittance coefficients for the HCE as a function of temperature.
    let emissionHCE: [Double]
    /// The shading coefficients for the HCE for different incident angles.
    let shadingHCE: [Double]
    /// The incident angle modifier as a polynomial function.
    let factorIAM: Polynomial
    /// A flag indicating whether to use integral radial loss calculation.
    let useIntegralRadialoss: Bool
  }
}

extension Collector.Parameter: CustomStringConvertible {
  /// A description of the `Collector.Parameter` instance.
  public var description: String {
    "Description:" * name
    + "Aperture [m]:" * aperture.description
    + "Length [m]:" * lengthSCA.description
    + "Aperture Area [m²]:" * areaSCAnet.description
    + "Extension of HCE [m]:" * extensionHCE.description
    + "Average Distance Parabola to Focus [m]:" * avgFocus.description
    + "Absorber Pipe Outer Radius [m]:" * rabsOut.description
    + "Absorber Pipe Inner Radius [m]:" * rabsInner.description
    + "Glass Tube Radius [m]:" * rglas.description
    + "Optical Efficiency [%]:" * (opticalEfficiency * 100).description
    + "Absorber Emittance; Emittance(T) = c0 + c1*T\n"
    + "c0:" * emissionHCE[0].description
    + "c1:" * emissionHCE[1].description
    + "Calc. Radialoss as Integral of dT:"
    * (useIntegralRadialoss ? "YES" : "NO")
    + "Bellow Shadowing Factors\n"
    + "for incident angle 0 - 1.5°:" * shadingHCE[0].description
    + "for incident angle 1.5 - 5°:" * shadingHCE[1].description
    + "for incident angle 5 - 14°:" * shadingHCE[2].description
    + "for incident angle >14°:" * shadingHCE[3].description
    + "Incident Angle Modifier;\nIAM(theta) = c0+c1*theta+c2*theta^2+c3*theta^3+c4*theta^4"
    + "\n\(factorIAM)"
  }
}

extension Collector.Parameter: TextConfigInitializable {
  /// Creates a `Collector.Parameter` instance using the data from a `TextConfigFile`.
  /// - Parameter file: The `TextConfigFile` containing the data for the parameter.
  init(file: TextConfigFile) throws {
    let ln: (Int) throws -> Double = { try file.readDouble(lineNumber: $0) }
    name = file.name
    aperture = try ln(10)
    lengthSCA = try ln(13)
    areaSCAnet = try ln(16)
    extensionHCE = try ln(19)
    avgFocus = try ln(22)
    rabsOut = try ln(25)
    rabsInner = try ln(28)
    rglas = try ln(31)
    glassEmission = try ln(71)
    opticalEfficiency = try ln(34)
    emissionHCE = try [ln(37), ln(40), 0]
    shadingHCE = try [ln(43), ln(46), ln(49), ln(52)]
    factorIAM = try [ln(55), ln(58), ln(61), ln(64), ln(67)]
    absorber = .schott
    useIntegralRadialoss = try ln(73) > 0 ? true : false
  }
}
