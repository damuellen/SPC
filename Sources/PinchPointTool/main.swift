// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import ArgumentParser
import Foundation
import Utilities
import Web
import PinchPoint
import xlsxwriter

PinchPointTool.main()

/// Command-line tool for calculating pinchpoint.
struct PinchPointTool: ParsableCommand {

  @Argument(help: "")
  var input: [Double] = []

  @Option(name: .customLong("htf", withSingleDash: true), help: "")
  var htfFluid: String = "ThVP1"

  @Option(name: .customLong("case", withSingleDash: true), help: "")
  var hexCase: Int = 2

  @Flag(name: .customLong("hex", withSingleDash: true), help: "")
  var hexValues: Bool = false

  @Flag(name: .customLong("pdf", withSingleDash: true))
  var pdf: Bool = false

  @Flag(name: .customLong("json", withSingleDash: true))
  var json: Bool = false

  @Flag(name: .customLong("html", withSingleDash: true))
  var html: Bool = false

  @Flag(name: .customLong("excel", withSingleDash: true))
  var excel: Bool = false

  /// The main function to run the pinch point calculator.
  func run() throws {
    var input = input
    let parameter: HeatExchangerParameter
    if hexValues {
      let values = Array(input.dropFirst(11))
      if let hex = HeatExchangerParameter(values: values) {
        input.removeLast(10)
        parameter = hex
      } else {
        fatalError("Invalid heat exchanger parameters.")
      }
    } else {
      switch hexCase {
      case 1: parameter = .case1
      case 2: parameter = .case2
      case 3: parameter = .case3
      default: fatalError("Invalid heat exchanger case.")
      }
    }

    var pinchPoint = PinchPoint.Calculation(parameter: parameter)

    if htfFluid == "Hel_XLP" {
      pinchPoint.HTF = HeatTransferFluid.XLP
    }

    if input.count == 11, (input.min() ?? 0) > .zero {
      pinchPoint.economizerFeedwaterTemperature = Temperature(celsius: input[0])

      pinchPoint.turbine = WaterSteam(
        temperature: Temperature(celsius: input[2]),
        pressure: input[3],
        massFlow: input[1]
      )

      pinchPoint.blowDownOfInputMassFlow = input[4]

      pinchPoint.reheatInlet = WaterSteam(
        temperature: Temperature(celsius: input[5]),
        pressure: input[6],
        massFlow: input[8],
        enthalpy: input[7]
      )

      pinchPoint.reheatOutletSteamPressure = input[9]

      pinchPoint.upperHTFTemperature = Temperature(celsius: input[10])
    } else {
      if !json {
        print("Missing or invalid input value. Fallback to default values.")
      }
    }

    pinchPoint()

    if excel {
      #if os(macOS)
      let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
      let path = cacheURL.appendingPathExtension("html").path
      #else
      let path = URL.temporaryFile().appendingPathExtension("xlsx").path
      #endif
      let wb = Workbook(name: path)
      defer { wb.close() }
      let _ = wb.addWorksheet()
      print(path)
      start(path)
    }

    // Generate plots and diagrams if requested in PDF or HTML format
    guard pdf || html else { 
      // Output results in JSON format, if requested
      if json {
        _ = try? print(pinchPoint.encodeToJSON())
      } else {
        print(
          "\nLower HTF temperature:", pinchPoint.mixHTFTemperature,
          "\nTotal HTF massflow to HEX:", pinchPoint.mixHTFMassflow,
          "\nPower of PB:", pinchPoint.powerBlockPower
        )
      }
      return 
    }
    let plot = Gnuplot(plotCommand: pinchPoint.temperatures())
    plot.settings.merge(
      ["encoding": "utf8",
      "xtics": "10", "ytics": "10",
      "xlabel": "'Q̇ [MW]' textcolor rgb 'black'",
      "ylabel": "'Temperatures [°C]' textcolor rgb 'black'"]
    ) { (_, new) in new }
    plot.plotCommands.append("""
      plot $data i 0 u 1:2 w lp ls 11 title columnheader(1), \
      $data i 1 u 1:2 w lp ls 12 title columnheader(1), \
      $data i 2 u 1:2 w lp ls 13 title columnheader(1), \
      $data i 3 u 1:2 w lp ls 15 title columnheader(1), \
      $data i 4 u 1:2 w lp ls 14 title columnheader(1), \
      $data i 5 u 1:2 w lp ls 14 title columnheader(1), \
      $data i 0 u 1:2:(sprintf("%d°C", $2)) with labels tc ls 18 offset char 3,0 notitle, \
      $data i 2 u 1:2:(sprintf("%d°C", $2)) with labels tc ls 18 offset char 3,0 notitle, \
      $data i 3 u 1:2:(sprintf("%d°C", $2)) with labels tc ls 18 offset char 3,0 notitle, \
      $data i 4 u 1:2:(sprintf("%d°C", $2)) with labels tc ls 18 offset char 3,0 notitle, \
      $data i 5 u 1:2:(sprintf("%d°C", $2)) with labels tc ls 18 offset char 3,0 notitle
      """)

    let svg = plot.svg(size: (1440, 900))!

    let dia = HeatBalanceDiagram(values: pinchPoint)

    let style = """
      <style media="print">
      svg.c {
        width: 28cm; height: 20cm; margin-left: 1cm;
      }
      </style>
      <style type="text/css">
      body { overflow: hidden; }
      svg.c {
        font-family: sans-serif; font-size: 17px;
        user-select: none; display: block;
      }
      </style>
      """

    if pdf {
      #if os(macOS)
      let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
      let path = cacheURL.appendingPathExtension("html").path
      #else
      let path = URL.temporaryFile().appendingPathExtension("html").path
      #endif
      let chart = path + "_chart.pdf"
      let diagram = path + "_diagram.pdf"
      try plot(.pdf(chart))
      let html = HTML(body: style + dia.svg)
      try html.pdf(toFile: diagram)
      if !json { print(chart, diagram)}
    }

    if html {
      var html = HTML(body: style + dia.svg + svg)
      if json {
        html.json = try pinchPoint.encodeToJSON()
      }
      #if DEBUG || os(macOS)
        let path = "temp.html"
      #else
        let path = URL.temporaryFile().appendingPathExtension("html").path
      #endif
      print(path)
      try html.description.write(toFile: path, atomically: false, encoding: .utf8)
      start(path)
    }
  }
}
