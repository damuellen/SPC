//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import ArgumentParser
import BlackBoxModel
import Config
import Dispatch
import Foundation
import Meteo
import Helpers

#if os(Windows)
system("chcp 65001")
#endif

let start = DispatchTime.now().uptimeNanoseconds

SolarPerformanceCalculator.main()
//print(SolarPerformanceCalculator.result!)

let end = DispatchTime.now().uptimeNanoseconds
let time = String((end - start) / 1_000_000) +  " ms"
print("elapsed time:", time)

#if os(Windows)
  MessageBox(text: time, caption: "")
#endif

#if os(Windows)
system("pause")
#endif
struct LocationInfo: ParsableArguments {
  @Option(name: [.customShort("z"), .long], help: "Time zone")
  var timezone: Int?
  @Option(
    name: [.customLong("long")],
    help: "Longitude (decimal degrees, negative west of Greenwich meridion)")
  var longitude: Double?
  @Option(name: [.customLong("lat")], help: "Latitude (decimal degrees)")
  var latitude: Double?
  @Option(name: [.customLong("ele")], help: "Elevation (meters)")
  var elevation: Double?

  var coords: (long: Double, lat: Double, ele: Double)? {
    if let long = longitude, let lat = latitude, let ele = elevation {
      return (long, lat, ele)
    } else {
      return nil
    }
  }
}

struct SolarPerformanceCalculator: ParsableCommand {

  static var result: Recording!
#if os(Windows)
  static let cwd = currentDirectoryPath()
#else
  static let cwd = FileManager.default.currentDirectoryPath
#endif
  @Option(name: .shortAndLong, help: "The search path for meteofile.")
  var meteofilePath: String?
  @Option(name: .shortAndLong, help: "The search path for config files.")
  var configPath: String = cwd
  @Option(name: .shortAndLong, help: "Destination path for result files.")
  var resultsPath: String = cwd
  @Option(name: .shortAndLong, help: "Custom name, otherwise they are numbered with 3 digits.")
  var nameResults: String?
  @Option(name: .shortAndLong, help: "Year of simulation.")
  var year: Int?
  @OptionGroup()
  var location: LocationInfo
  @Option(name: .shortAndLong, help: "Calculation steps per hour.")
  var stepsCalculation: Int?
  @Option(name: .shortAndLong, help: "Values per hour output file.")
  var outputValues: Int?
  @Flag(help: "Output performance data to sqlite.")
  var database: Bool = false
  @Flag(help: "Output of the model parameter.")
  var parameter: Bool = false
  @Flag(help: "Output performance data to excel.")
  var excel: Bool = false
  @Flag(help: "Convert meteofile to binary format")
  var convert: Bool = false

  func run() throws {
    let name = "Solar Performance Calculator"
    print(decorated(name), "")

    let path = meteofilePath ?? configPath

    do { 
      try BlackBoxModel.configure(meteoFilePath: path, convert: convert) } catch {
#if os(Windows)
      if case MeteoDataFileError.fileNotFound = error {
        guard let path = FileDialog() else { return }
        do { 
          try BlackBoxModel.configure(meteoFilePath: path, convert: convert) } catch {
          MessageBox(text: (error as! MeteoDataFileError).description, caption: name)
          return
        }
      } else {
        MessageBox(text: (error as! MeteoDataFileError).description, caption: name)
        return
      }
#else
      fatalError((error as! MeteoDataFileError).description)
#endif
    }

    do {
      try BlackBoxModel.loadConfigurations(atPath: configPath, format: .text)
    } catch {
 #if os(Windows)
      if let message = (error as? TextConfigFile.ReadError)?.description {
        MessageBox(text: message, caption: name)
      }
      return
 #endif
    }

    if parameter {
      print(ParameterSet())
      try JSONConfig.saveConfiguration(toPath: configPath)
      return
    }

    if let steps = stepsCalculation {
      Simulation.time.steps = Interval[steps]
    } else {
      Simulation.time.steps = .every5minutes
    }

    BlackBoxModel.configure(year: year ?? BlackBoxModel.yearOfSimulation)

    if let coords = location.coords,
     let tz = location.timezone {
      let loc = Location(coords, timezone: tz)
      BlackBoxModel.configure(location: loc)
    }

    let mode: Recorder.Mode
    if let steps = outputValues {
      mode = .custom(interval: Interval[steps])
    } else if database {
      mode = .database
    } else if excel {
      mode = .excel
    } else {
      mode = .csv
    }

    let log = Recorder(
      customName: nameResults, customPath: resultsPath, outputMode: mode
    )

    SolarPerformanceCalculator.result = BlackBoxModel.runModel(with: log)
    //plot(interval: DateInterval(ofWeek: 17, in: BlackBoxModel.yearOfSimulation))
    log.clearResults()
  }

