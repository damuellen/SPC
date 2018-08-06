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

let backgroundQueue = DispatchQueue(label: "serial.queue", qos: .utility)
let Log = Logger(logLevels: [.info, .error], writers: [ConsoleWriter()],
                 executionMethod: .asynchronous(queue: backgroundQueue))

let hourFraction = PerformanceCalculator.interval.fraction
let Fuelmode = OperationRestriction.FuelStrategy.strategy

var dniDay = 0.0

let fm = FileManager.default

public enum PerformanceCalculator {
  static var progress = Progress(totalUnitCount: 1)

  public static var interval: DateGenerator.Interval = .every5minutes

  static let year = 2019 // meteoDataSource.year ?? 2017
  static let timeZone = -(meteoDataSource.timeZone ?? 0)

  public static var meteoFilePath = fm.currentDirectoryPath

  static var meteoDataSource: MeteoDataSource = {
    do {
      let url = URL(fileURLWithPath: meteoFilePath)
      if !url.hasDirectoryPath {
        return try MeteoDataFileHandler(forReadingAtPath: meteoFilePath)
          .makeDataSource()
      } else if let path = try fm.subpathsOfDirectory(atPath: meteoFilePath)
        .first { $0.hasSuffix("mto") } {
        Log.infoMessage("Meteo file found in current working directory.")
        return try MeteoDataFileHandler(forReadingAtPath: path)
          .makeDataSource()
      } else {
        Log.errorMessage("Meteo file not found in current working directory.")
        fatalError("Meteo file is mandatory for calculation.")
      }
    } catch {
      print(error)
      fatalError("Meteo file is mandatory for calculation.")
    }
  }()

  public static func runModel(_ count: Int = 1,
                              output: PerformanceDataLoggerMode = .brief) {
    Plant.location = self.meteoDataSource.location

    let 🌞 = SolarPosition(
      location: meteoDataSource.location.doubles,
      year: year, timezone: timeZone, valuesPerHour: interval
    )

    let meteoDataGenerator = MeteoDataGenerator(
      from: meteoDataSource, interval: interval
    )

    let dates: DateGenerator
    if let start = Simulation.time.firstDateOfOperation,
      let end = Simulation.time.lastDateOfOperation {
      let range = DateInterval(start: start, end: end)
        .align(with: interval)
      meteoDataGenerator.setRange(range)
      dates = DateGenerator(range: range, interval: interval)
    } else {
      dates = DateGenerator(year: self.year, interval: self.interval)
    }

    let runProgress = Progress(
      totalUnitCount: 12, parent: progress, pendingUnitCount: 1
    )
    runProgress.becomeCurrent(withPendingUnitCount: 12)
    Log.infoMessage("\nThe calculation run \(count) started.\n")

    defer {
      runProgress.resignCurrent()
      Log.infoMessage("\nThe calculations have been completed.\n")
    }

    let results = PerformanceDataLogger(
      fileNameSuffix: "Run_\(count)", mode: output
    )
    results.dateFormatter = DateFormatter()

    defer {
      if case .full = output {
        try! Report.description.write(
          toFile: "Report_Run\(count).txt",
          atomically: true, encoding: .utf8
        )
      }
    }

    Plant.updateComponentsParameter()
    Maintenance.atDefaultTimeRange(for: self.year)

    var status = Plant.initialState

    for (meteo, date) in zip(meteoDataGenerator, dates) {
      TimeStep.current = .init(date)

      Plant.availability.set(calendar: TimeStep.current)

      Maintenance.isScheduled(at: date)

      runProgress.tracking(of: TimeStep.current.month)

      dniDay = meteoDataGenerator.sumDNI(ofDay: TimeStep.current.day)

      if let position = 🌞[date] {
        status.collector = Collector.tracking(sun: position)
        Collector.update(&status.collector, meteo: meteo)
      } else {
      }

      var timeRemain = 600.0
      SolarField.update(&status, timeRemain: timeRemain, meteo: meteo)
      timeRemain -= 600

      Plant.update(&status, at: TimeStep.current, fuel: &Availability.fuel, meteo: meteo)
      // debug(date, meteo, status)

      let (electricEnergy, electricalParasitics, thermal, fuelConsumption) =
        (Plant.electricEnergy, Plant.electricalParasitics, Plant.thermal, Plant.fuel)

      backgroundQueue.async {
        [date, meteo, status, electricEnergy, electricalParasitics, thermal, fuelConsumption] in
        results.append(
          date: date, meteo: meteo, electricEnergy: electricEnergy,
          electricalParasitics: electricalParasitics, thermal: thermal,
          fuelConsumption: fuelConsumption, status: status
        )
      }
    }

    backgroundQueue.sync {
      results.printResult()
    }
  }

  public static func loadConfigurations(atPath path: String,
                                        format: Config.Formats) {
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
