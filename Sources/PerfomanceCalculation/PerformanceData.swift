//
//  Copyright (c) 2017 Daniel Müllenborn. All rights reserved.
//  Distributed under the The Non-Profit Open Software License version 3.0
//  http://opensource.org/licenses/NPOSL-3.0
//
//  This project is NOT free software. It is open source, you are allowed to
//  modify it (if you keep the license), but it may not be commercially
//  distributed other than under the conditions noted above.
//
import Foundation
import DateGenerator
import Meteo

final class PerfomanceData {
  
  final class Result: Encodable {
    // Thermal: [MWHth] = [MWth] * [Hr]
    var heatFlow = HeatFlow()
    
    var fuelConsumption = FuelConsumption()
    // Electric: [MWHe] = [MWe] * [Hr]
    var parasitics = Components()
    var energy = ElectricEnergy()
    // Meteodata: [WHr/sqm]
    var dni: Double = 0
    var ico: Double = 0
    // SolarField
    var ITA: Double = 0
    var ETA: Double = 0
    var HL: Double = 0
    var heatLossHeader: Double = 0
    var heatLossHCE: Double = 0
    
    func add(solarfield: SolarField.PerformanceData, fraction: Double) {
      ITA += solarfield.ITA * fraction
      ETA += solarfield.ETA * fraction
      HL += solarfield.HL * fraction
      heatLossHeader += solarfield.heatLossHeader * fraction
      heatLossHCE += solarfield.heatLossHCE * fraction
    }
    
    func accumulate(_ result: Result, fraction: Double) {
      heatFlow.accumulate(result.heatFlow, fraction: 1)
      fuelConsumption.accumulate(result.fuelConsumption, fraction: 1)
      parasitics.accumulate(result.parasitics, fraction: 1)
      energy.accumulate(result.energy, fraction: 1)
      dni += result.dni * fraction
      ico += result.ico * fraction
      
      ITA += result.ITA * fraction
      ETA += result.ETA * fraction
      HL += result.HL
      heatLossHeader += result.heatLossHeader
      heatLossHCE += result.heatLossHCE
    }
    
    func reset() {
      heatFlow = HeatFlow()
      fuelConsumption = FuelConsumption()
      parasitics = Components()
      energy = ElectricEnergy()
      dni = 0; ico = 0; ITA = 0; ETA = 0; HL = 0
      heatLossHeader = 0; heatLossHCE = 0
    }
    
    var commaSeparatedValues: String {
      let stringValues: [String] = [
        String(format:"%.3f", heatFlow.solar),
        String(format:"%.3f", heatFlow.dump),
        String(format:"%.3f", heatFlow.toStorage),
        String(format:"%.3f", heatFlow.storage),
        String(format:"%.3f", heatFlow.heater),
        String(format:"%.3f", heatFlow.heatExchanger),
        String(format:"%.3f", heatFlow.wasteHeatRecovery),
        String(format:"%.3f", heatFlow.boiler),
        String(format:"%.3f", heatFlow.dump),
        String(format:"%.3f", heatFlow.production),
        
        String(format:"%.2f", fuelConsumption.backup),
        String(format:"%.2f", fuelConsumption.boiler),
        String(format:"%.2f", fuelConsumption.heater),
        String(format:"%.2f", fuelConsumption.gasTurbine),
        String(format:"%.2f", fuelConsumption.combined),
        
        String(format:"%.3f", 0),
        String(format:"%.3f", parasitics.solarField),
        String(format:"%.3f", parasitics.powerBlock),
        String(format:"%.3f", parasitics.storage),
        String(format:"%.3f", parasitics.shared),
        String(format:"%.3f", 0),
        String(format:"%.3f", parasitics.gasTurbine),
        
        String(format:"%.3f", energy.steamTurbineGross),
        String(format:"%.3f", energy.gasTurbineGross),
        String(format:"%.3f", energy.backupGross),
        String(format:"%.3f", energy.parasitics),
        String(format:"%.3f", energy.net),
        String(format:"%.3f", energy.consum),
        String(format:"%.0f", dni),
        String(format:"%.0f", ico),
        String(format:"%.0f", ITA),
        String(format:"%.0f", ETA),
        String(format:"%.3f", HL),
        String(format:"%.3f", heatLossHeader),
        String(format:"%.3f", heatLossHCE),
        ]
      return stringValues.joined(separator: ", ")
    }
  }
  
