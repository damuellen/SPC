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
public func terminalWidth() -> Int {
#if os(Windows)
  var csbi: CONSOLE_SCREEN_BUFFER_INFO = CONSOLE_SCREEN_BUFFER_INFO()
  if !GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &csbi) {
    return 80
  }
  return Int(csbi.srWindow.Right - csbi.srWindow.Left)
#else
  // Try to get from environment.
  if let columns = ProcessInfo.processInfo.environment["COLUMNS"],
   let width = Int(columns) {
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
    let id = UUID().uuidString
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
    let id = UUID().uuidString
    return fm.temporaryDirectory.appendingPathComponent(id)
  }

  public func removeItem() throws {
    try FileManager.default.removeItem(at: self)
  }
}

public func seek(
 _ range: ClosedRange<Double>, seekValue: Double,
 tolerance: Double = 0.001, maxIterations: Int = 100,
 _ f: (Double)-> Double) -> Double {
  var a = range.lowerBound
  var b = range.upperBound
  for _ in 0..<maxIterations {
    let c = (a + b) / 2
    let fc = f(c)
    let fa = f(a)
    if (fc == seekValue || (b-a)/2 < tolerance)
     { return c }
    if (fc < seekValue && fa < seekValue) 
    || (fc > seekValue && fa > seekValue) 
     { a = c } else { b = c }
  }
  return Double.nan
}
