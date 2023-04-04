//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import DateExtensions
import Utilities
import Foundation
import Meteo
import SolarPosition

public enum BlackBoxModel {

  public private(set) static var yearOfSimulation = 2019
  /// The apparent solar position based on date, time, and location.
  public private(set) static var sun: SolarPosition?
  /// Solar radiation and meteorological elements for a 1-year period.
  public private(set) static var meteoData: [MeteoData] = []

  public static func configure(year: Int) {
    if yearOfSimulation != year, Simulation.time.dateInterval != nil {
      Simulation.time.dateInterval!.start = Greenwich.date(
        byAdding: .year, value: year - yearOfSimulation,
        to: Simulation.time.dateInterval!.start)!
      yearOfSimulation = year
    }
    if let sun = BlackBoxModel.sun, yearOfSimulation != sun.year {
      BlackBoxModel.sun = SolarPosition(
        coords: sun.location.coordinates, tz: sun.location.timezone,
        year: yearOfSimulation, frequence: Simulation.time.steps
      )
    }
  }

  public static func configure(location: Location) {
    if let sun = sun, sun.location == location {
      return
    }
    // Calculate sun angles for location
    sun = SolarPosition(
      coords: location.coordinates, tz: location.timezone,
      year: yearOfSimulation, frequence: Simulation.time.steps
    )

    if meteoData.isEmpty {
      meteoData = MeteoData.using(sun!, model: .special, clouds: false)
    }
  }

