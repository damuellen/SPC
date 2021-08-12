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

/// Create graphs using gnuplot.
public final class Gnuplot {
  let datablock: String
  let plot: String

  public init(data: String) {
    self.datablock = data
    self.plot = "plot $data"
  }

  public static func process() -> Process {
    let gnuplot = Process()
    #if os(Windows)
    gnuplot.executableURL = URL(fileURLWithPath: "C:/bin/gnuplot.exe")
    #elseif os(Linux)
    gnuplot.executableURL = .init(fileURLWithPath: "/usr/bin/gnuplot")
    #else
    gnuplot.executableURL = .init(fileURLWithPath: "/opt/homebrew/bin/gnuplot")
    #endif
    gnuplot.standardInput = Pipe()
    gnuplot.standardOutput = Pipe()
    return gnuplot
  }
  /// Execute and returns the plot commands.
  /// - Note: If the svg terminal is used, the function returns the svg.
  @discardableResult public func plot(_ terminal: Terminal) throws -> String {
    let process = Gnuplot.process()
    let stdin = process.standardInput as! Pipe
    let style: String
    if case .svg = terminal {
      style = (settings + SVG + userSettings).concatenated
    } else if case .pdf = terminal {
      style = (settings + PDF + userSettings).concatenated
    } else {
      style = (settings + PNG + SVG + userSettings).concatenated
    }
    let command = userCommand ?? plot
    let code = terminal.output + style + datablock + command + "exit\n\n"
    try process.run()
    stdin.fileHandleForWriting.write(code.data(using: .utf8)!)
    stdin.fileHandleForWriting.closeFile()
    if case .svg = terminal {
      let stdout = process.standardOutput as! Pipe
      let data = stdout.fileHandleForReading.readDataToEndOfFile()
      return String(decoding: data, as: Unicode.UTF8.self)
    }
    // try! code.write(toFile: "/workspaces/SPC/plt", atomically: false, encoding: .utf8)
    return code
  }

  let settings = [
    "style line 11 lt 1 lw 3 pt 7 ps 0.5 lc rgb '#0072bd'",
    "style line 12 lt 1 lw 3 pt 7 ps 0.5 lc rgb '#d95319'",
    "style line 13 lt 1 lw 3 pt 7 ps 0.5 lc rgb '#edb120'",
    "style line 14 lt 1 lw 3 pt 7 ps 0.5 lc rgb '#7e2f8e'",
    "style line 15 lt 1 lw 3 pt 7 ps 0.5 lc rgb '#77ac30'",
    "style line 16 lt 1 lw 3 pt 7 ps 0.5 lc rgb '#4dbeee'",
    "style line 17 lt 1 lw 3 pt 7 ps 0.5 lc rgb '#a2142f'",
    "style line 21 lt 1 lw 3 pt 9 ps 0.8 lc rgb '#0072bd'",
    "style line 22 lt 1 lw 3 pt 9 ps 0.8 lc rgb '#d95319'",
    "style line 23 lt 1 lw 3 pt 9 ps 0.8 lc rgb '#edb120'",
    "style line 24 lt 1 lw 3 pt 9 ps 0.8 lc rgb '#7e2f8e'",
    "style line 25 lt 1 lw 3 pt 9 ps 0.8 lc rgb '#77ac30'",
    "style line 26 lt 1 lw 3 pt 9 ps 0.8 lc rgb '#4dbeee'",
    "style line 27 lt 1 lw 3 pt 9 ps 0.8 lc rgb '#a2142f'",
    "style line 18 lt 1 lw 1 dashtype 3 lc rgb 'black'",
    "style line 19 lt 0 lw 0.5 lc rgb 'black'",
    "label textcolor rgb 'black'",
    "key above tc ls 18",
  ]

  public var userSettings = [String]()
  public var userCommand: String? = nil

  let SVG = ["border 31 lw 0.5 lc rgb 'black'", "grid ls 19"]
  let PDF = ["border 31 lw 1 lc rgb 'black'", "grid ls 18"]
  let PNG = [
    "object rectangle from graph 0,0 to graph 1,1 behind fillcolor rgb '#EBEBEB' fillstyle solid noborder"
  ]

  static let temperatures = [
    "xtics 10", "ytics 10",
    "xlabel 'Q̇ [MW]' textcolor rgb 'black'",
    "ylabel 'Temperatures [°C]' textcolor rgb 'black'",
  ]

