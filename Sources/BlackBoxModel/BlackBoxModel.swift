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
      coords: meteoData!.location.coordinates, tz: meteoData!.location.timezone,
      year: yearOfSimulation, frequence: Simulation.time.steps
    )
  }

  public static func loadConfigurations(
    atPath path: String, format: Config.Formats = .json
  ) {
    do {
      switch format {
      case .json:
        let urls = JSONConfig.fileSearch(atPath: path)
        try JSONConfig.loadConfigurations(urls)
      case .text:
        try TextConfig.loadConfigurations(atPath: path)
      }
    } catch {
      print(error)
    }
  }

  /// - Parameter recorder: Creates the log and write results to file.
  /// - Attention: `configure()` must called before this.
  public static func runModel(with recorder: PerformanceDataRecorder) -> PerformanceLog {

    guard let 🌞 = sun, let 🌤 = meteoData else {
      print("We need the sun.")
      exit(1)
    }

    Maintenance.setDefaultSchedule(for: yearOfSimulation)

    var status = Plant.initialState

    var plant = Plant.setup()

    let (🌦, 📅) = makeGenerators(dataSource: 🌤)

    for (meteo, date) in zip(🌦, 📅) {

      DateTime.setCurrent(date: date)

      Maintenance.checkSchedule(date)

      if let position = 🌞[date] {
        status.collector = Collector.tracking(sun: position)  // cosTheta

        Collector.efficiency(&status.collector, ws: meteo.windSpeed)

        status.collector.insolationAbsorber =
          Double(meteo.dni)
          * status.collector.cosTheta
          * status.collector.efficiency
      } else {
        status.collector = Collector.initialState
        DateTime.setNight()
      }

      //if DateTime.isSunRise { print(DateTime.current) }
      //if DateTime.isSunSet { print(DateTime.current) }

      let temperature = Temperature(meteo: meteo)

      status.solarField.inletTemperature(outlet: status.powerBlock)

      status.solarField.massFlow = SolarField.parameter.massFlow

      if GridDemand.current.ratio < 1 {
        Plant.adjustMassFlow(&status.solarField)
      }

      if Design.hasStorage {

        status.solarField.inletTemperature(
          storage: status.storage, heat: plant.heat
        )

        if status.storage.charge.ratio < Storage.parameter.chargeTo {
          status.solarField.massFlow += status.storage.massFlow
        } else if Design.hasGasTurbine {
          status.solarField.massFlow = HeatExchanger.parameter.sccHTFmassFlow
        }
        if status.solarField.massFlow > SolarField.parameter.massFlow {
          status.solarField.massFlow = SolarField.parameter.massFlow
        }
      }

      status.solarField.calculate(
        dumping: &plant.heat.dumping.watt,
        collector: status.collector,
        ambient: temperature)

      status.solarField.temperature.outlet =
        status.solarField.heatLossesHotHeader(ambient: temperature)

      plant.electricalParasitics.solarField = status.solarField.parasitics()

      plant.calculate(&status, ambient: temperature)

      if Design.hasStorage {        
        // Calculate the operating state of the salt
        status.storage.calculate(
          thermal: &plant.heat.storage.megaWatt,
          status.powerBlock)
        status.storage.heatlosses()

        if plant.heat.storage.megaWatt < 0 {
          if case .freezeProtection = status.storage.operationMode {
            // FIXME: powerBlock.temperature.outlet // = powerBlock.temperature.outlet
          } else if case .charging = status.storage.operationMode {
            // added to avoid Tmix during TES discharge (valid for indirect storage), check!
            let htf = SolarField.parameter.HTF
            status.powerBlock.temperature.outlet = htf.mixingTemperature(
              status.powerBlock, status.storage
            )
          }
        }
      }
      
      let energy = plant.energyBalance()
      let dt = DateTime.current
      //  print(DateTime.current, date, status, energy)
      backgroundQueue.async { [status] in
        recorder(dt, meteo: meteo, status: status, energy: energy)
      }
    }

    backgroundQueue.sync {}  // wait for background queue
    return recorder.finish()
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
