//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Libc
import Foundation

precedencegroup ExponentiationPrecedence {
  associativity: right
  higherThan: MultiplicationPrecedence
}

infix operator **: ExponentiationPrecedence
infix operator **=: AssignmentPrecedence

extension Double {
  static func ** (lhs: Double, rhs: Double) -> Double {
    return pow(lhs, rhs)
  }

  static func **= (lhs: inout Double, rhs: Double) {
    lhs = lhs ** rhs
  }
}

func * (lhs: String, rhs: String) -> String {
  var width = terminalWidth()
  width.clamp(to: 70...100)
  var c = width - lhs.count - rhs.count - 1
  c = c < 0 ? 1 : c
  return lhs + String(repeating: " ", count: c) + rhs + "\n"
}

infix operator |>

func |> <T, U>(value: T, function: ((T)-> U)) -> U {
    return function(value)
}

func terminalWidth() -> Int {
#if os(Windows)
  var csbi: CONSOLE_SCREEN_BUFFER_INFO = CONSOLE_SCREEN_BUFFER_INFO()
  if !GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &csbi) {
    return 80
  }
  return Int(csbi.srWindow.Right - csbi.srWindow.Left)
#else
  // Try to get from environment.
  if let columns = ProcessInfo.processInfo.environment["COLUMNS"],
   let width = Int(columns) {
    return width
  }
  var ws = winsize()
  if ioctl(1, UInt(TIOCGWINSZ), &ws) == 0 {
    return Int(ws.ws_col) - 1
  }
  return 80
#endif
}