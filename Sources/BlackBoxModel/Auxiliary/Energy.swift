//
//  Copyright 2021 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Libc

public struct Energy: Codable {

  public var joule: Double // W/s

  public var kiloWattHour: Double {
    get { joule / 3_600 / 1_000 }
    set { joule = newValue * 3_600 * 1_000 }
  }

  public init(_ joule: Double) {
    self.joule = joule
  }

  public init() {
    self.joule = 0
  }
}

extension Energy: ExpressibleByFloatLiteral {
  public init(floatLiteral value: Double) {
    self.joule = value
  }
}

extension Energy: Comparable, Equatable {
  public static func < (lhs: Energy, rhs: Energy) -> Bool {
    lhs.joule < rhs.joule
  }

  public static func == (lhs: Energy, rhs: Energy) -> Bool {
    fdim(lhs.joule, rhs.joule) < 1e-4
  }
}

extension Energy: AdditiveArithmetic {
  public static var zero: Energy = Energy()

  public static func + (lhs: Energy, rhs: Energy) -> Energy {
    Energy(lhs.joule + rhs.joule)
  }

  public static func - (lhs: Energy, rhs: Energy) -> Energy {
    Energy(lhs.joule - rhs.joule)
  }
}
