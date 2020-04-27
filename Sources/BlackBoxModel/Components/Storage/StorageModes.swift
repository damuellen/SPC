//
//  StorageModes.swift
//  BlackBoxModel
//
//  Created by Daniel Müllenborn on 04.02.19.
//

import Foundation

extension Storage {
  /// Calculation of thermal power and parasitics
  static func perform(
    storage: inout Storage,
    solarField: inout SolarField,
    steamTurbine: inout SteamTurbine,
    powerBlock: inout PowerBlock,
    mode: Storage.OperationMode,
    nightHour: Double = 12.0,
    heat: inout ThermalEnergy)
    -> (Double, Double)
  {
    if storage.operationMode != mode {
      let oldMode = storage.operationMode
      debugPrint("""
        \(TimeStep.current) Storage mode change \(oldMode) -> \(mode)
        """)
    }
  
    storage.operationMode = mode
    
    func outletTemperature(_ status: Storage) -> Temperature {
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
    /* FIXME: Is this useless code ???
     if Plant.thermal.solar > 0 {
     status.solarField.header.massFlow = status.solarField.massFlow
     } else if case .freezeProtection = status.solarField.operationMode {
     status.solarField.header.massFlow = status.solarField.massFlow
     } else {
     status.solarField.header.massFlow = 0.0
     }
     */
    
    let thermalPower, parasitics: Double
    switch mode {
    case .charging:
      thermalPower = storageCharging(
        storage: &storage,
        solarField: &solarField,
        powerBlock: powerBlock,
        heat: &heat
      )
      parasitics = Storage.parasitics(&storage)
    case .fossilCharge:
      thermalPower = storageFossilCharge(
        storage: &storage,
        powerBlock: &powerBlock
      )
      parasitics = Storage.parasitics(&storage)
    case .discharge:
      let load = dischargeLoad(&storage, nightHour)
      massFlowStorage(&storage,
        powerBlock: powerBlock,
        solarField: solarField,
        dischargeLoad: load
      )
      
      (thermalPower, parasitics) = storageDischarge(
        storage: &storage,
        powerBlock: &powerBlock,
        steamTurbine: &steamTurbine,
        solarField: solarField,
        heatSolar: heat.solar.megaWatt,
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
      thermalPower = 0
      parasitics = Storage.parasitics(&storage)
    case .noOperation:
      // Temperatures remain constant
      storage.setMassFlow(rate: 0)
      thermalPower = 0
      parasitics = 0
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
  
  private static func massFlowStorage(
    _ storage: inout Storage,
    powerBlock: HeatCycle,
    solarField: SolarField,
    dischargeLoad: Ratio)
  {
    switch solarField.operationMode {
    case .operating where solarField.massFlow.rate > 0:
      storage.setMassFlow(rate: powerBlock.massFlow.rate
        / parameter.heatExchangerEfficiency - solarField.massFlow.rate)
    // * 0.97 deleted after separating combined from storage only operation
    default:
      storage.setMassFlow(rate: dischargeLoad.ratio
        * powerBlock.massFlow.rate / parameter.heatExchangerEfficiency)
    }
  }

  private static func storageCharging(
    storage: inout Storage,
    solarField: inout SolarField,
    powerBlock: HeatCycle, heat: inout ThermalEnergy)
    -> Double
  {
    let heatExchanger = HeatExchanger.parameter,
    htf = SolarField.parameter.HTF
    storage.setInletTemperature(equalToOutlet: solarField)
    
    storage.massFlow = solarField.massFlow - powerBlock.massFlow
    storage.massFlow.adjust(withFactor: parameter.heatExchangerEfficiency)
    
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
          - (parameter.designTemperature.cold
            - storage.temperatureTank.cold).kelvin
      } else {
        fittedTemperature = storage.temperatureTank.cold.kelvin
      }
    }
    
    storage.setOutletTemperature(inKelvin: fittedTemperature)
    
    var thermalPower = storage.massFlow.rate * htf.deltaHeat(storage) / 1_000
    
    if case .indirect = parameter.type,
      parameter.heatExchangerRestrictedMax,
      abs(thermalPower) > parameter.heatExchangerCapacity
    {
      thermalPower *= parameter.heatExchangerCapacity
      
      storage.adjustMassFlow(to: thermalPower)
      
      // FIXME: powerBlock.massFlow = powerBlock.massFlow
      // added to avoid increase in PB massFlow
      if case .demand = parameter.strategy {
        // too much power from sun, dump
        heat.dumping.megaWatt += heat.production.megaWatt
          - heatExchanger.sccHTFheat + thermalPower
      } else {
        heat.dumping.megaWatt += heat.production.megaWatt
          - heat.demand.megaWatt + thermalPower
      }
      
      // reduce HTF massflow in solarfield
      solarField.massFlow = powerBlock.massFlow + storage.massFlow
      
      heat.solar.kiloWatt = solarField.massFlow.rate
        * SolarField.parameter.HTF.deltaHeat(solarField)
      
      heat.production = heat.solar
    }
    return thermalPower
  }
 
  private static func storageFossilCharge(
    storage: inout Storage, powerBlock: inout PowerBlock
    ) -> Double
  {
    var thermalPower = 0.0
    // heat can be stored
    
    storage.setTemperature(inlet: Heater.parameter.nominalTemperatureOut)
    storage.massFlow = powerBlock.massFlow
    
    var fittedTemperature: Double
    if parameter.temperatureCharge.coefficients[1] > 0 { // usually = 0
      fittedTemperature = storage.charge < 0.5
        ? 1 : parameter.temperatureCharge2(storage.charge)
      fittedTemperature *= parameter.designTemperature.cold.kelvin
        - parameter.temperatureCharge.coefficients[2]
    } else {
      fittedTemperature = -Temperature.absoluteZeroCelsius
      fittedTemperature += parameter.temperatureCharge.coefficients[0]
        - (parameter.designTemperature.cold
          - storage.temperatureTank.cold).kelvin
    }
    storage.setOutletTemperature(inKelvin: fittedTemperature)
    
    thermalPower = -storage.massFlow.rate
      * SolarField.parameter.HTF.deltaHeat(storage) / 1_000
    // limit the size of the salt-oil heat exchanger
    if parameter.heatExchangerRestrictedMax,
      abs(thermalPower) > parameter.heatExchangerCapacity
    {
      thermalPower *= parameter.heatExchangerCapacity
      
      storage.adjustMassFlow(to: thermalPower)
      
      powerBlock.massFlow = storage.massFlow
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
    -> (Double, Double)
  {
    // used for parasitics
    storage.setInletTemperature(equalToOutlet: powerBlock)
    
    storage.temperature.outlet = outletTemperature(storage)
    
    let htf = SolarField.parameter.HTF
    
    var thermalPower = 0.0
    
    var parasitics = 0.0
    
    while true
    {
      thermalPower = storage.massFlow.rate * htf.deltaHeat(storage) / 1_000
      
      if parameter.heatExchangerRestrictedMax,
        abs(thermalPower) > parameter.heatExchangerCapacity
      {
        thermalPower *= parameter.heatExchangerCapacity
        storage.setMassFlow(rate: thermalPower / htf.deltaHeat(storage) * 1_000)
        #warning("The implementation here differs from PCT")
        if case .freezeProtection = solarField.operationMode {
          
          powerBlock.setMassFlow(rate: storage.massFlow.rate
            * parameter.heatExchangerEfficiency / 0.97) // - solarField.massFlow
        } else {
          // Mass flow is correctd by new factor
          powerBlock.setMassFlow(rate:
            (storage.massFlow + solarField.massFlow).rate
              * parameter.heatExchangerEfficiency / 0.97
          )
        }
      }
      let maxLoad: Double = 1/*
    
      (maxLoad, steamTurbine.efficiency) = SteamTurbine.perform(
        with: steamTurbine.load,
        ambientTemperature: ambientTemperature,
        boiler: status.boiler,
        gasTurbine: status.gasTurbine,
        heatExchanger: status.heatExchanger
      )*/
      
      steamTurbine.load.ratio = (heatSolar + thermalPower)
        / (SteamTurbine.parameter.power.max / steamTurbine.efficiency)
      steamTurbine.load.ratio = steamTurbine.load.ratio.limited(by: maxLoad)
      
      let mixTemp = htf.mixingTemperature(solarField, storage)
      
      let minTemp = Temperature(celsius: 310.0)
      
      if mixTemp.kelvin
        > (minTemp - Simulation.parameter.tempTolerance).kelvin * 2
      {
        thermalPower = storage.massFlow.rate
          * htf.deltaHeat(storage) / 1_000
        
        parasitics = Storage.parasitics(&storage)
        break
      } else if storage.massFlow.rate <= 0.05 * powerBlock.massFlow.rate {
        thermalPower = 0.0
        storage.operationMode = .noOperation
        parasitics = 0.0
        storage.massFlow = 0.0
        break
      }
      storage.massFlow.adjust(withFactor: 0.97) // reduce 5%
    }
    return (thermalPower, parasitics) // [MW]
  }
  
  private static func storagePreheat(
    storage: inout Storage,
    powerBlock: PowerBlock,
    solarField: SolarField,
    _ outletTemperature: (Storage) -> Temperature)
    -> (Double, Double)
  {
    let htf = SolarField.parameter.HTF
    /// the rest is heated by SF
    var thermalPower = 0.0
    
    storage.massFlow = powerBlock.subtractingMassFlow(solarField)
    
    storage.setInletTemperature(equalToOutlet: powerBlock)
    
    storage.temperature.outlet = outletTemperature(storage)
    
    thermalPower = storage.massFlow.rate * htf.deltaHeat(storage) / 1_000
    // limit the size of the salt-oil heat exchanger
    if parameter.heatExchangerRestrictedMax,
      abs(thermalPower) > parameter.heatExchangerCapacity
    {
      thermalPower *= parameter.heatExchangerCapacity
      
      storage.adjustMassFlow(to: thermalPower)
      
      storage.temperature.outlet = outletTemperature(storage)
      
      thermalPower = -storage.massFlow.rate * htf.deltaHeat(storage) / 1_000
    }
    return (thermalPower, Storage.parasitics(&storage))
  }
  
  private static func storageFreezeProtection(
    storage: inout Storage,
    solarField: inout SolarField,
    powerBlock: PowerBlock)
  {
    let antiFreezeFlow = SolarField.parameter.antiFreezeFlow

    let splitfactor: Ratio = 0.4
    
    storage.massFlow = antiFreezeFlow.adjusted(withFactor: splitfactor)
    
    solarField.header.massFlow = antiFreezeFlow
    // used for parasitics
    storage.setInletTemperature(equalToOutlet: powerBlock)
    
    var fittedTemperature = 0.0
    if Storage.parameter.temperatureCharge[1] > 0 {
      if Storage.parameter.temperatureDischarge.indices.contains(2) {
        storage.setTemperaturOutletEqualToOwnInlet()
      } else {
        fittedTemperature = storage.charge > 0.5
          ? 1 : Storage.parameter.temperatureCharge2(storage.charge)
        
        storage.setOutletTemperature(inKelvin: fittedTemperature
          * Storage.parameter.designTemperature.hot.kelvin
        )
      }
      storage.setOutletTemperature(inKelvin:
        splitfactor.ratio * storage.outletTemperature
          + (1 - splitfactor.ratio) * storage.inletTemperature
      )
    } else {
      storage.temperature.outlet = storage.temperatureTank.cold
    }
  }
}
