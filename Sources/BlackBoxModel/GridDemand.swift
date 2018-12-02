//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Config
import Foundation

struct GridDemand: Codable {
  
  static var current = withDefaults()
  
  private var index: Int { return TimeStep.current.month - 1 }
  
  private let data: [Ratio]
  
  init(data: [Ratio]) {
    self.data = data
  }

  var ratio: Double {
    return self.data[index].ratio
  }
  
  static func withDefaults() -> GridDemand {
    return GridDemand(data:
      Array(repeatElement(Ratio(1), count: 12)))
  }  
}
