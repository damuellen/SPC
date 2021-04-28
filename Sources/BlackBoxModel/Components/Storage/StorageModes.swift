//
//  StorageModes.swift
//  BlackBoxModel
//
//  Created by Daniel Müllenborn on 04.02.19.
//

import PhysicalQuantities

extension Storage {

  public enum OperationMode {
    case noOperation, discharge(load: Ratio), charge(load: Ratio)
    case preheat, fossilCharge, freezeProtection

    var dischargeLoad: Ratio {
      get { if case .discharge(let load) = self { return load } else { return .zero } }
    }
  }

  /// Calculation of thermal power and parasitics
  static func perform(
    storage: inout Storage,
    solarField: inout SolarField,
    steamTurbine: inout SteamTurbine,
    powerBlock: inout PowerBlock,
    nightHour: Double = 12.0,
    heatFlow: inout ThermalEnergy)
    -> (Power, Power)
  {      
    let thermalPower, parasitics: Power
    switch storage.operationMode {
    case .noOperation:
      // Temperatures remain constant
      storage.massFlow.rate = .zero
      thermalPower = .zero
      parasitics = Storage.parasitics(storage)
    case .charge:      
      thermalPower = storageCharge(
        storage: &storage,
        solarField: &solarField,
        powerBlock: powerBlock,
        heatFlow: &heatFlow
      )
      parasitics = Storage.parasitics(storage)
    case .fossilCharge:
      thermalPower = storageFossilCharge(
        storage: &storage,
        powerBlock: &powerBlock
      )
      parasitics = Storage.parasitics(storage)
    case .discharge(let load):
      if load.isZero {
        // Calculated only once a day
        let l = storage.dischargeLoad(nightHour)
        storage.operationMode = .discharge(load: l)
      }     
      (thermalPower, parasitics) = storageDischarge(
        storage: &storage,
        powerBlock: &powerBlock,
        steamTurbine: &steamTurbine,
        solarField: solarField,
        heatSolar: heatFlow.production.megaWatt,
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
      parasitics = Storage.parasitics(storage)
    }
    return (thermalPower, parasitics)
    /*Storage Heat Losses:
     if parameter.temperatureCharge.coefficients[1] > 0 {
     if parameter.temperatureCharge.coefficients[2] > 0 {
     let fittedHeatLoss = status.storage.charge.quotient <= 0
     ? parameter.heatlossCst[status.storage.charge]
     : parameter.heatlossC0to1[status.storage.charge]
     
     status.storage.heatLossStorage = fittedHeatLoss
     * 3_600 * 1e-07 * Design.layout.storage // [MW]
     } else {
     status.storage.heatLossStorage = parameter.heatlossCst[0] / 1_000
     * (status.storage.charge.quotient * (parameter.designTemperature.hot
     - parameter.designTemperature.cold).kelvin
     + parameter.designTemperature.cold.kelvin)
     / parameter.designTemperature.hot.kelvin
     }
     } else {
     status.storage.heatLossStorage = 0
     }*/
  }
  
  static func outletTemperature(_ status: Storage) -> Temperature {
      if case .charge = status.operationMode {
        return status.temperatureTank.cold + 7
      } else if case .discharge = status.operationMode {
        return status.temperatureTank.hot - 7
      }
      return status.temperature.inlet
  }

  private mutating func massFlow(
    powerBlock: PowerBlock,
    solarField: SolarField)
  {
    let dischargeLoad = operationMode.dischargeLoad.quotient
    let eff = Storage.parameter.heatExchangerEfficiency
    switch solarField.operationMode {
    case .track, .defocus(_):
      massFlow.rate = (powerBlock.designMassFlow.rate / eff) - solarField.massFlow.rate
    default:
      massFlow.rate = dischargeLoad * powerBlock.designMassFlow.rate / eff
    }
  }

  private static func storageCharge(
    storage: inout Storage,
    solarField: inout SolarField,
    powerBlock: PowerBlock,
    heatFlow: inout ThermalEnergy)
    -> Power
  {
    storage.massFlow(outlet: solarField)
    storage.massFlow -= PowerBlock.requiredMassFlow()

    storage.massFlow.adjust(factor: parameter.heatExchangerEfficiency)
    let heatExchanger = HeatExchanger.parameter
    var thermalPower: Power = .zero
    var fittedTemperature: Double

    if parameter.temperatureCharge.coefficients[1] > 0 { // usually = 0
      fittedTemperature = storage.relativeCharge < 0.5
        ? 1 : parameter.temperatureCharge2(storage.relativeCharge)
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
    
    thermalPower.kiloWatt = storage.massFlow.rate * -storage.heat
    
    if case .indirect = parameter.type,
      parameter.heatExchangerRestrictedMax,
      abs(thermalPower.megaWatt) > parameter.heatExchangerCapacity
    {
      thermalPower *= parameter.heatExchangerCapacity
      
      storage.massFlow.rate = thermalPower.kiloWatt / storage.heat
      
      // FIXME: powerBlock.massFlow = powerBlock.massFlow
      // added to avoid increase in PB massFlow
      if case .demand = parameter.strategy {
        // too much power from sun, dump
        heatFlow.dumping.megaWatt += heatFlow.production.megaWatt
          - heatExchanger.heatFlowHTF + thermalPower.megaWatt
      } else {
        heatFlow.dumping += heatFlow.production - heatFlow.demand + thermalPower
      }
      
      // reduce HTF massflow in solarfield
      solarField.massFlow = powerBlock.designMassFlow + storage.massFlow
      
      heatFlow.solar.kiloWatt = solarField.massFlow.rate * solarField.heat
      
      heatFlow.production = heatFlow.solar
    }
    return thermalPower
  }
 
  private static func storageFossilCharge(
    storage: inout Storage, powerBlock: inout PowerBlock
    ) -> Power
  {
    storage.massFlow = powerBlock.massFlow
    storage.setTemperature(inlet: Heater.parameter.nominalTemperatureOut)

    var fittedTemperature: Double
    if parameter.temperatureCharge.coefficients[1] > 0 { // usually = 0
      fittedTemperature = storage.relativeCharge < 0.5
        ? 1 : parameter.temperatureCharge2(storage.relativeCharge)
      fittedTemperature *= parameter.designTemperature.cold.kelvin
        - parameter.temperatureCharge.coefficients[2]
    } else {
      fittedTemperature = -Temperature.absoluteZeroCelsius
      fittedTemperature += parameter.temperatureCharge.coefficients[0]
        - (parameter.designTemperature.cold.kelvin
          - storage.temperatureTank.cold.kelvin)
    }
    storage.outletTemperature(kelvin: fittedTemperature)

    var thermalPower: Power = .zero
    // heat can be stored
    thermalPower.kiloWatt = -storage.massFlow.rate * storage.heat
    // limit the size of the salt-oil heat exchanger
    if parameter.heatExchangerRestrictedMax,
      abs(thermalPower.megaWatt) > parameter.heatExchangerCapacity
    {
      thermalPower *= parameter.heatExchangerCapacity
      
      storage.massFlow.rate = thermalPower.kiloWatt / storage.heat
      
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
    -> (Power, Power)
  {
    // used for parasitics
    storage.inletTemperature(outlet: powerBlock)
    storage.massFlow = powerBlock.designMassFlow - powerBlock.massFlow
    storage.massFlow.rate *= storage.operationMode.dischargeLoad.quotient
    storage.temperature.outlet = outletTemperature(storage)

    var thermalPower: Power = .zero
    var parasitics: Power = .zero
    
    while true
    {
      thermalPower.kiloWatt = storage.massFlow.rate * storage.heat
      
      if parameter.heatExchangerRestrictedMax,
        abs(thermalPower.megaWatt) > parameter.heatExchangerCapacity
      {
        thermalPower *= parameter.heatExchangerCapacity
        storage.massFlow.rate = thermalPower.kiloWatt / storage.heat
        //#warning("The implementation here differs from PCT")
        if case .freeze = solarField.operationMode {          
          powerBlock.massFlow.rate = storage.massFlow.rate
            * parameter.heatExchangerEfficiency / 0.97 // - solarField.massFlow
        } else {
          // Mass flow is correctd by new factor
          powerBlock.massFlow.rate = 
            (storage.massFlow + solarField.massFlow).rate
              * parameter.heatExchangerEfficiency / 0.97          
        }
      }
      let maxLoad: Double = 1
    /*
      (maxLoad, steamTurbine.efficiency) = SteamTurbine.perform(
        steamTurbine.load,
        
        Boiler.initialState,
        GasTurbine.initialState,
        status.heatExchanger,
        ambientTemperature
      )
*/
      let ratio = (heatSolar + thermalPower.megaWatt) 
        / (SteamTurbine.parameter.power.max / steamTurbine.efficiency.quotient)

      steamTurbine.load = Ratio(ratio, cap: maxLoad)
      let mixingOutlets = SolarField.parameter.HTF.mixingOutlets
      let mixTemp = mixingOutlets(solarField, storage)
      
      let minTemp = Temperature(celsius: 310.0)
      
      if mixTemp.kelvin > minTemp.kelvin - Simulation.parameter.tempTolerance * 2
      {
        thermalPower.kiloWatt = storage.massFlow.rate * storage.heat

        parasitics = Storage.parasitics(storage)
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
    storage.massFlow(outlet: powerBlock)
    storage.massFlow -= solarField.massFlow
    
    storage.temperature.outlet = outletTemperature(storage)
    
    /// the rest is heated by SF
    var thermalPower: Power = .zero    
    var parasitics: Power = .zero

    thermalPower.kiloWatt = storage.massFlow.rate * storage.heat
    // limit the size of the salt-oil heat exchanger
    if parameter.heatExchangerRestrictedMax,
      abs(thermalPower.megaWatt) > parameter.heatExchangerCapacity
    {
      thermalPower *= parameter.heatExchangerCapacity
      
      storage.massFlow.rate = thermalPower.kiloWatt / storage.heat
      
      storage.temperature.outlet = outletTemperature(storage)
      
      thermalPower.kiloWatt = -storage.massFlow.rate * storage.heat
    }
    parasitics = Storage.parasitics(storage)

    return (thermalPower, parasitics)
  }
  
  private static func storageFreezeProtection(
    storage: inout Storage,
    solarField: inout SolarField,
    powerBlock: PowerBlock)
  {
    let antiFreeze = SolarField.parameter.antiFreezeFlow.quotient
    let maxMassFlow = SolarField.parameter.maxMassFlow.rate
    let antiFreezeFlow = MassFlow(antiFreeze * maxMassFlow) 
    let splitfactor: Ratio = 0.4
    
    storage.massFlow = antiFreezeFlow.adjusted(withFactor: splitfactor)
    
    solarField.header.massFlow = antiFreezeFlow

    storage.inletTemperature(outlet: powerBlock)
    
    var fittedTemperature = 0.0
    if Storage.parameter.temperatureCharge[1] > 0 {
      if Storage.parameter.temperatureDischarge.indices.contains(2) {
        storage.temperatureFromInlet()
      } else {
        fittedTemperature = storage.relativeCharge > 0.5
          ? 1 : Storage.parameter.temperatureCharge2(storage.relativeCharge)
        
        storage.outletTemperature(kelvin: fittedTemperature
          * Storage.parameter.designTemperature.hot.kelvin
        )
      }
      storage.outletTemperature(kelvin:
        splitfactor.quotient * storage.outlet
          + (1 - splitfactor.quotient) * storage.inlet
      )
    } else {
      storage.temperature.outlet = storage.temperatureTank.cold
    }
  }
}

extension Storage.OperationMode: CustomStringConvertible {
  public var description: String {
    switch self {
      case .noOperation: return "No operation"
      case .charge(_): return "Charging"
      case .discharge(let load): return "Discharge \(load.singleBar)"
      default: return "No description"
    }
  }
}
