// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import Foundation

/// A calendar instance representing Greenwich Mean Time (GMT).
public let Greenwich = { calendar -> NSCalendar in
  calendar.timeZone = TimeZone(secondsFromGMT: 0)!
  return calendar
}(NSCalendar(identifier: .gregorian)!)

/// A type that supplies a sequence of dates with a fixed interval.
/// The `DateSeries` class provides a way to generate a sequence of dates with a fixed time interval between each date.
/// It can be used to create a sequence of dates for a specific year or within a given date range, with various interval frequencies
/// such as hourly, half-hourly, fifteen minutes, ten minutes, five minutes, or minute intervals.
///
/// Example usage:
/// ```swift
/// // Create a DateSeries for the year 2023 with hourly intervals
/// let dateSeries = DateSeries(year: 2023, interval: .hour)
///
/// // Generate dates for the entire year with hourly intervals
/// for date in dateSeries {
///     print(date)
/// }
/// ```
public final class DateSeries: Sequence, IteratorProtocol {
  /// An enumeration representing different frequencies (intervals) for date series.
  public enum Frequence: Int, Codable, CaseIterable, CustomStringConvertible {
    case hour = 1
    case thirtyMinutes = 2
    case fifteenMinutes = 4
    case tenMinutes = 6
    case fiveMinutes = 12
    case minute = 60

    /// The fractional value of the frequency.
    public var fraction: Double { 1 / Double(self.rawValue) }

    /// The time interval for the frequency in seconds.
    public var interval: Double { 3600 * fraction }

    /// The denominators for the frequency, representing the multiples of the frequency.
    public var denominators: [Int] {
      var result = [Int]()
      for i in 2...6 { if rawValue % i == 0 { result.append(i) } }
      return result
    }

    /// A textual representation of the frequency, indicating the minutes value (e.g., "30min").
    public var description: String { "\(60 / rawValue)min" }

    /// Checks if the current frequency is a multiple of another frequency.
    /// - Parameter other: The other frequency to compare with.
    /// - Returns: A boolean value indicating if the current frequency is a multiple of the other frequency.
    public func isMultiple(of other: Frequence) -> Bool {
      other.denominators.contains(rawValue)
    }

    /// Subscript to access a frequency by its rawValue (integer value).
    /// - Parameter value: The rawValue of the desired frequency.
    /// - Returns: The frequency corresponding to the provided rawValue.
    public static subscript(value: Int) -> Frequence {
      if 0 == 60 % value { return Frequence(rawValue: value)! }
      return Frequence(rawValue: 1)!
    }
  }

  let startDate: Date
  let endDate: Date
  let valuesPerHour: Int
  var currentDate: Date

  /// Initializes a DateSeries instance with a specific year and interval frequency.
  /// - Parameters:
  ///   - year: The year for which the date series is generated.
  ///   - interval: The interval (frequency) for the date series.
  public init(year: Int, interval: Frequence) {
    precondition(
      year > 1950 && year < 2050, "Year out of valid range or wrong format")

    var dateComponents = DateComponents()
    dateComponents.timeZone = Greenwich.timeZone
    dateComponents.year = year
    dateComponents.month = 1
    self.startDate = Greenwich.date(from: dateComponents)!
    self.valuesPerHour = interval.rawValue
    self.currentDate = self.startDate
    dateComponents.year = year + 1
    self.endDate = Greenwich.date(from: dateComponents)!
  }

  /// Initializes a DateSeries instance within the specified date range and interval frequency.
  /// - Parameters:
  ///   - range: The date interval representing the range of the date series.
  ///   - interval: The interval (frequency) for the date series.
  public init(range: DateInterval, interval: Frequence) {
    self.startDate = range.start
    self.valuesPerHour = interval.rawValue
    self.currentDate = self.startDate
    self.endDate = range.end
  }

  /// Returns the next date in the sequence until the end date is reached; otherwise, returns nil.
  public func next() -> Date? {
    let interval = 1.hours / TimeInterval(valuesPerHour)
    defer { currentDate += interval }
    return endDate.timeIntervalSince(currentDate) <= 0 ? nil : currentDate
  }
}

extension DateInterval {
  /// Creates a `DateInterval` representing the whole year for the given year.
  /// - Parameter ofYear: The year for which the `DateInterval` is created.
  public init(ofYear: Int) {
    var dateComponents = DateComponents()
    dateComponents.timeZone = Greenwich.timeZone
    dateComponents.day = 1
    dateComponents.month = 1
    dateComponents.year = ofYear
    let start = Greenwich.date(from: dateComponents)!
    dateComponents.year! += 1
    let end = Greenwich.date(from: dateComponents)! - 1
    self = .init(start: start, end: end)
  }

  /// Creates a `DateInterval` representing the whole month for the given month and year.
  /// - Parameters:
  ///   - ofMonth: The month for which the `DateInterval` is created.
  ///   - in: The year for which the `DateInterval` is created.
  public init(ofMonth month: Int, in year: Int) {
    var dateComponents = DateComponents()
    dateComponents.timeZone = Greenwich.timeZone
    dateComponents.day = 1
    dateComponents.month = month
    dateComponents.year = year
    let start = Greenwich.date(from: dateComponents)!
    dateComponents.month! += 1
    let end = Greenwich.date(from: dateComponents)! - 1
    self = .init(start: start, end: end)
  }

  /// Creates a `DateInterval` representing the whole week for the given week and year.
  /// - Parameters:
  ///   - ofWeek: The week for which the `DateInterval` is created.
  ///   - in: The year for which the `DateInterval` is created.
  public init(ofWeek week: Int, in year: Int) {
    var dateComponents = DateComponents()
    dateComponents.timeZone = Greenwich.timeZone
    if week > 1 { dateComponents.weekOfYear = week }
    dateComponents.year = year
    dateComponents.weekday = 2  // Monday
    let start = Greenwich.date(from: dateComponents)!
    if week < 53 {
      dateComponents.weekOfYear = week + 1
    } else {
      dateComponents.year = year + 1
      dateComponents.weekday = nil
    }
    let end = Greenwich.date(from: dateComponents)! - 1
    self = .init(start: start, end: end)
  }

  /// Creates a `DateInterval` representing a specific day for the given day and year.
  /// - Parameters:
  ///   - ofDay: The day for which the `DateInterval` is created.
  ///   - in: The year for which the `DateInterval` is created.
  public init(ofDay day: Int, in year: Int) {
    var dateComponents = DateComponents()
    dateComponents.timeZone = Greenwich.timeZone
    dateComponents.day = day
    dateComponents.year = year
    let start = Greenwich.date(from: dateComponents)!
    dateComponents.day! += 1
    let end = Greenwich.date(from: dateComponents)! - 1
    self = .init(start: start, end: end)
  }
}

extension Date {
  /// Creates a `Date` object representing the first day of the given month and year.
  /// - Parameters:
  ///   - ofMonth: The month for which the `Date` object is created.
  ///   - in: The year for which the `Date` object is created.
  public init(ofMonth month: Int, in year: Int) {
    var dateComponents = DateComponents()
    dateComponents.timeZone = Greenwich.timeZone
    dateComponents.day = 1
    dateComponents.month = month
    dateComponents.year = year
    self = Greenwich.date(from: dateComponents)!
  }

  /// Creates a `Date` object representing the specific day and year.
  /// - Parameters:
  ///   - ofDay: The day for which the `Date` object is created.
  ///   - in: The year for which the `Date` object is created.
  public init(ofDay day: Int, in year: Int) {
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
