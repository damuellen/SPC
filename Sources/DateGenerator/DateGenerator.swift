import Foundation

public let calendar = { calendar -> NSCalendar in
  calendar.timeZone = TimeZone(secondsFromGMT: 0)!
  return calendar
}(NSCalendar(identifier: .gregorian)!)

/// A type that supplies a sequence of dates with a fixed interval.
public final class DateGenerator: Sequence, IteratorProtocol {

  public enum Interval: Int, CaseIterable, CustomStringConvertible {
    case hourly = 1
    case thirtyMinutes = 2
    case fifteenMinutes = 4
    case teenMinutes = 6
    case fiveMinutes = 12

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

    public func isMultiple(of other: Interval) -> Bool {
      other.denominators.contains(rawValue)
    }

    public static subscript(value: Int) -> Interval {
      if 0 == 60 % value {
        return Interval(rawValue: value)!
      }
      return Interval(rawValue: 1)!
    }
  }

  let startDate: Date
  let endDate: Date
  let valuesPerHour: Int

  var currentDate: Date

  public init(year: Int, interval: Interval) {

    precondition(
      year > 1950 && year < 2050,
      "year out of valid range or wrong format")

    var dateComponents = DateComponents()
    dateComponents.timeZone = calendar.timeZone
    dateComponents.year = year
    dateComponents.month = 1

    self.startDate = calendar.date(from: dateComponents)!
    self.valuesPerHour = interval.rawValue
    self.currentDate = self.startDate
    dateComponents.year = year + 1
    self.endDate = calendar.date(from: dateComponents)! - 1
  }

  public init(range: DateInterval, interval: Interval) {
    self.startDate = range.start
    self.valuesPerHour = interval.rawValue
    self.currentDate = self.startDate
    self.endDate = range.end
  }

  /// Returns date until the end date is reached; otherwise nil
  public func next() -> Date? {

    let interval = 1.hours / TimeInterval(valuesPerHour)

    defer { currentDate += interval }

    if currentDate.timeIntervalSince(endDate) > 0 { return nil }

    return currentDate
  }
}

extension DateInterval {
  public init(ofMonth month: Int, in year: Int) {
    var dateComponents = DateComponents()
    dateComponents.timeZone = calendar.timeZone
    dateComponents.day = 1
    dateComponents.month = month
    dateComponents.year = year
    let start = calendar.date(from: dateComponents)!
    dateComponents.month! += 1
    let end = calendar.date(from: dateComponents)! - 1
    self = .init(start: start, end: end)
  }

  public init(ofWeek week: Int, in year: Int) {
    var dateComponents = DateComponents()
    dateComponents.timeZone = calendar.timeZone

    if week > 1 {
      dateComponents.weekOfYear = week
    }

    dateComponents.year = year
    dateComponents.weekday = 2
    let start = calendar.date(from: dateComponents)!

    if week < 53 {
      dateComponents.weekOfYear = week + 1
    } else {
      dateComponents.year = year + 1
      dateComponents.weekday = nil
    }

    let end = calendar.date(from: dateComponents)! - 1
    self = .init(start: start, end: end)
  }

  public init(ofDay day: Int, in year: Int) {
    var dateComponents = DateComponents()
    dateComponents.timeZone = calendar.timeZone
    dateComponents.day = day
    dateComponents.year = year
    let start = calendar.date(from: dateComponents)!
    dateComponents.day! += 1
    let end = calendar.date(from: dateComponents)! - 1
    self = .init(start: start, end: end)
  }
}


extension Date {
  public init(ofMonth month: Int, in year: Int) {
    var dateComponents = DateComponents()
    dateComponents.timeZone = calendar.timeZone
    dateComponents.day = 1
    dateComponents.month = month
    dateComponents.year = year
    self = calendar.date(from: dateComponents)!
  }

  public init(ofDay day: Int, in year: Int) {
    var dateComponents = DateComponents()
    dateComponents.timeZone = calendar.timeZone
    dateComponents.day = day
    dateComponents.year = year
    self = calendar.date(from: dateComponents)!
  }
}

extension TimeInterval {
  var minutes: TimeInterval { self * 60.0 }
  var hours: TimeInterval { self * 3600.0 }
}
