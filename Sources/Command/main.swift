//
//  Copyright (c) 2017 Daniel Müllenborn. All rights reserved.
//  Distributed under the The Non-Profit Open Software License version 3.0
//  http://opensource.org/licenses/NPOSL-3.0
//
//  This project is NOT free software. It is open source, you are allowed to
//  modify it (if you keep the license), but it may not be commercially
//  distributed other than under the conditions noted above.
//

import Foundation
import Config
import PerfomanceCalculation

let start = CFAbsoluteTimeGetCurrent()

let path = CommandLine.arguments.count > 1
  ? CommandLine.arguments[1]
  : FileManager.default.currentDirectoryPath

let meteoFilePath = CommandLine.arguments.count > 2
  ? CommandLine.arguments[2]
  : FileManager.default.currentDirectoryPath

PerformanceCalculator.loadConfigurations(atPath: path, format: .json)
//PerformanceCalculator.saveConfigurations(toPath: path)
PerformanceCalculator.meteoFilePath = meteoFilePath

for i in 1...2 {
  PerformanceCalculator.run(i)
 // Design.layout.solarField += 2
}

let end = CFAbsoluteTimeGetCurrent()

print("Duration:", String(format:"%.2f sec", end - start))
