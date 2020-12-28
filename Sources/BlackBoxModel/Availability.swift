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
import DateGenerator

struct Availability: Codable {

  static var current = withDefaults()

  static var fuel: Double = 5

  private var index: Int { DateTime.current.month }

  private let data: [Values]

  private static let defaults: Availability.Values = .init(
    solarField: 0.993, breakHCE: 0.001, airHCE: 0.0, fluorHCE: 0.0,
    reflMirror: 0.93, missingMirros: 0.0005, powerBlock: 1.0, storage: 0.98
  )

  init(_ data: [Values]) {
    self.data = data
  }

  public struct Values: Codable {
    var solarField,
      breakHCE,
      airHCE,
      fluorHCE,
      reflMirror,
      missingMirros,
      powerBlock,
      storage: Ratio
  }

  var value: Values { self.data[index] }

  var values: Values { self.data[0] }

  static func withDefaults() -> Availability {
    Availability(Array(repeating: Availability.defaults, count: 13))
  }
}

extension Availability {
  public init(file: TextConfigFile) throws {
    let ln: (Int) throws -> Double = { try file.double(line: $0) }
    var data = [Availability.defaults]
    for n in 0..<12 {
      let offset = 3 * n
      try data.append(
        Values(
          solarField: Ratio(percent: ln(38 + offset)),
          breakHCE: Ratio(percent: ln(78 + offset)),
          airHCE: Ratio(percent: ln(118 + offset)),
          fluorHCE: Ratio(percent: ln(158 + offset)),
          reflMirror: Ratio(percent: ln(198 + offset)),
          missingMirros: Ratio(percent: ln(238 + offset)),
          powerBlock: Ratio(percent: ln(278 + offset)),
          storage: Ratio(percent: 98) //ln(318 + offset))
        )
      )
    }
    self.init(data)
  }
}

extension Availability: CustomStringConvertible {
  public var description: String {
    "Annual Average Solar Field Availability [%]:"
    * values.solarField.percentage.description
    + "Average Percentage of Broken HCE [%]:"
    * values.breakHCE.percentage.description
    + "Average Percentage of HCE with Lost Vacuum [%]:"
    * values.airHCE.percentage.description
    + "Average Percentage of Flourescent HCE [%]:"
    * values.fluorHCE.percentage.description
    + "Average Mirror Reflectivity [%]:"
    * values.reflMirror.percentage.description
    + "Broken Mirrors [%]:"
    * values.missingMirros.percentage.description
  }
}