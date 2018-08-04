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
import Foundation

public struct FuelParameter: Codable {
  let name: String
  let measurementUnit: String
  let LHV, price, density, part, FERCeff, usedAmount, Qsol: Double
}

extension FuelParameter {
  public init(file: TextConfigFile) throws {
    let row: (Int) throws -> Double = { try file.parseDouble(row: $0) }
    self.name = file.name
    self.measurementUnit = file.values[9]
    self.LHV = try row(13)
    self.price = try row(16)
    self.density = try row(19)
    self.part = try row(22)
    self.FERCeff = try row(25)
    self.usedAmount = try row(28)
    self.Qsol = try row(31)
  }
}
