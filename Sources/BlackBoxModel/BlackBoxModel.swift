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
import Foundation
import Meteo
import SolarPosition
import Utilities

public enum BlackBoxModel {

  public private(set) static var simulatedYear = 2001
  /// The apparent solar position based on date, time, and location.
  public private(set) static var sun: SolarPosition?
  /// Solar radiation and meteorological elements for a 1-year period.
  public private(set) static var meteoData: [MeteoData] = []

  public static func configure(year: Int) {
    simulatedYear = year
    if let dateInterval = Simulation.time.dateInterval,
      let newStart = Greenwich.date(
        bySettingUnit: .year, value: year, of: dateInterval.start)
    {
      Simulation.time.dateInterval = DateInterval(
        start: newStart, duration: dateInterval.duration)
    }
    if let sun = BlackBoxModel.sun, simulatedYear != sun.year {
      BlackBoxModel.sun = SolarPosition(
        coords: sun.location.coordinates, tz: sun.location.timezone,
        year: simulatedYear, frequence: Simulation.time.steps)
    }
  }

  public static func configure(location: Location) {
    if let sun = sun, sun.location == location { return }
    // Calculate sun angles for location
    sun = SolarPosition(
      coords: location.coordinates, tz: location.timezone,
      year: simulatedYear, frequence: Simulation.time.steps)

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

    let metadata = try handler.metadata()

    // Check if the sun angles for the location have already been calculated
    if let sun = sun, metadata.location == sun.location { return }

    // Calculate sun angles for location
    sun = SolarPosition(
      coords: metadata.location.coordinates, tz: metadata.location.timezone,
      year: metadata.year, frequence: Simulation.time.steps)
  }

  public static func loadConfiguration(atPath path: String) throws -> String? {
    let url = URL(fileURLWithPath: path)
    if url.hasDirectoryPath {
      let files = try FileManager.default.contentsOfDirectory(atPath: path)
      let json = files.filter { $0.hasSuffix("json") }
      let check = JSONConfig.Name.detectFile(name:)
      if let file = json.drop(while: { file in check(file) }).first {
        _ = try JSONConfig.loadConfiguration(atPath: path + "/" + file)
        return files.first(where: { $0.hasSuffix("mto") })
      }
    } else if url.pathExtension.contains("json") {
      return try JSONConfig.loadConfiguration(atPath: path)?.path
    }
    return try TextConfig.loadConfiguration(atPath: path)?.path
  }

  /// - Parameter with: Creates the log and write results to file.
  /// - Attention: `configure()` must called before this.
  public static func runModel(with record: Historian) {
    let insolation = meteoDataDiagnose()
    guard let 🌞 = sun, insolation.direct else { 
      print("Missing sunshine."); exit(1)
    }

    // Preparation of the plant parameters
    var plant = Plant.setup()

    // Set initial values
    var status = Plant.initialState
    var photovoltaic = [Double]()

    if insolation.global { 
      let pv = PV()

      var inputs = [(solar: Double, ambient: Temperature, windSpeed: Double)]()

      for (meteo, date) in simulationPeriod(.hour) {
        let solar: Double
        if let position = 🌞[date] {
          let panel = singleAxisTracker(
            apparentZenith: position.zenith, 
            apparentAzimuth: position.azimuth,
            maxAngle: 55, GCR: 0.444)
          solar = Insolation(meteo: meteo).effective(
            surfTilt: panel.surfTilt, incidence: panel.AOI,
            zenith: position.zenith, doy: DateTime(date).yearDay)
        } else {
          solar = .zero
        }
        inputs.append(
          (solar, Temperature(celsius: meteo.temperature), meteo.windSpeed)
        )
      }
      let count = Simulation.time.steps.rawValue
      photovoltaic = inputs.reversed().reduce(into: []) { result, input in
        result += repeatElement(pv(input) / 10.0e6, count: count)
      }
    }

    for (meteo, date) in simulationPeriod() {
      // Set the date for the calculation step
      DateTime.setCurrent(date: date)
      let dt = DateTime.current
      /// Hourly PV result
      if !photovoltaic.isEmpty {
        plant.electricity.photovoltaic = photovoltaic.removeLast()
      }
      if Maintenance.checkSchedule(date) {
        // No operation is simulated
        let status = Plant.initialState
        let energy = PlantPerformance()
        record(dt, meteo: meteo, status: status, energy: energy)
        continue
      }

      if let position = 🌞[date] {
        // Only when the sun is above the horizon.
        status.collector.tracking(sun: position)  // cosTheta
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

      // Calculate outlet temperature and mass flow
      status.solarField.calculate(
        collector: status.collector, ambient: temperature)

      // Determine the current efficiency of the solar field
      status.solarField.eta(collector: status.collector)

      // Calculate the heat losses in the hot header
      status.solarField.temperature.outlet = status.solarField.heatLosses(
        header: status.solarField.header.temperature.outlet,
        ambient: temperature)
      // Calculate power consumption of the pumps
      plant.electricalParasitics.solarField = status.solarField.parasitics()

      // Calculate the performance data of the plant
      plant.perform(&status, ambient: temperature)

      if Design.hasStorage {
        // Calculate the operating state of the salt
        status.storage.calculate(
          output: &plant.heatFlow.storage,
          input: plant.heatFlow.toStorage,
          powerBlock: status.powerBlock)
        // Calculate the heat loss of the tanks
        status.storage.heatlosses(for: Simulation.time.steps.interval)
      }

      plant.electricity.consumption()
      record(dt, meteo: meteo, status: status, energy: plant.performance)
    }
  }

  private static func meteoDataDiagnose() -> (direct: Bool, global: Bool) {
    // Check the first 12 hours of the year for insolation
    let am = meteoData.prefix(meteoData.count / 730)
    return (!am.isEmpty && !am.map(\.dni).max()!.isZero,
     !am.isEmpty && !am.map(\.ghi).max()!.isZero && !am.map(\.dhi).max()!.isZero)
  }

  private static func simulationPeriod(
    _ valuesPerHour: DateSeries.Frequence? = nil
  ) -> Zip2Sequence<ArraySlice<MeteoData>, DateSeries> {
    let times: DateSeries
    var meteo: ArraySlice<MeteoData>
    let interval = Simulation.time.steps
    if let dateInterval = Simulation.time.dateInterval {
      let range = dateInterval.aligned(to: interval)
      let values: [MeteoData]
      if let steps = valuesPerHour, interval.rawValue > steps.rawValue {
        times = DateSeries(range: range, interval: steps)
        values = stride(
          from: meteoData.startIndex, to: meteoData.endIndex,
          by: interval.rawValue
        ).map { meteoData[$0] }
      } else {
        times = DateSeries(range: range, interval: interval)
        values = meteoData
      }
      let indices = values.range(for: range)
      meteo = values[indices]
    } else {
      times = DateSeries(year: simulatedYear, interval: interval)
      meteo = meteoData[...]
    }
    return zip(meteo, times)
  }
}
