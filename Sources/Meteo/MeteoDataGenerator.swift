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

/// A type that supplies a sequence of meteorological data.
public class MeteoDataGenerator: Sequence {

  private(set) var frequence: DateGenerator.Interval

  private(set) var dateInterval: DateInterval?

  private let dataSource: MeteoDataProvider

  private let method: Method

  public init(
    _ source: MeteoDataProvider,
    frequence: DateGenerator.Interval,
    method: Method = .linear
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

  private var firstStep = 0

  public func makeIterator() -> AnyIterator<MeteoData> {
    let data = dataSource.data
    let method = self.method
    let steps = dataSource.hourFraction < 1
      ? Int(dataSource.hourFraction / frequence.fraction)
      : frequence.rawValue

    let lastStep = steps * 2
    var step = firstStep //self.firstStep
    var cursor = range.startIndex

    return AnyIterator<MeteoData> {
      defer { step += 1 }
      let window: [MeteoData]
      switch method {
        case .gradient:
        window = Array(data[((cursor-1)..<(cursor+2)).clamped(to: data.indices)])
        case .linear:
        window = Array(data[((cursor)..<(cursor+2)).clamped(to: data.indices)])
      }
      if data.endIndex > cursor, step == lastStep { return nil }
      let meteo = MeteoData.interpolation(window, method: method, step: step, steps: steps)
      if step > 0, cursor-1 < data.endIndex, step.isMultiple(of: steps) {
        step = 0
        cursor += 1
      }
      return meteo
    }
  }
}

public enum Method { case linear, gradient }

extension MeteoData {
  /// Interpolation function for meteo data
  static func interpolation(_ data: [MeteoData], method: Method, step: Int, steps: Int) -> MeteoData {
    let step = Double(step + 1)
    let steps = Double(steps)
    let stride = (1 / steps)
    let progress = step * stride
    let insolation: [Double]
    let conditions: [Double]
    
    switch method {
      case .gradient:
      insolation = data.map(\.insolation).map { values in
        if data.count > 2 {
          return Double.interpolated(from: values, step: step, steps: steps)
        } else {
          return values[0].interpolated(to: values[1], step: step, steps: steps)
        }
      }
      conditions = zip(data[0].conditions, data[2].conditions).map { this, other in
        this.lerp(to: other, progress)
      }
      case .linear:
      insolation = zip(data[0].insolation, data[1].insolation).map { this, other in
        this.lerp(to: other, progress)
      }
      conditions = zip(data[0].conditions, data[1].conditions).map { this, other in
        this.lerp(to: other, progress)
      }
    }
    return MeteoData(insolation: insolation, conditions: conditions)
  }
}
