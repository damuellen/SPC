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

extension Collector.PerformanceData {
  
  var values: [String] {
    return [
      String(format:"%.1f", theta),
      String(format:"%.2f", cosTheta),
      String(format:"%.2f", efficiency),
      String(format:"%.1f", parabolicElevation),
    ]
  }
  
  var csv: String {
    return String(format:"%.1f, %.1f, %.1f, %.1f",
                  theta, cosTheta, efficiency, parabolicElevation)
  }
  
  static var columns: [(String, String)]  {
    return [
      ("Collector|theta", "degree"), ("Collector|cosTheta", "Ratio"),
      ("Collector|Eff", "%"), ("Collector|Position", "degree"),
    ]
  }
}

public struct ElectricEnergy: Encodable, CustomStringConvertible {
  var demand = 0.0, gross = 0.0, shared = 0.0, solarField = 0.0, powerBlock = 0.0,
  storage = 0.0, gasTurbine = 0.0, steamTurbineGross = 0.0, gasTurbineGross = 0.0,
  backupGross = 0.0, parasitics = 0.0, net = 0.0, consum = 0.0
  
  var values:[String] {
    return [
      String(format:"%.1f", steamTurbineGross),
      String(format:"%.1f", gasTurbineGross),
      String(format:"%.1f", backupGross),
      String(format:"%.1f", parasitics),
      String(format:"%.1f", net),
      String(format:"%.1f", consum),
    ]
  }
  
  var csv: String {
    return String(format:"%.1f, %.1f, %.1f, %.1f, %.1f, %.1f, ",
                  steamTurbineGross, gasTurbineGross, backupGross, parasitics, net, consum)
  }
  
  static var columns: [(String, String)]  {
    return [
      ("Electric|SteamTurbineGross", "MWh"),
      ("Electric|GasTurbineGross", "MWh"),
      ("Electric|BackupGross", "MWh"), ("Electric|Parasitics", "MWh"),
      ("Electric|Net", "MWh"), ("Electric|Consum", "MWh"),
    ]
  }
  
  public var description: String {
    return zip(values, ElectricEnergy.columns).reduce("\n") { head, append in
      let text = append.1.0 >< (append.0 + " " + append.1.1)
      return head + text
    }
  }
  
  mutating func accumulate(_ electricEnergy: ElectricEnergy, fraction: Double) {
    steamTurbineGross += electricEnergy.steamTurbineGross * fraction
    gasTurbineGross += electricEnergy.gasTurbineGross * fraction
    //backupGross +=
    parasitics += electricEnergy.parasitics * fraction
    net += electricEnergy.net * fraction
    consum += electricEnergy.consum * fraction
  }
}

public struct Parasitics: Encodable, CustomStringConvertible {
  var boiler = 0.0, gasTurbine = 0.0, heater = 0.0, powerBlock = 0.0,
  shared = 0.0, solarField = 0.0, storage = 0.0
  
  var values: [String] {
    return [
      String(format:"%.2f", solarField),
      String(format:"%.2f", powerBlock),
      String(format:"%.2f", storage),
      String(format:"%.2f", shared),
      String(format:"%.2f", 0),
      String(format:"%.2f", gasTurbine),
    ]
  }
  
  var csv: String {
    return String(format:"%.1f, %.1f, %.1f, %.1f, %.1f, %.1f, ",
                  solarField, powerBlock, storage, shared, 0, gasTurbine)
  }
  
  static var columns: [(String, String)]  {
    return [
      ("Parasitics|SolarField", "MWh"), ("Parasitics|PowerBlock", "MWh"),
      ("Parasitics|Storage", "MWh"), ("Parasitics|Shared", "MWh"),
      ("Parasitics|Backup", "MWh"), ("Parasitics|GasTurbine", "MWh"),
    ]
  }
  
  public var description: String {
    return zip(values, Parasitics.columns).reduce("\n") { ininsolationAbsorberl, append in
      let text = append.1.0 >< (append.0 + " " + append.1.1)
      return ininsolationAbsorberl + text
    }
  }
  
