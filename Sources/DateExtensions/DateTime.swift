// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import Foundation

/// DateTime is a struct used to represent calendar data for the current time step during a simulation.
///
/// - Note: This struct is utilized by several routines, including `Availability` and `GridDemand`, and also used in `SteamTurbine` and `Storage`.
public struct DateTime: CustomStringConvertible {
  /// The current DateTime object representing the current time step.
  private(set) public static var current = DateTime(
    year: 0, month: 0, day: 0, hour: 0, minute: 0, yearDay: 0, second: 0)
  /// A boolean value indicating if it is currently nighttime.
  private(set) static var nightfall = false
  /// A boolean value indicating if it is currently daytime.
  private(set) var isDaytime: Bool = false
  /// A boolean value indicating if the sun has risen.
  private(set) var isSunRise: Bool = false
  /// A boolean value indicating if the sun has set.
  private(set) var isSunSet: Bool = false
  /// A boolean value indicating if it is currently nighttime (opposite of isDaytime).
  public var isNighttime: Bool { !isDaytime }
  /// The hour index in the current day for the meteorological data.
  public static var indexHour: Int { current.hour }
  /// The day index in the current year for the meteorological data.
  public static var indexDay: Int { current.yearDay - 1 }
  /// The month index in the current year for the meteorological data.
  public static var indexMonth: Int { current.month - 1 }
  /// A boolean value indicating if it is currently daytime.
  public static var isDaytime: Bool { current.isDaytime }
  /// A boolean value indicating if the sun has risen.
  public static var isSunRise: Bool { current.isSunRise }
  /// A boolean value indicating if the sun has set.
  public static var isSunSet: Bool { current.isSunSet }
  /// The year in the DateTime object.
  public var year: Int
  /// The month in the DateTime object.
  public var month: Int
  /// The day in the DateTime object.
  public var day: Int
  /// The hour in the DateTime object.
  public var hour: Int
  /// The minute in the DateTime object.
  public var minute: Int
  /// The day of the year (yearDay) in the DateTime object.
  public var yearDay: Int
  /// The second in the DateTime object.
  public var second: Int

  /// A string representation of the DateTime object in the format "yyyy-MM-ddTHH:mm:ssZ".
  public var description: String {
    String(
      format: "%04d-%02d-%02dT%02d:%02d:%02dZ", year, month, day, hour, minute,
      second)
  }

  /// A comma-separated string containing the month, day, and hour of the DateTime object.
  public var commaSeparatedValues: String { "\(month),\(day),\(hour)" }

  /// A string representation of the date in the format "MM-dd".
  public var calendarDay: String { String(format: "%02d-%02d", month, day) }

  /// A string representation of the time in the format "HH:mm".
  public var time: String { String(format: "%02d:%02d", hour, minute) }

  /// Set the current DateTime object based on the given date.
  ///
  /// - Parameter date: The date to set as the current DateTime.
  public static func setCurrent(date: Date) {
    nightfall = current.isDaytime
    current = .init(date)
    if !nightfall { current.isSunRise = true }
  }

  /// Set the current DateTime object to represent nighttime.
  public static func setNight() {
    current.isDaytime = false
    current.isSunRise = false
    current.isSunSet = nightfall
    nightfall = false
  }

  public typealias MonthDay = (day: Int, month: Int)

  /// Check if the DateTime object matches the given minute, hour, day, and month values.
  ///
  /// - Parameters:
  ///   - minute: The minute value to check (default is nil to match the current minute).
  ///   - hour: The hour value to check (default is nil to match the current hour).
  ///   - day: The day value to check (default is nil to match the current day).
  ///   - month: The month value to check (default is nil to match the current month).
  /// - Returns: A boolean value indicating if the DateTime object matches the given values.
  public static func `is`(
    minute: Int? = nil, hour: Int? = nil, day: Int? = nil, month: Int? = nil
  ) -> Bool {
    guard current.minute == (minute ?? current.minute) else { return false }
    guard current.hour == (hour ?? current.hour) else { return false }
    guard current.day == (day ?? current.day) else { return false }
    guard current.month == (month ?? current.month) else { return false }
    return true
  }

  /// Check if the DateTime object matches the given minute, hour, and yearDay values.
  ///
  /// - Parameters:
  ///   - minute: The minute value to check.
  ///   - hour: The hour value to check (default is nil to match the current hour).
  ///   - yearDay: The yearDay value to check (default is nil to match the current day).
  /// - Returns: A boolean value indicating if the DateTime object matches the given values.
  public static func `is`(
    minute: Int = 0, hour: Int? = nil, yearDay: Int? = nil
  ) -> Bool {
    guard current.minute == minute else { return false }
    guard current.hour == (hour ?? current.hour) else { return false }
    guard current.yearDay == (yearDay ?? current.day) else { return false }
    return true
  }

  /// Check if the DateTime object is within the given start and stop MonthDay values.
  ///
  /// - Parameters:
  ///   - start: The start MonthDay value to check.
  ///   - stop: The stop MonthDay value to check.
  /// - Returns: A boolean value indicating if the DateTime object is within the given range.
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
  /// Initialize a new DateTime object with the given Date.
  ///
  /// - Parameter date: The Date to use for creating the DateTime object.
  public init(_ date: Date) {
    #if os(Windows)
    var timeInfo = tm.init()
    var time = time_t(date.timeIntervalSince1970)
    gmtime_s(&timeInfo, &time)
    #else
    var ts = Int(date.timeIntervalSince1970)
    let timeInfo = gmtime(&ts).pointee
    #endif

    self.isDaytime = true
    self.year = Int(timeInfo.tm_year + 1900)
    self.month = Int(timeInfo.tm_mon + 1)
    self.day = Int(timeInfo.tm_mday)
    self.yearDay = Int(timeInfo.tm_yday)
    self.hour = Int(timeInfo.tm_hour)
    self.minute = Int(timeInfo.tm_min)
    self.second = Int(timeInfo.tm_sec)
  }
}
