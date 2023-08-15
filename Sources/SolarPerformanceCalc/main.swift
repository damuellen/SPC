// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import ArgumentParser
import SolarPosition
import BlackBoxModel
import DateExtensions
import Dispatch
import Foundation
import Meteo
import Helpers
import Web

let semaphore = DispatchSemaphore(value: 0)
let source = DispatchSource.interrupt(semaphore: semaphore)
#if os(Windows)
import WinSDK
_ = SetConsoleOutputCP(UINT(CP_UTF8))
SetConsoleCtrlHandler({_ in source.cancel();semaphore.wait();return WindowsBool(true)}, true)
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
  var configPath: String = cwd
  @Option(name: .shortAndLong, help: "Destination path for result files.")
  var pathForResult: String = cwd
  @Option(name: .shortAndLong, help: "Custom name, otherwise they are numbered with 2 digits.")
  var resultName: String?
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
  @Flag(help: "Save the model parameter in json file format.")
  var json: Bool = false
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
    var path: String! = nil
    do {
      path = try BlackBoxModel.loadConfiguration(atPath: configPath)
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

    if let s = stepsCalculation { Simulation.steps(perHour: s) }
    
    do {
      if path == nil { path = meteofilePath ?? configPath }
      try BlackBoxModel.configure(meteoFilePath: path) } catch {
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

    BlackBoxModel.configure(year: year ?? BlackBoxModel.sun!.year)
    
    if let coords = location.coords,
     let tz = location.timezone {
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

    let recording = Historian(name: resultName, path: pathForResult, mode: mode)

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
      print("web server listening on port \(server.port). Press Crtl+C to shut down.")
      start("http://127.0.0.1:\(server.port)")
      semaphore.wait()
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
    let interrupt = DispatchSource.interrupt(semaphore: semaphore)
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
      if interrupt.isCancelled { break }
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

extension Recording {
  /// Processes an HTTP request and generates an HTTP response with a dynamic HTML body.
  func respond(request: HTTP.Request) -> HTTP.Response {
    // Extract the URI from the request
    var uri = request.uri
    uri.remove(at: uri.startIndex)
    if uri.isEmpty { 
      return .init(html: HTML(body: "<pre>\(description)</pre>")) 
    }
    let imageRequested: Bool = uri.hasSuffix("png")
    if imageRequested { uri.removeLast(4) }
    
    // Extract the day from the URI
    guard var day = Int(uri) else {
      return HTTP.Response(response: .BAD_REQUEST)
    }
    if case 0..<365 = day { day += 1 } else {
      return HTTP.Response(response: .METHOD_NOT_ALLOWED)
    }
    let year = BlackBoxModel.simulatedYear
    // Calculate y-axis ranges for the plot
    let yRange = ((maxMassFlow / 100).rounded(.up) * 110, (maxHeatFlow / 100).rounded(.up) * 110)

    let range = DateInterval(ofDay: day, in: year)
    let date = DateTime(range.start).date
    Swift.print("\rGET request \(date)", terminator: "\u{001B}[?25l")
    fflush(stdout)
    // Retrieve mass flow and power data for the specified day
    let y1 = massFlows(range: range)
    let y2 = power(range: range)
    
    // Create a TimeSeriesPlot with the extracted data and specific plot configuration
    let plot = TimeSeriesPlot(y1: y1, y2: y2, range: range, yRange: yRange, style: .impulses)
    
    // Set y-axis titles for the plot
    plot.y1Titles = ["solarfield", "powerblock", "storage"]
    let p = ["solar", "production", "toStorage", "fromStorage", "gross", "net", "consum"]
    plot.y2Titles = p
    
    // Convert the plot to a base64-encoded image string
    guard let data = try? plot.callAsFunction(toFile: "") else { return .init(response: .SERVER_ERROR) }
    if imageRequested { return HTTP.Response(bodyData: data) }
    let base64PNG = data.base64EncodedString()
    // Create the HTML body with dynamic content based on the data and plot
    var body = "<div>\n\(icon("left"))<h1></h1>\n"
    body += #"<img id="image" alt="" width="1573" height="900" src="data:image/png;base64,"#
    body += base64PNG + "\"/>\n\(icon("right"))\n</div>"

    // Return an HTTP response containing the generated HTML body
    return .init(html: .init(body: body + stylesheets() + script(day, year: year)))
  }
}