  mutating func accumulate(_ electricalParasitics: Parasitics, fraction: Double) {
    solarField += electricalParasitics.solarField * fraction
    powerBlock += electricalParasitics.powerBlock * fraction
    storage += electricalParasitics.storage * fraction
    shared += electricalParasitics.shared * fraction
    //parasiticsBackup += electricalParasitics
    gasTurbine += electricalParasitics.gasTurbine * fraction
  }
}

public struct ThermalEnergy: Encodable, CustomStringConvertible {
  var solar = 0.0, toStorage = 0.0, toStorageMin = 0.0, storage = 0.0,
  heater = 0.0, boiler = 0.0, wasteHeatRecovery = 0.0, heatExchanger = 0.0,
  production = 0.0, demand = 0.0, dump = 0.0, overtemp_dump = 0.0
  
  var values: [String] {
    return [
      String(format:"%.1f", solar),
      String(format:"%.1f", dump),
      String(format:"%.1f", toStorage),
      String(format:"%.1f", storage),
      String(format:"%.1f", heater),
      String(format:"%.1f", heatExchanger),
      String(format:"%.1f", wasteHeatRecovery),
      String(format:"%.1f", boiler),
      String(format:"%.1f", production),
    ]
  }
  
  var csv: String {
    return String(format:"%.1f, %.1f, %.1f, %.1f, %.1f, %.1f, %.1f, %.1f, %.1f, ",
                  solar, dump, toStorage, storage, heater, heatExchanger,
                  wasteHeatRecovery, boiler, production)
  }
  
  public var description: String {
    return zip(values, ThermalEnergy.columns).reduce("\n") { ininsolationAbsorberl, append in
      let text = append.1.0 >< (append.0 + " " + append.1.1)
      return ininsolationAbsorberl + text
    }
  }
  
  static var columns: [(String, String)]  {
    return [
      ("Thermal|Solar", "MWh"), ("Thermal|Dump", "MWh"),
      ("Thermal|ToStorage", "MWh"), ("Thermal|Storage", "MWh"),
      ("Thermal|Heater", "MWh"), ("Thermal|HeatExchanger", "MWh"),
      ("Thermal|WasteHeatRecovery", "MWh"), ("Thermal|Boiler", "MWh"),
      ("Thermal|Production", "MWh"),
    ]
  }
  
  mutating func accumulate(_ thermal: ThermalEnergy, fraction: Double) {
    solar += thermal.solar * fraction
    toStorage += thermal.toStorage * fraction
    storage += thermal.storage * fraction
    heater += thermal.heater * fraction
    heatExchanger += thermal.heatExchanger * fraction
    wasteHeatRecovery += thermal.wasteHeatRecovery * fraction
    boiler += thermal.boiler * fraction
    dump += thermal.dump * fraction
    production += thermal.production * fraction
  }
}

public struct FuelConsumption: Encodable, CustomStringConvertible {
  var backup = 0.0,
   boiler = 0.0,
   heater = 0.0,
   gasTurbine = 0.0
  
  var combined: Double {
    return boiler + heater
  }
  
  var total: Double {
    return boiler + heater + gasTurbine
  }
  
  var values: [String] {
    return [
      String(format:"%.1f", backup),
      String(format:"%.1f", boiler),
      String(format:"%.1f", heater),
      String(format:"%.1f", gasTurbine),
      String(format:"%.1f", combined),
    ]
  }
  
  var csv: String {
    return String(format:"%.1f, %.1f, %.1f, %.1f, %.1f, ",
                  backup, boiler, heater, gasTurbine, combined)
  }
  
  static var columns: [(String, String)]  {
    return [
      ("Fuel|Backup", " "), ("Fuel|Boiler", " "), ("Fuel|Heater", " "),
      ("Fuel|GasTurbine", " "), ("Fuel|Combined", " "),
    ]
  }
  
  public var description: String {
    return zip(values, FuelConsumption.columns).reduce("\n") { ininsolationAbsorberl, append in
      let text = append.1.0 >< (append.0 + " " + append.1.1)
      return ininsolationAbsorberl + text
    }
  }
  
  mutating func accumulate(_ fuelConsumption: FuelConsumption, fraction: Double) {
    backup += fuelConsumption.backup * fraction
    boiler += fuelConsumption.boiler * fraction
    heater += fuelConsumption.heater * fraction
    gasTurbine += fuelConsumption.gasTurbine * fraction
  }
}

