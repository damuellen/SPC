//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Units

public struct PlantPerformance: MeasurementsConvertible {

  internal(set) public var thermal: ThermalEnergy

  internal(set) public var electric: ElectricPower

  internal(set) public var fuel: FuelConsumption

  internal(set) public var parasitics: Parasitics

  mutating func totalize(_ performance: some RangeReplaceableCollection<PlantPerformance>, fraction: Double) {
    self.thermal = performance.map(\.thermal).totalize(fraction: fraction)
    self.fuel = performance.map(\.fuel).totalize(fraction: fraction)
    self.parasitics = performance.map(\.parasitics).totalize(fraction: fraction)
    self.electric = performance.map(\.electric).totalize(fraction: fraction)
  }

  var values: [Double] {
    thermal.values + fuel.values + parasitics.values + electric.values
  }

  static var measurements: [(name: String, unit: String)] {
    ThermalEnergy.measurements + FuelConsumption.measurements
      + Parasitics.measurements + ElectricPower.measurements
  }
}

extension PlantPerformance {
  init(_ plant: Plant) {
    self.thermal = plant.heatFlow
    self.electric = plant.electricity
    self.fuel = plant.fuelConsumption
    self.parasitics = plant.electricalParasitics
  }

  init() {
    self.thermal = ThermalEnergy()
    self.electric = ElectricPower()
    self.fuel = FuelConsumption()
    self.parasitics = Parasitics()
  }
}

public struct ElectricPower: Encodable, MeasurementsConvertible {
  internal(set) public var demand: Double = .zero
  internal(set) public var gross: Double = .zero
  internal(set) public var shared: Double = .zero
  internal(set) public var solarField: Double = .zero
  internal(set) public var powerBlock: Double = .zero
  internal(set) public var storage: Double = .zero
  internal(set) public var gasTurbine: Double = .zero
  internal(set) public var steamTurbineGross: Double = .zero
  internal(set) public var gasTurbineGross: Double = .zero
  internal(set) public var photovoltaic: Double = .zero
  internal(set) public var parasitics: Double = .zero
  internal(set) public var net: Double = .zero
  internal(set) public var consum: Double = .zero

  var values: [Double] {
    [demand, steamTurbineGross, photovoltaic, storage, parasitics, shared, net, consum]
  }

  static var measurements: [(name: String, unit: String)] {
    [
      ("Electric|Demand", "MWh e"),
      ("Electric|SteamTurbineGross", "MWh e"),
      ("Electric|Photovoltaic", "MWh e"),
      ("Electric|Storage", "MWh e"),
      ("Electric|Parasitics", "MWh e"),
      ("Electric|Shared", "MWh e"),
      ("Electric|Net", "MWh e"),
      ("Electric|Consum", "MWh e"),
    ]
  }

  @discardableResult mutating func estimateDemand() -> Double {
    var estimate = 0.0
    if Design.hasGasTurbine {
      demand =
        GridDemand.current.ratio
        * (Design.layout.powerBlock - Design.layout.gasTurbine)
      estimate =
        demand
        * Simulation.parameter.electricalParasitics
      // Iter. start val. for parasitics, 10% demand
      demand += estimate
    } else {
      let power = SteamTurbine.parameter.power.max
      demand = GridDemand.current.ratio * power
      estimate = storage
    }
    return estimate
  }

  mutating  func totalize(parasitics: Parasitics) {
    // + GasTurbine = total productionuced electricity
    solarField = parasitics.solarField
    storage = parasitics.storage

    // electricPerformance.parasiticsBU =
    // electricalParasitics.heater + electricalParasitics.boiler
    powerBlock = parasitics.powerBlock
    shared = parasitics.shared

    self.parasitics =
      solarField
      + gasTurbine
      + parasitics.powerBlock
      + parasitics.shared

    self.parasitics *=
      Simulation.adjustmentFactor.electricalParasitics
  }

  mutating func consumption() {
    net = gross
    net -= parasitics

    if net < .zero {
      consum = -net
      net = .zero
    } else {
      consum = .zero
    }
  }
}

extension RangeReplaceableCollection where Element==ElectricPower {
  func totalize(fraction: Double) -> ElectricPower {
    var result = ElectricPower()
    for values in self {
      result.demand += values.demand * fraction
      result.gross += values.gross * fraction
      result.steamTurbineGross += values.steamTurbineGross * fraction
      // self.gasTurbineGross += values.gasTurbineGross * fraction
      result.photovoltaic += values.photovoltaic * fraction
      result.shared += values.shared * fraction
      result.solarField += values.solarField * fraction
      result.parasitics += values.parasitics * fraction
      result.storage += values.storage * fraction
      result.net += values.net * fraction
      result.consum += values.consum * fraction
    }
    return result
  }
}

public struct Parasitics: Encodable, MeasurementsConvertible {
  internal(set) public var boiler: Double = .zero
  internal(set) public var gasTurbine: Double = .zero
  internal(set) public var heater: Double = .zero
  internal(set) public var powerBlock: Double = .zero
  internal(set) public var shared: Double = .zero
  internal(set) public var solarField: Double = .zero
  internal(set) public var storage: Double = .zero

