//
//  Copyright 2021 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//


let A = UnicodeScalar("A").value
let columns = (0..<1100).map { n -> String in 
  var nn = n
  var x = ""
  if n > 701 {
    nn -= 676
    x = "A"
  }
  let i = nn.quotientAndRemainder(dividingBy: 26)
  let q = i.quotient > 0 ? String(UnicodeScalar(A + UInt32(i.quotient - 1))!) : ""
  return x + q + String(UnicodeScalar(A + UInt32(i.remainder))!)
}

/*
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


func downsample(values: [(x:Double, y: Double)], threshold: Int) -> [(x:Double,y: Double)] {

  guard values.count > threshold && values.count > 2 else { return values }
  
  let bucketSize = (values.count - 2) / (threshold - 2)
  
  var A = 0, nextA = 0
  var out = [(x:Double, y: Double)]()
  var maxAreaPoint: (x:Double, y: Double) = (x:0, y: 0)
  out.append(values.first!)
  
  for i in 0..<(threshold - 2) {
    
    var avgRangeStart = (i + 1) * bucketSize + 1
    var avgRangeEnd   = (i + 2) * bucketSize + 1
    
    avgRangeEnd = avgRangeEnd < values.count ? avgRangeEnd : values.count
    
    let avgRangeLength = avgRangeEnd - avgRangeStart
    
    var avgX = 0.0, avgY = 0.0
    
    while avgRangeStart < avgRangeEnd {
      avgX += values[avgRangeStart].x
      avgY += values[avgRangeStart].y
      avgRangeStart += 1;
    }
    
    avgX /= Double(avgRangeLength)
    avgY /= Double(avgRangeLength)
    
    var rangeOffs = (i + 0) * bucketSize + 1
    let rangeTo   = (i + 1) * bucketSize + 1
    
    let pointAx = values[A].x
    let pointAy = values[A].y
    
    var maxArea = -1.0;
    
    while rangeOffs < rangeTo {
      
      let x = (pointAx - avgX) * ( values[rangeOffs].y - pointAy)
      let y = (pointAx - values[rangeOffs].x ) * (avgY - pointAy)
      let area = abs ( x - y ) * 0.5;
      
      if area > maxArea {
        maxArea = area;
        maxAreaPoint = values[rangeOffs]
        nextA = rangeOffs
      }
      rangeOffs += 1
    }
    out.append( maxAreaPoint  )
    A = nextA
  }
  out.append (values.last!)
  return out
}

let c = CSV(atPath: "/workspaces/SPC/Saudian.csv")!
let dni = c["DNI"]
let ss = dni.chunks(ofCount: 24)
var count = 1
var result = [Double]()

for day in ss {
  let y1 = Array(day)
  let x1 = [Double](stride(from: 0, to: Double(y1.count), by: 1))
  let x2 = [Double](stride(from: 0, to: Double(y1.count), by: 1 / 12))
  let d = CubicSpline(x: x1, y: y1)
  let y2 = x2.map(d.callAsFunction(x:)).map { max(0, $0) }
  let factor = y1.reduce(0, +) / (y2.reduce(0, +) / 12)
  let y3 = y2.map { factor * $0 }
  // try! Gnuplot(xs: x1, x2, x2, ys: y1, y2, y3)(.pngLarge(path: "dni_\(count).png"))
  count += 1
  result.append(contentsOf: y3)
}

try? Gnuplot(xs: result.prefix(1000), result.prefix(1000))
  .plot(multi: true, index: 0, x: 0, y: 1)
  .plot(multi: true, index: 1, x: 0, y: 1)(.pngLarge(path: "_test1.png"))
try? Gnuplot(xs: result.prefix(1000), result.prefix(1000))
  .plot(multi: true, index: 0, x: 0, y: 1)
  .plot(multi: true, index: 1, x: 0, y: 1)(.pngLarge(path: "_test2.png"))
dni.map { $0 < 5 ? 0 : $0 }.forEach { print($0) }
*/