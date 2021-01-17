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
import xlsxwriter

public final class Recorder {

#if DEBUG && !os(Windows)
  /// Tracking the month
  private var progress: Int = 0
#endif
  /// Number of values per hour
  private let interval = Simulation.time.steps
  /// Changes the resolution of the output
  private let stride: Int
  /// Specifies what the output is
  let mode: Mode

  public enum Mode {
    case database, csv, excel, inMemory
    case custom(interval: DateGenerator.Interval)

    var hasFileOutput: Bool {
      if case .inMemory = self { return false }  
      return true
    }

    var hasHistory: Bool {
      if case .excel = self { return true }
      if case .database = self { return true }
      if case .inMemory = self { return true }
      return false
    }
  }

  private var iso8601_Hourly: String = ""
  private var iso8601_Interval: String = ""
  private var stringBuffer: String = ""
  /// sqlite file
  private var db: Connection? = nil

  private var xlsx: Workbook? = nil
  /// Totals
  private var annualPerformance = Performance()
  private var annualRadiation = SolarRadiation()
  /// Volatile subtotals
  private var hourlyPerformance = Performance()
  private var hourlyRadiation = SolarRadiation()
  /// Sum of hourly values
  private var dailyPerformance = Performance()
  private var dailyRadiation = SolarRadiation()

  private var customIntervalPerformance = Performance()
  private var customIntervalRadiation = SolarRadiation()

  /// All past states of the plant
  private var statusHistory: [Status] = []
  private var performanceHistory: [Performance] = []
  private var sunHistory: [SolarRadiation] = []

  public init(mode: Mode) {
    self.mode = mode
    self.stride = 1
    self.parent = ""
  }
  /// Common prefix of output
  var name = "Results_"
  /// Directory path of output
  private let parent: String
  /// Output name suffix
  private var suffix: String = "001"

  public init(
   customName: String? = nil,
   customPath: String? = nil,
   outputMode: Mode
  ) {
    self.parent = customPath ?? ""
        
    if case .inMemory = outputMode {
      statusHistory.reserveCapacity(8760 * interval.rawValue)
      performanceHistory.reserveCapacity(8760 * interval.rawValue)
    }

    if case .custom(let i) = outputMode, i.isMultiple(of: interval) {
      self.stride = interval.rawValue / i.rawValue
      self.mode = outputMode
    } else {
      self.mode = outputMode
      self.stride = 1
    }

    let urlDir = URL(fileURLWithPath: parent)

    if outputMode.hasFileOutput, !urlDir.hasDirectoryPath {
      print("Invalid path for results: \(urlDir.path)\n")
      print("There will be no output files.\n")
    }

    if let name = customName {
      self.name = name
    } else {
      let numbers = checkForResults(atPath: urlDir.path)
      let n = (numbers?.max() ?? 0) + 1
      self.suffix = String(format: "%03d", n)
    }

    var urls = [URL]()

    if case .excel = outputMode {
      let url = urlDir.appendingPathComponent("\(name)\(suffix).xlsx") 
      self.xlsx = Workbook(name: url.path)
      urls = [url]
    }

    if case .database = outputMode {
      let url = urlDir.appendingPathComponent("\(name)\(suffix).sqlite3") 
      self.db = try! Connection(url.path)
      urls = [url]
    }

    if case .csv = outputMode  {
      let tableHeader = headers.name + .lineBreak + headers.unit + .lineBreak
      let dailyResultsURL = urlDir.appendingPathComponent("\(name)\(suffix)_daily.csv")
      let hourlyResultsURL = urlDir.appendingPathComponent("\(name)\(suffix)_hourly.csv")
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

      let resultsURL = urlDir.appendingPathComponent("\(name)\(suffix)_\(i).csv")

      customIntervalStream = OutputStream(url: resultsURL, append: false)
      stringBuffer.reserveCapacity(200 * 8760 * i.rawValue)
      customIntervalStream?.open()
      customIntervalStream?.write(tableHeader)
      urls = [resultsURL]
    }
    if case .inMemory = outputMode { return } 
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
    annualPerformance.zero()
    annualRadiation.zero()
    dailyPerformance.zero()
    dailyRadiation.zero()
    hourlyPerformance.zero()
    hourlyRadiation.zero()
    performanceHistory.removeAll(keepingCapacity: true)
    statusHistory.removeAll(keepingCapacity: true)
  }

