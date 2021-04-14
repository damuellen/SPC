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
import Helpers

extension Double {
  @inline(__always)
  func asString(precision: Int = 2) -> String {
    String(format: "%.\(precision)f", self)
  }
}

func formatting(_ values: [Double], _ labels: [String]) -> String {
  let pairs = zip(    
    labels.map { "  " + $0.padding(30) },
    values.map { String(format: "%03.2f", $0) }
  )
  return pairs.map { $0.0 + $0.1 }.joined(separator: "\n")
}

extension String {
  func padding(_ length: Int) -> String {
    padding(toLength: length, withPad: " ", startingAt: 0)
  }
}

extension Comparable {
  mutating func clamp(to limits: ClosedRange<Self>) {
    self = min(max(self, limits.lowerBound), limits.upperBound)
  }
  func clamped(to limits: ClosedRange<Self>) -> Self {    
    min(max(self, limits.lowerBound), limits.upperBound)
  }
}

public func decorated(_ title: String) -> String {
  var width = terminalWidth()
  width.clamp(to: 70...100)
  let half = (width - title.count - 8) / 2
  let line = String(repeating: "─", count: half)
  return line + "┤   " + title + "   ├" + line
}

public func heading(_ title: String) -> String {
  var width = terminalWidth()
  width.clamp(to: 70...100)
  let half = (width - title.count - 8) / 2
  let s = String(repeating: "─", count: half)
  return "\n" + s + "┤   " + title + "   ├" + s + "\n"
}

public typealias Angle = Double

extension Angle {
  public var toRadians: Double { self * .pi / 180 }
  public var toDegrees: Double { self * (180 / .pi) }
}
