//
//  Copyright (c) 2017 Daniel Müllenborn. All rights reserved.
//  Distributed under the The Non-Profit Open Software License version 3.0
//  http://opensource.org/licenses/NPOSL-3.0
//
//  This project is NOT free software. It is open source, you are allowed to
//  modify it (if you keep the license), but it may not be commercially
//  distributed other than under the conditions noted above.
//

import Config

extension Collector {
  public struct Parameter: ModelParameter, Codable {
    let name: String
    public enum Absorber: String, Codable {
      case schott, rio
    }
    let newFunction: Bool = false
    let absorber: Absorber
    let aperture, lengthSCA, areaSCAnet, extensionHCE, avgFocus,
    rabsOut, rabsInner, rglas, glassEmission, opticalEfficiency: Double
    let emissionHCE, shadingHCE, IAMfac: [Double]
    let IntradiationLosses: Bool
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
      >< "\(opticalEfficiency)"
    d += "Absorber emittance; Emittance(T) = c0 + c1*T\n"
    d += "c0:" >< "\(emissionHCE[0])"
    d += "c1:" >< "\(emissionHCE[1])"
    d += "Bellow Shadowing Factors\n"
    d += "for incident angle 0 - 1.5°:" >< "\(shadingHCE[0])"
    d += "for incident angle 1.5 - 5°:" >< "\(shadingHCE[1])"
    d += "for incident angle 5 - 14°:"  >< "\(shadingHCE[2])"
    d += "for incident angle >14°:"     >< "\(shadingHCE[3])"
    d += "Incident Angle Modifier; IAM(theta) = c0+c1*theta+c2*theta^2+c3*theta^3+c4*theta^4\n"
    d += "c0:" >< "\(IAMfac[0])"
    d += "c1:" >< "\(IAMfac[1])"
    d += "c2:" >< "\(IAMfac[2])"
    d += "c3:" >< "\(IAMfac[3])"
    d += "c4:" >< "\(IAMfac[4])"
    return d
  }
}

extension Collector.Parameter: TextConfigInitializable {
  public init(file: TextConfigFile)throws {
    let row: (Int)throws -> Double = { try file.double(row: $0) }
    self.name = file.name
    self.aperture = try row(10)
    self.lengthSCA = try row(13)
    self.areaSCAnet = try row(16)
    self.extensionHCE = try row(19)
    self.avgFocus = try row(22)
    self.rabsOut = try row(25)
    self.rabsInner = try row(28)
    self.rglas = try row(31)
    self.glassEmission = try row(71)
    self.opticalEfficiency = try row(34)
    self.emissionHCE = [try row(37), try row(40)]
    self.shadingHCE = [try row(43), try row(46), try row(49), try row(52)]
    self.IAMfac = [
      try row(55), try row(58), try row(61), try row(64), try row(67)]
    self.absorber = .schott
    self.IntradiationLosses = try row(73) > 0 ? true : false
  }
}

