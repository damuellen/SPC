//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Libc
import Utilities

extension Storage.Salt: MeasurementsConvertible {
  static var columns: [(name: String, unit: String)] {
    [
      ("Storage|MassCold", "kg"), ("Storage|MassHot", "kg"),
      ("Storage|Mass", "kg")
    ]
  }

  var numericalForm: [Double] {
    [cold.kg, hot.kg, active.kg]
  }
}

extension Storage {

  public struct Salt { 
    public internal(set) var active: Mass = .zero
    public internal(set) var minimum: Mass
    public internal(set) var cold: Mass
    public internal(set) var hot: Mass
    public internal(set) var total: Mass

    init() {
      let parameter = Storage.parameter
      let specificHeat = parameter.HTF.properties.specificHeat
      let dischargeToTurbine = parameter.dischargeToTurbine.quotient
      let cold = specificHeat(parameter.designTemperature.cold)
      let hot = specificHeat(parameter.designTemperature.hot)
      let startLoad = parameter.startLoad
      precondition(hot > cold, "No usable heat content")
      precondition(parameter.startLoad.hot + parameter.startLoad.cold == 1)
      let mass: Double
      switch parameter.definedBy {
      case .hours:
        let heatFlowRate = HeatExchanger.parameter.heatFlowHTF
        mass = Design.layout.storage * heatFlowRate * 3_600 / (hot - cold)
      case .cap:
        mass = Design.layout.storage_cap * dischargeToTurbine * 3_600 / (hot - cold)
      case .ton:
        mass = Design.layout.storage_ton * dischargeToTurbine
      }
      self.minimum = Mass(ton: dischargeToTurbine * mass)
      self.hot = Mass(ton: (startLoad.hot + dischargeToTurbine) * mass)
      self.cold = Mass(ton: (startLoad.cold + dischargeToTurbine) * mass)
      self.total = Mass(ton: (1 + dischargeToTurbine) * mass)
      assert(self.minimum.kg + self.total.kg == self.cold.kg + self.hot.kg)
    }
  }

  /// Calculates the mass of salt needed to obtain the thermal output
  fileprivate mutating func calculateMass(
    cold: Temperature, hot: Temperature, thermal: Double
  ) -> (mass: Mass, delta: Double) {
    let salt = Storage.parameter.HTF.properties
    let cold = salt.specificHeat(cold)
    let hot = salt.specificHeat(hot)
    let fraction = Simulation.time.steps.fraction
    // assert(hot > cold, "No usable heat content")
    let mass = Mass(thermal / (hot - cold) * fraction * 3_600)
    return (mass, hot - cold)
  }

  /// Recalculate thermal power if salt minimum was undershot
  mutating func recalculate(_ thermal: inout Power) {
    var m: Mass = .zero
    var heat = 0.0
    if case .discharge = operationMode {
      (salt.active, heat) = calculateMass(
        cold: temperature.inlet + dT_HTFsalt.cold,
        hot: temperatureTank.hot,
        thermal: thermal.megaWatt
      )
      m = salt.hot
    }

    if case .charge = operationMode {
      (salt.active, heat) = calculateMass(
        cold: temperatureTank.cold,
        hot: temperature.inlet - dT_HTFsalt.hot,
        thermal: thermal.megaWatt
      )
      m = salt.cold
    }

    if (m - salt.active) < salt.minimum {
      salt.active.kg -= -salt.minimum.kg + salt.cold.kg
      if salt.active < 10.0 { salt.active = .zero }      
      thermal.kiloWatt =
        (salt.active.kg * heat / Simulation.time.steps.fraction / 3_600)
    }
  }

  private mutating func indirectCharging(thermal: Double) {
    (salt.active, _) = calculateMass(
      cold: temperatureTank.cold,
      hot: temperature.inlet - dT_HTFsalt.hot,
      thermal: thermal)
    let cold = salt.cold
    salt.cold -= salt.active

    // avoids negative or too low mass and therefore no heat losses.
    if salt.cold < salt.minimum {
      salt.active -= salt.minimum - salt.cold
      salt.cold = salt.minimum
    }

    if salt.active < 100.0 {
      salt.active = .zero
      salt.cold = cold
      relativeCharge = Storage.parameter.chargeTo
    } else {
      salt.hot += salt.active
      relativeCharge = Ratio(salt.hot.kg / salt.total.kg)
    }

    temperatureTank.hot = Temperature.mixture(
      m1: salt.active, m2: salt.hot,
      t1: temperature.inlet - dT_HTFsalt.hot,
      t2: temperatureTank.hot
    )
  }

