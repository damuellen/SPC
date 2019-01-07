//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Config
import DateGenerator
import Foundation
import Meteo
import SolarPosition

public enum Plant {

  private(set) static var location: Position = .primeMeridian

  private(set) static var ambientTemperature = Temperature()

  static var heat = ThermalEnergy()

  private(set) static var electricalEnergy = ElectricPower()

  private(set) static var fuelConsumption = FuelConsumption()

  static var electricalParasitics = Parasitics()

  private static let initialState = PerformanceData()

  private static var componentsNeedUpdate = true

  static func initializeComponents() {
    guard componentsNeedUpdate else { return }
    componentsNeedUpdate = false
    let steamTurbine = SteamTurbine.parameter
    let powerBlock = PowerBlock.parameter

    if steamTurbine.power.max == 0 {
      SteamTurbine.parameter.power.max = Design.layout.powerBlock
        + powerBlock.fixelectricalParasitics
        + powerBlock.nominalElectricalParasitics
        + powerBlock.electricalParasiticsStep[1]
    }

    let solarField = SolarField.parameter

    if Design.hasGasTurbine {

      HeatExchanger.parameter.sccHTFheat = Design.layout.heatExchanger
        / steamTurbine.efficiencySCC / HeatExchanger.parameter.sccEff

      let designHeatExchanger = solarField.HTF.deltaHeat(
        HeatExchanger.parameter.scc.htf.outlet.max,
        HeatExchanger.parameter.scc.htf.inlet.max
      )

      let heatExchanger = HeatExchanger.parameter
      SolarField.parameter.massFlow.max = MassFlow(
        heatExchanger.sccHTFheat * 1_000 / designHeatExchanger
      )

      WasteHeatRecovery.parameter.ratioHTF = heatExchanger.sccHTFheat
        / (steamTurbine.power.max - heatExchanger.sccHTFheat)

    } else {

      if Design.layout.heatExchanger != Design.layout.powerBlock {

        HeatExchanger.parameter.sccHTFheat = Design.layout.heatExchanger
          / steamTurbine.efficiencyNominal
          / HeatExchanger.parameter.efficiency

      } else {

        HeatExchanger.parameter.sccHTFheat = steamTurbine.power.max
          / steamTurbine.efficiencyNominal
          / HeatExchanger.parameter.efficiency
      }

      let designHeatExchanger = solarField.HTF.deltaHeat(
        HeatExchanger.parameter.temperature.htf.inlet.max,
        HeatExchanger.parameter.temperature.htf.outlet.max
      )

      SolarField.parameter.massFlow.max = MassFlow(
        HeatExchanger.parameter.sccHTFheat * 1_000 / designHeatExchanger
      )
    }

    if Design.hasSolarField {
      let numberOfSCAsInRow = Double(solarField.numberOfSCAsInRow)
      let edgeFactor1 = solarField.distanceSCA / 2
        * (1 - 1 / numberOfSCAsInRow)
        / Collector.parameter.lengthSCA
      let edgeFactor2 = (1 + 1 / numberOfSCAsInRow)
        / Collector.parameter.lengthSCA / 2
      SolarField.parameter.edgeFactor = [edgeFactor1, edgeFactor2]
    }
  }

  static func setLocation(_ location: Position) {
    self.location = location
  }

  static func reset() {
    heat.reset()
    fuelConsumption.reset()
    electricalParasitics.reset()
    electricalEnergy.reset()
  }

