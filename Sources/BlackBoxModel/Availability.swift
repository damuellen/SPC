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

public class Availability: Codable {
  static var fuel: Double = .greatestFiniteMagnitude
  let data: [Values]
  var index = 0
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

  var value: Values {
    return self.data[index]
  }

  var values: Values {
    return self.data[0]
  }

  static func withDefaults() -> Availability {
    return Availability(data:
      Array(repeatElement(Availability.defaults, count: 13)))
  }

  func set(calendar: TimeStep) {
    self.index = calendar.month
  }
}

extension Availability {
  public convenience init(file: TextConfigFile) throws {
    let row: (Int) throws -> Double = { try file.parseDouble(row: $0) }
    var data = [Values]()
    for n in 0 ..< 12 {
      let offset = 3 * n
      try data.append(Values(
        solarField: Ratio(percent: row(38 + offset)),
        breakHCE: Ratio(percent: row(78 + offset)),
        airHCE: Ratio(percent: row(118 + offset)),
        fluorHCE: Ratio(percent: row(158 + offset)),
        reflMirror: Ratio(percent: row(198 + offset)),
        missingMirros: Ratio(percent: row(238 + offset)),
        powerBlock: Ratio(percent: row(278 + offset)),
        storage: Ratio(percent: row(318 + offset))
      ))
    }
    self.init(data: data)
  }
}
