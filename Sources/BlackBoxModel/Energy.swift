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

public struct Energy: CustomStringConvertible {
  
  internal(set) public var thermal: ThermalEnergy
  
  internal(set) public var electric: ElectricPower
  
  internal(set) public var fuel: FuelConsumption
  
  internal(set) public var parasitics: Parasitics
  
  public var description: String {
    return "\n" + (thermal.description + parasitics.description
      + electric.description + fuel.description).split(
        separator: "\n", maxSplits: .max, omittingEmptySubsequences: true
        ).joined(separator: "\n") + "\n"
  }
  
  mutating func reset() {
    self.thermal = ThermalEnergy()
    self.fuel = FuelConsumption()
    self.parasitics = Parasitics()
    self.electric = ElectricPower()
  }
  
  mutating func totalize(_ energy: Energy, fraction: Double) {
    self.thermal.totalize(energy.thermal, fraction: fraction)
    self.fuel.totalize(energy.fuel, fraction: fraction)
    self.parasitics.totalize(energy.parasitics, fraction: fraction)
    self.electric.totalize(energy.electric, fraction: fraction)
  }
}

extension Energy {
  init() {
    self.thermal = ThermalEnergy()
    self.electric = ElectricPower()
    self.fuel = FuelConsumption()
    self.parasitics = Parasitics()
  }
}

public struct ElectricPower: Encodable, PerformanceData {
  internal(set) public var demand = 0.0, gross = 0.0, shared = 0.0,
  solarField = 0.0, powerBlock = 0.0, storage = 0.0, gasTurbine = 0.0,
  steamTurbineGross = 0.0, gasTurbineGross = 0.0, backupGross = 0.0,
  parasitics = 0.0, net = 0.0, consum = 0.0
  
  var values: [String] {
    return NumberFormatter.string(precision: 1, [
      steamTurbineGross, gasTurbineGross, backupGross,
      parasitics, net, consum,
    ])
  }
  
  var csv: String {
    return "\(csv: steamTurbineGross, gasTurbineGross, backupGross, parasitics, net, consum)"
  }
  
  static var columns: [(name: String, unit: String)] {
    return [
      ("Electric|SteamTurbineGross", "MWh e"),
      ("Electric|GasTurbineGross", "MWh e"),
      ("Electric|BackupGross", "MWh e"), ("Electric|Parasitics", "MWh e"),
      ("Electric|Net", "MWh e"), ("Electric|Consum", "MWh e"),
    ]
  }
  
  mutating func totalize(_ electricEnergy: ElectricPower, fraction: Double) {
    self.steamTurbineGross += electricEnergy.steamTurbineGross * fraction
    self.gasTurbineGross += electricEnergy.gasTurbineGross * fraction
    // backupGross +=
    self.parasitics += electricEnergy.parasitics * fraction
    self.net += electricEnergy.net * fraction
    self.consum += electricEnergy.consum * fraction
  }
  
  mutating func reset() {
    self.steamTurbineGross = 0
    self.gasTurbineGross = 0
    // backupGross +=
    self.parasitics = 0
    self.net = 0
    self.consum = 0
  }
}

public struct Parasitics: Encodable, PerformanceData {
  internal(set) public var boiler = 0.0, gasTurbine = 0.0, heater = 0.0,
  powerBlock = 0.0, shared = 0.0, solarField = 0.0, storage = 0.0
  
  var values: [String] {
    return NumberFormatter.string(precision: 3, [
      solarField, powerBlock, storage,
      shared, 0, gasTurbine,
    ])
  }
  
  var csv: String {
    return "\(csv: solarField, powerBlock, storage, shared, 0, gasTurbine)"
  }
  
  static var columns: [(name: String, unit: String)] {
    return [
      ("Parasitics|SolarField", "MWh"), ("Parasitics|PowerBlock", "MWh"),
      ("Parasitics|Storage", "MWh"), ("Parasitics|Shared", "MWh"),
      ("Parasitics|Backup", "MWh"), ("Parasitics|GasTurbine", "MWh"),
    ]
  }
  
  mutating func totalize(_ electricalParasitics: Parasitics, fraction: Double) {
    self.solarField += electricalParasitics.solarField * fraction
    self.powerBlock += electricalParasitics.powerBlock * fraction
    self.storage += electricalParasitics.storage * fraction
    self.shared += electricalParasitics.shared * fraction
    // parasiticsBackup += electricalParasitics
    self.gasTurbine += electricalParasitics.gasTurbine * fraction
  }
  
