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
import SQLite
import Utility

public final class PerformanceDataRecorder {

#if DEBUG && !os(Windows)
  let animation = NinjaProgressAnimation(stream: stdoutStream)
#endif

  let interval = Simulation.time.steps
  let stride: Int
  let mode: Mode

  public enum Mode {
    case database, csv, inMemory
    case custom(interval: DateGenerator.Interval)

    var hasFileOutput: Bool {
      if case .inMemory = self { return false }  
      return true
    }

    var hasHistory: Bool {
      if case .database = self { return true }
      if case .inMemory = self { return true }
      return false
    }
  }

  private var iso8601_Hourly: String = ""
  private var iso8601_Interval: String = ""
  private var stringBuffer: String = ""

  public var log: PerformanceLog?

  private var db: Connection? = nil
  /// Totals
  private var annualEnergy = Energy()
  private var annualRadiation = SolarRadiation()
  /// Volatile subtotals
  private var hourlyEnergy = Energy()
  private var hourlyRadiation = SolarRadiation()
  /// Sum of hourly values
  private var dailyEnergy = Energy()
  private var dailyRadiation = SolarRadiation()

  private var customIntervalEnergy = Energy()
  private var customIntervalRadiation = SolarRadiation()

  /// All past states of the plant
  private var performanceHistory: [PerformanceData] = []
  private var energyHistory: [Energy] = []

  public init() {
    self.mode = .inMemory
    self.stride = 1
  }

  public init(name: String? = nil, path: String? = nil, output: Mode) {

    let 💾 = FileManager.default
    let suffix: String

    if case .inMemory = output {
      performanceHistory.reserveCapacity(8760 * interval.rawValue)
      energyHistory.reserveCapacity(8760 * interval.rawValue)
    }

    if case .custom(let i) = output, i.isMultiple(of: interval) {
      self.stride = interval.rawValue / i.rawValue
      self.mode = output
    } else {
      self.mode = output
      self.stride = 1
    }

    let urlDir = URL(fileURLWithPath: path ?? 💾.currentDirectoryPath)

    if output.hasFileOutput, !urlDir.hasDirectoryPath {
      print("Invalid path for results: \(urlDir.path)\n")
      print("There will be no output files.\n")
      return
    }

    if let name = name {
      suffix = name
    } else {
      let contents = try? 💾.contentsOfDirectory(atPath: urlDir.path)

      let oldResults = contents?.filter { $0.hasSuffix("ly.csv") }

      let numbers = oldResults?.compactMap { filename in
        return Int(filename.filter(\.isWholeNumber))
      }
      let n = (numbers?.max() ?? 0) + 1
      suffix = String(format: "%03d", n)
    }

    var urls = [URL]()

    if case .database = output {
      let url = urlDir.appendingPathComponent("Results_\(suffix).sqlite3") 
      self.db = try! Connection(url.path)
      urls = [url]
    }

    if case .csv = output  {
      let tableHeader = headers.name + .lineBreak + headers.unit + .lineBreak
      let dailyResultsURL = urlDir.appendingPathComponent("Results_\(suffix)_daily.csv")
      let hourlyResultsURL = urlDir.appendingPathComponent("Results_\(suffix)_hourly.csv")
      self.dailyResultsStream = OutputStream(url: dailyResultsURL, append: false)
      self.hourlyResultsStream = OutputStream(url: hourlyResultsURL, append: false)
      self.dailyResultsStream?.open()
      self.hourlyResultsStream?.open()
      self.dailyResultsStream?.write(tableHeader)
      self.hourlyResultsStream?.write(tableHeader)

      urls = [dailyResultsURL, hourlyResultsURL]      
    }

    if case .custom(let i) = mode {
      let startTime = repeatElement("0", count: headers.count)
        .joined(separator: .separator)
      let intervalTime = repeatElement("\(i.fraction)", count: headers.count)
        .joined(separator: .separator)
      let tableHeader =
        "wxDVFileHeaderVer.1" + .lineBreak
        + headers.name + .lineBreak
        + startTime + .lineBreak
        + intervalTime + .lineBreak
        + headers.unit + .lineBreak

      let resultsURL = urlDir.appendingPathComponent("Results_\(suffix)_\(i).csv")

      customIntervalStream = OutputStream(url: resultsURL, append: false)
      stringBuffer.reserveCapacity(200 * 8760 * i.rawValue)
      customIntervalStream?.open()
      customIntervalStream?.write(tableHeader)
      urls = [resultsURL]
    }
    if case .inMemory = output { return } 
    print("Results: \(urlDir.path)/")
    urls.map(\.lastPathComponent).enumerated()
      .forEach { print("  \($0.offset+1).\t", $0.element) }
    print()
  }

  deinit {
    dailyResultsStream?.close()
    hourlyResultsStream?.close()
    customIntervalStream?.close()
  }

  public func clearResults() {
    annualEnergy.zero()
    annualRadiation.zero()
    dailyEnergy.zero()
    dailyRadiation.zero()
    hourlyEnergy.zero()
    hourlyRadiation.zero()
    energyHistory.removeAll(keepingCapacity: true)
    performanceHistory.removeAll(keepingCapacity: true)
  }

  public func printResult() {
    print("")
    print(decorated("Annual results"))
    print(annualRadiation.prettyDescription)
    print(annualEnergy.prettyDescription)
  }

