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

let start = CFAbsoluteTimeGetCurrent()

print("Solar Performance Calculator (build: \(dateString))")

let currentDirectoryPath = FileManager.default.currentDirectoryPath

let configPath = CommandLine.arguments.count > 1
  ? CommandLine.arguments[1]
  : currentDirectoryPath

let meteoFilePath = CommandLine.arguments.count > 2
  ? CommandLine.arguments[2]
  : currentDirectoryPath

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
BlackBoxModel.meteoFilePath = meteoFilePath
BlackBoxModel.interval = .every5minutes
/*
SolarField.parameter.massFlow.max = 2500.0
Design.layout.powerBlock = 73
Design.layout.solarField = 98
Design.layout.heatExchanger = 98
*/

let log = PerformanceDataRecorder(
  customNaming: "Run_\(lastRun + Int(1))", mode: .brief
)

let result1 = BlackBoxModel.runModel(with: log, progress: Progress())

print(result1)

/*
let gp = GeneticParameters(populationSize: 8, numberOfGenerations: 8, mutationRate: 0.5)

let ga = GeneticAlgorithm(parameters: gp)

ga.simulateNGenerations()
*/
let end = CFAbsoluteTimeGetCurrent()

print("Duration:", String(format: "%.2f sec", end - start))
