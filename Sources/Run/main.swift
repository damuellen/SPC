//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation
import Config
import Meteo
import BlackBoxModel


let start = CFAbsoluteTimeGetCurrent()

let path = CommandLine.arguments.count > 1
  ? CommandLine.arguments[1]
  : FileManager.default.currentDirectoryPath

let meteoFilePath = CommandLine.arguments.count > 2
  ? CommandLine.arguments[2]
  : FileManager.default.currentDirectoryPath

//PerformanceCalculator.loadConfigurations(atPath: path, format: .text)
//PerformanceCalculator.saveConfigurations(toPath: path)
PerformanceCalculator.meteoFilePath = meteoFilePath
PerformanceCalculator.interval = .every5minutes
let n = Int.random(in: 10000..<100000)
PerformanceCalculator.runModel(109)


let end = CFAbsoluteTimeGetCurrent()

print("Duration:", String(format:"%.2f sec", end - start))

//foo()

