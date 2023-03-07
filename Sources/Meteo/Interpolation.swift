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
    let (temperature, dni, ghi, dhi, windSpeed) =
      self.map(\.temperature).interpolate(steps: steps),
      self.map(\.dni).interpolate(steps: steps),
      self.map(\.ghi).interpolate(steps: steps),
      self.map(\.dhi).interpolate(steps: steps),
      self.map(\.windSpeed).interpolate(steps: steps))
    return data.indices.map { i -> MeteoData in
      MeteoData(dni: dni[i], ghi: ghi[i], dhi: dhi[i],
        temperature: temperature[i], windSpeed: windSpeed[i])
    }
  }
}
