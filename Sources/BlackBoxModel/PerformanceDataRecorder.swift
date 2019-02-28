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

public final class PerformanceDataRecorder {
  
  let interval = { BlackBoxModel.interval }()
  
  let mode: Mode
  
  public enum Mode {
    case full, brief, playground, none
    
    var hasFileOutput: Bool {
      if case .none = self {
        return false
      }
      return true
    }
  }
  
  private var dateString: String = ""

  private let dateFormatter: DateFormatter = { dateFormatter in
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
    return dateFormatter
  }(DateFormatter())

  public var log: PerformanceLog {
    defer { reset() }
    return PerformanceLog(
      energy: annualEnergy,
      radiation: annualRadiation,
      energyHistory: energyHistory,
      performanceHistory: performanceHistory
    )
  }
  
  /// Totals
  private var annualEnergy = Energy()
  private var annualRadiation = SolarRadiation()
  /// Volatile subtotals
  private var hourlyEnergy = Energy()
  private var hourlyRadiation = SolarRadiation()
  /// Sum of hourly values
  private var dailyEnergy = Energy()
  private var dailyRadiation = SolarRadiation()
  /// All past states of the plant
  private var performanceHistory: [Plant.PerformanceData] = []
  private var energyHistory: [Energy] = []
  private var meteo: [MeteoData] = []

  public init(noHistory: Bool = false) {
    self.mode = noHistory ? .none : .playground
  }

  public init(customNaming: String? = nil, mode: Mode = .full) {
    self.mode = mode
    let fileNameSuffix = customNaming ?? dateFormatter.string(from: Date())
    
    if mode.hasFileOutput {
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
  
  public func reset() {
    annualEnergy.reset()
    annualRadiation.reset()
    dailyEnergy.reset()
    dailyRadiation.reset()
    hourlyEnergy.reset()
    hourlyRadiation.reset()
    meteo.removeAll(keepingCapacity: true)
    energyHistory.removeAll(keepingCapacity: true)
    performanceHistory.removeAll(keepingCapacity: true)
  }

  func printResult() {
    print("")
    print("---------------------------+=[  Annual results  ]=+-----------------------------")
    print(annualEnergy)
    print("________________________________________________________________________________")
  }

  func add(
    _ date: Date, meteo: MeteoData, status: Plant.PerformanceData, energy: Energy)
  {
    if case .playground = mode {
      self.meteo.append(meteo)
      self.performanceHistory.append(status)
      self.energyHistory.append(energy)
    }
    
    let solar = SolarRadiation(
      meteo: meteo, cosTheta: status.collector.cosTheta
    )
    
    if case .full = mode {
        self.writeIntermediateResults(
          status: status, energy: energy, solar: solar, date: date
        )
    }

    let fraction = interval.fraction
    if mode.hasFileOutput {
      
      defer { intervalCounter += 1 }

      if self.intervalCounter == 0 {
        self.dateString = dateFormatter.string(from: date)
      }
      hourlyRadiation.totalize(solar ,fraction: fraction)
      hourlyEnergy.totalize(energy, fraction: fraction)
      // Daily and annual sums are also calculated in
      // writeHourlyResults() and writeDailyResults()
    } else {
      // Only the annual sums are calculated.
      annualRadiation.totalize(solar, fraction: fraction)
      annualEnergy.totalize(energy, fraction: fraction)
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
    let columns = [SolarRadiation.columns, ThermalEnergy.columns,
                   ElectricPower.columns, Parasitics.columns,
                   FuelConsumption.columns].joined()
    let names: String = columns.map { $0.0 }.joined(separator: ",")
    let units: String = columns.map { $0.1 }.joined(separator: ",")
    // if dateFormatter != nil {
    return ("Date,Time," + names, "_,_," + units)
    // }
    // return (names, units)
  }

  private var headersHourly: (name: String, unit: String) {
    let columns = [SolarRadiation.columns, ThermalEnergy.columns,
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
    let columns = [SolarRadiation.columns, ThermalEnergy.columns,
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
      dailyRadiation.values, dailyEnergy.thermal.values,
      dailyEnergy.electric.values, dailyEnergy.parasitics.values,
      dailyEnergy.fuel.values].joined()
      .joined(separator: ",") + .lineBreak
    dailyResultsStream?.write(csv)
    annualEnergy.totalize(dailyEnergy, fraction: 24)
    annualRadiation.totalize(dailyRadiation, fraction: 24)
    dailyEnergy.reset()
    dailyRadiation.reset()
  }

  private func writeHourlyResults() {
    let csv = dateString + .separator + [
      hourlyRadiation.values, hourlyEnergy.thermal.values,
      hourlyEnergy.electric.values, hourlyEnergy.parasitics.values,
      hourlyEnergy.fuel.values].joined()
      .joined(separator: .separator) + .lineBreak
    hourlyResultsStream?.write(csv)
    dailyEnergy.totalize(hourlyEnergy, fraction: 1 / 24)
    dailyRadiation.totalize(hourlyRadiation, fraction: 1 / 24)
    hourCounter += 1
    hourlyEnergy.reset()
    hourlyRadiation.reset()
  }

  private func writeIntermediateResults(
    status: Plant.PerformanceData, energy: Energy,
    solar: SolarRadiation, date: Date)
  {
    guard let stream = allResultsStream,
      let stream2 = allResultsStream2 else { return }
    let dateString = dateFormatter.string(from: date)
 
    let csv1 = dateString + .separator + solar.csv
      + energy.thermal.csv + energy.electric.csv
      + energy.parasitics.csv + energy.fuel.csv
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
