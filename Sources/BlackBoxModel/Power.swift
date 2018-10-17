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

public struct Power: Codable {
  
  public var watt: Double

  public var megaWatt: Double {
    get { return watt / 1_000_000 }
    set { watt = newValue * 1_000_000 }
  }
  
  static func + (lhs: Power, rhs: Power) -> Power {
    return Power(watt: lhs.watt + rhs.watt)
  }
  
  static func += (lhs: inout Power, rhs: Power) {
    lhs.watt = lhs.watt + rhs.watt
  }
  
  static func - (lhs: Power, rhs: Power) -> Power {
    return Power(watt: lhs.watt - rhs.watt)
  }
  
  static func * (lhs: Power, rhs: Double) -> Power {
    return Power(watt: lhs.watt * rhs)
  }
}

extension Power: ExpressibleByFloatLiteral {
  public init(floatLiteral value: Double) {
    self.watt = value
  }
}
