//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import DateExtensions
import Utilities

// A struct representing availability data for a solar power plant, including various percentages for each month.
struct Availability: Codable {

  // A static instance of Availability representing the current availability data.
  static var current = Availability()

  // A static variable representing the default fuel value for the power plant.
  static var fuel: Double = 5

  // A private computed property to get the current month index.
  private var index: Int { DateTime.indexMonth + 1 }

  // An array of Values struct representing the availability data for each month.
  private let data: [Values]

  // A nested struct representing the availability values for different components of the power plant.
  public struct Values: Codable {
    var solarField: Ratio = 0.993
    var breakHCE: Ratio = 0.001
    var airHCE: Ratio = 0.0
    var fluorHCE: Ratio = 0.0
    var reflMirror: Ratio = 0.93
    var missgMirror: Ratio = 0.0005
    var powerBlock: Ratio = 1.0
    var storage: Ratio = 1.0
  }

  // Computed property to get the availability values for the current month.
  var value: Values { self.data[index] }

  // Computed property to get the availability values for the entire year.
  var values: Values { self.data[0] }

  init(_ data: [Values]) { self.data = data }
  // Private initializer to create an Availability in∂stance with default availability values for each month.
  private init() { self.data = Array(repeating: Values(), count: 13) }
}

// An extension to provide an initializer to create an Availability instance from a TextConfigFile.
extension Availability {
  public init(file: TextConfigFile) throws {
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
          storage: Ratio(percent: 100) //ln(318 + offset))
        )
      )
    }
    self.init(data)
  }
}

// An extension to provide a description for the Availability struct.
extension Availability: CustomStringConvertible {
  public var description: String {
    let year = [
      "January", "February ", "March", "April", "Mai", "June", "July", "August",
      "September", "October", "November", "December",
    ]
    let month = "or individually for every Month [%]:\n"
    return "Annual Average Solar Field Availability [%]:"
      * String(format: "%.1f", values.solarField.percentage)
      + year.enumerated().reduce(into: month) {
        $0 += $1.1 * String(format: "%.1f", data[$1.0+1].solarField.percentage)
      } + "\n" + "Average Percentage of Broken HCE [%]:"
      * String(format: "%.1f", values.breakHCE.percentage)
      + year.enumerated().reduce(into: month) {
        $0 += $1.1 * String(format: "%.1f", data[$1.0+1].airHCE.percentage)
      } + "\n" + "Average Percentage of HCE with Lost Vacuum [%]:"
      * String(format: "%.1f", values.airHCE.percentage)
      + year.enumerated().reduce(into: month) {
        $0 += $1.1 * String(format: "%.1f", data[$1.0+1].airHCE.percentage)
      } + "\n" + "Average Percentage of Flourescent HCE [%]:"
      * String(format: "%.1f", values.fluorHCE.percentage)
      + year.enumerated().reduce(into: month) {
        $0 += $1.1 * String(format: "%.1f", data[$1.0+1].fluorHCE.percentage)
      } + "\n" + "Average Mirror Reflectivity [%]:"
      * String(format: "%.1f", values.reflMirror.percentage)
      + year.enumerated().reduce(into: month) {
        $0 += $1.1 * String(format: "%.1f", data[$1.0+1].reflMirror.percentage)
      } + "\n" + "Broken Mirrors [%]:" 
      * String(format: "%.1f", values.missgMirror.percentage)
      + year.enumerated().reduce(into: month) {
        $0 += $1.1 * String(format: "%.1f", data[$1.0+1].missgMirror.percentage)
      }
  }
}
