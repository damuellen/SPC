//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import DateGenerator
import Foundation
import Meteo

public enum PerformanceDataLoggerMode { case full, brief }

final class PerformanceDataLogger {
  var dateString: String = ""

  var dateFormatter: DateFormatter? {
    didSet {
      self.dateFormatter?.timeZone = TimeZone(secondsFromGMT: 0)
      self.dateFormatter?.dateStyle = .short
      self.dateFormatter?.timeStyle = .short
    }
  }

  let interval = PerformanceCalculator.interval

  let annuallyResults = Results()
  let dailyResults = Results()
  let hourlyResults = Results()

  let mode: PerformanceDataLoggerMode

  init(fileNameSuffix: String, mode: PerformanceDataLoggerMode = .full) {
    self.mode = mode

    self.dailyResultsStream = OutputStream(
      toFileAtPath: "DailyResults_\(fileNameSuffix).csv", append: false
    )
    self.dailyResultsStream?.open()
    self.dailyResultsStream?.write(
      self.headersDaily.name + .lineBreak + self.headersDaily.unit + .lineBreak
    )

    self.hourlyResultsStream = OutputStream(
      toFileAtPath: "HourlyResults_\(fileNameSuffix).csv", append: false
    )
    self.hourlyResultsStream?.open()
    self.hourlyResultsStream?.write(
      self.headersHourly.name + .lineBreak + self.headersHourly.unit + .lineBreak
    )

    if case .full = mode {
      let header = "wxDVFileHeaderVer.1\n"
      let startTime = repeatElement("0", count: 40)
        .joined(separator: ", ") + .lineBreak
      let intervalTime = repeatElement("\(interval.fraction)", count: 40)
        .joined(separator: ", ") + .lineBreak

      allResultsStream = OutputStream(
        toFileAtPath: "AllResults_\(fileNameSuffix).csv", append: false
      )

      allResultsStream?.open()
      allResultsStream?.write(
        header + headersInterval.name + startTime + intervalTime + headersInterval.unit
      )

      allResultsStream2 = OutputStream(
        toFileAtPath: "AllResults2_\(fileNameSuffix).csv", append: false
      )
      allResultsStream2?.open()
      allResultsStream2?.write(
        header + headersInterval2.name + startTime + intervalTime + headersInterval2.unit
      )
    }
  }

  deinit {
    dailyResultsStream?.close()
    hourlyResultsStream?.close()
    allResultsStream?.close()
    allResultsStream2?.close()
  }

  func append(date: Date, meteo: MeteoData,
              electricEnergy: ElectricEnergy,
              electricalParasitics: Parasitics,
              thermal: ThermalEnergy,
              fuelConsumption: FuelConsumption,
              status: Plant.PerformanceData) {
    if case .full = self.mode {
      let results = Results()
      results.thermal = thermal
      results.energy = electricEnergy
      results.fuelConsumption = fuelConsumption
      results.parasitics = electricalParasitics
      results.dni = Double(meteo.dni)
      results.ghi = Double(meteo.ghi)
      results.dhi = Double(meteo.dhi)
      results.temp = Double(meteo.temperature)
      results.ws = Double(meteo.windSpeed)
      results.ico = Double(meteo.dni) * status.collector.cosTheta
      results.insolationAbsorber = status.solarField.insolationAbsorber
      results.status = status
      results.heatLossSolarField = status.solarField.heatLosses
      results.heatLossHeader = status.solarField.heatLossHeader
      results.heatLossHCE = status.solarField.heatLossHCE
      writeAll(results: results, date: date)
    }
    // The counter triggers the writing of the file when it is set.
    defer { intervalCounter += 1 }

    if self.intervalCounter == 0, let dateFormatter = dateFormatter {
      self.dateString = dateFormatter.string(from: date)
    }

    let fraction = interval.fraction
    hourlyResults.thermal.accumulate(thermal, fraction: fraction)
    hourlyResults.energy.accumulate(electricEnergy, fraction: fraction)
    hourlyResults.fuelConsumption.accumulate(fuelConsumption, fraction: fraction)
    hourlyResults.parasitics.accumulate(electricalParasitics, fraction: fraction)

    hourlyResults.dni += Double(meteo.dni) * fraction
    hourlyResults.ghi += Double(meteo.ghi) * fraction
    hourlyResults.dhi += Double(meteo.dhi) * fraction
    hourlyResults.temp = Double(meteo.temperature)
    hourlyResults.ws = Double(meteo.windSpeed)
    hourlyResults.ico += Double(meteo.dni) * status.collector.cosTheta * fraction

    hourlyResults.add(solarfield: status.solarField, fraction: fraction)
  }

