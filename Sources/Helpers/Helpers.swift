//
//  Copyright 2021 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation
#if os(Windows)
import WinSDK
#endif

fileprivate var cachedWidth: Int?
public func terminalWidth() -> Int {
  if let width = cachedWidth { return width }
#if os(Windows)
  var csbi: CONSOLE_SCREEN_BUFFER_INFO = CONSOLE_SCREEN_BUFFER_INFO()
  if !GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &csbi) {
    return 80
  }
  let width = Int(csbi.srWindow.Right - csbi.srWindow.Left)
  cachedWidth = width
  return width
#else
  // Try to get from environment.
  if let columns = ProcessInfo.processInfo.environment["COLUMNS"],
   let width = Int(columns) {
    cachedWidth = width
    return width
  }
  var ws = winsize()
  if ioctl(1, UInt(TIOCGWINSZ), &ws) == 0 {
    return Int(ws.ws_col) - 1
  }
  return 80
#endif
}

public func openFile(atPath: String) {
#if os(Windows)
  system("start " + atPath)
#elseif os(macOS)
  try? Process.run(
    URL(fileURLWithPath: "/usr/bin/open"),
    arguments: [atPath]
  )
#endif
}
extension FileManager {
  static func transientDirectory(url: (URL) throws -> Void) throws {
    let fm = FileManager.default
    let id = String(UUID().uuidString.prefix(8))
    let directory = fm.temporaryDirectory.appendingPathComponent(id, isDirectory: true)
    try fm.createDirectory(at: directory, withIntermediateDirectories: false)
    try url(directory)
    try fm.removeItem(at: directory)
  }
}

extension URL {
  var windowsPath: String {
    path.replacingOccurrences(of: "/", with: "\\")
  }

  static public func temporaryFile() -> URL {
    let fm = FileManager.default
    let id = String(UUID().uuidString.prefix(8))
    return fm.temporaryDirectory.appendingPathComponent(id)
  }

  public func removeItem() throws {
    try FileManager.default.removeItem(at: self)
  }
}

@_alwaysEmitIntoClient
public func seek(goal: Double, _ range: ClosedRange<Double> = 0...1,
 tolerance: Double = 0.0001, maxIterations: Int = 100,
 _ f: (Double)-> Double) -> Double {
  var a = range.lowerBound
  var b = range.upperBound
  for _ in 0..<maxIterations {
    let c = (a + b) / 2
    let fc = f(c)
    let fa = f(a)
    if (fc == goal || (b-a)/2 < tolerance) { return c }
    if (fc < goal && fa < goal) || (fc > goal && fa > goal)
     { a = c } else { b = c }
  }
  return Double.nan
}

@_alwaysEmitIntoClient
public func concurrentSeek(goal: Double, _ range: ClosedRange<Double> = 0...1,
 tolerance: Double = 0.0001, maxIterations: Int = 100,
 _ f: (Double)-> Double) -> Double {
  var x = [range.lowerBound, 0.0, range.upperBound]
  var y = [0.0, 0.0]
  for _ in 0..<maxIterations {
    x[1] = (x[0] + x[2]) / 2
    DispatchQueue.concurrentPerform(iterations: 2) { i in
      y[i] = f(x[i])
    }
    if (y[1] == goal || (x[2]-x[0])/2 < tolerance) { return x[1] }
    if (y[1] < goal && y[0] < goal) || (y[1] > goal && y[0] > goal)
     { x[0] = x[1] } else { x[2] = x[1] }
  }
  return Double.nan
}

// Fitting y = a0 + a1*x
    // least squares method
    // a0 =  (sumX - sumY) * sumXY / (sumX * sumX - n * sumXY)
    // a1 =  (sumX * sumY - n * sumXY) / (sumX * sumX - n * sumXX)    
@_alwaysEmitIntoClient
public func linearFit(x: [Double], y: [Double]) -> (Double)-> Double {
  var sumX: Double = 0
  var sumY: Double = 0
  var sumXY: Double = 0
  var sumXX: Double = 0
  let count = min(x.count, y.count)
  
  for i in 0..<count {
    sumX += x[i]
    sumY += y[i]
    sumXX += x[i] * x[i]
    sumXY += x[i] * y[i]
  }
  let a0 = (sumX - sumY) * sumXY / (sumX * sumX - Double(count) * sumXY)
  let a1 =  (sumX * sumY - Double(count) * sumXY) / (sumX * sumX - Double(count) * sumXX)

  return { value in a0 + a1 * value }
}

