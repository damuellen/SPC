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

final class PerfomanceData {
  
  final class Result {
    // Thermal: [MWHth] = [MWth] * [Hr]
    var thermal = ThermalEnergy()
    
    var fuelConsumption = FuelConsumption()
    
    // Electric: [MWHe] = [MWe] * [Hr]
    var parasitics = Parasitics()
    var energy = ElectricEnergy()
    
    var throughput = Throughput()
    
    // Meteodata: [WHr/sqm]
    var dni: Double = 0
    var ghi: Double = 0
    var dhi: Double = 0
    var ico: Double = 0

    // SolarField
    var ITA: Double = 0
    var HL: Double = 0
    var heatLossHeader: Double = 0
    var heatLossHCE: Double = 0
    
    var numbers: [String] {
      return [
        String(format:"%.0f", dni),
        String(format:"%.0f", ghi),
        String(format:"%.0f", dhi),
        String(format:"%.0f", ico),
        String(format:"%.0f", ITA),
        String(format:"%.1f", HL),
        String(format:"%.1f", heatLossHeader),
        String(format:"%.1f", heatLossHCE),
      ]
    }
    
    static var titles: [(String, String)]  {
      return [
        ("Meteo|DNI", "Wh/m2"), ("Meteo|GHI", "Wh/m2"), ("Meteo|DHI", "Wh/m2"),
        ("SolarField|ICO", "Wh/m2"), ("SolarField|ITA", "_"), ("SolarField|HL", "_"),
        ("SolarField|heatLossHeader", "_"), ("SolarField|heatLossHCE", "_"),
      ]
    }

    fileprivate func add(solarfield: SolarField.PerformanceData, fraction: Double) {
      ITA += solarfield.ITA * fraction
      HL += solarfield.HL * fraction
      heatLossHeader += solarfield.heatLossHeader * fraction
      heatLossHCE += solarfield.heatLossHCE * fraction
    }
    
    fileprivate func accumulate(_ result: Result, fraction: Double) {
      thermal.accumulate(result.thermal, fraction: fraction)
      fuelConsumption.accumulate(result.fuelConsumption, fraction: fraction)
      parasitics.accumulate(result.parasitics, fraction: fraction)
      energy.accumulate(result.energy, fraction: fraction)
      dni += result.dni * fraction
      ghi += result.ghi * fraction
      dhi += result.dhi * fraction
      ico += result.ico * fraction
      
      ITA += result.ITA * fraction
      HL += result.HL * fraction
      heatLossHeader += result.heatLossHeader * fraction
      heatLossHCE += result.heatLossHCE * fraction
    }
    
    fileprivate func reset() {
      thermal = ThermalEnergy()
      fuelConsumption = FuelConsumption()
      parasitics = Parasitics()
      energy = ElectricEnergy()
      dni = 0; ghi = 0; dhi = 0; ico = 0; ITA = 0; HL = 0
      heatLossHeader = 0; heatLossHCE = 0
    }
  }
  
  var dateString: String = ""
  let interval = PerformanceCalculator.interval
  
  var intervalResults: Result? = nil
  var collectorResults = Collector.initialState
  let hourlyResults = Result()
  let dailyResults = Result()
  let annuallyResults = Result()

