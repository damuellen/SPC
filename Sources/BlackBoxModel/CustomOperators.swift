//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Darwin

precedencegroup ExponentiationPrecedence {
  associativity: right
  higherThan: MultiplicationPrecedence
}

infix operator **: ExponentiationPrecedence
infix operator **=: AssignmentPrecedence

extension Double {
  static func ** (lhs: Double, rhs: Double) -> Double {
    return pow(lhs, rhs)
  }

  static func **= (lhs: inout Double, rhs: Double) {
    lhs = lhs ** rhs
  }
}

infix operator ><

func >< (lhs: String, rhs: String) -> String {
  let count = 80 - lhs.count - rhs.count
  return lhs + String(repeating: " ", count: count) + rhs + "\n"
}
