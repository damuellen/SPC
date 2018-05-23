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
  
  var numbers: [String] {
    return [
      String(format:"%.1f", theta),
      String(format:"%.3f", cosTheta),
      String(format:"%.2f", efficiency),
      String(format:"%.1f", parabolicElevation),
    ]
  }
  
  static var titles: [(String, String)]  {
    return [
      ("Collector|theta", "degree"), ("Collector|cosTheta", "Ratio"),
      ("Collector|Eff", "%"), ("Collector|Position", "degree"),
    ]
  }
}

public struct ElectricEnergy: Encodable {
  var demand = 0.0, gross = 0.0, shared = 0.0, solarField = 0.0, powerBlock = 0.0,
  storage = 0.0, gasTurbine = 0.0, steamTurbineGross = 0.0, gasTurbineGross = 0.0,
  backupGross = 0.0, parasitics = 0.0, net = 0.0, consum = 0.0
  
  var numbers: [String] {
    return [
      String(format:"%.2f", steamTurbineGross),
      String(format:"%.2f", gasTurbineGross),
      String(format:"%.2f", backupGross),
      String(format:"%.2f", parasitics),
      String(format:"%.2f", net),
      String(format:"%.2f", consum),
    ]
  }
  
  static var titles: [(String, String)]  {
    return [
      ("Electric|SteamTurbineGross", "MWh"),
      ("Electric|GasTurbineGross", "MWh"),
      ("Electric|BackupGross", "MWh"), ("Parasitics|A", "MWh"),
      ("Electric|Net", "MWh"), ("Electric|Consum", "MWh"),
    ]
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

public struct Parasitics: Encodable {
  var boiler = 0.0, gasTurbine = 0.0, heater = 0.0, powerBlock = 0.0,
  shared = 0.0, solarField = 0.0, storage = 0.0
  
  var numbers: [String] {
    return [
      String(format:"%.2f", solarField),
      String(format:"%.2f", powerBlock),
      String(format:"%.2f", storage),
      String(format:"%.2f", shared),
      String(format:"%.2f", 0),
      String(format:"%.2f", gasTurbine),
    ]
  }
  
  static var titles: [(String, String)]  {
    return [
      ("Parasitics|SolarField", "MWh"), ("Parasitics|PowerBlock", "MWh"),
      ("Parasitics|Storage", "MWh"), ("Parasitics|Shared", "MWh"),
      ("Parasitics|Backup", "MWh"), ("Parasitics|GasTurbine", "MWh"),
    ]
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

public struct ThermalEnergy: Encodable {
  var solar = 0.0, toStorage = 0.0, toStorageMin = 0.0, storage = 0.0,
  heater = 0.0, boiler = 0.0, wasteHeatRecovery = 0.0, heatExchanger = 0.0,
  production = 0.0, demand = 0.0, dump = 0.0, overtemp_dump = 0.0
  
  var numbers: [String] {
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
  
  static var titles: [(String, String)]  {
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

public struct Throughput {
  var solar: ThermalFlow = .init()
  
  var numbers: [String] {
    return [
      String(format:"%.1f", solar.temperature.inlet.celsius),
      String(format:"%.1f", solar.temperature.outlet.celsius),
      String(format:"%.1f", solar.massFlow.rate),
    ]
  }
  
  static var titles: [(String, String)]  {
    return [
      ("SolarField|T in", "°C"), ("SolarField|T out", "°C"), ("SolarField|Mfl", "kg/s"),
    ]
  }
  
  init() { }
}

public struct FuelConsumption: Encodable {
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
  
  var numbers: [String] {
    return [
      String(format:"%.2f", backup),
      String(format:"%.2f", boiler),
      String(format:"%.2f", heater),
      String(format:"%.2f", gasTurbine),
      String(format:"%.2f", combined),
    ]
  }
  
  static var titles: [(String, String)]  {
    return [
      ("Fuel|Backup", " "), ("Fuel|Boiler", " "), ("Fuel|Heater", " "),
      ("Fuel|GasTurbine", " "), ("Fuel|Combined", " "),
    ]
  }
  
  init() { }
  
  mutating func accumulate(_ fuelConsumption: FuelConsumption, fraction: Double) {
    backup += fuelConsumption.backup * fraction
    boiler += fuelConsumption.boiler * fraction
    heater += fuelConsumption.heater * fraction
    gasTurbine += fuelConsumption.gasTurbine * fraction
  }
}
