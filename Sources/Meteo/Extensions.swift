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

extension Array where Element == MeteoData {
  /// Interpolation function for meteo data
  internal func interpolate(steps: Int) -> [MeteoData] {
    if self.count < 2 { return self }
    let (temperature, dni, ghi, dhi, windSpeed) = (
      self.map(\.temperature).interpolate(steps: steps),
      self.map(\.dni).interpolate(steps: steps),
      self.map(\.ghi).interpolate(steps: steps),
      self.map(\.dhi).interpolate(steps: steps),
      self.map(\.windSpeed).interpolate(steps: steps))
    return dni.indices.map { i -> MeteoData in
      MeteoData(dni: dni[i], ghi: ghi[i], dhi: dhi[i],
        temperature: temperature[i], windSpeed: windSpeed[i])
    }
  }

  public func analyse(day: Array.Indices) -> MeteoData.Statistics {
    var isPeak = false
    var peaks = 0
    var hours = 0.0
    var sum = 0.0
    var max = 0.0
    let hourFraction = Double(self.count) / 8760
    for i in day.indices.dropFirst() {
      let prev = self[i - 1].dni
      let curr = self[i].dni
      if curr > max { max = curr }
      if curr > 0 {
        hours += hourFraction
        sum += curr * hourFraction
      }
      if isPeak {
        if prev < curr { isPeak = false }
      } else {
        if prev > curr {
          isPeak = true
          peaks += 1
        }
      }
    }

    if hours > 0 {
      let avg = sum / hours
      let ratio = avg / max
      return (peaks, hours, sum, avg, max, ratio)
    }
    return (0, 0, 0, 0, 0, 0)
  }

  public func range(for dateInterval: DateInterval) -> Range<Int> {
    let start = dateInterval.start
    let end = dateInterval.end
    let hourFraction = self.count / 8760
    let fraction = 60 / hourFraction 
    let startHour = Greenwich.ordinality(of: .hour, in: .year, for: start)
    let startMinute = Greenwich.ordinality(of: .minute, in: .hour, for: start) 
    let endHour = Greenwich.ordinality(of: .hour, in: .year, for: end)
    let endMinute = Greenwich.ordinality(of: .minute, in: .hour, for: end)

    let startIndex = ((startHour - 1) * hourFraction) + (startMinute / fraction)
    let lastIndex = ((endHour - 1) * hourFraction) + (endMinute / fraction)

    return startIndex..<lastIndex
  }
}

extension MeteoData {
  public typealias Statistics =
  (peaks: Int, hours: Double, sum: Double, avg: Double, max: Double, ratio: Double)
}
