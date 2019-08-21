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
/// A namespace for the main routines of the simulation.
public enum Plant {

  static var heat = ThermalEnergy()

  private(set) static var electricalEnergy = ElectricPower()

  private(set) static var fuelConsumption = FuelConsumption()

  static var electricalParasitics = Parasitics()

  static let initialState = PerformanceData()
  
  /// used for Plant.setupComponentParameters()
  static var componentsNeedUpdate = true

  static func energyBalance() -> Energy {
    electricalEnergy.net = electricalEnergy.gross
    electricalEnergy.net -= electricalEnergy.parasitics
    
    if electricalEnergy.net < 0 {
      electricalEnergy.consum = -electricalEnergy.net
      electricalEnergy.net = 0
    } else {
      electricalEnergy.consum = 0
    }
    
    return Energy(
      thermal: heat, electric: electricalEnergy,
      fuel: fuelConsumption, parasitics: electricalParasitics)
  }

  // MARK: - SolarField
  
  static func refresh(
    solarField: inout SolarField.PerformanceData,
    _ storage: Storage.PerformanceData)
  {
    if Design.hasStorage {
      switch storage.operationMode {
      case .freezeProtection:
        if Storage.parameter.temperatureCharge[1] > 0 {
          solarField.temperature.inlet = storage.temperature.outlet
        } else {
          solarField.inletTemperature(kelvin: storage.antiFreezeTemperature)
        }
      case .preheat:
        solarField.temperature.inlet = storage.temperatureTank.cold
      case .charging where Plant.heat.production.watt == 0:
        solarField.temperature.inlet = solarField.temperature.outlet
      default: break
      }
    }
 
    let parameter = SolarField.parameter,
    heatExchanger = HeatExchanger.parameter,
    steamTurbine = SteamTurbine.parameter
    
    if GridDemand.current.ratio < 1 {
      // added to reduced SOF massflow with electrical demand
      solarField.setMassFlow(rate: GridDemand.current.ratio
        * (steamTurbine.power.max / steamTurbine.efficiencyNominal
          / heatExchanger.efficiency) * 1_000 / parameter.HTF.deltaHeat(
            heatExchanger.temperature.htf.inlet.max,
            heatExchanger.temperature.htf.outlet.max)
      )
      
      solarField.massFlow.rate =
        (solarField.massFlow + storage.massFlow).rate
          .limited(by: parameter.massFlow.max.rate)
    } else {
      solarField.massFlow = parameter.massFlow.max
    }
    
    if Design.hasStorage, storage.charge.ratio >= Storage.parameter.chargeTo {
      if Design.hasGasTurbine {
        solarField.massFlow = heatExchanger.sccHTFmassFlow
      }
    }
  }
  
  static func refresh(
    solarField: inout SolarField.PerformanceData,
    _ collector: Collector.PerformanceData,
    _ ambient: Temperature)
  {
    var timeRemain = 600.0

    SolarField.calculate(
      &solarField, collector: collector, time: &timeRemain,
      dumping: &heat.dumping.watt, ambient: ambient)
    
    solarField.temperature.outlet =
      SolarField.heatLossesHotHeader(solarField, ambient: ambient)
    
    electricalParasitics.solarField = SolarField.parasitics(solarField)
  }

  // MARK: - PowerBlock

