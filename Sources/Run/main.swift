//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import BlackBoxModel
import Config
import Foundation
import Meteo
import ArgumentParser

import Swifter
import Dispatch

struct LocationInfo: ParsableArguments {
  @Option(name: [.customShort("z"), .long], help: "Time zone")
  var timezone: Int?
  @Option(name: [.customLong("long")], help: "Longitude (decimal degrees, negative west of Greenwich meridion)")
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

  @Option(name: .shortAndLong, default: cwd, help: "The search path for meteofile.")
  var meteofilePath: String
  @Option(name: .shortAndLong, default: cwd, help: "The search path for config files.")
  var configPath: String
  @Option(name: .shortAndLong, default: cwd, help: "Destination path for result files.")
  var resultsPath: String
  @Option(name: .shortAndLong, help: "Custom name, otherwise they are numbered with 3 digits.")
  var nameResults: String?
  @Option(name: .shortAndLong, default: 2019, help: "Year of simulation.")
  var year: Int
  @OptionGroup()
  var location: LocationInfo 
  @Option(name: .shortAndLong, default: nil, help: "Calculation steps per hour.")
  var stepsCalculation: Int?
  @Option(name: .shortAndLong, default: nil, help: "Values per hour output file.")
  var outputValues: Int?
  @Flag(help: "All results are output to file.")
  var full: Bool

  func run() throws {  
    print("──────────────────────┤  Solar Performance Calculator   ├───────────────────────\n") 
    // BlackBoxModel.loadConfigurations(atPath: configPath, format: .json)
    // BlackBoxModel.saveConfigurations(toPath: configPath)
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

    BlackBoxModel.configure(meteoFilePath: "/Users/Daniel/Development/spc")

   // let mode: PerformanceDataRecorder.Mode = full ? .all : .brief
    let mode: PerformanceDataRecorder.Mode
    if let steps = outputValues {
      mode = .custom(interval: Interval[steps])
    } else {
      mode = .brief
    }
    let log = PerformanceDataRecorder(name: nameResults, path: resultsPath, output: mode)

    BlackBoxModel.runModel(with: log)
    
    SolarPerformanceCalculator.result = log.log
    
    log.printResult()  
/*
    let semaphore = DispatchSemaphore(value: 0)
	do {
	  try server.start(9080, forceIPv4: true)
	  print("Server has started ( port = \(try server.port()) ). Try to connect now...")
	//  system("x-www-browser http://localhost:9080")
	  semaphore.wait()
	} catch {
	  print("Server start error: \(error)")
	  semaphore.signal()
	}*/
  }

  static var configuration = CommandConfiguration(
    commandName: "Solar Performance Calculator",
    abstract: "Simulates the performance of entire solar thermal power plants."
  )
}
/*
let server = HttpServer()
let encoder = JSONEncoder()
let cases = JSONConfig.Name.allCases
let json = try cases.map(JSONConfig.generateJSON)

for (c, d) in zip(cases, json) {
  server["/json/\(c.rawValue)"] = { request in
    return HttpResponse.ok(.data(d))
  }
  server["/text/\(c.rawValue)"] = { request in
    return HttpResponse.ok(.text(c.description))
  }

  server.POST["/json/\(c.rawValue)"] = { request in
    do {
      try JSONConfig.loadConfiguration(c, data: Data(request.body))
      return HttpResponse.ok(.text(c.description))
    } catch {
      return HttpResponse.internalServerError
    }
  }
}

server["/text/BlackBoxModel"] = { request in
    return HttpResponse.ok(.text(SolarPerformanceCalculator.result.report))
  }


server["/day/:day.json"] = { request in
  if let day = Int(request.params.first!.value), 1...365 ~= day {    
    let array = SolarPerformanceCalculator.result[\.collector.insolationAbsorber, ofDay: day]
    return HttpResponse.ok(.json(["values":array]))
    } else {
      return HttpResponse.internalServerError
    }

}



SolarField.parameter.massFlow.max = 2500.0
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

SolarPerformanceCalculator.main()
