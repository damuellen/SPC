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
      ("Storage|ColdFlow", "kg/s"), ("Storage|HotFlow", "kg/s"),
    ]
  }

  var numericalForm: [Double] {
    [heatInSalt.cold, heatInSalt.hot, massFlows.cold.rate, massFlows.hot.rate]
  }

  fileprivate mutating func calculateMassFlow(
    cold: Temperature, hot: Temperature, thermal: Double
  ) {
    let htf = Storage.parameter.HTF.properties
    heatInSalt.cold = htf.specificHeat(cold)
    heatInSalt.hot = htf.specificHeat(hot)
    let rate =
      thermal / heatInSalt.available
      * Simulation.time.steps.fraction * 3600 * 1_000
    massFlows.need.rate = rate
  }

  /// Calculate thermal power given by TES
  mutating func calculate(_ thermal: Double) -> Double {
    var thermal = thermal
    var saltMassFlow = MassFlow()

    if case .discharge = operationMode {
      calculateMassFlow(
        cold: temperature.inlet + dT_HTFsalt.cold,
        hot: temperatureTank.hot,
        thermal: thermal
      )
      saltMassFlow = massFlows.hot
    }

    if case .charging = operationMode {
      calculateMassFlow(
        cold: temperatureTank.cold,
        hot: temperature.inlet - dT_HTFsalt.hot,
        thermal: -thermal
      )
      saltMassFlow = massFlows.cold
    }

    if (saltMassFlow - massFlows.need)
      < massFlows.minimum
    {
      massFlows.need -= (-massFlows.minimum + massFlows.cold)

      if massFlows.need.rate < 10 {
        massFlows.need.rate = 0
      }
      // recalculate thermal power given by TES
      thermal =
        (-massFlows.need.rate * heatInSalt.available
          / Simulation.time.steps.fraction / 3_600) / 1_000
    }

    return thermal
  }

  private mutating func indirectCharging(thermal: Double) {
    calculateMassFlow(
      cold: temperatureTank.cold,
      hot: temperature.inlet - dT_HTFsalt.hot,
      thermal: -thermal)

    massFlows.cold = massFlows.need
    massFlows.minimum = Storage.minMassFlow(self)

    // avoids negative or too low mass and therefore no heat losses.
    if massFlows.cold < massFlows.minimum {
      massFlows.need -=
        massFlows.minimum - massFlows.cold
    }

    if abs(massFlows.need.rate) < 10 {
      massFlows.need.rate = 0

      massFlows.cold = massFlows.minimum

      massFlows.hot += massFlows.need

      charge.ratio = Storage.parameter.chargeTo
    } else {
      massFlows.hot += massFlows.need
      let designT = Storage.parameter.designTemperature
      let designDeltaT = (designT.hot - designT.cold).kelvin

      charge.ratio =
        massFlows.hot.rate * designDeltaT
        / (massOfSalt * designDeltaT)

      storedHeat =
        massFlows.hot.rate * heatInSalt.hot / 1_000 / 3_600
    }
    if massFlows.hot.rate > 0 {
       temperatureTank.hot = Temperature.mixture(
        m1: massFlows.need, m2: massFlows.hot,
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

    massFlows.cold -= massFlows.need
    massFlows.hot += massFlows.need

    let designDeltaT = (designT.hot - designT.cold).kelvin

    charge.ratio =
      massFlows.hot.rate * designDeltaT
      / massOfSalt * designDeltaT

    if massFlows.hot.rate > 0 {
      temperatureTank.hot = Temperature.mixture(
        m1: massFlows.need, m2: massFlows.hot,
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

    massFlows.hot -= massFlows.need

    // massFlow.minimum = Storage.minMassFlow(storage)
    // added to avoid negative or too low mass and therefore no heat losses
    if massFlows.hot < massFlows.minimum {
      massFlows.need -= massFlows.minimum - massFlows.hot

      if massFlows.need.rate < 10 {
        massFlows.need.rate = 0
      }
      thermalPower =
        massFlows.need.rate
        * heatInSalt.available
        / Simulation.time.steps.fraction / 3_600 / 1_000

      massFlows.hot = massFlows.minimum

      massFlows.cold += massFlows.need

      charge.ratio = Storage.parameter.dischargeToTurbine

    } else {
      massFlows.cold += massFlows.need
      let designT = Storage.parameter.designTemperature
      let designDeltaT = (designT.hot - designT.cold).kelvin

      charge.ratio =
        massFlows.hot.rate * designDeltaT
        / (massOfSalt * designDeltaT)
    }

    if massFlows.cold.rate > 0 {
      temperatureTank.cold = Temperature.mixture(
        m1: massFlows.need, m2: massFlows.cold,
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

    massFlows.cold += massFlows.need
    massFlows.hot -= massFlows.need

    let designDeltaT = (designT.hot - designT.cold).kelvin

    charge.ratio =
      massFlows.hot.rate * designDeltaT
      / massOfSalt * designDeltaT

    temperatureTank.cold = Temperature.mixture(
      m1: massFlows.need, m2: massFlows.cold,
      t1: designT.cold, t2: temperatureTank.cold
    )
  }

  private mutating func freezeProtection(powerBlock: PowerBlock) {
    let splitfactor = Storage.parameter.HTF == .hiXL ? 0.4 : 1

    let solarField = SolarField.parameter
    let antiFreezeFlow = solarField.antiFreezeFlow.ratio * solarField.massFlow.rate

    massFlows.need.rate = antiFreezeFlow * Simulation.time.steps.interval

    let mf = massFlows.need.adjusted(withFactor: splitfactor)

    temperatureTank.cold = Temperature.mixture(
      m1: mf, m2: massFlows.cold,
      t1: powerBlock.temperature.outlet,
      t2: temperatureTank.cold
    )

    antiFreezeTemperature =
      splitfactor
      * temperatureTank.cold.kelvin
      + (1 - splitfactor) * powerBlock.outletTemperature
  }

  private mutating func noOperation(powerBlock: PowerBlock) {
    let parameter = Storage.parameter
    if parameter.stepSizeIteration < -90,
      temperatureTank.cold < parameter.designTemperature.cold,
      powerBlock.temperature.outlet > temperatureTank.cold,
      massFlows.cold.rate > 0
    {
      massFlows.need.rate =
        powerBlock.massFlow.rate
        * Simulation.time.steps.fraction

      temperatureTank.cold = Temperature.mixture(
        m1: massFlows.need, m2: massFlows.cold,
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
    if massFlows.cold.rate
      > abs(parameter.dischargeToTurbine * massFlows.need.rate)
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
        / massFlows.cold.rate
      // temp after cool down
      temperatureTank.cold = Storage.tankTemperature(heatInSalt.cold)
    }

    if massFlows.hot.rate > 1 {
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
        / massFlows.hot.rate
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