  public func printResult() {
    print("")
    print(decorated("Annual results"))
    print(annualRadiation.prettyDescription)
    print(annualPerformance.prettyDescription)
  }
   
  func callAsFunction(
    _ ts: DateTime, meteo: MeteoData, status: Status, energy: Performance
  ) {
    if mode.hasHistory {
      self.statusHistory.append(status)
      self.performanceHistory.append(energy)
    }

    let solar = SolarRadiation(
      meteo: meteo, cosTheta: status.collector.cosTheta
    )
    
    self.sunHistory.append(solar)

    if mode.hasFileOutput {

      defer { intervalCounter += 1 }

      if intervalCounter == 1 {
        iso8601_Hourly = String(ts.description.dropFirst(3))
      }

      if case .custom(_) = mode {
        if stride == 1 || intervalCounter % stride == 1 {
          iso8601_Interval = ts.description
        }
        let fraction = 1 / Double(stride)
        customIntervalRadiation.totalize(solar, fraction: fraction)
        customIntervalPerformance.totalize(energy, fraction: fraction)

        if stride == 1 || intervalCounter % stride == 0 {
          let csv = generateValues()
          stringBuffer.append(contentsOf: csv)      
          customIntervalRadiation.zero()
          customIntervalPerformance.zero()
        }
      }
    }

    if case .csv = mode {
      hourlyRadiation.totalize(solar, fraction: interval.fraction)
      hourlyPerformance.totalize(energy, fraction: interval.fraction)
      // Daily and annual sum calculations see counters
    } else {
      // Only the annual sums are calculated.
      annualRadiation.totalize(solar, fraction: interval.fraction)
      annualPerformance.totalize(energy, fraction: interval.fraction)
    }

#if DEBUG && !os(Windows)
    if progress != ts.month {
      progress = ts.month
      print(" [\(progress)/\(12)] recording month…", terminator: "\r")
      fflush(stdout)   
    }
#endif
  }

  public func finish() -> Recording {
#if DEBUG && !os(Windows)
    let clearLineString = "\u{001B}[2K"
    print(clearLineString, terminator: "\r")
    fflush(stdout)
#endif
    if case .custom(_) = mode {
      customIntervalStream?.write(stringBuffer)
      stringBuffer.removeAll()
    }          

    if case .database = mode {
      storeInDB()
    }

    return Recording(
      performance: annualPerformance,
      radiation: annualRadiation,
      performanceHistory: performanceHistory,
      statusHistory: statusHistory
    )
  }

  private func checkForResults(atPath path: String) -> [Int]? {
    let 💾 = FileManager.default

    let contents = try? 💾.contentsOfDirectory(atPath: path)

    let results = contents?.filter { $0.hasPrefix(name) }

    return results?.compactMap { filename in
      return Int(filename.filter(\.isWholeNumber))
    }
  }

  private var hourCounter: Int = 1 {
    didSet {
      if case .csv = mode, hourCounter > 24 {
        annualPerformance.totalize(dailyPerformance, fraction: 1)
        annualRadiation.totalize(dailyRadiation, fraction: 1)

        let csv = generateDailyValues()
        dailyResultsStream?.write(csv)

        hourlyResultsStream?.write(stringBuffer)
        stringBuffer.removeAll(keepingCapacity: true)

        dailyPerformance.zero()
        dailyRadiation.zero()

        hourCounter = 1
      }
    }
  }

  private var intervalCounter: Int = 1 {
    didSet {
      if case .csv = mode, intervalCounter > interval.rawValue {
        dailyPerformance.totalize(hourlyPerformance, fraction: 1)
        dailyRadiation.totalize(hourlyRadiation, fraction: 1)

        let csv = generateHourlyValues()
        // Will be written together with the daily results
        stringBuffer.append(contentsOf: csv)        

        hourlyPerformance.zero()
        hourlyRadiation.zero()

        hourCounter += 1
        intervalCounter = 1
      }
    }
  }

