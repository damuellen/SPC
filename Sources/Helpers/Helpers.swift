//
//  Copyright 2021 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation
#if os(Windows)
import WinSDK
#endif
public func terminalWidth() -> Int {
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

public func openFile(atPath: String) {
#if os(Windows)
  try? Process.run(URL(fileURLWithPath: atPath), arguments: [])
#elseif os(macOS)
  try? Process.run(
    url: URL(fileURLWithPath: "/usr/bin/open"),
    arguments: [atPath]
  )
#endif
}