  var dateString: String = ""
  let interval = PerformanceCalculator.interval
  let hourlyResults = Result()
  let dailyResults = Result()
  let annuallyResults = Result()
  
  init() { }
  
  private var intervalCount: Int = 0 {
    didSet {
      if intervalCount == interval.rawValue {
        writeHourlyResults()
        intervalCount = 0
      }
    }
  }
  
  private var hourCount: Int = 0 {
    didSet {
      if hourCount == 24 {
        writeDailyResults()
        hourCount = 0
      }
    }
  }
  
  private func writeHourlyResults() {
    let csv = dateString + hourlyResults.commaSeparatedValues
    let data = [UInt8]((csv + "\n").utf8)
    hourlyOutputStream?.write(data, maxLength: data.count)
    dailyResults.accumulate(hourlyResults, fraction: (1/24))
    hourCount += 1
    hourlyResults.reset()
  }
  
  private func writeDailyResults() {
    let csv = dateString.dropLast(4) + dailyResults.commaSeparatedValues
    let data = [UInt8]((csv + "\n").utf8)
    dailyOutputStream?.write(data, maxLength: data.count)
    annuallyResults.accumulate(dailyResults, fraction: 1)
    dailyResults.reset()
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
  
  var headers: (name: String, unit: String) {
    let stringValues: [(String, String)] = [
      ("Thermal|Solar", "MWh"), ("Thermal|Dump", "MWh"),
      ("Thermal|ToStorage", "MWh"), ("Thermal|Storage", "MWh"),
      ("Thermal|Heater", "MWh"), ("Thermal|HeatExchanger", "MWh"),
      ("Thermal|WasteHeatRecovery", "MWh"), ("Thermal|Boiler", "MWh"),
      ("Thermal|Dump", "MWh"), ("Thermal|Production", "MWh"),
      ("Fuel|Backup", " "), ("Fuel|Boiler", " "), ("Fuel|Heater", " "),
      ("Fuel|GasTurbine", " "), ("Fuel|Fuel", " "), ("Electric|Gross", "MWh"),
      ("Parasitics|SolarField", "MWh"), ("Parasitics|PowerBlock", "MWh"),
      ("Parasitics|Storage", "MWh"), ("Parasitics|Shared", "MWh"),
      ("Parasitics|Backup", "MWh"), ("Parasitics|GasTurbine", "MWh"),
      ("Electric|SteamTurbineGross", "MWh"), ("Electric|GasTurbineGross", "MWh"),
      ("Electric|BackupGross", "MWh"), ("Parasitics", "MWh"),
      ("Electric|Net", "MWh"), ("Electric|Consum", "MWh"),
      ("Meteo|Insolation", "Wh/m2"), ("Collector|ICosTheta", " "),
      ("SolarField|ITA", " "), ("SolarField|ETA", " "),
      ("SolarField|HL", " "), ("SolarField|heatLossHeader", " "),
      ("SolarField|heatLossHCE", " ")]
    let names = stringValues.map({$0.0}).joined(separator: ",")
    let units = stringValues.map({$0.1}).joined(separator: ",")
    return (names, units)
  }

  var headersDaily: (name: String, unit: String) {
    let names = headers.name
    let units = headers.unit
    if dateFormatter != nil {
      return ("Date,Date," + names, "Month,Day," + units)
    }
    return (names, units)
  }
  
  var headersHourly: (name: String, unit: String) {
    let names = headers.name
    let units = headers.unit
    if dateFormatter != nil {
      return ("Date,Date,Date," + names, "Month,Day,Hour," + units)
    }
    return (names, units)
  }

  func sumUp(date: Date, meteo: MeteoData,
             electricEnergy: ElectricEnergy,
             electricalParasitics: Components,
             heatFlow: HeatFlow,
             fuelConsumption: FuelConsumption,
             solarfield: SolarField.PerformanceData,
             collector: Collector.PerformanceData) {
    
    defer { intervalCount += 1 }
    if intervalCount == 0, let dateFormatter = dateFormatter {
      dateString = dateFormatter.string(from: date)
    }
    let fraction = interval.fraction
    hourlyResults.heatFlow.accumulate(heatFlow, fraction: fraction)
    hourlyResults.energy.accumulate(electricEnergy, fraction: fraction)
    hourlyResults.fuelConsumption.accumulate(fuelConsumption, fraction: fraction)
    hourlyResults.parasitics.accumulate(electricalParasitics, fraction: fraction)
    hourlyResults.add(solarfield: solarfield, fraction: fraction)
    hourlyResults.dni += Double(meteo.dni) * fraction
    hourlyResults.ico += Double(meteo.dni) * cos(collector.theta) * fraction
  }
}

public struct ElectricEnergy: Encodable {
  var demand = 0.0, gross = 0.0, shared = 0.0, solarField = 0.0, powerBlock = 0.0,
  storage = 0.0, gasTurbine = 0.0, steamTurbineGross = 0.0, gasTurbineGross = 0.0,
  backupGross = 0.0, parasitics = 0.0, net = 0.0, consum = 0.0
  