  static var configuration = CommandConfiguration(
    commandName: "Solar Performance Calculator",
    abstract: "Simulates the performance of entire solar thermal power plants."
  )

  func plot(interval: DateInterval) {
    do {
      let ys = SolarPerformanceCalculator.result.power(range: interval)
      let plot = TimeSeriesPlot(y1: ys.0, y2: ys.1, range: interval)
      plot.y1Titles = ["solar", "toStorage", "storage", "production"]
      plot.y2Titles = ["gross", "net", "consum"]
      try! plot(toFile: "power")
    }
    do {
      let ys = SolarPerformanceCalculator.result[\.collector.insolationAbsorber, range: interval]
      let plot = TimeSeriesPlot(y1: ys,range: interval)
      plot.y1Titles = ["MassFlow"]
      plot.y2Titles = ["T in", "T out"]
      try! plot(toFile: "insol")
    }
    do {
      let ys = SolarPerformanceCalculator.result.solarFieldHeader(range: interval)
      let plot = TimeSeriesPlot(y1: ys.0, y2: ys.1, range: interval, style: .impulses)
      plot.y1Titles = ["MassFlow"]
      plot.y2Titles = ["T in", "T out"]
      try! plot(toFile: "header")
    }
    do {
      let ys = SolarPerformanceCalculator.result[\.solarField.loops[0], range: interval]
      let plot = TimeSeriesPlot(y1: ys.0, y2: ys.1, range: interval, style: .impulses)
      plot.y1Titles = ["MassFlow"]
      plot.y2Titles = ["T in", "T out"]
      try! plot(toFile: "loop0")
    }
    do {
      let ys1 = SolarPerformanceCalculator.result.solarFieldHeader(range: interval)
      let ys2 = SolarPerformanceCalculator.result[\.solarField.loops[1], range: interval]
      let ys = (ys1.0 + ys2.0, ys1.1 + ys2.1)
      let plot = TimeSeriesPlot(y1: ys.0, y2: ys.1, range: interval, style: .impulses)
      plot.y1Titles = ["Header MassFlow", "Loop MassFlow"]
      plot.y2Titles = ["Header T in", "Header T out", "Loop T in", "Loop T out"]
     // try! plot(toFile: "loop1")
    }
    do {
      let ys = SolarPerformanceCalculator.result[\.solarField.loops[2], range: interval]
      let plot = TimeSeriesPlot(y1: ys.0, y2: ys.1, range: interval, style: .impulses)
      plot.y1Titles = ["MassFlow"]
      plot.y2Titles = ["T in", "T out"]
      try! plot(toFile: "loop2")
    }
    do {
      let ys = SolarPerformanceCalculator.result[\.solarField.loops[3], range: interval]
      let plot = TimeSeriesPlot(y1: ys.0, y2: ys.1, range: interval, style: .impulses)
      plot.y1Titles = ["MassFlow"]
      plot.y2Titles = ["T in", "T out"]
      try! plot(toFile: "loop3")
    }
  }
}
/*

SolarField.parameter.maxMassFlow.max = 2500.0
Design.layout.powerBlock = 73
Design.layout.solarField = 98
Design.layout.heatExchanger = 98

let gp = GeneticParameters(populationSize: 8, numberOfGenerations: 8, mutationRate: 0.5)

let ga = GeneticAlgorithm(parameters: gp)

ga.simulateNGenerations()

let df = DateFormatter()
df.timeZone = TimeZone(secondsFromGMT: 0)
df.dateFormat = "dd.MM.yyyy"
//Simulation.time.firstDateOfOperation = df.date(from: "02.01.2005")!
//Simulation.time.lastDateOfOperation = df.date(from: "04.01.2005")!


let log = Recorder(
  customNaming: "Result_\(lastRun + Int(1))"
)
*/
