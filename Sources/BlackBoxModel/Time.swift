//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Config
import DateGenerator
import Foundation

public typealias Interval = DateGenerator.Interval

public struct Time {
  var isLeapYear = false
  public var firstDateOfOperation: Date?
  public var lastDateOfOperation: Date?
  let holidays: [Date]
  public var steps: Interval
}

extension Time: TextConfigInitializable {
  public init(file: TextConfigFile) throws {
    let ln: (Int) throws -> Double = { try file.double(line: $0) }

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
      try DateGenerator.Interval(
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

extension Time: Codable {
  enum CodingKeys: String, CodingKey {
    case firstDateOfOperation
    case lastDateOfOperation
    case holidays
    case steps
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    firstDateOfOperation = try values.decodeIfPresent(
      Date.self, forKey: .firstDateOfOperation
    )
    lastDateOfOperation = try values.decodeIfPresent(
      Date.self, forKey: .lastDateOfOperation
    )
    holidays = try values.decode(Array<Date>.self, forKey: .holidays)
    let steps = try values.decode(Int.self, forKey: .steps)
    self.steps = DateGenerator.Interval(rawValue: steps)!
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(
      firstDateOfOperation, forKey: .firstDateOfOperation
    )
    try container.encodeIfPresent(
      lastDateOfOperation, forKey: .lastDateOfOperation
    )
    try container.encode(holidays, forKey: .holidays)
    try container.encode(steps.rawValue, forKey: .steps)
  }
}
