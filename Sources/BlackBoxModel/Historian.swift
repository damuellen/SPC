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
// import SQLite
import xlsxwriter

/// A class that creates a recording of the performance data.
public final class Historian {

  #if DEBUG && !os(Windows)
  /// Tracking the day
  private var progress: Int = 0
  #endif
  /// Number of values per hour
  private let frequency = Simulation.time.steps
  /// Specifies what the output is
  let mode: Mode

  var startDate: Date { 
    Simulation.time.dateInterval?.start 
    ?? Greenwich.date(from: .init(year: BlackBoxModel.simulatedYear))!
  }

  public enum Mode {
    case database
    case inMemory
    case custom(interval: DateSeries.Frequence)
    case csv
    case excel
    var hasFileOutput: Bool {
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
  private var fileStream: OutputStream?
  private var xlsx: Workbook? = nil
  private var url: URL
  /// All past states of the plant
  private(set) var status: [Status] = []
  private(set) var performance: [PlantPerformance] = []
  private(set) var sun: [Insolation] = []

  /// Common prefix of output
  var name = "Run"

  public init(name: String? = nil, path: String? = nil, mode: Mode) {
    status.reserveCapacity(8760 * frequency.rawValue)
    performance.reserveCapacity(8760 * frequency.rawValue)
    sun.reserveCapacity(8760 * frequency.rawValue)

    self.url = URL(fileURLWithPath: path ?? "")
    self.mode = mode
    if mode.hasFileOutput, !url.hasDirectoryPath {
      print("Invalid path for results: \(url.path)\n")
      print("There will be no output files.\n")
    }

    if let name = name { self.name = name } 
    let no = sequenceNumber(atPath: url.path)

    if case .excel = mode {
      url = url.appendingPathComponent("\(self.name)_\(no)_\(frequency).xlsx")
      self.xlsx = Workbook(name: url.path)
    }
    // if case .database = mode {
    //   let url = urlDir.appendingPathComponent("\(name)\(suffix).sqlite3")
    //   self.db = try! Connection(url.path)
    //   urls = [url]
    // }
    
    if case .csv = mode {
      let header = headers()
      let buffer = header.name.encoded + newLine + header.unit.encoded + newLine
      url = url.appendingPathComponent("\(self.name)_\(no)_hourly.csv")
      fileStream = OutputStream(url: url, append: false)
      fileStream?.open()
      _ = fileStream?.write(buffer, maxLength: buffer.count)
    }

    if case .custom(let i) = mode {
      let header = headers(minutes: true)
      let startTime = repeatElement("0", count: header.count + 4)
        .joined(separator: ",")
      let fraction = String(format: "%.5f", i.fraction)
      let frequence = repeatElement(fraction, count: header.count + 4)
        .joined(separator: ",")
      let buffer = "wxDVFileHeaderVer.1".encoded + newLine 
        + header.name.encoded + newLine + startTime.encoded + newLine
        + frequence.encoded + newLine + header.unit.encoded + newLine

      url = url.appendingPathComponent("\(self.name)_\(no)_\(i).csv")

      fileStream = OutputStream(url: url, append: false)
      fileStream?.open()
      _ = fileStream?.write(buffer, maxLength: buffer.count)
    }
    if !mode.hasFileOutput { return }
    print("File output to: \(url.deletingLastPathComponent().path)")
    print("  \(url.lastPathComponent)")
    print()
  }

  deinit {
    fileStream?.close()
  }

  public func clearResults() {
    performance.removeAll(keepingCapacity: true)
    status.removeAll(keepingCapacity: true)
    sun.removeAll(keepingCapacity: true)
  }

  func callAsFunction(
    _ time: DateTime, meteo: MeteoData, status: Status, energy: PlantPerformance
  ) {
    self.status.append(status)
    self.performance.append(energy)
    self.sun.append(Insolation(meteo: meteo))
    #if PRINT
    print(decorated(time.description), meteo, status, energy)
    ClearScreen()
    #elseif DEBUG && !os(Windows)
    if progress != time.yearDay {
      progress = time.yearDay
      print(" [\(progress)/\(365)] recording month…", terminator: "\r")
      fflush(stdout)
    }
    #endif
  }

  public func finish(open: Bool = false) -> Recording {
    #if DEBUG && !os(Windows)
    let clearLineString = "\u{001B}[2K"
    print(clearLineString, terminator: "\r")
    fflush(stdout)
    #endif
    var buffer = [UInt8]()
      /// Sum of hourly values
    var accumulate = PlantPerformance()
    var insolation = Insolation()
    if case .custom(let custom) = mode {
      let f = frequency.rawValue / custom.rawValue
      var date = startDate
      for i in stride(from: 0, to: performance.count, by: f) {
        accumulate(performance[i..<i+f], fraction: 1 / Double(f))
        insolation = sun[i..<i+f].hourly(fraction: 1 / Double(f))
        let time = DateTime(date)
        buffer = time.commaSeparatedValues.encoded + comma
          + "\(time.minute)".encoded + comma
          + insolation.commaSeparatedValues.encoded + comma
          + accumulate.commaSeparatedValues.encoded + newLine
        date.addTimeInterval(custom.interval)
        _ = fileStream?.write(buffer, maxLength: buffer.count)
      }
    }

    if case .csv = mode {
      let f = frequency.rawValue
      var date = startDate
      for i in stride(from: 0, to: performance.count, by: f) {
        let fraction = frequency.fraction
        accumulate(performance[i..<i+f], fraction: fraction)
        insolation = sun[i..<i+f].hourly(fraction: fraction)
        buffer = DateTime(date).commaSeparatedValues.encoded + comma
          + insolation.commaSeparatedValues.encoded + comma
          + accumulate.commaSeparatedValues.encoded + newLine
        date.addTimeInterval(DateSeries.Frequence.hour.interval)
        _ = fileStream?.write(buffer, maxLength: buffer.count)
      }
    }

    if case .database = mode { storeInDB() }
    if case .excel = mode { writeExcel() }

    let irradiance = sun.hourly(fraction: frequency.fraction)
    if mode.hasFileOutput, open { start(url.path) }
    fileStream?.close()
    fileStream = nil
    return Recording(
      startDate: startDate, irradiance: irradiance, 
      performanceHistory: performance,
      statusHistory: status)
  }

  /// Determines the sequence number by checking the existing files in the path.
  private func sequenceNumber(atPath path: String) -> String {
    let 💾 = FileManager.default
    let contents = try? 💾.contentsOfDirectory(atPath: path)
    let results = contents?.filter { $0.hasPrefix(name) }
    let last = results?.compactMap { filename in
      let splited = filename.split(separator: "_")
      let idx = min(1,splited.endIndex - 1)
      return Int(splited[idx].filter(\.isWholeNumber))
    }.max() 
    return String(format: "%02d", (last ?? 0) + 1)
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
    var date = startDate

    status.indices.forEach { i in
      ws1.write(.datetime(date), [i + 1, 0])
      ws1.write(sun[i].values, row: i + 1, col: 1)
      ws1.write(status[i].modes, row: i + 1, col: 4)
      ws1.write(status[i].values, row: i + 1, col: 4 + modesCount)
      date.addTimeInterval(interval)
    }

    date = startDate

    performance.indices.forEach { i in
      ws2.write(.datetime(date), [i + 1, 0])
      ws2.write(performance[i].values, row: i + 1, col: 1)
      date.addTimeInterval(interval)
    }
    wb.close()
    print("Excel file creation took \(Int(-now.timeIntervalSinceNow)) seconds.")
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


  /// Returns the headers for the table
  private func headers(minutes: Bool = false) -> (name: String, unit: String, count: Int) {
    #if DEBUG
    let m = Insolation.measurements + PlantPerformance.measurements + Status.measurements
    #else
    let m = Insolation.measurements + PlantPerformance.measurements
    #endif
    let name: String = m.map(\.name).joined(separator: ",")
    let unit: String = m.map(\.unit).joined(separator: ",")
    if minutes { return ("Month,Day,Hour,Minute," + name, "_,_,_,_," + unit, m.count) }
    return ("Month,Day,Hour," + name, "_,_,_," + unit, m.count)
  }
}

extension String { fileprivate var encoded: [UInt8] { [UInt8](self.utf8) } }
#if os(Windows)
fileprivate let newLine: [UInt8] = [UInt8(ascii: "\r"), UInt8(ascii: "\n")] 
#else
fileprivate let newLine: [UInt8] = [UInt8(ascii: "\n")] 
#endif
fileprivate let comma: [UInt8] = [UInt8(ascii: ",")] 
