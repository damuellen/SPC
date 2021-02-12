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

public enum BlackBoxModel {

  public private(set) static var yearOfSimulation = 0
  /// The apparent solar position based on date, time, and location.
  public private(set) static var sun: SolarPosition?
  /// Solar radiation and meteorological elements for a 1-year period.
  public private(set) static var meteoData: MeteoDataSource?

  public static func configure(year: Int) {
    yearOfSimulation = year
  }

  public static func configure(location: Location) {
    if let sun = sun, sun.location.coords == location.coordinates {
      return
    }
    sun = SolarPosition(
      coords: location.coordinates, tz: location.timezone,
      year: yearOfSimulation, frequence: Simulation.time.steps
    )

    if meteoData == nil {
      meteoData = MeteoDataSource.generatedFrom(sun!)
    }
  }

  public static func configure(meteoFilePath: String? = nil) throws {
    let path = meteoFilePath ?? FileManager.default.currentDirectoryPath

    let handler = try MeteoDataFileHandler(forReadingAtPath: path)
    meteoData = try handler()

    yearOfSimulation = meteoData!.year ?? yearOfSimulation
    if let sun = sun, let coords = meteoData?.location.coordinates,
      coords == sun.location.coords
    {
      return
    }
    sun = SolarPosition(
      coords: meteoData!.location.coordinates,
      tz: meteoData!.location.timezone,
      year: yearOfSimulation,
      frequence: Simulation.time.steps
    )
  }

  public static func loadConfigurations(
    atPath path: String, format: ConfigFormat = .json
  ) throws {
    switch format {
    case .json:
      break//let urls = JSONConfig.fileSearch(atPath: path)
      //try JSONConfig.loadConfiguration(urls.first!)
    case .text:
      try TextConfig.loadConfigurations(atPath: path)
    }
  }

  /// - Parameter with: Creates the log and write results to file.
  /// - Attention: `configure()` must called before this.
  public static func runModel(with log: Recorder) -> Recording {

    guard let 🌞 = sun, let 🌤 = meteoData else {
      print("We need the sun.")
      exit(1)
    }

    Maintenance.setDefaultSchedule(for: yearOfSimulation)

    // Preparation of the plant parameters
    var plant = Plant.setup()
  
    // Set initial values
    var status = Plant.initialState

    let (🌦, 📅) = makeGenerators(dataSource: 🌤)

    for (meteo, date) in zip(🌦, 📅) {
      // Set the date for the calculation step
      DateTime.setCurrent(date: date)

      Maintenance.checkSchedule(date)

      if let position = 🌞[date] {
        // Only when the sun is above the horizon.
        status.collector = Collector.tracking(sun: position)  // cosTheta

        Collector.efficiency(&status.collector, ws: meteo.windSpeed)

        status.collector.insolationAbsorber =
          Double(meteo.dni)
          * status.collector.cosTheta
          * status.collector.efficiency.quotient
      } else {
        status.collector = Collector.initialState
        DateTime.setNight()
      }
      let dt = DateTime.current
#if DEBUG
      if DateTime.isSunRise {
      //  print(DateTime.current)
      }
      if DateTime.isSunSet {
      //  print(DateTime.current) 
      }
#endif
      // Used when calculating the heat losses and the efficiency
      let temperature = Temperature(meteo: meteo)

      // Setting the mass flow required by the power block in the solar field
      status.solarField.maxMassFlow = PowerBlock.requiredMassFlow()
      status.solarField.inletTemperature(outlet: status.powerBlock)
     
      if Design.hasStorage {
        // Increasing the mass flow allowed in the solar field
        status.solarField.requiredMassFlow(storage: status.storage)
        // Sets the temperature when the storage does freeze protection
        status.solarField.inletTemperature(storage: status.storage)
      }
      // Calculate outlet temperature and mass flow
      status.solarField.calculate(
        dumping: &plant.heatFlow.dumping.watt,
        collector: status.collector,
        ambient: temperature)

      if status.solarField.isOperating {
        // Calculate the heat losses in the hot header
        status.solarField.header.temperature.outlet =
          status.solarField.heatLossesHotHeader(ambient: temperature)
      }
      // Calculate power consumption of the pumps
      plant.electricalParasitics.solarField = status.solarField.parasitics()

      // Calculate the performance data of the plant
      plant.perform(&status, ambient: temperature)

      if Design.hasStorage {
        // Calculate the operating state of the salt
        status.storage.calculate(thermal: &plant.heatFlow, status.powerBlock)
        // Calculate the heat loss of the tanks
        status.storage.heatlosses()
      } 
      
      plant.electricity.consumption()
      
      let performance = plant.performance
#if DEBUG
 //  print(decorated(dt.description), status, performance)
 //  print()
#endif
      backgroundQueue.async { [status] in
        log(dt, meteo: meteo, status: status, energy: performance)
      }
    }

    backgroundQueue.sync {}  // wait for background queue
    return log.finish()
  }

  private static func makeGenerators(dataSource: MeteoDataSource)
    -> (MeteoDataGenerator, DateGenerator)
  {
    let interval = Simulation.time.steps

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
      dateGenerator = DateGenerator(year: yearOfSimulation, interval: interval)
    }
    return (meteoDataGenerator, dateGenerator)
  }
}
