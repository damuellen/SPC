//
//  Copyright (c) 2017 Daniel Müllenborn. All rights reserved.
//  Distributed under the The Non-Profit Open Software License version 3.0
//  http://opensource.org/licenses/NPOSL-3.0
//
//  This project is NOT free software. It is open source, you are allowed to
//  modify it (if you keep the license), but it may not be commercially
//  distributed other than under the conditions noted above.
//

import Foundation
import Config

public struct FuelParameter: Codable {
  let name: String
  let measurementUnit: String
  let LHV, price, density, part, FERCeff, usedAmount, Qsol: Double
}

extension FuelParameter {
  
  public init(file: TextConfigFile)throws {
    let row: (Int)throws -> Double = { try file.parseDouble(row: $0) }
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