  func callAsFunction(
    _ ts: DateTime, meteo: MeteoData, status: PerformanceData, energy: Energy
  ) {
    if mode.hasHistory {
      self.performanceHistory.append(status)
      self.energyHistory.append(energy)
    }

    let solar = SolarRadiation(
      meteo: meteo, cosTheta: status.collector.cosTheta
    )

    if mode.hasFileOutput {

      defer { intervalCounter += 1 }

      if intervalCounter == 1 {
        iso8601_Hourly = ts.description 
      }

      if case .custom(_) = mode {
        if stride == 1 || intervalCounter % stride == 1 {
          iso8601_Interval = ts.description
        }
        let fraction = 1 / Double(stride)
        customIntervalRadiation.totalize(solar, fraction: fraction)
        customIntervalEnergy.totalize(energy, fraction: fraction)

        if stride == 1 || intervalCounter % stride == 0 {
          let csv = generateValues()
          stringBuffer.append(contentsOf: csv)      
          customIntervalRadiation.zero()
          customIntervalEnergy.zero()
        }
      }
    }

    if case .csv = mode {
      hourlyRadiation.totalize(solar, fraction: interval.fraction)
      hourlyEnergy.totalize(energy, fraction: interval.fraction)
      // Daily and annual sum calculations see counters
    } else {
      // Only the annual sums are calculated.
      annualRadiation.totalize(solar, fraction: interval.fraction)
      annualEnergy.totalize(energy, fraction: interval.fraction)
    }

#if DEBUG && !os(Windows)
    if progress != ts.month {
      progress = ts.month
      animation.update(
        step: progress,
        total: 12,
        text: "recording month."
      )
    }
#endif
  }

  public func complete() {
    log = PerformanceLog(
      energy: annualEnergy,
      radiation: annualRadiation,
      energyHistory: energyHistory,
      performanceHistory: performanceHistory
    )

    if case .custom(_) = mode {
      customIntervalStream?.write(stringBuffer)
      stringBuffer.removeAll()
    }          

    if case .database = mode {
      storeInDB()
    }

  #if DEBUG && !os(Windows)
    animation.clear()
  #endif
  }

#if DEBUG && !os(Windows)
  private var progress: Int = 0
#endif

  private var hourCounter: Int = 1 {
    didSet {
      if case .csv = mode, hourCounter > 24 {
        annualEnergy.totalize(dailyEnergy, fraction: 1)
        annualRadiation.totalize(dailyRadiation, fraction: 1)

        let csv = generateDailyValues()
        dailyResultsStream?.write(csv)

        hourlyResultsStream?.write(stringBuffer)
        stringBuffer.removeAll(keepingCapacity: true)

        dailyEnergy.zero()
        dailyRadiation.zero()

        hourCounter = 1
      }
    }
  }

  private var intervalCounter: Int = 1 {
    didSet {
      if case .csv = mode, intervalCounter > interval.rawValue {
        dailyEnergy.totalize(hourlyEnergy, fraction: 1)
        dailyRadiation.totalize(hourlyRadiation, fraction: 1)

        let csv = generateHourlyValues()
        // Will be written together with the daily results
        stringBuffer.append(contentsOf: csv)        

        hourlyEnergy.zero()
        hourlyRadiation.zero()

        hourCounter += 1
        intervalCounter = 1
      }
    }
  }

  // MARK: Output database

  public func storeInDB() {
    guard let db = db else { return }

    func createTable(name: String, columns: [String]) {
      let table = Table(name)
      let expressions = columns.map { Expression<Double>($0) }
      try! db.run(
        table.create { t in
          expressions.forEach { t.column($0) }
        })
    }

    let performanceData = PerformanceData.columns.map(\.0)
    let energy = Energy.columns.map(\.0)
    createTable(name: "PerformanceData", columns: performanceData)
    createTable(name: "Energy", columns: energy)

    let p1 = repeatElement("?", count: performanceData.count).joined(separator: ",")
    try! db.transaction {
      let stmt = try! db.prepare("INSERT INTO PerformanceData VALUES (\(p1))")
      for entry in performanceHistory { try! stmt.run(entry.numericalForm) }
    }

    let p2 = repeatElement("?", count: energy.count).joined(separator: ",")
    try! db.transaction {
      let stmt = try! db.prepare("INSERT INTO Energy VALUES (\(p2))")
      for entry in energyHistory { try! stmt.run(entry.numericalForm) }
    }
  }

  // MARK: Output Streams

  private var customIntervalStream: OutputStream?

  private var dailyResultsStream: OutputStream?
  private var hourlyResultsStream: OutputStream?

  // MARK: Table headers

  private var headers: (name: String, unit: String, count: Int) {
    let columns = [SolarRadiation.columns, Energy.columns].joined()
    let names: String = columns.map { $0.0 }.joined(separator: ",")
    let units: String = columns.map { $0.1 }.joined(separator: ",")
    return ("DateTime," + names, "_," + units, columns.count)
  }

  // MARK: Write Results

  private func generateDailyValues() -> String {
    return iso8601_Hourly.dropFirst(3).prefix(10) + .separator
      + [dailyRadiation.values, dailyEnergy.values]
      .joined().joined(separator: ",") + .lineBreak
  }

  private func generateHourlyValues() -> String {
    return iso8601_Hourly.dropFirst(3) + .separator
      + [hourlyRadiation.values, hourlyEnergy.values]
      .joined().joined(separator: .separator) + .lineBreak
  }

  private func generateValues() -> String {
    return iso8601_Interval.dropFirst(3) + .separator
      + [customIntervalRadiation.values, customIntervalEnergy.values]
      .joined().joined(separator: .separator) + .lineBreak
  }
}

extension OutputStream {
  @_transparent func write(_ string: String) {
    let bytes = [UInt8](string.utf8)
    let _ = write(bytes, maxLength: bytes.count)
  }
}
