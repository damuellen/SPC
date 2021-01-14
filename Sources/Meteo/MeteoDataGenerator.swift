//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import DateGenerator
import Foundation

public class MeteoDataGenerator: Sequence {

  private(set) var frequence: DateGenerator.Interval

  private(set) var dateInterval: DateInterval?

  private let dataSource: MeteoDataSource

  public enum Method {
    case linear, gradient
  }

  private let method: Method

  public init(
    _ source: MeteoDataSource,
    frequence: DateGenerator.Interval,
    method: Method = .gradient
  ) {
    precondition(
      frequence.fraction <= source.hourFraction,
      "The interval must be shorter or the same as in the source.")
    self.dataSource = source
    self.frequence = frequence
    self.range = source.data.startIndex..<source.data.endIndex
    self.method = method
  }

  public func setRange(_ dateInterval: DateInterval) {
    self.dateInterval = dateInterval.align(with: self.frequence)

    let start = self.dateInterval!.start
    let end = self.dateInterval!.end
    let fraction = Int(1 / dataSource.hourFraction)

    let startHour = calendar.ordinality(of: .hour, in: .year, for: start)
    let startIndex = (startHour - 1) * fraction

    let startMinute = calendar.ordinality(of: .minute, in: .hour, for: start)
    firstStep += startMinute / (60 / frequence.rawValue) / fraction

    let endHour = calendar.ordinality(of: .hour, in: .year, for: end)
    let lastIndex = (endHour - 1) * fraction

    range = startIndex..<lastIndex

    //let endMinute = calendar.ordinality(of: .minute, in: .hour, for: end)
    //lastStep = endMinute / (60 / frequence.rawValue) / fraction
  }

  private var range: Range<Int>

  private var firstStep = 1

  public func makeIterator() -> AnyIterator<MeteoData> {
    let data = dataSource.data
    let r = 0...data.endIndex-1
    let method = self.method
    let steps =
      dataSource.hourFraction < 1
      ? Int(dataSource.hourFraction / frequence.fraction)
      : frequence.rawValue

    let stride = (1 / Float(steps))
    let firstStep = 0//-(s / 2)
    let lastStep = steps * 2

    var step = firstStep //self.firstStep
    var cursor = range.startIndex

    return AnyIterator<MeteoData> {
      defer { step += 1 }
      
      let idx0 = (cursor - 1).clamped(to: r)
      let idx1 = cursor.clamped(to: r)
      let idx2 = (cursor + 1).clamped(to: r)
      
      if idx2 == r.upperBound, step == lastStep { return nil }
      
      let prev = data[idx0]
      let curr = data[idx1]
      let next = data[idx2]      
      
      var meteo: MeteoData
      switch method {
      case .linear:
      meteo = MeteoData.lerp(start: curr, end: next, Float(step) * stride)
      case .gradient:
        if idx0 == idx1 {
          meteo = MeteoData.interpolation(
            nil, curr, next, step: Float(step + 1), steps: Float(steps)
          )
        } else {
          meteo = MeteoData.interpolation(
            prev, curr, next, step: Float(step + 1), steps: Float(steps)
          )
        }
      }
      
      if step > 0, idx2 != r.upperBound,
         step.isMultiple(of: steps) {
        step = 0
        cursor += 1
      }
      
      return meteo
    }
  }
}

extension Comparable {
  func clamped(to limits: ClosedRange<Self>) -> Self {
    min(max(self, limits.lowerBound), limits.upperBound)
  }
}
