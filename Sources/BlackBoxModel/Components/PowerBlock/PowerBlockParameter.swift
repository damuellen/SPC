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
    var line = 10, spacing = 3
    func parse()throws -> Double {
      defer { line += spacing }; return try file.parseDouble(line: line)
    }
    name = file.name
    fixElectricalParasitics = try parse()
    nominalElectricalParasitics = try parse()
    electricalParasitics = try [parse(), parse()]
    electricalParasiticsStep = try [parse(), parse()]
    fixElectricalParasitics0 = try parse()
    startUpElectricalParasitics = try parse()
    electricalParasiticsShared = try [parse(), parse()]
    spacing = 2
    nominalElectricalParasiticsACC = try parse()
    electricalParasiticsACC = try [parse(), parse(), parse(), parse()]
    electricalParasiticsACCTamb = try [parse(), parse(), parse(), parse()]
  }
}
