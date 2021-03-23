//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

protocol MeasurementsConvertible {
  static var columns: [(name: String, unit: String)] { get }
  var numericalForm: [Double] { get }
  var prettyDescription: String { get }
}

extension MeasurementsConvertible {
  var values: [String] { numericalForm.map { $0.asString() } }

  var prettyDescription: String {
    return zip(numericalForm, Self.columns).reduce("\n") { result, tuple in
      let (value, desc) = (tuple.0.asString(), tuple.1)
      if value.hasPrefix("0") { return result }
      return result + (desc.name * (value + " " + desc.unit))
    }
  }

  var multiBar: String {
    let maxValue = numericalForm.max() ?? 0
    let increment = maxValue
    return zip(numericalForm, Self.columns).reduce("\n") { result, pair in
      let (value, desc) = (pair.0.asString(), pair.1.name)
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
        + fractionalPart + .lineBreak
    }
  }
}