  func directCharging(thermal: Double) {

  }

  private mutating func fossilCharging(thermal: Double) {
    let designT = Storage.parameter.designTemperature
    (salt.active, _) = calculateMass(
      cold: temperatureTank.cold,
      hot: designT.hot,
      thermal: thermal
    )
    salt.cold -= salt.active
    salt.hot += salt.active

    relativeCharge = Ratio(salt.hot.kg / (salt.total.kg))

    temperatureTank.hot = Temperature.mixture(
      m1: salt.active, m2: salt.hot,
      t1: designT.hot, t2: temperatureTank.hot
    )
  }

  private mutating func indirectDischarging(thermal: Double) -> Double {
    var thermalPower = thermal
    let heat: Double

    (salt.active, heat) = calculateMass(
      cold: temperature.inlet + dT_HTFsalt.cold,
      hot: temperatureTank.hot,
      thermal: -thermalPower)

    salt.active.kg = abs(salt.active.kg)
    let hot = salt.hot
    salt.hot -= salt.active

    if salt.hot < salt.minimum {
      salt.active -= salt.minimum - salt.hot
      salt.hot = salt.minimum
      if salt.active < 100.0 {
        salt.active = .zero
        salt.hot = hot
      }
      thermalPower = salt.active.kg * heat
        / Simulation.time.steps.fraction / 3_600 / 1_000

      salt.cold += salt.active

      relativeCharge = Storage.parameter.dischargeToTurbine
    } else {
      salt.cold += salt.active

      relativeCharge = Ratio(salt.hot.kg  / salt.total.kg)
    }

    temperatureTank.cold = Temperature.mixture(
      m1: salt.active, m2: salt.cold,
      t1: temperature.inlet + dT_HTFsalt.cold,
      t2: temperatureTank.cold
    )

    return thermalPower
  }

  private mutating func directDischarging(thermal: Double) -> Double {
    return 0
  }

  private mutating func preheating(thermal: Double) {
    let designT = Storage.parameter.designTemperature
    (salt.active, _) = calculateMass(
      cold: designT.cold,
      hot: temperatureTank.hot,
      thermal: thermal
    )

    salt.cold += salt.active
    salt.hot -= salt.active


    relativeCharge = Ratio(salt.hot.kg / salt.total.kg)

    temperatureTank.cold = Temperature.mixture(
      m1: salt.active, m2: salt.cold,
      t1: designT.cold, t2: temperatureTank.cold
    )
  }

  private mutating func freezeProtection(powerBlock: PowerBlock) {
    let splitfactor = Storage.parameter.HTF == .hiXL ? 0.4 : 1

    let antiFreeze = SolarField.parameter.antiFreezeFlow.quotient
    let maxMassFlow = SolarField.parameter.maxMassFlow.rate
    let antiFreezeFlow = antiFreeze * maxMassFlow

    salt.active.kg = antiFreezeFlow * Simulation.time.steps.interval

    let m = salt.active * splitfactor

    temperatureTank.cold = Temperature.mixture(
      m1: m, m2: salt.cold,
      t1: powerBlock.temperature.outlet,
      t2: temperatureTank.cold
    )

    antiFreezeTemperature =
      splitfactor * temperatureTank.cold.kelvin
      + (1 - splitfactor) * powerBlock.outlet
  }

  private mutating func noOperation(powerBlock: PowerBlock) {
    let parameter = Storage.parameter
    if parameter.stepSizeIteration < -90,
      temperatureTank.cold < parameter.designTemperature.cold,
      powerBlock.temperature.outlet > temperatureTank.cold,
      salt.cold > .zero
    {
      salt.active.kg =
        powerBlock.massFlow.rate
        * Simulation.time.steps.fraction

      temperatureTank.cold = Temperature.mixture(
        m1: salt.active, m2: salt.cold,
        t1: powerBlock.temperature.outlet,
        t2: temperatureTank.cold
      )
      // status.operationMode = .sc
    }
  }