  static func run(
    progress: Progress,
    dates: DateGenerator,
    meteoData: MeteoDataGenerator,
    sun: SolarPosition)
  {
    var status = initialState
    SolarField.last = SolarField.initialState.loops
    SolarField.lastDNI = 0.0

    for (meteo, date) in zip(meteoData, dates) {

      TimeStep.setCurrent(date: date)

      // if Maintenance.checkSchedule(date) { continue }

      progress.tracking(month: TimeStep.current.month)

      dniDay = meteoData.sumDNI(ofDay: TimeStep.current.day)

      ambientTemperature = Temperature(celsius: meteo.temperature)

      if let position = sun[date] {
        status.collector = Collector.tracking(sun: position)
        Collector.efficiency(&status.collector, meteo: meteo)
      } else {
        TimeStep.current.isDayTime = false
      }

      updateSolarField(&status, meteo: meteo)
      if TimeStep.current.hour == 16, TimeStep.current.minute == 56,
        TimeStep.current.day == 27 {
      
      }
      updatePowerBlock(&status)

      netElectricalEnergy()
      
      record(status: status, meteo: meteo, date: date)
      
      reset()
    }
  }

  private static func record(    
    status: PerformanceData,
    meteo: MeteoData,
    date: DateGenerator.Element)
  {
    guard let logger = BlackBoxModel.logger else { return }
    backgroundQueue.async {
      [electricalEnergy, electricalParasitics, heat, fuelConsumption] in

      logger.append(
        date: date, meteo: meteo, status: status,
        electricalEnergy: electricalEnergy,
        electricalParasitics: electricalParasitics,
        thermalEnergy: heat,
        fuelConsumption: fuelConsumption
      )
    }
  }

  private static func netElectricalEnergy() {
    
    electricalEnergy.net = electricalEnergy.gross - electricalEnergy.parasitics
    
    if electricalEnergy.net < 0 {
      electricalEnergy.consum = -electricalEnergy.net
      electricalEnergy.net = 0
    } else {
      electricalEnergy.consum = 0
    }
  }

  private static func updateSolarField(
    _ status: inout PerformanceData, meteo: MeteoData)
  {
    var timeRemain = 600.0
    var dumping = heat.dumping.watt
    status.solarField = SolarField.update(
      status, timeRemain: &timeRemain, dumping: &dumping, meteo: meteo
    )
    heat.dumping.watt = dumping
    electricalParasitics.solarField = SolarField.parasitics(status.solarField)
  }

