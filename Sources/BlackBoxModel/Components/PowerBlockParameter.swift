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

/// The PowerBlock namespace contains structures and extensions related to power block parameters.
extension PowerBlock {
  /// The Parameter struct represents the parameters of the power block and is Codable and Equatable for serialization and comparison.
  public struct Parameter: Codable, Equatable {
    /// The name of the power block.
    let name: String
    /// The fixed electrical parasitics for load > 0 [MW].
    let fixElectricalParasitics: Double
    /// The nominal electrical parasitics for load = 1 [MW].
    let nominalElectricalParasitics: Double
    /// The fixed electrical parasitics for load = 0 [MW].
    let fixElectricalParasitics0: Double
    /// The parasitics during power block start-up [MW].
    let startUpElectricalParasitics: Double
    /// The nominal electrical parasitics of the auxiliary condenser cooling (ACC) [MW].
    let nominalElectricalParasiticsACC: Double
    /// The electrical parasitics of the shared facilities for load = 0 [MW] and load > 0 [MW].
    let electricalParasiticsShared: Polynomial
    /// The electrical parasitics of the cooling tower for load < 50% [MW].
    let electricalParasiticsStep: Polynomial
    /// The polynomial representing electrical parasitics for load = parasitics(100%) * (c0 + c1 * load).
    let electricalParasitics: Polynomial
    /// The polynomial representing ACC parasitics for load = parasiticsACC(100%) * (c0 + c1 * load + c2 * load^2 + ...).
    let electricalParasiticsACC: Polynomial
    /// The polynomial representing ACC parasitics for temperature Tamb = parasiticsACC(100%) * (c0 + c1 * Tamb + c2 * Tamb^2 + ...).
    let electricalParasiticsACCTamb: Polynomial
  }
}

/// Custom description for PowerBlock.Parameter to provide a formatted string representation.
extension PowerBlock.Parameter: CustomStringConvertible {
  public var description: String {
    "Description:" * name
    + "Fixed Parasitics for Load = 0 [MW]:"
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
    // + "c2:" * electricalParasitics[2].description
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

/// TextConfigInitializable extension for PowerBlock.Parameter to create an instance using data from a TextConfigFile.
extension PowerBlock.Parameter: TextConfigInitializable {
  /// Creates a `PowerBlock.Parameter` instance using the data from a `TextConfigFile`.
  /// - Parameter file: The `TextConfigFile` containing the data for the parameter.
  public init(file: TextConfigFile) throws {
    var line = 10
    func go(_ spacing: Int) throws -> Double {
      defer { line += spacing }
      return try file.readDouble(lineNumber: line)
    }
    name = file.name
    fixElectricalParasitics = try go(3)
    nominalElectricalParasitics = try go(3)
    electricalParasitics = try [go(3), go(3)]
    electricalParasiticsStep = try [go(3), go(3)]
    fixElectricalParasitics0 = try go(3)
    startUpElectricalParasitics = try go(3)
    electricalParasiticsShared = try [go(3), go(2)]
    nominalElectricalParasiticsACC = try go(2)
    electricalParasiticsACC = try [go(2), go(2), go(2), go(2), go(2)]
    electricalParasiticsACCTamb = try [go(2), go(2), go(2), go(2), go(2)]
  }
}
