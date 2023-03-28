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
  /// Specifies what the output is
  let mode: Mode

  var range: DateInterval = Simulation.time.dateInterval!

  public enum Mode {
    case database
    case inMemory, none
    case custom(interval: DateSeries.Frequence)
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

  /// sqlite file
  // private var db: Connection? = nil

  private var xlsx: Workbook? = nil
  /// Totals
  private var annualPerformance = PlantPerformance()
  private var annualRadiation = Insolation()
  /// Sum of hourly values
  private var hourlyPerformance = PlantPerformance()

  /// All past states of the plant
  private var status: [Status] = []
  private var performance: [PlantPerformance] = []
  private var sun: [Insolation] = []

  public init(mode: Mode) {
    self.mode = mode
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
    // let outputMode = Mode.custom(interval: interval)
    #endif

    if case .inMemory = outputMode {
      status.reserveCapacity(8760 * interval.rawValue)
      performance.reserveCapacity(8760 * interval.rawValue)
      sun.reserveCapacity(8760 * interval.rawValue)
    }

    if case .custom(let i) = outputMode, i.isMultiple(of: interval) {
      self.mode = outputMode
    } else {
      self.mode = outputMode
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
      let tableHeader: [UInt8] = [UInt8](headers.name.utf8) 
        + ln + [UInt8](headers.unit.utf8) + ln
      let resultsURL = urlDir.appendingPathComponent(
        "\(name)\(suffix)_hourly.csv")
      resultsStream = OutputStream(url: resultsURL, append: false)
      resultsStream?.open()
      _ = resultsStream?.write(tableHeader, maxLength: tableHeader.count)

      urls = [resultsURL]
    }

    if case .custom(let i) = mode {
      let startTime = repeatElement("0", count: headers.count + 1)
        .joined(separator: ",")
      let fraction = String(format: "%.5f", i.fraction)
      let intervalTime = repeatElement(fraction, count: headers.count + 1)
        .joined(separator: ",")
      let tableHeader: [UInt8] =
        [UInt8]("wxDVFileHeaderVer.1".utf8) + ln 
        + [UInt8](headers.name.utf8) + ln
        + [UInt8](startTime.utf8) + ln
        + [UInt8](intervalTime.utf8) + ln
        + [UInt8](headers.unit.utf8) + ln

      let resultsURL = urlDir.appendingPathComponent("\(name)\(suffix)_\(i).csv")

      customIntervalStream = OutputStream(url: resultsURL, append: false)
      customIntervalStream?.open()
      _ = customIntervalStream?.write(tableHeader, maxLength: tableHeader.count)
      urls = [resultsURL]
    }
    if !mode.hasFileOutput { return }
    print("Results: \(urlDir.path)/")
    urls.map(\.lastPathComponent).enumerated()
      .forEach { print("  \($0.offset+1).\t", $0.element) }
    print()
  }

  deinit {
    resultsStream?.close()
    customIntervalStream?.close()
  }

  public func clearResults() {
    performance.removeAll(keepingCapacity: true)
    status.removeAll(keepingCapacity: true)
    sun.removeAll(keepingCapacity: true)
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
    self.status.append(status)
    self.performance.append(energy)
    self.sun.append(Insolation(meteo: meteo))

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

    let s = interval.rawValue
    
    for (date, i) in zip(DateSeries(range: range, interval: .hour),
      stride(from: 0, to: performance.count-s, by: s)) {
      hourlyPerformance.totalize(performance[i..<i+s], fraction: interval.fraction)
      let hourlyRadiation = sun[i..<i+s].hourly(fraction: interval.fraction)
      let row = [UInt8](DateTime(date).commaSeparatedValues.utf8) 
        + comma + [UInt8](hourlyRadiation.commaSeparatedValues.utf8)
        + comma + [UInt8](hourlyPerformance.commaSeparatedValues.utf8) 
        + ln
      _ = resultsStream?.write(row, maxLength: row.count)
    }
   
    annualPerformance.totalize(performance, fraction: interval.fraction)
    annualRadiation = sun.hourly(fraction: interval.fraction)
    if case .database = mode { storeInDB() }
    if case .excel = mode { writeExcel() }

    printResult()
    return Recording(
      startDate: range.start, performance: annualPerformance,
      irradiance: annualRadiation, performanceHistory: performance,
      statusHistory: status)
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

    status.indices.forEach { i in
      ws1.write(.datetime(date), [i + 1, 0])
      ws1.write(sun[i].values, row: i + 1, col: 1)
      ws1.write(status[i].modes, row: i + 1, col: 4)
      ws1.write(status[i].values, row: i + 1, col: 4 + modesCount)
      date.addTimeInterval(interval)
    }

    date = Simulation.time.dateInterval!.start

    performance.indices.forEach { i in
      ws2.write(.datetime(date), [i + 1, 0])
      ws2.write(performance[i].values, row: i + 1, col: 1)
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
  private var resultsStream: OutputStream?

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
    let names: String = measurements.map(\.name).joined(separator: ",")
    let units: String = measurements.map(\.unit).joined(separator: ",")
    return ("Month,Day,Hour," + names, "_,_,_," + units, measurements.count)
  }


}

#if os(Windows)
fileprivate let ln: [UInt8] = [UInt8(ascii: "\r"), UInt8(ascii: "\n")] 
#else
fileprivate let ln: [UInt8] = [UInt8(ascii: "\n")] 
#endif  
fileprivate let comma: [UInt8] = [UInt8(ascii: ",")] 

