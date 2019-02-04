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
    let fixelectricalParasitics: Double
    let nominalElectricalParasitics: Double
    let fixElectricalParasitics0: Double
    let startUpelectricalParasitics: Double
    let nominalElectricalParasiticsACC: Double
    let electricalParasiticsShared, electricalParasiticsStep,
      electricalParasitics, electricalParasiticsACC,
      electricalParasiticsACCTamb: Coefficients
  }
}

extension PowerBlock.Parameter: CustomStringConvertible {
  public var description: String {
    var d: String = ""
    d += "Fixed Parasitics for Load = 0 [MW]:"
      >< "\(fixElectricalParasitics0)"
    d += "Parasitics during PB Start-Up [MW]:"
      >< "\(startUpelectricalParasitics)"
    d += "Fixed Parasitics (Load > 0) [MW]:"
      >< "\(fixelectricalParasitics)"
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
    let row: (Int) throws -> Double = { try file.parseDouble(row: $0) }
    name = file.name
    fixelectricalParasitics = try row(10)
    nominalElectricalParasitics = try row(13)
    electricalParasitics = try [row(16), row(19)]
    electricalParasiticsStep = try [row(22), row(25)]
    fixElectricalParasitics0 = try row(28)
    startUpelectricalParasitics = try row(31)
    nominalElectricalParasiticsACC = try row(39)
    electricalParasiticsShared = try [row(34), row(37)]
    electricalParasiticsACC = try [row(41), row(43), row(45), row(47)]
    electricalParasiticsACCTamb = try [row(49), row(51), row(53), row(55)]
  }
}
