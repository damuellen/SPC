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
  
  public private(set) static var yearOfSimulation = 2005
  /// The apparent solar position based on date, time, and location.
  public private(set) static var sun: SolarPosition?
  /// Solar radiation and meteorological elements for a 1-year period.
  public private(set) static var meteoData: MeteoDataSource?
  
  public static func configure(year: Int)
  {
    yearOfSimulation = year    
  }

  public static func configure(location: Location)
  { 
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
  
  public static func configure(meteoFilePath: String? = nil)
  {
    let path = meteoFilePath ?? FileManager.default.currentDirectoryPath
    
    do {
      let handler = try MeteoDataFileHandler(forReadingAtPath: path)
      meteoData = try handler()
    } catch {
      fatalError("\(error) Meteo data is mandatory for calculation.")
    }    
    yearOfSimulation = meteoData!.year ?? yearOfSimulation
    if let sun = sun, let coords = meteoData?.location.coordinates,
    coords == sun.location.coords {
      return
    }
    sun = SolarPosition(
      coords: meteoData!.location.coordinates, tz: meteoData!.location.timezone,
      year: yearOfSimulation, frequence: Simulation.time.steps
    )
  } 

  public static func loadConfigurations(
    atPath path: String, format: Config.Formats = .json)
  {
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
  
  public static func saveConfigurations(toPath path: String)
  {
    do {
    //  try JsonConfigFileHandler.saveConfigurations(toPath: path)
    } catch {
      print(error)
    }
  }
  
  /// - Parameter recorder: Creates the log and write results to file.
  /// - Returns: The operating data collected by the recorder.
  /// - Attention: `configure()` must called before this.
  public static func runModel(with recorder: PerformanceDataRecorder) {

    guard let 🌞 = sun, let 🌤 = meteoData else {
      print("We need the sun."); exit(1)
    }
    
    Maintenance.setDefaultSchedule(for: yearOfSimulation)
    
    var status = Plant.initialState

    var plant = Plant.setup()

    let (🌦, 📅) = makeGenerators(dataSource: 🌤)

    for (meteo, date) in zip(🌦, 📅) {
 
      TimeStep.setCurrent(date: date)
      
      Maintenance.checkSchedule(date)

      if let position = 🌞[date] {
        status.collector = Collector.tracking(sun: position)
        
        Collector.efficiency(&status.collector, ws: meteo.windSpeed)

        status.collector.insolationAbsorber = Double(meteo.dni)
          * status.collector.cosTheta
          * status.collector.efficiency
      } else {
        status.collector = Collector.initialState
        TimeStep.current.isDaytime = false
      }

      let ambientTemperature = Temperature(celsius: Double(meteo.temperature))
      
      status.solarField.setInletTemperature(equalToOutlet: status.powerBlock)
      
      status.solarField.massFlow = SolarField.parameter.massFlow.max

      if GridDemand.current.ratio < 1 {
        Plant.adjustMassFlow(solarField: &status.solarField)
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
        if status.solarField.massFlow > SolarField.parameter.massFlow.max {
          status.solarField.massFlow = SolarField.parameter.massFlow.max
        }
      }
      
      var timeRemain = 600.0

      status.solarField.calculate(
        collector: status.collector,
        time: &timeRemain,
        dumping: &plant.heat.dumping.watt,
        ambient: ambientTemperature
      )
      
      status.solarField.temperature.outlet =
        status.solarField.heatLossesHotHeader(ambient: ambientTemperature)
      
      plant.electricalParasitics.solarField = status.solarField.parasitics()

      plant.calculate(&status, ambientTemperature: ambientTemperature)

      if Design.hasStorage {
        // Calculate the operating state of the salt
        plant.heat.storage.megaWatt = Storage.operate(
          storage: &status.storage,
          powerBlock: &status.powerBlock,
          steamTurbine: status.steamTurbine,
          thermal: plant.heat.storage.megaWatt
        )
      }
      
      let energy = plant.energyBalance()
      let ts = TimeStep.current
    //  print(TimeStep.current, date, status, energy)
      backgroundQueue.async { [status] in
        recorder.add(ts, meteo: meteo, status: status, energy: energy)
      }      
    }

    backgroundQueue.sync { } // wait for background queue
    recorder.complete()
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
