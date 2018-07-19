//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation
import DateGenerator
import Meteo

final class PerformanceDataLogger {

  var dateString: String = ""
  
  var dateFormatter: DateFormatter? {
    didSet {
      dateFormatter?.timeZone = TimeZone(secondsFromGMT: 0)
      dateFormatter?.dateStyle = .short
      dateFormatter?.timeStyle = .short
    }
  }
  
  let interval = PerformanceCalculator.interval
  
  var intervalResults: Results? = nil
  var collectorResults = Collector.initialState
  let hourlyResults = Results()
  let dailyResults = Results()
  let annuallyResults = Results()

  enum Mode { case full, brief }
  
  init(fileNameSuffix: String, mode: PerformanceDataLogger.Mode = .full) {

    if case .full = mode {
      let header = "wxDVFileHeaderVer.1\n"
      let startTime = repeatElement("0", count: 40)
        .joined(separator: ", ") + .lineBreak
      let intervalTime = repeatElement("\(interval.fraction)", count: 40)
        .joined(separator: ", ") + .lineBreak
      
      intervalOutputStream = OutputStream(
        toFileAtPath: "IntervalResults_\(fileNameSuffix).csv", append: false)
      intervalResults = Results()
      intervalOutputStream?.open()
      intervalOutputStream?.write(
        header + headersInterval.name + startTime + intervalTime + headersInterval.unit)
    }

    hourlyOutputStream = OutputStream(
      toFileAtPath: "HourlyResults_\(fileNameSuffix).csv", append: false)
    hourlyOutputStream?.open()
    hourlyOutputStream?.write(
      headersHourly.name + .lineBreak + headersHourly.unit + .lineBreak)
    
    dailyOutputStream = OutputStream(
      toFileAtPath: "DailyResults_\(fileNameSuffix).csv", append: false)
    dailyOutputStream?.open()
    dailyOutputStream?.write(
      headersDaily.name + .lineBreak + headersDaily.unit + .lineBreak)
  }

  deinit {
    intervalOutputStream?.close()
    hourlyOutputStream?.close()
    dailyOutputStream?.close()
  }
  
  func openFiles() {

  }
  
  func append(date: Date, meteo: MeteoData,
              electricEnergy: ElectricEnergy,
              electricalParasitics: Parasitics,
              thermal: ThermalEnergy,
              fuelConsumption: FuelConsumption,
              status: Plant.PerformanceData) {
    
    if intervalResults != nil {
      intervalResults!.thermal = thermal
      intervalResults!.energy = electricEnergy
      intervalResults!.fuelConsumption = fuelConsumption
      intervalResults!.parasitics = electricalParasitics
      intervalResults!.dni = Double(meteo.dni)
      intervalResults!.ghi = Double(meteo.ghi)
      intervalResults!.dhi = Double(meteo.dhi)
      intervalResults!.ico = Double(meteo.dni) * status.collector.cosTheta
      intervalResults!.insolationAbsorber = status.solarField.insolationAbsorber
      intervalResults!.status = status

      writeIntervalResults(date: date)
    }
    // The counter triggers the writing of the file when it is set.
    defer { intervalCounter += 1 }
    
    if intervalCounter == 0, let dateFormatter = dateFormatter {
      dateString = dateFormatter.string(from: date)
    }
    
    let fraction = interval.fraction
    hourlyResults.thermal.accumulate(thermal, fraction: fraction)
    hourlyResults.energy.accumulate(electricEnergy, fraction: fraction)
    hourlyResults.fuelConsumption.accumulate(fuelConsumption, fraction: fraction)
    hourlyResults.parasitics.accumulate(electricalParasitics, fraction: fraction)
    
    hourlyResults.dni += Double(meteo.dni) * fraction
    hourlyResults.ghi += Double(meteo.ghi) * fraction
    hourlyResults.dhi += Double(meteo.dhi) * fraction
    hourlyResults.ico += Double(meteo.dni) * status.collector.cosTheta * fraction

    hourlyResults.add(solarfield: status.solarField, fraction: fraction)
  }
  
