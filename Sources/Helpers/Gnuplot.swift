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
  /// Execute the plot commands.
  @discardableResult public func plot(_ terminal: Terminal) throws -> String {
    let process = Gnuplot.process()
    let stdin = process.standardInput as! Pipe
    let style: String
    if case .svg = terminal {
      style = (settings + settingsSVG + userSettings).concatenated
    } else {
      style = (settings + settingsPDF + userSettings).concatenated
    }
    let command = userCommand ?? plot
    let code = terminal.output + style + datablock + command + ";exit\n\n"
    try process.run()
    stdin.fileHandleForWriting.write(code.data(using: .utf8)!)
    stdin.fileHandleForWriting.closeFile()
    if case .svg = terminal {
      let stdout = process.standardOutput as! Pipe
      let data = stdout.fileHandleForReading.readDataToEndOfFile()
      return String(decoding: data, as: Unicode.UTF8.self)
    }
    return terminal.output
  }

  let settings = [
    "style line 11 lt 1 lw 3 pt 7 ps 0.5 lc rgb '#0072bd'",
    "style line 12 lt 1 lw 3 pt 7 ps 0.5 lc rgb '#d95319'",
    "style line 13 lt 1 lw 3 pt 7 ps 0.5 lc rgb '#edb120'",
    "style line 14 lt 1 lw 3 pt 7 ps 0.5 lc rgb '#7e2f8e'",
    "style line 15 lt 1 lw 3 pt 7 ps 0.5 lc rgb '#77ac30'",
    "style line 21 lt 1 lw 3 pt 9 ps 0.8 lc rgb '#0072bd'",
    "style line 22 lt 1 lw 3 pt 9 ps 0.8 lc rgb '#d95319'",
    "style line 23 lt 1 lw 3 pt 9 ps 0.8 lc rgb '#edb120'",
    "style line 24 lt 1 lw 3 pt 9 ps 0.8 lc rgb '#7e2f8e'",
    "style line 25 lt 1 lw 3 pt 9 ps 0.8 lc rgb '#77ac30'",
    "style line 16 lt 1 lw 1 dashtype 3 lc rgb 'black'",
    "style line 17 lt 0 lw 0.5 lc rgb 'black'", "label textcolor rgb 'black'",
    "key top left tc ls 16"
  ]

  public var userSettings = [String]()
  public var userCommand: String? = nil

  let settingsSVG = ["border 31 lw 0.5 lc rgb 'black'", "grid ls 17"]
  let settingsPDF = ["border 31 lw 1 lc rgb 'black'", "grid ls 16"]

  static let temperatures = [
    "xtics 10", "ytics 10",
    "title 'T-Q' textcolor rgb 'black'",
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
      $data i 0 u 1:2:(sprintf("%d°C", $2)) with labels tc ls 16 offset char 3,0 notitle, \
      $data i 2 u 1:2:(sprintf("%d°C", $2)) with labels tc ls 16 offset char 3,0 notitle, \
      $data i 3 u 1:2:(sprintf("%d°C", $2)) with labels tc ls 16 offset char 3,0 notitle, \
      $data i 4 u 1:2:(sprintf("%d°C", $2)) with labels tc ls 16 offset char 3,0 notitle, \
      $data i 5 u 1:2:(sprintf("%d°C", $2)) with labels tc ls 16 offset char 3,0 notitle\n
    """
  }

  public init<T: FloatingPoint>(xys: [(T, T)]..., titles: String...) {
    let missingTitles = xys.count - titles.count
    var titles = titles
    if missingTitles > 0 {
      titles.append(contentsOf: repeatElement("-", count: missingTitles))
    }
    let data = zip(titles, xys).map { xy in 
      xy.0 + "\n" + xy.1.map { (x, y) in "\(x), \(y)" }.joined(separator: "\n")
    }.joined(separator: "\n\n\n")
    self.datablock = "\n$data <<EOD\n" + data + "\n\n\nEOD\n"
    self.plot =
      "\nplot " + xys.indices
      .map { i in "$data i \(i) u 1:2 w lp ls \(i+11) title columnheader(1)" }
      .joined(separator: ", ") + "\n"
  }

  public init<T: FloatingPoint>(xy1s: [(T, T)]..., xy2s: [(T, T)]..., titles: String...) {
    let missingTitles = xy1s.count + xy2s.count - titles.count
    var titles = titles
    if missingTitles > 0 {
      titles.append(contentsOf: repeatElement("-", count: missingTitles))
    }
    let y1 = zip(titles, xy1s).map { xy1 in
      xy1.0 + "\n" + xy1.1.map { (x, y) in "\(x), \(y)" }.joined(separator: "\n")
    }
    let y2 = zip(titles.dropFirst(xy1s.count), xy2s).map { xy2 in
      xy2.0 + "\n" + xy2.1.map { (x, y) in "\(x), \(y)" }.joined(separator: "\n")
    }
    self.datablock = "\n$data <<EOD\n" 
      + y1.joined(separator: "\n\n\n") + "\n\n\n"
      + y2.joined(separator: "\n\n\n") + "\n\n\nEOD\n"
    self.plot = "\nset ytics nomirror\nset y2tics\nplot "
      + xy1s.indices.map { i in
        "$data i \(i) u 1:2 axes x1y1 w lp ls \(i+11) title columnheader(1)"
      }.joined(separator: ", ") + ", "
      + xy2s.indices.map { i in let n = i + xy1s.endIndex
        return "$data i \(n) u 1:2 axes x1y2 w lp ls \(i+21) title columnheader(1)"
      }.joined(separator: ", ") + "\n"
  }

  public enum Terminal {
    case svg
    case pdf(path: String)
    case png(path: String)

    var output: String {
      #if os(Linux)
      let font = "font 'Times,14'"
      #else
      let font = "font 'Arial,14'"
      #endif
      switch self {
      case .svg: return "set term svg size 1280,800;set output\n"
      case .pdf(let path):
        return "set term pdfcairo size 10,7.1 enhanced \(font);set output '\(path)'\n"
      case .png(let path):
        return "set term pngcairo size 1680, 1050 enhanced \(font);set output '\(path)'\n"
      }
    }
  }
}

extension Array where Element == String {
  var concatenated: String { self.map { "set " + $0 + "\n" }.joined() }
}
