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
import Meteo

extension Insolation: MeasurementsConvertible {}

protocol MeasurementsConvertible {
  static var measurements: [(name: String, unit: String)] { get }
  var values: [Double] { get }
  var prettyDescription: String { get }
}

extension MeasurementsConvertible {
  var commaSeparatedValues: String {
    values.map { 
      if $0.magnitude < 0.005 { return "0" }
      let (q, r) = Int($0 * 100 + 0.5).quotientAndRemainder(dividingBy: 100)
      return "\($0 < 0 ? "-" : "")\(q).\(r < 10 ? "0" : "")\(r)"
    }.joined(separator: ",")
  }

  var prettyDescription: String {
    return zip(values, Self.measurements).reduce("\n") { result, tuple in
      let (value, desc) = (String(format: "%.2f", tuple.0), tuple.1)
      if value.hasPrefix("0") { return result }
      return result + (desc.name * (value + " " + desc.unit))
    }
  }

  var multiBar: String {
    let maxValue = values.max() ?? 0
    let increment = maxValue
    return zip(values, Self.measurements).reduce("\n") { result, pair in
      let (value, desc) = (String(format: "%.2f", pair.0), pair.1.name)
      let c = 34 - desc.count - value.count
      let text = desc + String(repeating: " ", count: c) + value
      let r = result + text + " "
      if pair.0.isZero { return result }
      let (bar_chunks, remainder) = Int(pair.0 * maxValue / increment)
        .quotientAndRemainder(dividingBy: 8)
      let full = UnicodeScalar("█").value
      let fractionalPart = remainder > 0
        ? String(UnicodeScalar(full + UInt32(8 - remainder))!) : ""
      return r + String(repeating: "█", count: bar_chunks)
        + fractionalPart + "\n"
    }
  }
}
