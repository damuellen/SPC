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
// import SQLite
import xlsxwriter

/// A class that creates a recording of the performance data.
public final class Historian {

  #if DEBUG && !os(Windows)
  /// Tracking the month
  private var progress: Int = 0
  #endif
  /// Number of values per hour
  private let interval = Simulation.time.steps
  private var intervalCounter: Int = 1
  private var hourCounter: Int = 1
  /// Changes the resolution of the output
  private let stride: Int
  /// Specifies what the output is
  let mode: Mode

  var startDate: Date? = Simulation.time.dateInterval?.start

  public enum Mode {
    case database
    case inMemory, none
    case custom(interval: DateSequence.Interval)
    case csv
    case excel
    var hasFileOutput: Bool {
      if case .none = self { return false }
      if case .inMemory = self { return false }
      return true
    }

    var hasHistory: Bool {
      #if DEBUG && !os(Windows)
      return true
      #else
      if case .excel = self { return true }
      if case .database = self { return true }
      if case .inMemory = self { return true }
      return false
      #endif
    }
  }

  private var iso8601_Hourly: String = ""
  private var iso8601_Interval: String = ""
  private var stringBuffer: String = ""

  /// sqlite file
  // private var db: Connection? = nil

  private var xlsx: Workbook? = nil
  /// Totals
  private var annualPerformance = PlantPerformance()
  private var annualRadiation = Insolation()
  /// Volatile subtotals
  private var hourlyPerformance = PlantPerformance()
  private var hourlyRadiation = Insolation()
  /// Sum of hourly values
  private var dailyPerformance = PlantPerformance()
  private var dailyRadiation = Insolation()

  private var customIntervalPerformance = PlantPerformance()
  private var customIntervalRadiation = Insolation()

