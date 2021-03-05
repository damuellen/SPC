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

public class MeteoDataSource {
  public let name: String
  public let year: Int?
  public let location: Location

  let data: [MeteoData]
  let hourFraction: Double

  private let valuesPerDay: Int

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

    self.statisticsOfDays.reserveCapacity(365)

    for day in 1...365 { statistics(ofDay: day) }
  }

  public func serialized() -> Data {
    data.reduce(into: location.data) { $0 += $1.data }
  }

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
      let prev = Double(day[i - 1].dni)
      let curr = Double(day[i].dni)
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

  public static func generatedFrom(_ sun: SolarPosition, clouds: Bool = false)
    -> MeteoDataSource
  {
    let steps = 24
    var step = 0
    var day = 1
    var isCloudy = false

    var data = [MeteoData]()
    data.reserveCapacity(steps * 365)

    let rng = LinearCongruentialGenerator()

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
        let dni = Float(
          insolation(zenith: pos.zenith, day: day)
            * (isCloudy ? rng.random() : 1))
        data.append(MeteoData(dni: dni, temperature: 20))
      } else {
        data.append(MeteoData(temperature: 10))
      }
    }

    let location = Location(
      sun.location.coords, timezone: sun.location.timezone
    )

    return MeteoDataSource(
      name: "Fake", data: data, (sun.year, location)
    )
  }
}

private class LinearCongruentialGenerator: RandomNumberGenerator {
  var lastRandom = 95.0  // random seed
  let m = 139968.0
  let a = 3877.0
  let c = 29573.0

  func random() -> Double {
    lastRandom = ((lastRandom * a + c).truncatingRemainder(dividingBy: m))
    return lastRandom / m
  }
}

enum ClearSkyModel {
  case meinel, hottel, constant, moon
}

private func insolation(
  zenith: Double, day: Int, model: ClearSkyModel = .hottel
) -> Double {
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
    dni = (1 - 0.14 * al) * exp(-0.357 / pow(cz, 0.678)) + 0.14 * al
  case .hottel:
    dni =
      0.4237 - 0.00821 * pow(6.0 - al, 2)
      + (0.5055 + 0.00595 * pow(6.5 - al, 2))
      * exp(-(0.2711 + 0.01858 * pow(2.5 - al, 2)) / (cz + 0.00001))
  case .constant:
    let dni_des = 950.0
    dni = dni_des / (S0 * 1000.0)
  case .moon:
    let dpres = 1.0
    let del_h2o = 1.0
    dni =
      1 - 0.263 * ((del_h2o + 2.72) / (del_h2o + 5))
      * pow(save * dpres, ((del_h2o + 11.53) / (del_h2o + 7.88)) * 0.367)
  }
  return dni * S0 * 1000.0
}
