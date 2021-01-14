//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

extension Storage: MeasurementsConvertible {

  static var columns: [(name: String, unit: String)] {
    [
      ("Storage|ColdHeat", "kJ/kg"), ("Storage|HotHeat", "kJ/kg"),
      ("Storage|ColdMass", "kg"), ("Storage|HotMass", "kg"),
    ]
  }

  var numericalForm: [Double] {
    [heatInSalt.cold, heatInSalt.hot, saltMass.cold, saltMass.hot]
  }

  fileprivate mutating func calculateMassFlow(
    cold: Temperature, hot: Temperature, thermal: Double
  ) {
    let htf = Storage.parameter.HTF.properties
    heatInSalt.cold = htf.specificHeat(cold)
    heatInSalt.hot = htf.specificHeat(hot)
    saltMass.need = 
      thermal / heatInSalt.available
      * Simulation.time.steps.fraction * 3_600 * 1_000
  }

  /// Calculate thermal power given by TES
  mutating func calculate(_ thermal: Double) -> Double {
    var thermal = thermal
    var saltMassFlow = 0.0

    if case .discharge = operationMode {
      calculateMassFlow(
        cold: temperature.inlet + dT_HTFsalt.cold,
        hot: temperatureTank.hot,
        thermal: thermal
      )
      saltMassFlow = saltMass.hot
    }

    if case .charging = operationMode {
      calculateMassFlow(
        cold: temperatureTank.cold,
        hot: temperature.inlet - dT_HTFsalt.hot,
        thermal: -thermal
      )
      saltMassFlow = saltMass.cold
    }

    if (saltMassFlow - saltMass.need)
      < saltMass.minimum
    {
      saltMass.need -= (-saltMass.minimum + saltMass.cold)

      if saltMass.need < 10 {
        saltMass.need = 0
      }
      // recalculate thermal power given by TES
      thermal =
        (-saltMass.need * heatInSalt.available
          / Simulation.time.steps.fraction / 3_600) / 1_000
    }

    return thermal
  }

  private mutating func indirectCharging(thermal: Double) {
    calculateMassFlow(
      cold: temperatureTank.cold,
      hot: temperature.inlet - dT_HTFsalt.hot,
      thermal: thermal)

    saltMass.cold = saltMass.need

    // avoids negative or too low mass and therefore no heat losses.
    if saltMass.cold < saltMass.minimum {
      saltMass.need -= saltMass.minimum - saltMass.cold
    }

    if abs(saltMass.need) < 10 {
      saltMass.need = 0

      saltMass.cold = saltMass.minimum

      saltMass.hot += saltMass.need

      charge.ratio = Storage.parameter.chargeTo
    } else {
      saltMass.hot += saltMass.need
      let designT = Storage.parameter.designTemperature
      let designDeltaT = (designT.hot - designT.cold).kelvin

      charge.ratio =
        saltMass.hot * designDeltaT
        / (massOfSalt * designDeltaT)

      storedHeat =
        saltMass.hot * heatInSalt.hot / 1_000 / 3_600
    }
    if saltMass.hot > 0 {
       temperatureTank.hot = Temperature.mixture(
        m1: saltMass.need, m2: saltMass.hot,
        t1: temperature.inlet - dT_HTFsalt.hot,
        t2: temperatureTank.hot
      )
    }
  }

  func directCharging(thermal: Double) {

  }

  private mutating func fossilCharging(thermal: Double) {
    let designT = Storage.parameter.designTemperature
    calculateMassFlow(
      cold: temperatureTank.cold,
      hot: designT.hot,
      thermal: -thermal
    )

    saltMass.cold -= saltMass.need
    saltMass.hot += saltMass.need

    let designDeltaT = (designT.hot - designT.cold).kelvin

    charge.ratio =
      saltMass.hot * designDeltaT
      / massOfSalt * designDeltaT

    if saltMass.hot > 0 {
      temperatureTank.hot = Temperature.mixture(
        m1: saltMass.need, m2: saltMass.hot,
        t1: designT.hot, t2: temperatureTank.hot
      )
    }
  }