  static func refresh(
    powerBlock: inout PowerBlock.PerformanceData,
    solarField: inout SolarField.PerformanceData,
    _ collector: Collector.PerformanceData,
    storage: inout Storage.PerformanceData,
    heater: inout Heater.PerformanceData,
    heatExchanger: inout HeatExchanger.PerformanceData,
    boiler: inout Boiler.PerformanceData,
    gasTurbine: inout GasTurbine.PerformanceData,
    steamTurbine: inout SteamTurbine.PerformanceData,    
    _ ambient: Temperature)
  {
    @discardableResult func estimateElectricalEnergyDemand() -> Double {
      var estimate = 0.0
      if Design.hasGasTurbine {
        electricalEnergy.demand = GridDemand.current.ratio
          * (Design.layout.powerBlock - Design.layout.gasTurbine)
        estimate = electricalEnergy.demand
          * Simulation.parameter.electricalParasitics
        // Iter. start val. for parasitics, 10% demand
        electricalEnergy.demand += estimate
      } else {
        let steamTurbine = SteamTurbine.parameter.power.max
        electricalEnergy.demand = GridDemand.current.ratio * steamTurbine
        estimate = electricalEnergy.storage
      }
      return estimate
    }
    
    func demandStrategyStorage() -> Double {
      switch Storage.parameter.strategy {
      case .demand:
        return SteamTurbine.parameter.power.max
      case .shifter:
        return SteamTurbine.parameter.power.max * GridDemand.current.ratio
      case .always:
        return electricalEnergy.demand
      }
    }
    
    func checkAvailability(_ steamTurbine: inout SteamTurbine.PerformanceData)
      -> Double? {
      if steamTurbine.load > Availability.current.value.powerBlock {
        
        steamTurbine.load = Availability.current.value.powerBlock
        // The turbine load has changed recalculation of efficiency
        (_, steamTurbine.efficiency) = SteamTurbine.perform(
          steamTurbine.load, boiler.operationMode, gasTurbine.operationMode,
          heatExchanger.temperature.inlet, ambient)
        
        return (SteamTurbine.parameter.power.max
          * steamTurbine.load.ratio / steamTurbine.efficiency)
          .limited(by: HeatExchanger.parameter.sccHTFheat)
      }
      return nil
    }
    
    func powerBlockElectricalParasitics()
      -> (powerBlock: Double, shared: Double) {
      let energy = heat.production.megaWatt - SteamTurbine.parameter.power.max
        / steamTurbine.efficiency
      
      let powerBlock = PowerBlock.parasitics(
        heat: energy, steamTurbine: steamTurbine, temperature: ambient
      )
      
      if heat.production.watt == 0 { // added to separate shared facilities parasitics
        return (powerBlock, PowerBlock.parameter.electricalParasiticsShared[0])
      } else {
        return (powerBlock, PowerBlock.parameter.electricalParasiticsShared[1])
      }
    }

    func totalizeElectricalParasitics() {
      // + GasTurbine = total productionuced electricity
      electricalEnergy.solarField = electricalParasitics.solarField
      electricalEnergy.storage = electricalParasitics.storage
      
      // electricEnergy.parasiticsBU =
      // electricalParasitics.heater + electricalParasitics.boiler
      electricalEnergy.powerBlock = electricalParasitics.powerBlock
      electricalEnergy.shared = electricalParasitics.shared
      
      electricalEnergy.parasitics
        = electricalEnergy.solarField
        + electricalEnergy.gasTurbine
        + electricalParasitics.powerBlock
        + electricalParasitics.shared
      
      electricalEnergy.parasitics *=
        Simulation.adjustmentFactor.electricalParasitics
    }
    
    var deviation: Double
    var parasiticsAssumed = estimateElectricalEnergyDemand()
    var step = 0
    var factor = 0.0
    // Iteration to account for correct parasitics
    Iteration: repeat {
      step += 1
      factor = Double(step / 10) + 1
      estimateElectricalEnergyDemand()

      let load = (electricalEnergy.demand + Design.layout.gasTurbine)
        / SteamTurbine.parameter.power.max

      steamTurbine.load.ratio = load
      // The turbine load has changed recalculation of efficiency
      (_, steamTurbine.efficiency) = SteamTurbine.perform(
        steamTurbine.load, boiler.operationMode, gasTurbine.operationMode,
        heatExchanger.temperature.inlet, ambient)

      let demand = demandStrategyStorage()

      heat.demand.megaWatt = (demand / steamTurbine.efficiency)
        .limited(by: HeatExchanger.parameter.sccHTFheat)

      heat.demand.megaWatt =
        (checkAvailability(&steamTurbine) ?? heat.demand.megaWatt
        / Simulation.adjustmentFactor.heatLossH2O)
        / HeatExchanger.parameter.efficiency

      var heatDiff = temperaturesPowerBlock(
        solarField: &solarField,
        collector: collector,
        powerBlock: &powerBlock,
        heater: &heater,
        heatExchanger: &heatExchanger,
        steamTurbine: &steamTurbine,
        boiler: &boiler,
        gasTurbine: &gasTurbine,
        storage: &storage,
        ambient: ambient)

      heat.production = heat.heatExchanger + heat.wasteHeatRecovery
      /// Therm heat demand is lower after HX
      heat.demand.watt *= HeatExchanger.parameter.efficiency
      /// Unavoidable losses in Power Block
      heat.production.watt *= Simulation.adjustmentFactor.heatLossH2O
      
      if Design.hasBoiler { update(boiler: &boiler, &heatDiff) }

      update(steamTurbine: &steamTurbine, boiler: &boiler, heatDiff: &heatDiff,
             gasTurbine, heater, heatExchanger, ambient)
      
      electricalEnergy.gross = electricalEnergy.steamTurbineGross
      electricalEnergy.gross += electricalEnergy.gasTurbineGross
  
      let (powerBlock, shared) = powerBlockElectricalParasitics()
      electricalParasitics.powerBlock = powerBlock
      electricalParasitics.shared = shared
      totalizeElectricalParasitics()

      if case .startUp = steamTurbine.operationMode {
        heat.production = 0.0
      }

      if Design.hasBoiler {
        if case .startUp = boiler.operationMode {
          boiler.operationMode = .SI
        } else if case .noOperation = boiler.operationMode {
          boiler.operationMode = .NI
        }
      }

      deviation = abs(parasiticsAssumed - electricalEnergy.parasitics)
      parasiticsAssumed = electricalEnergy.parasitics

    } while deviation > Simulation.parameter.electricalTolerance * factor
    assert(step < 31, "Too many iterations")
  }

