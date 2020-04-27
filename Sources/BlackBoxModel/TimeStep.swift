//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import CoreFoundation
import Foundation

/**
 TimeStep is used to easily make the calendar data
 of the current time step available during a run.

  - Attention: Needed by `Availability` and `GridDemand` both use `current`,
  also used in `SteamTurbine` and `Storage` routines.
*/
public struct TimeStep: CustomStringConvertible {

  public static var current = TimeStep()

  var isDaytime: Bool = true

  var isNighttime: Bool {
    return !isDaytime
  }

  var year: Int = 0
  var month: Int = 0
  var day: Int = 0
  var hour: Int = 0
  var minute: Int = 0
  private var second: Int = 0

  public var description: String {
    let ds = String(format: "%04d-%02d-%02d  %02d:%02d:%02d",
                    year, month, day, hour, minute, second)
    let symbol = isDaytime ? " 🌞 " : " 🌃 "
    return symbol + ds
  }

  static func setCurrent(date: Date) {
    current = .init(date)
  }

  typealias MonthDay = (day: Int, month: Int)

  func isWithin(start: MonthDay, stop: MonthDay) -> Bool {
    assert(start.month <= stop.month)
    var result = false
    if start.month ... stop.month ~= month {
      // month has been checked
      if start.month == stop.month { // both days must checked
        assert(start.day < stop.day - 1)
        if start.day + 1 ..< stop.day ~= day { result = true }
      } else if month == start.month { // start day must checked
        if day > start.day { result = true }
      } else if month == stop.month { // stop day must checked
        if day < stop.day { result = true }
      } else { // No day check necessary
        result = true
      }
    }
    return result
  }
}

extension TimeStep {

  init(_ date: Date) {
    let ref = date.timeIntervalSinceReferenceDate
    var absolute = Int(floor(ref / 86400.0))

    func daysAfterMonth(_ month: Int, _ year: Int, _ leap: Bool) -> Int {
      let daysAfterMonth = [365, 334, 306, 275, 245, 214, 184, 153, 122, 92, 61, 31, 0, 0, 0, 0]
      return daysAfterMonth[month] + ((month < 2 && leap) ? 1 : 0)
    }

    func daysBeforeMonth(_ month: Int, _ year: Int, _ leap: Bool) -> Int {
      let daysBeforeMonth = [0, 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365, 0, 0]
      return daysBeforeMonth[month] + ((month < 2 && leap) ? 1 : 0)
    }

    func isleap(_ year: Int) -> Bool {
      var y = (year + 1) % 400  /* correct to nearest multiple-of-400 year, then find the remainder */
      if y < 0 { y = -y }
      return (0 == (y & 3) && 100 != y && 200 != y && 300 != y);
    }

    let b = absolute / 146097 // take care of as many multiples of 400 years as possible
    var y = b * 400
    var ydays = 0
    absolute -= b * 146097;
    while (absolute < 0) {
      y -= 1
      absolute += daysAfterMonth(0, y, isleap(y))
    }
    /* Now absolute is non-negative days to add to year */
    ydays = daysAfterMonth(0, y, isleap(y))
    while ydays <= absolute {
      y += 1;
      absolute -= ydays;
      ydays = daysAfterMonth(0, y, isleap(y))
    }

    /* Now we have year and days-into-year */
    let year = y
    var m = absolute / 33 + 1 /* search from the approximation */
    let leap = isleap(y)
    while daysBeforeMonth(m + 1, y, leap) <= absolute { m += 1 }
    let month = m
    let day = absolute - daysBeforeMonth(m, y, leap) + 1

    func doubleModToInt(_ d: Double, _ modulus: Int) -> Int {
      var result = Int(floor(d - floor(d / Double(modulus)) * Double(modulus)))
      if result < 0 { result += modulus }
      return result
    }

    self.isDaytime = true
    self.year =  year + 2001
    self.month = month
    self.day = day
    self.hour = doubleModToInt(floor(ref / 3600.0), 24)
    self.minute = doubleModToInt(floor(ref / 60.0), 60)
    self.second = doubleModToInt(ref, 60)
  }
}
