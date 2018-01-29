//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation
import Config

public struct Availability: Codable {
  let data: [Values]
  
  private static let defaults: Availability.Values = .init(
    solarField: 0.99, breakHCE: 0.1, airHCE: 0.0, fluorHCE: 0.0,
    reflMirror: 0.93, missingMirros: 0.0005, powerBlock: 1.0, storage: 0.98)
  
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
  
  var values: Values {
    return data[0]
  }
  
  static func withDefaults() -> Availability {
    return Availability(data:
      Array(repeatElement(Availability.defaults, count: 13))
    )
  }
  
  subscript(calendar: CalendarDay) -> Values {
    return data[calendar.month]
  }
}

extension Availability {
  public init(file: TextConfigFile)throws {
    let row: (Int)throws -> Double = { try file.parseDouble(row: $0) }
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
        storage: Ratio(percent: row(318 + offset)))
      )
    }
    self.data = data
  }
}
