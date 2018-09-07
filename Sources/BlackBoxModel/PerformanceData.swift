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

protocol PerformanceData {
  static var columns: [(name: String, unit: String)] { get }
  var values: [String] { get }
}

extension PerformanceData {
  var description: String {
    return zip(values, Self.columns).reduce("\n") { result, pair in
      let (value, desc) = pair
      return result + (desc.name >< (value + " " + desc.unit))
    }
  }
}

extension Plant {
  public struct PerformanceData: CustomStringConvertible {
    public var collector = Collector.initialState,
    boiler = Boiler.initialState,
    powerBlock = PowerBlock.initialState,
    solarField = SolarField.initialState,
    steamTurbine = SteamTurbine.initialState,
    heater = Heater.initialState,
    heatExchanger = HeatExchanger.initialState,
    gasTurbine = GasTurbine.initialState,
    storage = Storage.initialState

    public init() {}

    public var description: String {
      return "Collector:\n\(collector)\n\n"
        + "Boiler:\n\(boiler)\n\n"
        + "Power Block:\n\(powerBlock)\n\n"
        + "Solar Field:\n\(solarField)\n\n"
        + "Steam Turbine:\n\(steamTurbine)\n\n"
        + "Heater:\n\(heater)\n\n"
        + "Heat Exchanger:\n\(heatExchanger)\n\n"
        + "Gas Turbine:\n\(gasTurbine)\n\n"
        + "Storage:\n\(storage)\n"
    }

    var csv: String {
      let values = storage.values + heater.values
        + powerBlock.values + heatExchanger.values
        + solarField.values + solarField.loops[0].values
      return values.joined(separator: .separator)
    }

    static var columns: [(String, String)] {
      let values: [(name: String, unit: String)] =
        [("|Massflow", "kg/s"), ("|Tin", "degC"), ("|Tout", "degC")]
      return ["Storage", "Heater", "PowerBlock", "HeatExchanger", "SolarField", "Loop"]
        .flatMap { name in values.map { value in (name + value.name, value.unit) } }
    }

  }
}

extension Collector.PerformanceData: PerformanceData {
  var values: [String] {
    return [
      String(format: "%.1f", theta),
      String(format: "%.2f", cosTheta),
      String(format: "%.2f", efficiency),
      String(format: "%.1f", parabolicElevation),
    ]
  }

  var csv: String {
    return String(format: "%.1f, %.1f, %.1f, %.1f",
                  theta, cosTheta, efficiency, parabolicElevation)
  }

  static var columns: [(name: String, unit: String)] {
    return [
      ("Collector|theta", "degree"), ("Collector|cosTheta", "Ratio"),
      ("Collector|Eff", "%"), ("Collector|Position", "degree"),
    ]
  }
}

public struct ElectricEnergy: Encodable, PerformanceData {
  internal(set) public var demand = 0.0, gross = 0.0, shared = 0.0,
    solarField = 0.0, powerBlock = 0.0, storage = 0.0, gasTurbine = 0.0,
    steamTurbineGross = 0.0, gasTurbineGross = 0.0, backupGross = 0.0,
    parasitics = 0.0, net = 0.0, consum = 0.0

  var values: [String] {
    return [
      String(format: "%.1f", steamTurbineGross),
      String(format: "%.1f", gasTurbineGross),
      String(format: "%.1f", backupGross),
      String(format: "%.1f", parasitics),
      String(format: "%.1f", net),
      String(format: "%.1f", consum),
    ]
  }

  var csv: String {
    return String(format: "%.1f, %.1f, %.1f, %.1f, %.1f, %.1f, ",
                  steamTurbineGross, gasTurbineGross, backupGross, parasitics, net, consum)
  }

  static var columns: [(name: String, unit: String)] {
    return [
      ("Electric|SteamTurbineGross", "MWh e"),
      ("Electric|GasTurbineGross", "MWh e"),
      ("Electric|BackupGross", "MWh e"), ("Electric|Parasitics", "MWh e"),
      ("Electric|Net", "MWh e"), ("Electric|Consum", "MWh e"),
    ]
  }

  mutating func accumulate(_ electricEnergy: ElectricEnergy, fraction: Double) {
    self.steamTurbineGross += electricEnergy.steamTurbineGross * fraction
    self.gasTurbineGross += electricEnergy.gasTurbineGross * fraction
    // backupGross +=
    self.parasitics += electricEnergy.parasitics * fraction
    self.net += electricEnergy.net * fraction
    self.consum += electricEnergy.consum * fraction
  }
}

public struct Parasitics: Encodable, PerformanceData {
  internal(set) public var boiler = 0.0, gasTurbine = 0.0, heater = 0.0,
    powerBlock = 0.0, shared = 0.0, solarField = 0.0, storage = 0.0

