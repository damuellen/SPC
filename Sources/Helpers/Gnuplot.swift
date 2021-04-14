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

public enum Gnuplot {

  private static func process() -> Process {
    let gnuplot = Process()
    gnuplot.standardInput = Pipe()
    gnuplot.standardOutput = Pipe()
  #if os(Windows)
    var exe = "gnuplot.exe".utf8CString
    exe.withUnsafeMutableBufferPointer {
      guard PathFindOnPathA($0.baseAddress, nil) else {
        fatalError("gnuplot is not installed on the system.") 
      }
    }
    gnuplot.executableURL = .init(fileURLWithPath: "gnuplot.exe")
  #else
    gnuplot.executableURL = .init(fileURLWithPath: "/usr/bin/gnuplot")
  #endif
    return gnuplot
  }

  public static func svg(commands: String) throws -> String {
    let process = Gnuplot.process()
    try process.run()
    let str = "set terminal svg size 1100,700 enhanced;" 
      + style + commands + ";exit\n"
    let stdin = process.standardInput as! Pipe
    stdin.fileHandleForWriting.write(str.data(using: .utf8)!)
    process.waitUntilExit()
    let stdout = process.standardOutput as! Pipe
    let data = stdout.fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: .utf8)!
  }

  public static func pdf(commands: String) throws -> Data {
    let process = Gnuplot.process()
    try process.run()
    let str = "set terminal pdfcairo size 10,7.1;" 
      + style + commands + ";exit\n"
    let stdin = process.standardInput as! Pipe
    stdin.fileHandleForWriting.write(str.data(using: .utf8)!)
    process.waitUntilExit()
    let stdout = process.standardOutput as! Pipe
    let data = stdout.fileHandleForReading.readDataToEndOfFile()
    return data
  }

  static var style = """
  afont = "Arial";
  text_color = "#000000";
  set style line 11 lt 1 lw 3 pt 7 ps 0.5 lc rgb '#0072bd'; # blue
  set style line 12 lt 1 lw 3 pt 7 ps 0.5 lc rgb '#d95319'; # orange
  set style line 13 lt 1 lw 3 pt 7 ps 0.5 lc rgb '#edb120'; # yellow
  set style line 14 lt 1 lw 3 pt 7 ps 0.5 lc rgb '#7e2f8e'; # purple
  set style line 15 lt 1 lw 3 pt 7 ps 0.5 lc rgb '#77ac30'; # green
  set style line 16 lt 0 lw 0.5 lc rgb text_color;
  set style line 17 lt 1 lw 0.5 lc rgb text_color;
  set border 31 lw 0.5 lc rgb text_color;
  set label textcolor rgb text_color font afont;
  set grid ls 16;
  """

  public static func temperatures(data: String) -> String {
    return  "$Data <<EOD\n" + data + "EOD\n" + """
    set xtics 10;
    set ytics 10;
    set key top left tc ls 17;
    set title "T-Q" textcolor rgb text_color font afont;
    set xlabel 'Power [MW]' textcolor rgb text_color font afont;
    set ylabel 'Temperatures [°C]' textcolor rgb text_color font afont;

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
