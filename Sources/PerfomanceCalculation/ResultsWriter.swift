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

class ResultsWriter {

  let interval: DateGenerator.Interval
  
  // Thermal: [MWHth] = [MWth] * [Hr]
  var solar: Double = 0
  var damp: Double = 0
  var toStorage: Double = 0
  var storage: Double = 0
  var heater: Double = 0
  var heatExchanger: Double = 0
  var wasteHeatRecovery: Double = 0
  var boiler: Double = 0
  var dump: Double = 0
  var production: Double = 0
  var backupFuel: Double = 0
  var boilerFuel: Double = 0
  var heaterFuel: Double = 0
  var gasTurbineFuel: Double = 0
  var fuel: Double = 0
  
  // Electric: [MWHe] = [MWe] * [Hr]
  var gross: Double = 0
  var parasiticsSF: Double = 0
  var parasiticsPB: Double = 0
  var parasiticsSTO: Double = 0
  var parasiticsshared: Double = 0
  var parasiticsBU: Double = 0
  var parasiticsGasTurbine: Double = 0
  var steamTurbineGross: Double = 0
  var gasTurbineGross: Double = 0
  var backupGross: Double = 0
  var parasitics: Double = 0
  var net: Double = 0
  var consum: Double = 0
  
  // Meteodata: [WHr/sqm]
  var dni: Double = 0
  var ico: Double = 0
  // SolarField
  var ITA: Double = 0
  var ETA: Double = 0
  var HL: Double = 0
  var heatLossHeader: Double = 0
  var heatLossHCE: Double = 0
  var dateString: String = ""
  
  init(interval: DateGenerator.Interval) {
    self.interval = interval
    
  }
  
  private var intervalCount: Int = 0 {
    didSet {
      if intervalCount == interval.rawValue {
        writeResults()
        resetResults()
      }
    }
  }
  
  var outputStream: OutputStream? {
    didSet {
      outputStream?.open()
      let data = [UInt8]((headers.name + "\n").utf8)
        + [UInt8]((headers.unit + "\n").utf8)
      outputStream?.write(data, maxLength: data.count)
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
      ("Thermal|Solar", "MWh"),
      ("Thermal|Damp", "MWh"),
      ("Thermal|ToStorage", "MWh"),
      ("Thermal|Storage", "MWh"),
      ("Thermal|Heater", "MWh"),
      ("Thermal|HeatExchanger", "MWh"),
      ("Thermal|WasteHeatRecovery", "MWh"),
      ("Thermal|Boiler", "MWh"),
      ("Thermal|Dump", "MWh"),
      ("Thermal|Production", "MWh"),
      ("Fuel|Backup", " "),
      ("Fuel|Boiler", " "),
      ("Fuel|Heater", " "),
      ("Fuel|GasTurbine", " "),
      ("Fuel|Fuel", " "),
      
      ("Electric|Gross", "MWh"),
      ("Parasitics|SolarField", "MWh"),
      ("Parasitics|PowerBlock", "MWh"),
      ("Parasitics|Storage", "MWh"),
      ("Parasitics|Shared", "MWh"),
      ("Parasitics|Backup", "MWh"),
      ("Parasitics|GasTurbine", "MWh"),
      ("Electric|steamTurbineGross", "MWh"),
      ("Electric|gasTurbineGross", "MWh"),
      ("Electric|BackupGross", "MWh"),
      ("Parasitics", "MWh"),
      ("Electric|Net", "MWh"),
      ("Electric|Consum", "MWh"),
      ("Meteo|Insolation", "Wh/m2"),
      ("Collector|ICosTheta", " "),
      ("SolarField|ITA", " "),
      ("SolarField|ETA", " "),
      ("SolarField|HL", " "),
      ("SolarField|heatLossHeader", " "),
      ("SolarField|heatLossHCE", " "),
      ]
    let names = stringValues.map({$0.0}).joined(separator: ",")
    let units = stringValues.map({$0.1}).joined(separator: ",")
    if dateFormatter != nil {
      return ("Date,Date,Date," + names, "Month,Day,Hour," + units)
    }
    return (names, units)
  }
  
