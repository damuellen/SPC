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
import BlackBoxModel
import Foundation
import Helpers

PinchPointTool.main()

struct PinchPointTool: ParsableCommand {

  @Option(name: .long, help: "Total number of loops")
  var htfTemperature: Double? // "SolarFieldModel.json"

  @Option(name: .long, help: "Input file name")
  var input: String? // "SolarFieldModel.json"

  func run() throws {

    if let input = input { }

    let _ = foo()

    let sss: [HeatBalanceDiagram.Stream] = (0..<17).map { _ in
      return HeatBalanceDiagram.Stream(
        temperature: Temperature(celsius: Double.random(in: 300...400)),
        pressure: Double.random(in: 10...100),
        massFlow: Double.random(in: 300...1000),
        enthalpy: Double.random(in: 1000...3000)
      ) 
    }

    let plotter = Gnuplot(temperatures: temperatures())
    let s = try plotter.plot(.svg)
    let _ = try plotter.plot(.pdf(path: "plot.pdf"))
    let aaa = [("LMTD","1"),("LMTD","1"),("Blowdown","1"),("LMTD","1"),("LMTD","1")]
    let dia = HeatBalanceDiagram(streams: sss, singleValues: aaa)
    let html1 = HTML(body: dia!.svg + s)
    let html2 = HTML(body: dia!.svg)
    let html3 = HTML(body: s)
    try html2.pdf(toFile: "diagram.pdf")
    try html1.raw.write(toFile: "all.html", atomically: false, encoding: .utf8)
    try html2.raw.write(toFile: "diagram.html", atomically: false, encoding: .utf8)
    try html3.raw.write(toFile: "plot.html", atomically: false, encoding: .utf8)
    openFile(atPath: "all.html")
  }
}
