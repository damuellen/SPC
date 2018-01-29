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
import DateGenerator

let calendar = { calendar -> NSCalendar in
  calendar.timeZone = TimeZone(secondsFromGMT: 0)!
  return calendar
}(NSCalendar(identifier: .gregorian)!)

public class MeteoDataGenerator: Sequence {
  private(set) var intermediateSteps: DateGenerator.Interval
  private(set) var dateInterval: DateInterval?
  private let dataSource: MeteoDataSource

  public init(from source: MeteoDataSource, interval: DateGenerator.Interval) {
    self.dataSource = source
    self.intermediateSteps = interval
    self.lastIndex = source.data.endIndex
  }
  
  public func setRange(_ dateInterval: DateInterval) {
    self.dateInterval = dateInterval.align(with: intermediateSteps)
    let startDate = self.dateInterval!.start
    let endDate = self.dateInterval!.end
    
    let startHour = calendar.ordinality(of: .hour, in: .year, for: startDate)
    self.index = startHour - 1
    
    let startMinute = calendar.ordinality(of: .minute, in: .hour, for: startDate)
    self.step = startMinute / (60 / intermediateSteps.rawValue)
    
    let endHour = calendar.ordinality(of: .hour, in: .year, for: endDate)
    self.lastIndex = endHour - 1
    
    let endMinute = calendar.ordinality(of: .minute, in: .hour, for: endDate)
    self.lastStep = endMinute / (60 / intermediateSteps.rawValue)
  }
  
  private var DNI_perDaySums: [Double] = []
  
  public func DNI_sum(of day: Int) -> Double {
    let idx = day - 1
    if DNI_perDaySums.endIndex > idx { return DNI_perDaySums[idx] }
    
    let start = (day * 24) - 24
    let end = (day * 24)
    
    var sum: Float = 0.0
    for value in dataSource.data[start..<end] {
      sum += value.dni
    }
    DNI_perDaySums.append(Double(sum))
    return Double(sum)
  }
  
  private var lastIndex: Int
  private var index = 0
  private var step = 0
  private var lastStep = 0

  public func makeIterator() -> AnyIterator<MeteoData> {
    var lastIndex = self.lastIndex
    var index = self.index
    var step = self.step
    var lastStep = self.lastStep
    return AnyIterator<MeteoData> {
      defer { step += 1 }
      let data = self.dataSource.data
      let steps = self.intermediateSteps.rawValue
      // First value, no interpolation is needed.
      if step == 0 { return data[index] }
      // When step count is reached move index to the next hourly value.
      if step > steps { step = 1; index += 1 }
      
      let progress = Float(step) * (1 / Float(steps))
      // Check whether the end of the range has already been reached.
      if index == lastIndex && step > lastStep { return nil }
      
      if index < data.endIndex - 1 {
        return MeteoData.interpolate(
          data[index], to: data[index + 1], progress: progress)
      } else if index == data.endIndex - 1 {
        // For the last hour, the start value is reused for the interpolation.
        return MeteoData.interpolate(
          data[index], to: data[0], progress: progress)
      } else {
        return nil
      }
    }
  }
}
