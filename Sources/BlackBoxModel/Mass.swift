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

public struct Mass: Codable, CustomStringConvertible {

  public var description: String {
    "\(kg / 1000)t"
  }

  public var kg: Double 

  public init(_ kg: Double) {
    self.kg = kg
  }

  public init() {
    self.kg = 0
  }

  static func * (lhs: Mass, rhs: Double) -> Mass {
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
