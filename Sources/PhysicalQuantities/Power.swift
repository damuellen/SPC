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

/// A unit of measure for power.
///
/// Power is the amount of energy used over time.
/// The SI unit for power is the watt (W),
/// which is derived as one joule per second (1W = 1J / 1s).
public struct Power: Codable {
  /// Returns the watts unit of power.
  public var watt: Double
  /// Returns the megawatts unit of power.
  public var megaWatt: Double {
    get { watt / 1_000_000 }
    set { watt = newValue * 1_000_000 }
  }
  /// Returns the kilowatts unit of power.
  public var kiloWatt: Double {
    get { watt / 1_000 }
    set { watt = newValue * 1_000 }
  }

  public var isZero: Bool { watt == 0 }
  /// Create a Power of zero.
  public init() {
    self.watt = 0
  }
  /// Create a Power given a specified value in watts.
  public init(_ watt: Double) {
    self.watt = watt
  }
  /// Create a Power given a specified value in megawatts.
  public init(megaWatt: Double) {
    self.watt = megaWatt * 1_000_000
  }

  public static func * (lhs: Power, rhs: Double) -> Power {
    Power(lhs.watt * rhs)
  }

  public static func *= (lhs: inout Power, rhs: Double) {
    lhs.watt = lhs.watt * rhs
  }

  public static func / (lhs: Power, rhs: Double) -> Power {
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