public typealias XY = SIMD2<Double>

extension Sequence where Element == XY {
  public func plot(_ terminal: Gnuplot.Terminal) -> Data {
    try! Gnuplot(xys: self, style: .points)(terminal)
  }
}

public extension Comparable {
  mutating func clamp(to limits: ClosedRange<Self>) {
    self = min(max(self, limits.lowerBound), limits.upperBound)
  }
  func clamped(to limits: ClosedRange<Self>) -> Self {    
    min(max(self, limits.lowerBound), limits.upperBound)
  }
}

/// Sorts the given arguments in ascending order, and returns the middle value.
///
///     // Values clamped to `0...100`
///     median(0, .min, 100)  //-> 0
///     median(0, .max, 100)  //-> 100
///
/// - Parameters:
///   - x: A value to compare.
///   - y: Another value to compare.
///   - z: A third value to compare.
///
/// - Returns: The middle value.
@_alwaysEmitIntoClient
public func median<T: Comparable>(_ x: T, _ y: T, _ z: T) -> T {
  var (x, y, z) = (x, y, z)
  // Compare (and swap) each pair of adjacent variables.
  if x > y {
    (x, y) = (y, x)
  }
  if y > z {
    (y, z) = (z, y)
    if x > y {
      (x, y) = (y, x)
    }
  }
  // Now `x` has the least value, and `z` has the greatest value.
  return y
}

/// Sorts the given arguments in ascending order, and returns the middle value.
///
///     // Values clamped to `0.0...1.0`
///     median(0.0, -.pi, 1.0)  //-> 0.0
///     median(0.0, +.pi, 1.0)  //-> 1.0
///
/// The sorted values will be totally ordered, including signed zeros and NaNs.
///
/// - Parameters:
///   - x: A value to compare.
///   - y: Another value to compare.
///   - z: A third value to compare.
///
/// - Returns: The middle value.
@_alwaysEmitIntoClient
public func median<T: FloatingPoint>(_ x: T, _ y: T, _ z: T) -> T {
  var (x, y, z) = (x, y, z)
  // Compare (and swap) each pair of adjacent variables.
  if !x.isTotallyOrdered(belowOrEqualTo: y) {
    (x, y) = (y, x)
  }
  if !y.isTotallyOrdered(belowOrEqualTo: z) {
    (y, z) = (z, y)
    if !x.isTotallyOrdered(belowOrEqualTo: y) {
      (x, y) = (y, x)
    }
  }
  // Now `x` has the least value, and `z` has the greatest value.
  return y
}

/// Sorts the given arguments in ascending order, and returns the middle value,
/// or the arithmetic mean of two middle values.
///
///     median(1, 2)            //-> 1.5
///     median(1, 2, 4)         //-> 2
///     median(1, 2, 4, 8)      //-> 3
///     median(1, 2, 4, 8, 16)  //-> 4
///
/// The sorted values will be totally ordered, including signed zeros and NaNs.
///
/// - Parameters:
///   - x: A value to compare.
///   - y: Another value to compare.
///   - rest: Zero or more additional values.
///
/// - Returns: The middle value, or the arithmetic mean of two middle values.
@_alwaysEmitIntoClient
public func median<T: FloatingPoint>(_ x: T, _ y: T, _ rest: T...) -> T {
  func _mean(_ a: T, _ b: T) -> T {
    (a.sign == b.sign)   // Avoid overflowing to infinity, by choosing to
    ? a + ((b - a) / 2)  // ? either advance by half the distance,
    : (a + b) / 2        // : or use the sum divided by the count.
  }
  guard !rest.isEmpty else { return _mean(x, y) }

  var values = ContiguousArray<T>()
  values.reserveCapacity(2 + rest.count)
  values.append(x)
  values.append(y)
  values.append(contentsOf: rest)
  values.sort(by: { !$1.isTotallyOrdered(belowOrEqualTo: $0) })

  let index = (values.endIndex - 1) / 2
  if values.count.isMultiple(of: 2) {
    return _mean(values[index], values[index + 1])
  } else {
    return values[index]
  }
}

