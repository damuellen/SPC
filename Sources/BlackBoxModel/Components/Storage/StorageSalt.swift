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

extension Storage.Salt: MeasurementsConvertible {

  static var columns: [(name: String, unit: String)] {
     [("Storage|ColdHeat", "kJ/kg"),("Storage|HotHeat", "kJ/kg"),     
     ("Storage|ColdFlow", "kg/s"),("Storage|HotFlow", "kg/s")]
  }

  var numericalForm: [Double] {
    [heat.cold, heat.hot, massFlow.cold.rate, massFlow.hot.rate]
  }

  fileprivate mutating func calculateMassFlow(
    cold: Temperature, hot: Temperature, thermal: Double)
  {
    let htf = Storage.parameter.HTF.properties
    heat.cold = htf.specificHeat(cold)
    heat.hot = htf.specificHeat(hot)
    let rate = thermal / heat.available
      * Simulation.time.steps.fraction * 3600 * 1_000
    massFlow.calculated.rate = rate
  }

  /// Calculate thermal power given by TES
  mutating func calculate(_ thermal: Double, storage: Storage) -> Double
  {
    var thermal = thermal
    var saltMassFlow = MassFlow()
    
    if case .discharge = storage.operationMode
    {
      calculateMassFlow(
        cold: storage.temperature.inlet + storage.dT_HTFsalt.cold,
        hot: storage.temperatureTank.hot,
        thermal: thermal
      )
      saltMassFlow = massFlow.hot
    }
    
    if case .charging = storage.operationMode
    {
      calculateMassFlow(
        cold: storage.temperatureTank.cold,
        hot: storage.temperature.inlet - storage.dT_HTFsalt.hot,
        thermal: -thermal
      )
      saltMassFlow = massFlow.cold
    }
    
    if (saltMassFlow - massFlow.calculated)
      < massFlow.minimum
    {
      massFlow.calculated = massFlow.calculated
        - (-massFlow.minimum + massFlow.cold)
      
      if massFlow.calculated.rate < 10 {
        massFlow.calculated.rate = 0
      }
      // recalculate thermal power given by TES
      thermal = (-massFlow.calculated.rate * heat.available
        / Simulation.time.steps.fraction / 3_600) / 1_000
    }

    return thermal
  }
  
  mutating func indirectCharging(
    _ storage: Storage, thermal: Double)
  {
    calculateMassFlow(
      cold: storage.temperatureTank.cold,
      hot: storage.temperature.inlet - storage.dT_HTFsalt.hot,
      thermal: -thermal)
    
    massFlow.cold = massFlow.calculated
    massFlow.minimum = Storage.minMassFlow(storage)

    // avoids negative or too low mass and therefore no heat losses.
    if massFlow.cold < massFlow.minimum {
      massFlow.calculated -=
        massFlow.minimum - massFlow.cold
    }
    
    if abs(massFlow.calculated.rate) < 10 {
      massFlow.calculated.rate = 0
      
      massFlow.cold = massFlow.minimum
      
      massFlow.hot += massFlow.calculated
      
      let charge = Storage.parameter.chargeTo
    } else {
      massFlow.hot += massFlow.calculated
      let designT = Storage.parameter.designTemperature
      let designDeltaT = (designT.hot - designT.cold).kelvin

      let charge = massFlow.hot.rate * designDeltaT
        / (storage.saltMass * designDeltaT)
      
      let storedHeat = massFlow.hot.rate
        * heat.hot / 1000 / 3600
    }
    if massFlow.hot.rate > 0 {
      var temperatureTankHot = Temperature.mixture(
        m1: massFlow.calculated, m2: massFlow.hot,
        t1: storage.temperature.inlet - storage.dT_HTFsalt.hot,
        t2: storage.temperatureTank.hot
      )
    }
  }
  
  func directCharging(_ storage: Storage, thermal: Double)
  {
    
  }
  
