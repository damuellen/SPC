//
//  Copyright (c) 2017 Daniel Müllenborn. All rights reserved.
//  Distributed under the The Non-Profit Open Software License version 3.0
//  http://opensource.org/licenses/NPOSL-3.0
//
//  This project is NOT free software. It is open source, you are allowed to
//  modify it (if you keep the license), but it may not be commercially
//  distributed other than under the conditions noted above.
//

import Foundation
import Config
import DateGenerator

public struct Time {
  var isLeapYear = false
  var firstDateOfOperation: Date? = nil
  var lastDateOfOperation: Date? = nil
  let holidays: [Date]
  let steps: DateGenerator.Interval
}

extension Time: TextConfigInitializable {
  
  public init(file: TextConfigFile)throws {
    
    let row: (Int)throws -> Double = { try file.parseDouble(row: $0) }
    
    let getDate: (String) -> Date? = { dateString in
      let components: [Int] = dateString.split(
        separator: ".", maxSplits: 2, omittingEmptySubsequences: true)
        .map(String.init).flatMap(Int.init)
      guard components.count == 2 else { return nil }
      let dateComponents = DateComponents(
        year: 2010, month: components[0], day: components[1])
      guard let date = calendar.date(from: dateComponents)
        else { return nil }
      return date
    }
    
    if let firstDayOfOperation = getDate(file.values[12]) {
      let hours = try row(14) * 3600
      let minutes = try row(15) * 60
      let timeInterval = hours + minutes
      let date = firstDayOfOperation.addingTimeInterval(timeInterval)
      self.firstDateOfOperation = date
    }
    
    if let lastDayOfOperation = getDate(file.values[15]) {
      let hours = try row(17) * 3600
      let minutes = try row(18) * 60
      let timeInterval = hours + minutes
      let date = lastDayOfOperation.addingTimeInterval(timeInterval)
      self.lastDateOfOperation = date
    }
    
    self.steps = try DateGenerator.Interval(
      rawValue: Int(row(12))) ?? .every5minutes
    
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
    self.firstDateOfOperation = try values.decodeIfPresent(
      Date.self, forKey: .firstDateOfOperation)
    self.lastDateOfOperation = try values.decodeIfPresent(
      Date.self, forKey: .lastDateOfOperation)
    self.holidays = try values.decode(Array<Date>.self, forKey: .holidays)
    let steps = try values.decode(Int.self, forKey: .steps)
    self.steps = DateGenerator.Interval(rawValue: steps)!
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(
      firstDateOfOperation, forKey: .firstDateOfOperation)
    try container.encodeIfPresent(
      lastDateOfOperation, forKey: .lastDateOfOperation)
    try container.encode(holidays, forKey: .holidays)
    try container.encode(steps.rawValue, forKey: .steps)
  }
}
