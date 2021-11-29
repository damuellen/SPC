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
import SolarPosition

/// A type that provides meteorological data for one year.
public class MeteoDataProvider: Sequence {
  public let name: String
  public let year: Int?
  public let location: Location

  let data: [MeteoData]
  let hourFraction: Double

  private let valuesPerDay: Int
  private(set) var frequence: DateGenerator.Interval
  private(set) var dateInterval: DateInterval?

  public init(
    name: String, data: [MeteoData],
    _ meta: (year: Int, location: Location)
  ) {
    self.data = data
    self.location = meta.location
    self.year = meta.year
    self.name = name
    self.hourFraction = 8760 / Double(data.count)
    self.valuesPerDay = Int(24 / hourFraction)
    self.frequence = .init(rawValue: Int(1 / hourFraction)) ?? .hourly
    self.range = data.startIndex..<data.endIndex
    self.statisticsOfDays.reserveCapacity(365)

    for day in 1...365 { statistics(ofDay: day) }
  }

  public init(data: Data, year: Int? = nil) {
    self.name = ""
    self.year = year
    let sizeLocation = 16
    self.location = Location(data: data.prefix(sizeLocation))
    let stride = 12
    let count = (data.count - sizeLocation) / stride

    self.data = (0..<count).map {
      let startIndex = sizeLocation + $0 * stride
      let endIndex = startIndex + stride
      return MeteoData(data: data[startIndex..<endIndex])
    }

    self.hourFraction = 8760 / Double(self.data.count)
    self.valuesPerDay = Int(24 / hourFraction)
    self.frequence = .init(rawValue: Int(1 / hourFraction)) ?? .hourly
    self.range = data.startIndex..<data.endIndex
    self.statisticsOfDays.reserveCapacity(365)

    for day in 1...365 { statistics(ofDay: day) }
  }

  public func serialized() -> Data {
    data.reduce(into: location.data) { $0 += $1.data }
  }

  public func setInterval(_ frequence: DateGenerator.Interval) {
    self.frequence = frequence
  }

  public func setRange(_ dateInterval: DateInterval) {
    self.dateInterval = dateInterval.align(with: self.frequence)

    let start = self.dateInterval!.start
    let end = self.dateInterval!.end
    let fraction = Int(1 / hourFraction)

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

  public var currentDay: Statistics {
    return statisticsOfDays[DateTime.indexDay]
  }

  public typealias Statistics =
    (peaks: Int, hours: Double, sum: Double, avg: Double, max: Double, ratio: Double)

  private var statisticsOfDays: [Statistics] = []

  private func statistics(ofDay day: Int) {
    let end = (day * valuesPerDay)
    let start = end - valuesPerDay

    let day = data[start..<end]

    let statistics = analyse(day: day)

    statisticsOfDays.append(statistics)
  }

  private func analyse(day: ArraySlice<MeteoData>) -> Statistics {
    var isPeak = false
    var peaks = 0
    var hours = 0.0
    var sum = 0.0
    var max = 0.0
    for i in day.indices.dropFirst() {
      let prev = day[i - 1].dni
      let curr = day[i].dni
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

  public static func using(_ sun: SolarPosition, model: ClearSkyModel, clouds: Bool = false)
    -> MeteoDataProvider
  {
    let steps = 24
    var step = 0
    var day = 1
    var isCloudy = false

    var data = [MeteoData]()
    data.reserveCapacity(steps * 365)

    var rng = LinearCongruentialGenerator()

    for d in DateGenerator(year: sun.year, interval: sun.frequence) {
      step += 1
      if step == steps {
        day += 1
        step = 0
      }
      if let pos = sun[d], pos.zenith < 90 {
        if (step * 2) % steps == 0 {
          isCloudy = (rng.random() < 0.314) && clouds
        }
        let dni = insolation(zenith: pos.zenith, day: day, model: model)
         * (isCloudy ? rng.random() : 1)
        data.append(MeteoData(dni: dni, temperature: 20))
      } else {
        data.append(MeteoData(temperature: 10))
      }
    }

    let location = Location(
      sun.location.coords, timezone: sun.location.timezone
    )

    return MeteoDataProvider(
      name: "Fake", data: data, (sun.year, location)
    )
  }

  private var firstStep = 0

  public func makeIterator() -> AnyIterator<MeteoData> {
    let data = self.data
    let steps = hourFraction < 1
      ? Int(hourFraction / frequence.fraction)
      : frequence.rawValue

    let lastStep = steps * 2
    var step = firstStep

    var cursor = range.startIndex

    return AnyIterator<MeteoData> {
      defer { step += 1 }
      if step > 0, cursor-1 < data.endIndex, step.isMultiple(of: steps) {
        step = 0; cursor += 1
      }
      let window = Array(data[((cursor)..<(cursor+2)).clamped(to: data.indices)])
      if data.endIndex > cursor, step == lastStep { return nil }
      let meteo = MeteoData.interpolation(window, step: step, steps: steps)
      return meteo
    }
  }
}

private struct LinearCongruentialGenerator {
  var lastRandom = 95.0  // random seed
  let m = 139968.0
  let a = 3877.0
  let c = 29573.0

  mutating func random() -> Double {
    lastRandom = ((lastRandom * a + c).truncatingRemainder(dividingBy: m))
    return lastRandom / m
  }
}

public enum ClearSkyModel { case meinel, hottel, constant }

private func insolation(zenith: Double, day: Int, model: ClearSkyModel) -> Double {
  let S0 = 1.353 * (1 + 0.0335 * cos(2 * .pi * (Double(day) + 10) / 365))

  let sz = sin(zenith * .pi / 180)
  let cz = cos(zenith * .pi / 180)

  let R2D = 57.29577951308232286465

  let save2 = 90 - atan2(sz, cz) * R2D
  var save = 1 / cz

  if save2 <= 30 {
    save =
      save - 41.972213
      * pow(
        save2, -2.0936381 - 0.04117341 * save2 + 0.000849854 * pow(save2, 2)
      )
  }
  let al = 0.1 / 1000.0

  var dni: Double

  switch model {
  case .meinel:
    dni = 940 * ((1 - 0.14 * al) * exp(-0.357 / pow(cz, 0.678)) + 0.14 * al) 
  case .hottel:
    dni = 1030 *
      (0.4237 - 0.00821 * pow(6.0 - al, 2)
      + (0.5055 + 0.00595 * pow(6.5 - al, 2))
      * exp(-(0.2711 + 0.01858 * pow(2.5 - al, 2)) / (cz + 0.00001)))
  case .constant:
    let dni_des = 900.0
    dni = dni_des / S0
  }
  return dni * S0 
}
