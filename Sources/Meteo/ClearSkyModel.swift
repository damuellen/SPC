//
//  Copyright 2023 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Libc
import SolarPosition
import DateExtensions

extension MeteoData {
  
  public static func using(
    _ sun: SolarPosition, model: ClearSkyModel = .constant, clouds: Bool = false
    ) -> [MeteoData]
  {
    let steps = sun.frequence.rawValue * 24
    var step = 0
    var day = 1
    var isCloudy = false

    var data = [MeteoData]()
    data.reserveCapacity(steps * 365)

    var rng = LinearCongruentialGenerator()

    for d in DateSequence(year: sun.year, interval: sun.frequence) {
      step += 1
      if step == steps {
        day += 1
        step = 0
      }
      if let pos = sun[d], pos.zenith < 90 {
        if (step * 2) % steps == 0 {
          isCloudy = clouds && (rng.random() < 0.2)
        }
        let dni = calculate(zenith: pos.zenith, day: day, model: model)
          * (isCloudy ? rng.random() : 1)
        data.append(MeteoData(dni: dni, temperature: 20))
      } else {
        data.append(MeteoData(temperature: 10))
      }
    }

    return data
  }
}

public enum ClearSkyModel { case meinel, hottel, constant, special }

fileprivate func calculate(zenith: Double, day: Int, model: ClearSkyModel) -> Double {
  let S0 = 1.353 * (1 + 0.0335 * cos(2 * .pi * (Double(day) + 10) / 365))
  let B = 2.0 * .pi * Double(day) / 365.0
  let roverR0sqrd = 1.00011
   + 0.034221 * cos(B) + 0.00128 * sin(B)
   + 0.000719 * cos(2 * B) + 0.000077 * sin(2 * B)

  let dni_des = 930.0 * roverR0sqrd

  let cz = cos(zenith * .pi / 180)
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
    dni = dni_des / S0
  case .special:
    dni = (0.5 * ((1 - 0.14 * al) * exp(-0.357 / pow(cz, 0.678)) + 0.14 * al) + 
      (0.4237 - 0.00821 * pow(6.0 - al, 2) + (0.5055 + 0.00595 * pow(6.5 - al, 2))
      * exp(-(0.2711 + 0.01858 * pow(2.5 - al, 2)) / (cz + 0.00001)))) / 1.45
  }
  return dni * S0 * dni_des
}

fileprivate struct LinearCongruentialGenerator {
  var lastRandom = 95.0  // random seed
  let m = 139968.0
  let a = 3877.0
  let c = 29573.0

  mutating func random() -> Double {
    lastRandom = ((lastRandom * a + c).truncatingRemainder(dividingBy: m))
    return lastRandom / m
  }
}
