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

public typealias FractionalTime = Double

extension Date: ExpressibleByStringLiteral {
  public init(stringLiteral: String) {
    self.init(stringLiteral)
  }
  public init(_ dateString: String) {
    let values = dateString.split(whereSeparator: {!$0.isWholeNumber}).compactMap{Int32($0)}
    var t = time_t()
    time(&t)
    var info = localtime(&t)!.pointee
    if values.count > 2 {
      info.tm_year = values[0] - 1900
      info.tm_mon = values[1] - 1
      info.tm_mday = values[2]
    }
    if values.count > 4 {
      info.tm_hour = values[3]
      info.tm_min = values[4]
    }
    if values.count > 5 {
      info.tm_sec = values[5]
    }
    let time = mktime(&info)
    self.init(timeIntervalSince1970: TimeInterval(time))
}} 

extension Date {

  public func getComponents() -> DateComponents {
    Greenwich.components([.day, .month, .year, .weekday, .hour, .minute, .second], from: self)
  }

  public func set(time fractionalTime: FractionalTime) -> Date? {
    let min = 60 * (fractionalTime - Double(Int(fractionalTime)))
    let sec = 60 * (min - Double(Int(min)))
    var components = self.getComponents()
    components.hour = Int(fractionalTime)
    components.minute = Int(min)
    components.second = Int(sec)
    return Greenwich.date(from: components)
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

    return DateInterval(start: Greenwich.date(from: start)!, end: Greenwich.date(from: end)!)
  }
}