  var commaSeparatedValues: String {
    let stringValues: [String] = [
      String(format:"%.3f", solar),
      String(format:"%.3f", damp),
      String(format:"%.3f", toStorage),
      String(format:"%.3f", storage),
      String(format:"%.3f", heater),
      String(format:"%.3f", heatExchanger),
      String(format:"%.3f", wasteHeatRecovery),
      String(format:"%.3f", boiler),
      String(format:"%.3f", dump),
      String(format:"%.3f", production),
      String(format:"%.2f", backupFuel),
      String(format:"%.2f", boilerFuel),
      String(format:"%.2f", heaterFuel),
      String(format:"%.2f", gasTurbineFuel),
      String(format:"%.2f", fuel),
      
      String(format:"%.3f", gross),
      String(format:"%.3f", parasiticsSF),
      String(format:"%.3f", parasiticsPB),
      String(format:"%.3f", parasiticsSTO),
      String(format:"%.3f", parasiticsshared),
      String(format:"%.3f", parasiticsBU),
      String(format:"%.3f", parasiticsGasTurbine),
      String(format:"%.3f", steamTurbineGross),
      String(format:"%.3f", gasTurbineGross),
      String(format:"%.3f", backupGross),
      String(format:"%.3f", parasitics),
      String(format:"%.3f", net),
      String(format:"%.3f", consum),
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
  
  func add(date: Date, meteo: MeteoData,
           electricEnergy: ElectricEnergy,
           electricalParasitics: Components,
           heatFlow: HeatFlow,
           fuelConsumption: FuelConsumption,
           solarfield: SolarField.PerformanceData,
           collector: Collector.PerformanceData) {
    
    if intervalCount == 0, dateFormatter != nil {
      dateString = dateFormatter!.string(from: date)
    }
    
    let fraction = interval.fraction
    
    solar += heatFlow.solar * fraction
    damp += heatFlow.dump * fraction
    toStorage += heatFlow.toSTO * fraction
    storage += heatFlow.storage * fraction
    heater += heatFlow.heater * fraction
    heatExchanger += heatFlow.heatExchanger * fraction
    wasteHeatRecovery += heatFlow.wasteHeatRecovery * fraction
    boiler += heatFlow.boiler * fraction
    dump += heatFlow.dump * fraction
    production += heatFlow.production * fraction
    //backupFuel += fuelConsumption * fraction
    boilerFuel += fuelConsumption.boiler * fraction
    heaterFuel += fuelConsumption.heater * fraction
    gasTurbineFuel += fuelConsumption.gasTurbine * fraction
    
    //fuel +=
    //gross +=
    parasiticsSF += electricalParasitics.solarField * fraction
    parasiticsPB += electricalParasitics.powerBlock * fraction
    parasiticsSTO += electricalParasitics.storage * fraction
    parasiticsshared += electricalParasitics.shared * fraction
    //parasiticsBackup += electricalParasitics
    parasiticsGasTurbine += electricalParasitics.gasTurbine * fraction
    steamTurbineGross += electricEnergy.steamTurbineGross * fraction
    gasTurbineGross += electricEnergy.gasTurbineGross * fraction
    //backupGross +=
    parasitics += electricEnergy.parasitics * fraction
    net += electricEnergy.net * fraction
    consum += electricEnergy.consum * fraction
    
    dni += Double(meteo.dni) * fraction
    ico += Double(meteo.dni) * cos(collector.theta) * fraction
    
    ITA += solarfield.ITA * fraction
    ETA += solarfield.ETA * fraction
    HL += solarfield.HL * fraction
    heatLossHeader += solarfield.heatLossHeader * fraction
    heatLossHCE += solarfield.heatLossHCE * fraction
    intervalCount += 1
  }
  
  private func writeResults() {
    let csv = dateString + commaSeparatedValues
    let data = [UInt8]((csv + "\n").utf8)
    outputStream?.write(data, maxLength: data.count)
  }
  
  private func resetResults() {
    solar = 0; damp = 0; toStorage = 0; storage = 0; heater = 0
    heatExchanger = 0; wasteHeatRecovery = 0; boiler = 0; dump = 0
    production = 0; backupFuel = 0; boilerFuel = 0; heaterFuel = 0
    gasTurbineFuel = 0; fuel = 0; gross = 0; parasiticsSF = 0; parasiticsPB = 0
    parasiticsSTO = 0; parasiticsshared = 0; parasiticsBU = 0
    parasiticsGasTurbine = 0; steamTurbineGross = 0; gasTurbineGross = 0
    backupGross = 0; parasitics = 0; net = 0; consum = 0
    dni = 0; ico = 0; ITA = 0; ETA = 0; HL = 0
    heatLossHeader = 0; heatLossHCE = 0
    intervalCount = 0
  }
}
