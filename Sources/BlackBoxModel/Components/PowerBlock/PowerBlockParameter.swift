//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Utilities

extension PowerBlock {
  /// A struct with the assigned details of the power block.
  public struct Parameter: Codable, Equatable {
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
    "Fixed Parasitics for Load = 0 [MW]:"
    * fixElectricalParasitics0.description
    + "Parasitics during PB Start-Up [MW]:"
    * startUpElectricalParasitics.description
    + "Fixed Parasitics (Load > 0) [MW]:"
    * fixElectricalParasitics.description
    + "Nominal Parasitics (Load = 1)[MW]:"
    * nominalElectricalParasiticsACC.description
    + "Parasitic ; Parasitics(Load) = Parasitics(100%)*(c0+c1*load)\n"
    + "c0:" * electricalParasitics[0].description
    + "c1:" * electricalParasitics[1].description
    + "c2:" * electricalParasitics[2].description
    + "Parasitics of Cooling Tower for load < 50% [MW]:"
    * electricalParasiticsStep[0].description
    + "Parasitics of Cooling Tower for load > 50% [MW]:"
    * electricalParasiticsStep[1].description
    + "Parasitics of Shared Facilities for load = 0 [MW]:"
    * electricalParasiticsShared[0].description
    + "Parasitics of Shared Facilities for load > 0 [MW]:"
    * electricalParasiticsShared[1].description
    + "Nominal Parasitics of ACC [MW]:"
    * nominalElectricalParasiticsACC.description
    + "ACC Parasitic f(Load) = ParasiticsACC(100%)*(c0+c1*load+c2*load^2+...)"
    + "\n\(electricalParasiticsACC)"
    + "ACC Parasitic f(Tamb) = ParasiticsACC(100%)*(c0+c1*Tamb+c2*Tamb^2+...)"
    + "\n\(electricalParasiticsACCTamb)"
  }
}

extension PowerBlock.Parameter: TextConfigInitializable {
  public init(file: TextConfigFile) throws {
    var line = 10
    var spacing = 3
    func parse() throws -> Double {
      defer { line += spacing }
      return try file.double(line: line)
    }
    name = file.name
    fixElectricalParasitics = try parse()
    nominalElectricalParasitics = try parse()
    electricalParasitics = try [parse(), parse()]
    electricalParasiticsStep = try [parse(), parse()]
    fixElectricalParasitics0 = try parse()
    startUpElectricalParasitics = try parse()
    electricalParasiticsShared = try [parse(), parse()]
    line = 39
    spacing = 2
    nominalElectricalParasiticsACC = try parse()
    electricalParasiticsACC = try [parse(), parse(), parse(), parse(), parse()]
    electricalParasiticsACCTamb = try [parse(), parse(), parse(), parse(), parse()]
  }
}