  mutating func reset() {
    self.solarField = 0
    self.powerBlock = 0
    self.storage = 0
    self.shared = 0
    // parasiticsBackup += electricalParasitics
    self.gasTurbine = 0
  }
}

public struct ThermalEnergy: Encodable, PerformanceData {
  internal(set) public var solar: Power = 0.0, toStorage: Power = 0.0,
  toStorageMin: Power = 0.0, storage: Power = 0.0, heater: Power = 0.0,
  boiler: Power = 0.0, wasteHeatRecovery: Power = 0.0,
  heatExchanger: Power = 0.0, production: Power = 0.0, demand: Power = 0.0,
  dumping: Power = 0.0, overtemp_dump: Power = 0.0, startUp: Power = 0.0
  
  var values: [String] {
    return NumberFormatter.string(precision: 1, [
      solar.megaWatt, dumping.megaWatt,
      toStorage.megaWatt, storage.megaWatt,
      heater.megaWatt, heatExchanger.megaWatt,
      startUp.megaWatt, wasteHeatRecovery.megaWatt,
      boiler.megaWatt, production.megaWatt,
    ])
  }
  
  var csv: String {
    return """
    \(csv: solar.megaWatt, dumping.megaWatt, toStorage.megaWatt, storage.megaWatt,
    heater.megaWatt, heatExchanger.megaWatt, startUp.megaWatt,
    wasteHeatRecovery.megaWatt, boiler.megaWatt, production.megaWatt)
    """
  }
  
  static var columns: [(name: String, unit: String)] {
    return [
      ("Thermal|Solar", "MWh th"), ("Thermal|Dumping", "MWh th"),
      ("Thermal|ToStorage", "MWh th"), ("Thermal|Storage", "MWh th"),
      ("Thermal|Heater", "MWh th"), ("Thermal|HeatExchanger", "MWh th"),
      ("Thermal|Startup", "MWh th"),
      ("Thermal|WasteHeatRecovery", "MWh th"),
      ("Thermal|Boiler", "MWh th"),
      ("Thermal|Production", "MWh th"),
    ]
  }
  
  mutating func totalize(_ thermal: ThermalEnergy, fraction: Double) {
    solar += thermal.solar * fraction
    if thermal.storage.watt < 0 {
      toStorage += thermal.storage * fraction
    } else {
      storage += thermal.storage * fraction
    }
    heater += thermal.heater * fraction
    heatExchanger += thermal.heatExchanger * fraction
    startUp += thermal.startUp * fraction
    wasteHeatRecovery += thermal.wasteHeatRecovery * fraction
    boiler += thermal.boiler * fraction
    dumping += thermal.dumping * fraction
    production += thermal.production * fraction
  }
  
  mutating func reset() {
    solar = 0.0
    toStorage = 0.0
    storage = 0.0
    heater = 0.0
    heatExchanger = 0.0
    startUp = 0.0
    wasteHeatRecovery = 0.0
    boiler = 0.0
    dumping = 0.0
    production = 0.0
  }
}

public struct FuelConsumption: Encodable, PerformanceData {
  internal(set) public var backup = 0.0,
  boiler = 0.0, heater = 0.0, gasTurbine = 0.0
  
  var combined: Double {
    return boiler + heater
  }
  
  var total: Double {
    return boiler + heater + gasTurbine
  }
  
  var values: [String] {
    return NumberFormatter.string(precision: 1, [
      backup, boiler, heater, gasTurbine, combined,
    ])
  }
  
  var csv: String {
    return "\(csv: backup, boiler, heater, gasTurbine, combined)"
  }
  
  static var columns: [(name: String, unit: String)] {
    return [
      ("FuelConsumption|Backup", "MWh"), ("FuelConsumption|Boiler", "MWh"),
      ("FuelConsumption|Heater", "MWh"), ("FuelConsumption|GasTurbine", "MWh"),
      ("FuelConsumption|Combined", "MWh"),
    ]
  }
  
  mutating func totalize(_ fuel: FuelConsumption, fraction: Double) {
    backup += fuel.backup * fraction
    boiler += fuel.boiler * fraction
    heater += fuel.heater * fraction
    gasTurbine += fuel.gasTurbine * fraction
  }
  
  mutating func reset() {
    backup = 0
    boiler = 0
    heater = 0
    gasTurbine = 0
  }
}