  static func refresh(
    storage: inout Storage.PerformanceData,
    powerBlock: inout PowerBlock.PerformanceData,
    _ steamTurbine: SteamTurbine.PerformanceData)
  {
    if Design.hasStorage {
      // Calculate the operating state of the salt
      heat.storage.megaWatt = Storage.operate(
        storage: &storage,
        powerBlock: &powerBlock,
        steamTurbine: steamTurbine,
        thermal: heat.storage.megaWatt
      )
    }
  }
  
  private static func checkForFreezeProtection(
    heater: inout Heater.PerformanceData,
    powerBlock: inout PowerBlock.PerformanceData,
    storage: Storage.PerformanceData,
    solarField: SolarField.PerformanceData,
    _ heatDiff: Double, _ fuel: Double)
  {
    if [.normal, .reheat].contains(heater.operationMode) { return }

    let freezeTemperature = SolarField.parameter.HTF.freezeTemperature

    if solarField.header.temperature.outlet <
      freezeTemperature + Simulation.parameter.dfreezeTemperatureHeat,
      storage.massFlow.isNearZero
    { // No freeze protection heater use anymore if storage is in operation
      heater.inletTemperature(inlet: powerBlock)

      heater.massFlow = powerBlock.massFlow

      heater.operationMode = .freezeProtection

      let energy = Heater.update(
        heater: &heater,
        powerBlock: powerBlock,
        storage: storage,
        solarField: solarField,
        demand: 1,
        fuelAvailable: fuel)
      fuelConsumption.heater = energy.fuel
      heat.heater.megaWatt = energy.heat
      electricalParasitics.heater = energy.electric
    }

    if case .freezeProtection = heater.operationMode {
      powerBlock.outletTemperature(outlet: heater)
    } else {
      if solarField.header.outletTemperature
        > freezeTemperature.kelvin
        + Simulation.parameter.dfreezeTemperatureHeat.kelvin
      {
        heater.operationMode = .noOperation

        let energy = Heater.update(
          heater: &heater,
          powerBlock: powerBlock,
          storage: storage,
          solarField: solarField,
          demand: heatDiff,
          fuelAvailable: fuel)
        fuelConsumption.heater = energy.fuel
        heat.heater.megaWatt = energy.heat
        electricalParasitics.heater = energy.electric
      }
    }
  }

  private static func temperatureLossPowerBlock(
    _ powerBlock: inout PowerBlock.PerformanceData,
    _ solarField: SolarField.PerformanceData,
    _ storage: Storage.PerformanceData)
  {
    if Design.hasGasTurbine {
      powerBlock.setTemperaturOutletEqualToInlet()
    } else {
      let tlpb = 0.0
// 0.38 * (TpowerBlock.status - meteo.temperature) / 100 * (30 / Design.layout.powerBlock) ** 0.5 // 0.38

      let massFlow = max(0.1,
        (solarField.massFlow + powerBlock.massFlow).rate)
      let inlet = (solarField.massFlow.rate * solarField.outletTemperature
        + powerBlock.massFlow.rate * storage.outletTemperature) / massFlow
      if inlet > 0 {
        powerBlock.inletTemperature(kelvin: inlet)
      }
      #warning("The implementation here differs from PCT")
      // FIXME: Was ist Tstatus ?????????
      let sec = Double(period)
      let outlet = (powerBlock.massFlow.rate * sec
        * powerBlock.inletTemperature + powerBlock.outletTemperature
        * (SolarField.parameter.HTFmass - powerBlock.massFlow.rate * sec))
        / SolarField.parameter.HTFmass - tlpb
      powerBlock.outletTemperature(kelvin: outlet)
      if inlet > 0 {
        powerBlock.outletTemperature(kelvin: inlet)
      }
    }
  }