  private static func updatePowerBlock(_ status: inout PerformanceData) {

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
    
    func availabilityCheckSteamTurbine() -> SteamTurbine.PerformanceData {
      var steamTurbine = status.steamTurbine
      if steamTurbine.load > Availability.current.value.powerBlock {
        
        steamTurbine.load = Availability.current.value.powerBlock
        
        (_, steamTurbine.efficiency) = SteamTurbine.perform(
          steamTurbine: steamTurbine, boiler: status.boiler,
          gasTurbine: status.gasTurbine, heatExchanger: status.heatExchanger
        )
        
        heat.demand.megaWatt = (SteamTurbine.parameter.power.max
          * steamTurbine.load.ratio / steamTurbine.efficiency)
          .limited(by: HeatExchanger.parameter.sccHTFheat)
      }
      return steamTurbine
    }
    
    func electricalParasiticsPowerBlock() {
      let energy = heat.production.megaWatt - SteamTurbine.parameter.power.max
        / status.steamTurbine.efficiency
      
      electricalParasitics.powerBlock = PowerBlock.parasitics(
        heat: energy, steamTurbine: status.steamTurbine
      )
      
      if heat.production.watt == 0 {
        // added to separate shared facilities parasitics
        electricalParasitics.shared =
          PowerBlock.parameter.electricalParasiticsShared[0]
      } else {
        electricalParasitics.shared =
          PowerBlock.parameter.electricalParasiticsShared[1]
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

      status.steamTurbine.load.ratio =
        (electricalEnergy.demand + Design.layout.gasTurbine)
        / SteamTurbine.parameter.power.max

      (_, status.steamTurbine.efficiency) = SteamTurbine.perform(
        steamTurbine: status.steamTurbine, boiler: status.boiler,
        gasTurbine: status.gasTurbine, heatExchanger: status.heatExchanger
      )

      let demand = demandStrategyStorage()

      heat.demand.megaWatt = (demand / status.steamTurbine.efficiency)
        .limited(by: HeatExchanger.parameter.sccHTFheat)

      status.steamTurbine = availabilityCheckSteamTurbine()

      heat.demand.megaWatt = (heat.demand.megaWatt
        / Simulation.adjustmentFactor.heatLossH2O)
        / HeatExchanger.parameter.efficiency

      var heatDiff: Double = 0.0
      temperaturesPowerBlock(&status, &heatDiff)

      heat.production = heat.heatExchanger + heat.wasteHeatRecovery
      /// Therm heat demand is lower after HX
      heat.demand.watt *= HeatExchanger.parameter.efficiency
      /// Unavoidable losses in Power Block
      heat.production.watt *= Simulation.adjustmentFactor.heatLossH2O
      
      if Design.hasBoiler { updateBoiler(&status.boiler, &heatDiff) }

      updateSteamTurbine(&status, &heatDiff)
      
      electricalEnergy.gross = electricalEnergy.steamTurbineGross
      electricalEnergy.gross += electricalEnergy.gasTurbineGross

      electricalParasiticsPowerBlock()

      totalizeElectricalParasitics()

      if case .startUp = status.steamTurbine.operationMode {
        heat.production = 0.0
      }

      if Design.hasBoiler {
        if case .startUp = status.boiler.operationMode {
          status.boiler.operationMode = .SI
        } else if case .noOperation = status.boiler.operationMode {
          status.boiler.operationMode = .NI
        }
      }

      deviation = abs(parasiticsAssumed - electricalEnergy.parasitics)
      parasiticsAssumed = electricalEnergy.parasitics

    } while deviation > Simulation.parameter.electricalTolerance * factor
    assert(step < 31, "Too many iterations")
    
    if Design.hasStorage {
      heat.storage.megaWatt = Storage.operate(
        storage: &status.storage, powerBlock: &status.powerBlock,
        steamTurbine: status.steamTurbine, thermal: heat.storage.megaWatt
      )
    }
  }

  private static func checkForFreezeProtection(
    _ status: inout PerformanceData, _ heatDiff: Double, _ fuel: Double)
  {
    if [.normal, .reheat].contains(status.heater.operationMode) { return }

    let solarField = SolarField.parameter

    let freezeTemperature = solarField.HTF.freezeTemperature

    if status.solarField.header.temperature.outlet <
      freezeTemperature + Simulation.parameter.dfreezeTemperatureHeat,
      status.storage.massFlow.isNearZero
    { // No freeze protection heater use anymore if storage is in operation
      status.heater.temperature.inlet = status.powerBlock.temperature.inlet

      status.heater.massFlow = status.powerBlock.massFlow

      status.heater.operationMode = .freezeProtection

      Heater.update(status, demand: 1, fuelAvailable: fuel)
      { result in
        status.heater = result.status
        heat.heater.megaWatt = result.supply
        electricalParasitics.heater = result.parasitics
        fuelConsumption.heater = result.fuel
      }
    }

    if case .freezeProtection = status.heater.operationMode {
      status.powerBlock.setTemperature(outlet:
        status.heater.temperature.outlet
      )
    } else {
      if status.solarField.header.outletTemperature
        > freezeTemperature.kelvin
        + Simulation.parameter.dfreezeTemperatureHeat.kelvin
      {
        status.heater.operationMode = .noOperation

        Heater.update(status, demand: heatDiff, fuelAvailable: fuel)
        { result in
          status.heater = result.status
          heat.heater.megaWatt = result.supply
          electricalParasitics.heater = result.parasitics
          fuelConsumption.heater = result.fuel
        }
      }
    }
  }

  private static func temperatureLossPowerBlock(
    _ status: inout PerformanceData)
  {
    if Design.hasGasTurbine {
      status.powerBlock.setTemperaturOutletEqualToInlet()
    } else {
      let tlpb = 0.0
// 0.38 * (TpowerBlock.status - meteo.temperature) / 100 * (30 / Design.layout.powerBlock) ** 0.5 // 0.38

      let massFlow = max(0.1,
        (status.solarField.massFlow + status.powerBlock.massFlow).rate)

      status.powerBlock.inletTemperature(kelvin:
        (status.solarField.massFlow.rate
          * status.solarField.outletTemperature
          + status.powerBlock.massFlow.rate
          * status.storage.outletTemperature) / massFlow
      )
      #warning("The implementation here differs from PCT")
      // FIXME: Was ist Tstatus ?????????

      status.powerBlock.outletTemperature(kelvin:
        (status.powerBlock.massFlow.rate
          * Double(period) * status.powerBlock.inletTemperature
          + status.powerBlock.outletTemperature
          * (SolarField.parameter.HTFmass
            - status.powerBlock.massFlow.rate * Double(period)))
          / SolarField.parameter.HTFmass - tlpb
      )
    }
  }

  private static func temperaturesPowerBlock(
    _ status: inout PerformanceData, _ heatDiff: inout Double)
  {
    func operateHeatExchanger() {
      status.heatExchanger.massFlow = status.powerBlock.massFlow

      status.heatExchanger.setTemperature(inlet:
        status.powerBlock.temperature.inlet
      )

      heat.heatExchanger.megaWatt = HeatExchanger.perform(
        &status.heatExchanger,
        steamTurbine: status.steamTurbine,
        storage: status.storage
      )

      status.powerBlock.setTemperature(outlet:
        status.heatExchanger.temperature.outlet
      )
      
      if Design.hasGasTurbine, Design.hasStorage,
        heat.heatExchanger.megaWatt > HeatExchanger.parameter.sccHTFheat
      {
        heat.dumping.megaWatt += heat.heatExchanger.megaWatt
          - HeatExchanger.parameter.sccHTFheat
        
        heat.heatExchanger.megaWatt = HeatExchanger.parameter.sccHTFheat
      }
    }

    func bypassHeatExchanger() -> Bool {

      if status.powerBlock.temperature.inlet
        < HeatExchanger.parameter.temperature.htf.inlet.min
      //  || status.powerBlock.massFlow.rate == 0
        || status.storage.operationMode.isFreezeProtection
        || status.solarField.operationMode.isFreezeProtection
      {
        if status.heater.operationMode.isFreezeProtection == false {
          temperatureLossPowerBlock(&status)
        }
        return true
      }
      return false
    }
    
    func outletTemperature(
      _ heatExchanger: inout HeatExchanger.PerformanceData,
      _ powerBlock: inout PowerBlock.PerformanceData,
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
      }
    }
    
    status.powerBlock.temperature.inlet = status.solarField.temperature.outlet
    
    outletTemperature(&status.heatExchanger, &status.powerBlock, status.storage)
    // Iteration: Find the right temperature for inlet and outlet of powerblock

    Iteration: while(true) {

      if Design.hasSolarField { updateSolarField(&status) }

      let fuel = Availability.fuel

      if Design.hasStorage { updateStorage(&status, fuel) }

      if Design.hasGasTurbine {
        electricalEnergy.gasTurbineGross = GasTurbine.update(&status, fuel: fuel)
      }

      guard Design.hasHeater && !Design.hasBoiler else { return }

      updateHeater(&status, electricalEnergy.gasTurbineGross, &heatDiff, fuel)

      checkForFreezeProtection(&status, heatDiff, fuel)

      if bypassHeatExchanger() {
        heat.production = 0.0
        heat.heatExchanger = 0.0
        status.heatExchanger.massFlow = 0.0

        break Iteration
      }

      operateHeatExchanger()

      if abs(status.powerBlock.outletTemperature
        - status.heatExchanger.outletTemperature)
        < Simulation.parameter.tempTolerance.kelvin
      {
        break Iteration
      }

      status.powerBlock.setTemperature(outlet:
        status.heatExchanger.temperature.outlet
      )
    }
    // FIXME: H2OinPB = H2OinHX
  }