  init() { }
  
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
      collectorResults = status.collector
      intervalResults!.throughput.solar = status.solarField.header
      intervalResults!.add(solarfield: status.solarField, fraction: 1)
      writeIntervalResults(date: date)
    }
    
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

  var intervalOutputStream: OutputStream? {
    didSet {
      intervalResults = Result()
      intervalOutputStream?.open()
      var data = [UInt8](("wxDVFileHeaderVer.1\n").utf8)
      let titles = [PerfomanceData.Result.titles, ThermalEnergy.titles,
                    ElectricEnergy.titles, Parasitics.titles,
                    FuelConsumption.titles, Collector.PerformanceData.titles,
                    Throughput.titles].joined()
      let names = titles.map { $0.0 }.joined(separator: ",")
      let units = titles.map { $0.1 }.joined(separator: ",")
      data += [UInt8]((names + "\n").utf8)
      data += [UInt8]((repeatElement("0", count: names.count)
        .joined(separator: ", ") + "\n").utf8)
      data += [UInt8]((repeatElement("\(interval.fraction)", count: names.count)
        .joined(separator: ", ") + "\n").utf8)
      data += [UInt8]((units + "\n").utf8)
      intervalOutputStream?.write(data, maxLength: data.count)
    }
  }
  
  var hourlyOutputStream: OutputStream? {
    didSet {
      hourlyOutputStream?.open()
      let data = [UInt8]((headersHourly.name + "\n").utf8)
        + [UInt8]((headersHourly.unit + "\n").utf8)
      hourlyOutputStream?.write(data, maxLength: data.count)
    }
  }
  
  var dailyOutputStream: OutputStream? {
    didSet {
      dailyOutputStream?.open()
      let data = [UInt8]((headersDaily.name + "\n").utf8)
        + [UInt8]((headersDaily.unit + "\n").utf8)
      dailyOutputStream?.write(data, maxLength: data.count)
    }
  }
  
  var dateFormatter: DateFormatter? {
    didSet {
      dateFormatter?.timeZone = TimeZone(secondsFromGMT: 0)
      dateFormatter?.dateFormat = "MM, dd, HH, "
    }
  }
  
  private var headersDaily: (name: String, unit: String) {
    let titles = [PerfomanceData.Result.titles, ThermalEnergy.titles,
                  ElectricEnergy.titles, Parasitics.titles,
                  FuelConsumption.titles].joined()
    let names = titles.map { $0.0 }.joined(separator: ",")
    let units = titles.map { $0.1 }.joined(separator: ",")
    if dateFormatter != nil {
      return ("Date,Date," + names, "Month,Day," + units)
    }
    return (names, units)
  }
  
  private var headersHourly: (name: String, unit: String) {
    let titles = [PerfomanceData.Result.titles, ThermalEnergy.titles,
                  ElectricEnergy.titles, Parasitics.titles,
                  FuelConsumption.titles].joined()
    let names = titles.map { $0.0 }.joined(separator: ",")
    let units = titles.map { $0.1 }.joined(separator: ",")
    if dateFormatter != nil {
      return ("Date,Date,Date," + names, "Month,Day,Hour," + units)
    }
    return (names, units)
  }
  
  private func writeIntervalResults(date: Date) {
    guard let stream = intervalOutputStream else { return }
    let csv = [
      intervalResults!.numbers, intervalResults!.thermal.numbers,
      intervalResults!.energy.numbers, intervalResults!.parasitics.numbers,
      intervalResults!.fuelConsumption.numbers, collectorResults.numbers,
      intervalResults!.throughput.numbers]
      .joined().joined(separator: ",")
    let data = [UInt8]((csv + "\n").utf8)
    stream.write(data, maxLength: data.count)
    intervalResults!.reset()
  }
  
  private func writeHourlyResults() {
    let csv = dateString + [
      hourlyResults.numbers, hourlyResults.thermal.numbers,
      hourlyResults.energy.numbers, hourlyResults.parasitics.numbers,
      hourlyResults.fuelConsumption.numbers, hourlyResults.throughput.numbers]
      .joined().joined(separator: ", ")
    let data = [UInt8]((csv + "\n").utf8)
    hourlyOutputStream?.write(data, maxLength: data.count)
    dailyResults.accumulate(hourlyResults, fraction: 1)
    hourCounter += 1
    hourlyResults.reset()
  }
  
  private func writeDailyResults() {
    let csv = dateString.dropLast(4) + [
      dailyResults.numbers, dailyResults.thermal.numbers,
      dailyResults.energy.numbers, dailyResults.parasitics.numbers,
      dailyResults.fuelConsumption.numbers, dailyResults.throughput.numbers]
      .joined().joined(separator: ",")
    let data = [UInt8]((csv + "\n").utf8)
    dailyOutputStream?.write(data, maxLength: data.count)
    annuallyResults.accumulate(dailyResults, fraction: 1)
    dailyResults.reset()
  }
}