  private static func temperaturesPowerBlock(
    solarField: inout SolarField.PerformanceData,
    collector: Collector.PerformanceData,
    powerBlock: inout PowerBlock.PerformanceData,
    heater: inout Heater.PerformanceData,
    heatExchanger: inout HeatExchanger.PerformanceData,
    steamTurbine: inout SteamTurbine.PerformanceData,
    boiler: inout Boiler.PerformanceData,
    gasTurbine: inout GasTurbine.PerformanceData,
    storage: inout Storage.PerformanceData,
    ambient: Temperature)
    -> Double
  {
    func operateHeatExchanger() {
      heatExchanger.massFlow = powerBlock.massFlow

      heatExchanger.setTemperature(inlet: powerBlock.temperature.inlet)

      heat.heatExchanger.megaWatt = HeatExchanger.perform(
        &heatExchanger,
        steamTurbine: steamTurbine,
        storage: storage)

      powerBlock.outletTemperature(outlet: heatExchanger)
      
      if Design.hasGasTurbine, Design.hasStorage,
        heat.heatExchanger.megaWatt > HeatExchanger.parameter.sccHTFheat
      {
        heat.dumping.megaWatt += heat.heatExchanger.megaWatt
          - HeatExchanger.parameter.sccHTFheat
        
        heat.heatExchanger.megaWatt = HeatExchanger.parameter.sccHTFheat
      }
    }

    func isHeatExchangerBypassed() -> Bool {

      if powerBlock.temperature.inlet
        < HeatExchanger.parameter.temperature.htf.inlet.min
      //  || status.powerBlock.massFlow.rate == 0
      //  || status.storage.operationMode.isFreezeProtection
      //  || status.solarField.operationMode.isFreezeProtection
      {
        if heater.operationMode.isFreezeProtection == false {
          temperatureLossPowerBlock(&powerBlock, solarField, storage)
        }
        return true
      }
      return false
    }
    
    func outletTemperature(
      powerBlock: inout PowerBlock.PerformanceData,
      heatExchanger: inout HeatExchanger.PerformanceData,
      _ storage: Storage.PerformanceData)
    {
      if powerBlock.massFlow.isNearZero == false,
        powerBlock.temperature.inlet
          >= HeatExchanger.parameter.temperature.htf.inlet.min
      {
        powerBlock.temperature.outlet = HeatExchanger
          .outletTemperature(powerBlock, heatExchanger)
        
        if case .discharge = storage.operationMode,
          powerBlock.temperature.outlet.isLower(than: 534.0)
        {
          let result = PowerBlock.heatExchangerBypass(powerBlock)
          powerBlock = result.powerBlock
          heatExchanger.heatOut = result.heatOut
          heatExchanger.heatToTES = result.heatToTES
        }
      } else {
        powerBlock.temperature.outlet = powerBlock.temperature.inlet
      }
    }
    
    powerBlock.inletTemperature(outlet: solarField)
    
    outletTemperature(
      powerBlock: &powerBlock,
      heatExchanger: &heatExchanger,
      storage)
    // Iteration: Find the right temperature for inlet and outlet of powerblock

    let fuel = Availability.fuel
    var heatDiff: Double = 0.0
    
    Iteration: while(true) {
      // Calculation of the heat supplied by the solar field
      if Design.hasSolarField {
        solarField.massFlow = update(solarField, collector, steamTurbine)
        powerBlock.massFlow = solarField.massFlow
      }

      if Design.hasStorage {
        update(
          storage: &storage,
          solarField: &solarField,
          powerBlock: &powerBlock,
          heater: &heater,
          steamTurbine: &steamTurbine,
          fuelAvailable: fuel)
      }

      if Design.hasGasTurbine {
        electricalEnergy.gasTurbineGross = GasTurbine.update(
          storage: &storage,
          powerBlock: &powerBlock,
          boiler: boiler.operationMode,
          gasTurbine: &gasTurbine,
          heatExchanger: &heatExchanger,
          steamTurbine: &steamTurbine,
          temperature: ambient, fuel: fuel)
      }

      if Design.hasHeater && !Design.hasBoiler {
        update(
          heater: &heater,
          solarField: &solarField,
          powerBlock: &powerBlock,
          gasTurbine: gasTurbine,
          steamTurbine: &steamTurbine,
          storage: &storage,
          &heatDiff, fuel)
      }
      checkForFreezeProtection(
        heater: &heater,
        powerBlock: &powerBlock,
        storage: storage,
        solarField: solarField,
        heatDiff, fuel)

      if isHeatExchangerBypassed() {
        heat.production = 0.0
        heat.heatExchanger = 0.0
        heatExchanger.massFlow = 0.0

        break Iteration
      }

      operateHeatExchanger()

      if abs(powerBlock.outletTemperature - heatExchanger.outletTemperature)
        < Simulation.parameter.tempTolerance.kelvin
      {
        break Iteration
      }

      powerBlock.outletTemperature(outlet: heatExchanger)
    }
    return heatDiff
    // FIXME: H2OinPB = H2OinHX
  }
  /// Calculation of the heat supplied by the solar field
  private static func update(
    _ solarField: SolarField.PerformanceData,
    _ collector: Collector.PerformanceData,
    _ steamTurbine: SteamTurbine.PerformanceData)
    -> MassFlow
  {
    if collector.insolationAbsorber > 0 {
      heat.solar.kiloWatt = solarField.massFlow.rate
        * SolarField.parameter.HTF.deltaHeat(solarField)
    } else {
      // added to avoid solar > 0 during some night and freeze protection time
      heat.solar = 0.0
    }
    // powerblock mass flow can change when heater is running
    if heat.solar.watt > 0 {
      if case .startUp = steamTurbine.operationMode {
        heat.production = 0.0
      } else {
        heat.production = heat.solar
      }
    } else if case .freezeProtection = solarField.operationMode {
      heat.solar = 0.0
      heat.production = 0.0
    } else {
      heat.solar = 0.0
      heat.production = 0.0
      return 0.0
    }
    return solarField.massFlow
  }

