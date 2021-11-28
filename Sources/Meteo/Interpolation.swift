//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

extension Double {
   /// Linear interpolation function
  func lerp(to: Double, _ progress: Double) -> Double  {
    if progress >= 1 { return to }
    if progress <= 0 { return self }
    return self + (progress * (to - self))
  }

  func interpolated(to: Double, step: Double, steps: Double) -> Double {
    let a = self
    let b = (to - self) / 2 + self
    let m = (b - a)
    let aPrime = (2 * self - m) / 2
    return m * step / steps + aPrime
  }

  static func interpolated(from domain: [Double], step: Double, steps: Double) -> Double {
    let a = max((domain[1] - domain[0]) / 2 + domain[0], 0)
    let b = max((domain[2] - domain[1]) / 2 + domain[1], 0)
    var m = (b - a)
    var aPrime = (2 * domain[1] - m) / 2
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
}
