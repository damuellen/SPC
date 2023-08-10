// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import DateExtensions
import Utilities

/// A struct representing availability data for a solar power plant, including various percentages for each month.
struct Availability: Codable {

  /// A static instance of Availability representing the current availability data.
  static var current = Availability()

  /// A static variable representing the default fuel value for the power plant.
  static var fuel: Double = 5

  /// A private computed property to get the current month index.
  private var index: Int { DateTime.indexMonth + 1 }

  /// An array of Values struct representing the availability data for each month.
  private let data: [Values]

  /// A nested struct representing the availability values for different components of the power plant.
  struct Values: Codable {
    /// Availability percentage for the solar field.
    var solarField: Ratio = 0.993
    /// Availability percentage for the broken HCE (Heat Collection Element).
    var breakHCE: Ratio = 0.001
    /// Availability percentage for the HCE with lost vacuum.
    var airHCE: Ratio = 0.0
    /// Availability percentage for the fluorescent HCE.
    var fluorHCE: Ratio = 0.0
    /// Availability percentage for the mirror reflectivity.
    var reflMirror: Ratio = 0.93
    /// Availability percentage for the mirrors with missing or damaged glass.
    var missgMirror: Ratio = 0.0005
    /// Availability percentage for the power block, including turbines and generators.
    var powerBlock: Ratio = 1.0
    /// Availability percentage for the energy storage system.
    var storage: Ratio = 1.0
  }

  /// Computed property to get the availability values for the current month.
  var value: Values { self.data[index] }

  /// Computed property to get the availability values for the entire year.
  var values: Values { self.data[0] }

  init(_ data: [Values]) { self.data = data }
  /// Private initializer to create an Availability in∂stance with default availability values for each month.
  private init() { self.data = Array(repeating: Values(), count: 13) }
}

/// An extension to provide an initializer to create an Availability instance from a TextConfigFile.
extension Availability {
  init(file: TextConfigFile) throws {
    let ln: (Int) throws -> Double = { try file.readDouble(lineNumber: $0) }
    var data = [Values()]
    for n in 0..<12 {
      let offset = 3 * n
      try data.append(
        Values(
          solarField: Ratio(percent: ln(38 + offset)),
          breakHCE: Ratio(percent: ln(78 + offset)),
          airHCE: Ratio(percent: ln(118 + offset)),
          fluorHCE: Ratio(percent: ln(158 + offset)),
          reflMirror: Ratio(percent: ln(198 + offset)),
          missgMirror: Ratio(percent: ln(238 + offset)),
          powerBlock: Ratio(percent: ln(278 + offset)),
          storage: Ratio(percent: 100)  //ln(318 + offset))
        ))
    }
    self.init(data)
  }
}

extension Availability: CustomStringConvertible {
  /// A string representation of the `Availability` instance.
  public var description: String {
    let year = [
      "January", "February ", "March", "April", "Mai", "June", "July",
      "August", "September", "October", "November", "December",
    ]
    let month = "or individually for every Month [%]:\n"
    return "Annual Average Solar Field Availability [%]:"
      * String(format: "%.1f", values.solarField.percentage)
      + year.enumerated()
      .reduce(into: month) {
        $0 +=
          $1.1 * String(format: "%.1f", data[$1.0 + 1].solarField.percentage)
      } + "\n" + "Average Percentage of Broken HCE [%]:"
      * String(format: "%.1f", values.breakHCE.percentage)
      + year.enumerated()
      .reduce(into: month) {
        $0 += $1.1 * String(format: "%.1f", data[$1.0 + 1].airHCE.percentage)
      } + "\n" + "Average Percentage of HCE with Lost Vacuum [%]:"
      * String(format: "%.1f", values.airHCE.percentage)
      + year.enumerated()
      .reduce(into: month) {
        $0 += $1.1 * String(format: "%.1f", data[$1.0 + 1].airHCE.percentage)
      } + "\n" + "Average Percentage of Flourescent HCE [%]:"
      * String(format: "%.1f", values.fluorHCE.percentage)
      + year.enumerated()
      .reduce(into: month) {
        $0 += $1.1 * String(format: "%.1f", data[$1.0 + 1].fluorHCE.percentage)
      } + "\n" + "Average Mirror Reflectivity [%]:"
      * String(format: "%.1f", values.reflMirror.percentage)
      + year.enumerated()
      .reduce(into: month) {
        $0 +=
          $1.1 * String(format: "%.1f", data[$1.0 + 1].reflMirror.percentage)
      } + "\n" + "Broken Mirrors [%]:"
      * String(format: "%.1f", values.missgMirror.percentage)
      + year.enumerated()
      .reduce(into: month) {
        $0 +=
          $1.1 * String(format: "%.1f", data[$1.0 + 1].missgMirror.percentage)
      }
  }
}
