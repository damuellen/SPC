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

public typealias Interval = DateSequence.Interval

extension Simulation {
  public struct Year: Codable, CustomStringConvertible {
    var isLeapYear = false
    public var firstDateOfOperation: Date?
    public var lastDateOfOperation: Date?
    let holidays: [Date]
    public var steps: Interval

    public var description: String {
      """
      Weekday of 1st January:                         Fr
      Number of Days in February:                      28 
      First Day of Operation:               \(firstDateOfOperation!)
      Last Day of Operation:                \(lastDateOfOperation!)
      Time Step for Report (H/D/M/Y) :                 H
      If hourly based; number of steps for detailed Report (TC) :
                                                        12 
      First Day of Daylight Saving time [MM.DD] :       0 
      Last Day of Daylight Saving time [MM.DD] :        1.01 
      Holidays [MM.DD] : \(holidays.map(DateTime.init(_:)).map(\.date).joined(separator: " "))

      """
    }
  }
}

extension Simulation.Year: TextConfigInitializable {
  public init(file: TextConfigFile) throws {
    let ln: (Int) throws -> Double = { try file.readDouble(lineNumber: $0) }

    let getDate: (String) -> Date? = { dateString in
      let dateFormatter = DateFormatter()
      dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
      dateFormatter.dateFormat = "MM.dd yyyy"
      return dateFormatter.date(from:
        dateString + "\(BlackBoxModel.yearOfSimulation)"
      )
    }

    if let firstDayOfOperation = getDate(file.values[12]) {
      let hours = try ln(14) * 3600
      let minutes = try ln(15) * 60
      let timeInterval = hours + minutes
      let date = firstDayOfOperation.addingTimeInterval(timeInterval)
      firstDateOfOperation = date
    }

    if let lastDayOfOperation = getDate(file.values[15]) {
      let hours = try ln(17) * 3600
      let minutes = try ln(18) * 60
      let timeInterval = hours + minutes
      let date = lastDayOfOperation.addingTimeInterval(timeInterval)
      lastDateOfOperation = date
    }

    self.steps =
      try DateSequence.Interval(
        rawValue: Int(ln(22))
      ) ?? .fiveMinutes

    var dates = [Date]()
    for row in stride(from: 38, through: 95, by: 3) {
      let idx = row - 1
      let dateString = file.values[idx]
      guard let date = getDate(dateString) else { continue }
      dates.append(date)
    }
    self.holidays = dates
  }
}

