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

protocol PerformanceData {
  static var columns: [(name: String, unit: String)] { get }
  var values: [String] { get }
}

extension PerformanceData {
  var description: String {
    return zip(values, Self.columns).reduce("\n") { result, pair in
      let (value, desc) = pair
      if value.hasPrefix("0") { return result }
      return result + (desc.name >< (value + " " + desc.unit))
    }    
  }
}
