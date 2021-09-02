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

@inlinable
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

@inlinable
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
@inlinable
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