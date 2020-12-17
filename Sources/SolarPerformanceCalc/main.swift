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

#if os(Windows)
system("chcp 65001")
#endif

let start = DispatchTime.now().uptimeNanoseconds

SolarPerformanceCalculator.main()
print(SolarPerformanceCalculator.result!.report)

let end = DispatchTime.now().uptimeNanoseconds
let time = String((end - start) / 1_000_000) +  " ms"
print("elapsed time:", time)

#if os(Windows)
  MessageBox(text: time, caption: "")
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

  static var result: PerformanceLog!

  static let cwd = FileManager.default.currentDirectoryPath

  @Option(name: .shortAndLong, help: "The search path for meteofile.")
  var meteofilePath: String?
  @Option(name: .shortAndLong, help: "The search path for config files.")
  var configPath: String = cwd
  @Option(name: .shortAndLong, help: "Destination path for result files.")
  var resultsPath: String = cwd
  @Option(name: .shortAndLong, help: "Custom name, otherwise they are numbered with 3 digits.")
  var nameResults: String?
  @Option(name: .shortAndLong, help: "Year of simulation.")
  var year: Int = 2019
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

  func run() throws {
    let name = "Solar Performance Calculator"
    print(decorated(name), "")
    
    let path = meteofilePath ?? configPath

    do { try BlackBoxModel.configure(meteoFilePath: path) } catch {
#if os(Windows)
      if case MeteoDataFileError.fileNotFound = error {
        guard let path = FileDialog() else { return }
        do { try BlackBoxModel.configure(meteoFilePath: path) } catch {
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
    } catch is TextConfigFile.ReadError {
 #if os(Windows)
      MessageBox(text: error.description, caption: name)
      return
 #endif
    }
    
    if parameter { 
      printParameter() 
      try JSONConfig.saveConfiguration(toPath: configPath)
      return
    }

    if let steps = stepsCalculation {
      Simulation.time.steps = Interval[steps]
    } else {
      Simulation.time.steps = .every5minutes
    }

    BlackBoxModel.configure(year: year)

    if let coords = location.coords {
      var loc = Location(coords)
      if let tz = location.timezone {
        loc.timezone = tz
        print(loc)
      }
      BlackBoxModel.configure(location: loc)
    }

    let mode: PerformanceDataRecorder.Mode
    if let steps = outputValues {
      mode = .custom(interval: Interval[steps])
    } else if database {
      mode = .database
    } else {
      mode = .csv
    }

    let log = PerformanceDataRecorder(name: nameResults, path: resultsPath, output: mode)

    SolarPerformanceCalculator.result = BlackBoxModel.runModel(with: log)

    log.printResult()
    log.clearResults()
  }

  static var configuration = CommandConfiguration(
    commandName: "Solar Performance Calculator",
    abstract: "Simulates the performance of entire solar thermal power plants."
  )

  func printParameter() {    
    print(
      Simulation.parameter,
      SolarField.parameter,
      Collector.parameter,
      Heater.parameter,
      HeatTransferFluid.parameter,
      HeatExchanger.parameter,
      Boiler.parameter,
      WasteHeatRecovery.parameter,
      GasTurbine.parameter,
      SteamTurbine.parameter,
      PowerBlock.parameter,
      Storage.parameter,
      separator: "\n"
    )
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


let log = PerformanceDataRecorder(
  customNaming: "Result_\(lastRun + Int(1))"
)
*/