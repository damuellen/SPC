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

public final class PerformanceDataLogger {
  var dateString: String = ""

  let dateFormatter: DateFormatter = { dateFormatter in
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
    return dateFormatter
  }(DateFormatter())

  public var log: PerformanceLog {
    var annual = self.annual
    annual.temp /= 8760 * 12
    return PerformanceLog(annual: annual, history: history, results: results)
  }
  
  private var annual = PerformanceLog.Results()
  private var daily = PerformanceLog.Results()
  private var hourly = PerformanceLog.Results()
  private var history: [Plant.PerformanceData] = []
  private var results: [PerformanceLog.Results] = []
  private let interval = BlackBoxModel.interval
  private let mode: Mode

  public enum Mode {
    case full, brief, playground, none
    
    var writeResults: Bool {
      if case .none = self {
        return false
      }
      return true
    }
  }
  
  public init() {
    self.mode = .playground
  }

  init(fileNameSuffix: String, mode: Mode = .full) {
    self.mode = mode
    if mode.writeResults {
      self.dailyResultsStream = OutputStream(
        toFileAtPath: "DailyResults_\(fileNameSuffix).csv", append: false
      )
      self.dailyResultsStream?.open()
      self.dailyResultsStream?.write(
        self.headersDaily.name + .lineBreak
          + self.headersDaily.unit + .lineBreak
      )

      self.hourlyResultsStream = OutputStream(
        toFileAtPath: "HourlyResults_\(fileNameSuffix).csv", append: false
      )
      self.hourlyResultsStream?.open()
      self.hourlyResultsStream?.write(
        self.headersHourly.name + .lineBreak
          + self.headersHourly.unit + .lineBreak
      )
    }
    if case .full = mode {
      let header = "wxDVFileHeaderVer.1\n"
      let startTime = repeatElement("0", count: 40)
        .joined(separator: .separator) + .lineBreak
      let intervalTime = repeatElement("\(interval.fraction)", count: 40)
        .joined(separator: .separator) + .lineBreak

      allResultsStream = OutputStream(
        toFileAtPath: "AllResults_\(fileNameSuffix).csv", append: false
      )

      allResultsStream?.open()
      allResultsStream?.write(
        header + headersInterval.name + startTime
          + intervalTime + headersInterval.unit
      )

      allResultsStream2 = OutputStream(
        toFileAtPath: "AllResults2_\(fileNameSuffix).csv", append: false
      )
      allResultsStream2?.open()
      allResultsStream2?.write(
        header + headersInterval2.name + startTime
          + intervalTime + headersInterval2.unit
      )
    }
  }

  deinit {
    dailyResultsStream?.close()
    hourlyResultsStream?.close()
    allResultsStream?.close()
    allResultsStream2?.close()
  }

  func reset() {
    annual.reset()
    daily.reset()
    hourly.reset()
    history.removeAll(keepingCapacity: true)
    results.removeAll(keepingCapacity: true)
  }

  func printResult() {
    print("")
    print("---------------------------+=[  Annual results  ]=+-----------------------------")
    print(annual)
    print("________________________________________________________________________________")
  }

