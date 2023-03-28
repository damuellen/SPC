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

  public func aligned(to valuesPerHour: DateSeries.Frequence) -> DateInterval {
    var start = self.start.getComponents()
    var end = self.end.getComponents()

    start.second = 0
    end.second = 0

    let interval = 60.0 / Double(valuesPerHour.rawValue)
    start.minute = (Int(Double(start.minute!) / interval)) * Int(interval)
    end.minute = Int((Double(end.minute!) / interval).rounded(.up)) * Int(interval)

    return DateInterval(start: Greenwich.date(from: start)!, end: Greenwich.date(from: end)!)
  }
}
