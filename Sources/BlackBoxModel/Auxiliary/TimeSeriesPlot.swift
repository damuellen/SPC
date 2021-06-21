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
import Helpers

/// Creates a chart to represent time-series data using multiple y axis.
public final class TimeSeriesPlot {
  let gnuplot: Process
  public enum Style: String { case steps, impulses }

  let y1: [[Double]]
  let y2: [[Double]]
  let range: DateInterval

  public var y1Titles: [String]
  public var y2Titles: [String]
  public var y1Label: String = ""
  public var y2Label: String = ""

  public init(y1: [[Double]], y2: [[Double]] = [], range: DateInterval, style: Style = .steps) {
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
      self.x = (1800, "'%R'", "")
    }
    gnuplot = Gnuplot.process()
  }

  func plot(code: String) throws {
    let stdin = gnuplot.standardInput as! Pipe
    try gnuplot.run()
    stdin.fileHandleForWriting.write(code.data(using: .utf8)!)
    stdin.fileHandleForWriting.closeFile()
  }

  public func callAsFunction(toFile: String? = nil) throws {
    var code: String = ""
    if let file = toFile {
      code = """
        set terminal png size 1622,944;
        set output '\(file).png'\n;
        """
    }
    code += settings.concatenated + datablock + plot() + ";exit\n\n"
    try plot(code: code)
  }

  private let xr: (start: Double, end: Double)
  private let x: (tics: Double, format: String, label: String)
  private let freq: Double
  private let style: Style

  var settings: [String] { [
    "grid", "key above",
    "ylabel '\(y1Label)'",
    "y2label '\(y2Label)'",
    "xlabel '\(x.label)'",
    "object 1 rectangle from graph 0,0 to graph 1,1 behind fillcolor rgb '#EBEBEB' fillstyle solid noborder",
    // "object 2 rectangle from graph \(5.25/24),0 to graph \(16.75/24),1 behind fillcolor rgb '#DBDBDB' fillstyle solid noborder",
    "style textbox opaque margins 1.0, 1.0 fc bgnd border lt -1 lw 1.0",
    "xdata time",
    "timefmt '%s'",
    "format x \(x.format)",
    "xrange [\(xr.start):\(xr.end)]",
    "xtics \(x.tics)",
    "xtics rotate",
    "autoscale y2",
    "ytics nomirror 200",
    "y2tics 25",
    "style line 1 lt 1 lw 2 lc rgb '#FC8D62'",
    "style line 2 lt 1 lw 2 lc rgb '#8DA0CB'",
    "style line 3 lt 1 lw 2 lc rgb '#FFD92F'",
    "style line 4 lt 1 lw 2 lc rgb '#A6D854'",
    "style line 5 lt 1 lw 2 lc rgb '#E78AC3'",
    "style line 6 lt 1 lw 2 lc rgb '#E5C494'",
    "style line 11 lt 1 lw 2 lc rgb '#E41A1C'",
    "style line 12 lt 1 lw 2 lc rgb '#377EB8'",
    "style line 13 lt 1 lw 2 lc rgb '#498744'",
    "style line 14 lt 1 lw 2 lc rgb '#FF7F00'",
    "style line 15 lt 1 lw 2 lc rgb '#984EA3'",
    "style line 16 lt 1 lw 2 lc rgb '#784520'",
    "style line 17 lt 1 lw 2 lc rgb '#F781BF'",
  ] }

  func plot() -> String {
    switch style {
    case .impulses:
      return "\nplot " + y1.indices.map { i in
        "$data i 0 u ($0*\(freq)+\(xr.start)):\(i+1) t '\(y1Titles[i])' axes x1y1 with i ls \(i+1)"
      }.joined(separator: ", ") + ", " + y2.indices.map { i in
        "$data i 1 u ($0*\(freq)+\(xr.start)):\(i+1) t '\(y2Titles[i])' axes x1y2 with steps ls \(i+11)"
      }.joined(separator: ", ")
    case .steps:
      return "\nplot " + y1.indices.map { i in
        let x = (xr.start + (freq / Double(y1.count)) * Double(i))
        return "$data i 0 u ($0*\(freq)+\(x)):\(i+1) t '\(y1Titles[i])' axes x1y1 with steps ls \(i+1)"
      }.joined(separator: ", ") + ", " + y2.indices.map { i in
        "$data i 1 u ($0*\(freq)+\(xr.start)):\(i+1) t '\(y2Titles[i])' axes x1y2 with steps ls \(i+1)"
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
