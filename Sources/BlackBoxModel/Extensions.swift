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

public typealias Heat = Double
public typealias Pressure = Double
public typealias Angle = Double

public extension Double {
  var toKelvin: Double { return self - Temperature.absoluteZeroCelsius }
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
  func tracking(of month: Int) {
    let monthSymbol = monthSymbols[month - 1]
    let month = Int64(month)
    if month > completedUnitCount {
      completedUnitCount = month
      💬.infoMessage("The calculations for \(monthSymbol) are in progress.")
    }
  }
}

func debug(_ value: Any...) {
  value.forEach { value in
    print(value, terminator: "\n\n")
  }
  _ = readLine()
}

extension String {
  static var lineBreak: String { return "\n" }
  static var separator: String { return ", " }
}