  mutating func calculate(thermal: inout ThermalEnergy, _ powerBlock: PowerBlock) {
    switch operationMode {
    case .charge:
      switch Storage.parameter.type {
      case .indirect:
        indirectCharging(thermal: thermal.toStorage.kiloWatt)
      case .direct:
        directCharging(thermal: thermal.toStorage.kiloWatt)
      }
    case .fossilCharge:
      fossilCharging(thermal: thermal.toStorage.kiloWatt)
    case .discharge:
      switch Storage.parameter.type {
      case .indirect:
        thermal.storage.kiloWatt = indirectDischarging(thermal: thermal.storage.kiloWatt)
      case .direct:
        thermal.storage.kiloWatt = directDischarging(thermal: thermal.storage.kiloWatt)
      }
    case .preheat:
      preheating(thermal: thermal.storage.kiloWatt)
    case .freezeProtection:
      freezeProtection(powerBlock: powerBlock)
    // powerBlock.temperature.outlet = storage.temperatureTank.cold
    case .noOperation:
      noOperation(powerBlock: powerBlock)
    }
    assert((salt.minimum.kg + salt.total.kg) - (salt.cold.kg + salt.hot.kg) < 0.1)
  }

  /// Calculates the temperature drop of the tanks with the help of the heat losses
  mutating func heatlosses(for period: Double) {

    func tankTemperature(_ specificHeat: Double) -> Temperature {
      let hcap = Storage.parameter.HTF.properties.heatCapacity
      return Temperature(celsius: (-hcap[0] + (hcap[0] ** 2 - 4 * (hcap[1] * 0.5)
          * (-350.5536 - specificHeat)) ** 0.5) / (2 * hcap[1] * 0.5))
    }

    let parameter = Storage.parameter
    let specificHeat = parameter.HTF.properties.specificHeat
    if salt.cold.kg
      > abs(parameter.dischargeToTurbine.quotient * salt.active.kg)
    {
      // enthalpy before cooling down
      var cold = specificHeat(temperatureTank.cold)

      let coldTankHeatLoss =
        parameter.heatLoss.cold
        * (temperatureTank.cold.kelvin)
        / (parameter.designTemperature.cold.kelvin - 27)
      // enthalpy after cooling down
      cold -= coldTankHeatLoss * period / salt.cold.kg
      // temp after cool down
      temperatureTank.cold = tankTemperature(cold)
    }

    if salt.hot > 1.0 {
      // parameter.dischargeToTurbine * Saltmass {
      // enthalpy before cooling down
      var hot = specificHeat(temperatureTank.hot)

      let hotTankHeatLoss =
        parameter.heatLoss.hot
        * (temperatureTank.hot.kelvin)
        / (parameter.designTemperature.hot.kelvin - 27)
      // enthalpy after cooling down
      hot -= hotTankHeatLoss * Double(period) / salt.hot.kg
      // temp after cool down
      temperatureTank.hot = tankTemperature(hot)
    }    
  }

  static func defineSaltMass() -> Double {
    let availability = Availability.current.value.storage.quotient
    let dischargeToTurbine = Storage.parameter.dischargeToTurbine.quotient
    let designTemperature = Storage.parameter.designTemperature
    let salt = Storage.parameter.HTF.properties
    let cold = salt.specificHeat(designTemperature.cold)
    let hot = salt.specificHeat(designTemperature.hot)
    precondition(hot > cold, "No usable heat content")
    switch Storage.parameter.definedBy {
    case .hours:
      let heatFlowRate = HeatExchanger.parameter.heatFlowHTF
      return Design.layout.storage
        * availability * (1 + dischargeToTurbine)
        * heatFlowRate * 1_000 * 3_600 / (hot - cold)
    case .cap:
      return Design.layout.storage_cap
        * availability * (1 + dischargeToTurbine) 
        * 1_000 * 3_600 / (hot - cold)
    case .ton:
      return Design.layout.storage_ton
        * availability * (1 + dischargeToTurbine) * 1_000
    }
  }
}
