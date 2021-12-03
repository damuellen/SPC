//
//  Copyright 2021 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

public struct CubicSpline {
  private var x: [Double]
  private var a: [Double]
  private var b: [Double]
  private var c: [Double]
  private var d: [Double]

  public init(x: [Double], y: [Double]) {
    let count: Int = min(x.count, y.count)
    self.x = x
    self.a = y
    self.b = [Double](repeating: 0.0, count: count)
    self.c = [Double](repeating: 0.0, count: count)
    self.d = [Double](repeating: 0.0, count: count)
    guard count > 0 else { return }

    let n: Int = count - 1
    var h = [Double](repeating: 0.0, count: count)
    var y = [Double](repeating: 0.0, count: count)
    var l = [Double](repeating: 0.0, count: count)
    var u = [Double](repeating: 0.0, count: count)
    var z = [Double](repeating: 0.0, count: count)
    var k = [Double](repeating: 0.0, count: count)
    var s = [Double](repeating: 0.0, count: count)

    for i in 0..<n {
      h[i] = x[i + 1] - x[i]
      k[i] = a[i + 1] - a[i]
      s[i] = k[i] / h[i]
    }

    for i in 1..<n { y[i] = 3 / h[i] * (a[i + 1] - a[i]) - 3 / h[i - 1] * (a[i] - a[i - 1]) }

    l[0] = 1
    u[0] = 0
    z[0] = 0

    for i in 1..<n {
      let temp: Double = 2 * (x[i + 1] - x[i - 1])
      l[i] = temp - h[i - 1] * u[i - 1]
      u[i] = h[i] / l[i]
      z[i] = (y[i] - h[i - 1] * z[i - 1]) / l[i]
    }
    
    l[n] = 1
    z[n] = 0
    var i = n - 1

    while i >= 0 {
      c[i] = z[i] - u[i] * c[i + 1]
      let aDiff: Double = a[i + 1] - a[i]
      let temp: Double = c[i + 1] + 2.0 * c[i]
      b[i] = aDiff / h[i] - h[i] * temp / 3.0
      d[i] = (c[i + 1] - c[i]) / (3 * h[i])
      i -= 1
    }

    c[n] = 0
  }

  public func callAsFunction(x input: Double) -> Double {
    guard x.count > 0 else { return input }
    var i = x.count - 1
    while i > 0 {
      if x[i] <= input { break }
      i -= 1
    }
    let dX = input - x[i]
    let (af, cf, df) = (b[i], c[i], d[i])
    return a[i] + af * dX + cf * (dX * dX) + df * (dX * dX * dX)
  }
}
import Libc

extension Double {
  private static var queudGaussian: Double?
  public static func randomGaussian(stdD standardDeviation: Double = 1.0, mean: Double = 0.0, maximum: Double = .infinity, minimum: Double = -.infinity) -> Double {
    var result: Double?
    repeat {
      let baseGaussian: Double
      if let gaussian = Double.queudGaussian {
        Double.queudGaussian = nil
        baseGaussian = gaussian
      } else {
        var value1: Double
        var value2: Double
        var sumOfSquares: Double
        repeat {
          value1 = 2 * Double.random(in: 0...1) - 1
          value2 = 2 * Double.random(in: 0...1) - 1
          sumOfSquares = value1 * value1 + value2 * value2
        } while sumOfSquares >= 1 || sumOfSquares == 0
        let multiplier = sqrt(-2 * log(sumOfSquares) / sumOfSquares)
        Double.queudGaussian = value2 * multiplier
        baseGaussian = value1 * multiplier
      }
      let parameterAdjustedGaussian = baseGaussian * standardDeviation + mean
      if (minimum...maximum).contains(parameterAdjustedGaussian) { result = parameterAdjustedGaussian }
    } while result == nil
    return result!
  }
}