  // MARK: - SteamTurbine
  
  private static func update(
    steamTurbine: inout SteamTurbine.PerformanceData,
    boiler: inout Boiler.PerformanceData,
    heatDiff: inout Double,
    _ gasTurbine: GasTurbine.PerformanceData,
    _ heater: Heater.PerformanceData,
    _ heatExchanger: HeatExchanger.PerformanceData,
    _ ambient: Temperature)
  {
    (_, steamTurbine.efficiency) = SteamTurbine.perform(
      steamTurbine.load, boiler.operationMode, gasTurbine.operationMode,
      heatExchanger.temperature.inlet, ambient)

    let energy = heat.production.megaWatt
      - SteamTurbine.parameter.power.max / steamTurbine.efficiency
    
    let excessHeat = heat.production.megaWatt - heat.demand.megaWatt
    
    if energy > Simulation.parameter.heatTolerance { // TB.Overload
      /*  💬.infoMessage("""
       \(TimeStep.current)
       Overloading TB: \(heat) MWH,th
       """)*/
    } /*else if heatDiff > 2 * Simulation.parameter.heatTolerance {
      💬.infoMessage("""
        \(TimeStep.current)
        Production > demand: \(diff) MWH,th
        """)
    }*/

    let minLoad: Double
    if SteamTurbine.parameter.minPowerFromTemp.isInapplicable {
      #warning("The implementation here differs from PCT")
      minLoad = SteamTurbine.parameter.power.min
        / SteamTurbine.parameter.power.max
    } else {
      minLoad = SteamTurbine.parameter.minPowerFromTemp[ambient]
        / SteamTurbine.parameter.power.max
    }
    var minPower: Double
    if SteamTurbine.parameter.minPowerFromTemp.isInapplicable {
      minPower = SteamTurbine.parameter.power.min
        / SteamTurbine.parameter.efficiencyNominal
    } else {
      minPower = SteamTurbine.parameter.minPowerFromTemp[ambient]
      
      minPower = max(SteamTurbine.parameter.power.nominal * minPower,
                     SteamTurbine.parameter.power.min)
      
      (_, steamTurbine.efficiency) = SteamTurbine.perform(
        steamTurbine.load, boiler.operationMode, gasTurbine.operationMode,
        heatExchanger.temperature.inlet, ambient)

      minPower /= steamTurbine.efficiency
    }
    if heat.production.watt > 0, heat.production.megaWatt < minPower {
      heat.production = 0.0
      /*  💬.infoMessage("""
       \(TimeStep.current)
       "Damping (SteamTurbine underload): \(heat.production.megaWatt) MWH,th.
       """)*/
    }
    
    electricalEnergy.steamTurbineGross = SteamTurbine.update(
      &steamTurbine, boiler: boiler, heater: heater,
      gasTurbine: gasTurbine, heatExchanger: heatExchanger,
      heat: heat.production.megaWatt, temperature: ambient)
    
    if OperationRestriction.fuelStrategy.isPredefined {
      let steamTurbine = SteamTurbine.parameter.power.max
      if fuelConsumption.combined > 0 && electricalEnergy.steamTurbineGross
        > steamTurbine + 1 {
        electricalEnergy.steamTurbineGross = steamTurbine + 1
      }
      if fuelConsumption.combined > 0, heat.solar.watt > 0,
        electricalEnergy.steamTurbineGross > steamTurbine - 1
      {
        electricalEnergy.steamTurbineGross = steamTurbine - 1
      }
    }
    
    if Design.hasStorage {
      if case .always = Storage.parameter.strategy {} // new restriction of production
      else if electricalEnergy.steamTurbineGross > electricalEnergy.demand {
        heat.dumping.megaWatt = electricalEnergy.steamTurbineGross
          - electricalEnergy.demand
        electricalEnergy.steamTurbineGross = electricalEnergy.demand
      }
    } else { /* if Heater.parameter.operationMode */ // following uncomment for Shams-1.
      if electricalEnergy.steamTurbineGross > electricalEnergy.demand
      {
        adjustLoadSteamTurbine(
          steamTurbine: &steamTurbine,
          boiler: &boiler,
          heater: heater,
          gasTurbine: gasTurbine,
          heatExchanger: heatExchanger,
          heatDiff: &heatDiff,
          ambient: ambient)
      }
    }
  }

