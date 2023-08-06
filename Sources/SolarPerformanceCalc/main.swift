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
  /// Responds to an HTTP request and generates an HTTP response containing a dynamic plot based on the provided request URI.
  ///
  /// - Parameters:
  ///   - request: The HTTP request received from the client, containing the request URI.
  /// - Returns: An HTTP response containing a dynamic plot and associated data for the specified URI.
  func respond(request: HTTP.Request) -> HTTP.Response {
    // Extract the URI from the request
    var uri = request.uri
    uri.remove(at: uri.startIndex)
    if uri.isEmpty { 
      return .init(html: HTML(body: "<pre>\(description)</pre>")) 
    }
    // Extract the day from the URI
    guard let day = Int(uri) else {
      return HTTP.Response(response: .BAD_REQUEST)
    }
    
    // Calculate y-axis ranges for the plot
    let year = DateInterval(ofYear: BlackBoxModel.simulatedYear)
    let yRange = (
      (massFlows(range: year).joined().max()! / 100).rounded(.up) * 110,
      (power(range: year).joined().max()! / 100).rounded(.up) * 110)
    
    let range = DateInterval(ofDay: day, in: BlackBoxModel.simulatedYear)
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
    guard let base64Image = try? plot.callAsFunction(toFile: "")?.base64EncodedString()
     else { return HTTP.Response(response: .SERVER_ERROR) }
    
    let icons = """
    <svg version="1.1" class="right" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 256 256" enable-background="new 0 0 256 256" xml:space="preserve"><g><g><path d="M184.5,234.2c-32.9-34.9-65.9-69.9-98.8-104.8c32.7-35.9,65.3-71.7,98-107.6c5.9-6.5-3.7-16.2-9.7-9.7c-34.2,37.5-68.3,75-102.5,112.5c-2.8,3-2.1,6.7-0.1,9.2c0.3,0.6,0.7,1.1,1.2,1.6c34.1,36.1,68.2,72.3,102.2,108.4C180.9,250.3,190.5,240.6,184.5,234.2z"/></g></g></svg>
    <svg version="1.1" class="left" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 256 256" enable-background="new 0 0 256 256" xml:space="preserve"><g><g><path d="M184.5,234.2c-32.9-34.9-65.9-69.9-98.8-104.8c32.7-35.9,65.3-71.7,98-107.6c5.9-6.5-3.7-16.2-9.7-9.7c-34.2,37.5-68.3,75-102.5,112.5c-2.8,3-2.1,6.7-0.1,9.2c0.3,0.6,0.7,1.1,1.2,1.6c34.1,36.1,68.2,72.3,102.2,108.4C180.9,250.3,190.5,240.6,184.5,234.2z"/></g></g></svg>
    """

    let script = """
    <script type="text/javascript">
        let currentWebsiteIndex = \(day);
        document.addEventListener('keydown', function(event) {
            if (event.key === 'ArrowLeft') {
                currentWebsiteIndex = (currentWebsiteIndex - 1 + 365) % 365;
                window.location.href = currentWebsiteIndex;
            } else if (event.key === 'ArrowRight') {
                currentWebsiteIndex = (currentWebsiteIndex + 1) % 365;
                window.location.href = currentWebsiteIndex;
            }
        });
        const left = document.getElementsByClassName("left")[0];
        const right = document.getElementsByClassName("right")[0];
        left.addEventListener("click", function(event) {
            currentWebsiteIndex = (currentWebsiteIndex - 1 + 365) % 365;
            window.location.href = currentWebsiteIndex;
        });
        right.addEventListener("click", function(event) {
            currentWebsiteIndex = (currentWebsiteIndex + 1) % 365;
            window.location.href = currentWebsiteIndex;
        });
    </script>
    <style>
    @media (prefers-color-scheme: dark) { table { color: white; } }
    table {
      font-family: monospace; 
      border-collapse: collapse; width: 1573px; table-layout: fixed;
    }
    th { border: 2px solid white; text-align: right; padding: 5px; }
    td { border: 2px solid white; text-align: left; padding: 5px; }
    svg.right {
      transform: scale(-1,1); width: 128px; position: absolute; top: 0; right: 0;
    }
    svg.left {
     width: 128px; position: absolute; top: 0; left: 0; 
    }
    svg:hover { fill: white; }
    </style>
    """
    
    // Calculate sums for the y2 values
    let s = Double(interval.rawValue)
    let sums = y2.map { $0.reduce(0,+) / s }.map(Int.init)
    
    // Create table data by combining sums and corresponding titles
    let table = zip(sums.map(\.description), p).map { "<th>" + $0.0 + "</th><td>" + $0.1 + "</td>" }.joined(separator: " ")

    // Create the HTML body with dynamic content based on the data and plot
    var body = #"<center><h1 style="color: white;">"#
    body += date
    body += #"</h1><img src="data:image/png;base64,"#
    body += base64Image + #""/><table><tr>"#
    body += table + #"</tr></table></center>"#
 
    // Return an HTTP response containing the generated HTML body
    return .init(html: .init(body: icons + script + body))
  }
}
