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

public struct Gnuplot {
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
#else
    gnuplot.executableURL = .init(fileURLWithPath: "/usr/bin/gnuplot")
#endif
    gnuplot.standardInput = Pipe()
    gnuplot.standardOutput = Pipe()
    return gnuplot
  }

  public func plot(_ terminal: Terminal) throws -> String {
    let process = Gnuplot.process()
    let stdin = process.standardInput as! Pipe
    let code = terminal.output + settings.concatenated + datablock + plot + ";exit\n\n"
    try process.run()
    stdin.fileHandleForWriting.write(code.data(using: .utf8)!)
    stdin.fileHandleForWriting.closeFile()
    if case .svg = terminal {
      let stdout = process.standardOutput as! Pipe
      let data = stdout.fileHandleForReading.readDataToEndOfFile()
      return String(data: data, encoding: .utf8) ?? ""
    }
    return terminal.output
  }
  
  var settings = [
    "style line 11 lt 1 lw 3 pt 7 ps 0.5 lc rgb '#0072bd'",
    "style line 12 lt 1 lw 3 pt 7 ps 0.5 lc rgb '#d95319'",
    "style line 13 lt 1 lw 3 pt 7 ps 0.5 lc rgb '#edb120'",
    "style line 14 lt 1 lw 3 pt 7 ps 0.5 lc rgb '#7e2f8e'",
    "style line 15 lt 1 lw 3 pt 7 ps 0.5 lc rgb '#77ac30'",
    "style line 16 lt 0 lw 0.5 lc rgb 'black'",
    "style line 17 lt 1 lw 0.5 lc rgb 'black'",
    "border 31 lw 0.5 lc rgb'black'",
    "label textcolor rgb 'black'",
    "grid ls 16"
  ]

  static var temperatures = [
    "xtics 10",
    "ytics 10",
    "key top left tc ls 17",
    "title 'T-Q' textcolor rgb 'black'",
    "xlabel 'Q̇ [MW]' textcolor rgb 'black'",
    "ylabel 'Temperatures [°C]' textcolor rgb 'black'",
  ]

  public init(temperatures: String) {
    self.settings.append(contentsOf: Gnuplot.temperatures)
    self.datablock = "\n$data <<EOD\n" + temperatures + "EOD\n"
    self.plot = """
    \nplot $data i 0 u 1:2 w lp ls 11 title columnheader(1), \
      $data i 1 u 1:2 w lp ls 12 title columnheader(1), \
      $data i 2 u 1:2 w lp ls 13 title columnheader(1), \
      $data i 3 u 1:2 w lp ls 15 title columnheader(1), \
      $data i 4 u 1:2 w lp ls 14 title columnheader(1), \
      $data i 5 u 1:2 w lp ls 14 title columnheader(1), \
      $data i 0 u 1:2:(sprintf("%d°C", $2)) with labels tc ls 16 offset char 3,0 notitle , \
      $data i 2 u 1:2:(sprintf("%d°C", $2)) with labels tc ls 16 offset char 3,0 notitle, \
      $data i 3 u 1:2:(sprintf("%d°C", $2)) with labels tc ls 16 offset char 3,0 notitle, \
      $data i 4 u 1:2:(sprintf("%d°C", $2)) with labels tc ls 16 offset char 3,0 notitle, \
      $data i 5 u 1:2:(sprintf("%d°C", $2)) with labels tc ls 16 offset char 3,0 notitle\n
    """
  }

  public enum Terminal {
    case svg, pdf(path: String), png(path: String)

    var output: String {
      let font = "font 'Arial,16'"
      switch self {
        case .svg: 
        return "set term svg size 1280,800;set output\n"
        case .pdf(let path): 
        return "set term pdfcairo size 10,7.1 enhanced \(font);set output '\(path)'\n"
        case .png(let path): 
        return "set term pngcairo size 1280, 800 enhanced \(font);set output '\(path)'\n"
      }
    }
  }
}

extension Array where Element == String { 
  var concatenated: String { self.map { "set " + $0 + "\n" }.joined() }
}
