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

public struct HTML {
  public func pdf(toFile name: String) throws {
    guard let data = raw.data(using: .utf8) else { return }
#if os(Windows)
    var exe = "wkhtmltopdf.exe".utf8CString
    exe.withUnsafeMutableBufferPointer {
      guard PathFindOnPathA($0.baseAddress, nil) else {
        print("wkhtmltopdf is not installed on the system.");return 
      }
    }
#else
    let exe = "/usr/local/bin/wkhtmltopdf"
#endif
    let wkhtmltopdf = Process()
    wkhtmltopdf.executableURL = .init(fileURLWithPath: exe)
    wkhtmltopdf.arguments = [
      "--quiet", "--print-media-type", "--disable-smart-shrinking",
      "-L", "0", "-R", "0", "-T", "0", "-B", "0",
      "-O", "Landscape", "--dpi", "600", "-",
      name
    ]
    let stdin = Pipe()
    wkhtmltopdf.standardInput = stdin
    stdin.fileHandleForWriting.write(data)
    try wkhtmltopdf.run()
  }

  public init(body: String) { self.body = body }

  public var body: String
  let type = "<!DOCTYPE html>\n"
  let meta = "<meta charset=\"utf-8\">\n"

  public var style = """
    <style media="print">
      svg {font-family: sans-serif;}
    </style>
    <style media="screen">
      svg {
        padding-bottom: 2vh;
        margin-left: 0.5cm; margin-right: auto; 
        height: 95vh; width: 95%; 
        font-family: 'Segoe UI', sans-serif;
        font-size: 1em;
      }
      tspan { font-family: 'Segoe UI', sans-serif;}
      body {background-color: #f7f7f7;}
      @media (prefers-color-scheme: dark) { body {background: #1C1C1C; filter: invert(1);}}
    </style>
    """

  public var raw: String {
    let head = "<html><head>" + meta + style + "</head>\n"   
    let content = "<body>" + body + "</body>\n"
    let tail = "</html>\n"
    return type + head + content + tail
  }
}
