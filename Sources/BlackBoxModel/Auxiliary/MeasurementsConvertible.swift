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
}