  /// All past states of the plant
  private var statusHistory: [Status] = []
  private var performanceHistory: [PlantPerformance] = []
  private var sunHistory: [Insolation] = []

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
    customName: String? = nil, customPath: String? = nil, outputMode: Mode
  ) {
    self.parent = customPath ?? ""

    #if DEBUG
    let outputMode = Mode.custom(interval: interval)
    #endif

    if case .inMemory = outputMode {
      statusHistory.reserveCapacity(8760 * interval.rawValue)
      performanceHistory.reserveCapacity(8760 * interval.rawValue)
      sunHistory.reserveCapacity(8760 * interval.rawValue)
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
    // if case .database = outputMode {
    //   let url = urlDir.appendingPathComponent("\(name)\(suffix).sqlite3")
    //   self.db = try! Connection(url.path)
    //   urls = [url]
    // }
    if case .csv = outputMode {
      let tableHeader = headers.name + .lineBreak + headers.unit + .lineBreak
      let dailyResultsURL = urlDir.appendingPathComponent(
        "\(name)\(suffix)_daily.csv")
      let hourlyResultsURL = urlDir.appendingPathComponent(
        "\(name)\(suffix)_hourly.csv")
      self.dailyResultsStream = OutputStream(
        url: dailyResultsURL, append: false)
      self.hourlyResultsStream = OutputStream(
        url: hourlyResultsURL, append: false)
      self.dailyResultsStream?.open()
      self.hourlyResultsStream?.open()
      self.dailyResultsStream?.write(tableHeader)
      self.hourlyResultsStream?.write(tableHeader)

      urls = [dailyResultsURL, hourlyResultsURL]
    }

    if case .custom(let i) = mode {
      let startTime = repeatElement("0", count: headers.count + 1)
        .joined(separator: .separator)
      let fraction = String(format: "%.5f", i.fraction)
      let intervalTime = repeatElement(fraction, count: headers.count + 1)
        .joined(separator: .separator)
      let tableHeader =
        "wxDVFileHeaderVer.1" + .lineBreak + headers.name + .lineBreak
        + startTime + .lineBreak + intervalTime + .lineBreak + headers.unit
        + .lineBreak

      let resultsURL = urlDir.appendingPathComponent("\(name)\(suffix)_\(i).csv")

      customIntervalStream = OutputStream(url: resultsURL, append: false)
      stringBuffer.reserveCapacity(200 * 8760 * i.rawValue)
      customIntervalStream?.open()
      customIntervalStream?.write(tableHeader)
      urls = [resultsURL]
    }
    if !mode.hasFileOutput { return }
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

  func printResult() {
    print("")
    print(decorated("Annual results"))
    print(annualRadiation.prettyDescription)
    print(annualPerformance.prettyDescription)
  }

  func callAsFunction(
    _ ts: DateTime, meteo: MeteoData, status: Status, energy: PlantPerformance
  ) {
    let solar = Insolation(meteo: meteo)

    if mode.hasHistory {
      self.statusHistory.append(status)
      self.performanceHistory.append(energy)
      self.sunHistory.append(solar)
    }

    if mode.hasFileOutput {

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
          #if DEBUG
          let s = status.formattedValues.joined(separator: ",")
          stringBuffer.append(contentsOf: csv + "," + s + .lineBreak)
          #else
          stringBuffer.append(contentsOf: csv + .lineBreak)
          #endif
          customIntervalStream?.write(stringBuffer)
          stringBuffer.removeAll()
          customIntervalRadiation.zero()
          customIntervalPerformance.zero()
        }
      }
    }

    intervalCounter += 1

    if case .csv = mode {
      if intervalCounter > interval.rawValue {
        dailyPerformance.totalize(hourlyPerformance, fraction: 1)
        dailyRadiation.totalize(hourlyRadiation, fraction: 1)

        let csv = generateHourlyValues() + .lineBreak
        // Will be written together with the daily results
        stringBuffer.append(contentsOf: csv)

        hourlyPerformance.zero()
        hourlyRadiation.zero()

        hourCounter += 1
        intervalCounter = 1
      }

      if hourCounter > 24 {
        annualPerformance.totalize(dailyPerformance, fraction: 1)
        annualRadiation.totalize(dailyRadiation, fraction: 1)

        let csv = generateDailyValues() + .lineBreak
        dailyResultsStream?.write(csv)

        hourlyResultsStream?.write(stringBuffer)
        stringBuffer.removeAll(keepingCapacity: true)

        dailyPerformance.zero()
        dailyRadiation.zero()

        hourCounter = 1
      }
      hourlyRadiation.totalize(solar, fraction: interval.fraction)
      hourlyPerformance.totalize(energy, fraction: interval.fraction)
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
    printResult()

    if case .custom(_) = mode {
      customIntervalStream?.write(stringBuffer)
      stringBuffer.removeAll()
    }

    if case .database = mode { storeInDB() }
    if case .excel = mode { writeExcel() }

    return Recording(
      startDate: startDate!, performance: annualPerformance,
      irradiance: annualRadiation, performanceHistory: performanceHistory,
      statusHistory: statusHistory)
  }

  private func checkForResults(atPath path: String) -> [Int]? {
    let 💾 = FileManager.default

    let contents = try? 💾.contentsOfDirectory(atPath: path)

    let results = contents?.filter { $0.hasPrefix(name) }

    return results?
      .compactMap { filename in
        let name = filename.split(separator: "_").dropLast().joined()
        return Int(name.filter(\.isWholeNumber))
      }
  }

  private func writeExcel() {
    guard let wb = xlsx else { return }
    print("Excel file creation started.")
    let now = Date()
    let f1 = wb.addFormat().set(num_format: "hh:mm  dd.mm")
    let f0 = wb.addFormat().set(num_format: "0")
    let f2 = wb.addFormat().set(num_format: "0.0")
    let f3 = wb.addFormat().set(num_format: "0.00")
    let f4 = wb.addFormat().set(num_format: 9)
    let statusCaptions =
      ["Time  Date"] + Insolation.measurements.map(\.0) + Status.modes
      + Status.measurements.map(\.0)
    let statusCount = statusCaptions.count
    let modesCount = Status.modes.count
    let energyCaptions = ["Date"] + PlantPerformance.measurements.map(\.0)
    let energyCount = energyCaptions.count

    let ws1 = wb.addWorksheet(name: "Status")
      .column("A:A", width: 13, format: f1)
      .column("B:D", width: 6, format: f0)
      .column("E:G", width: 17, format: f3)
      .column("H:H", width: 6, format: f0)
      .column("I:I", width: 6, format: f3)
      .column("J:J", width: 11, format: f4)
      .column([10, statusCount], width: 15, format: f2)
      .hide_columns(statusCount)
      .write(statusCaptions, row: 0)

    let ws2 = wb.addWorksheet(name: "Performance")
      .column("A:A", width: 13, format: f1)
      .column([1, energyCount], width: 6, format: f2)
      .hide_columns(energyCount)
      .write(energyCaptions, row: 0)

    let interval = Simulation.time.steps.interval
    var date = Simulation.time.dateInterval!.start

    statusHistory.indices.forEach { i in
      ws1.write(.datetime(date), [i + 1, 0])
      ws1.write(sunHistory[i].values, row: i + 1, col: 1)
      ws1.write(statusHistory[i].modes, row: i + 1, col: 4)
      ws1.write(statusHistory[i].values, row: i + 1, col: 4 + modesCount)
      date.addTimeInterval(interval)
    }

    date = Simulation.time.dateInterval!.start

    performanceHistory.indices.forEach { i in
      ws2.write(.datetime(date), [i + 1, 0])
      ws2.write(performanceHistory[i].values, row: i + 1, col: 1)
      date.addTimeInterval(interval)
    }
    wb.close()
    print("Excel file creation took \((-now.timeIntervalSinceNow).asString()) seconds.")
  }
  // MARK: Output database
  private func storeInDB() {
    // guard let db = db else { return }

    // func createTable(name: String, measurements: [String]) {
    //   let table = Table(name)
    //   let expressions = measurements.map { Expression<Double>($0) }
    //   try! db.run(table.create { t in expressions.forEach { t.column($0) } })
    // }

    // let status = Status.measurements.map {
    //   $0.name.replacingOccurrences(of: "|", with: "_")
    // }
    // let energy = PlantPerformance.measurements.map {
    //   $0.name.replacingOccurrences(of: "|", with: "_")
    // }
    // createTable(name: "PerformanceData", measurements: status)
    // createTable(name: "Performance", measurements: energy)

    // let p1 = repeatElement("?", count: status.count).joined(separator: ",")
    // try! db.transaction {
    //   let stmt = try! db.prepare("INSERT INTO PerformanceData VALUES (\(p1))")
    //   for entry in statusHistory { try! stmt.run(entry.values) }
    // }

    // let p2 = repeatElement("?", count: energy.count).joined(separator: ",")
    // try! db.transaction {
    //   let stmt = try! db.prepare("INSERT INTO Performance VALUES (\(p2))")
    //   for entry in performanceHistory { try! stmt.run(entry.values) }
    // }
  }
  // MARK: Output Streams

  private var customIntervalStream: OutputStream?
  private var dailyResultsStream: OutputStream?
  private var hourlyResultsStream: OutputStream?

  // MARK: Table headers

  private var headers: (name: String, unit: String, count: Int) {
    #if DEBUG
    let measurements = [
      Insolation.measurements, PlantPerformance.measurements, Status.measurements,
    ]
    .joined()
    #else
    let measurements = [Insolation.measurements, PlantPerformance.measurements].joined()
    #endif
    let names: String = measurements.map(\.name).joined(separator: .separator)
    let units: String = measurements.map(\.unit).joined(separator: .separator)
    return ("DateTime," + names, "_," + units, measurements.count)
  }

  // MARK: Write Results

  private func generateDailyValues() -> String {
    iso8601_Hourly.prefix(10) + .separator + [
      dailyRadiation.formattedValues,
      dailyPerformance.formattedValues
      ].joined().joined(separator: .separator)
  }

  private func generateHourlyValues() -> String {
    iso8601_Hourly + .separator + [
      hourlyRadiation.formattedValues,
      hourlyPerformance.formattedValues
      ].joined().joined(separator: .separator)
  }

  private func generateValues() -> String {
    iso8601_Interval + .separator + [
      customIntervalRadiation.formattedValues,
      customIntervalPerformance.formattedValues
      ].joined().joined(separator: .separator)
  }
}

extension OutputStream {
  @_transparent func write(_ string: String) {
    let bytes = [UInt8](string.utf8)
    let _ = write(bytes, maxLength: bytes.count)
  }
}