  mutating func fossilCharging(_ storage: Storage, thermal: Double)
  {
    let designT = Storage.parameter.designTemperature
    calculateMassFlow(
      cold: storage.temperatureTank.cold,
      hot: designT.hot,
      thermal: -thermal
    )
    
    massFlow.cold -= massFlow.calculated
    massFlow.hot += massFlow.calculated
    
    let designDeltaT = (designT.hot - designT.cold).kelvin
    
    let charge = massFlow.hot.rate * designDeltaT
      / storage.saltMass * designDeltaT
    
    if massFlow.hot.rate > 0 {
      var temperatureTankHot = Temperature.mixture(
        m1: massFlow.calculated, m2: massFlow.hot,
        t1: designT.hot, t2: storage.temperatureTank.hot
      )
    }
  }
  
  private mutating func indirectDischarging(
    _ storage: Storage, thermal: Double) -> Double
  {
    var thermalPower = thermal
    
    calculateMassFlow(
      cold: storage.temperature.inlet + storage.dT_HTFsalt.cold,
      hot: storage.temperatureTank.hot,
      thermal: -thermalPower)

    massFlow.hot -= massFlow.calculated
    
   // massFlow.minimum = Storage.minMassFlow(storage)
    // added to avoid negative or too low mass and therefore no heat losses
    if massFlow.hot < massFlow.minimum {
      massFlow.calculated -=
        massFlow.minimum - massFlow.hot
      
      if massFlow.calculated.rate < 10 {
        massFlow.calculated.rate = 0
      }
      thermalPower = massFlow.calculated.rate
        * heat.available
        / Simulation.time.steps.fraction / 3_600 / 1_000
      
      massFlow.hot = massFlow.minimum
      
      massFlow.cold += massFlow.calculated
      
      let charge = Storage.parameter.dischargeToTurbine
      
    } else {
      massFlow.cold += massFlow.calculated
      let designT = Storage.parameter.designTemperature
      let designDeltaT = (designT.hot - designT.cold).kelvin
      
      let charge = massFlow.hot.rate * designDeltaT
        / (storage.saltMass * designDeltaT)
    }
    
    if massFlow.cold.rate > 0 {
      let temperatureTankCold = Temperature.mixture(
        m1: massFlow.calculated, m2: massFlow.cold,
        t1: storage.temperature.inlet + storage.dT_HTFsalt.cold,
        t2: storage.temperatureTank.cold
      )
    }
    return thermalPower
  }
  
  private mutating func directDischarging(
    _ storage: Storage, thermal: Double) -> Double
  {
    return 0
  }
  
  private mutating func preheating(
    _ storage: Storage, thermal: Double)
  {
    let designT = Storage.parameter.designTemperature
    calculateMassFlow(
      cold: designT.cold,
      hot: storage.temperatureTank.hot,
      thermal: thermal
    )
    
    massFlow.cold += massFlow.calculated
    massFlow.hot -= massFlow.calculated
    
    let designDeltaT = (designT.hot - designT.cold).kelvin
    
    let charge = massFlow.hot.rate * designDeltaT
      / storage.saltMass * designDeltaT
    
    let temperatureTankCold = Temperature.mixture(
      m1: massFlow.calculated, m2: massFlow.cold,
      t1: designT.cold, t2: storage.temperatureTank.cold
    )
  }
  
  private mutating func freezeProtection(
    _ storage: Storage, powerBlock: PowerBlock)
  {
    let splitfactor = Storage.parameter.HTF == .hiXL ? 0.4 : 1

    let solarField =  SolarField.parameter

    massFlow.calculated.rate =
      solarField.antiFreezeFlow.rate * Simulation.time.steps.interval

    let mf = massFlow.calculated
      .adjusted(withFactor: splitfactor)

    let temperatureTankCold = Temperature.mixture(
      m1: mf, m2: massFlow.cold,
      t1: powerBlock.temperature.outlet,
      t2: storage.temperatureTank.cold
    )
    
    let antiFreezeTemperature = splitfactor
      * storage.temperatureTank.cold.kelvin
      + (1 - splitfactor) * powerBlock.outletTemperature
  }
  