 public func writeExcel() {
    guard let wb = xlsx else { return }
    let f1 = wb.addFormat().set(num_format: "d mmm hh:mm")
    let f2 = wb.addFormat().set(num_format: "0.0")

    let statusCaptions = ["Date"] 
      + SolarRadiation.columns.map(\.0) 
      + Status.modes + Status.columns.map(\.0)
    let statusCount = statusCaptions.count
    let modesCount = Status.modes.count
    let energyCaptions = ["Date"] 
      + Performance.columns.map(\.0)
    let energyCount = energyCaptions.count

    let ws1 = wb.addWorksheet()
      .column("A:A", width: 12, format: f1)
      .column([1, statusCount], width: 8, format: f2)
      .hide_columns(statusCount + 1)
      .write(statusCaptions, row: 0)

    let ws2 = wb.addWorksheet()
      .column("A:A", width: 12, format: f1)
      .column([1, energyCount], width: 8, format: f2)
      .hide_columns(energyCount + 1)
      .write(energyCaptions, row: 0)
    
    let interval = Simulation.time.steps.interval
    var date = Simulation.time.firstDateOfOperation!

    statusHistory.indices.forEach { i in
      ws1.write(.datetime(date), [i+1,0])
      ws1.write(sunHistory[i].numericalForm, row: i+1, col: 1)
      ws1.write(statusHistory[i].modes, row: i+1, col: 5)
      ws1.write(statusHistory[i].numericalForm, row: i+1, col: 5 + modesCount)
      date.addTimeInterval(interval)
    }

    date = Simulation.time.firstDateOfOperation!
    ws1.autofilter(range: [0,0,statusHistory.count+1, statusCount])

    performanceHistory.indices.forEach  { i in
      ws2.write(.datetime(date), [i+1,0])
      ws2.write(performanceHistory[i].numericalForm, row: i+1, col: 1)
      date.addTimeInterval(interval)
    }

    ws2.autofilter(range: [0,0,performanceHistory.count+1, energyCount])
    wb.close()
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

    let status = Status.columns.map(\.0)
    let energy = Performance.columns.map(\.0)
    createTable(name: "PerformanceData", columns: status)
    createTable(name: "Performance", columns: energy)

    let p1 = repeatElement("?", count: status.count).joined(separator: ",")
    try! db.transaction {
      let stmt = try! db.prepare("INSERT INTO PerformanceData VALUES (\(p1))")
      for entry in statusHistory { try! stmt.run(entry.numericalForm) }
    }

    let p2 = repeatElement("?", count: energy.count).joined(separator: ",")
    try! db.transaction {
      let stmt = try! db.prepare("INSERT INTO Performance VALUES (\(p2))")
      for entry in performanceHistory { try! stmt.run(entry.numericalForm) }
    }
  }

  // MARK: Output Streams

  private var customIntervalStream: OutputStream?
  private var dailyResultsStream: OutputStream?
  private var hourlyResultsStream: OutputStream?

  // MARK: Table headers

  private var headers: (name: String, unit: String, count: Int) {
    let columns = [SolarRadiation.columns, Performance.columns].joined()
    let names: String = columns.map { $0.0 }.joined(separator: ",")
    let units: String = columns.map { $0.1 }.joined(separator: ",")
    return ("DateTime," + names, "_," + units, columns.count)
  }

  // MARK: Write Results

  private func generateDailyValues() -> String {
    iso8601_Hourly.prefix(10) + .separator
      + [dailyRadiation.values, dailyPerformance.values]
      .joined().joined(separator: ",") + .lineBreak
  }

  private func generateHourlyValues() -> String {
    iso8601_Hourly + .separator
      + [hourlyRadiation.values, hourlyPerformance.values]
      .joined().joined(separator: .separator) + .lineBreak
  }

  private func generateValues() -> String {
    iso8601_Interval + .separator
      + [customIntervalRadiation.values, customIntervalPerformance.values]
      .joined().joined(separator: .separator) + .lineBreak
  }
}

extension OutputStream {
  @_transparent func write(_ string: String) {
    let bytes = [UInt8](string.utf8)
    let _ = write(bytes, maxLength: bytes.count)
  }
}
