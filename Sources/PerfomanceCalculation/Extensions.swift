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

infix operator **: MultiplicationPrecedence

func ** (num: Double, power: Double) -> Double {
  return pow(num, power)
}

infix operator ><

func >< (lhs: String, rhs: String) -> String {
  let count = 80 - lhs.utf16.count - rhs.utf16.count
  return lhs + String(repeating: " ", count: count) + rhs + "\n"
}

public extension Array {
  public static func += (lhs: inout Array, rhs: Element) {
    lhs.append(rhs)
  }
}
 
public typealias Temperature = Double
public typealias Pressure = Double
public typealias Angle = Double


public extension Angle {
  var toRadians: Double { return self * .pi / 180 }
  var toDegress: Double { return self *  180 / .pi}
}

public extension Temperature {
  var toCelsius: Double { return self - 273.15 }
  var toKelvin: Double { return self + 273.15 }
}

let calendar = { calendar -> Calendar in
  var calendar = calendar
  calendar.timeZone = TimeZone(secondsFromGMT: 0)!
  return calendar
}(Calendar(identifier: .gregorian))

extension Progress {
  func tracking(month: Int) {
    let month = Int64(month)
    if month > self.completedUnitCount {
      self.completedUnitCount = month
      print("Month", self.completedUnitCount,
            "is currently being calculated.")
    }
  }
}
