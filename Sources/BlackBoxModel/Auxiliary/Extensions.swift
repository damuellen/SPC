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
import TSCBasic

extension Optional {
  var isNone: Bool {
    switch self {
    case .some: return false
    case .none: return true
    }
  }
}

extension DefaultStringInterpolation {
  mutating func appendInterpolation(csv values: Double...)  {
    values.forEach { value in
      self.appendInterpolation(value.description)
      self.appendInterpolation(", ")
    }
  }
  
  mutating func appendInterpolation(format values: Double...){
    values.forEach { value in
      self.appendInterpolation(string(value))
    }
  }
}

public func decorated(_ title: String) -> String {
  let width = TerminalController.terminalWidth() ?? 80
  let half = (width - title.count - 8) / 2
  let line = String(repeating: "─", count: half)
  return line + "┤   " + title + "   ├" + line
}

@inline(__always)
func strings(_ array: [Double], precision: Int = 1) -> [String] {
  array.map { String(format: "%.\(precision)f", $0) }
}

@inline(__always)
func string(_ value: Double, precision: Int = 2) -> String {
  String(format: "%.\(precision)f", value)
}

let backgroundQueue = DispatchQueue(label: "serial.queue")

public typealias Heat = Double
public typealias Pressure = Double
public typealias Angle = Double

public extension Angle {
  var toRadians: Double { return self * .pi / 180 }
  var toDegrees: Double { return self * (180 / .pi) }
}

let calendar = { calendar -> Calendar in
  var calendar = calendar
  calendar.timeZone = TimeZone(secondsFromGMT: 0)!
  calendar.locale = Locale(identifier: "en_US")
  return calendar
}(Calendar(identifier: .gregorian))

extension String {
  static var lineBreak: String { return "\n" }
  static var separator: String { return ", " } 
}

final class Cache<T: Hashable> {
  var cachedValues: [Int:T] = [:]
  
  func lookupResult(for hash: Int) -> T? {
    return cachedValues[hash]
  }
  
  func update(hash: Int, result: T) {
    cachedValues[hash] = result
  }
}

@inline(__always)
public func unreachable() -> Never {
  return unsafeBitCast((), to: Never.self)
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
    let start = count % 2 // 1 if odd, skipping the first element
    for i in stride(from: start, to: count, by: 2) {
      let (first, second) = (self[i], self[i+1])
      
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
