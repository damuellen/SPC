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
import DateExtensions
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
    name: [.customLong("long", withSingleDash: true)],
    help: "Longitude (decimal degrees, negative west of Greenwich meridion)")
  var longitude: Double?
  @Option(
    name: [.customLong("lat", withSingleDash: true)],
    help: "Latitude (decimal degrees)")
  var latitude: Double?
  @Option(
    name: [.customLong("ele", withSingleDash: true)],
    help: "Elevation (meters)")
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
  var meteofilePath: String = "COM/Midelt.mto"
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

    if true {
      print(ParameterSet())
      try JSONConfig.saveConfiguration(toPath: configPath)
      return
    }

    if let steps = stepsCalculation {
      Simulation.time.steps = Interval[steps]
    } else {
      Simulation.time.steps = .fiveMinutes
    }

    BlackBoxModel.configure(year: year ?? BlackBoxModel.yearOfSimulation)

    if let coords = location.coords,
     let tz = location.timezone {
      let loc = Location(coords, timezone: tz)
      BlackBoxModel.configure(location: loc)
    }

    let mode: Historian.Mode
    if let steps = outputValues {
      mode = .custom(interval: Interval[steps])
    } else if database {
      #if canImport(CSQLite)
      mode = .database
      #else
      mode = .csv
      #endif    
    } else {
      mode = .csv
    }

    let log = Historian(
      customName: nameResults, customPath: resultsPath, outputMode: mode
    )

    SolarPerformanceCalculator.result = BlackBoxModel.runModel(with: log)

    // plot(interval: DateInterval(ofWeek: 17, in: BlackBoxModel.yearOfSimulation))
    log.clearResults()
  }

  static var configuration = CommandConfiguration(
    commandName: "Solar Performance Calculator",
    abstract: "Simulates the performance of entire solar thermal power plants.",
    shouldPromptForMissing: true
  )

  func plot(interval: DateInterval) {
    let steamTurbine = SolarPerformanceCalculator.result.annual(\.steamTurbine.load.quotient)
    let parabolicElevation = SolarPerformanceCalculator.result.annual(\.collector.parabolicElevation)
    _ = try? Gnuplot(y1s: steamTurbine, y2s: parabolicElevation)(.pdf("parabolicElevation.pdf"))
    let electric = SolarPerformanceCalculator.result.annual(\.thermal.storage.megaWatt)
    _ = try? Gnuplot(y1s: steamTurbine, y2s: electric)(.pdf("thermal.pdf"))
    let formatter = DateFormatter()
    formatter.dateFormat = "MM_dd"
    for i in 1...365 {
      let interval = DateInterval(ofDay: i, in: BlackBoxModel.yearOfSimulation)
      let y1 = SolarPerformanceCalculator.result.massFlows(range: interval)
      let y2 = SolarPerformanceCalculator.result.power(range: interval)
      let plot = TimeSeriesPlot(y1: y1, y2: y2, range: interval, style: .impulses)
      plot.y1Titles = ["solarfield", "powerblock", "storage"]
      plot.y2Titles = ["solar", "toStorage", "production", "storage", "gross", "net", "consum"]
      
      try? plot(toFile: "/workspaces/SPC/res/Power_\(formatter.string(from: interval.start))")
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


let log = Historian(
  customNaming: "Result_\(lastRun + Int(1))"
)
*/
