// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import Foundation
import Helpers
import Meteo

extension Insolation: MeasurementsConvertible {}

/// A protocol to provide a blueprint for types that can represent measurements
protocol MeasurementsConvertible {
  /// A collection of tuples representing the name and unit of measurements.
  static var measurements: [(name: String, unit: String)] { get }

  /// The numerical values for the measurements.
  var values: [Double] { get }
  
  /// A user-friendly and descriptive representation of the measurements.
  var prettyDescription: String { get }
}

extension MeasurementsConvertible {
  /// Iterates over the values array and convert each value to a formatted string. 
  ///
  /// If the magnitude of the value is less than 0.005, it is considered as 0.
  /// The formatted strings are joined together with commas.
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
