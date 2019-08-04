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

extension PowerBlock {
  public struct Parameter: ComponentParameter, Codable, Equatable {
    let name: String
    let fixElectricalParasitics: Double
    let nominalElectricalParasitics: Double
    let fixElectricalParasitics0: Double
    let startUpElectricalParasitics: Double
    let nominalElectricalParasiticsACC: Double
    let electricalParasiticsShared, electricalParasiticsStep,
      electricalParasitics, electricalParasiticsACC,
      electricalParasiticsACCTamb: Polynomial
  }
}

extension PowerBlock.Parameter: CustomStringConvertible {
  public var description: String {
    var d: String = ""
    d += "Fixed Parasitics for Load = 0 [MW]:"
      >< "\(fixElectricalParasitics0)"
    d += "Parasitics during PB Start-Up [MW]:"
      >< "\(startUpElectricalParasitics)"
    d += "Fixed Parasitics (Load > 0) [MW]:"
      >< "\(fixElectricalParasitics)"
    d += "Nominal Parasitics (Load = 1)[MW]:"
      >< "\(nominalElectricalParasiticsACC)"
    d += "Parasitic ; Parasitics(Load) = Parasitics(100%)*(c0+c1*load)"
    d += "c0:" >< "\(electricalParasitics[0])"
    d += "c1:" >< "\(electricalParasitics[1])"
    d += "c2:" >< "\(electricalParasitics[2])"
    d += "Parasitics of Cooling Tower for load < 50% [MW]:"
      >< "\(electricalParasiticsStep[0])"
    d += "Parasitics of Cooling Tower for load > 50% [MW]:"
      >< "\(electricalParasiticsStep[1])"
    d += "Parasitics of Shared Facilities for load = 0 [MW]:"
      >< "\(electricalParasiticsShared[0])"
    d += "Parasitics of Shared Facilities for load > 0 [MW]:"
      >< "\(electricalParasiticsShared[1])"
    d += "Nominal Parasitics of ACC [MW]:"
      >< "\(nominalElectricalParasiticsACC)"
    d += "ACC Parasitic f(Load) = ParasiticsACC(100%)*(c0+c1*load+c2*load^2+...)"
    for (i, c) in electricalParasiticsACC.coefficients.enumerated() {
      d += "c\(i):" >< String(format: "%.4E", c)
    }
    d += "ACC Parasitic f(Tamb) = ParasiticsACC(100%)*(c0+c1*Tamb+c2*Tamb^2+...)"
    for (i, c) in electricalParasiticsACCTamb.coefficients.enumerated() {
      d += "c\(i):" >< String(format: "%.4E", c)
    }
    return d
  }
}

extension PowerBlock.Parameter: TextConfigInitializable {
  public init(file: TextConfigFile) throws {
    let line: (Int) throws -> Double = { try file.parseDouble(line: $0) }
    name = file.name
    fixElectricalParasitics = try line(10)
    nominalElectricalParasitics = try line(13)
    electricalParasitics = try [line(16), line(19)]
    electricalParasiticsStep = try [line(22), line(25)]
    fixElectricalParasitics0 = try line(28)
    startUpElectricalParasitics = try line(31)
    nominalElectricalParasiticsACC = try line(39)
    electricalParasiticsShared = try [line(34), line(37)]
    electricalParasiticsACC = try [line(41), line(43), line(45), line(47)]
    electricalParasiticsACCTamb = try [line(49), line(51), line(53), line(55)]
  }
}
