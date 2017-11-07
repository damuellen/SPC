//
//  Copyright (c) 2017 Daniel Müllenborn. All rights reserved.
//  Distributed under the The Non-Profit Open Software License version 3.0
//  http://opensource.org/licenses/NPOSL-3.0
//
//  This project is NOT free software. It is open source, you are allowed to
//  modify it (if you keep the license), but it may not be commercially
//  distributed other than under the conditions noted above.
//

import Darwin

infix operator ** : MultiplicationPrecedence

func ** (num: Double, power: Double) -> Double {
  return pow(num, power)
}

infix operator ><

func >< (lhs: String, rhs: String) -> String {
  let count = 80 - lhs.count - rhs.count
  return lhs + String(repeating: " ", count: count) + rhs + "\n"
}


