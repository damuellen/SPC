//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Libc

public struct Power: Codable {

  public var watt: Double

  public var megaWatt: Double {
    get { watt / 1_000_000 }
    set { watt = newValue * 1_000_000 }
  }

  public var kiloWatt: Double {
    get { watt / 1_000 }
    set { watt = newValue * 1_000 }
  }

  public init() {
    self.watt = 0
  }

  public init(_ watt: Double) {
    self.watt = watt
  }

  public init(megaWatt: Double) {
    self.watt = megaWatt * 1_000_000
  }

  static func * (lhs: Power, rhs: Double) -> Power {
    Power(lhs.watt * rhs)
  }

  static func *= (lhs: inout Power, rhs: Double) {
    lhs.watt = lhs.watt * rhs
  }

  static func / (lhs: Power, rhs: Double) -> Power {
    Power(lhs.watt / rhs)
  }
}

extension Power: ExpressibleByFloatLiteral {
  public init(floatLiteral value: Double) {
    self.watt = value
  }
}

extension Power: Comparable, Equatable {
  public static func < (lhs: Power, rhs: Power) -> Bool {
    lhs.watt < rhs.watt
  }

  public static func == (lhs: Power, rhs: Power) -> Bool {
    fdim(lhs.watt, rhs.watt) < 1e-4
  }
}

extension Power: AdditiveArithmetic {
  public static var zero: Power = Power()

  public static func + (lhs: Power, rhs: Power) -> Power {
    Power(lhs.watt + rhs.watt)
  }

  public static func - (lhs: Power, rhs: Power) -> Power {
    Power(lhs.watt - rhs.watt)
  }
}