  private static func updateSolarField(_ status: inout PerformanceData) {
    if status.solarField.insolationAbsorber > 0 {

      heat.solar.kiloWatt = status.solarField.massFlow.rate *
        SolarField.parameter.HTF.deltaHeat(
          status.solarField.temperature.outlet,
          status.solarField.temperature.inlet)
    } else {
      // added to avoid solar > 0 during some night and freeze protection time
      heat.solar = 0.0
    }

    status.powerBlock.massFlow = status.solarField.header.massFlow

    if heat.solar.watt > 0 {
      if case .startUp = status.steamTurbine.operationMode {
        heat.production = 0.0
      } else {
        heat.production = heat.solar
      }
    } else if case .freezeProtection = status.solarField.operationMode {
      heat.solar = 0.0
      heat.production = 0.0
    } else {
      heat.solar = 0.0
      heat.production = 0.0
      status.powerBlock.massFlow = 0.0
      status.solarField.header.massFlow = 0.0
    }
  }

  private static func updateSteamTurbine(
    _ status: inout Plant.PerformanceData, _ heatDiff: inout Double)
  {
    (_, status.steamTurbine.efficiency) = SteamTurbine.perform(
      steamTurbine: status.steamTurbine, boiler: status.boiler,
      gasTurbine: status.gasTurbine, heatExchanger: status.heatExchanger
    )
    
    let efficiency = status.steamTurbine.efficiency
    
    let energy = heat.production.megaWatt
      - SteamTurbine.parameter.power.max / efficiency
    
    let diff = heat.production.megaWatt - heat.demand.megaWatt
    
    if energy > Simulation.parameter.heatTolerance { // TB.Overload
      /*  💬.infoMessage("""
       \(TimeStep.current)
       Overloading TB: \(heat) MWH,th
       """)*/
    } else if heatDiff > 2 * Simulation.parameter.heatTolerance {
      💬.infoMessage("""
        \(TimeStep.current)
        Production > demand: \(diff) MWH,th
        """)
    }
    
    let steamTurbine = SteamTurbine.parameter
    
    let minLoad: Double
    if steamTurbine.minPowerFromTemp.isInapplicable {
      #warning("The implementation here differs from PCT")
      minLoad = steamTurbine.power.min / steamTurbine.power.max
    } else {
      minLoad = steamTurbine.minPowerFromTemp[ambientTemperature]
        / steamTurbine.power.max
    }
    var minPower: Double
    if steamTurbine.minPowerFromTemp.isInapplicable {
      minPower = steamTurbine.power.min / steamTurbine.efficiencyNominal
    } else {
      minPower = steamTurbine.minPowerFromTemp[ambientTemperature]
      
      minPower = max(steamTurbine.power.nominal * minPower,
                     steamTurbine.power.min)
      
      (_, status.steamTurbine.efficiency) = SteamTurbine.perform(
        steamTurbine: status.steamTurbine, boiler: status.boiler,
        gasTurbine: status.gasTurbine, heatExchanger: status.heatExchanger
      )
      
      let efficiency = status.steamTurbine.efficiency
      minPower /= efficiency
    }
    if heat.production.watt > 0, heat.production.megaWatt < minPower {
      heat.production = 0.0
      /*  💬.infoMessage("""
       \(TimeStep.current)
       "Damping (SteamTurbine underload): \(heat.production.megaWatt) MWH,th.
       """)*/
    }
    
    SteamTurbine.update(status, heat: heat.production.megaWatt)
    { result in
      status.steamTurbine = result.status
      electricalEnergy.steamTurbineGross = result.gross
    }
    
    if Fuelmode.isPredefined {
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
      if electricalEnergy.steamTurbineGross > electricalEnergy.demand {
        
        adjustLoadSteamTurbine(&status, &heatDiff)
      }
    }
  }

