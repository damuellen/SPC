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

let HourFraction = BlackBoxModel.interval.fraction
let Fuelmode = OperationRestriction.FuelStrategy.predefined
let currentDirectoryPath = FileManager.default.currentDirectoryPath

public enum BlackBoxModel {
  
  public static var sun: SolarPosition?
  
  public static var interval: DateGenerator.Interval = .every5minutes

  static let year = 2005 // meteoDataSource.year ?? 2005
  
  public static var meteoFilePath: String = currentDirectoryPath {
    didSet { _meteoData = nil }
  }
  
  private static var _meteoData: MeteoDataSource?
  
  static var meteoData: MeteoDataSource {
    if _meteoData == nil {
      do { _meteoData = try makeMeteoDataSource() } catch {
        print(error)
        fatalError("Meteo file is mandatory for calculation.")
      }
    }
    return _meteoData!
  }
  
  private static func makeMeteoDataSource() throws -> MeteoDataSource {
    let url = URL(fileURLWithPath: meteoFilePath)
    if url.hasDirectoryPath == false {
      let filePath = url.path
      return try MeteoDataFileHandler(forReadingAtPath: filePath)
        .makeDataSource()
    }
    else if let fileName = try FileManager.default
      .contentsOfDirectory(atPath: meteoFilePath).first { item in
        item.hasSuffix("mto") || item.hasPrefix("TMY")
      }
    {
      let filePath = url.appendingPathComponent(fileName).path
      return try MeteoDataFileHandler(forReadingAtPath: filePath)
        .makeDataSource()
    } else {
      throw MeteoDataFileError.fileNotFound(meteoFilePath)
    }
  }

  public static func loadConfigurations(
    atPath path: String, format: Config.Formats = .json)
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
    progress: Progress? = nil)
    -> PerformanceLog
  {
    progress?.becomeCurrent(withPendingUnitCount: 12)
    
    defer { progress?.resignCurrent() }
    
    Plant.setLocation(meteoData.location)
    
    Plant.setupComponentParameters()
    
    if case .none = sun {
      sun = SolarPosition(
        location: Plant.location.coordinates, year: year,
        timezone: -(meteoData.timeZone ?? 0), frequence: interval)
    }
    guard let 🌞 = sun else { preconditionFailure("We need the sun.") }

    Maintenance.setDefaultSchedule(for: year)
    
    var status = Plant.initialState
    
    let (🌦, 📅) = makeGenerators(dataSource: meteoData)

    for (meteo, date) in zip(🌦, 📅) {
      
      TimeStep.setCurrent(date: date)
      
      Maintenance.checkSchedule(date)
      
      progress?.tracking(month: TimeStep.current.month)
      
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

  private static func makeGenerators(dataSource: MeteoDataSource)
    -> (MeteoDataGenerator, DateGenerator)
  {
    let meteoDataGenerator = MeteoDataGenerator(
      dataSource, frequence: interval
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
