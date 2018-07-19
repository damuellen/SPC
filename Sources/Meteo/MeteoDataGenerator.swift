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
  private let sunHoursPerDay: [DateInterval]

  public init(from source: MeteoDataSource, interval: DateGenerator.Interval) {
    self.dataSource = source
    self.intermediateSteps = interval
    self.range = source.data.startIndex..<source.data.endIndex
    self.sunHoursPerDay = []
  }
  
  public init(from source: MeteoDataSource, sunHoursPerDay: [DateInterval], interval: DateGenerator.Interval) {
    self.dataSource = source
    self.intermediateSteps = interval
    
    self.range = source.data.startIndex..<source.data.endIndex
    self.sunHoursPerDay = sunHoursPerDay
    let d = sunHoursPerDay.first!.start
    let x = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: d, options: [])
    self.dateInterval = DateInterval(start: x!, duration: 0)
  }
  
  public func setRange(_ dateInterval: DateInterval) {
    self.dateInterval = dateInterval.align(with: intermediateSteps)
    let startDate = self.dateInterval!.start
    let endDate = self.dateInterval!.end
    
    let startHour = calendar.ordinality(of: .hour, in: .year, for: startDate)
    let startIndex = startHour - 1
    
    let startMinute = calendar.ordinality(of: .minute, in: .hour, for: startDate)
    self.step = startMinute / (60 / intermediateSteps.rawValue)
    
    let endHour = calendar.ordinality(of: .hour, in: .year, for: endDate)
    let lastIndex = endHour - 1
    self.range = startIndex..<lastIndex
    let endMinute = calendar.ordinality(of: .minute, in: .hour, for: endDate)
    self.lastStep = endMinute / (60 / intermediateSteps.rawValue)
  }
  
  private var perDaySumsDNI: [Double] = []
  
  public func sumDNI(ofDay day: Int) -> Double {
    let idx = day - 1
    if perDaySumsDNI.endIndex > idx { return perDaySumsDNI[idx] }
    
    let start = (day * 24) - 24
    let end = (day * 24)
    
    var sum: Float = 0.0
    for value in dataSource.data[start..<end] {
      sum += value.dni //* Float(dataSource.interval)
    }
    perDaySumsDNI.append(Double(sum))
    return Double(sum)
  }
  
  private var range: Range<Int>

  private var step = 0
  private var lastStep = 0

  public func makeIterator() -> AnyIterator<MeteoData> {
    let data = self.dataSource.data
    let lastIndex = self.range.endIndex
    let lastStep = self.lastStep
    let sunHoursPerDay = self.sunHoursPerDay
    let steps = self.dataSource.interval < 1
      ? Int(self.dataSource.interval / intermediateSteps.fraction)
      : intermediateSteps.rawValue
    
    let stride = (1 / Float(steps))
    
    var step = 1
    var index = self.range.startIndex
    //var date = self.dateInterval?.start ?? Date()
    let period = self.intermediateSteps.fraction * 3600
    

    var dict = [Int:(Int,Float)]()
    sunHoursPerDay.forEach { day in
      let startIndex = calendar.ordinality(of: .hour, in: .year, for: day.start) - 1
      let startStep = calendar.ordinality(of: .second, in: .hour, for: day.start) / Int(period)
      let startFraction = 1 / (startStep < steps ? (Float(steps) - Float(startStep)) / Float(steps) : 1)
      dict[startIndex] = (startStep, startFraction)
      let endIndex = calendar.ordinality(of: .hour, in: .year, for: day.end) - 1
      let endStep = calendar.ordinality(of: .second, in: .hour, for: day.end) / Int(period)
      let endFraction = endStep > 1 ? 1 / Float(endStep) / Float(steps) : 1
      dict[endIndex] = (endStep, endFraction)
    }

    return AnyIterator<MeteoData> {
      defer { step += 1 }
      // When step count is reached move index to the next hourly value.
      if step > steps { step = 1; index += 1 }
      // Check whether the end of the range has already been reached.
      if index == lastIndex && step > lastStep { return nil }
      
      if steps == 1 { return data[index] }
      
      let prev = index > 0 ? data[index - 1] : data[data.endIndex - 1]
      let current = data[index]
      // For the last hour, the start value is reused for the interpolation.
      let next = index < data.endIndex - 1 ? data[index + 1] : data[0]
      // let day = calendar.ordinality(of: .day, in: .year, for: date) - 1

      let start = MeteoData.lerp(start: prev, end: current, 0.5)
      let end = MeteoData.lerp(start: current, end: next, 0.5)
      let meteoData = MeteoData.lerp(start: start, end: end, Float(step - 1) * stride)
     // let meteoData = MeteoData.interpolation(prev: prev, current: current, next: next, progess: Float(step) * stride)

      return meteoData
    }
  }
}