  private static func adjustLoadSteamTurbine(
    steamTurbine: inout SteamTurbine.PerformanceData,
    boiler: inout Boiler.PerformanceData,
    heater: Heater.PerformanceData,
    gasTurbine: GasTurbine.PerformanceData,
    heatExchanger: HeatExchanger.PerformanceData,
    heatDiff: inout Double,
    ambient: Temperature)
  {
    let electricEnergyFactor = electricalEnergy.demand
      / electricalEnergy.steamTurbineGross
    
    heat.dumping.megaWatt = electricalEnergy.steamTurbineGross
      - electricalEnergy.demand * electricEnergyFactor
    
    // reduction necessary for every project without storage
    heat.solar.watt *= electricEnergyFactor
    heat.heatExchanger.watt *= electricEnergyFactor
    
    heatDiff *= electricEnergyFactor
    var Qsf_load = 0.0
    Qsf_load *= electricEnergyFactor
    
    let fuel = Availability.fuel
    
    let energy = Boiler.update(
      &boiler, demand: heatDiff, Qsf_load: Qsf_load, fuelAvailable: fuel
    )
    heat.boiler.megaWatt = energy.heat
    fuelConsumption.boiler = energy.fuel
    electricalParasitics.boiler = energy.electric
    
    electricalEnergy.steamTurbineGross = SteamTurbine.update(
      &steamTurbine, boiler: boiler, heater: heater,
      gasTurbine: gasTurbine, heatExchanger: heatExchanger,
      heat: heat.production.megaWatt, temperature: ambient)
  }
  
  // MARK: - Storage
  
  private static func update(
    storage: inout Storage.PerformanceData,
    solarField: inout SolarField.PerformanceData,
    powerBlock: inout PowerBlock.PerformanceData,
    heater: inout Heater.PerformanceData,
    steamTurbine: inout SteamTurbine.PerformanceData,
    fuelAvailable fuel: Double)
  {
    // Demand for operation of the storage and adjustment of the powerblock mass flow
    Storage.demandStrategy(
      storage: &storage,
      powerBlock: &powerBlock,
      solarField: solarField)
    
    let energy = Storage.update(
      storage: &storage,
      solarField: &solarField,
      steamTurbine: &steamTurbine,
      powerBlock: &powerBlock,
      heater: &heater,
      demand: heat.demand.megaWatt,
      fuelAvailable: fuel
    )
    heat.storage.megaWatt = energy.heat
    fuelConsumption.heater = energy.fuel
    electricalParasitics.storage = energy.electric

    var thermal = storage.massFlow.rate
      * SolarField.parameter.HTF.deltaHeat(storage) / 1_000
    
    let (thermalPower, salt) = Storage.calculate(thermal, storage: storage)
    storage.salt = salt
    heat.storage.megaWatt = thermalPower

    if storage.heat > 0 { // Energy surplus
      if storage.charge.ratio < Storage.parameter.chargeTo,
        solarField.massFlow >= powerBlock.massFlow
      { // 1.1
        heat.production = heat.solar
        heat.production += heat.storage
      } else { // heat cannot be stored
        heat.production = heat.solar
        heat.production.megaWatt -= storage.heat
      }
    } else { // Energy deficit
      heat.production = heat.solar
      heat.production += heat.storage
    }
  }

  // MARK: - Heater
  
