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

  private let dataSource: MeteoDataSource

  public enum Method { case linear, gradient }

  private let method: Method

  public init(
    _ source: MeteoDataSource,
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
    let r = 0...data.endIndex-1
    let method = self.method
    let steps =
      dataSource.hourFraction < 1
      ? Int(dataSource.hourFraction / frequence.fraction)
      : frequence.rawValue

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

      let meteo: MeteoData
      switch method {
      case .linear:
        meteo =  .interpolation((prev, curr, nil), step: step, steps: steps)
      case .gradient:
        let next = data[idx2]
        if idx0 == idx1 {
          meteo = .interpolation((nil, curr, next), step: step, steps: steps)
        } else {
          meteo = .interpolation((prev, curr, next), step: step, steps: steps)
        }
      }

      if step > 0, idx2 != r.upperBound, step.isMultiple(of: steps) {
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

extension MeteoData {
  /// Interpolation function for meteo data
  static func interpolation(
    _ values: (MeteoData?, MeteoData, MeteoData?), step: Int, steps: Int
  ) -> MeteoData {
    let step = Float(step + 1)
    let steps = Float(steps)
    let stride = (1 / steps)
    let curr = values.1
    let progress = step * stride
    let insolation: [Float]
    let conditions: [Float]
    if let next = values.2 {
      if let prev = values.0 {
        let i = zip(curr.insolation,
          zip(prev.insolation, next.insolation).map { ($0.0, $0.1) }
        )
        insolation = i.map { this, others in
          this.interpolated(between: others, step: step, steps: steps)
        }
      } else { // First index only
        insolation = zip(curr.insolation, next.insolation).map { this, other in
          this.interpolated(to: other, step: step, steps: steps)
        }
      }
      conditions = zip(curr.conditions, next.conditions).map { this, other in
        this.lerp(to: other, progress)
      }
    } else { // Linear interpolation
      guard let prev = values.0 else { preconditionFailure() }
      insolation = zip(prev.insolation, curr.insolation).map { this, other in
        this.lerp(to: other, progress)
      }
      conditions = zip(prev.conditions, curr.conditions).map { this, other in
        this.lerp(to: other, progress)
      }
    }
    return MeteoData(insolation: insolation, conditions: conditions)
  }
}
