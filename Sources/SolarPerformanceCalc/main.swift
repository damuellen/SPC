//
//  Copyright 2023 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import ArgumentParser
import SolarPosition
import BlackBoxModel
import DateExtensions
import Dispatch
import Foundation
import Meteo
import Helpers

#if os(Windows)
import WinSDK
_ = SetConsoleOutputCP(UINT(CP_UTF8))
#endif

SolarPerformanceCalculator.main()

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

  var coords: (longitude: Double, latitude: Double, elevation: Double)? {
    if let long = longitude, let lat = latitude, let ele = elevation {
      return (long, lat, ele)
    } else {
      return nil
    }
  }
}

struct SolarPerformanceCalculator: ParsableCommand {

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
  @Flag(help: "Print the model parameter. No calculation.")
  var parameter: Bool = false
  @Flag(help: "Save the model parameter in json file format.")
  var json: Bool = false
  @Flag(help: "Output performance data to excel.")
  var excel: Bool = false

  func run() throws {
    let now = Date()
    let name = "Solar Performance Calculator"
    print(decorated(name), "")
    var path: String! = nil
    do {
      path = try BlackBoxModel.loadConfiguration(atPath: configPath)
      if parameter { print(Parameters()); return }
      if json { try JSONConfig.saveConfiguration(toPath: configPath); return }
    } catch {
 #if os(Windows)
      if let message = (error as? TextConfigFile.ReadError)?.description {
        MessageBox(text: message, caption: name)
      } else {
        MessageBox(text: error.localizedDescription, caption: name)
      }
      return
 #endif
    }

    if let steps = stepsCalculation {
      Simulation.time.steps = Frequence[steps]
    } else {
      Simulation.time.steps = .fiveMinutes
    }
    
    do {
      if path == nil { path = meteofilePath ?? configPath }
      try BlackBoxModel.configure(meteoFilePath: path) } catch {
#if os(Windows)
      if case MeteoDataFileError.fileNotFound = error {
        guard let path = FileDialog() else { return }
        do {
          try BlackBoxModel.configure(meteoFilePath: path) } catch {
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

    BlackBoxModel.configure(year: year ?? BlackBoxModel.sun!.year)
    
    if let coords = location.coords,
     let tz = location.timezone {
      let location = Location(coords, tz: tz)
      BlackBoxModel.configure(location: location)
    }

    Maintenance.setDefaultSchedule(for: BlackBoxModel.simulatedYear)

    let mode: Historian.Mode
    if let steps = outputValues {
      if steps == 0 { 
        mode = .inMemory
      } else {
        mode = .custom(interval: Frequence[steps])
      }
    } else if database {
      if excel { print("Using both options at the same time is not supported.") }
      mode = .database 
    } else if excel {
      mode = .excel 
    } else {
      mode = .csv
    }

    let recording = Historian(
      customName: nameResults, customPath: resultsPath, outputMode: mode
    )

    let start = Date()

    BlackBoxModel.runModel(with: recording)

    let t = (start.timeIntervalSince(now), -start.timeIntervalSinceNow)

    let result = recording.finish()

    let t2 = -now.timeIntervalSinceNow
    print("Preparing:", String(format: "%.2f seconds", t.0))
    print("Computing:", String(format: "%.2f seconds", t.1))
    print("Wall time:", String(format: "%.2f seconds", t2))
    result.print()
  }

  static var configuration = CommandConfiguration(
    commandName: "Solar Performance Calculator",
    abstract: "Calculates the annual production of a solar thermal power plant."
  )

  func plot(_ result: Recording) {
    let steamTurbine = result.annual(\.steamTurbine.load.quotient)
    let parabolicElevation = result.annual(\.collector.parabolicElevation)
    _ = try? Gnuplot(y1s: steamTurbine, y2s: parabolicElevation)(.pdf("parabolicElevation.pdf"))
    let electric = result.annual(\.thermal.storage.megaWatt)
    _ = try? Gnuplot(y1s: steamTurbine, y2s: electric)(.pdf("thermal.pdf"))
    let formatter = DateFormatter()
    formatter.dateFormat = "MM_dd"
    for i in 1...365 {
      let interval = DateInterval(ofDay: i, in: BlackBoxModel.simulatedYear)
      let y1 = result.massFlows(range: interval)
      let y2 = result.power(range: interval)
      let plot = TimeSeriesPlot(y1: y1, y2: y2, range: interval, style: .impulses)
      plot.y1Titles = ["solarfield", "powerblock", "storage"]
      plot.y2Titles = ["solar", "toStorage", "production", "storage", "gross", "net", "consum"]
      
      try? plot(toFile: "/workspaces/SPC/res/Power_\(formatter.string(from: interval.start))")
    }
  }
}
