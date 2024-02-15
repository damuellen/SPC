// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import DateExtensions
import Foundation
import Meteo
import SolarPosition
import Utilities

/// A namespace representing a black box model for a solar power plant simulation.
public enum BlackBoxModel {

  /// The year for which the simulation is configured.
  public private(set) static var simulatedYear = 2001
  /// The apparent solar position based on date, time, and location.
  public private(set) static var sun: SolarPosition?
  /// Handle for meteorological file
  public private(set) static var meteo: MeteoDataFileHandler!

  // MARK: - Configuration Functions
  
  /// Configure the simulation for a specific year.
  ///
  /// - Parameter year: The year for which the simulation should be configured.
  public static func configure(year: Int) {
    simulatedYear = year

    // Update the simulation date interval if it exists.
    if let dateInterval = Simulation.time.dateInterval,
      let newStart = Greenwich.date(
        bySettingUnit: .year, value: year, of: dateInterval.start)
    {
      Simulation.time.dateInterval = DateInterval(
        start: newStart, duration: dateInterval.duration)
    }

    // Recalculate solar positions if the year has changed.
    if let sun = BlackBoxModel.sun, simulatedYear != sun.year {
      BlackBoxModel.sun = SolarPosition(
        coords: sun.location.coordinates, tz: sun.location.timezone,
        year: simulatedYear, frequence: Simulation.time.steps)
    }
  }

  /// Configure the simulation for a specific location.
  ///
  /// - Parameter location: The `Location` object representing the location for the simulation.
  public static func configure(location: Location) {
    // If the solar position has already been calculated for the same location, return early.
    if let sun = sun, sun.location == location { return }

    // Calculate sun angles for the given location.
    sun = SolarPosition(
      coords: location.coordinates, tz: location.timezone,
      year: simulatedYear, frequence: Simulation.time.steps)
  }

  /// Configure the simulation using meteo data from a file.
  ///
  /// - Parameter meteoFilePath: The file path for the meteo data file. If nil, it searches the current directory.
  /// - Throws: An error if there's an issue with reading the meteo data file.
  public static func configure(meteoFilePath: String) throws {
    // Search for the meteo data file.
    meteo = try MeteoDataFileHandler(forReadingAtPath: meteoFilePath)
    meteo.interpolation = false
    // Read the content of the meteo data file.
    let info = meteo.info()

    simulatedYear = info.year
    // Check if the sun angles for the location have already been calculated.
    if let sun = sun, info.location == sun.location { return }

    // Calculate sun angles for the location.
    sun = SolarPosition(
      coords: info.location.coordinates,
      tz: info.location.timezone,
      year: simulatedYear,
      frequence: Simulation.time.steps)
  }

  /// Load configuration from a JSON or text configuration file.
  ///
  /// - Parameter path: The path to the configuration file.
  /// - Returns: The path to the meteo data file if available.
  /// - Throws: An error if there's an issue with reading the configuration file.
  public static func loadConfiguration(atPath path: String) throws -> URL? {
    let url = URL(fileURLWithPath: path)
    if url.hasDirectoryPath {
      print("Search for config files in directory:\n  \(path)\n")
      let fileNames = try FileManager.default.contentsOfDirectory(atPath: path)
      let urls = fileNames.map { filename in 
        URL(fileURLWithPath: filename, relativeTo: url)
      } 
      if let config = urls.first(where: { $0.lastPathComponent.hasPrefix("CFG_") }) {
        try JSONConfig.read(urls: [config])
        return URL(fileURLWithPath: path)
      } else if urls.contains(where: { $0.pathExtension == "json" }) {
        try JSONConfig.read(urls: urls)
        return URL(fileURLWithPath: path)
      } else {
        return try TextConfig.read(urls: urls)
      }
    } else if url.pathExtension.lowercased().contains("json") {
      try JSONConfig.read(urls: [url])
    } else if url.pathExtension.lowercased().contains("pdd") {
      print("Parse file paths from pdd file:", path)
      return try TextConfig.read(urls: [url])
    }
    return nil
  }

  // MARK: - Simulation Function
  
