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

struct Availability: Codable {

  static var current = Availability()

  static var fuel: Double = 5

  private var index: Int { DateTime.indexMonth + 1 }

  private let data: [Values]

  init(_ data: [Values]) { self.data = data }

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

  var value: Values { self.data[index] }

  var values: Values { self.data[0] }

  private init() { self.data = Array(repeating: Values(), count: 13) }
}

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
