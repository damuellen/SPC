// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import Foundation
import Helpers

/// Creates a chart to represent time-series data using multiple y axis.
public final class TimeSeriesPlot {
  #if !os(iOS)
  let gnuplot: Process
  #endif
  /// Enumeration to specify the style of the time-series plot (steps or impulses).
  public enum Style: String { case steps, impulses }

  /// Array to hold the data for primary (y1) Y-axes.
  let y1: [[Double]]
  /// Array to hold the data for secondary (y2) Y-axes.
  let y2: [[Double]]
  
  /// The time range for the X-axis.
  let range: DateInterval

  /// Arrays to hold the titles of Y1 data series.
  public var y1Titles: [String]

  /// Arrays to hold the titles of Y2 data series.
  public var y2Titles: [String]
  
  /// Labels for Y1 axes.
  public var y1Label: String = ""

  /// Labels for Y2 axes.
  public var y2Label: String = ""

  /// Initializer to set up the TimeSeriesPlot with provided data and options.
  ///
  /// - Parameters:
  ///   - y1: The data for primary Y-axis (mandatory).
  ///   - y2: The data for secondary Y-axis (optional, default is empty array).
  ///   - range: The time range for the X-axis.
  ///   - yRange: Optional custom range for Y-axes (min, max) if not provided, auto-calculated.
  ///   - style: The style of the time-series plot (steps or impulses, default is steps).
  public init(y1: [[Double]], y2: [[Double]] = [], range: DateInterval, yRange: (Double, Double)? = nil, style: Style = .steps) {
    self.y1 = y1
    self.y2 = y2
    self.range = range
    self.y1Titles = Array(repeating: "", count: y1.count)
    self.y2Titles = Array(repeating: "", count: y2.count)

    // Frequency of data points.
    self.freq = Simulation.time.steps.interval
    // X-axis range (start and end timestamps).
    self.xr = (range.start.timeIntervalSince1970, range.end.timeIntervalSince1970)
    // Y-axis range (optional custom range or auto-calculated).
    if let yRange = yRange {
      self.yr = yRange
    } else {
      self.yr = (
        (y1.joined().max()! / 100).rounded(.up) * 100,
        (y2.joined().max()! / 100).rounded(.up) * 100
      )
    }
    // Style of the time-series plot (steps or impulses).
    self.style = style

    // Determine the format for X-axis labels based on the duration of the range.
    let secondsPerDay: Double = 86400
    if range.duration > secondsPerDay * 7 {
      self.x = (secondsPerDay, "'%d.%d'", "Date")
    } else if range.duration > secondsPerDay {
      self.x = (secondsPerDay, "'%a'", "Day")
    } else {
      self.x = (1800, "'%R'", "")
    }
    #if !os(iOS)
    gnuplot = Gnuplot.process()
    #endif
  }

  #if os(iOS)
  func plot(code: String) throws {}
  #else
  func plot(code: String) throws {
    // Check if the Gnuplot process is already running, and run it if not.
    if !gnuplot.isRunning { try gnuplot.run() }
    let stdin = gnuplot.standardInput as! Pipe
    // Write the Gnuplot script to the standard input of the process
    stdin.fileHandleForWriting.write(code.data(using: .utf8)!)
    #if !os(Linux)
    stdin.fileHandleForWriting.closeFile()
    #endif
  }
  #endif
  
  /// Main function to create the time-series chart and optionally save it to a file.
  ///
  /// - Parameter toFile: The file name to save the chart as a PNG image (optional).
  public func callAsFunction(toFile: String? = nil) throws {
    var code: String = ""
    if let file = toFile {
      // If a file name is provided, set the terminal output to PNG.
      code = """
        set terminal png size 1573,960 font 'Sans,9';
        set output '\(file).png'\n;
        """
    }
    // Concatenate Gnuplot settings, data block, plot function, and optional exit command.
    code += settings.concatenated + datablock + plot() + "\n"
    #if !os(Linux)
    code += "exit\n\n"
    #endif
    // Call the plot function to generate the chart using the constructed Gnuplot script.
    try plot(code: code)
  }

  private let xr: (start: Double, end: Double)
  private let yr: (Double, Double)
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
    "yrange [0:\(Int(yr.0))]",
    "y2range [0:\(Int(yr.1))]",
    "xtics \(x.tics)",
    "xtics rotate",
    "ytics nomirror 10",
    "ytics 100",
    "y2tics 100",
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
        return "$data i 0 u ($0*\(freq)+\(x)):\(i+1) t '\(y1Titles[i])' axes x1y2 with steps ls \(i+1)"
      }.joined(separator: ", ") + ", " + y2.indices.map { i in
        "$data i 1 u ($0*\(freq)+\(xr.start)):\(i+1) t '\(y2Titles[i])' axes x1y1 with steps ls \(i+1)"
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
