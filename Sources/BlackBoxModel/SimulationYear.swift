//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import DateExtensions
import Foundation

public typealias Frequence = DateSeries.Frequence

extension Simulation {
  public struct Period: Codable, CustomStringConvertible {
    var isLeapYear = false
    /// Simulated date interval
    public var dateInterval: DateInterval?
    public let holidays: [DateInterval]
    public var steps: Frequence

    public var description: String {
      """
      Weekday of 1st January:                         Fr
      Number of Days in February:                      28 
      First Day of Operation:               \(dateInterval!.start)
      Last Day of Operation:                \(dateInterval!.end)
      Time Step for Report (H/D/M/Y) :                 H
      If hourly based; number of steps for detailed Report (TC) :
                                                        12 
      First Day of Daylight Saving time [MM.DD] :       0 
      Last Day of Daylight Saving time [MM.DD] :        1.01 
      Holidays [MM.DD] : \(holidays.map(\.start).map(DateTime.init(_:)).map(\.date).joined(separator: " "))

      """
    }
  }
}

extension Simulation.Period: TextConfigInitializable {
  public init(file: TextConfigFile) throws {
    let ln: (Int) throws -> Double = { try file.readDouble(lineNumber: $0) }

    let getDate: (String) -> Date? = { dateString in
      let dateFormatter = DateFormatter()
      dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
      dateFormatter.dateFormat = "MM.dd yyyy"
      return dateFormatter.date(from: dateString + "\(BlackBoxModel.simulatedYear)"
      )
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
    self.holidays = dates.map{ DateInterval(start: $0, duration: 86_400) }
  }
}

