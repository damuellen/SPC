//
//  Copyright 2023 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation 
import Helpers


func formatting(_ values: [Double], _ labels: [String]) -> String {
  let pairs = zip(    
    labels.map { "  " + $0.padding(30) },
    values.map { String(format: "%03.2f", $0) }
  )
  return pairs.map { $0.0 + $0.1 }.joined(separator: "\n")
}

extension String {
  func padding(_ length: Int) -> String {
    padding(toLength: length, withPad: " ", startingAt: 0)
  }
}

/// Generates the title with border
public func decorated(_ title: String, width: Int = terminalWidth()) -> String {
  let width = median(80, width, 110)
  let half = (width - title.count - 8) / 2
  let line = String(repeating: "─", count: half)
  return line + "┤   " + title + "   ├" + line
}

typealias Angle = Double

extension Angle {
  public var toRadians: Double { self * .pi / 180 }
  public var toDegrees: Double { self * (180 / .pi) }
}
