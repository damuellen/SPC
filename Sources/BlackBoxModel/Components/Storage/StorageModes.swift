//
//  StorageModes.swift
//  BlackBoxModel
//
//  Created by Daniel Müllenborn on 04.02.19.
//

extension Storage {
  /// Calculation of thermal power and parasitics
  static func perform(
    storage: inout Storage,
    solarField: inout SolarField,
    steamTurbine: inout SteamTurbine,
    powerBlock: inout PowerBlock,
    nightHour: Double = 12.0,
    heat: inout ThermalPower)
    -> (Power, Power)
  {      
    let thermalPower, parasitics: Power
    switch storage.operationMode {
    case .charging:
      thermalPower = storageCharging(
        storage: &storage,
        solarField: &solarField,
        powerBlock: powerBlock,
        heat: &heat
      )
      parasitics = .init(megaWatt: Storage.parasitics(&storage))
    case .fossilCharge:
      thermalPower = storageFossilCharge(
        storage: &storage,
        powerBlock: &powerBlock
      )
      parasitics = .init(megaWatt: Storage.parasitics(&storage))
    case .discharge:
      let _ = dischargeLoad(&storage, nightHour)
      massFlowStorage(&storage,
        powerBlock: powerBlock,
        solarField: solarField,
        dischargeLoad: 1.0
      )
      
      (thermalPower, parasitics) = storageDischarge(
        storage: &storage,
        powerBlock: &powerBlock,
        steamTurbine: &steamTurbine,
        solarField: solarField,
        heatSolar: heat.production.megaWatt,
        outletTemperature
      )
    case .preheat:
      (thermalPower, parasitics) = storagePreheat(
        storage: &storage,
        powerBlock: powerBlock,
        solarField: solarField,
        outletTemperature
      )
    case .freezeProtection:
      storageFreezeProtection(
        storage: &storage,
        solarField: &solarField,
        powerBlock: powerBlock
      )
      thermalPower = .zero
      parasitics = .init(megaWatt: Storage.parasitics(&storage))
    case .noOperation:
      // Temperatures remain constant
      storage.massFlow.rate = .zero
      thermalPower = .zero
      parasitics = .init(megaWatt: Storage.parasitics(&storage))
    }
    return (thermalPower, parasitics)
    /*Storage Heat Losses:
     if parameter.temperatureCharge.coefficients[1] > 0 {
     if parameter.temperatureCharge.coefficients[2] > 0 {
     let fittedHeatLoss = status.storage.charge.ratio <= 0
     ? parameter.heatlossCst[status.storage.charge]
     : parameter.heatlossC0to1[status.storage.charge]
     
     status.storage.heatLossStorage = fittedHeatLoss
     * 3_600 * 1e-07 * Design.layout.storage // [MW]
     } else {
     status.storage.heatLossStorage = parameter.heatlossCst[0] / 1_000
     * (status.storage.charge.ratio * (parameter.designTemperature.hot
     - parameter.designTemperature.cold).kelvin
     + parameter.designTemperature.cold.kelvin)
     / parameter.designTemperature.hot.kelvin
     }
     } else {
     status.storage.heatLossStorage = 0
     }*/
  }
  
  static func outletTemperature(_ status: Storage) -> Temperature {
    var temp: Double
    if parameter.temperatureDischarge2[1] > 0 {
      temp = status.charge > 0.5
        ? 1 : parameter.temperatureDischarge2(status.charge)
      temp *= parameter.designTemperature.hot.kelvin
        - parameter.temperatureDischarge[1]
    } else {
      temp = -Temperature.absoluteZeroCelsius
      if status.charge.ratio < 0 {
        temp += parameter.temperatureDischarge[0]
          - (parameter.designTemperature.hot.kelvin
            - status.temperatureTank.hot.kelvin)
      } else {
        temp += parameter.temperatureCharge[0]
          - (parameter.designTemperature.hot.kelvin
            - status.temperatureTank.hot.kelvin)
        // adjust of HTF outlet temp. with status hot tank temp.
      }
    }
    return Temperature(temp)
  }

  private static func massFlowStorage(
    _ storage: inout Storage,
    powerBlock: PowerBlock,
    solarField: SolarField,
    dischargeLoad: Ratio)
  {
    switch solarField.operationMode {
    case .operating where solarField.massFlow.rate > 0:
      storage.massFlow.rate = (powerBlock.designMassFlow.rate
        / parameter.heatExchangerEfficiency) - solarField.massFlow.rate
    // * 0.97 deleted after separating combined from storage only operation
    default:
      storage.massFlow.rate = dischargeLoad.ratio
        * powerBlock.massFlow.rate / parameter.heatExchangerEfficiency
    }
  }

