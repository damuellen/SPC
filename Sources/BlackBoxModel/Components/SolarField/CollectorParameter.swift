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
    "Description:" >< name
    + "Aperture [m]:" >< "\(aperture)"
    + "Length [m]:" >< "\(lengthSCA)"
    + "Aperture Area [m²]:" >< "\(areaSCAnet)"
    + "Extension of HCE [m]:" >< "\(extensionHCE)"
    + "Average Distance Parabola to Focus [m]:" >< "\(avgFocus)"
    + "Absorber Pipe Outer Radius [m]:" >< "\(rabsOut)"
    + "Absorber Pipe Inner Radius [m]:" >< "\(rabsInner)"
    + "Glas Tube Radius [m]:" >< "\(rglas)"
    + "Optical Efficiency [%]:" >< "\(opticalEfficiency * 100)"
    + "Absorber emittance; Emittance(T) = c0 + c1*T\n"
    + "c0:" >< "\(emissionHCE[0])"
    + "c1:" >< "\(emissionHCE[1])"
    + "Calc. Radialoss as Integral of dT:"
    >< "\(useIntegralRadialoss ? "YES" : "NO")"
    + "Bellow Shadowing Factors\n"
    + "for incident angle 0 - 1.5°:" >< "\(shadingHCE[0])"
    + "for incident angle 1.5 - 5°:" >< "\(shadingHCE[1])"
    + "for incident angle 5 - 14°:" >< "\(shadingHCE[2])"
    + "for incident angle >14°:" >< "\(shadingHCE[3])"
    + "Incident Angle Modifier;\nIAM(theta) = c0+c1*theta+c2*theta^2+c3*theta^3+c4*theta^4"
    + "\n\(IAMfac)"
  }
}

extension Collector.Parameter: TextConfigInitializable {
  public init(file: TextConfigFile) throws {
    let line: (Int) throws -> Double = { try file.parseDouble(line: $0) }
    name = file.name
    aperture = try line(10)
    lengthSCA = try line(13)
    areaSCAnet = try line(16)
    extensionHCE = try line(19)
    avgFocus = try line(22)
    rabsOut = try line(25)
    rabsInner = try line(28)
    rglas = try line(31)
    glassEmission = try line(71)
    opticalEfficiency = try line(34)
    emissionHCE = try [line(37), line(40)]
    shadingHCE = try [line(43), line(46), line(49), line(52)]
    IAMfac = try [line(55), line(58), line(61), line(64), line(67)]
    absorber = .schott
    useIntegralRadialoss = try line(73) > 0 ? true : false
  }
}
