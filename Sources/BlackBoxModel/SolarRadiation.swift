//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Meteo

struct SolarRadiation: PerformanceData {
  
  var dni, ghi, dhi, ico: Double
  
  init() {
    self.dni = 0.0
    self.ghi = 0.0
    self.dhi = 0.0
    self.ico = 0.0
  }
  
  init(meteo: MeteoData, cosTheta: Double) {
    self.dni = Double(meteo.dni)
    self.ghi = Double(meteo.ghi)
    self.dhi = Double(meteo.dhi)
    self.ico = Double(meteo.dni) * cosTheta
  }
  
  var csv: String {
    return "\(csv: dni, ghi, dhi, ico)"
  }
  
  public var values: [String] {
    return [
      String(format: "%.1f", dni),
      String(format: "%.1f", ghi),
      String(format: "%.1f", dhi),
      String(format: "%.1f", ico)
    ]
  }
  
  static var columns: [(name: String, unit: String)] {
    return [
      ("Solar|DNI", "Wh/m2"), ("Solar|GHI", "Wh/m2"),
      ("Solar|DHI", "Wh/m2"), ("Solar|ICO", "Wh/m2")
    ]
  }
  
  mutating func totalize(_ radiation: SolarRadiation, fraction: Double) {
    dni += radiation.dni * fraction
    ghi += radiation.ghi * fraction
    dhi += radiation.dhi * fraction
    ico += radiation.ico * fraction
  }
  
  mutating func reset() {
    dni = 0.0
    ghi = 0.0
    dhi = 0.0
    ico = 0.0
  }
}
