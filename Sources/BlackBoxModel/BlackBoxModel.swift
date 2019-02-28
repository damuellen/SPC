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
        💬.infoMessage("Meteo file found in current working directory.\n")
        return try MeteoDataFileHandler(forReadingAtPath: path)
          .makeDataSource()
      } else {
        💬.errorMessage("Meteo file not found in current working directory.\n")
        fatalError("Meteo file is mandatory for calculation.")
      }
    } catch {
      print(error)
      fatalError("Meteo file is mandatory for calculation.")
    }
  }()

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
    with recorder: PerformanceDataRecorder,
    progress: Progress? = nil
    ) -> PerformanceLog
  {
    if progress != nil {
      progress!.becomeCurrent(withPendingUnitCount: 12)
    }
    
    defer {
      progress?.resignCurrent()
      if progress != nil {
        print("The calculations have been completed.              ")
      }
    }
    Maintenance.setDefaultSchedule(for: year)
    
    Plant.setLocation(meteoDataSource.location)

    if case .none = sun {
      sun = SolarPosition(location: Plant.location.coordinates,
                          year: year, timezone: timeZone, frequence: interval)
    }
    guard let 🌞 = sun else { preconditionFailure("We need the sun.") }

    Plant.setupComponentParameters()
    
    var status = Plant.initialState
    
    let (🌦, 📅) = makeGenerators()
    
    for (meteo, date) in zip(🌦, 📅) {
      
      TimeStep.setCurrent(date: date)
      
      Maintenance.checkSchedule(date)
      
      progress?.tracking(month: TimeStep.current.month)
      
      dniDay = 🌦.sumDNI(ofDay: TimeStep.current.day)
      
      Plant.setAmbientTemperature(meteo.temperature)
      
      if let position = 🌞[date] {
        status.collector = Collector.tracking(sun: position)
        Collector.efficiency(&status.collector, meteo: meteo)
      } else {
        status.collector = Collector.initialState
        TimeStep.current.isDayTime = false
      }
      
      Plant.updateSolarField(&status, meteo: meteo)
      
      Plant.updatePowerBlock(&status)
      
      let energy = Plant.energyFeed()
      
      backgroundQueue.async { [status] in
        recorder.add(date, meteo: meteo, status: status, energy: energy)
      }
    }
    
    backgroundQueue.sync { } // wait for background queue
    
    return recorder.log
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
