//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

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
}

extension MeteoData {
  /// Interpolation function for meteo data
  static func interpolation(_ data: [MeteoData], step: Int, steps: Int) -> MeteoData {
    if data.count < 2 { return data[0] }
    let step = Double(step + 1)
    let steps = Double(steps)
    let stride = (1 / steps)
    let progress = step * stride
    let insolation = zip(data[0].insolation, data[1].insolation).map { this, next in
      this.lerp(to: next, progress)
    }
    let conditions = zip(data[0].conditions, data[1].conditions).map { this, next in
      this.lerp(to: next, progress)
    }
    return MeteoData(insolation: insolation, conditions: conditions)
  }
}

extension Double {
   /// Linear interpolation function
  func lerp(to: Double, _ progress: Double) -> Double  {
    if progress >= 1 { return to }
    if progress <= 0 { return self }
    return self + (progress * (to - self))
  }
}