  public static func configure(meteoFilePath: String? = nil) throws {
    let path = meteoFilePath ?? FileManager.default.currentDirectoryPath
    // Search for the meteo data file
    let handler = try MeteoDataFileHandler(forReadingAtPath: path)
    handler.interpolation = false
    // Read the content meteo data file
    meteoData = try handler.data(valuesPerHour: Simulation.time.steps.rawValue)

    let metaData = try handler.metaData()

    // Check if the sun angles for the location have already been calculated
    if let sun = sun, metaData.location == sun.location { return }

    // Calculate sun angles for location
    sun = SolarPosition(
      coords: metaData.location.coordinates,
      tz: metaData.location.timezone,
      year: metaData.year,
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
  public static func runModel(with recorder: Historian) -> Recording {

    guard let 🌞 = sun else {
      print("We need the sun.")
      exit(1)
    }

    // Preparation of the plant parameters
    var plant = Plant.setup()

    // Set initial values
    var status = Plant.initialState
    
    // PV system setup
    let pv = PV()

    var conditions = [(Temperature, Double, Double)]()

    for (meteo, date) in simulationPeriod(.hour) {
      DateTime.setCurrent(date: date)
      let dt = DateTime.current
      let (temperature, wind) = 
        (Temperature(celsius: Double(meteo.temperature)), Double(meteo.windSpeed))
      if let position = 🌞[date] {
        let panel = singleAxisTracker(
          apparentZenith: position.zenith,
          apparentAzimuth: position.azimuth,
          maxAngle: 55, GCR: 0.444
        )
        conditions.append((temperature, wind,
          Insolation.effective(
            ghi: Double(meteo.dni), dhi: Double(meteo.dni),
            surfTilt: panel.surfTilt, incidence: panel.AOI,
            zenith: position.zenith, doy: dt.yearDay)
          )
        )
      } else {
        conditions.append((temperature, wind, .zero))
      }
    }
    let photovoltaic = conditions.concurrentMap { t, ws, gti -> Double in
      pv(radiation: gti, ambient: t, windSpeed: ws) / 10.0e6
    }
    // Repeat the values to fill the hour
    var iter = photovoltaic.repeated(times: Simulation.time.steps.rawValue).makeIterator()
    
    for (meteo, date) in simulationPeriod() {
      // Set the date for the calculation step
      DateTime.setCurrent(date: date)
      let dt = DateTime.current
      
      /// Hourly PV result
      plant.electricity.photovoltaic = iter.next()!

      if Maintenance.checkSchedule(date) {
        // No operation is simulated
        let status = Plant.initialState
        let energy = PlantPerformance()
        recorder(dt, meteo: meteo, status: status, energy: energy)
        continue
      }

      if let position = 🌞[date] {
        // Only when the sun is above the horizon.
        status.collector.tracking(sun: position) // cosTheta
        status.collector.efficiency(ws: meteo.windSpeed)
        status.collector.irradiation(dni: meteo.dni)
      } else {
        status.collector = Collector.initialState
        DateTime.setNight()
      }
#if DEBUG
      if DateTime.isSunRise
      {()}
      if DateTime.isSunSet
      {()}
      if DateTime.at(minute: 40, hour: 8, day: 1, month: 1)
      {()}
#endif
      // Used when calculating the heat losses and the efficiency
      let temperature = Temperature(celsius: Double(meteo.temperature))

      // Setting the mass flow required by the power block in the solar field
      status.solarField.requiredMassFlow = HeatExchanger.designMassFlow
      if status.solarField.massFlow > .zero {
        status.solarField.inletTemperature(outlet: status.powerBlock)
      } else {
        // Calculate the heat losses in the cold header
        status.solarField.temperature.inlet = status.solarField.heatLosses(
          header: status.solarField.header.temperature.inlet,
          ambient: temperature
        )
      }

      if Design.hasStorage {
        // Increasing the mass flow allowed in the solar field
        status.solarField.requiredMassFlow(from: status.storage)
        // Sets the temperature when the storage does freeze protection
        status.solarField.inletTemperature(from: status.storage)
      }

      // Calculate outlet temperature and mass flow
      status.solarField.calculate(
        collector: status.collector, ambient: temperature
      )

      // Determine the current efficiency of the solar field
      status.solarField.eta(collector: status.collector)

      // Calculate the heat losses in the hot header
      status.solarField.temperature.outlet = status.solarField.heatLosses(
        header: status.solarField.header.temperature.outlet,
        ambient: temperature
      )
      // Calculate power consumption of the pumps
      plant.electricalParasitics.solarField = status.solarField.parasitics()

      // Calculate the performance data of the plant
      plant.perform(&status, ambient: temperature)

      if Design.hasStorage {
        // Calculate the operating state of the salt
        status.storage.calculate(
          output: &plant.heatFlow.storage,
          input: plant.heatFlow.toStorage,          
          powerBlock: status.powerBlock
        )
        // Calculate the heat loss of the tanks
        status.storage.heatlosses(for: Simulation.time.steps.interval)
      }

      plant.electricity.consumption()

      let performance = plant.performance
#if PRINT      
      print(decorated(dt.description), meteo, status, performance)
      ClearScreen()
#endif
      recorder(dt, meteo: meteo, status: status, energy: performance)
    }

    return recorder.finish()
  }

  private static func simulationPeriod(
    _ valuesPerHour: DateSeries.Frequence? = nil
  ) -> Zip2Sequence<ArraySlice<MeteoData>, DateSeries> 
  {
    let times: DateSeries
    var meteo: ArraySlice<MeteoData>
    let interval = Simulation.time.steps
    if let dateInterval = Simulation.time.dateInterval
    {
      let range = dateInterval.aligned(to: interval)
      times = DateSeries(range: range, interval: interval)
      let values: [MeteoData] 
      if let steps = valuesPerHour, interval.rawValue > steps.rawValue {
        values = stride(
          from: meteoData.startIndex, to: meteoData.endIndex, by: interval.rawValue
        ).map { meteoData[$0] }
      } else {
        values = meteoData
      }
      let indices = values.range(for: range)
      meteo = values[indices]
    } else {
      times = DateSeries(year: yearOfSimulation, interval: interval)
      meteo = meteoData[...]
    }
    return zip(meteo, times)
  }
}
