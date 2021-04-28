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

//system("clear")
PinchPointTool.main()

struct PinchPointTool: ParsableCommand {

  @Option(name: .long, help: "")
  var htfTemperature: Double = 393.0
  @Option(name: .long, help: "")
  var htfFluid: String = "ThVP1"
  @Option(name: .long, help: "")
  var hexCase: String = "2"
  @Argument(help: "")
  var steam: [Double] 
  @Flag
  var pdf: Bool = false
  @Flag
  var json: Bool = false

  func run() throws {
    let pressureDrop = HeatExchangerParameter.PressureDrop(
      economizer: 1.2,
      economizer_steamGenerator: 6.0,
      steamGenerator: 0.1,
      steamGenerator_superHeater: 0.2,
      superHeater: 0.5,
      superHeater_turbine: 1.5
    )

    let parameter = HeatExchangerParameter(
      temperatureDifferenceSteamGenerator: 3.0,
      temperatureDifferenceReheat: 29.1514, 
      steamQuality: 1.0,
      pressureDrop: pressureDrop
    )

    var pinchPoint = PinchPoint(parameter: parameter)

    pinchPoint()    

    if json {
      try! print(String(data: pinchPoint.encodeToJSONData(), encoding: .utf8)!)
      return
    }

    let sss: [HeatBalanceDiagram.Stream] = (0..<17).map { _ in
      return HeatBalanceDiagram.Stream(
        temperature: Temperature(celsius: Double.random(in: 300...400)),
        pressure: Double.random(in: 10...100),
        massFlow: Double.random(in: 300...1000),
        enthalpy: Double.random(in: 1000...3000)
      ) 
    }

    let plotter = Gnuplot(temperatures: pinchPoint.temperatures())
    let plot = try plotter.plot(.svg)

    let aaa = [("LMTD","1"),("LMTD","1"),("Blowdown","1"),("LMTD","1"),("LMTD","1")]
    let dia = HeatBalanceDiagram(streams: sss, singleValues: aaa)!
    let html1 = HTML(body: dia.svg + plot)
    

    if pdf {
      let html2 = HTML(body: dia.svg)
      try html2.pdf(toFile: "diagram.pdf")
      let _ = try plotter.plot(.pdf(path: "plot.pdf"))
    }

    let path = URL.temporaryFile().appendPathExtension("html").path
    try html1.raw.write(toFile: path, atomically: false, encoding: .utf8)
    print(path)
  //  try html2.raw.write(toFile: "diagram.html", atomically: false, encoding: .utf8)
  //  try html3.raw.write(toFile: "plot.html", atomically: false, encoding: .utf8)
  }
}
