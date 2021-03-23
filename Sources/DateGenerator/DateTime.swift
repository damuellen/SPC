//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation

/// DateTime is used to easily make the calendar data
/// of the current time step available during a run.
///
///  - Attention: Needed by `Availability` and `GridDemand` both use `current`,
///  also used in `SteamTurbine` and `Storage` routines.
public struct DateTime: CustomStringConvertible {

  private(set) public static var current = DateTime()
  private(set) static var nightfall = false

  private(set) var isDaytime: Bool = false
  private(set) var isSunRise: Bool = false
  private(set) var isSunSet: Bool = false

  public var isNighttime: Bool { !isDaytime }
  /// The meteorological data suitable for today are identified with this property. `MeteoDataSource.currentDay`
  public static var indexDay: Int { current.yearDay - 1 }
  public static var indexMonth: Int { current.month - 1 }
  public static var isDaytime: Bool { current.isDaytime }
  public static var isSunRise: Bool { current.isSunRise }
  public static var isSunSet: Bool { current.isSunSet }

  public let year: Int
  public let month: Int
  public let day: Int
  public let hour: Int
  public let minute: Int
  public let yearDay: Int
  private let second: Int

  public var description: String {
    let ds = String(
      format: "%04d-%02d-%02dT%02d:%02d:%02dZ",
      year, month, day, hour, minute, second)
    //let symbol = isDaytime ? " 🌞 " : " 🌑 "
    return ds
  }

  public static func setCurrent(date: Date) {
    nightfall = current.isDaytime
    current = .init(date)
    if !nightfall { current.isSunRise = true }
  }

  public static func setNight() {
    current.isDaytime = false
    current.isSunRise = false
    current.isSunSet = nightfall
    nightfall = false
  }

  public typealias MonthDay = (day: Int, month: Int)

  public static func at(minute: Int = 0, hour: Int? = nil, day: Int? = nil, month: Int? = nil) -> Bool {
    guard current.minute == minute else { return false }
    guard current.hour == (hour ?? current.hour) else { return false }
    guard current.day == (day ?? current.day) else { return false }
    guard current.month == (month ?? current.month) else { return false }
    return true
  }

  public static func at(minute: Int = 0, hour: Int? = nil, yearDay: Int? = nil) -> Bool {
    guard current.minute == minute else { return false }
    guard current.hour == (hour ?? current.hour) else { return false }
    guard current.yearDay == (yearDay ?? current.day) else { return false }
    return true
  }

  public func isWithin(start: MonthDay, stop: MonthDay) -> Bool {
    assert(start.month <= stop.month)
    var result = false
    if start.month...stop.month ~= month {
      // month has been checked
      if start.month == stop.month {  // both days must checked
        assert(start.day < stop.day - 1)
        if start.day + 1..<stop.day ~= day { result = true }
      } else if month == start.month {  // start day must checked
        if day > start.day { result = true }
      } else if month == stop.month {  // stop day must checked
        if day < stop.day { result = true }
      } else {  // No day check necessary
        result = true
      }
    }
    return result
  }
}

extension DateTime {

  init() {
    self.year = 0
    self.month = 0
    self.day = 0
    self.hour = 0
    self.minute = 0
    self.yearDay = 0
    self.second = 0
  }

  public init(_ date: Date) {
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
      var y =
        (year + 1) % 400 /* correct to nearest multiple-of-400 year, then find the remainder */
      if y < 0 { y = -y }
      return (0 == (y & 3) && 100 != y && 200 != y && 300 != y)
    }

    let b = absolute / 146097  // take care of as many multiples of 400 years as possible
    var y = b * 400
    var ydays = 0
    absolute -= b * 146097
    while absolute < 0 {
      y -= 1
      absolute += daysAfterMonth(0, y, isleap(y))
    }
    /* Now absolute is non-negative days to add to year */
    ydays = daysAfterMonth(0, y, isleap(y))
    while ydays <= absolute {
      y += 1
      absolute -= ydays
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
    self.year = year + 2001
    self.month = month
    self.day = day
    self.yearDay = Int(absolute) + 1
    self.hour = doubleModToInt(floor(ref / 3600.0), 24)
    self.minute = doubleModToInt(floor(ref / 60.0), 60)
    self.second = doubleModToInt(ref, 60)
  }
}