  private var hourCounter: Int = 0 {
    didSet {
      if hourCounter == 24 {
        writeDailyResults()
        hourCounter = 0
      }
    }
  }

  private var intervalCounter: Int = 0 {
    didSet {
      if intervalCounter == interval.rawValue {
        writeHourlyResults()
        intervalCounter = 0
      }
    }
  }

  // MARK: Output Streams

  var dailyResultsStream: OutputStream?
  var hourlyResultsStream: OutputStream?
  var allResultsStream: OutputStream?
  var allResultsStream2: OutputStream?

  // MARK: Table headers

  private var headersDaily: (name: String, unit: String) {
    let columns = [PerformanceDataLogger.Results.columns, ThermalEnergy.columns,
                   ElectricEnergy.columns, Parasitics.columns,
                   FuelConsumption.columns].joined()
    let names = columns.map { $0.0 }.joined(separator: ",")
    let units = columns.map { $0.1 }.joined(separator: ",")
    // if dateFormatter != nil {
    return ("Date,Time," + names, "_,_," + units)
    // }
    // return (names, units)
  }

  private var headersHourly: (name: String, unit: String) {
    let columns = [PerformanceDataLogger.Results.columns, ThermalEnergy.columns,
                   ElectricEnergy.columns, Parasitics.columns,
                   FuelConsumption.columns].joined()
    let names = columns.map { $0.0 }.joined(separator: ",")
    let units = columns.map { $0.1 }.joined(separator: ",")
    // if dateFormatter != nil {
    return ("Date,Time," + names, "_,_," + units)
    // }
    // return (names, units)
  }

  private var headersInterval: (name: String, unit: String) {
    let columns = [PerformanceDataLogger.Results.columns, ThermalEnergy.columns,
                   ElectricEnergy.columns, Parasitics.columns,
                   FuelConsumption.columns,
                   Collector.PerformanceData.columns].joined()
    let names = columns.map { $0.0 }.joined(separator: ",") + .lineBreak
    let units = columns.map { $0.1 }.joined(separator: ",") + .lineBreak
    return ("Date,Time," + names, "_,_," + units)
  }

  private var headersInterval2: (name: String, unit: String) {
    let columns = PerformanceDataLogger.Results.columns2
    let names = columns.map { $0.0 }.joined(separator: ",") + .lineBreak
    let units = columns.map { $0.1 }.joined(separator: ",") + .lineBreak
    return ("Date,Time," + names, "_,_," + units)
  }

  // MARK: Write Results

  private func writeDailyResults() {
    let csv = dateString.dropLast(4) + ", " + [
      dailyResults.values, dailyResults.thermal.values,
      dailyResults.energy.values, dailyResults.parasitics.values,
      dailyResults.fuelConsumption.values,
    ]
    .joined().joined(separator: ",") + .lineBreak
    dailyResultsStream?.write(csv)
    annuallyResults.accumulate(dailyResults, fraction: 24)
    dailyResults.reset()
  }

  private func writeHourlyResults() {
    let csv = dateString + ", " + [
      hourlyResults.values, hourlyResults.thermal.values,
      hourlyResults.energy.values, hourlyResults.parasitics.values,
      hourlyResults.fuelConsumption.values,
    ]
    .joined().joined(separator: ", ") + .lineBreak
    hourlyResultsStream?.write(csv)
    dailyResults.accumulate(hourlyResults, fraction: 1 / 24)
    hourCounter += 1
    hourlyResults.reset()
  }

  private func writeAll(results: Results, date: Date) {
    guard let stream = allResultsStream,
      let stream2 = allResultsStream2 else { return }
    let dateString = dateFormatter?.string(from: date) ?? ""
    let csv1 = dateString + ", "
      + results.csv + results.thermal.csv + results.energy.csv
      + results.parasitics.csv + results.fuelConsumption.csv
      + results.status!.collector.csv + .lineBreak
    let csv2 = dateString + ", " + results.csv2 + .lineBreak
    stream.write(csv1)
    stream2.write(csv2)
  }
}

extension PerformanceDataLogger {
  final class Results: CustomStringConvertible {
    // Thermal: [MWHth] = [MWth] * [Hr]
    var thermal = ThermalEnergy()

    var fuelConsumption = FuelConsumption()

    // Electric: [MWHe] = [MWe] * [Hr]
    var parasitics = Parasitics()
    var energy = ElectricEnergy()

