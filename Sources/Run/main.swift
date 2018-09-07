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

typealias PC = PerformanceCalculator

let start = CFAbsoluteTimeGetCurrent()

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

// PC.loadConfigurations(atPath: path, format: .text)
// PC.saveConfigurations(toPath: path)
PC.meteoFilePath = meteoFilePath
PC.interval = .every5minutes

var log = PC.runModel(lastRun + 1, output: .brief)
print(log.description)
/*
log = goalSeek(\.thermal.production, greaterThen: 164000) {
 Design.layout.solarField += 1
}*/

let end = CFAbsoluteTimeGetCurrent()

print("Duration:", String(format: "%.2f sec", end - start))



