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

public class TimeSeriesPlot {

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
    let secondsPerDay: Double = 86400
    if range.duration > secondsPerDay * 7 {
      self.x = (secondsPerDay, "'%d.%d'", "Date")
    } else if range.duration > secondsPerDay {
      self.x = (secondsPerDay, "'%a'", "Day")
    } else {
      self.x = (1800, "'%R'", "Hour")
    }
  }

  func plot(code: String) throws {
    let gnuplot = Process()
#if os(Windows)
    gnuplot.executableURL = .init(fileURLWithPath: "C:/bin/gnuplot.exe")
#else
    gnuplot.executableURL = .init(fileURLWithPath: "/usr/bin/gnuplot")
#endif
    gnuplot.standardInput = Pipe()
    gnuplot.standardOutput = Pipe()
    let stdin = gnuplot.standardInput as! Pipe
    try gnuplot.run()
    stdin.fileHandleForWriting.write(code.data(using: .utf8)!)
    stdin.fileHandleForWriting.closeFile()
  }

  public func callAsFunction(toFile: String? = nil) throws {
    var code: String = ""
    if let file = toFile {
      code = """
        set terminal pdfcairo size 17,12 enhanced;
        set output '\(file).pdf';
        set title '\(file)'\n;
        """
    }
    code += settings.concatenated + datablock + plot + ";exit\n\n"
    try plot(code: code)
  }

  private let xr: (start: Double, end: Double)
  private let x: (tics: Double, format: String, label: String)
  private let freq: Double
  private let style: Style

  var settings: [String] { [
    "grid", "key",
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
    "y2tics 10"
  ] }

  var plot: String {
    switch style {
    case .lines:
      return "\nplot " + y1.indices.map { i in
        "$data i 0 u ($0*\(freq)+\(xr.start)):\(i+1) t '\(y1Titles[i])' axes x1y1 with steps lw 3"
      }.joined(separator: ", ") + ", " + y2.indices.map { i in
        "$data i 1 u ($0*\(freq)+\(xr.start)):\(i+1) t '\(y2Titles[i])' axes x1y2 with steps lw 3"
      }.joined(separator: ", ")
    case .impulses:
      return "\nplot " + y1.indices.map { i in
        let x = (xr.start + (freq / Double(y1.count)) * Double(i))
        return "$data i 0 u ($0*\(freq)+\(x)):\(i+1) t '\(y1Titles[i])' axes x1y1 w i lw 3"
      }.joined(separator: ", ") + ", " + y2.indices.map { i in
        "$data i 1 u ($0*\(freq)+\(xr.start)):\(i+1) t '\(y2Titles[i])' axes x1y2 w steps lw 3"
      }.joined(separator: ", ")
    }
  }

  var datablock: String {
    guard let y1s = y1.first?.indices else { return "" }
    var data = "\n$data <<EOD\nHeader\n" 
    for y in y1s {
      data.append(y1.map { String($0[y]) }.joined(separator: ", ") + "\n")
    }
    data.append("\n\n")
    if let y2s = y2.first?.indices {
      for y in y2s {
        data.append(y2.map { String($0[y]) }.joined(separator: ", ") + "\n")
      }
    }
    data.append("EOD\n")
    return data
  }
}

extension Array where Element == String { 
  var concatenated: String { self.map { "set " + $0 + "\n" }.joined() }
}
