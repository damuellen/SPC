//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Config
import DateGenerator
import Foundation
import Meteo
import SolarPosition

let hourFraction = BlackBoxModel.interval.fraction
let Fuelmode = OperationRestriction.FuelStrategy.predefined

var dniDay = 0.0

public enum BlackBoxModel {
  
  public static var logger: PerformanceDataLogger?
  
  public static var sun: SolarPosition?
  
  public static var interval: DateGenerator.Interval = .every5minutes

  static let year = 2005 // meteoDataSource.year ?? 2005
  
  static let timeZone = -(meteoDataSource.timeZone ?? 0)

  public static var meteoFilePath = FileManager.default.currentDirectoryPath

  static var meteoDataSource: MeteoDataSource = {
    do {
      let url = URL(fileURLWithPath: meteoFilePath)
      if url.hasDirectoryPath == false {
        return try MeteoDataFileHandler(forReadingAtPath: meteoFilePath)
          .makeDataSource()
      } else if let path = try FileManager.default
        .subpathsOfDirectory(atPath: meteoFilePath)
        .first { $0.hasSuffix("mto") } {
        💬.infoMessage("Meteo file found in current working directory.")
        return try MeteoDataFileHandler(forReadingAtPath: path)
          .makeDataSource()
      } else {
        💬.errorMessage("Meteo file not found in current working directory.")
        fatalError("Meteo file is mandatory for calculation.")
      }
    } catch {
      print(error)
      fatalError("Meteo file is mandatory for calculation.")
    }
  }()

  static var progress = Progress(totalUnitCount: 1)

  public static func loadConfigurations(
    atPath path: String, format: Config.Formats)
  {
    do {
      switch format {
      case .json:
        try JsonConfigFileHandler.loadConfigurations(atPath: path)
      case .text:
        try TextConfigFileHandler.loadConfigurations(atPath: path)
      }
    } catch {
      print(error)
    }
  }
  
  public static func saveConfigurations(toPath path: String) {
    do {
      try JsonConfigFileHandler.saveConfigurations(toPath: path)
    } catch {
      print(error)
    }
  }
  
  @discardableResult
  public static func runModel(
    _ count: Int = 1, output: PerformanceDataLogger.Mode = .brief
    ) -> PerformanceDataLogger
  {
    let progress = Progress(
      totalUnitCount: 12, parent: self.progress, pendingUnitCount: 1
    )
    
    progress.becomeCurrent(withPendingUnitCount: 12)
    💬.infoMessage("\nThe calculation run \(count) started.\n")
    
    defer {
      progress.resignCurrent()
      💬.infoMessage("\nThe calculations have been completed.\n")
    }
    
    if let logger = logger {
      logger.reset()
    } else {
      logger = PerformanceDataLogger(
        fileNameSuffix: "Run_\(count)", mode: output
      )
    }
    
    defer {
      if case .full = output {
        try? logger!.log.report.write(toFile:
          "Report_Run\(count).txt", atomically: true, encoding: .utf8)
      }
    }
    
    Maintenance.setDefaultSchedule(for: year)
    
    Plant.setLocation(meteoDataSource.location)
    
    Plant.initializeComponents()
    
    if case .none = sun {
      sun = SolarPosition(location: Plant.location.coordinates,
                          year: year, timezone: timeZone, frequence: interval)
    }
    guard let 🌞 = sun else { preconditionFailure("We need the sun.") }
    
    let (🌦, 📅) = makeGenerators()
    
    Plant.run(progress: progress, dates: 📅, meteoData: 🌦, sun: 🌞)
    
    Plant.reset()
    
    backgroundQueue.sync { } // wait for background queue
    
    return logger!
  }

  private static func makeGenerators() -> (MeteoDataGenerator, DateGenerator) {
    let meteoDataGenerator = MeteoDataGenerator(
      meteoDataSource, frequence: interval
    )
    
    let dateGenerator: DateGenerator
    if let start = Simulation.time.firstDateOfOperation,
      let end = Simulation.time.lastDateOfOperation
    {
      let range = DateInterval(start: start, end: end).align(with: interval)
      meteoDataGenerator.setRange(range)
      dateGenerator = DateGenerator(range: range, interval: interval)
    } else {
      dateGenerator = DateGenerator(year: year, interval: interval)
    }
    return (meteoDataGenerator, dateGenerator)
  }
}
