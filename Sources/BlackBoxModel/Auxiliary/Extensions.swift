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


/// Formats the given values and labels into a single string.
///
/// - Parameters:
///   - values: An array of Double values to format.
///   - labels: An array of corresponding String labels for each value.
/// - Returns: A formatted string with values and labels aligned.
public func formatting(_ values: [Double], _ labels: [String]) -> String {
  let pairs = zip(
    labels.map { "  " + $0.padding(30) },
    values.map { String(format: "%03.2f", $0) }
  )
  return pairs.map { $0.0 + $0.1 }.joined(separator: "\n")
}

extension String {
  /// Pads the string to the given length with spaces.
  ///
  /// - Parameter length: The total length of the padded string.
  /// - Returns: The padded string.
  func padding(_ length: Int) -> String {
    padding(toLength: length, withPad: " ", startingAt: 0)
  }
}

/// Generates a title with a border around it.
///
/// - Parameters:
///   - title: The title to be displayed.
///   - width: The width of the terminal or the desired width for the title (default is 80).
/// - Returns: A string with the title surrounded by a border.
public func decorated(_ title: String, width: Int = terminalWidth()) -> String {
  let width = median(80, width, 110)
  let half = (width - title.count - 8) / 2
  let line = String(repeating: "─", count: half)
  return line + "┤   " + title + "   ├" + line
}

/// A type representing an angle.
typealias Angle = Double

extension Angle {
  /// Converts the angle from degrees to radians.
  var toRadians: Double { self * .pi / 180 }
  /// Converts the angle from radians to degrees.
  var toDegrees: Double { self * (180 / .pi) }
}