  public init(temperatures: String) {
    self.userSettings = Gnuplot.temperatures
    self.datablock = "\n$data <<EOD\n" + temperatures + "\n\n\nEOD\n"
    self.plot = """
    \nplot $data i 0 u 1:2 w lp ls 11 title columnheader(1), \
      $data i 1 u 1:2 w lp ls 12 title columnheader(1), \
      $data i 2 u 1:2 w lp ls 13 title columnheader(1), \
      $data i 3 u 1:2 w lp ls 15 title columnheader(1), \
      $data i 4 u 1:2 w lp ls 14 title columnheader(1), \
      $data i 5 u 1:2 w lp ls 14 title columnheader(1), \
      $data i 0 u 1:2:(sprintf("%d°C", $2)) with labels tc ls 18 offset char 3,0 notitle, \
      $data i 2 u 1:2:(sprintf("%d°C", $2)) with labels tc ls 18 offset char 3,0 notitle, \
      $data i 3 u 1:2:(sprintf("%d°C", $2)) with labels tc ls 18 offset char 3,0 notitle, \
      $data i 4 u 1:2:(sprintf("%d°C", $2)) with labels tc ls 18 offset char 3,0 notitle, \
      $data i 5 u 1:2:(sprintf("%d°C", $2)) with labels tc ls 18 offset char 3,0 notitle\n
    """
  }

  public init<T: FloatingPoint>(xys: [(T, T)]..., titles: String..., smooth: Bool = false) {
    let missingTitles = xys.count - titles.count
    var titles = titles
    if missingTitles > 0 {
      titles.append(contentsOf: repeatElement("-", count: missingTitles))
    }
    let data = zip(titles, xys).map {
      $0.0 + "\n" + $0.1.map { (x, y) in "\(x), \(y)" }.joined(separator: "\n")
    }

    self.datablock = "\n$data <<EOD\n"
    + data.joined(separator: "\n\n\n") + "\n\n\nEOD\n"
    let s = smooth ? "smooth csplines" : ""
    let l = smooth ? "l" : "lp"
    self.plot = "\nplot " + xys.indices.map { i in
      "$data i \(i) u 1:2 \(s) w \(l) ls \(i+11) title columnheader(1)"
    }.joined(separator: ", ") + "\n"
  }

  public init<T: FloatingPoint>(
    xy1s: [(T, T)]..., xy2s: [(T, T)]..., titles: String..., smooth: Bool = false) {
    let missingTitles = xy1s.count + xy2s.count - titles.count
    var titles = titles
    if missingTitles > 0 {
      titles.append(contentsOf: repeatElement("-", count: missingTitles))
    }

    let y1 = zip(titles, xy1s).map {
      $0.0 + " ,\n" + $0.1.map { (x,y) in "\(x), \(y)" }.joined(separator: "\n")
    }
    let y2 = zip(titles.dropFirst(xy1s.count), xy2s).map {
      $0.0 + " ,\n" + $0.1.map { (x,y) in "\(x), \(y)" }.joined(separator: "\n")
    }

    self.datablock = "\n$data <<EOD\n"
      + y1.joined(separator: "\n\n\n") + "\n\n\n"
      + y2.joined(separator: "\n\n\n") + "\n\n\nEOD\n"
    let s = smooth ? "smooth csplines" : ""
    let l = smooth ? "l" : "lp"
    let t = "title columnheader(1)"
    self.plot = "\nset ytics nomirror\nset y2tics\nplot "
      + xy1s.indices.map { i in
        "$data i \(i) u 1:2 \(s) axes x1y1 w \(l) ls \(i+11) \(t)"
      }.joined(separator: ", ") + ", "
      + xy2s.indices.map { i in let n = i + xy1s.endIndex
        return "$data i \(n) u 1:2 \(s) axes x1y2 w \(l) ls \(i+21) \(t)"
      }.joined(separator: ", ") + "\n"
  }

  public enum Terminal {
    case svg
    case pdf(path: String)
    case png(path: String)
    case pngSmall(path: String)
    case pngLarge(path: String)
    var output: String {
      #if os(Linux)
      let font = "font 'Times,"
      #else
      let font = "font 'Arial,"
      #endif

      switch self {
      case .svg: return "set term svg size 1280,800;set output\n"
      case .pdf(let path):
        return "set term pdfcairo size 10,7.1 enhanced \(font)14';set output '\(path)'\n"
      case .png(let path):
        return "set term pngcairo size 1440, 900 enhanced \(font)12';set output '\(path)'\n"
      case .pngSmall(let path):
        return "set term pngcairo size 1024, 720 enhanced \(font)12';set output '\(path)'\n"
      case .pngLarge(let path):
        return "set term pngcairo size 1920, 1200 enhanced \(font)14';set output '\(path)'\n"
      }
    }
  }
}

extension Array where Element == String {
  var concatenated: String { self.map { "set " + $0 + "\n" }.joined() }
}

@inlinable public func solve(in range: ClosedRange<Double>, by: Double, f: (Double) -> Double) -> [(Double, Double)] {
  stride(from: range.lowerBound, through: range.upperBound, by: by).map{($0,f($0))}
}