  private static func heating(
    storage: inout Storage.PerformanceData,
    solarField: inout SolarField.PerformanceData,
    powerBlock: inout PowerBlock.PerformanceData,
    heater: inout Heater.PerformanceData,
    steamTurbine: inout SteamTurbine.PerformanceData,
    heatDiff: inout Double,
    fuel: Double)
  {
    if heatDiff < 0,
      storage.charge.ratio < Storage.parameter.dischargeToTurbine,
      storage.charge.ratio > Storage.parameter.dischargeToHeater
    {
      // Direct Discharging to SteamTurbine
      var supply, parasitics: Double
      if fuel > 0 { // Fuel available, Storage for Pre-Heating

        (supply, parasitics) = Storage.perform(
          storage: &storage,
          solarField: &solarField,
          steamTurbine: &steamTurbine,
          powerBlock: &powerBlock,
          mode: .preheat)

        heater.inletTemperature(outlet: storage)

        heater.operationMode = .unknown

        heatDiff = heat.production.megaWatt
          + heat.storage.megaWatt - heat.demand.megaWatt

        heating(
          solarField: solarField,
          heater: &heater,
          powerBlock: &powerBlock,
          storage: storage,
          heatdiff: heatDiff,
          fuel: fuel)
        
        heater.massFlow = storage.massFlow
      } else {  // No Fuel Available -> Discharge directly with reduced TB load

        (supply, parasitics) = Storage.perform(
          storage: &storage,
          solarField: &solarField,
          steamTurbine: &steamTurbine,
          powerBlock: &powerBlock,
          mode: .discharge)

        let htf = SolarField.parameter.HTF

        powerBlock.temperature.inlet =
          htf.mixingTemperature(solarField, storage)

        powerBlock.massFlow = solarField.massFlow
        powerBlock.massFlow += storage.massFlow
      } // STORAGE: dischargeToHeater < Qrel < dischargeToTurbine; Fuel/NoFuel

      heat.storage.megaWatt = supply

      electricalParasitics.storage = parasitics

    } else if heatDiff < 0,
      storage.charge.ratio < Storage.parameter.dischargeToHeater,
      heater.operationMode != .freezeProtection
    {
      heatDiff = (heat.production + heat.wasteHeatRecovery).megaWatt
        / HeatExchanger.parameter.efficiency
        - GridDemand.current.ratio * heat.demand.megaWatt
      // added to avoid heater use is storage is selected and checkbox marked:
      if heat.production.watt == 0, Heater.parameter.onlyWithSolarField {
        // use heater only in parallel with solar field and not as stand alone.
        // heatdiff = 0
        // commented to use gas not only in parallel to SF (for AH1)
        heatDiff = 0
      }

      heater.inletTemperature(outlet: powerBlock)
      heating(
        solarField: solarField,
        heater: &heater,
        powerBlock: &powerBlock,
        storage: storage,
        heatdiff: heatDiff,
        fuel: fuel)
    }
  }

  private static func heating(
    solarField: SolarField.PerformanceData,
    heater: inout Heater.PerformanceData,
    powerBlock: inout PowerBlock.PerformanceData,
    storage: Storage.PerformanceData,
    heatdiff: Double,
    fuel: Double)
  {
    let energy = Heater.update(
      heater: &heater, powerBlock: powerBlock,
      storage: storage, solarField: solarField,
      demand: heatdiff, fuelAvailable: fuel)
    fuelConsumption.heater = energy.fuel
    heat.heater.megaWatt = energy.heat
    electricalParasitics.heater = energy.electric

    let htf = SolarField.parameter.HTF

    powerBlock.temperature.inlet = htf.mixingTemperature(solarField, heater)

    powerBlock.massFlow = solarField.massFlow
    powerBlock.massFlow += heater.massFlow
  }

  private static func heating(
    powerBlock: inout PowerBlock.PerformanceData,
    heater: inout Heater.PerformanceData,
    storage: Storage.PerformanceData,
    solarField: SolarField.PerformanceData,
    heatdiff: Double,
    fuel: Double)
  {
    let energy = Heater.update(
      heater: &heater,
      powerBlock: powerBlock,
      storage: storage,
      solarField: solarField,
      demand: heatdiff,
      fuelAvailable: fuel)
    fuelConsumption.heater = energy.fuel
    heat.heater.megaWatt = energy.heat
    electricalParasitics.heater = energy.electric

    let htf = SolarField.parameter.HTF

    powerBlock.temperature.inlet =
      htf.mixingTemperature(inlet: powerBlock, with: heater)

    powerBlock.massFlow += heater.massFlow
  }

  private static func update(
    heater: inout Heater.PerformanceData,
    solarField: inout SolarField.PerformanceData,
    powerBlock: inout PowerBlock.PerformanceData,
    gasTurbine: GasTurbine.PerformanceData,
    steamTurbine: inout SteamTurbine.PerformanceData,
    storage: inout Storage.PerformanceData,
    _ heatDiff: inout Double,
    _ fuel: Double)
  {
    // restart variable to avoid errors due to Boiler.  added for Shams-1
    if case .pure = gasTurbine.operationMode {
      // Plant updates in Pure CC Mode now again without RH!!
      // demand * WasteHeatRecovery.parameter.effPure * (1 / gasTurbine.efficiency- 1))
      // heat supplied by the WHR system
      
    } else if case .integrated = gasTurbine.operationMode {
      // Plant does not update in Pure CC Mode
      let energy = electricalEnergy.gasTurbineGross * (1
        / GasTurbine.efficiency(at: gasTurbine.load) - 1)
        * WasteHeatRecovery.parameter.efficiencyNominal
        / WasteHeatRecovery.parameter.ratioHTF
      /// necessary HTF share
      heatDiff = heat.production.megaWatt - energy
      
      heater.inletTemperature(outlet: powerBlock)

      heating(
        powerBlock: &powerBlock,
        heater: &heater,
        storage: storage,
        solarField: solarField,
        heatdiff: heatDiff,
        fuel: fuel)
    } else if case .noOperation = gasTurbine.operationMode {
      // GasTurbine does not update at all (Load<Min?)
      heating(
        solarField: solarField,
        heater: &heater,
        powerBlock: &powerBlock,
        storage: storage,
        heatdiff: heatDiff,
        fuel: fuel)
    }

    if Design.hasStorage {
      heating(
        storage: &storage,
        solarField: &solarField,
        powerBlock: &powerBlock,
        heater: &heater,
        steamTurbine: &steamTurbine,
        heatDiff: &heatDiff,
        fuel: fuel)
    } else {
      heatDiff = (heat.production + heat.wasteHeatRecovery).megaWatt
        / HeatExchanger.parameter.efficiency - heat.demand.megaWatt

      if heat.production.watt == 0 {
        // use heater only in parallel with solar field and not as stand alone.
        if Heater.parameter.onlyWithSolarField { heatDiff = 0 }
      }

      heater.inletTemperature(outlet: powerBlock)
      heating(
        solarField: solarField,
        heater: &heater,
        powerBlock: &powerBlock,
        storage: storage,
        heatdiff: heatDiff,
        fuel: fuel)
    }
    
    if heater.massFlow.isNearZero == false {
      heat.production.kiloWatt = powerBlock.massFlow.rate
        * SolarField.parameter.HTF.deltaHeat(powerBlock)
    }
  }

