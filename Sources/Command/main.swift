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

print("Program started")

let timeBegin = CFAbsoluteTimeGetCurrent()

let path = FileManager.default.currentDirectoryPath

PerfomanceCalculator.loadConfigurations(atPath: path, format: .json)
//PerfomanceCalculator.meteoFilePath = "/Blythe.mto"
PerfomanceCalculator.run()

let timeEnd = CFAbsoluteTimeGetCurrent()

print("Duration:", String(format:"%.2f sec", timeEnd - timeBegin))
