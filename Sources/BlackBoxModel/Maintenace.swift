// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import DateExtensions
import Foundation

public enum Maintenance {
  static var ranges: [DateInterval] = []

  public static func setDefaultSchedule(for year: Int) {
    let calendar = Calendar(identifier: .gregorian)
    let components = DateComponents(
      calendar: calendar, year: year, month: 1, day: 1, hour: 0, minute: 0
    )
    let start = components.date!
    // let end = calendar.date(byAdding: .day, value: 5, to: start)!
    ranges = [DateInterval(start: start, end: start + 1)]
  }
  /// Is used to check if a given date falls within any of the maintenance schedules.
  @discardableResult
  static func checkSchedule(_ date: Date) -> Bool {
    return ranges.reduce(false) { $0 || $1.contains(date) }
  }
}
