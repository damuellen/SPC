//
//  Copyright 2021 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import ArgumentParser
import Foundation
import Helpers
import PhysicalQuantities
import PinchPoint
import xlsxwriter

//system("clear")
PinchPointTool.main()

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
      pinchPoint.HTF = HELISOL_XLP
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

    if json {
      try! print(pinchPoint.encodeToJSON())
    } else {
      print(
        "\nLower HTF temperature:", pinchPoint.mixHTFTemperature,
        "\nTotal HTF massflow to HEX:", pinchPoint.mixHTFMassflow,
        "\nPower of PB:", pinchPoint.powerBlockPower
      )
    }

    guard pdf || html else { return }
    let plot = Gnuplot(temperatures: pinchPoint.temperatures())
    let svg = try plot(.svg)

    let dia = HeatBalanceDiagram(values: pinchPoint)

    if excel {
      let wb = Workbook(name: "pinchpoint.xlsx")
      defer { wb.close() }
      let _ = wb.addWorksheet()
    }

    if pdf {
      try plot(.pdf(path: "plot.pdf"))
      let html = HTML(body: dia.svg)
      try html.pdf(toFile: "diagram.pdf")
    }

    if html {
      var html = HTML(body: dia.svg + svg)
      if json {
        html.json = try pinchPoint.encodeToJSON()
      }
      #if DEBUG
        let path = "temp.html"
      #else
        let path = URL.temporaryFile().appendingPathExtension("html").path
      #endif
      try html.render().write(toFile: path, atomically: false, encoding: .utf8)
      print(path)
    }
  }
}