  private static func storageCharging(
    storage: inout Storage,
    solarField: inout SolarField,
    powerBlock: PowerBlock, heat: inout ThermalPower)
    -> Power
  {
    let heatExchanger = HeatExchanger.parameter
    var thermalPower: Power = .zero

    storage.inletTemperature(outlet: solarField)

    let x = Plant.requiredMassFlow()
    storage.massFlow.rate = solarField.massFlow.rate - x.rate

    storage.massFlow.adjust(factor: parameter.heatExchangerEfficiency)
    
    var fittedTemperature: Double
    
    if parameter.temperatureCharge.coefficients[1] > 0 { // usually = 0
      fittedTemperature = storage.charge < 0.5
        ? 1 : parameter.temperatureCharge2(storage.charge)
      fittedTemperature *= parameter.designTemperature.cold.kelvin
        - parameter.temperatureCharge.coefficients[2]
    } else {
      if case .indirect = parameter.type {
        fittedTemperature = -Temperature.absoluteZeroCelsius
        fittedTemperature += parameter.temperatureCharge.coefficients[0]
          - (parameter.designTemperature.cold.kelvin
            - storage.temperatureTank.cold.kelvin)
      } else {
        fittedTemperature = storage.temperatureTank.cold.kelvin
      }
    }

    storage.outletTemperature(kelvin: fittedTemperature)
    
    thermalPower.kiloWatt = storage.massFlow.rate * storage.deltaHeat
    
    if case .indirect = parameter.type,
      parameter.heatExchangerRestrictedMax,
      abs(thermalPower.megaWatt) > parameter.heatExchangerCapacity
    {
      thermalPower *= parameter.heatExchangerCapacity
      
      storage.massFlow.rate = thermalPower.kiloWatt / storage.deltaHeat
      
      // FIXME: powerBlock.massFlow = powerBlock.massFlow
      // added to avoid increase in PB massFlow
      if case .demand = parameter.strategy {
        // too much power from sun, dump
        heat.dumping.megaWatt += heat.production.megaWatt
          - heatExchanger.sccHTFheat + thermalPower.megaWatt
      } else {
        heat.dumping += heat.production - heat.demand + thermalPower
      }
      
      // reduce HTF massflow in solarfield
      solarField.massFlow = powerBlock.designMassFlow + storage.massFlow
      
      heat.solar.kiloWatt = solarField.massFlow.rate * solarField.deltaHeat
      
      heat.production = heat.solar
    }
    return thermalPower
  }
 
  private static func storageFossilCharge(
    storage: inout Storage, powerBlock: inout PowerBlock
    ) -> Power
  {
    var thermalPower: Power = .zero
    // heat can be stored
    
    storage.setTemperature(inlet: Heater.parameter.nominalTemperatureOut)
    storage.massFlow = powerBlock.designMassFlow
    
    var fittedTemperature: Double
    if parameter.temperatureCharge.coefficients[1] > 0 { // usually = 0
      fittedTemperature = storage.charge < 0.5
        ? 1 : parameter.temperatureCharge2(storage.charge)
      fittedTemperature *= parameter.designTemperature.cold.kelvin
        - parameter.temperatureCharge.coefficients[2]
    } else {
      fittedTemperature = -Temperature.absoluteZeroCelsius
      fittedTemperature += parameter.temperatureCharge.coefficients[0]
        - (parameter.designTemperature.cold.kelvin
          - storage.temperatureTank.cold.kelvin)
    }
    storage.outletTemperature(kelvin: fittedTemperature)
    
    thermalPower.kiloWatt = -storage.massFlow.rate * storage.deltaHeat
    // limit the size of the salt-oil heat exchanger
    if parameter.heatExchangerRestrictedMax,
      abs(thermalPower.megaWatt) > parameter.heatExchangerCapacity
    {
      thermalPower *= parameter.heatExchangerCapacity
      
      storage.massFlow.rate = thermalPower.kiloWatt / storage.deltaHeat
      
      powerBlock.designMassFlow = storage.massFlow
    }
    return thermalPower
  }
  
