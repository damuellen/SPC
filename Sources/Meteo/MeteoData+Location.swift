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

public struct MeteoData: CustomStringConvertible {
  public var temperature, dni, ghi, dhi, windSpeed: Float
  public let wetBulbTemperature: Float? = nil

  /// Linear interpolation function for meteo data values
  static func lerp(start: MeteoData, end: MeteoData,
                   _ value: Float) -> MeteoData {
    if value >= 1 { return end }

    let dni = start.dni + (value * (end.dni - start.dni)),
      ghi = start.ghi + (value * (end.ghi - start.ghi)),
      dhi = start.dhi + (value * (end.dhi - start.dhi)),
      t = start.temperature
      + (value * (end.temperature - start.temperature)),
      ws = start.windSpeed
      + (value * (end.windSpeed - start.windSpeed))

    return MeteoData(
      dni: dni, ghi: ghi, dhi: dhi, temperature: t, windSpeed: ws
    )
  }

  static func cosineInterpolation(start: MeteoData, end: MeteoData,
                                  _ progress: Float) -> MeteoData {
    func cosine(y1: Float, y2: Float, mu: Float) -> Float {
      let mu2 = (1 - cos(mu * .pi)) / 2
      return (y1 * (1 - mu2) + y2 * mu2)
    }

    if progress >= 1 { return end }

    let dni = cosine(y1: start.dni, y2: end.dni, mu: progress),
      ghi = cosine(y1: start.ghi, y2: end.ghi, mu: progress),
      dhi = cosine(y1: start.dhi, y2: end.dhi, mu: progress),
      t = cosine(y1: start.temperature, y2: end.temperature, mu: progress),
      ws = cosine(y1: start.windSpeed, y2: end.windSpeed, mu: progress)

    return MeteoData(
      dni: dni, ghi: ghi, dhi: dhi, temperature: t, windSpeed: ws
    )
  }

  /// Interpolation function for meteo data values
  static func interpolation(prev: MeteoData, current: MeteoData,
                            next: MeteoData, progess: Float) -> MeteoData {
    let startValue = current
    let endValue = next

    func interpolation(_ prev: Float, _ current: Float,
                       _ next: Float, _ progess: Float) -> Float {
      let a = (current - prev) / 2 + prev
      let b = (next - current) / 2 + current
      var m = (b - a)
      var aPrime = (2 * current - m) / 2
      var bPrime = aPrime + m

      if aPrime < 0 {
        bPrime = bPrime + aPrime
        aPrime = 0
        m = bPrime - aPrime
      }

      if bPrime < 0 {
        aPrime = aPrime + bPrime
        bPrime = 0
        m = bPrime - aPrime
      }
      
      return m * progess + aPrime
    }

    let dni = interpolation(prev.dni, current.dni, next.dni, progess),
      ghi = interpolation(prev.ghi, current.ghi, next.ghi, progess),
      dhi = interpolation(prev.dhi, current.dhi, next.dhi, progess),
      t = startValue.temperature
        + (progess * (endValue.temperature - startValue.temperature)),
      ws = startValue.windSpeed
        + (progess * (endValue.windSpeed - startValue.windSpeed))

    return MeteoData(
      dni: dni, ghi: ghi, dhi: dhi, temperature: t, windSpeed: ws
    )
  }

  public init() {
    self.dni = 0
    self.ghi = 0
    self.dhi = 0
    self.temperature = 0
    self.windSpeed = 0
  }

  public init(dni: Float, ghi: Float, dhi: Float,
              temperature: Float, windSpeed: Float) {
    self.dni = dni
    self.ghi = ghi
    self.dhi = dhi
    self.temperature = temperature
    self.windSpeed = windSpeed
  }

  public init(_ values: [Float]) {
    self.dni = values[0]
    self.temperature = values[1]
    self.windSpeed = values[2]
    self.ghi = values.count > 4 ? values[4] : 0
    self.dhi = values.count > 5 ? values[5] : 0
  }

  public init(tmy values: [Float]) {
    self.dni = values[3]
    self.temperature = values[0]
    self.windSpeed = values[6]
    self.ghi = values[2]
    self.dhi = values[4]
  }

  public var description: String {
    return String(format: "Temp: %.1f ", temperature)
      + String(format: "DNI: %.1f ", dni)
      + String(format: "GHI: %.1f ", ghi)
      + String(format: "DHI: %.1f ", dhi)
      + String(format: "WS: %.1f\n", windSpeed)
  }

  var values: [String] {
    return [
      String(format: "%.1f", temperature),
      String(format: "%.1f", ghi),
      String(format: "%.1f", dhi),
      String(format: "%.1f", windSpeed),
    ]
  }
}

public class MeteoDataSource {
  
  public let location: Position
  public let timeZone: Int?
  public let name: String
  
  let data: [MeteoData]  
  let year: Int?
  let hourFraction: Double

  private let valuesPerDay: Int
  
  init(name: String, data: [MeteoData],
       location: Position, year: Int?, timeZone: Int?) {
    self.name = name
    self.data = data
    self.location = location
    self.year = year
    self.timeZone = timeZone
    self.hourFraction = 8760 / Double(data.count)
    self.valuesPerDay = Int(24 / hourFraction)
    
    self.classificationOfDays.reserveCapacity(365)
    
    for day in 1...365 {
      classification(ofDay: day)
    }
  }
  
  public subscript(ofDay day: Int) -> Classification {
    return classificationOfDays[day - 1]
  }
  
  public typealias Classification =
    (peaks: Int, hours: Double, sum: Double, avg: Double, max: Double, ratio: Double)
  
  private var classificationOfDays: [Classification] = []
  
  private func classification(ofDay day: Int) {
    let end = (day * valuesPerDay)
    let start = end - valuesPerDay
    
    let day = data[start ..< end]
    
    let classification = analyse(day: day)
    
    classificationOfDays.append(classification)
  }
  
  private func analyse(day: ArraySlice<MeteoData>) -> Classification {
    var isPeak = false
    var peaks = 0
    var hours = 0.0
    var sum = 0.0
    var max = 0.0
    for i in day.indices.dropFirst() {
      let prev = Double(day[i - 1].dni)
      let curr = Double(day[i].dni)
      if curr > max { max = curr }
      if curr > 0 { hours += hourFraction; sum += curr * hourFraction }
      if isPeak {
        if prev < curr { isPeak = false }
      } else {
        if prev > curr { isPeak = true; peaks += 1 }
      }
    }
    
    if hours > 0 {
      let avg =  sum / hours
      let ratio = avg / max
      return (peaks, hours, sum, avg, max, ratio)
    }
    return (0, 0, 0, 0, 0, 0)
  }
  
}

public struct Position {
  public let longitude: Float
  public let latitude: Float
  public let elevation: Float

  public var coordinates: (Double, Double, Double) {
    return (Double(longitude), Double(latitude), Double(elevation))
  }

  public static var primeMeridian = Position(
    longitude: 0, latitude: 0, elevation: 102
  )
  
  public init(longitude: Float, latitude: Float, elevation: Float) {
    self.longitude = longitude
    self.latitude = latitude
    self.elevation = elevation
  }
}
