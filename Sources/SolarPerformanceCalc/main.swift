// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import ArgumentParser
import SolarPosition
import BlackBoxModel
import Dispatch
import Foundation
import Meteo
import Helpers
import Web

#if os(Windows)
import WinSDK
_ = SetConsoleOutputCP(UINT(CP_UTF8))
#else
let semaphore = DispatchSemaphore(value: 0)
let source = DispatchSource.interrupt(semaphore: semaphore)
#endif

SolarPerformanceCalculator.main()
/// Represents information about the location of plant.
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

  // Computed property to return the coordinates if all location information is available, otherwise nil.
  var coords: (longitude: Double, latitude: Double, elevation: Double)? {
    if let long = longitude, let lat = latitude, let ele = elevation {
      return (long, lat, ele)
    } else {
      return nil
    }
  }
}

/// Command-line tool for calculating solar performance.
struct SolarPerformanceCalculator: ParsableCommand {

#if os(Windows)
  static let cwd = currentDirectoryPath()
#else
  static let cwd = FileManager.default.currentDirectoryPath
#endif
  @Option(name: .shortAndLong, help: "The search path for meteofile.")
  var meteofilePath: String?
  @Option(name: .shortAndLong, help: "The search path for config files.")
  var configPath: String?
  @Option(name: .shortAndLong, help: "Destination path for result files.")
  var resultPath: String = cwd
  @Option(name: .shortAndLong, help: "Custom name, otherwise they are numbered with 2 digits.")
  var nameResult: String?
  @Option(name: .shortAndLong, help: "Year of simulation.")
  var year: Int?
  @OptionGroup()
  var location: LocationInfo
  @Option(name: .shortAndLong, help: "Calculation steps per hour.")
  var stepsCalculation: Int?
  @Option(name: .shortAndLong, help: "Values per hour output file.")
  var outputValues: Int?
  @Flag(help: "Output performance data as sqlite db.")
  var database: Bool = false
  @Flag(name: .shortAndLong, help: "Detail overview of the model parameter.")
  var verbose: Bool = false
  @Option(help: "Save the model parameter in json file format.")
  var jsonPath: String?
  @Flag(help: "Save the model parameter in individual files.")
  var split: Bool = false
  @Flag(help: "Output performance data as excel file.")
  var excel: Bool = false
  @Flag(help: "Open result file after calculation.")
  var open: Bool = false
  @Flag(help: "Use result to create time series charts with gnuplot.")
  var plot: Bool = false
  @Flag(name: .long, help: "Start web server for time series charts.")
  var http = false

