//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import BlackBoxModel
import Config
import Foundation
import Meteo

print("Solar Performance Calculator (build: \(dateString))")

let configPath = CommandLine.arguments.count > 1
  ? CommandLine.arguments[1]
  : FileManager.default.currentDirectoryPath

let meteoFilePath = CommandLine.arguments.count > 2
  ? CommandLine.arguments[2]
  : FileManager.default.currentDirectoryPath

let contents = try? FileManager.default
  .contentsOfDirectory(atPath: configPath)

let csv = contents?.filter { $0.hasSuffix("csv") }

let runs = csv?.compactMap { filename in
  return filename.split(separator: ".").first?
    .split(separator:"_").last?.integerValue
}

let lastRun = runs?.max() ?? 99

// BlackBoxModel.loadConfigurations(atPath: configPath, format: .json)
// BlackBoxModel.saveConfigurations(toPath: configPath)

Simulation.time.steps = .every5minutes
let location = Position(longitude: 47.73, latitude: 29, elevation: 0)
//BlackBoxModel.configure(location: location, year: 2005, timeZone: 2)
BlackBoxModel.configure(meteoFilePath: "/home/daniel/")

/*
SolarField.parameter.massFlow.max = 2500.0
Design.layout.powerBlock = 73
Design.layout.solarField = 98
Design.layout.heatExchanger = 98
*/

let df = DateFormatter()
df.timeZone = TimeZone(secondsFromGMT: 0)
df.dateFormat = "dd.MM.yyyy"
//Simulation.time.firstDateOfOperation = df.date(from: "02.01.2005")!
//Simulation.time.lastDateOfOperation = df.date(from: "04.01.2005")!

/*
let log = PerformanceDataRecorder(
  customNaming: "Result_\(lastRun + Int(1))"
)
*/
let log = PerformanceDataRecorder(mode: .none)
let result = BlackBoxModel.runModel(with: log)

print(result)

/*
let gp = GeneticParameters(populationSize: 8, numberOfGenerations: 8, mutationRate: 0.5)

let ga = GeneticAlgorithm(parameters: gp)

ga.simulateNGenerations()
*/
