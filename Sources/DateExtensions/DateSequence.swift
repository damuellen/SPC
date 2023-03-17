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

    precondition(
      year > 1950 && year < 2050,
      "year out of valid range or wrong format")

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

extension DateInterval {
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

  public init(ofWeek week: Int, in year: Int) {
    var dateComponents = DateComponents()
    dateComponents.timeZone = Greenwich.timeZone

    if week > 1 {
      dateComponents.weekOfYear = week
    }

    dateComponents.year = year
    dateComponents.weekday = 2
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
  public init(ofMonth month: Int, in year: Int) {
    var dateComponents = DateComponents()
    dateComponents.timeZone = Greenwich.timeZone
    dateComponents.day = 1
    dateComponents.month = month
    dateComponents.year = year
    self = Greenwich.date(from: dateComponents)!
  }

  public init(ofDay day: Int, in year: Int) {
    var dateComponents = DateComponents()
    dateComponents.timeZone = Greenwich.timeZone
    dateComponents.day = day
    dateComponents.year = year
    self = Greenwich.date(from: dateComponents)!
  }
}

extension TimeInterval {
  var minutes: TimeInterval { self * 60.0 }
  var hours: TimeInterval { self * 3600.0 }
}
