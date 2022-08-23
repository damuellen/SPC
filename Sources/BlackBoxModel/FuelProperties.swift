//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Helpers

public struct FuelParameter: Codable {
  let name: String
  let measurementUnit: String
  let LHV, price, density, part, FERCeff, usedAmount, Qsol: Double
}

extension FuelParameter {
  public init(file: TextConfigFile) throws {
    let ln: (Int) throws -> Double = { try file.double(line: $0) }
    self.name = file.name
    self.measurementUnit = file.values[9]
    self.LHV = try ln(13)
    self.price = try ln(16)
    self.density = try ln(19)
    self.part = try ln(22)
    self.FERCeff = try ln(25)
    self.usedAmount = try ln(28)
    self.Qsol = try ln(31)
  }
}

extension FuelParameter: CustomStringConvertible {
  public var description: String {
    "Name :" * name
    + "Unit :" * measurementUnit.description
    + "Lower Heat Value [kWh/kg] :" * LHV.description
    + "Fuel Price [Currency/Unit] :" * price.description
    + "Density [kg/m³] :" * density.description
    + "Allowed Fuel share (currently not used) :" * part.description
    + "Fuel Efficiency assumed by Authorities [%] (currently not used) :" * FERCeff.description
    + "Fuel Amount already used [MWh] (currently not used) :" * usedAmount.description
    + "Solar Energy already produced [MWh] (currently not used) :" * Qsol.description
  }
}
