//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import DateGenerator
import Dispatch

func formatting(_ values: [Double], _ labels: [String]) -> String {
  let pairs = zip(    
    labels.map { "  " + $0.padding(30) },
    values.map { String(format: "%03.1f", $0) }
  )
  return pairs.map { $0.0 + $0.1 }.joined(separator: "\n")
}

extension String {
  func padding(_ length: Int) -> String {
    padding(toLength: length, withPad: " ", startingAt: 0)
  }
}

extension Optional {
  var isNone: Bool {
    switch self {
    case .some: return false
    case .none: return true
    }
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

extension DefaultStringInterpolation {
  mutating func appendInterpolation(csv values: Double...) {
    values.forEach { value in
      self.appendInterpolation(value.description)
      self.appendInterpolation(", ")
    }
  }

  mutating func appendInterpolation(format values: Double...) {
    values.forEach { value in
      self.appendInterpolation(value.asString())
    }
  }
}

public func decorated(_ title: String) -> String {
  var width = terminalWidth() ?? 80
  width.clamp(to: 70...100)
  let half = (width - title.count - 8) / 2
  let line = String(repeating: "─", count: half)
  return line + "┤   " + title + "   ├" + line
}

public func heading(_ title: String) -> String {
  var width = terminalWidth() ?? 80
  width.clamp(to: 70...100)
  let half = (width - title.count - 8) / 2
  let s = String(repeating: "─", count: half)
  return "\n" + s + "┤   " + title + "   ├" + s + "\n"
}

extension Double {
  @inline(__always)
  func asString(precision: Int = 2) -> String {
    String(format: "%.\(precision)f", self)
  }
}

let backgroundQueue = DispatchQueue(label: "serial.queue")

public typealias Heat = Double
public typealias Pressure = Double
public typealias Angle = Double

extension Angle {
  public var toRadians: Double { self * .pi / 180 }
  public var toDegrees: Double { self * (180 / .pi) }
}

extension String {
  static var lineBreak: String { "\n" }
  static var separator: String { ", " }
}

@inline(__always)
public func unreachable() -> Never {
  unsafeBitCast((), to: Never.self)
}

extension Array where Element: AdditiveArithmetic {
  public func sum() -> Element {
    reduce(.zero, +)
  }
}

extension Array where Element: BinaryFloatingPoint {
  public func mean() -> Element {
    reduce(.zero, +) / .init(count)
  }
}

extension Array where Element: Comparable {
  public func minMax() -> (min: Element, max: Element)? {
    guard var minimum = first else { return nil }
    var maximum = minimum
    // if 'vector' has an odd number of items,
    // let 'minimum' or 'maximum' deal with the leftover
    let start = count % 2  // 1 if odd, skipping the first element
    for i in stride(from: start, to: count, by: 2) {
      let (first, second) = (self[i], self[i + 1])

      if first > second {
        if first > maximum { maximum = first }
        if second < minimum { minimum = second }
      } else {
        if second > maximum { maximum = second }
        if first < minimum { minimum = first }
      }
    }
    return (minimum, maximum)
  }
}
