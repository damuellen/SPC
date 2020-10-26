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

    let calendar = NSCalendar(identifier: .gregorian)!
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!

    let startHour = calendar.ordinality(of: .hour, in: .year, for: start)
    let startIndex = (startHour - 1) * fraction

    let startMinute = calendar.ordinality(of: .minute, in: .hour, for: start)
    firstStep += startMinute / (60 / frequence.rawValue) / fraction

    let endHour = calendar.ordinality(of: .hour, in: .year, for: end)
    let lastIndex = (endHour - 1) * fraction

    range = startIndex..<lastIndex

    let endMinute = calendar.ordinality(of: .minute, in: .hour, for: end)
    lastStep = endMinute / (60 / frequence.rawValue) / fraction
  }

  private var range: Range<Int>

  private var firstStep = 1
  private var lastStep = 0

  public func makeIterator() -> AnyIterator<MeteoData> {
    let data = dataSource.data
    let method = self.method
    let steps =
      dataSource.hourFraction < 1
      ? Int(dataSource.hourFraction / frequence.fraction)
      : frequence.rawValue

    let stride = (1 / Float(steps))

    var step = self.firstStep
    var index = range.lowerBound

    let lastStep = self.lastStep
    let lastIndex = range.upperBound

    return AnyIterator<MeteoData> {
      defer { step += 1 }
      // When step count is reached move index to the next value.
      if step > steps {
        step = 1
        index += 1
      }
      // Check whether the end of the range has been reached.
      if index == lastIndex && step > lastStep { return nil }

      if steps == 1 { return data[index] }
      // The first values of the year are interpolated with the last,
      // otherwise always with the previous.
      let prev = index > 0 ? data[index - 1] : data[data.endIndex - 1]

      let current = data[index]

      switch method {
      case .linear:
        return MeteoData.lerp(start: prev, end: current, Float(step) * stride)
      case .gradient:
        // The last values of the year are interpolated with the first,
        // otherwise always with the next.
        let next = index < data.endIndex - 1 ? data[index + 1] : data[0]
        return MeteoData.interpolation(
          prev: prev, current: current, next: next, progess: Float(step) * stride
        )
      }
    }
  }
}
