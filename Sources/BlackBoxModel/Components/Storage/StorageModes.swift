//
//  StorageModes.swift
//  BlackBoxModel
//
//  Created by Daniel Müllenborn on 04.02.19.
//

import Foundation

extension Storage {
  /// Calculation of thermal power and parasitics
  static func perform(_ status: inout Plant.PerformanceData,
                      mode: PerformanceData.OperationMode,
                      nightHour: Double = 12.0) -> (Double, Double)
  {
    if status.storage.operationMode != mode {
      let oldMode = status.storage.operationMode
      💬.infoMessage("""
        \(TimeStep.current) Storage mode change \(oldMode) -> \(mode)
        """)
    }
    status.storage.operationMode = mode
    
    func outletTemperature(_ status: Storage.PerformanceData) -> Temperature {
      var temp: Double
      if parameter.temperatureDischarge2[1] > 0 {
        temp = status.charge > 0.5
          ? 1 : parameter.temperatureDischarge2[status.charge]
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
        storage: &status.storage,
        solarField: &status.solarField,
        powerBlock: status.powerBlock
      )
      parasitics = Storage.parasitics(&status.storage)
    case .fossilCharge:
      thermalPower = storageFossilCharge(
        storage: &status.storage,
        powerBlock: &status.powerBlock
      )
      parasitics = Storage.parasitics(&status.storage)
    case .discharge:
      let load = dischargeLoad(&status.storage, nightHour)
      massFlowStorage(&status, dischargeLoad: load)
      (thermalPower, parasitics) = storageDischarge(
        plant: &status,
        outletTemperature
      )
    case .preheat:
      (thermalPower, parasitics) = storagePreheat(
        storage: &status.storage,
        powerBlock: status.powerBlock,
        solarField: status.solarField,
        outletTemperature
      )
    case .freezeProtection:
      storageFreezeProtection(&status)
      thermalPower = 0
      parasitics = Storage.parasitics(&status.storage)
    case .noOperation:
      // Temperatures remain constant
      status.storage.setMassFlow(rate: 0)
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
    _ status: inout Plant.PerformanceData,
    dischargeLoad: Ratio)
  {
    let solarField = status.solarField,
    powerBlock = status.powerBlock
    var storage = status.storage
    
    switch solarField.operationMode {
    case .freezeProtection:
      storage.setMassFlow(rate: dischargeLoad.ratio
        * powerBlock.massFlow.rate / parameter.heatExchangerEfficiency)
      
    case .operating where solarField.massFlow.rate > 0:
      // Mass flow is correctd by parameter.Hx this factor is new
      storage.setMassFlow(rate: powerBlock.massFlow.rate
        / parameter.heatExchangerEfficiency - solarField.massFlow.rate)
    // * 0.97 deleted after separating combined from storage only operation
    default:
      // if demand < 1 { // only for OU1!?
      //  storage.massFlow = powerBlock.massFlow * 1.3
      //    / parameter.heatExchangerEfficiency
      // for OU1 adjust to demand file and not TES design parameter
      // } else {
      // added to control TES discharge during night
      storage.setMassFlow(rate: dischargeLoad.ratio
        * powerBlock.massFlow.rate / parameter.heatExchangerEfficiency)
      // }
    }
  }

  private static func storageCharging(
    storage: inout PerformanceData,
    solarField: inout SolarField.PerformanceData,
    powerBlock: PowerBlock.PerformanceData
    ) -> Double
  {
    let heatExchanger = HeatExchanger.parameter,
    htf = SolarField.parameter.HTF
    
    storage.temperature.inlet = solarField.temperature.outlet
    
    storage.massFlow = solarField.massFlow - powerBlock.massFlow
    storage.massFlow.adjust(withFactor: parameter.heatExchangerEfficiency)
    
    var fittedTemperature: Double
    
    if parameter.temperatureCharge.coefficients[1] > 0 { // usually = 0
      fittedTemperature = storage.charge < 0.5
        ? 1 : parameter.temperatureCharge2[storage.charge]
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
    
    storage.outletTemperature(kelvin: fittedTemperature)
    
    var thermalPower = storage.massFlow.rate * htf.deltaHeat(
      storage.temperature.outlet, storage.temperature.inlet) / 1_000
    
    if case .indirect = parameter.type,
      parameter.heatExchangerRestrictedMax,
      abs(thermalPower) > parameter.heatExchangerCapacity
    {
      thermalPower *= parameter.heatExchangerCapacity
      
      storage.calculateMassFlow(from: thermalPower)
      
      // FIXME: powerBlock.massFlow = powerBlock.massFlow
      // added to avoid increase in PB massFlow
      if case .demand = parameter.strategy {
        // too much power from sun, dump
        Plant.heat.dumping.megaWatt += Plant.heat.production.megaWatt
          - heatExchanger.sccHTFheat + thermalPower
      } else {
        Plant.heat.dumping.megaWatt += Plant.heat.production.megaWatt
          - Plant.heat.demand.megaWatt + thermalPower
      }
      
      // reduce HTF massflow in solarfield
      solarField.massFlow = powerBlock.massFlow + storage.massFlow
      
      Plant.heat.solar.kiloWatt = solarField.massFlow.rate
        * SolarField.parameter.HTF.deltaHeat(
          solarField.temperature.outlet,
          solarField.temperature.inlet)
      
      Plant.heat.production = Plant.heat.solar
    }
    return thermalPower
  }
 
  private static func storageFossilCharge(
    storage: inout PerformanceData,
    powerBlock: inout PowerBlock.PerformanceData
    ) -> Double
  {
    var thermalPower = 0.0
    // heat can be stored
    
    storage.setTemperature(inlet: Heater.parameter.nominalTemperatureOut)
    storage.massFlow = powerBlock.massFlow
    
    var fittedTemperature: Double
    if parameter.temperatureCharge.coefficients[1] > 0 { // usually = 0
      fittedTemperature = storage.charge < 0.5
        ? 1 : parameter.temperatureCharge2[storage.charge]
      fittedTemperature *= parameter.designTemperature.cold.kelvin
        - parameter.temperatureCharge.coefficients[2]
    } else {
      fittedTemperature = -Temperature.absoluteZeroCelsius
      fittedTemperature += parameter.temperatureCharge.coefficients[0]
        - (parameter.designTemperature.cold
          - storage.temperatureTank.cold).kelvin
    }
    storage.outletTemperature(kelvin: fittedTemperature)
    
    thermalPower = -storage.massFlow.rate
      * SolarField.parameter.HTF.deltaHeat(
        storage.temperature.outlet, storage.temperature.inlet
      ) / 1_000
    // limit the size of the salt-oil heat exchanger
    if parameter.heatExchangerRestrictedMax,
      abs(thermalPower) > parameter.heatExchangerCapacity
    {
      thermalPower *= parameter.heatExchangerCapacity
      
      storage.calculateMassFlow(from: thermalPower)
      
      powerBlock.massFlow = storage.massFlow
    }
    return thermalPower
  }
  
  private static func storageDischarge(
    plant status: inout Plant.PerformanceData,
    _ outletTemperature: (PerformanceData) -> Temperature
    ) -> (Double, Double)
  {
    var storage = status.storage,
    steamTurbine = status.steamTurbine,
    powerBlock = status.powerBlock
    
    defer {
      status.storage = storage
      status.steamTurbine = steamTurbine
      status.powerBlock = powerBlock
    }
    
    // used for parasitics
    storage.temperature.inlet = powerBlock.temperature.outlet
    
    storage.temperature.outlet = outletTemperature(storage)
    
    let htf = SolarField.parameter.HTF,
    solarField = status.solarField
    
    var thermalPower = 0.0
    
    var parasitics = 0.0
    
    while true {
      
      thermalPower = storage.massFlow.rate * htf.deltaHeat(
        storage.temperature.outlet, storage.temperature.inlet) / 1_000
      
      if parameter.heatExchangerRestrictedMax,
        abs(thermalPower) > parameter.heatExchangerCapacity
      {
        thermalPower *= parameter.heatExchangerCapacity
        storage.setMassFlow(rate: thermalPower / htf.deltaHeat(
          storage.temperature.outlet, storage.temperature.inlet) * 1_000
        )
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
      let maxLoad: Double
      (maxLoad, steamTurbine.efficiency) = SteamTurbine.perform(
        with: steamTurbine.load, boiler: status.boiler,
        gasTurbine: status.gasTurbine, heatExchanger: status.heatExchanger
      )
      
      steamTurbine.load.ratio = (Plant.heat.solar.megaWatt + thermalPower)
        / (SteamTurbine.parameter.power.max / steamTurbine.efficiency)
      steamTurbine.load.ratio = steamTurbine.load.ratio.limited(by: maxLoad)
      
      let mixTemp = htf.mixingTemperature(outlet: solarField, with: storage)
      
      let minTemp = Temperature(celsius: 310.0)
      
      if mixTemp.kelvin
        > (minTemp - Simulation.parameter.tempTolerance).kelvin * 2
      {
        thermalPower = storage.massFlow.rate * htf.deltaHeat(
          storage.temperature.outlet, storage.temperature.inlet) / 1_000
        
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
    storage: inout PerformanceData,
    powerBlock: PowerBlock.PerformanceData,
    solarField: SolarField.PerformanceData,
    _ outletTemperature: (Storage.PerformanceData) -> Temperature
    ) -> (Double, Double)
  {
    let htf = SolarField.parameter.HTF
    /// the rest is heated by SF
    var thermalPower = 0.0
    
    storage.massFlow = powerBlock.subtractingMassFlow(solarField)
    
    storage.temperature.inlet = powerBlock.temperature.outlet
    
    storage.temperature.outlet = outletTemperature(storage)
    
    thermalPower = storage.massFlow.rate * htf.deltaHeat(
      storage.temperature.outlet, storage.temperature.inlet) / 1_000
    // limit the size of the salt-oil heat exchanger
    if parameter.heatExchangerRestrictedMax,
      abs(thermalPower) > parameter.heatExchangerCapacity
    {
      thermalPower *= parameter.heatExchangerCapacity
      
      storage.calculateMassFlow(from: thermalPower)
      
      storage.temperature.outlet = outletTemperature(storage)
      
      thermalPower = -storage.massFlow.rate * htf.deltaHeat(
        storage.temperature.outlet, storage.temperature.inlet) / 1_000
    }
    return (thermalPower, Storage.parasitics(&storage))
  }
  
  private static func storageFreezeProtection(
    _ status: inout Plant.PerformanceData)
  {
    let solarField = SolarField.parameter
    
    let storage = Storage.parameter
    
    let splitfactor: Ratio = 0.4
    
    status.storage.massFlow = solarField.antiFreezeFlow
      .adjusted(withFactor: splitfactor)
    
    status.solarField.header.massFlow = solarField.antiFreezeFlow
    // used for parasitics
    status.storage.temperature.inlet = status.powerBlock.temperature.outlet
    
    var fittedTemperature = 0.0
    if storage.temperatureCharge[1] > 0 {
      if storage.temperatureDischarge.indices.contains(2) {
        status.storage.setTemperaturOutletEqualToInlet()
      } else {
        fittedTemperature = status.storage.charge > 0.5
          ? 1 : storage.temperatureCharge2[status.storage.charge]
        
        status.storage.outletTemperature(kelvin:
          fittedTemperature * storage.designTemperature.hot.kelvin
        )
      }
      status.storage.outletTemperature(kelvin:
        splitfactor.ratio * status.storage.outletTemperature
          + (1 - splitfactor.ratio) * status.storage.inletTemperature
      )
    } else {
      status.storage.temperature.outlet =
        status.storage.temperatureTank.cold
    }
  }
}