  private mutating func noOperation(_ storage: Storage, powerBlock: PowerBlock)
  {
    let parameter = Storage.parameter
    if parameter.stepSizeIteration < -90,
      storage.temperatureTank.cold < parameter.designTemperature.cold,
      powerBlock.temperature.outlet > storage.temperatureTank.cold,
      massFlow.cold.rate > 0
    {
      massFlow.calculated.rate = powerBlock.massFlow.rate
        * Simulation.time.steps.fraction
      
      let temperatureTankCold = Temperature.mixture(
        m1: massFlow.calculated, m2: massFlow.cold,
        t1: powerBlock.temperature.outlet,
        t2: storage.temperatureTank.cold
      )
      // status.operationMode = .sc
    }
  }

  mutating func calculate(
    thermal: inout Double, storage: inout Storage, _ powerBlock: PowerBlock)
  {
    let designTemperature = Storage.parameter.designTemperature
    let htf = Storage.parameter.HTF
    //heat.cold = htf.specificHeat(designTemperature.cold)
   // heat.hot = htf.specificHeat(designTemperature.hot)
    
  //  storage.saltMass = Storage.saltMass(storage)
    //   Saltmass = parameter.heatLossConstants0[3]
    
    switch storage.operationMode {
    case .charging:
      switch Storage.parameter.type {
      case .indirect:
        indirectCharging(storage, thermal: thermal)
      case .direct:
        directCharging(storage, thermal: thermal)
      }
    case .fossilCharge:
      fossilCharging(storage, thermal: thermal)
    case .discharge:
      switch Storage.parameter.type {
      case .indirect:
        thermal = indirectDischarging(storage, thermal: thermal)
      case .direct:
        thermal = directDischarging(storage, thermal: thermal)
      }      
    case .preheat:
      preheating(storage, thermal: thermal)
    case .freezeProtection:
      freezeProtection(storage, powerBlock: powerBlock)
    // powerBlock.temperature.outlet = storage.temperatureTank.cold
    case .noOperation:
      noOperation(storage, powerBlock: powerBlock)
    }
    // FIXME: HeatExchanger.storage.H2OinTmax = storage.mass.hot
    // HeatExchanger.storage.H2OinTmin = storage.mass.cold
    // HeatExchanger.storage.H2OoutTmax = storage.temperatureTank.hot
    // HeatExchanger.storage.H2OoutTmin = storage.temperatureTank.cold
  }
  
  mutating func heatlosses(storage: inout Storage) {
    let parameter = Storage.parameter
    if massFlow.cold.rate
      > abs(parameter.dischargeToTurbine * storage.salt.massFlow.calculated.rate)
    {
      // enthalpy before cooling down
      heat.cold = parameter.HTF.properties.specificHeat(
        storage.temperatureTank.cold
      )
      
      let coldTankHeatLoss = parameter.heatLoss.cold
        * (storage.temperatureTank.cold.kelvin)
        / (parameter.designTemperature.cold.kelvin - 27)
      // enthalpy after cooling down
      heat.cold -= coldTankHeatLoss * Double(period)
        / massFlow.cold.rate
      // temp after cool down
      storage.temperatureTank.cold = Storage.tankTemperature(heat.cold)
    }
    
    if massFlow.hot.rate > 1 {
      // parameter.dischargeToTurbine * Saltmass {
      // enthalpy before cooling down
      heat.hot = parameter.HTF.properties.specificHeat(
        storage.temperatureTank.hot
      )
      
      let hotTankHeatLoss = parameter.heatLoss.hot
        * (storage.temperatureTank.hot.kelvin)
        / (parameter.designTemperature.hot.kelvin - 27)
      // enthalpy after cooling down
      heat.hot -= hotTankHeatLoss * Double(period)
        / massFlow.hot.rate
      // temp after cool down
      storage.temperatureTank.hot = Storage.tankTemperature(heat.hot)
      //print(storage.temperatureTank.hot)
    }
    storage.salt = self
  }  
}