  private var intervalCounter: Int = 0 {
    didSet {
      if intervalCounter == interval.rawValue {
        writeHourlyResults()
        intervalCounter = 0
      }
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
  
  // MARK: Output Streams
  
  var dailyOutputStream: OutputStream?
  var hourlyOutputStream: OutputStream?
  var intervalOutputStream: OutputStream?

  // MARK: Headers
  
  private var headersDaily: (name: String, unit: String) {
    let columns = [PerformanceDataLogger.Results.columns, ThermalEnergy.columns,
                  ElectricEnergy.columns, Parasitics.columns,
                  FuelConsumption.columns].joined()
    let names = columns.map { $0.0 }.joined(separator: ",")
    let units = columns.map { $0.1 }.joined(separator: ",")
    if dateFormatter != nil {
      return ("Date,Time," + names, "_,_," + units)
    }
    return (names, units)
  }
  
  private var headersHourly: (name: String, unit: String) {
    let columns = [PerformanceDataLogger.Results.columns, ThermalEnergy.columns,
                  ElectricEnergy.columns, Parasitics.columns,
                  FuelConsumption.columns].joined()
    let names = columns.map { $0.0 }.joined(separator: ",")
    let units = columns.map { $0.1 }.joined(separator: ",")
    if dateFormatter != nil {
      return ("Date,Time," + names, "_,_," + units)
    }
    return (names, units)
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
  
  // MARK: Write
  
  private func writeIntervalResults(date: Date) {
    guard let stream = intervalOutputStream,
      let results = intervalResults else { return }
    var d = ""
    if let dateFormatter = dateFormatter {
      d = dateFormatter.string(from: date) + ","
    }

    let data = [UInt8]((d + results.csv + results.thermal.csv + results.energy.csv
      + results.parasitics.csv + results.fuelConsumption.csv
      + results.status.collector.csv + .lineBreak).utf8)
    stream.write(data, maxLength: data.count)
    intervalResults!.reset()
  }
  
  private func writeHourlyResults() {
    let csv = dateString + ", " + [
      hourlyResults.values, hourlyResults.thermal.values,
      hourlyResults.energy.values, hourlyResults.parasitics.values,
      hourlyResults.fuelConsumption.values]
      .joined().joined(separator: ", ")
    let row = csv + .lineBreak
    hourlyOutputStream?.write(row)
    dailyResults.accumulate(hourlyResults, fraction: 1/24)
    hourCounter += 1
    hourlyResults.reset()
  }
  
  private func writeDailyResults() {
    let csv = dateString.dropLast(4) + ", " + [
      dailyResults.values, dailyResults.thermal.values,
      dailyResults.energy.values, dailyResults.parasitics.values,
      dailyResults.fuelConsumption.values]
      .joined().joined(separator: ",")
    let data = [UInt8]((csv + "\n").utf8)
    dailyOutputStream?.write(data, maxLength: data.count)
    annuallyResults.accumulate(dailyResults, fraction: 24)
    dailyResults.reset()
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
    
    // SolarField
    var insolationAbsorber: Double = 0
    var HL: Double = 0
    var heatLossHeader: Double = 0
    var heatLossHCE: Double = 0
    
    var status = Plant.PerformanceData()
    
    var values: [String] {
      return [
        String(format:"%.1f", dni),
        String(format:"%.1f", ghi),
        String(format:"%.1f", dhi),
        String(format:"%.0f", ico),
        String(format:"%.0f", insolationAbsorber),
        String(format:"%.1f", HL),
        String(format:"%.1f", heatLossHeader),
        String(format:"%.1f", heatLossHCE),
      ]
    }
    
    var csv: String {
      return String(format:"%.1f, %.1f, %.1f, %.0f, %.0f, %.0f, %.0f, %.0f, ",
                    dni, ghi, dhi, ico, insolationAbsorber, HL, heatLossHeader, heatLossHCE)
    }
    
    static var columns: [(String, String)]  {
      return [
        ("Meteo|DNI", "W/m2"), ("Meteo|GHI", "W/m2"), ("Meteo|DHI", "W/m2"),
        ("SolarField|ICO", "W/m2"), ("SolarField|insolationAbsorber", "W/m2"),
        ("SolarField|HL", "MWh"), ("SolarField|heatLossHeader", "MWh"),
        ("SolarField|heatLossHCE", "MWh"),
      ]
    }
    
    public var description: String {
      return thermal.description + fuelConsumption.description
        + parasitics.description + energy.description
        + zip(values, Results.columns).reduce("\n") { ininsolationAbsorberl, next in
          let text = next.1.0 >< (next.0 + " " + next.1.1)
          return ininsolationAbsorberl + text
      }
    }
    
    fileprivate func add(solarfield: SolarField.PerformanceData, fraction: Double) {
      insolationAbsorber += solarfield.insolationAbsorber * fraction
      HL += solarfield.HL * fraction
      heatLossHeader += solarfield.heatLossHeader * fraction
      heatLossHCE += solarfield.heatLossHCE * fraction
    }
    
    fileprivate func accumulate(_ result: Results, fraction: Double) {
      thermal.accumulate(result.thermal, fraction: fraction)
      fuelConsumption.accumulate(result.fuelConsumption, fraction: fraction)
      parasitics.accumulate(result.parasitics, fraction: fraction)
      energy.accumulate(result.energy, fraction: fraction)
      dni += result.dni * fraction
      ghi += result.ghi * fraction
      dhi += result.dhi * fraction
      ico += result.ico * fraction
      
      insolationAbsorber += result.insolationAbsorber * fraction
      HL += result.HL * fraction
      heatLossHeader += result.heatLossHeader * fraction
      heatLossHCE += result.heatLossHCE * fraction
    }
    
    fileprivate func reset() {
      thermal = ThermalEnergy()
      fuelConsumption = FuelConsumption()
      parasitics = Parasitics()
      energy = ElectricEnergy()
      dni = 0; ghi = 0; dhi = 0; ico = 0; insolationAbsorber = 0; HL = 0
      heatLossHeader = 0; heatLossHCE = 0
    }
  }
}

extension OutputStream {
  
  func write(_ string: String) {
    let bytes = [UInt8](string.utf8)
    self.write(bytes, maxLength: bytes.count)
  }
}
