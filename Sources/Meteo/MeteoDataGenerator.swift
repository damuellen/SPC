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
import DateGenerator

let calendar = { calendar -> NSCalendar in
  calendar.timeZone = TimeZone(secondsFromGMT: 0)!
  return calendar
}(NSCalendar(identifier: .gregorian)!)

public class MeteoDataGenerator: IteratorProtocol, Sequence {
  private(set) var steps: DateGenerator.Interval

  private let source: MeteoDataSource

  public init(from source: MeteoDataSource, interval: DateGenerator.Interval) {
    self.source = source
    self.steps = interval
    self.lastIndex = source.data.endIndex
  }
  
  public func setRange(to dateInterval: DateInterval) {
    let dateInterval = dateInterval.align(with: steps)
    let startDate = dateInterval.start
    let endDate = dateInterval.end
    
    let startHour = calendar.ordinality(of: .hour, in: .year, for: startDate)
    self.idx = startHour - 1
    
    let startMinute = calendar.ordinality(of: .minute, in: .hour, for: startDate)
    self.step = startMinute / (60 / steps.rawValue)
    
    let endHour = calendar.ordinality(of: .hour, in: .year, for: endDate)
    self.lastIndex = endHour - 1
    
    let endMinute = calendar.ordinality(of: .minute, in: .hour, for: endDate)
    self.lastStep = endMinute / (60 / steps.rawValue)
  }
  
  private var lastIndex: Int
  private var idx = 0
  private var step = 0
  private var lastStep = 0
  
  public func next() -> MeteoData? {
    defer { step += 1 }
    // At the start, where it has not yet been interpolated.
    if step == 0 { return source.data[idx] }
    // Move index to the next hourly value.
    if step > steps.rawValue { step = 1; idx += 1 }
    // Necessary for the interpolation of values.
    let lerp = Float(step) * (1 / Float(steps.rawValue))
    // Check whether the end of the range has already been reached.
    if idx == lastIndex && step > lastStep { return nil }
    
    if idx < source.data.endIndex - 1 {
      return MeteoData.interpolate(from: source.data[idx],
                                   to: source.data[idx + 1], with: lerp)
    } else if idx == source.data.endIndex - 1 {
      // At the end, the first value is reused for interpolation.
      return MeteoData.interpolate(from: source.data[idx],
                                   to: source.data[0], with: lerp)
    } else {
      return nil
    }
  }
}
