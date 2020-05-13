//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import TSCBasic
import TSCUtility
import DateGenerator
import Foundation
import Meteo

public final class PerformanceDataRecorder {

#if DEBUG
  let animation = NinjaProgressAnimation(stream: stdoutStream)
#endif 

  let interval = Simulation.time.steps   

  let mode: Mode
  
  public enum Mode {
    case all, brief, playground, none
    
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

  public var log: PerformanceLog? 
  
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
  private var performanceHistory: [PerformanceData] = []
  private var energyHistory: [Energy] = []

  public init(noHistory: Bool = false) {
    self.mode = noHistory ? .none : .playground
  }

  public init(name: String? = nil, path: String? = nil, mode: Mode = .none) { 
    self.mode = mode
    let 💾 = FileManager.default    
    let suffix: String
    
    let url = URL(fileURLWithPath: path ?? 💾.currentDirectoryPath)
    
    if mode.hasFileOutput, !url.hasDirectoryPath { 
      print("Invalid path for results: \(url.path)\n")
      print("There will be no output files.\n")
      return
    }

    if let name = name {
      suffix = name
    } else {
      let contents = try? 💾.contentsOfDirectory(atPath: url.path)

      let oldResults = contents?.filter { $0.hasSuffix("csv") }

      let numbers = oldResults?.compactMap { filename in
        return Int(filename.filter(\.isWholeNumber))
      }
      let n = (numbers?.max() ?? 0) + 1
      suffix = String(format: "%03d", n)
    }
    let tab = "\t"
    if mode.hasFileOutput {   
        
      let dailyResultsURL = url.appendingPathComponent("Results_\(suffix)_daily.csv")
      self.dailyResultsStream = OutputStream(url: dailyResultsURL, append: false)
      self.dailyResultsStream?.open()
      self.dailyResultsStream?.write(
        self.headersDaily.name + .lineBreak + self.headersDaily.unit + .lineBreak
      )
      let hourlyResultsURL = url.appendingPathComponent("Results_\(suffix)_hourly.csv")
      
      self.hourlyResultsStream = OutputStream(url: hourlyResultsURL, append: false)
      self.hourlyResultsStream?.open()      
      self.hourlyResultsStream?.write(
        self.headersHourly.name + .lineBreak + self.headersHourly.unit + .lineBreak
      )
      var urls = [dailyResultsURL, hourlyResultsURL]

      if case .all = mode {
        let header = "wxDVFileHeaderVer.1\n"
        let startTime = repeatElement("0", count: 40)
          .joined(separator: .separator) + .lineBreak
        let intervalTime = repeatElement("\(interval.fraction)", count: 40)
          .joined(separator: .separator) + .lineBreak
        let allResults1URL = url.appendingPathComponent("Results_\(suffix)_all.csv")
        allResultsStream = OutputStream(url: allResults1URL, append: false)

        allResultsStream?.open()
        allResultsStream?.write(
          header + headersInterval.name + startTime + intervalTime + headersInterval.unit
        )
        let allResults2URL = url.appendingPathComponent("Results_\(suffix)_status.csv")
        print(tab, "\(allResults1URL.lastPathComponent)\t", "\(allResults2URL.lastPathComponent)\n")
        allResultsStream2 = OutputStream(url: allResults2URL, append: false)
        allResultsStream2?.open()
        allResultsStream2?.write(
          header + headersInterval2.name + startTime + intervalTime + headersInterval2.unit
        )
        urls += [allResults1URL, allResults2URL]
      }
      
      print("Results: \(url.path)/")
      urls.map(\.lastPathComponent).enumerated().forEach { print("  \($0.offset+1).\t", $0.element) }
      print()
    }
  }

  deinit {
    dailyResultsStream?.close()
    hourlyResultsStream?.close()
    allResultsStream?.close()
    allResultsStream2?.close()    
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
    print("─────────────────────────────┤   Annual results   ├─────────────────────────────")
    print(annualEnergy)
  }

