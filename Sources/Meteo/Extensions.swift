// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import DateExtensions
import Foundation

/// An extension on an array of `MeteoData` to provide interpolation and analysis functions.
extension Array where Element == MeteoData {
  /// Interpolates the meteorological data with the specified number of steps.
  /// - Parameter steps: The number of steps for interpolation.
  /// - Returns: An array of `MeteoData` with interpolated values.
  internal func interpolate(steps: Int) -> [MeteoData] {
    if self.count < 2 { return self }
    let (temperature, dni, ghi, dhi, windSpeed) = (
      self.map(\.temperature).interpolate(steps: steps),
      self.map(\.insolation.direct).interpolate(steps: steps),
      self.map(\.insolation.global).interpolate(steps: steps),
      self.map(\.insolation.diffuse).interpolate(steps: steps),
      self.map(\.windSpeed).interpolate(steps: steps)
    )
    return dni.indices.map { i -> MeteoData in
      MeteoData(
        dni: dni[i], ghi: ghi[i], dhi: dhi[i], temperature: temperature[i],
        windSpeed: windSpeed[i])
    }
  }

  /// Analyzes the meteorological data for a given day and calculates statistics.
  /// - Parameter day: An array of indices representing a day's data.
  /// - Returns: A tuple of statistics containing the number of peaks, hours of direct normal irradiance,
  ///            total irradiance sum, average irradiance, maximum irradiance, and average-to-max ratio.
  public func analyse(day: Array.Indices) -> MeteoData.Statistics {
    var isPeak = false
    var peaks = 0
    var hours = 0.0
    var sum = 0.0
    var max = 0.0
    let hourFraction = Double(self.count) / 8760
    for i in day.indices.dropFirst() {
      let prev = self[i - 1].insolation.direct
      let curr = self[i].insolation.direct
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

  /// Returns the range of indices corresponding to a given date interval.
  /// - Parameter dateInterval: The date interval to calculate the range for.
  /// - Returns: The range of indices within the date interval.
  public func range(for dateInterval: DateInterval) -> Range<Int> {
    let start = dateInterval.start
    let end = dateInterval.end
    let hourFraction = self.count / 8760
    let fraction = 60 / hourFraction
    let startHour = Greenwich.ordinality(of: .hour, in: .year, for: start)
    let startMinute = Greenwich.ordinality(of: .minute, in: .hour, for: start)
    let lastIndex: Int
    if Greenwich.compare(start, to: end, toUnitGranularity: .year)
      ~= .orderedSame
    {
      let endHour = Greenwich.ordinality(of: .hour, in: .year, for: end)
      let endMinute = Greenwich.ordinality(of: .minute, in: .hour, for: end)
      lastIndex = ((endHour - 1) * hourFraction) + (endMinute / fraction) + 1
    } else {
      lastIndex = self.endIndex
    }
    let startIndex =
      ((startHour - 1) * hourFraction) + (startMinute / fraction)
    return startIndex..<lastIndex
  }
}

extension MeteoData {
  /// A type alias for statistics calculated from meteorological data analysis.
  public typealias Statistics = (
    peaks: Int, hours: Double, sum: Double, avg: Double, max: Double,
    ratio: Double
  )
}