  /// Run the solar power plant simulation and record the results in a historian.
  ///
  /// - Parameters:
  ///   - record: The historian object to record the simulation results.
  /// - Attention: `configure()` must be called before this function.
  public static func runModel(with record: Historian) {
    guard let 🌞 = sun, let insolation = meteo.diagnose(), insolation.direct 
    else { print("Missing sunshine. Please check the file content."); exit(1) }

    // Preparation of the plant parameters
    var plant = Plant.setup()

    // Set initial values
    var status = Plant.initialState
    var photovoltaic = [Double]()

    if insolation.global {
      // If global insolation is available, calculate photovoltaic power.
      let pv = PV()
      var inputs = [PV.InputValues]()
      
      // Generate input values for each simulation time step.
      let (frequence, sequence) = valuesForSimulationPeriod()
      for (meteo, date) in sequence {
        let (t, ws) = (Temperature(celsius: meteo.temperature), meteo.windSpeed)
        let gti: Double

        // Calculate global tilt irradiation for the panel at the current time step.
        if let position = 🌞[date] {
          let panel = singleAxisTracker(
            apparentZenith: position.zenith, 
            apparentAzimuth: position.azimuth,
            maxAngle: 55, GCR: 0.444)
          gti = meteo.insolation.effective(
            surfTilt: panel.surfTilt, incidence: panel.AOI,
            zenith: position.zenith, doy: DateTime(date).yearDay)
        } else {
          gti = .zero
        }
        inputs.append(.init(gti: gti, ambient: t, windSpeed: ws))
      }
      let count = Simulation.time.steps.rawValue / frequence.rawValue
      // Generate photovoltaic power values for each time step.
      photovoltaic = inputs.reversed().reduce(into: []) { result, input in
        result += repeatElement(pv(input) / 10.0e6, count: count)
      }
    }

  for (meteo, date) in valuesForSimulationPeriod(Simulation.time.steps).1 {
      // Set the date for the calculation step
      DateTime.setCurrent(date: date)
      let dt = DateTime.current
      
      // Update hourly PV result if applicable
      if !photovoltaic.isEmpty {
        plant.electricity.photovoltaic = photovoltaic.removeLast()
      }
      
      // Check if maintenance schedule needs to be executed.
      if Maintenance.checkSchedule(date) {
        // No operation is simulated during maintenance.
        let status = Plant.initialState
        let energy = PlantPerformance()
        record(dt, meteo: meteo, status: status, energy: energy)
        continue
      }
      
      // Get sun angles for the current location and time.
      if let position = 🌞[date] {
        // Calculate collector tracking angle (cosTheta)
        status.collector.tracking(sun: position) 
        status.collector.efficiency(ws: meteo.windSpeed)
        status.collector.irradiation(dni: meteo.insolation.direct)
      } else {
        // If the sun is below the horizon, set the collector state accordingly.
        status.collector = Collector.initialState
        DateTime.setNight()
      }
#if DEBUG
      if DateTime.isSunRise
      {()}
      if DateTime.isSunSet
      {()}
      if DateTime.is(minute: 40, hour: 8, day: 1, month: 1)
      {()}
#endif

      // Temperature for heat loss and efficiency calculations
      let temperature = Temperature(celsius: meteo.temperature)

      // Setting the mass flow required by the power block in the solar field
      status.solarField.requiredMassFlow = HeatExchanger.designMassFlow
      if status.solarField.massFlow > .zero {
        status.solarField.inletTemperature(outlet: status.powerBlock)
      } else {
        // Calculate the heat losses in the cold header
        status.solarField.temperature.inlet = status.solarField.heatLosses(
          header: status.solarField.header.temperature.inlet,
          ambient: temperature)
      }

      if Design.hasStorage {
        // Increasing the mass flow allowed in the solar field
        status.solarField.requiredMassFlow(from: status.storage)
        // Sets the temperature when the storage does freeze protection
        status.solarField.inletTemperature(from: status.storage)
      }

      // Calculate outlet temperature and mass flow in the solar field
      status.solarField.calculate(collector: status.collector, ambient: temperature)

      // Determine the current efficiency of the solar field
      status.solarField.eta(collector: status.collector)

      // Calculate the heat losses in the hot header
      status.solarField.temperature.outlet = status.solarField.heatLosses(
        header: status.solarField.header.temperature.outlet,
        ambient: temperature)
      // Calculate power consumption of the pumps
      plant.electricalParasitics.solarField = status.solarField.parasitics()

      // Calculate the operating sequence of the plant
      plant.perform(&status, ambient: temperature)

      if Design.hasStorage {
        // Calculate the operating state of the salt storage
        status.storage.calculate(
          output: &plant.heatFlow.storage,
          input: plant.heatFlow.toStorage,
          powerBlock: status.powerBlock)
        // Calculate the heat loss of the tanks
        status.storage.heatlosses(for: Simulation.time.steps.interval)
      }

      // Calculate electricity consumption and record the results
      plant.electricity.consumption()
      record(dt, meteo: meteo, status: status, energy: plant.performance)
    }
  }

  private static func valuesForSimulationPeriod(_ valuesPerHour: Steps? = nil) -> (Steps, DataSet) {
    let times: DateSeries
    guard let meteo else { fatalError() }
    let meteoData = meteo.data(valuesPerHour: valuesPerHour?.rawValue)    
    let interval = valuesPerHour ?? meteo.interval  
    if let dateInterval = Simulation.time.dateInterval {
      let range = dateInterval.aligned(to: interval)
      times = DateSeries(range: range, interval: interval)
      let indices = meteoData.range(for: range)
      return (interval, zip(meteoData[indices], times))
    } else {
      times = DateSeries(year: simulatedYear, interval: interval)
      return (interval, zip(meteoData[...], times))
    }
  }
}

typealias DataSet = Zip2Sequence<ArraySlice<MeteoData>, DateSeries>