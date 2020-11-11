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

public class PerformanceDataPlot {

  public enum Style: String {
    case lines, impulses
  }

  let y1: [[Double]]
  let y2: [[Double]]
  let range: DateInterval

  public var y1Titles: [String] {
    didSet {
      while y1.count - y1Titles.count > 0 { y1Titles.append("") }
    }
  }

  public var y2Titles: [String] {
    didSet {
      while y2.count - y2Titles.count > 0 { y2Titles.append("") }
    }
  }

  public var y1Label: String = ""
  public var y2Label: String = ""

  public init(y1: [[Double]], y2: [[Double]] = [], range: DateInterval, style: Style = .lines) {
    self.y1 = y1
    self.y2 = y2
    self.range = range
    self.y1Titles = Array(repeating: "", count: y1.count)
    self.y2Titles = Array(repeating: "", count: y2.count)

    self.freq = Simulation.time.steps.interval
    self.xr = (range.start.timeIntervalSince1970, range.end.timeIntervalSince1970)
    self.style = style

    if range.duration > 86400 * 7 {
      self.x = (86400, "'%d.%d'", "Month")
    } else if range.duration > 86400 {
      self.x = (86400, "'%a'", "Week")
    } else {
      self.x = (1800, "'%R'", "Day")
    }
  }

  func plot(code: String) throws {
    let inputPipe = Pipe()
    let inputFile = inputPipe.fileHandleForWriting
    let gnuplot = Process()
#if os(Windows)
    gnuplot.executableURL = .init(fileURLWithPath: "gnuplot.exe")
#else
    gnuplot.executableURL = .init(fileURLWithPath: "/usr/bin/gnuplot")
#endif
    gnuplot.arguments = ["-p", "-e", code]
    gnuplot.standardInput = inputPipe
    try gnuplot.run()
    inputFile.write(plotData.data(using: .utf8)!)
  }

  public func callAsFunction(toFile: String? = nil) throws {
    var code: String = ""
    if let file = toFile {
      code = """
        set terminal pdf size 36,20 enhanced color font 'Helvetica,14' lw 1;
        set output \"\(file).pdf\";
        set title '\(file)';
        """
    }
    code += setCommands + plotCommands
    try plot(code: code)
  }

  private let xr: (start: Double, end: Double)
  private let x: (tics: Double, format: String, label: String)
  private let freq: Double
  private let style: Style

  var setCommands: String {
    [
      "grid",
      "ylabel '\(y1Label)'",
      "y2label '\(y2Label)'",
      "xlabel '\(x.label)'",
      "style textbox opaque margins 1.0, 1.0 fc bgnd border lt -1 lw 1.0",
      "xdata time",
      "timefmt '%s'",
      "format x \(x.format)",
      "xrange [\(xr.start):\(xr.end)]",
      "xtics \(x.tics)",
      "xtics rotate",
      "autoscale",
      "autoscale y2",
      "ytics nomirror 50",
      "y2tics;",
    ].map { "set " + $0 }.joined(separator: ";")
  }

  var plotCommands: String {
    let plotCommands: [String]
    switch style {
    case .lines:
      plotCommands =
        ["plot '-' using ($0*\(freq)+\(xr.start)):1 t '\(y1Titles.first!)' axes x1y1 w l lw 2"]
        + y1.indices.dropFirst().map { i in
          "'' using ($0*\(freq)+\(xr.start)):1 t '\(y1Titles[i])' axes x1y1 with l lw 4"
        }
        + y2.indices.map { i in
          "'' using ($0*\(freq)+\(xr.start)):1 t '\(y2Titles[i])' axes x1y2 with l lw 4"
        }
    case .impulses:
      plotCommands =
        ["plot '-' using ($0*\(freq)+\(xr.start)):1 t '\(y1Titles.first!)' axes x1y1 w i lw 2"]
        + y1.indices.dropFirst().map { i in
          "'' using ($0*\(freq)+\(xr.start + (freq / Double(y1.count)) * Double(i))):1 t '\(y1Titles[i])' axes x1y1 w i lw 2"
        }
        + y2.indices.map { i in
          "'' using ($0*\(freq)+\(xr.start)):1 t '\(y2Titles[i])' axes x1y2 w l lw 2"
        }
    }
    return plotCommands.joined(separator: ",")
  }

  var plotData: String {
    y1.map { $0.map(\.description).joined(separator: "\n") }
      .joined(separator: "\ne\n") + "\ne\n"
      + y2.map { $0.map(\.description).joined(separator: "\n") }
      .joined(separator: "\ne\n") + "\ne\n"
  }
}
