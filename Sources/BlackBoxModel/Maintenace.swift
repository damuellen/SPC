// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import DateExtensions
import Foundation

/// A public enum representing maintenance schedules for a solar power plant.
public enum Maintenance {

  /// An array of date intervals representing maintenance ranges.
  static var ranges: [DateInterval] = []

  /// Sets the default maintenance schedule for a given year.
  ///
  /// - Parameter year: The year for which to set the maintenance schedule.
  public static func setDefaultSchedule(for year: Int) {
    let calendar = Calendar(identifier: .gregorian)
    let components = DateComponents(
      calendar: calendar, year: year, month: 1, day: 1, hour: 0, minute: 0
    )
    let start = components.date!
    // let end = calendar.date(byAdding: .day, value: 5, to: start)!
    ranges = [DateInterval(start: start, end: start + 1)]
  }

  /// Checks if a given date falls within any of the maintenance schedules.
  ///
  /// - Parameter date: The date to check for maintenance.
  /// - Returns: A boolean value indicating if maintenance is scheduled for the given date.
  @discardableResult
  static func checkSchedule(_ date: Date) -> Bool {
    return ranges.reduce(false) { $0 || $1.contains(date) }
  }
}