  private static func storageDischarge(
    storage: inout Storage,
    powerBlock: inout PowerBlock,
    steamTurbine: inout SteamTurbine,
    solarField: SolarField,
    heatSolar: Double,
    _ outletTemperature: (Storage) -> Temperature)
    -> (Power, Power)
  {
    // used for parasitics
    storage.inletTemperature(outlet: powerBlock)
    
    storage.temperature.outlet = outletTemperature(storage)
    
    let htf = SolarField.parameter.HTF
    
    var thermalPower: Power = .zero    
    var parasitics: Power = .zero
    
    while true
    {
      thermalPower.kiloWatt = storage.massFlow.rate * storage.deltaHeat
      
      if parameter.heatExchangerRestrictedMax,
        abs(thermalPower.megaWatt) > parameter.heatExchangerCapacity
      {
        thermalPower *= parameter.heatExchangerCapacity
        storage.massFlow.rate = thermalPower.kiloWatt / storage.deltaHeat
        //#warning("The implementation here differs from PCT")
        if case .freezeProtection = solarField.operationMode {          
          powerBlock.designMassFlow.rate = storage.massFlow.rate
            * parameter.heatExchangerEfficiency / 0.97 // - solarField.massFlow
        } else {
          // Mass flow is correctd by new factor
          powerBlock.designMassFlow.rate = 
            (storage.massFlow + solarField.massFlow).rate
              * parameter.heatExchangerEfficiency / 0.97          
        }
      }
      let maxLoad: Double = 1
    /*
      (maxLoad, steamTurbine.efficiency) = SteamTurbine.perform(
        with: steamTurbine.load,
        ambientTemperature: ambientTemperature,
        boiler: status.boiler,
        gasTurbine: status.gasTurbine,
        heatExchanger: status.heatExchanger
      )*/
      let ratio = (heatSolar + abs(thermalPower.megaWatt)) 
        / (SteamTurbine.parameter.power.max / 0.39) //steamTurbine.efficiency)

      steamTurbine.load = Ratio(ratio, cap: maxLoad)
      
      let mixTemp = htf.mixingTemperature(solarField, storage)
      
      let minTemp = Temperature(celsius: 310.0)
      
      if mixTemp.kelvin > minTemp.kelvin - Simulation.parameter.tempTolerance * 2
      {
        thermalPower.kiloWatt = storage.massFlow.rate * storage.deltaHeat
        
        parasitics.megaWatt = Storage.parasitics(&storage)
        break
      } else if storage.massFlow.rate <= 0.05 * powerBlock.designMassFlow.rate {
        thermalPower = 0.0
        storage.operationMode = .noOperation
        parasitics = .zero
        storage.massFlow = 0.0
        break
      }
      storage.massFlow.adjust(factor: 0.97) // reduce 5%
    }
    return (thermalPower, parasitics) // [MW]
  }
  
  private static func storagePreheat(
    storage: inout Storage,
    powerBlock: PowerBlock,
    solarField: SolarField,
    _ outletTemperature: (Storage) -> Temperature)
    -> (Power, Power)
  {
    /// the rest is heated by SF
    var thermalPower: Power = .zero    
    var parasitics: Power = .zero
    
    storage.massFlow = powerBlock.designMassFlow - solarField.massFlow
    
    storage.inletTemperature(outlet: powerBlock)
    
    storage.temperature.outlet = outletTemperature(storage)
    
    thermalPower.kiloWatt = storage.massFlow.rate * storage.deltaHeat
    // limit the size of the salt-oil heat exchanger
    if parameter.heatExchangerRestrictedMax,
      abs(thermalPower.megaWatt) > parameter.heatExchangerCapacity
    {
      thermalPower *= parameter.heatExchangerCapacity
      
      storage.massFlow.rate = thermalPower.kiloWatt / storage.deltaHeat
      
      storage.temperature.outlet = outletTemperature(storage)
      
      thermalPower.kiloWatt = -storage.massFlow.rate * storage.deltaHeat 
    }
    parasitics.megaWatt = Storage.parasitics(&storage)

    return (thermalPower, parasitics)
  }
  
  private static func storageFreezeProtection(
    storage: inout Storage,
    solarField: inout SolarField,
    powerBlock: PowerBlock)
  {
    let antiFreezeFlow = MassFlow(
      SolarField.parameter.antiFreezeFlow.ratio 
      * SolarField.parameter.maxMassFlow.rate
    )
    let splitfactor: Ratio = 0.4
    
    storage.massFlow = antiFreezeFlow.adjusted(withFactor: splitfactor)
    
    solarField.header.massFlow = antiFreezeFlow
    // used for parasitics
    storage.inletTemperature(outlet: powerBlock)
    
    var fittedTemperature = 0.0
    if Storage.parameter.temperatureCharge[1] > 0 {
      if Storage.parameter.temperatureDischarge.indices.contains(2) {
        storage.outletTemperatureFromInlet()
      } else {
        fittedTemperature = storage.charge > 0.5
          ? 1 : Storage.parameter.temperatureCharge2(storage.charge)
        
        storage.outletTemperature(kelvin: fittedTemperature
          * Storage.parameter.designTemperature.hot.kelvin
        )
      }
      storage.outletTemperature(kelvin:
        splitfactor.ratio * storage.outletTemperature
          + (1 - splitfactor.ratio) * storage.inletTemperature
      )
    } else {
      storage.temperature.outlet = storage.temperatureTank.cold
    }
  }
}
