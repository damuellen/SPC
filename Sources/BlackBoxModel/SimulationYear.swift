// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import DateExtensions
import Foundation

/// Represents a frequency for simulation steps.
public typealias Frequence = DateSeries.Frequence

extension Simulation {
  /// Represents a simulation period.
  struct Period: Codable, CustomStringConvertible {
    /// Flag indicating whether the simulation year is a leap year.
    var isLeapYear = false
    /// Simulated date interval.
    var dateInterval: DateInterval?
    /// Holidays during the simulation period.
    let holidays: [DateInterval]
    /// Frequency of simulation steps.
    var steps: Frequence

    /// A textual representation of the simulation period.
    public var description: String {
      let dateFormatter = DateFormatter()
      dateFormatter.timeZone = Greenwich.timeZone
      dateFormatter.dateFormat = "EEEE"
      let weekday = dateFormatter.string(from: dateInterval!.start)
      dateFormatter.dateFormat = "MM-dd"
      let first = dateFormatter.string(from: dateInterval!.start)
      let last = dateFormatter.string(from: dateInterval!.end)

      return """
      Weekday of 1st January:                           \(weekday)
      Number of Days in February:                       28
      First Day of Operation [MM-DD]:                   \(first)
      Last Day of Operation [MM-DD]:                    \(last)
      Time Step for Report (H/D/M/Y) :                  \(steps.rawValue)
      If hourly based; number of steps for detailed Report (TC) :
                                                      12
      First Day of Daylight Saving time [MM.DD] :       0
      Last Day of Daylight Saving time [MM.DD] :        1.01
      Holidays [MM-DD]:
      \(holidays.map(\.start).map(DateTime.init(_:)).map(\.calendarDay).joined(separator: ", "))
      """
    }
  }
}

extension Simulation.Period: TextConfigInitializable {
  /// Initializes a Simulation.Period instance from a TextConfigFile.
  /// - Parameter file: The TextConfigFile to read the data from.
  init(file: TextConfigFile) throws {
    let ln: (Int) throws -> Double = { try file.readDouble(lineNumber: $0) }

    let getDate: (String) -> Date? = { dateString in
      let dateFormatter = DateFormatter()
      dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
      dateFormatter.dateFormat = "MM.dd yyyy"
      return dateFormatter.date(from: dateString + " \(BlackBoxModel.simulatedYear)")
    }

    if let firstDayOfOperation = getDate(file.lines[12]),
      let lastDayOfOperation = getDate(file.lines[15]) {
      let hoursFirst = try ln(14) * 3600
      let minutesFirst = try ln(15) * 60
      let timeIntervalFirst = hoursFirst + minutesFirst
      let firstDateOfOperation = firstDayOfOperation.addingTimeInterval(timeIntervalFirst)

      let hoursLast = try ln(17) * 3600
      let minutesLast = try ln(18) * 60
      let timeIntervalLast = hoursLast + minutesLast
      let lastDateOfOperation = lastDayOfOperation.addingTimeInterval(timeIntervalLast)

      self.dateInterval = DateInterval(start: firstDateOfOperation, end: lastDateOfOperation)
    }

    self.steps = try .init(rawValue: Int(ln(22))) ?? .fiveMinutes

    var dates = [Date]()
    for row in stride(from: 38, through: 95, by: 3) {
      let idx = row - 1
      let dateString = file.lines[idx]
      guard let date = getDate(dateString) else { continue }
      dates.append(date)
    }

    self.holidays = dates.map { DateInterval(start: $0, duration: 86_400) }
  }
}
