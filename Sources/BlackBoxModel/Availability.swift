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
import Foundation

struct Availability: Codable {

  static var current = withDefaults()

  static var fuel: Double = 5

  private var index: Int { return DateTime.current.month }

  private let data: [Values]

  private static let defaults: Availability.Values = .init(
    solarField: 0.99, breakHCE: 0.1, airHCE: 0.0, fluorHCE: 0.0,
    reflMirror: 0.93, missingMirros: 0.0005, powerBlock: 1.0, storage: 0.98
  )

  init(data: [Values]) {
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

  var value: Values { return self.data[index] }

  var values: Values { return self.data[0] }

  static func withDefaults() -> Availability {
    return Availability(
      data:
        Array(repeatElement(Availability.defaults, count: 13)))
  }
}

extension Availability {
  public init(file: TextConfigFile) throws {
    let line: (Int) throws -> Double = { try file.parseDouble(line: $0) }
    var data = [Values]()
    for n in 0..<12 {
      let offset = 3 * n
      try data.append(
        Values(
          solarField: Ratio(percent: line(38 + offset)),
          breakHCE: Ratio(percent: line(78 + offset)),
          airHCE: Ratio(percent: line(118 + offset)),
          fluorHCE: Ratio(percent: line(158 + offset)),
          reflMirror: Ratio(percent: line(198 + offset)),
          missingMirros: Ratio(percent: line(238 + offset)),
          powerBlock: Ratio(percent: line(278 + offset)),
          storage: Ratio(percent: line(318 + offset))
        ))
    }
    self.init(data: data)
  }
}