  func append(date: Date, meteo: MeteoData,
              status: Plant.PerformanceData,
              electricalEnergy: ElectricPower,
              electricalParasitics: Parasitics,
              thermalEnergy: ThermalEnergy,
              fuelConsumption: FuelConsumption)
  {
    var results = PerformanceLog.Results()
    results.thermal = thermalEnergy
    results.electric = electricalEnergy
    results.fuel = fuelConsumption
    results.parasitics = electricalParasitics
    results.dni = Double(meteo.dni)
    results.ghi = Double(meteo.ghi)
    results.dhi = Double(meteo.dhi)
    results.temp = Double(meteo.temperature)
    results.ws = Double(meteo.windSpeed)
    results.ico = Double(meteo.dni) * status.collector.cosTheta
    results.insolationAbsorber = status.solarField.insolationAbsorber
    results.heatLossSolarField = status.solarField.heatLosses
    results.heatLossHeader = status.solarField.heatLossHeader
    results.heatLossHCE = status.solarField.heatLossHCE

    if case .full = mode {
      writeAll(results: results, status: status, date: date)
    }

    if case .playground = mode {
      self.history.append(status)
      self.results.append(results)
    }

    let fraction = interval.fraction
    if mode.writeResults {
      // The hourly, daily and annual totals are calculated.
      defer { intervalCounter += 1 }

      if self.intervalCounter == 0 {
        self.dateString = dateFormatter.string(from: date)
      }

      hourly.thermal.totalize(thermalEnergy, fraction: fraction)
      hourly.electric.totalize(electricalEnergy, fraction: fraction)
      hourly.fuel.totalize(fuelConsumption, fraction: fraction)
      hourly.parasitics.totalize(electricalParasitics, fraction: fraction)

      hourly.dni += Double(meteo.dni) * fraction
      hourly.ghi += Double(meteo.ghi) * fraction
      hourly.dhi += Double(meteo.dhi) * fraction
      hourly.ico += Double(meteo.dni) * status.collector.cosTheta * fraction
      hourly.add(solarfield: status.solarField, fraction: fraction)
    } else {
      // Only the annual sums are calculated.
      annual.thermal.totalize(thermalEnergy, fraction: fraction)
      annual.electric.totalize(electricalEnergy, fraction: fraction)
      annual.fuel.totalize(fuelConsumption, fraction: fraction)
      annual.parasitics.totalize(electricalParasitics, fraction: fraction)
      annual.ws += Double(meteo.windSpeed)
      annual.temp += Double(meteo.temperature)
      annual.dni += Double(meteo.dni) * fraction
      annual.ghi += Double(meteo.ghi) * fraction
      annual.dhi += Double(meteo.dhi) * fraction
      annual.ico += Double(meteo.dni) * status.collector.cosTheta * fraction
      annual.add(solarfield: status.solarField, fraction: fraction)
    }
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

  private var dailyResultsStream: OutputStream?
  private var hourlyResultsStream: OutputStream?
  private var allResultsStream: OutputStream?
  private var allResultsStream2: OutputStream?

  // MARK: Table headers

  private var headersDaily: (name: String, unit: String) {
    let columns = [PerformanceLog.Results.columns,
                   ThermalEnergy.columns, ElectricPower.columns,
                   Parasitics.columns, FuelConsumption.columns].joined()
    let names: String = columns.map { $0.0 }.joined(separator: ",")
    let units: String = columns.map { $0.1 }.joined(separator: ",")
    // if dateFormatter != nil {
    return ("Date,Time," + names, "_,_," + units)
    // }
    // return (names, units)
  }

  private var headersHourly: (name: String, unit: String) {
    let columns = [PerformanceLog.Results.columns, ThermalEnergy.columns,
                   ElectricPower.columns, Parasitics.columns,
                   FuelConsumption.columns].joined()
    let names = columns.map { $0.0 }.joined(separator: ",")
    let units = columns.map { $0.1 }.joined(separator: ",")
    // if dateFormatter != nil {
    return ("Date,Time," + names, "_,_," + units)
    // }
    // return (names, units)
  }

  private var headersInterval: (name: String, unit: String) {
    let columns = [PerformanceLog.Results.columns, ThermalEnergy.columns,
                   ElectricPower.columns, Parasitics.columns,
                   FuelConsumption.columns, Collector.PerformanceData.columns]
      .joined()
    let names = columns.map { $0.0 }.joined(separator: ",") + .lineBreak
    let units = columns.map { $0.1 }.joined(separator: ",") + .lineBreak
    return ("Date,Time," + names, "_,_," + units)
  }

  private var headersInterval2: (name: String, unit: String) {
    let columns = Plant.PerformanceData.columns
    let names = columns.map { $0.0 }.joined(separator: ",") + .lineBreak
    let units = columns.map { $0.1 }.joined(separator: ",") + .lineBreak
    return ("Date,Time," + names, "_,_," + units)
  }

  // MARK: Write Results

  private func writeDailyResults() {
    let csv = dateString.dropLast(4) + .separator + [
      daily.values, daily.thermal.values,
      daily.electric.values, daily.parasitics.values,
      daily.fuel.values,
      ].joined().joined(separator: ",") + .lineBreak
    dailyResultsStream?.write(csv)
    annual.totalize(daily, fraction: 24)
    daily.reset()
  }

  private func writeHourlyResults() {
    let csv = dateString + .separator + [
      hourly.values, hourly.thermal.values,
      hourly.electric.values, hourly.parasitics.values,
      hourly.fuel.values,
      ].joined().joined(separator: .separator) + .lineBreak
    hourlyResultsStream?.write(csv)
    daily.totalize(hourly, fraction: 1 / 24)
    hourCounter += 1
    hourly.reset()
  }

  private func writeAll(results: PerformanceLog.Results,
                        status: Plant.PerformanceData, date: Date) {
    guard let stream = allResultsStream,
      let stream2 = allResultsStream2 else { return }
    let dateString = dateFormatter.string(from: date)
    let csv1 = dateString + .separator
      + results.csv + results.thermal.csv + results.electric.csv
      + results.parasitics.csv + results.fuel.csv
      + status.collector.csv + .lineBreak
    let csv2 = dateString + .separator + status.csv + .lineBreak
    stream.write(csv1)
    stream2.write(csv2)
  }
}

extension OutputStream {
  func write(_ string: String) {
    let bytes = [UInt8](string.utf8)
    write(bytes, maxLength: bytes.count)
  }
}
