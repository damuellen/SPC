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

/// A unit of measure for mass.
public struct Mass: Codable, CustomStringConvertible {
  /// A textual description of the value in metric tons.
  public var description: String {
    String(format: "%.1ft", kg / 1_000)
  }
  /// Returns the kilograms unit of mass.
  public var kg: Double 

  public init(_ kg: Double) {
    self.kg = kg
  }
  /// Create a Mass given a specified value in metric tons.
  public init(ton: Double) {
    self.kg = ton * 1_000
  }
  /// Create a Mass of zero.
  public init() {
    self.kg = 0
  }

  public static func * (lhs: Mass, rhs: Double) -> Mass {
    Mass(lhs.kg * rhs)
  }
}

extension Mass: ExpressibleByFloatLiteral {
  public init(floatLiteral value: Double) {
    self.kg = value
  }
}

extension Mass: Comparable, Equatable {
  public static func < (lhs: Mass, rhs: Mass) -> Bool {
    lhs.kg < rhs.kg
  }

  public static func == (lhs: Mass, rhs: Mass) -> Bool {
    fdim(lhs.kg, rhs.kg) < 1e-4
  }
}

extension Mass: AdditiveArithmetic {
  public static var zero: Mass = Mass()

  public static func + (lhs: Mass, rhs: Mass) -> Mass {
    Mass(lhs.kg + rhs.kg)
  }

  public static func - (lhs: Mass, rhs: Mass) -> Mass {
    Mass(lhs.kg - rhs.kg)
  }
}
