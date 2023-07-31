//
//  Copyright 2022 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation

public let Greenwich = { calendar -> NSCalendar in
  calendar.timeZone = TimeZone(secondsFromGMT: 0)!
  return calendar
}(NSCalendar(identifier: .gregorian)!)

/// A type that supplies a sequence of dates with a fixed interval.
public final class DateSeries: Sequence, IteratorProtocol {

  public enum Frequence: Int, Codable, CaseIterable, CustomStringConvertible {
    case hour = 1
    case thirtyMinutes = 2
    case fifteenMinutes = 4
    case tenMinutes = 6
    case fiveMinutes = 12
    case minute = 60

    public var fraction: Double {
      return 1 / Double(self.rawValue)
    }

    public var interval: Double {
      return 3600 * fraction
    }

    public var denominators: [Int] {
      var result = [Int]()
      for i in 2...6 {
        if rawValue % i == 0 {
          result.append(i)
        }
      }
      return result
    }

    public var description: String { "\(60 / rawValue)min" }

    public func isMultiple(of other: Frequence) -> Bool {
      other.denominators.contains(rawValue)
    }

    public static subscript(value: Int) -> Frequence {
      if 0 == 60 % value { return Frequence(rawValue: value)! }
      return Frequence(rawValue: 1)!
    }
  }

  let startDate: Date
  let endDate: Date
  let valuesPerHour: Int

  var currentDate: Date

  public init(year: Int, interval: Frequence) {
    // Check if the year is within the valid range and has the correct format
    precondition(
      year > 1950 && year < 2050,
      "year out of valid range or wrong format")

    // Create a DateComponents object to store the date information
    var dateComponents = DateComponents()
    dateComponents.timeZone = Greenwich.timeZone
    dateComponents.year = year
    dateComponents.month = 1

    // Set the start date using the Greenwich date and the provided year
    self.startDate = Greenwich.date(from: dateComponents)!
    // Set the values per hour based on the provided interval
    self.valuesPerHour = interval.rawValue
    // Set the current date to the start date
    self.currentDate = self.startDate
    // Set the end date to the start date of the next year
    dateComponents.year = year + 1
    self.endDate = Greenwich.date(from: dateComponents)!
  }

  public init(range: DateInterval, interval: Frequence) {
    self.startDate = range.start
    self.valuesPerHour = interval.rawValue
    self.currentDate = self.startDate
    self.endDate = range.end
  }

  /// Returns date until the end date is reached; otherwise nil
  public func next() -> Date? {

    let interval = 1.hours / TimeInterval(valuesPerHour)

    defer { currentDate += interval }

    if endDate.timeIntervalSince(currentDate) <= 0 { return nil }

    return currentDate
  }
}

// An extension on `DateInterval` to provide convenient initializers for intervals corresponding to different time periods.
extension DateInterval {
  /// Create a `DateInterval` representing the whole year for the given year.
  public init(ofYear: Int) {
    // Create `DateComponents` with the first day of the year.
    var dateComponents = DateComponents()
    dateComponents.timeZone = Greenwich.timeZone
    dateComponents.day = 1
    dateComponents.month = 1
    dateComponents.year = ofYear
    // Calculate the start date of the year.
    let start = Greenwich.date(from: dateComponents)!
    // Increment the year and calculate the end date (last day) of the year.
    dateComponents.year! += 1
    let end = Greenwich.date(from: dateComponents)! - 1
    self = .init(start: start, end: end)
  }

  /// Create a `DateInterval` representing the whole month for the given month and year.
  public init(ofMonth month: Int, in year: Int) {
    // Create `DateComponents` with the first day of the given month and year.
    var dateComponents = DateComponents()
    dateComponents.timeZone = Greenwich.timeZone
    dateComponents.day = 1
    dateComponents.month = month
    dateComponents.year = year
    // Calculate the start date of the month.
    let start = Greenwich.date(from: dateComponents)!
    // Increment the month and calculate the end date (last day) of the month.
    dateComponents.month! += 1
    let end = Greenwich.date(from: dateComponents)! - 1
    self = .init(start: start, end: end)
  }

  /// Create a `DateInterval` representing the whole week for the given week and year.
  public init(ofWeek week: Int, in year: Int) {
    // Create `DateComponents` and set the week of the year.
    var dateComponents = DateComponents()
    dateComponents.timeZone = Greenwich.timeZone
    if week > 1 {
      dateComponents.weekOfYear = week
    }
    dateComponents.year = year
    dateComponents.weekday = 2 // Monday

    // Calculate the start date of the week.
    let start = Greenwich.date(from: dateComponents)!

    // Increment the week and calculate the end date (last day) of the week.
    if week < 53 {
      dateComponents.weekOfYear = week + 1
    } else {
      dateComponents.year = year + 1
      dateComponents.weekday = nil
    }
    let end = Greenwich.date(from: dateComponents)! - 1
    self = .init(start: start, end: end)
  }

  /// Create a `DateInterval` representing a specific day for the given day and year.
  public init(ofDay day: Int, in year: Int) {
    // Create `DateComponents` with the given day and year.
    var dateComponents = DateComponents()
    dateComponents.timeZone = Greenwich.timeZone
    dateComponents.day = day
    dateComponents.year = year
    // Calculate the start date of the day.
    let start = Greenwich.date(from: dateComponents)!
    // Increment the day and calculate the end date (last second of the day).
    dateComponents.day! += 1
    let end = Greenwich.date(from: dateComponents)! - 1
    self = .init(start: start, end: end)
  }
}

// An extension on `Date` to provide convenient initializers for specific months and days of the year.
extension Date {
  /// Create a `Date` object representing the first day of the given month and year.
  public init(ofMonth month: Int, in year: Int) {
    // Create `DateComponents` with the first day of the given month and year.
    var dateComponents = DateComponents()
    dateComponents.timeZone = Greenwich.timeZone
    dateComponents.day = 1
    dateComponents.month = month
    dateComponents.year = year
    self = Greenwich.date(from: dateComponents)!
  }

  /// Create a `Date` object representing the specific day and year.
  public init(ofDay day: Int, in year: Int) {
    // Create `DateComponents` with the given day and year.
    var dateComponents = DateComponents()
    dateComponents.timeZone = Greenwich.timeZone
    dateComponents.day = day
    dateComponents.year = year
    self = Greenwich.date(from: dateComponents)!
  }
}

// An extension on `TimeInterval` to provide convenient properties to convert time intervals to minutes and hours.
extension TimeInterval {
  // Convert the time interval to minutes.
  var minutes: TimeInterval { self * 60.0 }
  // Convert the time interval to hours.
  var hours: TimeInterval { self * 3600.0 }
}
