import Foundation

let calendar = { calendar -> NSCalendar in
  calendar.timeZone = TimeZone(secondsFromGMT: 0)!
  return calendar
}(NSCalendar(identifier: .gregorian)!)

public final class DateGenerator: Sequence, IteratorProtocol {
  
  public enum Interval: Int {
    case hourly = 1
    case half_hourly = 2
    case everyThirdHour = 3
    case quarter_hourly = 4
    case every12minutes = 5
    case every10minutes = 6
    case every6minutes = 10
    case every5minutes = 12
    case every3minutes = 20
    case every2minutes = 30
    case everyMinute = 60

    public var fraction: Double {
      return 1 / Double(self.rawValue)
    }

    public var interval: Double {
      return 3600 * fraction
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

    precondition(year > 1950 && year < 2050,
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

    let interval = 1.hours / TimeInterval (valuesPerHour)

    defer { currentDate += interval }

    if currentDate.timeIntervalSince (endDate) > 0 { return nil }

    return currentDate
  }
  
  public static func getMonth(_ month: Int, year: Int) -> DateInterval {
    var dateComponents = DateComponents()
    dateComponents.timeZone = calendar.timeZone
    dateComponents.day = 1
    dateComponents.month = month
    dateComponents.year = year
    let first = calendar.date(from: dateComponents)!
    dateComponents = DateComponents()
    dateComponents.timeZone = calendar.timeZone
    dateComponents.day = 1
    dateComponents.month = month + 1
    dateComponents.year = year
    let last = calendar.date(from: dateComponents)!
    return DateInterval(start: first, end: last)
  }

  public static func getWeek(_ week: Int, year: Int) -> DateInterval {
    var dateComponents = DateComponents()
    dateComponents.timeZone = calendar.timeZone
    dateComponents.weekOfYear = week
    dateComponents.year = year
    let first = calendar.date(from: dateComponents)!
    dateComponents.weekOfYear = week + 1
    let last = calendar.date(from: dateComponents)!
    return DateInterval(start: first, end: last)
  }

  public static func getDay(_ day: Int, year: Int) -> DateInterval {
    var dateComponents = DateComponents()
    dateComponents.timeZone = calendar.timeZone
    dateComponents.day = day
    dateComponents.year = year
    let first = calendar.date(from: dateComponents)!
    dateComponents.day = day + 1
    let last = calendar.date(from: dateComponents)!
    return DateInterval(start: first, end: last)
  }
}

extension TimeInterval {

  var minutes: TimeInterval {
    return self * 60.0
  }

  var hours: TimeInterval {
    return self * 3600.0
  }
}