    // Meteodata: [WHr/sqm]
    var dni: Double = 0
    var ghi: Double = 0
    var dhi: Double = 0
    var ico: Double = 0
    var temp: Double = 0
    var ws: Double = 0

    // SolarField
    var insolationAbsorber: Double = 0
    var heatLossSolarField: Double = 0
    var heatLossHeader: Double = 0
    var heatLossHCE: Double = 0

    var status: Plant.PerformanceData?

    var values: [String] {
      return [
        String(format: "%.1f", dni),
        String(format: "%.1f", ghi),
        String(format: "%.1f", dhi),
        String(format: "%.1f", temp),
        String(format: "%.1f", ws),
        String(format: "%.0f", ico),
        String(format: "%.0f", insolationAbsorber),
        String(format: "%.1f", heatLossSolarField),
        String(format: "%.1f", heatLossHeader),
        String(format: "%.1f", heatLossHCE),
      ]
    }

    var csv: String {
      return String(format: "%.1f, %.1f, %.1f, %.1f, %.1f, %.0f, %.0f, %.0f, %.0f, %.0f, ",
                    self.dni, self.ghi, self.dhi, self.temp, self.ws, self.ico, self.insolationAbsorber,
                    self.heatLossSolarField, self.heatLossHeader, self.heatLossHCE)
    }

    static var columns: [(String, String)] {
      return [
        ("Meteo|DNI", "W/m2"), ("Meteo|GHI", "W/m2"), ("Meteo|DHI", "W/m2"),
        ("Meteo|Temperature", "degC"), ("Meteo|Windspeed", "m/s"),
        ("SolarField|ICO", "W/m2"), ("SolarField|InsolationAbsorber", "W/m2"),
        ("SolarField|HeatLosses", "MWh"), ("SolarField|HeatLossHeader", "MWh"),
        ("SolarField|HeatLossHCE", "MWh"),
      ]
    }

    var csv2: String {
      let values = status!.storage.values + status!.heater.values
        + status!.powerBlock.values + status!.heatExchanger.values
        + status!.solarField.values + status!.solarField.loops[0].values
      return values.joined(separator: ", ")
    }

    static var columns2: [(String, String)] {
      let values: [(name: String, unit: String)] =
        [("|Massflow", "kg/s"), ("|Tin", "degC"), ("|Tout", "degC")]
      return ["Storage", "Heater", "PowerBlock", "HeatExchanger", "SolarField", "Loop"]
        .flatMap { name in values.map { value in (name + value.name, value.unit) }
        }
    }

    public var description: String {
      return self.thermal.description + self.fuelConsumption.description
        + self.parasitics.description + self.energy.description
        + zip(self.values, Results.columns).reduce("\n") { result, next in
          let text = next.1.0 >< (next.0 + " " + next.1.1)
          return result + text
        }
    }

    fileprivate func add(solarfield: SolarField.PerformanceData, fraction: Double) {
      self.insolationAbsorber += solarfield.insolationAbsorber * fraction
      self.heatLossSolarField += solarfield.heatLosses * fraction
      self.heatLossHeader += solarfield.heatLossHeader * fraction
      self.heatLossHCE += solarfield.heatLossHCE * fraction
    }

    fileprivate func accumulate(_ result: Results, fraction: Double) {
      self.thermal.accumulate(result.thermal, fraction: fraction)
      self.fuelConsumption.accumulate(result.fuelConsumption, fraction: fraction)
      self.parasitics.accumulate(result.parasitics, fraction: fraction)
      self.energy.accumulate(result.energy, fraction: fraction)
      self.dni += result.dni * fraction
      self.ghi += result.ghi * fraction
      self.dhi += result.dhi * fraction
      self.ico += result.ico * fraction

      self.insolationAbsorber += result.insolationAbsorber * fraction
      self.heatLossSolarField += result.heatLossSolarField * fraction
      self.heatLossHeader += result.heatLossHeader * fraction
      self.heatLossHCE += result.heatLossHCE * fraction
    }

    fileprivate func reset() {
      self.thermal = ThermalEnergy()
      self.fuelConsumption = FuelConsumption()
      self.parasitics = Parasitics()
      self.energy = ElectricEnergy()
      self.dni = 0; self.ghi = 0; self.dhi = 0; self.ico = 0
      self.temp = 0; self.ws = 0
      self.insolationAbsorber = 0; self.heatLossSolarField = 0
      self.heatLossHeader = 0; self.heatLossHCE = 0
    }
  }
}

extension OutputStream {
  func write(_ string: String) {
    let bytes = [UInt8](string.utf8)
    write(bytes, maxLength: bytes.count)
  }
}
