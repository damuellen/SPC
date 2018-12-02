//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation

public struct Maintenance: Codable {
  static var ranges: [DateInterval] = []

  static func setDefaultSchedule(for year: Int) {
    let components = DateComponents(
      calendar: calendar, year: year, month: 1, day: 1, hour: 0, minute: 0
    )
    let start = calendar.date(from: components)!
    let end = calendar.date(byAdding: .day, value: 7, to: start)!
    ranges.append(DateInterval(start: start, end: end))
  }

  @discardableResult
  static func checkSchedule(_ date: Date) -> Bool {
    var inMaintenance = false
    for range in self.ranges {
      if range.contains(date) {
        inMaintenance = true
        break
      }
    }
    return inMaintenance
  }
}
