// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import Helpers

/// A struct representing parameters related to a specific fuel used in an power plant.
struct FuelParameter: Codable {
  /// The name of the fuel.
  let name: String
  /// The measurement unit for the fuel's properties.
  let measurementUnit: String
  /// The lower heat value of the fuel in kilowatt-hours per kilogram (kWh/kg).
  let LHV: Double
  /// The price of the fuel in currency per unit.
  let price: Double
  /// The density of the fuel in kilograms per cubic meter (kg/m³).
  let density: Double
  /// The allowed fuel share (currently not used).
  let part: Double
  /// The fuel efficiency assumed by authorities as a percentage (currently not used).
  let FERCeff: Double
  /// The fuel amount already used in megawatt-hours (MWh) (currently not used).
  let usedAmount: Double
  /// The solar energy already produced in megawatt-hours (MWh) (currently not used).
  let Qsol: Double
}

extension FuelParameter {
  /// Initializes the `FuelParameter` instance from a text configuration file (`TextConfigFile`).
  ///
  /// - Parameter file: The `TextConfigFile` containing fuel parameter information.
  /// - Throws: An error if there is an issue reading or parsing the fuel parameter data from the file.
  init(file: TextConfigFile) throws {
    // Helper function to read a double value from the specified line number in the file
    let ln: (Int) throws -> Double = { try file.readDouble(lineNumber: $0) }

    // Read the fuel parameter values from specific lines in the file and assign them to the corresponding properties
    self.name = file.name
    self.measurementUnit = file.lines[9]
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
  /// A string representation of the `FuelParameter` instance.
  public var description: String {
    "Name :" * name + "Unit :" * measurementUnit.description
      + "Lower Heat Value [kWh/kg] :" * LHV.description
      + "Fuel Price [Currency/Unit] :" * price.description
      + "Density [kg/m³] :" * density.description
      + "Allowed Fuel share (currently not used) :" * part.description
      + "Fuel Efficiency assumed by Authorities [%] (currently not used) :"
      * FERCeff.description
      + "Fuel Amount already used [MWh] (currently not used) :"
      * usedAmount.description
      + "Solar Energy already produced [MWh] (currently not used) :"
      * Qsol.description
  }
}
