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

public typealias Heat = Double
public typealias Pressure = Double
public typealias Angle = Double

public extension Double {
  var toCelsius: Double { return self - 273.15 }
  var toKelvin: Double { return self + 273.15 }
}

public extension Float {
  var toKelvin: Float { return self + 273.15 }
}

public extension Angle {
  var radians: Double { return self * .pi / 180 }
  var degrees: Double { return self *  180 / .pi}
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
