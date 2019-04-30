//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Config

extension Collector {
  /**
   ## The collector model contains the following:
     - net collector surface area
     - length
     - parabola aperture
     - average distance from focus
     - optical efficiency
     - absorber extension beyond collector
     - absorber tube outer radius- inner radius
     - coating emittance coefficient as a function of temperature
     - radius of glass cover tube
     - bellow shadowing
     - optical efficiency as a function of incident angle (incident angle modifier).
   */
  public struct Parameter: ComponentParameter, Codable, Equatable {
    let name: String
    public enum Absorber: String, Codable {
      case schott, rio
    }

    let newFunction: Bool = false
    let absorber: Absorber
    public let aperture, lengthSCA, areaSCAnet, extensionHCE, avgFocus,
      rabsOut, rabsInner, rglas, glassEmission, opticalEfficiency: Double
    public let emissionHCE, shadingHCE: [Double]
    public let IAMfac: Polynomial
    public let useIntegralRadialoss: Bool
  }
}

extension Collector.Parameter: CustomStringConvertible {
  public var description: String {
    var d: String = ""
    d += "Description:\t\(name)\n"
    d += "Aperture [m]:"
      >< "\(aperture)"
    d += "Length [m]:"
      >< "\(lengthSCA)"
    d += "Aperture Area [m²]:"
      >< "\(areaSCAnet)"
    d += "Extension of HCE [m]:"
      >< "\(extensionHCE)"
    d += "Average Distance Parabola to Focus [m]:"
      >< "\(avgFocus)"
    d += "Absorber Pipe Outer Radius [m]:"
      >< "\(rabsOut)"
    d += "Absorber Pipe Inner Radius [m]:"
      >< "\(rabsInner)"
    d += "Glas Tube Radius [m]:"
      >< "\(rglas)"
    d += "Optical Efficiency [%]:"
      >< "\(opticalEfficiency * 100)"
    d += "Absorber emittance; Emittance(T) = c0 + c1*T\n"
    d += "c0:" >< "\(emissionHCE[0])"
    d += "c1:" >< "\(emissionHCE[1])"
    d += "Calc. Radialoss as Integral of dT:"
      >< "\(useIntegralRadialoss ? "YES" : "NO")"
    d += "Bellow Shadowing Factors\n"
    d += "for incident angle 0 - 1.5°:" >< "\(shadingHCE[0])"
    d += "for incident angle 1.5 - 5°:" >< "\(shadingHCE[1])"
    d += "for incident angle 5 - 14°:" >< "\(shadingHCE[2])"
    d += "for incident angle >14°:" >< "\(shadingHCE[3])"
    d += "Incident Angle Modifier;\nIAM(theta) = c0+c1*theta+c2*theta^2+c3*theta^3+c4*theta^4\n"
    for (i, c) in IAMfac.coefficients.enumerated() {
      d += "c\(i):" >< String(format: "%.4E", c)
    }
    return d
  }
}

extension Collector.Parameter: TextConfigInitializable {
  public init(file: TextConfigFile) throws {
    let row: (Int) throws -> Double = { try file.parseDouble(row: $0) }
    name = file.name
    aperture = try row(10)
    lengthSCA = try row(13)
    areaSCAnet = try row(16)
    extensionHCE = try row(19)
    avgFocus = try row(22)
    rabsOut = try row(25)
    rabsInner = try row(28)
    rglas = try row(31)
    glassEmission = try row(71)
    opticalEfficiency = try row(34)
    emissionHCE = try [row(37), row(40)]
    shadingHCE = try [row(43), row(46), row(49), row(52)]
    IAMfac = try [row(55), row(58), row(61), row(64), row(67)]
    absorber = .schott
    useIntegralRadialoss = try row(73) > 0 ? true : false
  }
}
