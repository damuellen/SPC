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
import Willow

extension Optional {
  var isNone: Bool {
    switch self {
    case .some: return false
    case .none: return true
    }
  }
}

extension DefaultStringInterpolation {

  mutating func appendInterpolation<T>(csv values: T...) where T : Numeric {
    values.forEach { value in
      self.appendInterpolation(
        numberFormatter.string(from: value as! NSNumber)!
      )
      self.appendInterpolation(", ")
    }
  }
  
  mutating func appendInterpolation<T>(format values: T...) where T : Numeric {
    values.forEach { value in
      self.appendInterpolation(
        numberFormatter.string(from: value as! NSNumber)!
      )
    }
  }
}

extension NumberFormatter {
  static func string(precision: Int, _ array: [Double]) -> [String] {
    numberFormatter.maximumFractionDigits = precision
    defer { numberFormatter.maximumFractionDigits = 3 }
    return array.map { numberFormatter.string(from: $0 as NSNumber)! }
  }
}

private let numberFormatter: NumberFormatter = {
  let numberFormatter = NumberFormatter()
  numberFormatter.minimumIntegerDigits = 1
  numberFormatter.maximumFractionDigits = 3
  numberFormatter.minimumFractionDigits = 0
  numberFormatter.decimalSeparator = "."
  return numberFormatter
}()

let backgroundQueue = DispatchQueue(label: "serial.queue")

let 💬 = Logger(logLevels: [.info, .error], writers: [ConsoleWriter()],
                executionMethod: .asynchronous(queue: backgroundQueue))

public typealias Heat = Double
public typealias Pressure = Double
public typealias Angle = Double

public extension Double {
  var toKelvin: Double { return self - Temperature.absoluteZeroCelsius }
  
  func limited(by value: Double) -> Double {
    return min(value, self)
  }
}

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

private let monthSymbols = calendar.monthSymbols

extension Progress {
  func tracking(month: Int) {
    let monthSymbol = monthSymbols[month - 1]
    let month = Int64(month)
    if month > completedUnitCount {
      completedUnitCount = month
      let count = month < 10 ? "[ \(month)/12]" : "[\(month)/12]"
      print(
        "\(count) Calculations for \(monthSymbol) in progress.       ",
        terminator: "\r"
      )
      fflush(stdout)
    }
  }
}

func readout(_ values: Any...) {
  values.forEach { value in
    print(value, terminator: "\n\n")
  }
  _ = readLine()
}

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

func swap<T>(_ lhs: inout T, _ rhs: inout T) {
  let temp = lhs
  lhs = rhs
  rhs = temp
}

@inline(__always)
public func unreachable() -> Never {
  return unsafeBitCast((), to: Never.self)
}
