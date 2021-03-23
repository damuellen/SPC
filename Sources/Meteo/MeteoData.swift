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
import SolarPosition

public struct MeteoData: CustomStringConvertible {
  public var temperature, dni, ghi, dhi, windSpeed: Float
  var wetBulbTemperature: Float? = nil

  var values: [Float] { [temperature, dni, ghi, dhi, windSpeed] }

  /// Linear interpolation function for meteo data values
  static func lerp(start: MeteoData, end: MeteoData, _ progress: Float)
    -> MeteoData
  {
    if progress >= 1 { return end }
    if progress <= 0 { return start }

    return .init(zip(start.values, end.values).map { start, end in
      start + (progress * (end - start))
    })
  }

  /// Interpolation function for meteo data values
  static func interpolation(
    _ prev: MeteoData?, _ curr: MeteoData, _ next: MeteoData,
    step: Float, steps: Float
  ) -> MeteoData {
    
    func interpolation(
      _ curr: Float, _ next: Float, step: Float, steps: Float
    ) -> Float {
      let a = curr
      let b = (next - curr) / 2 + curr
      let m = (b - a)
      let aPrime = (2 * curr - m) / 2
      return m * step / steps + aPrime
    }

    func interpolation(
      _ prev: Float, _ curr: Float, _ next: Float, step: Float, steps: Float
    ) -> Float {
      let a = max((curr - prev) / 2 + prev, 0)
      let b = max((next - curr) / 2 + curr, 0)
      var m = (b - a)
      var aPrime = (2 * curr - m) / 2
      var bPrime = aPrime + m
      
      if aPrime < 0 {
        bPrime += aPrime
        aPrime = 0
        m = bPrime - aPrime
      }

      if bPrime < 0 {
        aPrime += bPrime
        bPrime = 0
        m = bPrime - aPrime
      }
      
      if aPrime > 0 {
        return m * (step - 1) / steps + aPrime
      }
      return m * step / steps
    }

    if let prev = prev {
      let (prev, curr, next) = (prev.values, curr.values, next.values)
      return .init((0..<5).map { i in
        interpolation(prev[i], curr[i], next[i], step: step, steps: steps)
      })
    } else {
      return .init(zip(curr.values, next.values).map { curr, next in
        interpolation(curr, next, step: step, steps: steps)
      })
    }
  }

  public init(
    dni: Float = 0, ghi: Float = 0, dhi: Float = 0,
    temperature: Float = 0, windSpeed: Float = 0
  ) {
    self.dni = dni
    self.ghi = ghi
    self.dhi = dhi
    self.temperature = temperature
    self.windSpeed = windSpeed
  }

  public init(meteo: [Float]) {
    self.dni = meteo[0]
    self.temperature = meteo[1]
    self.windSpeed = meteo[2]
    self.ghi = meteo.count > 4 ? meteo[4] : 0
    self.dhi = meteo.count > 5 ? meteo[5] : 0
  }
  
  public init(_ values: [Float]) {
    self.temperature = values[0]
    self.dni = values[1]
    self.ghi = values[2]
    self.dhi = values[3]
    self.windSpeed = values[4]
  }

  public init(tmy values: [Float]) {
    self.dni = values[3]
    self.temperature = values[0]
    self.windSpeed = values[6]
    self.ghi = values[2]
    self.dhi = values[4]
  }

  public init(tmy values: [Float], order: [Int]) {
    self.dni = values[order[0]]
    self.temperature = values[order[1]]
    self.windSpeed = values[order[2]]
    self.ghi = values[order[3]]
    self.dhi = values[order[4]]
  }

  public var description: String {
    String(format: "\nAmbient: %.1f degC", temperature)
      + String(format: "  DNI: %.1f W/m2", dni)
      + String(format: "  GHI: %.1f W/m2", ghi)
      + String(format: "  DHI: %.1f W/m2", dhi)
      + String(format: "  WS: %.1f m/s\n", windSpeed)
  }

  public var data: Data {
    let values = [
      Int16(dni * 10),
      Int16(dhi * 10),
      Int16(ghi * 10),
      Int16(temperature * 100),
      Int16(windSpeed * 100),
      Int16(wetBulbTemperature ?? 0 * 100)
    ]

    return values.withUnsafeBufferPointer { Data(buffer: $0) }
  }

  public init(data: Data) {
    let values = data.withUnsafeBytes { (p: UnsafeRawBufferPointer) -> [Int16] in
			let p = p.baseAddress!.assumingMemoryBound(to: Int16.self)
      let buffer = UnsafeBufferPointer(start: p, count: 6)
      return Array<Int16>(buffer)
    }
    self.dni = Float(values[0]) / 10
    self.dhi = Float(values[1]) / 10
    self.ghi = Float(values[2]) / 10
    self.temperature = Float(values[3]) / 100
    self.windSpeed = Float(values[4]) / 100
    self.wetBulbTemperature = Float(values[5]) / 100
  }
}
