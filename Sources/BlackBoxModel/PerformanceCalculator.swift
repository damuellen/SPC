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
import Willow

let backgroundQueue = DispatchQueue(label: "serial.queue")
let 💬 = Logger(logLevels: [.info, .error], writers: [ConsoleWriter()],
                executionMethod: .asynchronous(queue: backgroundQueue))

let hourFraction = PerformanceCalculator.interval.fraction
let Fuelmode = OperationRestriction.FuelStrategy.predefined

var dniDay = 0.0
var timeRemain = 600.0

public enum PerformanceCalculator {
  public static var logger: PerformanceDataLogger?
  public static var sun: SolarPosition?
  static var progress = Progress(totalUnitCount: 1)

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

  @discardableResult
  public static func runModel(
    _ count: Int = 1, output: PerformanceLogMode = .brief
    ) -> PerformanceLog
  {
    Plant.setLocation(self.meteoDataSource.location)

    let meteoDataGenerator = MeteoDataGenerator(
      meteoDataSource, frequence: interval
    )

    if case .none = sun {
      sun = SolarPosition(location: meteoDataSource.location.doubles,
                          year: year, timezone: timeZone, frequence: interval)
    }
    guard let 🌞 = sun else { preconditionFailure("We need the sun.") }

    let dates: DateGenerator
    if let start = Simulation.time.firstDateOfOperation,
      let end = Simulation.time.lastDateOfOperation
    {
      let range = DateInterval(start: start, end: end).align(with: interval)
      meteoDataGenerator.setRange(range)
      dates = DateGenerator(range: range, interval: interval)
    } else {
      dates = DateGenerator(year: year, interval: interval)
    }

    let runProgress = Progress(
      totalUnitCount: 12, parent: progress, pendingUnitCount: 1
    )
    runProgress.becomeCurrent(withPendingUnitCount: 12)
    💬.infoMessage("\nThe calculation run \(count) started.\n")

    defer {
      runProgress.resignCurrent()
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
        try? logger!.log.report.write(
          toFile: "Report_Run\(count).txt", atomically: true, encoding: .utf8)
      }
    }

    Plant.updateComponentsParameter()
    Maintenance.setDefaultSchedule(for: year)

    var status = Plant.initialState

    for (🌦, 📅) in zip(meteoDataGenerator, dates) {

      TimeStep.current = .init(📅)
      Maintenance.checkSchedule(📅)
      Plant.availability.set(calendar: TimeStep.current)

      runProgress.tracking(of: TimeStep.current.month)

      dniDay = meteoDataGenerator.sumDNI(ofDay: TimeStep.current.day)

      if let position = 🌞[📅] {
        status.collector = Collector.tracking(sun: position)
        Collector.update(&status.collector, meteo: 🌦)
      } else {
        TimeStep.current.isAtNight = true
      }

      Plant.electricalParasitics.solarField =
        SolarField.update(&status, timeRemain: timeRemain, meteo: 🌦)

      Plant.update(&status, fuel: Availability.fuel, meteo: 🌦)
      // debug(date, meteo, status)

      let (electricEnergy, parasitics, thermal, fuel) =
        (Plant.electric, Plant.electricalParasitics,
         Plant.thermal, Plant.fuelConsumption)

      backgroundQueue.async {
        [📅, 🌦, status, electricEnergy, parasitics, thermal, fuel] in
        logger!.append(
          date: 📅, meteo: 🌦, electricEnergy: electricEnergy,
          electricalParasitics: parasitics, thermal: thermal,
          fuelConsumption: fuel, status: status
        )
      }
    }
    Plant.reset()
    backgroundQueue.sync { } // wait for background queue
    return logger!.log
  }

  public static func loadConfigurations(atPath path: String, format: Config.Formats) {
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
}
