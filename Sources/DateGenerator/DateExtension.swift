import Foundation

public typealias FractionalTime = Double

extension Date {

  public func getComponents() -> DateComponents {
    calendar.components([.day, .month, .year, .weekday, .hour, .minute, .second], from: self)
  }

  public func set(time fractionalTime: FractionalTime) -> Date? {
    let min = 60 * (fractionalTime - Double(Int(fractionalTime)))
    let sec = 60 * (min - Double(Int(min)))
    var components = self.getComponents()
    components.hour = Int(fractionalTime)
    components.minute = Int(min)
    components.second = Int(sec)
    return calendar.date(from: components)
  }
}

extension DateInterval {

  public func align(with valuesPerHour: DateGenerator.Interval) -> DateInterval {
    var start = self.start.getComponents()
    var end = self.end.getComponents()

    start.second = 0
    end.second = 0

    let interval = 60.0 / Double(valuesPerHour.rawValue)
    start.minute = (Int(Double(start.minute!) / interval)) * Int(interval)
    end.minute = (Int(Double(end.minute!) / interval)) * Int(interval)

    return DateInterval(start: calendar.date(from: start)!, end: calendar.date(from: end)!)
  }
}