  var values: [Double] {
    [solarField, powerBlock, storage, shared, 0, gasTurbine]
  }

  static var measurements: [(name: String, unit: String)] {
    [
      ("Parasitics|SolarField", "MWh e"), ("Parasitics|PowerBlock", "MWh e"),
      ("Parasitics|Storage", "MWh e"), ("Parasitics|Shared", "MWh e"),
      ("Parasitics|Backup", "MWh e"), ("Parasitics|GasTurbine", "MWh e"),
    ]
  }
}

extension RangeReplaceableCollection where Element==Parasitics {
  func totalize(fraction: Double) -> Parasitics {
    var result = Parasitics()
    for values in self {
      result.solarField += values.solarField * fraction
      result.powerBlock += values.powerBlock * fraction
      result.storage += values.storage * fraction
      result.shared += values.shared * fraction
    // parasiticsBackup += electricalParasitics
      result.gasTurbine += values.gasTurbine * fraction
    }
    return result
  }
}

public struct ThermalEnergy: Encodable, MeasurementsConvertible {
  internal(set) public var solar: Power = .zero
  internal(set) public var toStorage: Power = .zero
  internal(set) public var toStorageMin: Power = .zero
  internal(set) public var storage: Power = .zero
  internal(set) public var heater: Power = .zero
  internal(set) public var boiler: Power = .zero
  internal(set) public var wasteHeatRecovery: Power = .zero
  internal(set) public var heatExchanger: Power = .zero
  internal(set) public var production: Power = .zero
  internal(set) public var demand: Power = .zero
  internal(set) public var dumping: Power = .zero
  internal(set) public var startUp: Power = .zero

  var balance: Power { production - demand }

  var values: [Double] {
    [
      demand.megaWatt, solar.megaWatt, dumping.megaWatt,
      toStorage.megaWatt, storage.megaWatt,
      heater.megaWatt, heatExchanger.megaWatt,
      startUp.megaWatt, production.megaWatt
    ]
  }

  static var measurements: [(name: String, unit: String)] {
    [
      ("Thermal|Demand", "MWh th"),
      ("Thermal|Solar", "MWh th"), ("Thermal|Dumping", "MWh th"),
      ("Thermal|ToStorage", "MWh th"), ("Thermal|Storage", "MWh th"),
      ("Thermal|Heater", "MWh th"), ("Thermal|HeatExchanger", "MWh th"),
      ("Thermal|Startup", "MWh th"), ("Thermal|Production", "MWh th")
    ]
  }

  /// Calculation of the heat supplied by the solar field
  mutating func solarProduction(_ solarField: SolarField) {
    solar.kiloWatt = solarField.massFlow.rate * solarField.heat

    if solar > .zero {
      production = solar
    } else if case .freeze = solarField.operationMode {
      solar = .zero
      production = solar
    } else {
      solar = .zero
      production = .zero
    }

    if case .defocus(let ratio) = solarField.operationMode {
      dumping = (solar / ratio.quotient) * (1-ratio.quotient)
    } else {
      dumping = .zero
    }
  }
}

extension RangeReplaceableCollection where Element==ThermalEnergy {
  func totalize(fraction: Double) -> ThermalEnergy {
    var result = ThermalEnergy()
    for values in self {
      result.solar += values.solar * fraction
      result.toStorage += values.toStorage * fraction
      result.storage += values.storage * fraction
      result.heater += values.heater * fraction
      result.heatExchanger += values.heatExchanger * fraction
      result.startUp += values.startUp * fraction
      result.wasteHeatRecovery += values.wasteHeatRecovery * fraction
      result.boiler += values.boiler * fraction
      result.dumping += values.dumping * fraction
      result.production += values.production * fraction
    }
    return result
  }
}

public struct FuelConsumption: Encodable, MeasurementsConvertible {
  internal(set) public var backup: Double = .zero
  internal(set) public var boiler: Double = .zero
  internal(set) public var heater: Double = .zero
  internal(set) public var gasTurbine: Double = .zero

  var combined: Double {
    boiler + heater
  }

  var total: Double {
    boiler + heater + gasTurbine
  }

  var values: [Double] {
    [backup, boiler, heater, gasTurbine, combined]
  }

  static var measurements: [(name: String, unit: String)] {
    [
      ("FuelConsumption|Backup", "MWh"), ("FuelConsumption|Boiler", "MWh"),
      ("FuelConsumption|Heater", "MWh"), ("FuelConsumption|GasTurbine", "MWh"),
      ("FuelConsumption|Combined", "MWh"),
    ]
  }
}

extension RangeReplaceableCollection where Element==FuelConsumption {
  func totalize(fraction: Double) -> FuelConsumption {
    var result = FuelConsumption()
    for fuel in self {
      result.backup += fuel.backup * fraction
      result.boiler += fuel.boiler * fraction
      result.heater += fuel.heater * fraction
      result.gasTurbine += fuel.gasTurbine * fraction
    }
    return result
  }
}

extension PlantPerformance: CustomStringConvertible {
  public var description: String {
    thermal.multiBar + electric.multiBar + fuel.multiBar + parasitics.multiBar
  }
}