  func add(
    _ ts: TimeStep, meteo: MeteoData, status: PerformanceData, energy: Energy)
  {
#if DEBUG
    if progress != ts.month {
      progress = ts.month
      animation.update(
        step: progress,
        total: 12,
        text: "currently simulated month."
      )
    }
#endif 
    if case .playground = mode {
      self.performanceHistory.append(status)
      self.energyHistory.append(energy)
    }   
    
    let solar = SolarRadiation(
      meteo: meteo, cosTheta: status.collector.cosTheta
    )   

    let fraction = interval.fraction
    if mode.hasFileOutput {
      
      if case .all = mode {
        let (csv1, csv2) = generateValues(
          status: status, energy: energy, solar: solar, ts: ts
        )
        allResultsStream?.write(csv1)
        allResultsStream2?.write(csv2)      
      }

      defer { intervalCounter += 1 }

      if intervalCounter == 0 {
        dateString = ts.description // dateFormatter.string(from: date)
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

  func complete() {
    log = PerformanceLog(
      energy: annualEnergy,
      radiation: annualRadiation,
      energyHistory: energyHistory,
      performanceHistory: performanceHistory
    )

#if DEBUG
    animation.clear()
#endif     
  }
#if DEBUG
  private var progress: Int = 0
#endif 
  private var hourCounter: Int = 0 {
    didSet {
      if hourCounter == 24 {
        annualEnergy.totalize(dailyEnergy, fraction: 24)
        annualRadiation.totalize(dailyRadiation, fraction: 24)

        let csv = generateDailyValues()
        dailyResultsStream?.write(csv)
        dailyEnergy.zero()
        dailyRadiation.zero()
        hourCounter = 0
      }
    }
  }

  private var intervalCounter: Int = 0 {
    didSet {
      if intervalCounter == interval.rawValue {        
        dailyEnergy.totalize(hourlyEnergy, fraction: 1 / 24)
        dailyRadiation.totalize(hourlyRadiation, fraction: 1 / 24)

        let csv = generateHourlyValues()
        hourlyResultsStream?.write(csv)
        
        hourlyEnergy.zero()
        hourlyRadiation.zero()

        hourCounter += 1
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
    return ("DateTime," + names, "_," + units)
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
    return ("DateTime," + names, "_," + units)
    // }
    // return (names, units)
  }

  private var headersInterval: (name: String, unit: String) {
    let columns = [SolarRadiation.columns, ThermalEnergy.columns,
                   ElectricPower.columns, Parasitics.columns,
                   FuelConsumption.columns, Collector.columns]
      .joined()
    let names = columns.map { $0.0 }.joined(separator: ",") + .lineBreak
    let units = columns.map { $0.1 }.joined(separator: ",") + .lineBreak
    return ("DateTime," + names, "_," + units)
  }

  private var headersInterval2: (name: String, unit: String) {
    let columns = PerformanceData.columns
    let names = columns.map { $0.0 }.joined(separator: ",") + .lineBreak
    let units = columns.map { $0.1 }.joined(separator: ",") + .lineBreak
    return ("DateTime," + names, "_," + units)
  }

  // MARK: Write Results

  private func generateDailyValues() -> String {
    return dateString.dropFirst(3).prefix(10) + .separator + [
      dailyRadiation.values, dailyEnergy.thermal.values,
      dailyEnergy.electric.values, dailyEnergy.parasitics.values,
      dailyEnergy.fuel.values].joined()
      .joined(separator: ",") + .lineBreak
  }

  private func generateHourlyValues() -> String {
    return dateString.dropFirst(3) + .separator + [
      hourlyRadiation.values, hourlyEnergy.thermal.values,
      hourlyEnergy.electric.values, hourlyEnergy.parasitics.values,
      hourlyEnergy.fuel.values].joined()
      .joined(separator: .separator) + .lineBreak
  }

  private func generateValues(
    status: PerformanceData, energy: Energy,
    solar: SolarRadiation, ts: TimeStep)
    -> (String, String)
  {
    let dateString = ts.description   //dateFormatter.string(from: date)
 
    let csv1 = dateString + .separator + solar.csv
      + energy.thermal.csv + energy.electric.csv
      + energy.parasitics.csv + energy.fuel.csv
      + status.collector.csv + .lineBreak
    let csv2 = dateString + .separator + status.csv + .lineBreak

    return (csv1, csv2)  
  }
}

extension OutputStream {
  func write(_ string: String) {
    let bytes = [UInt8](string.utf8)
    let _ = write(bytes, maxLength: bytes.count)
  }
}
