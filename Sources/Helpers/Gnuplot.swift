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

public struct Gnuplot {
  let commands: String
  public init(commands: String) { self.commands = commands }

  private static func process() -> Process {
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

  public func svg() throws -> String {
    let process = Gnuplot.process()
    let term = "set terminal svg size 1100,700;\n"
    let stdin = process.standardInput as! Pipe
    let input = term + Gnuplot.style + commands + ";exit\ne"
    stdin.fileHandleForWriting.write(input.data(using: .utf8)!)
    stdin.fileHandleForWriting.closeFile()
    try process.run()
    let stdout = process.standardOutput as! Pipe
    let data = stdout.fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: .utf8) ?? ""
  }

  public func pdf(toFile: String) throws {
    let pdf = URL(fileURLWithPath: toFile)
    let process = Gnuplot.process()
    let term = "set terminal pdfcairo size 10,7.1 enhanced font 'Arial';\n"
    let output = "set output '\(pdf.path)';\n"
    let stdin = process.standardInput as! Pipe
    let input = term + output + Gnuplot.style + commands + ";exit\ne"
    stdin.fileHandleForWriting.write(input.data(using: .utf8)!)
    stdin.fileHandleForWriting.closeFile()
    try process.run()
  }

  static var style = """
  set style line 11 lt 1 lw 3 pt 7 ps 0.5 lc rgb '#0072bd';
  set style line 12 lt 1 lw 3 pt 7 ps 0.5 lc rgb '#d95319';
  set style line 13 lt 1 lw 3 pt 7 ps 0.5 lc rgb '#edb120';
  set style line 14 lt 1 lw 3 pt 7 ps 0.5 lc rgb '#7e2f8e';
  set style line 15 lt 1 lw 3 pt 7 ps 0.5 lc rgb '#77ac30';
  set style line 16 lt 0 lw 0.5 lc rgb 'black';
  set style line 17 lt 1 lw 0.5 lc rgb 'black';
  set border 31 lw 0.5 lc rgb'black';
  set label textcolor rgb 'black';
  set grid ls 16;
  """

  public static func temperatures(data: String) -> String {
    return  "$Data <<EOD\n" + data + "EOD\n" + """
    set xtics 10;
    set ytics 10;
    set key top left tc ls 17;
    set title "T-Q" textcolor rgb 'black';
    set xlabel 'Q̇ [MW]' textcolor rgb 'black';
    set ylabel 'Temperatures [°C]' textcolor rgb 'black';

    plot $Data i 0 u 1:2 w lp ls 11 title columnheader(1), \
      $Data i 1 u 1:2 w lp ls 12 title columnheader(1), \
      $Data i 2 u 1:2 w lp ls 13 title columnheader(1), \
      $Data i 3 u 1:2 w lp ls 15 title columnheader(1), \
      $Data i 4 u 1:2 w lp ls 14 title columnheader(1), \
      $Data i 5 u 1:2 w lp ls 14 title columnheader(1), \
      $Data i 0 u 1:2:(sprintf("%d °C", $2)) with labels tc ls 16 offset char 4,0 notitle , \
      $Data i 2 u 1:2:(sprintf("%d °C", $2)) with labels tc ls 16 offset char 4,0 notitle, \
      $Data i 3 u 1:2:(sprintf("%d °C", $2)) with labels tc ls 16 offset char 4,0 notitle, \
      $Data i 4 u 1:2:(sprintf("%d °C", $2)) with labels tc ls 16 offset char 4,0 notitle, \
      $Data i 5 u 1:2:(sprintf("%d °C", $2)) with labels tc ls 16 offset char 4,0 notitle
    """
  }
}