  mutating func accumulate(_ electricEnergy: ElectricEnergy, fraction: Double) {
    steamTurbineGross += electricEnergy.steamTurbineGross * fraction
    gasTurbineGross += electricEnergy.gasTurbineGross * fraction
    //backupGross +=
    parasitics += electricEnergy.parasitics * fraction
    net += electricEnergy.net * fraction
    consum += electricEnergy.consum * fraction
  }
}

public struct Components: Encodable {
  var boiler = 0.0, gasTurbine = 0.0, heater = 0.0, powerBlock = 0.0,
  shared = 0.0, solarField = 0.0, storage = 0.0
  
  mutating func accumulate(_ electricalParasitics: Components, fraction: Double) {
    solarField += electricalParasitics.solarField * fraction
    powerBlock += electricalParasitics.powerBlock * fraction
    storage += electricalParasitics.storage * fraction
    shared += electricalParasitics.shared * fraction
    //parasiticsBackup += electricalParasitics
    gasTurbine += electricalParasitics.gasTurbine * fraction
  }
}

public struct HeatFlow: Encodable {
  var solar = 0.0, toStorage = 0.0, toStorageMin = 0.0, storage = 0.0,
  heater = 0.0, boiler = 0.0, wasteHeatRecovery = 0.0, heatExchanger = 0.0,
  production = 0.0, demand = 0.0, dump = 0.0, overtemp_dump = 0.0
  
  mutating func accumulate(_ heatFlow: HeatFlow, fraction: Double) {
    solar += heatFlow.solar * fraction
    toStorage += heatFlow.toStorage * fraction
    storage += heatFlow.storage * fraction
    heater += heatFlow.heater * fraction
    heatExchanger += heatFlow.heatExchanger * fraction
    wasteHeatRecovery += heatFlow.wasteHeatRecovery * fraction
    boiler += heatFlow.boiler * fraction
    dump += heatFlow.dump * fraction
    production += heatFlow.production * fraction
  }
}

public struct FuelConsumption: Encodable {
  var backup = 0.0
  var boiler = 0.0
  var heater = 0.0
  var gasTurbine = 0.0
  
  var combined: Double {
    return boiler + heater
  }
  
  var total: Double {
    return boiler + heater + gasTurbine
  }
  
  init() { }
  
  mutating func accumulate(_ fuelConsumption: FuelConsumption, fraction: Double) {
    backup += fuelConsumption.backup * fraction
    boiler += fuelConsumption.boiler * fraction
    heater += fuelConsumption.heater * fraction
    gasTurbine += fuelConsumption.gasTurbine * fraction
  }
}
