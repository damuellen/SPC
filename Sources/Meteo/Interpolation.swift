//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

extension Float {
   /// Linear interpolation function
  func lerp(to: Float, _ progress: Float) -> Float  {
    if progress >= 1 { return to }
    if progress <= 0 { return self }
    return self + (progress * (to - self))
  }

  func interpolated(to: Float, step: Float, steps: Float) -> Float {
    let a = self
    let b = (to - self) / 2 + self
    let m = (b - a)
    let aPrime = (2 * self - m) / 2
    return m * step / steps + aPrime
  }

  typealias Pair = (past: Float, future: Float)

  func interpolated(between: Pair, step: Float, steps: Float) -> Float {
    let a = max((self - between.past) / 2 + between.past, 0)
    let b = max((between.future - self) / 2 + self, 0)
    var m = (b - a)
    var aPrime = (2 * self - m) / 2
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
