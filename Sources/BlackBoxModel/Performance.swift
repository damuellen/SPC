//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

public struct Performance: MeasurementsConvertible {

  internal(set) public var thermal: ThermalPower

  internal(set) public var electric: ElectricPower

  internal(set) public var fuel: FuelConsumption

  internal(set) public var parasitics: Parasitics

  mutating func zero() {
    self.thermal = ThermalPower()
    self.fuel = FuelConsumption()
    self.parasitics = Parasitics()
    self.electric = ElectricPower()
  }

  mutating func totalize(_ values: Performance, fraction: Double) {
    self.thermal.totalize(values.thermal, fraction: fraction)
    self.fuel.totalize(values.fuel, fraction: fraction)
    self.parasitics.totalize(values.parasitics, fraction: fraction)
    self.electric.totalize(values.electric, fraction: fraction)
  }

  var numericalForm: [Double] {
    thermal.numericalForm + fuel.numericalForm
      + parasitics.numericalForm + electric.numericalForm
  }

  static var columns: [(name: String, unit: String)] {
    ThermalPower.columns + FuelConsumption.columns
      + Parasitics.columns + ElectricPower.columns
  }
}

extension Performance {
  init() {
    self.thermal = ThermalPower()
    self.electric = ElectricPower()
    self.fuel = FuelConsumption()
    self.parasitics = Parasitics()
  }
}

public struct ElectricPower: Encodable, MeasurementsConvertible {
  internal(set) public var demand = 0.0, gross = 0.0, shared = 0.0,
    solarField = 0.0, powerBlock = 0.0, storage = 0.0, gasTurbine = 0.0,
    steamTurbineGross = 0.0, gasTurbineGross = 0.0, backupGross = 0.0,
    parasitics = 0.0, net = 0.0, consum = 0.0

  var numericalForm: [Double] {
    [steamTurbineGross, gasTurbineGross, backupGross, storage, parasitics, shared, net, consum]
  }

  static var columns: [(name: String, unit: String)] {
    [
      ("Electric|SteamTurbineGross", "MWh e"),
      ("Electric|GasTurbineGross", "MWh e"),
      ("Electric|BackupGross", "MWh e"),
      ("Electric|Storage", "MWh e"),
      ("Electric|Parasitics", "MWh e"),
      ("Electric|Shared", "MWh e"),
      ("Electric|Net", "MWh e"),
      ("Electric|Consum", "MWh e"),
    ]
  }

  mutating func totalize(_ values: ElectricPower, fraction: Double) {
    self.demand += values.demand * fraction
    self.gross += values.gross * fraction
    self.steamTurbineGross += values.steamTurbineGross * fraction
    self.gasTurbineGross += values.gasTurbineGross * fraction
    self.backupGross += values.backupGross * fraction
    // backupGross +=
    self.shared += values.shared * fraction
    self.solarField += values.solarField * fraction
    self.parasitics += values.parasitics * fraction
    
    self.storage += values.storage * fraction
    self.net += values.net * fraction
    self.consum += values.consum * fraction
  }
}

public struct Parasitics: Encodable, MeasurementsConvertible {
  internal(set) public var boiler = 0.0, gasTurbine = 0.0, heater = 0.0,
    powerBlock = 0.0, shared = 0.0, solarField = 0.0, storage = 0.0

  var numericalForm: [Double] {
    [solarField, powerBlock, storage, shared, 0, gasTurbine]
  }

  static var columns: [(name: String, unit: String)] {
    [
      ("Parasitics|SolarField", "MWh e"), ("Parasitics|PowerBlock", "MWh e"),
      ("Parasitics|Storage", "MWh e"), ("Parasitics|Shared", "MWh e"),
      ("Parasitics|Backup", "MWh e"), ("Parasitics|GasTurbine", "MWh e"),
    ]
  }

  mutating func totalize(_ values: Parasitics, fraction: Double) {
    self.solarField += values.solarField * fraction
    self.powerBlock += values.powerBlock * fraction
    self.storage += values.storage * fraction
    self.shared += values.shared * fraction
    // parasiticsBackup += electricalParasitics
    self.gasTurbine += values.gasTurbine * fraction
  }
}

public struct ThermalPower: Encodable, MeasurementsConvertible {
  internal(set) public var solar: Power = 0.0, toStorage: Power = 0.0,
    toStorageMin: Power = 0.0, storage: Power = 0.0, heater: Power = 0.0,
    boiler: Power = 0.0, wasteHeatRecovery: Power = 0.0,
    heatExchanger: Power = 0.0, production: Power = 0.0, demand: Power = 0.0,
    dumping: Power = 0.0, overtemp_dump: Power = 0.0, startUp: Power = 0.0

  var excess: Power { production - demand }

  var numericalForm: [Double] {
    [
      solar.megaWatt, dumping.megaWatt,
      toStorage.megaWatt, storage.megaWatt,
      heater.megaWatt, heatExchanger.megaWatt,
      startUp.megaWatt, wasteHeatRecovery.megaWatt,
      boiler.megaWatt, production.megaWatt,
    ]
  }

  static var columns: [(name: String, unit: String)] {
    [
      ("Thermal|Solar", "MWh th"), ("Thermal|Dumping", "MWh th"),
      ("Thermal|ToStorage", "MWh th"), ("Thermal|Storage", "MWh th"),
      ("Thermal|Heater", "MWh th"), ("Thermal|HeatExchanger", "MWh th"),
      ("Thermal|Startup", "MWh th"),
      ("Thermal|WasteHeatRecovery", "MWh th"),
      ("Thermal|Boiler", "MWh th"),
      ("Thermal|Production", "MWh th"),
    ]
  }

  mutating func totalize(_ values: ThermalPower, fraction: Double) {
    solar += values.solar * fraction
    if values.storage.watt < 0 {
      toStorage += values.storage * fraction
    } else {
      storage += values.storage * fraction
    }
    heater += values.heater * fraction
    heatExchanger += values.heatExchanger * fraction
    startUp += values.startUp * fraction
    wasteHeatRecovery += values.wasteHeatRecovery * fraction
    boiler += values.boiler * fraction
    dumping += values.dumping * fraction
    production += values.production * fraction
  }
}

public struct FuelConsumption: Encodable, MeasurementsConvertible {
  internal(set) public var backup = 0.0,
    boiler = 0.0, heater = 0.0, gasTurbine = 0.0

  var combined: Double {
    boiler + heater
  }

  var total: Double {
    boiler + heater + gasTurbine
  }

  var numericalForm: [Double] {
    [backup, boiler, heater, gasTurbine, combined]
  }

  static var columns: [(name: String, unit: String)] {
    [
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
}

extension Performance: CustomStringConvertible {
  public var description: String {
    thermal.prettyDescription
      + electric.prettyDescription
      + fuel.prettyDescription
      + parasitics.prettyDescription
  }
}

struct PerformanceData<Parameterizable> {
  var heat, electric, fuel: Double
}