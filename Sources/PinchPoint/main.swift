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
import PhysicalQuantities
import Foundation
import Helpers
import xlsxwriter

//system("clear")
PinchPointTool.main()

struct PinchPointTool: ParsableCommand {

  @Argument(help: "")
  var input: [Double] = []

  @Option(name: .customLong("htf", withSingleDash: true), help: "")
  var htfFluid: String = "ThVP1"

  @Option(name: .customLong("case", withSingleDash: true), help: "")
  var hexCase: String = "2"

  @Flag(name: .customLong("pdf", withSingleDash: true))
  var pdf: Bool = false

  @Flag(name: .customLong("json", withSingleDash: true))
  var json: Bool = false

  @Flag(name: .customLong("html", withSingleDash: true))
  var html: Bool = false

  @Flag(name: .customLong("excel", withSingleDash: true))
  var excel: Bool = false

  func run() throws {
    let pressureDrop = HeatExchangerParameter.PressureDrop(
      economizer: 1.0,
      economizer_steamGenerator: 0.2,
      steamGenerator: 0.55,
      steamGenerator_superHeater: 0.1,
      superHeater: 1.25,
      superHeater_turbine: 3.2
    )

    let parameter = HeatExchangerParameter(
      temperatureDifferenceHTF: 3.0,
      temperatureDifferenceWater: 3.0,
      steamQuality: 1.0,
      requiredLMTD: 20.0,
      pressureDrop: pressureDrop
    )

    var pinchPoint = PinchPoint(parameter: parameter)

    if input.count == 11, (input.min() ?? 0) > .zero {
      pinchPoint.economizerFeedwaterTemperature = Temperature(celsius: input[0])

      pinchPoint.ws = WaterSteam(
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
      print("Missing or invalid input value")
    }

    pinchPoint()

    if json {
      try! print(pinchPoint.encodeToJSON())
    }

    let plotter = Gnuplot(temperatures: pinchPoint.temperatures())
    let plot = try plotter.plot(.svg)

    let dia = HeatBalanceDiagram(values: pinchPoint)

    if excel {
      let wb = Workbook(name: "pinchpoint.xlsx")
      defer { wb.close() }
      let _ = wb.addWorksheet()
    }

    if pdf {
      let _ = try plotter.plot(.pdf(path: "plot.pdf"))
      let html = HTML(body: dia.svg)
      try html.pdf(toFile: "diagram.pdf")
    }

    if html {
      let html = HTML(body: dia.svg + plot)
#if DEBUG
      let path = "temp.html"
#else
      let path = URL.temporaryFile().appendingPathExtension("html").path
#endif
      try html.raw.write(toFile: path, atomically: false, encoding: .utf8)
      print(path)
    }
  }
}
