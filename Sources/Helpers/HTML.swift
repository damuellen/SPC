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
    let html = URL.temporaryFile().appendingPathExtension("html")
    try data.write(to: html)
    let path = html.path
    let wkhtmltopdf = Process()
    wkhtmltopdf.arguments = [
      "--quiet", "--print-media-type", "--disable-smart-shrinking",
      "-L", "0", "-R", "0", "-T", "0", "-B", "0",
      "-O", "Landscape", "--dpi", "600", path, name
    ]
#if os(Windows)
    wkhtmltopdf.executableURL = .init(fileURLWithPath: "C:/bin/wkhtmltopdf.exe")
#else
    wkhtmltopdf.executableURL = .init(fileURLWithPath: "/usr/local/bin/wkhtmltopdf")
#endif
    try wkhtmltopdf.run()
    wkhtmltopdf.waitUntilExit()
    try html.removeItem()
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
        margin-top: 1%;
        margin-left: 1%;
        margin-right: auto;
        padding-bottom: 2vh;
        height: 95vh;
        width: 98%;
        font-family: sans-serif;
        font-size: 1em;
      }
      tspan { font-family: sans-serif;}
      body { background-color: rgb(10,10,10);}
      @media (prefers-color-scheme: dark) {
        svg { filter: drop-shadow(3px 3px 3px rgb(255, 255, 255)); }
        body { background-image: radial-gradient(circle, rgb(40,40,40), rgb(10,10,10)); filter: invert(1); }
      }
    </style>
    """

  public var raw: String {
    let head = "<html lang=\"en\"><head>" + meta + style + "</head>\n"
    let click = "onclick=\"document.documentElement.requestFullscreen();\""
    let content = "<body \(click)>" + body + "</body>\n"
    let tail = "</html>\n"
    return type + head + content + tail
  }
}