  /// Main function to run the solar performance calculator.
  func run() throws {
    let now = Date()
    let name = "Solar Performance Calculator"
    print(decorated(name), "")

    var meteoFile: URL?
    do {      
      if let path = configPath {
        meteoFile = try BlackBoxModel.loadConfiguration(atPath: path)
      }
      if let path = meteofilePath { meteoFile = URL(fileURLWithPath: path) }
      if let path = jsonPath {
        try JSONConfig.write(toPath: path, split: split)
      }
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

    if let s = stepsCalculation { Simulation.steps(perHour: s) }
    
    do {
      guard let path = meteoFile?.path else {
        throw MeteoFileError.fileNotFound("Missing file name!")
      }
      try BlackBoxModel.configure(meteoFilePath: path) } catch {
#if os(Windows)
      if case MeteoFileError.fileNotFound = error {
        guard let path = FileDialog() else { return }
        do { try BlackBoxModel.configure(meteoFilePath: path) } catch {
          MessageBox(text: (error as! MeteoFileError).description, caption: name)
          return
        }
      } else {
        if let err = (error as? MeteoFileError) {
          MessageBox(text: err.description, caption: name)
        } else {
          let err = error as! NSError
          MessageBox(text: err.description, caption: name)
        }        
        return
      }
#else
      fatalError((error as! MeteoFileError).description)
#endif
    }
    if let year = year { BlackBoxModel.configure(year: year) }    
    
    if let coords = location.coords, let tz = location.timezone {
      let location = Location(coords, tz: tz)
      BlackBoxModel.configure(location: location)
    }

    Maintenance.setDefaultSchedule(for: BlackBoxModel.simulatedYear)

    let mode: Historian.Mode
    if let steps = outputValues {
      mode = steps == 0 ? .inMemory : .custom(interval: Frequence[steps])
    }
    else if database { mode = .database } 
    else if excel { mode = .excel }
    else { mode = .csv }

    let recording = Historian(name: nameResult, path: resultPath, mode: mode)

    let begin = Date()

    BlackBoxModel.runModel(with: recording)

    let t = (begin.timeIntervalSince(now), -begin.timeIntervalSinceNow)

    let result = recording.finish(open: open)

    let t2 = -now.timeIntervalSinceNow
    print("Preparing:", String(format: "%.2f seconds", t.0))
    print("Computing:", String(format: "%.2f seconds", t.1))
    print("Wall time:", String(format: "%.2f seconds", t2))
    result.print(verbose: verbose)

    if http {
      let server = HTTP(handler: result.respond)
      server.start()
#if os(Windows)
      start("http://127.0.0.1:\(server.port)")
      MessageBox(text: "Calculation completed. Check results.", caption: name)
#else
      print("web server listening on port \(server.port). Press Crtl+C to shut down.")
      semaphore.wait()
#endif
      server.stop()
      print("\u{001B}[?25h\u{001B}[2K", terminator: "\r")
      fflush(stdout)
    }
    if plot { plotter(result) }
  }

  static var configuration = CommandConfiguration(
    commandName: "Solar Performance Calculator",
    abstract: "Calculates the annual production of a solar thermal power plant."
  )

  /// Function to plot time series charts using gnuplot.
  func plotter(_ result: Recording) {
    #if !os(Windows)
    let interrupt = DispatchSource.interrupt(semaphore: semaphore)
    #endif
   // terminalHideCursor()
   // defer { terminalShowCursor(clearLine: interrupt.isCancelled) }
    // let steamTurbine = result.annual(\.steamTurbine.load.quotient)
    // let parabolicElevation = result.annual(\.collector.parabolicElevation)
    // _ = try? Gnuplot(y1s: steamTurbine, y2s: parabolicElevation)(.pdf("parabolicElevation.pdf"))
    // let electric = result.annual(\.thermal.storage.megaWatt)
    // _ = try? Gnuplot(y1s: steamTurbine, y2s: electric)(.pdf("thermal.pdf"))
    let year = DateInterval(ofYear: BlackBoxModel.simulatedYear)
    let yRange = (
      (result.massFlows(range: year).joined().max()! / 100).rounded(.up) * 100,
      (result.power(range: year).joined().max()! / 100).rounded(.up) * 100)
    for i in 1...365 {
      #if !os(Windows)
      if interrupt.isCancelled { break }
      #endif
     // print("Plotting [\(i)/365]".background(.white), terminator: "\r")
      fflush(stdout)
      let day = DateInterval(ofDay: i, in: BlackBoxModel.simulatedYear)
      let y1 = result.massFlows(range: day)
      let y2 = result.power(range: day)
      let plot = TimeSeriesPlot(y1: y1, y2: y2, range: day, yRange: yRange, style: .impulses)
      plot.y1Titles = ["solarfield", "powerblock", "storage"]
      plot.y2Titles = ["solar", "production", "toStorage", "fromStorage", "gross", "net", "consum"]
      try? FileManager.default.createDirectory(atPath: ".plots", withIntermediateDirectories: true)
      _ = try? plot(toFile: String(format: ".plots/day%03d", i))
    }
  }
}

extension DispatchSource {
  /// Create and configure a DispatchSource for handling SIGINT (interrupt signal).
  static func interrupt(semaphore: DispatchSemaphore) -> DispatchSourceSignal {
    let sig = DispatchSource.makeSignalSource(signal: SIGINT, queue: .global())
    signal(SIGINT, SIG_IGN)
    sig.setEventHandler { sig.cancel(); semaphore.signal() }
    sig.resume()
    return sig
  }
}


