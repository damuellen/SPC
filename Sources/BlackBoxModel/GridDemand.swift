//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import DateExtensions
import Physics

struct GridDemand: Codable {

  static var current = GridDemand()

  private var index: Int { return DateTime.indexMonth }

  private let data: [Ratio]

  init(_ data: [Ratio]) {
    self.data = data
  }

  var ratio: Double {
    if index < 0 { return self.data[0].quotient }
    return self.data[index].quotient
  }

  private init() {
    self = GridDemand(Array(repeatElement(Ratio(1), count: 12)))
  }
}

public struct Demand {}