  private static func adjustLoadSteamTurbine(
    _ status: inout PerformanceData,
    _ heatDiff: inout Double)
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
    
    Boiler.update(
      status.boiler, heatFlow: heatDiff,
      Qsf_load: Qsf_load, fuelAvailable: Availability.fuel
    ) { result in
      status.boiler = result.status
      heat.boiler.megaWatt = result.supply
      fuelConsumption.boiler = result.fuel
      electricalParasitics.boiler = result.parasitics
    }
    
    SteamTurbine.update(status, heat: heat.production.megaWatt)
    { result in
      status.steamTurbine = result.status
      electricalEnergy.steamTurbineGross = result.gross
    }
  }
  
  private static func updateStorage(
    _ status: inout PerformanceData, _ fuel: Double)
  {
    Storage.update(&status, demand: heat.demand.megaWatt, fuelAvailable: fuel)
    { result in
      heat.storage.megaWatt = result.supply
      heat.demand.megaWatt = result.demand
      fuelConsumption.heater = result.fuel
      electricalParasitics.storage = result.parasitics
    }

    let (thermalPower, sto) = Storage.calculate(status.storage)
    status.storage = sto
    heat.storage.megaWatt = thermalPower

    if status.storage.heat > 0 { // Energy surplus
      if status.storage.charge.ratio < Storage.parameter.chargeTo,
        status.solarField.massFlow >= status.powerBlock.massFlow
      { // 1.1
        heat.production = heat.solar
        heat.production += heat.storage
      } else { // heat cannot be stored
        heat.production = heat.solar
        heat.production.megaWatt -= status.storage.heat
      }
    } else { // Energy deficit
      heat.production = heat.solar
      heat.production += heat.storage
    }
  }

  private static func heatingStorage(
    _ status: inout PerformanceData,
    _ heatDiff: inout Double,
    _ fuel: Double)
  {
    if heatDiff < 0,
      status.storage.charge.ratio < Storage.parameter.dischargeToTurbine,
      status.storage.charge.ratio > Storage.parameter.dischargeToHeater
    {
      // Direct Discharging to SteamTurbine
      var supply, parasitics: Double
      if fuel > 0 { // Fuel available, Storage for Pre-Heating

        (supply, parasitics) = Storage.perform(&status, mode: .preheat)

        status.heater.temperature.inlet = status.storage.temperature.outlet

        status.heater.operationMode = .unknown

        heatDiff = heat.production.megaWatt
          + heat.storage.megaWatt - heat.demand.megaWatt

        heatingSolarField(&status, heatDiff, fuel)

        status.heater.massFlow = status.storage.massFlow
      } else {  // No Fuel Available -> Discharge directly with reduced TB load

        (supply, parasitics) = Storage.perform(&status, mode: .discharge)

        let htf = SolarField.parameter.HTF

        status.powerBlock.temperature.inlet = htf.mixingTemperature(
          outlet: status.solarField, with: status.storage
        )

        status.powerBlock.massFlow = status.storage.massFlow
        status.powerBlock.massFlow += status.solarField.massFlow
      } // STORAGE: dischargeToHeater < Qrel < dischargeToTurbine; Fuel/NoFuel

      heat.storage.megaWatt = supply

      electricalParasitics.storage = parasitics

    } else if heatDiff < 0,
      status.storage.charge.ratio < Storage.parameter.dischargeToHeater,
      status.heater.operationMode != .freezeProtection
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

      status.heater.temperature.inlet = status.powerBlock.temperature.outlet

      heatingSolarField(&status, heatDiff, fuel)
    }
  }

  private static func heatingSolarField(
    _ status: inout PerformanceData,
    _ heatdiff: Double,
    _ fuel: Double)
  {
    Heater.update(status, demand: heatdiff, fuelAvailable: fuel)
    { result in
      status.heater = result.status
      heat.heater.megaWatt = result.supply
      electricalParasitics.heater = result.parasitics
      fuelConsumption.heater = result.fuel
    }
    let htf = SolarField.parameter.HTF

    status.powerBlock.temperature.inlet = htf.mixingTemperature(
      outlet: status.solarField, with: status.heater
    )

    status.powerBlock.massFlow = status.solarField.massFlow
    status.powerBlock.massFlow += status.heater.massFlow
  }

  private static func heatingPowerBlock(
    _ status: inout PerformanceData,
    _ heatdiff: Double,
    _ fuel: Double)
  {
    Heater.update(status, demand: heatdiff, fuelAvailable: fuel)
    { result in
      status.heater = result.status
      heat.heater.megaWatt = result.supply
      electricalParasitics.heater = result.parasitics
      fuelConsumption.heater = result.fuel
    }

    let htf = SolarField.parameter.HTF

    status.powerBlock.temperature.inlet = htf.mixingTemperature(
      inlet: status.powerBlock, with: status.heater
    )

    status.powerBlock.massFlow += status.heater.massFlow
  }

  private static func updateHeater(
    _ status: inout PerformanceData,
    _ supplyGasTurbine: Double,
    _ heatDiff: inout Double,
    _ fuel: Double)
  {
    // restart variable to avoid errors due to Boiler.  added for Shams-1
    if case .pure = status.gasTurbine.operationMode {
      // Plant updates in Pure CC Mode now again without RH!!
      // demand * WasteHeatRecovery.parameter.effPure * (1 / gasTurbine.efficiency- 1))
      // heat supplied by the WHR system
      
    } else if case .integrated = status.gasTurbine.operationMode {
      // Plant does not update in Pure CC Mode
      let energy = supplyGasTurbine * (1
        / GasTurbine.efficiency(at: status.gasTurbine.load) - 1)
        * WasteHeatRecovery.parameter.efficiencyNominal
        / WasteHeatRecovery.parameter.ratioHTF
      /// necessary HTF share
      heatDiff = heat.production.megaWatt - energy
      
      status.heater.temperature.inlet = status.powerBlock.temperature.outlet
      
      heatingPowerBlock(&status, heatDiff, fuel)
      
    } else if case .noOperation = status.gasTurbine.operationMode {
      // GasTurbine does not update at all (Load<Min?)
      heatingSolarField(&status, heatDiff, fuel)
    }

    if Design.hasStorage {
      heatingStorage(&status, &heatDiff, fuel)
      return
    } else {
      heatDiff = (heat.production + heat.wasteHeatRecovery).megaWatt
        / HeatExchanger.parameter.efficiency - heat.demand.megaWatt

      if heat.production.watt == 0 {
        // use heater only in parallel with solar field and not as stand alone.
        if Heater.parameter.onlyWithSolarField {
          heatDiff = 0
        }
      }

      status.heater.temperature.inlet = status.powerBlock.temperature.outlet

      heatingSolarField(&status, heatDiff, fuel)
    }
    
    if status.heater.massFlow.isNearZero == false {
      
      heat.production.megaWatt = status.powerBlock.massFlow.rate
        * SolarField.parameter.HTF.deltaHeat(
          status.powerBlock.temperature.outlet,
          status.powerBlock.temperature.inlet) / 1_000
    }
  }

  private static func updateBoiler(
    _ boiler: inout Boiler.PerformanceData,
    _ heatDiff: inout Double)
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

    Boiler.update(
      boiler, heatFlow: heatDiff, Qsf_load: Qsf_load, fuelAvailable: 0
    ) { result in
      boiler = result.status
      heat.boiler.megaWatt = result.supply
    }

    if Fuelmode.isPredefined { // predefined fuel consumption in *.pfc-file
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
