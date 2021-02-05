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

  struct Salt { 
    var active: Mass = .zero
    var minimum: Mass
    var cold: Mass
    var hot: Mass

    init() {
      let parameter = Storage.parameter
      let specificHeat = parameter.HTF.properties.specificHeat
      let dischargeToTurbine = parameter.dischargeToTurbine.quotient
      let cold = specificHeat(parameter.designTemperature.cold)
      let hot = specificHeat(parameter.designTemperature.hot)
      assert(hot > cold)

      switch parameter.definedBy {
      case .hours:
        let heatFlowRate = HeatExchanger.parameter.heatFlowHTF

        self.minimum = Mass(Design.layout.storage * dischargeToTurbine
          * heatFlowRate * 1_000 * 3_600 / (hot - cold)
        )
        self.hot = Mass(
          parameter.startLoad.hot * Design.layout.storage
            * heatFlowRate * 1_000 * 3_600 / (hot - cold) + self.minimum.kg
        )        
        self.cold = Mass(
          parameter.startLoad.cold * Design.layout.storage
            * heatFlowRate * 1_000 * 3_600 / (hot - cold) + self.minimum.kg
        )
      case .cap:
        self.minimum = Mass(
          Design.layout.storage_cap * dischargeToTurbine * 1_000 * 3_600
          / (hot - cold)
        )
        self.hot = Mass(
          parameter.startLoad.hot * Design.layout.storage_cap * 1_000 * 3_600
            / (hot - cold) + self.minimum.kg
        )        
        self.cold = Mass(
          parameter.startLoad.cold * Design.layout.storage_cap * 1_000 * 3_600
            / (hot - cold) + self.minimum.kg
        )
      case .ton:
        self.minimum = Mass(Design.layout.storage_ton * dischargeToTurbine)

        self.hot = Mass(1_000 *
          (parameter.startLoad.hot * Design.layout.storage_ton) + self.minimum.kg
        )        
        self.cold = Mass(1_000 *
          (parameter.startLoad.cold * Design.layout.storage_ton) + self.minimum.kg
        )
      }
    }
  }

  fileprivate mutating func calculateMass(
    cold: Temperature, hot: Temperature, thermal: Double
  ) -> (mass: Double, delta: Double) {
    let salt = Storage.parameter.HTF.properties
    let cold = salt.specificHeat(cold)
    let hot = salt.specificHeat(hot)
    assert(hot > cold)
    let mass = (thermal / (hot - cold)
      * Simulation.time.steps.fraction * 3_600 * 1_000)
    return (mass, hot - cold)
  }

  /// Calculate thermal power given by TES
  mutating func calculate(_ thermal: Double) -> Double {
    var thermal = thermal
    var m: Mass = .zero
    var heat = 0.0
    if case .discharge = operationMode {
      (salt.active.kg, heat) = calculateMass(
        cold: temperature.inlet + dT_HTFsalt.cold,
        hot: temperatureTank.hot,
        thermal: -thermal
      )
      m = salt.hot
    }

    if case .charging = operationMode {
      (salt.active.kg, heat) = calculateMass(
        cold: temperatureTank.cold,
        hot: temperature.inlet - dT_HTFsalt.hot,
        thermal: thermal
      )
      m = salt.cold
    }

    if (m - salt.active) < salt.minimum
    {
      salt.active.kg -= -salt.minimum.kg + salt.cold.kg

      if salt.active < 10.0 {
        salt.active = Mass.zero
      }
      // recalculate thermal power given by TES
      thermal =
        (salt.active.kg * heat
          / Simulation.time.steps.fraction / 3_600) / 1_000
    }
    return thermal
  }

  private mutating func indirectCharging(thermal: Double) {
    (salt.active.kg, _) = calculateMass(
      cold: temperatureTank.cold,
      hot: temperature.inlet - dT_HTFsalt.hot,
      thermal: thermal)

    salt.cold -= salt.active

    // avoids negative or too low mass and therefore no heat losses.
    if salt.cold < salt.minimum {
      salt.active -= salt.minimum - salt.cold
    }

    if salt.active < 10.0 {
      salt.active = .zero

      salt.cold = salt.minimum

      salt.hot += salt.active

      relativeCharge = Storage.parameter.chargeTo
    } else {
      salt.hot += salt.active
      let designT = Storage.parameter.designTemperature
      let designDeltaT = (designT.hot - designT.cold).kelvin

      relativeCharge = Ratio(salt.hot.kg * designDeltaT / (massOfSalt * designDeltaT))
    }
    if salt.hot > .zero {
       temperatureTank.hot = Temperature.mixture(
        m1: salt.active, m2: salt.hot,
        t1: temperature.inlet - dT_HTFsalt.hot,
        t2: temperatureTank.hot
      )
    }
  }

  func directCharging(thermal: Double) {

  }

  private mutating func fossilCharging(thermal: Double) {
    let designT = Storage.parameter.designTemperature
    (salt.active.kg, _) = calculateMass(
      cold: temperatureTank.cold,
      hot: designT.hot,
      thermal: thermal
    )

    salt.cold -= salt.active
    salt.hot += salt.active

    let designDeltaT = (designT.hot - designT.cold).kelvin

    relativeCharge = Ratio(salt.hot.kg * designDeltaT / (massOfSalt * designDeltaT))

    if salt.hot > .zero {
      temperatureTank.hot = Temperature.mixture(
        m1: salt.active, m2: salt.hot,
        t1: designT.hot, t2: temperatureTank.hot
      )
    }
  }

  private mutating func indirectDischarging(thermal: Double) -> Double {
    let hot = salt.hot
    var thermalPower = thermal
    var heat: Double

    (salt.active.kg, heat) = calculateMass(
      cold: temperature.inlet + dT_HTFsalt.cold,
      hot: temperatureTank.hot,
      thermal: -thermalPower)

    salt.active.kg = abs(salt.active.kg)
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
      let designT = Storage.parameter.designTemperature
      let designDeltaT = (designT.hot - designT.cold).kelvin

      relativeCharge = Ratio(salt.hot.kg * designDeltaT / (massOfSalt * designDeltaT))
    }

    if salt.cold > .zero {
      temperatureTank.cold = Temperature.mixture(
        m1: salt.active, m2: salt.cold,
        t1: temperature.inlet + dT_HTFsalt.cold,
        t2: temperatureTank.cold
      )
    }
    return thermalPower
  }

  private mutating func directDischarging(thermal: Double) -> Double {
    return 0
  }

  private mutating func preheating(thermal: Double) {
    let designT = Storage.parameter.designTemperature
    (salt.active.kg, _) = calculateMass(
      cold: designT.cold,
      hot: temperatureTank.hot,
      thermal: thermal
    )

    salt.cold += salt.active
    salt.hot -= salt.active

    let designDeltaT = (designT.hot - designT.cold).kelvin

    relativeCharge = Ratio(salt.hot.kg * designDeltaT / (massOfSalt * designDeltaT))

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
      + (1 - splitfactor) * powerBlock.outletTemperature
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

  mutating func calculate(thermal: inout Double, _ powerBlock: PowerBlock) {
    switch operationMode {
    case .charging:
      switch Storage.parameter.type {
      case .indirect:
        indirectCharging(thermal: thermal)
      case .direct:
        directCharging(thermal: thermal)
      }
    case .fossilCharge:
      fossilCharging(thermal: thermal)
    case .discharge:
      switch Storage.parameter.type {
      case .indirect:
        thermal = indirectDischarging(thermal: thermal)
      case .direct:
        thermal = directDischarging(thermal: thermal)
      }
    case .preheat:
      preheating(thermal: thermal)
    case .freezeProtection:
      freezeProtection(powerBlock: powerBlock)
    // powerBlock.temperature.outlet = storage.temperatureTank.cold
    case .noOperation:
      noOperation(powerBlock: powerBlock)
    }
    // FIXME: HeatExchanger.storage.H2OinTmax = storage.salt.hot
    // HeatExchanger.storage.H2OinTmin = storage.salt.cold
    // HeatExchanger.storage.H2OoutTmax = storage.temperatureTank.hot
    // HeatExchanger.storage.H2OoutTmin = storage.temperatureTank.cold
  }

  mutating func heatlosses() {
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
      cold -= coldTankHeatLoss * Double(period) / salt.cold.kg
      // temp after cool down
      temperatureTank.cold = Storage.tankTemperature(cold)
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
      temperatureTank.hot = Storage.tankTemperature(hot)
    }    
  }
    
  static func defineSaltMass() -> Double {
    let availability = Availability.current.value.storage.quotient
    let dischargeToTurbine = Storage.parameter.dischargeToTurbine.quotient
    let designTemperature = Storage.parameter.designTemperature
    let salt = Storage.parameter.HTF.properties
    let cold = salt.specificHeat(designTemperature.cold)
    let hot = salt.specificHeat(designTemperature.hot)
    assert(hot > cold)
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