  private mutating func indirectDischarging(thermal: Double) -> Double {
    var thermalPower = thermal

    calculateMassFlow(
      cold: temperature.inlet + dT_HTFsalt.cold,
      hot: temperatureTank.hot,
      thermal: -thermalPower)

    saltMass.hot -= saltMass.need

    // massFlow.minimum = Storage.minMassFlow(storage)
    // added to avoid negative or too low mass and therefore no heat losses
    if saltMass.hot < saltMass.minimum {
      saltMass.need -= saltMass.minimum - saltMass.hot

      if saltMass.need < 10 {
        saltMass.need = 0
      }
      thermalPower =
        saltMass.need
        * heatInSalt.available
        / Simulation.time.steps.fraction / 3_600 / 1_000

      saltMass.hot = saltMass.minimum

      saltMass.cold += saltMass.need

      charge.ratio = Storage.parameter.dischargeToTurbine

    } else {
      saltMass.cold += saltMass.need
      let designT = Storage.parameter.designTemperature
      let designDeltaT = (designT.hot - designT.cold).kelvin

      charge.ratio =
        saltMass.hot * designDeltaT
        / (massOfSalt * designDeltaT)
    }

    if saltMass.cold > 0 {
      temperatureTank.cold = Temperature.mixture(
        m1: saltMass.need, m2: saltMass.cold,
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
    calculateMassFlow(
      cold: designT.cold,
      hot: temperatureTank.hot,
      thermal: thermal
    )

    saltMass.cold += saltMass.need
    saltMass.hot -= saltMass.need

    let designDeltaT = (designT.hot - designT.cold).kelvin

    charge.ratio =
      saltMass.hot * designDeltaT
      / massOfSalt * designDeltaT

    temperatureTank.cold = Temperature.mixture(
      m1: saltMass.need, m2: saltMass.cold,
      t1: designT.cold, t2: temperatureTank.cold
    )
  }

  private mutating func freezeProtection(powerBlock: PowerBlock) {
    let splitfactor = Storage.parameter.HTF == .hiXL ? 0.4 : 1

    let solarField = SolarField.parameter
    let antiFreezeFlow = solarField.antiFreezeFlow.ratio * solarField.maxMassFlow.rate

    saltMass.need = antiFreezeFlow * Simulation.time.steps.interval

    let mf = saltMass.need * splitfactor

    temperatureTank.cold = Temperature.mixture(
      m1: mf, m2: saltMass.cold,
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
      saltMass.cold > 0
    {
      saltMass.need =
        powerBlock.massFlow.rate
        * Simulation.time.steps.fraction

      temperatureTank.cold = Temperature.mixture(
        m1: saltMass.need, m2: saltMass.cold,
        t1: powerBlock.temperature.outlet,
        t2: temperatureTank.cold
      )
      // status.operationMode = .sc
    }
  }

  mutating func calculate(thermal: inout Double, _ powerBlock: PowerBlock) {
    let designTemperature = Storage.parameter.designTemperature
    let htf = Storage.parameter.HTF.properties
    heatInSalt.cold = htf.specificHeat(designTemperature.cold)
    heatInSalt.hot = htf.specificHeat(designTemperature.hot)

    massOfSalt = Storage.calculatingMass(self)

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
    // FIXME: HeatExchanger.storage.H2OinTmax = storage.mass.hot
    // HeatExchanger.storage.H2OinTmin = storage.mass.cold
    // HeatExchanger.storage.H2OoutTmax = storage.temperatureTank.hot
    // HeatExchanger.storage.H2OoutTmin = storage.temperatureTank.cold
  }

  mutating func heatlosses() {
    let parameter = Storage.parameter
    if saltMass.cold
      > abs(parameter.dischargeToTurbine * saltMass.need)
    {
      // enthalpy before cooling down
      heatInSalt.cold = parameter.HTF.properties.specificHeat(
        temperatureTank.cold
      )

      let coldTankHeatLoss =
        parameter.heatLoss.cold
        * (temperatureTank.cold.kelvin)
        / (parameter.designTemperature.cold.kelvin - 27)
      // enthalpy after cooling down
      heatInSalt.cold -=
        coldTankHeatLoss * Double(period)
        / saltMass.cold
      // temp after cool down
      temperatureTank.cold = Storage.tankTemperature(heatInSalt.cold)
    }

    if saltMass.hot > 1 {
      // parameter.dischargeToTurbine * Saltmass {
      // enthalpy before cooling down
      heatInSalt.hot = parameter.HTF.properties.specificHeat(
        temperatureTank.hot
      )

      let hotTankHeatLoss =
        parameter.heatLoss.hot
        * (temperatureTank.hot.kelvin)
        / (parameter.designTemperature.hot.kelvin - 27)
      // enthalpy after cooling down
      heatInSalt.hot -=
        hotTankHeatLoss * Double(period)
        / saltMass.hot
      // temp after cool down
      temperatureTank.hot = Storage.tankTemperature(heatInSalt.hot)
      //print(storage.temperatureTank.hot)
    }    
  }
    
  static func calculatingMass(_ storage: Storage) -> Double {
    switch Storage.parameter.definedBy {
    case .hours:
      return Design.layout.storage
        * Availability.current.value.storage.ratio
        * (1 + Storage.parameter.dischargeToTurbine)
        * HeatExchanger.parameter.sccHTFheat * 1_000 * 3_600
        / storage.heatInSalt.available
    case .cap:
      return Design.layout.storage_cap
        * Availability.current.value.storage.ratio
        * (1 + Storage.parameter.dischargeToTurbine) * 1_000 * 3_600
        / storage.heatInSalt.available
    case .ton:
      return Design.layout.storage_ton
        * Availability.current.value.storage.ratio
        * (1 + Storage.parameter.dischargeToTurbine) * 1_000
    }
  }
}
