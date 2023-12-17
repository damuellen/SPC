// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import Foundation

/// A type alias for fractional time, represented as a double.
public typealias FractionalTime = Double

extension DateTime {
  /// Sets the time of the date instance to the specified fractional time.
  /// - Parameter fractionalTime: The fractional time value (hour with decimal fraction).
  /// - Returns: A new date instance with the time set to the specified fractional time.
  public func date(time fractionalTime: FractionalTime) -> Date {
    let min = 60 * (fractionalTime - Double(Int(fractionalTime)))
    let sec = 60 * (min - Double(Int(min)))
    var new = self
    new.hour = Int(fractionalTime)
    new.minute = Int(min)
    new.second = Int(sec)
    return new.date
  }

  public var date: Date {
    var tm = tm.init()
    tm.tm_year = Int32(self.year - 1900)
    tm.tm_mon = Int32(self.month - 1)
    tm.tm_mday = Int32(self.day)
    tm.tm_yday = Int32(self.yearDay)
    tm.tm_hour = Int32(self.hour)
    tm.tm_min = Int32(self.minute) 
    tm.tm_sec = Int32(self.second)
    #if os(Windows)
    let time = _mkgmtime(&tm)
    #else
    let time = timegm(&tm)
    #endif
    return Date(timeIntervalSince1970: Double(time))
  }

  public var isLeapYear: Bool {
    if (year & 3) != 0 { return false }
    if year % 400 == 0 { return true }
    if year % 100 == 0 { return false }
    return true
  }
}

extension DateInterval {
  /// Aligns the date interval to the specified frequency in values per hour.
  /// - Parameter valuesPerHour: The frequency of values per hour for alignment.
  /// - Returns: A new date interval aligned to the specified frequency.
  public func aligned(to valuesPerHour: DateSeries.Frequence) -> DateInterval {
    var start = DateTime(self.start)
    var end = DateTime(self.end)

    start.second = 0
    end.second = 0

    let interval = 60.0 / Double(valuesPerHour.rawValue)
    start.minute = (Int(Double(start.minute) / interval)) * Int(interval)
    end.minute = Int((Double(end.minute) / interval).rounded(.up)) * Int(interval)

    return DateInterval(start: start.date, end: end.date)
  }
}