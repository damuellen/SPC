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
import TSCBasic
import TSCUtility

public final class PerformanceDataRecorder {

#if DEBUG
  let animation = NinjaProgressAnimation(stream: stdoutStream)
#endif 

  let interval = Simulation.time.steps   
  let stride: Int
  let mode: Mode
  
  public enum Mode {
    case persistent, brief, memory, none,
    custom(interval: DateGenerator.Interval)
    
    var hasFileOutput: Bool {
      if case .none = self { return false }
      if case .memory = self { return false }
      return true
    }
    
    var hasHistory: Bool {
      if case .persistent = self { return true }
      if case .memory = self { return true }
      return false
    }
  }

  private var dateString: String = ""
  private var dateString2: String = ""
  
  private let dateFormatter: DateFormatter = { dateFormatter in
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
    return dateFormatter
  }(DateFormatter())

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
  
  private var transientEnergy = Energy()
  private var transientRadiation = SolarRadiation()
  
  /// All past states of the plant
  private var performanceHistory: [PerformanceData] = []
  private var energyHistory: [Energy] = []

  public init(noHistory: Bool = false) {
    self.mode = noHistory ? .none : .memory
    self.stride = 1
  }

  public init(name: String? = nil, path: String? = nil, output: Mode = .none) {
    
    let 💾 = FileManager.default    
    
    if case .custom(let i) = output, i.isMultiple(of: interval) {
      self.stride = interval.rawValue / i.rawValue
      self.mode = output
    } else {
      self.mode = output
      self.stride = 1
    }
    
    let url = URL(fileURLWithPath: path ?? 💾.currentDirectoryPath)
    
    if output.hasFileOutput, !url.hasDirectoryPath { 
      print("Invalid path for results: \(url.path)\n")
      print("There will be no output files.\n")
      return
    }

    let suffix: String
    if let name = name {
      suffix = name
    } else {
      let contents = try? 💾.contentsOfDirectory(atPath: url.path)

      let oldResults = contents?.filter { $0.hasSuffix("ly.csv") }

      let numbers = oldResults?.compactMap { filename in
        return Int(filename.filter(\.isWholeNumber))
      }
      let n = (numbers?.max() ?? 0) + 1
      suffix = String(format: "%03d", n)
    }
    
    if case .persistent = output {
      self.db = try! Connection("Results_\(suffix).sqlite3")
    }

    if output.hasFileOutput {   
      let tableHeader = headers.name + .lineBreak + headers.unit + .lineBreak

      let dailyResultsURL = url.appendingPathComponent("Results_\(suffix)_daily.csv")
      let hourlyResultsURL = url.appendingPathComponent("Results_\(suffix)_hourly.csv")

      try! self.dailyResultsStream = LocalFileOutputByteStream(AbsolutePath(dailyResultsURL.path))
      try! self.hourlyResultsStream = LocalFileOutputByteStream(AbsolutePath(hourlyResultsURL.path))

      self.dailyResultsStream!.write(tableHeader)
      self.hourlyResultsStream!.write(tableHeader)

      var urls = [dailyResultsURL, hourlyResultsURL]
      
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
        let resultsURL = url.appendingPathComponent("Results_\(suffix)_\(i).csv")
        
        try! transientStream = LocalFileOutputByteStream(AbsolutePath(resultsURL.path))

        transientStream?.write(tableHeader)
        urls.append(resultsURL)
      }
 
      print("Results: \(url.path)/")
      urls.map(\.lastPathComponent).enumerated()
        .forEach { print("  \($0.offset+1).\t", $0.element) }
      print()
    }
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
        dateString = ts.description  // dateFormatter.string(from: date)
      }

      if case .custom(_) = mode {
        if stride == 1 || intervalCounter % stride == 1 {
          dateString2 = ts.description
        }
        let fraction = 1 / Double(stride)
        transientRadiation.totalize(solar, fraction: fraction)
        transientEnergy.totalize(energy, fraction: fraction)

        if stride == 1 || intervalCounter % stride == 0 {
          let csv = generateValues()
          transientStream?.write(csv)
          transientRadiation.zero()
          transientEnergy.zero()
        }
      }
      
      hourlyRadiation.totalize(solar, fraction: interval.fraction)
      hourlyEnergy.totalize(energy, fraction: interval.fraction)
      // Daily and annual sum calculations see counters
    } else {
      // Only the annual sums are calculated.
      annualRadiation.totalize(solar, fraction: interval.fraction)
      annualEnergy.totalize(energy, fraction: interval.fraction)
    }
#if DEBUG
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

  func complete() {
    log = PerformanceLog(
      energy: annualEnergy,
      radiation: annualRadiation,
      energyHistory: energyHistory,
      performanceHistory: performanceHistory
    )
    
    if case .persistent = mode {
      storeInDB()
    }

#if DEBUG
    animation.clear()
#endif     
  }
#if DEBUG
  private var progress: Int = 0
#endif 
  private var hourCounter: Int = 1 {
    didSet {
      if hourCounter > 24 {
        annualEnergy.totalize(dailyEnergy, fraction: 1)
        annualRadiation.totalize(dailyRadiation, fraction: 1)
        
        let csv = generateDailyValues()
        dailyResultsStream?.write(csv)
        
        dailyEnergy.zero()
        dailyRadiation.zero()
        
        hourCounter = 1
      }
    }
  }

  private var intervalCounter: Int = 1 {
    didSet {
      if intervalCounter > interval.rawValue {
        dailyEnergy.totalize(hourlyEnergy, fraction: 1)
        dailyRadiation.totalize(hourlyRadiation, fraction: 1)

        let csv = generateHourlyValues()
        hourlyResultsStream?.write(csv)
        
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

  private var transientStream: LocalFileOutputByteStream?  
  private var dailyResultsStream: LocalFileOutputByteStream?
  private var hourlyResultsStream: LocalFileOutputByteStream?

  // MARK: Table headers

  private var headers: (name: String, unit: String, count: Int) {
    let columns = [SolarRadiation.columns, Energy.columns].joined()
    let names: String = columns.map { $0.0 }.joined(separator: ",")
    let units: String = columns.map { $0.1 }.joined(separator: ",")
    // if dateFormatter != nil {
    return ("DateTime," + names, "_," + units, columns.count)
    // }
    // return (names, units)
  }

  // MARK: Write Results

  private func generateDailyValues() -> String {
    return dateString.dropFirst(3).prefix(10) + .separator
      + [dailyRadiation.values, dailyEnergy.values]
        .joined().joined(separator: ",") + .lineBreak
  }

  private func generateHourlyValues() -> String {
    return dateString.dropFirst(3) + .separator
      + [hourlyRadiation.values, hourlyEnergy.values]
        .joined().joined(separator: .separator) + .lineBreak
  }
  
  private func generateValues() -> String {
    return dateString2.dropFirst(3) + .separator
      + [transientRadiation.values, transientEnergy.values]
        .joined().joined(separator: .separator) + .lineBreak
  }
}