  // MARK: - Boiler
  
  private static func update(
    boiler: inout Boiler.PerformanceData, _ heatDiff: inout Double)
  {
    var Qsf_load: Double

    let adjustmentFactor = Simulation.adjustmentFactor

    let efficiency = SteamTurbine.parameter.efficiencyNominal

    if case .solarOnly = Control.whichOptimization {
      if heat.production.megaWatt < adjustmentFactor.efficiencyHeater,
        heat.production.megaWatt >= adjustmentFactor.efficiencyBoiler
      {
        switch boiler.operationMode {
        case .startUp, .SI, .NI:
          break
        default:
          boiler.operationMode = .unknown
        }

        heatDiff = heat.production.megaWatt - heat.demand.megaWatt
        if Boiler.parameter.booster { // booster superheater
          if heat.heater.megaWatt == Design.layout.heater {
            // Firm Output case
            // for shams-1 769% of the boiler load is used during firm output.
            // no time to find a nice formula. sorry!
            Qsf_load = 0.769
          } else {
            Qsf_load = heat.production.megaWatt
              / (Design.layout.heatExchanger / efficiency)
          }
        }
        // H2OinBO.temperature.inlet = H2OinPB.temperature.outlet
      } else {
        boiler.operationMode = .noOperation(hours: 0)
      }
    }

    if heat.heater.megaWatt == Design.layout.heater { // Firm Output case
      // for shams-1 769% of the boiler load is used during firm output.
      // no time to find a nice formula. sorry!
      Qsf_load = 0.769
    } else {
      Qsf_load = heat.production.megaWatt /
        (Design.layout.heatExchanger / efficiency)
    }

    let energy = Boiler.update(
      &boiler, demand: heatDiff, Qsf_load: Qsf_load, fuelAvailable: 0
    )
    heat.boiler.megaWatt = energy.heat
    fuelConsumption.boiler = energy.fuel
    electricalParasitics.boiler = energy.electric
    
    // predefined fuel consumption in *.pfc-file
    if OperationRestriction.fuelStrategy.isPredefined {
      if (heat.heatExchanger.megaWatt + heat.boiler.megaWatt) > 110 {
        heat.boiler.megaWatt = 105 - heat.heatExchanger.megaWatt
      }

      heat.production = (heat.heatExchanger + heat.wasteHeatRecovery)
        * adjustmentFactor.heatLossH2O + heat.boiler
    }
  }
}
/* FIXME: Not used
private static func foo(_ status: inout PerformanceData) {
  
   let storage = Storage.parameter
   storage.mass.hot = heatExchanger.temperature.h2o.inlet.max
   storage.mass.cold = heatExchanger.temperature.h2o.inlet.min
   status.storage.salt.massFlow.cold.rate = storage.startLoad.cold
   status.storage.salt.massFlow.hot.rate = storage.startLoad.hot
   storage.temperatureTank.hot = heatExchanger.temperature.h2o.outlet.max
   storage.temperatureTank.cold = heatExchanger.temperature.h2o.outlet.max
   
   // Average HTF temp. in loop [K]
   let solarField = SolarField.parameter
   let x = (1 - solarField.SSFHL / solarField.pipeHeatLosses)
   * SolarField.pipeHeatLoss(
   pipe: status.solarField.header.averageTemperature,
   ambient: ambientTemperature
   ) * status.solarField.area
   
   thermal.solar.watt += x
   // H2OinHX.temperature.inlet = H2OinPB.temperature.outlet
}
*/