  var values: [String] {
    return [
      String(format: "%.2f", solarField),
      String(format: "%.2f", powerBlock),
      String(format: "%.2f", storage),
      String(format: "%.2f", shared),
      String(format: "%.2f", 0),
      String(format: "%.2f", gasTurbine),
    ]
  }

  var csv: String {
    return String(format: "%.1f, %.1f, %.1f, %.1f, %.1f, %.1f, ",
                  solarField, powerBlock, storage, shared, 0, gasTurbine)
  }

  static var columns: [(name: String, unit: String)] {
    return [
      ("Parasitics|SolarField", "MWh"), ("Parasitics|PowerBlock", "MWh"),
      ("Parasitics|Storage", "MWh"), ("Parasitics|Shared", "MWh"),
      ("Parasitics|Backup", "MWh"), ("Parasitics|GasTurbine", "MWh"),
    ]
  }

  mutating func accumulate(_ electricalParasitics: Parasitics, fraction: Double) {
    self.solarField += electricalParasitics.solarField * fraction
    self.powerBlock += electricalParasitics.powerBlock * fraction
    self.storage += electricalParasitics.storage * fraction
    self.shared += electricalParasitics.shared * fraction
    // parasiticsBackup += electricalParasitics
    self.gasTurbine += electricalParasitics.gasTurbine * fraction
  }
}

public struct ThermalEnergy: Encodable, PerformanceData {
  internal(set) public var solar = 0.0, toStorage = 0.0, toStorageMin = 0.0,
    storage = 0.0, heater = 0.0, boiler = 0.0, wasteHeatRecovery = 0.0,
    heatExchanger = 0.0, production = 0.0, demand = 0.0, dump = 0.0,
    overtemp_dump = 0.0

  var values: [String] {
    return [
      String(format: "%.1f", solar),
      String(format: "%.1f", dump),
      String(format: "%.1f", toStorage),
      String(format: "%.1f", storage),
      String(format: "%.1f", heater),
      String(format: "%.1f", heatExchanger),
      String(format: "%.1f", wasteHeatRecovery),
      String(format: "%.1f", boiler),
      String(format: "%.1f", production),
    ]
  }

  var csv: String {
    return String(format: "%.1f, %.1f, %.1f, %.1f, %.1f, %.1f, %.1f, %.1f, %.1f, ",
                  solar, dump, toStorage, storage, heater, heatExchanger,
                  wasteHeatRecovery, boiler, production)
  }

  static var columns: [(name: String, unit: String)] {
    return [
      ("Thermal|Solar", "MWh th"), ("Thermal|Dump", "MWh th"),
      ("Thermal|ToStorage", "MWh th"), ("Thermal|Storage", "MWh th"),
      ("Thermal|Heater", "MWh th"), ("Thermal|HeatExchanger", "MWh th"),
      ("Thermal|WasteHeatRecovery", "MWh th"), ("Thermal|Boiler", "MWh th"),
      ("Thermal|Production", "MWh th"),
    ]
  }

  public var description: String {
    return zip(values, ThermalEnergy.columns).reduce("") { result, pair in
      let (value, desc) = pair
      return result + (desc.name >< (value + " " + desc.unit))
    }
  }

  mutating func accumulate(_ thermal: ThermalEnergy, fraction: Double) {
    solar += thermal.solar * fraction
    if thermal.storage < 0 {
      toStorage += thermal.storage * fraction
    } else {
      storage += thermal.storage * fraction
    }
    heater += thermal.heater * fraction
    heatExchanger += thermal.heatExchanger * fraction
    wasteHeatRecovery += thermal.wasteHeatRecovery * fraction
    boiler += thermal.boiler * fraction
    dump += thermal.dump * fraction
    production += thermal.production * fraction
  }
}

public struct FuelConsumption: Encodable, PerformanceData {
  internal(set) public var backup = 0.0,
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
      String(format: "%.1f", backup),
      String(format: "%.1f", boiler),
      String(format: "%.1f", heater),
      String(format: "%.1f", gasTurbine),
      String(format: "%.1f", combined),
    ]
  }

  var csv: String {
    return String(format: "%.1f, %.1f, %.1f, %.1f, %.1f, ",
                  backup, boiler, heater, gasTurbine, combined)
  }

  static var columns: [(name: String, unit: String)] {
    return [
      ("FuelConsumption|Backup", " "), ("FuelConsumption|Boiler", " "),
      ("FuelConsumption|Heater", " "), ("FuelConsumption|GasTurbine", " "),
      ("FuelConsumption|Combined", " "),
    ]
  }

  mutating func accumulate(_ fuel: FuelConsumption, fraction: Double) {
    backup += fuel.backup * fraction
    boiler += fuel.boiler * fraction
    heater += fuel.heater * fraction
    gasTurbine += fuel.gasTurbine * fraction
  }
}
