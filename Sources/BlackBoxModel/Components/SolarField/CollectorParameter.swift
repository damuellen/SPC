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
  public struct Parameter: Codable, Equatable {
    let name: String
    public enum Absorber: String, Codable {
      case schott, rio
    }
  //  let kind: Kind = .sklalet
    var newFunction: Bool = false
    let absorber: Absorber
    public let aperture, lengthSCA, areaSCAnet, extensionHCE, avgFocus,
      rabsOut, rabsInner, rglas, glassEmission, opticalEfficiency: Double
    public let emissionHCE, shadingHCE: [Double]
    public let IAMfac: Polynomial
    public let useIntegralRadialoss: Bool
  }
/*
  enum Kind: Int, Encodable {
    case sklatet = 0, ls2, validation
  }*/
}

extension Collector.Parameter: CustomStringConvertible {
  public var description: String {
    "Description:" * name
    + "Aperture [m]:" * aperture.description
    + "Length [m]:" * lengthSCA.description
    + "Aperture Area [m²]:" * areaSCAnet.description
    + "Extension of HCE [m]:" * extensionHCE.description
    + "Average Distance Parabola to Focus [m]:" * avgFocus.description
    + "Absorber Pipe Outer Radius [m]:" * rabsOut.description
    + "Absorber Pipe Inner Radius [m]:" * rabsInner.description
    + "Glas Tube Radius [m]:" * rglas.description
    + "Optical Efficiency [%]:" * (opticalEfficiency * 100).description
    + "Absorber emittance; Emittance(T) = c0 + c1*T\n"
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
    + "\n\(IAMfac)"
  }
}

extension Collector.Parameter: TextConfigInitializable {
  public init(file: TextConfigFile) throws {
    let ln: (Int) throws -> Double = { try file.double(line: $0) }
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
    emissionHCE = try [ln(37), ln(40)]
    shadingHCE = try [ln(43), ln(46), ln(49), ln(52)]
    IAMfac = try [ln(55), ln(58), ln(61), ln(64), ln(67)]
    absorber = .schott
    useIntegralRadialoss = try ln(73) > 0 ? true : false
  }
}
