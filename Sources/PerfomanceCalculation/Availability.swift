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
  
  subscript(dateTime: DateTime) -> Values {
    return data[dateTime.month]
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
