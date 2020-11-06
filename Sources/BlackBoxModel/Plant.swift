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
public struct Plant {

  var heat = ThermalEnergy()

  var electricalEnergy = ElectricPower()

  var fuelConsumption = FuelConsumption()

  var electricalParasitics = Parasitics()

  public static let initialState = PerformanceData()

  mutating func energyBalance() -> Energy {
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

  /// Reduces the mass flow of the solar field
  /// when there is less demand from the grid
  static func adjustMassFlow(_ solarField: inout SolarField) {
    let heatExchanger = HeatExchanger.parameter
    let steamTurbine = SteamTurbine.parameter
    // added to reduced SOF massflow with electrical demand
    solarField.setMassFlow(
      rate: GridDemand.current.ratio
        * (steamTurbine.power.max / steamTurbine.efficiencyNominal
          / heatExchanger.efficiency) * 1_000 / heatExchanger.heatDesign
    )
  }

  /// Calculation of the heat supplied by the solar field
  private mutating func update(
    _ solarField: SolarField,
    _ collector: Collector,
    _ steamTurbine: SteamTurbine
  )
    -> MassFlow
  {
    if collector.insolationAbsorber > 10 {
      heat.solar.kiloWatt = solarField.massFlow.rate * solarField.deltaHeat
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

  // MARK: - PowerBlock

  mutating func calculate(_ status: inout PerformanceData, ambient: Temperature) {
    let collector = status.collector
    var solarField = status.solarField
    var powerBlock = status.powerBlock
    var heater = status.heater
    var heatExchanger = status.heatExchanger
    var steamTurbine = status.steamTurbine
    var boiler = status.boiler
    var gasTurbine = status.gasTurbine
    var storage = status.storage

    defer {
      status.solarField = solarField
      status.powerBlock = powerBlock
      status.heater = heater
      status.heatExchanger = heatExchanger
      status.steamTurbine = steamTurbine
      status.boiler = boiler
      status.gasTurbine = gasTurbine
      status.storage = storage
    }

    @discardableResult func estimateElectricalEnergyDemand() -> Double {
      var estimate = 0.0
      if Design.hasGasTurbine {
        electricalEnergy.demand =
          GridDemand.current.ratio
          * (Design.layout.powerBlock - Design.layout.gasTurbine)
        estimate =
          electricalEnergy.demand
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

    func checkAvailability(_ steamTurbine: inout SteamTurbine) -> Double? {
      var load = steamTurbine.load ?? Ratio(1)
      guard load < Availability.current.value.powerBlock else { return nil }

      steamTurbine.load = Availability.current.value.powerBlock
      // The turbine load has changed recalculation of efficiency
      let (_, efficiency) = SteamTurbine.perform(
        steamTurbine.load, heat,
        boiler.operationMode,
        gasTurbine.operationMode,
        heatExchanger.temperature.inlet,
        ambient)

      return min(
        SteamTurbine.parameter.power.max * steamTurbine.load.ratio / efficiency,
        HeatExchanger.parameter.sccHTFheat)
    }

    func powerBlockElectricalParasitics(_ efficiency: Double)
      -> (powerBlock: Double, shared: Double)
    {
      let energy =
        heat.production.megaWatt - SteamTurbine.parameter.power.max
        / efficiency

      let powerBlock = PowerBlock.parasitics(
        heat: energy, steamTurbine: status.steamTurbine,
        temperature: ambient
      )
      let parasitics = PowerBlock.parameter.electricalParasiticsShared
      if heat.production.watt == 0 {  // added to separate shared facilities parasitics
        return (powerBlock, parasitics[0])
      } else {
        return (powerBlock, parasitics[1])
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

      electricalEnergy.parasitics =
        electricalEnergy.solarField
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

      let load =
        (electricalEnergy.demand + Design.layout.gasTurbine)
        / SteamTurbine.parameter.power.max

      steamTurbine.load = Ratio(load)
      // The turbine load has changed recalculation of efficiency
      var (_, efficiency) = SteamTurbine.perform(
        steamTurbine.load, heat,
        boiler.operationMode, gasTurbine.operationMode,
        heatExchanger.temperature.inlet, ambient)

      let demand = demandStrategyStorage()

      heat.demand.megaWatt = min(
        (demand / efficiency),
        HeatExchanger.parameter.sccHTFheat)

      /*  heat.demand.megaWatt =
        (checkAvailability(&steamTurbine) ?? heat.demand.megaWatt
        / Simulation.adjustmentFactor.heatLossH2O)
        / HeatExchanger.parameter.efficiency*/

      powerBlock.inletTemperature(outlet: solarField)

      Plant.outletTemperature(
        powerBlock: &powerBlock, heatExchanger: &heatExchanger, storage
      )

      if Design.hasSolarField {
        solarField.massFlow = update(solarField, collector, steamTurbine)
        powerBlock.massFlow = solarField.massFlow
      }

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
        ambient: ambient
      )

      heat.production = heat.heatExchanger + heat.wasteHeatRecovery
      /// Therm heat demand is lower after HX
      heat.demand.watt *= HeatExchanger.parameter.efficiency
      /// Unavoidable losses in Power Block
      heat.production.watt *= Simulation.adjustmentFactor.heatLossH2O

      if Design.hasBoiler { updateBoiler(&boiler, &heatDiff) }

      (_, efficiency) = SteamTurbine.perform(
        steamTurbine.load, heat,
        boiler.operationMode, gasTurbine.operationMode,
        heatExchanger.temperature.inlet, ambient
      )

      let energy =
        heat.production.megaWatt
        - SteamTurbine.parameter.power.max / efficiency

      if energy > Simulation.parameter.heatTolerance {  // TB.Overload
        /*  debugPrint("""
         \(DateTime.current)
         Overloading TB: \(heat) MWH,th
         """)*/
      } /*else if heatDiff > 2 * Simulation.parameter.heatTolerance {
        debugPrint("""
          \(DateTime.current)
          Production > demand: \(diff) MWH,th
          """)
      }*/

      let minLoad: Double
      if SteamTurbine.parameter.minPowerFromTemp.isInapplicable {
        #warning("The implementation here differs from PCT")
        minLoad =
          SteamTurbine.parameter.power.min
          / SteamTurbine.parameter.power.max
      } else {
        minLoad =
          SteamTurbine.parameter.minPowerFromTemp(ambient)
          / SteamTurbine.parameter.power.max
      }
      var minPower: Double
      if SteamTurbine.parameter.minPowerFromTemp.isInapplicable {
        minPower =
          SteamTurbine.parameter.power.min
          / SteamTurbine.parameter.efficiencyNominal
      } else {
        minPower = SteamTurbine.parameter.minPowerFromTemp(ambient)

        minPower = max(
          SteamTurbine.parameter.power.nominal * minPower,
          SteamTurbine.parameter.power.min)

        (_, efficiency) = SteamTurbine.perform(
          steamTurbine.load, heat,
          boiler.operationMode, gasTurbine.operationMode,
          heatExchanger.temperature.inlet, ambient
        )

        minPower /= efficiency
      }
      if heat.production.watt > 0, heat.production.megaWatt < minPower {
        heat.production = 0.0
        /*  debugPrint("""
         \(DateTime.current)
         "Damping (SteamTurbine underload): \(heat.production.megaWatt) MWH,th.
         """)*/
      }

      electricalEnergy.steamTurbineGross = steamTurbine(
        heater: heater, modeBoiler: boiler.operationMode,
        modeGasTurbine: gasTurbine.operationMode,
        heatExchanger: heatExchanger,
        temperature: ambient, heat: heat
      )

      if OperationRestriction.fuelStrategy.isPredefined {
        let steamTurbine = SteamTurbine.parameter.power.max
        if fuelConsumption.combined > 0
          && electricalEnergy.steamTurbineGross
            > steamTurbine + 1
        {
          electricalEnergy.steamTurbineGross = steamTurbine + 1
        }
        if fuelConsumption.combined > 0, heat.solar.watt > 0,
          electricalEnergy.steamTurbineGross > steamTurbine - 1
        {
          electricalEnergy.steamTurbineGross = steamTurbine - 1
        }
      }

      if Design.hasStorage {
        if case .always = Storage.parameter.strategy {
        }  // new restriction of production
        else if electricalEnergy.steamTurbineGross > electricalEnergy.demand {
          heat.dumping.megaWatt =
            electricalEnergy.steamTurbineGross
            - electricalEnergy.demand
          electricalEnergy.steamTurbineGross = electricalEnergy.demand
        }
      } else { /* if Heater.parameter.operationMode */
        // following uncomment for Shams-1.
        if electricalEnergy.steamTurbineGross > electricalEnergy.demand {
          let electricEnergyFactor =
            electricalEnergy.demand
            / electricalEnergy.steamTurbineGross

          heat.dumping.megaWatt =
            electricalEnergy.steamTurbineGross
            - electricalEnergy.demand * electricEnergyFactor

          // reduction necessary for every project without storage
          heat.solar.watt *= electricEnergyFactor
          heat.heatExchanger.watt *= electricEnergyFactor

          heatDiff *= electricEnergyFactor
          var Qsf_load = 0.0
          Qsf_load *= electricEnergyFactor

          let fuel = Availability.fuel

          let energy = boiler(
            demand: heatDiff, Qsf_load: Qsf_load, fuelAvailable: fuel
          )
          heat.boiler.megaWatt = energy.heat
          fuelConsumption.boiler = energy.fuel
          electricalParasitics.boiler = energy.electric

          electricalEnergy.steamTurbineGross = steamTurbine(
            heater: heater, modeBoiler: boiler.operationMode,
            modeGasTurbine: gasTurbine.operationMode,
            heatExchanger: heatExchanger,
            temperature: ambient, heat: heat
          )
        }
      }

      electricalEnergy.gross = electricalEnergy.steamTurbineGross
      electricalEnergy.gross += electricalEnergy.gasTurbineGross

      let (powerBlock, shared) = powerBlockElectricalParasitics(efficiency)
      electricalParasitics.powerBlock = powerBlock
      electricalParasitics.shared = shared
      totalizeElectricalParasitics()

      if case .startUp = steamTurbine.operationMode {
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
    assert(step < 11, "Too many iterations")
  }

  private mutating func checkForFreezeProtection(
    heater: inout Heater, powerBlock: inout PowerBlock,
    storage: Storage, solarField: SolarField,
    _ heatDiff: Double, _ fuel: Double
  ) {
    // if [.normal, .reheat].contains(heater.operationMode) { return }

    let freezeTemperature = SolarField.parameter.HTF.freezeTemperature

    if solarField.header.temperature.outlet < freezeTemperature
      + Simulation.parameter.dfreezeTemperatureHeat,
      storage.massFlow.isNearZero
    {  // No freeze protection heater use anymore if storage is in operation
      heater.inletTemperature(powerBlock)

      heater.massFlow = powerBlock.massFlow

      heater.operationMode = .freezeProtection(.zero)

      let energy = heater(
        temperatureOutlet: solarField.temperature.outlet,
        temperatureInlet: powerBlock.temperature.inlet,
        massFlowStorage: storage.massFlow,
        modeStorage: storage.operationMode,
        demand: heatDiff, fuelAvailable: fuel, heat: heat
      )
      fuelConsumption.heater = energy.fuel
      heat.heater.megaWatt = energy.heat
      electricalParasitics.heater = energy.electric
    }

    if case .freezeProtection = heater.operationMode {
      powerBlock.outletTemperature(heater)
    } else {
      if solarField.header.outletTemperature
        > freezeTemperature.kelvin
        + Simulation.parameter.dfreezeTemperatureHeat.kelvin
      {
        heater.operationMode = .noOperation

        let energy = heater(
          temperatureOutlet: solarField.temperature.outlet,
          temperatureInlet: powerBlock.temperature.inlet,
          massFlowStorage: storage.massFlow,
          modeStorage: storage.operationMode,
          demand: heatDiff, fuelAvailable: fuel, heat: heat
        )
        fuelConsumption.heater = energy.fuel
        heat.heater.megaWatt = energy.heat
        electricalParasitics.heater = energy.electric
      }
    }
  }

  private static func outletTemperature(
    powerBlock: inout PowerBlock,
    heatExchanger: inout HeatExchanger,
    _ storage: Storage
  ) {
    if powerBlock.massFlow.isNearZero == false,
      powerBlock.temperature.inlet
        >= HeatExchanger.parameter.temperature.htf.inlet.min
    {
      powerBlock.temperature.outlet =
        HeatExchanger
        .outletTemperature(powerBlock, heatExchanger)

      if case .discharge = storage.operationMode,
        powerBlock.temperature.outlet.isLower(than: 534.0)
      {
        let result = powerBlock.heatExchangerBypass()
        heatExchanger.heatOut = result.heatOut
        heatExchanger.heatToTES = result.heatToTES
      }
    } else {
      powerBlock.outletTemperatureInlet()
    }
  }

  private mutating func temperaturesPowerBlock(
    solarField: inout SolarField,
    collector: Collector,
    powerBlock: inout PowerBlock,
    heater: inout Heater,
    heatExchanger: inout HeatExchanger,
    steamTurbine: inout SteamTurbine,
    boiler: inout Boiler,
    gasTurbine: inout GasTurbine,
    storage: inout Storage,
    ambient: Temperature
  )
    -> Double
  {
    // Iteration: Find the right temperature for inlet and outlet of powerblock
    let fuel = Availability.fuel
    var heatDiff: Double = 0.0
    let tolerance = Simulation.parameter.tempTolerance.kelvin
    // Calculation of the heat supplied by the solar field

    Iteration: while true {
      if Design.hasStorage {
        updateStorage(
          &storage,
          solarField: &solarField,
          powerBlock: &powerBlock,
          heater: &heater,
          steamTurbine: &steamTurbine,
          fuelAvailable: fuel
        )
      }

      if Design.hasGasTurbine {
        electricalEnergy.gasTurbineGross = GasTurbine.update(
          //        storage: &storage,
          //        powerBlock: &powerBlock,
          boiler: boiler.operationMode,
          gasTurbine: &gasTurbine,
          heatExchanger: heatExchanger,
          steamTurbine: &steamTurbine,
          temperature: ambient, fuel: fuel, plant: &self
        )
      }

      if Design.hasHeater && !Design.hasBoiler {
        updateHeater(
          &heater,
          solarField: &solarField,
          powerBlock: &powerBlock,
          gasTurbine: gasTurbine,
          steamTurbine: &steamTurbine,
          storage: &storage,
          &heatDiff, fuel
        )
      }

      checkForFreezeProtection(
        heater: &heater,
        powerBlock: &powerBlock,
        storage: storage,
        solarField: solarField,
        heatDiff, fuel
      )

      if powerBlock.temperature.inlet
        < HeatExchanger.parameter.temperature.htf.inlet.min
        || powerBlock.massFlow.rate == 0//  || status.storage.operationMode.isFreezeProtection
      //  || status.solarField.operationMode.isFreezeProtection
      {
        if heater.operationMode.isFreezeProtection == false {
          powerBlock.temperatureLoss(wrt: solarField, storage)
        }
        heat.production = 0.0
        heat.heatExchanger = 0.0
        heatExchanger.massFlow = 0.0

        break Iteration
      }

      heatExchanger.massFlow = powerBlock.massFlow

      heatExchanger.setTemperature(inlet: powerBlock.temperature.inlet)

      heat.heatExchanger.megaWatt = heatExchanger(
        steamTurbine: steamTurbine, storage: storage
      )

      powerBlock.outletTemperature(heatExchanger)

      if Design.hasGasTurbine, Design.hasStorage,
        heat.heatExchanger.megaWatt > HeatExchanger.parameter.sccHTFheat
      {
        heat.dumping.megaWatt +=
          heat.heatExchanger.megaWatt
          - HeatExchanger.parameter.sccHTFheat

        heat.heatExchanger.megaWatt = HeatExchanger.parameter.sccHTFheat
      }

      if abs(powerBlock.outletTemperature - heatExchanger.outletTemperature)
        < tolerance
      {
        break Iteration
      }

      powerBlock.outletTemperature(heatExchanger)
    }
    return heatDiff
  }

  // MARK: - Storage

  private mutating func updateStorage(
    _ storage: inout Storage,
    solarField: inout SolarField,
    powerBlock: inout PowerBlock,
    heater: inout Heater,
    steamTurbine: inout SteamTurbine,
    fuelAvailable fuel: Double
  ) {
    // Demand for operation of the storage and adjustment of the powerblock mass flow
    Storage.demandStrategy(
      storage: &storage,
      powerBlock: &powerBlock,
      solarField: solarField,
      heat: heat
    )

    let energy = Storage.update(
      storage: &storage,
      solarField: &solarField,
      steamTurbine: &steamTurbine,
      powerBlock: &powerBlock,
      heater: &heater,
      demand: heat.demand.megaWatt,
      fuelAvailable: fuel,
      heat: &heat
    )

    heat.storage.megaWatt = -energy.heat
    fuelConsumption.heater = energy.fuel
    electricalParasitics.storage = energy.electric

    let thermal = -storage.massFlow.rate * storage.deltaHeat / 1_000

    let thermalPower = storage.salt.calculate(thermal, storage: storage)
    heat.storage.megaWatt = thermalPower

    if storage.heat > 0 {  // Energy surplus
      if storage.charge.ratio < Storage.parameter.chargeTo,
        solarField.massFlow >= powerBlock.massFlow
      {  // 1.1
        heat.production = heat.solar
        heat.production += heat.storage
      } else {  // heat cannot be stored
        heat.production = heat.solar
        heat.production.megaWatt -= storage.heat
      }
    } else {  // Energy deficit
      heat.production = heat.solar
      heat.production += heat.storage
    }
  }

  // MARK: - Heater

  private mutating func heating(
    storage: inout Storage,
    solarField: inout SolarField,
    powerBlock: inout PowerBlock,
    heater: inout Heater,
    steamTurbine: inout SteamTurbine,
    heatDiff: inout Double,
    fuel: Double
  ) {
    if heatDiff < 0,
      storage.charge.ratio < Storage.parameter.dischargeToTurbine,
      storage.charge.ratio > Storage.parameter.dischargeToHeater
    {
      // Direct Discharging to SteamTurbine
      var supply: Double
      var parasitics: Double
      if fuel > 0 {  // Fuel available, Storage for Pre-Heating

        (supply, parasitics) = Storage.perform(
          storage: &storage,
          solarField: &solarField,
          steamTurbine: &steamTurbine,
          powerBlock: &powerBlock,
          mode: .preheat, heat: &heat
        )

        heater.inletTemperature(outlet: storage)

        heater.operationMode = .unknown

        heatDiff =
          heat.production.megaWatt
          + heat.storage.megaWatt - heat.demand.megaWatt

        heating(
          solarField: solarField,
          heater: &heater,
          powerBlock: &powerBlock,
          storage: storage,
          heatDiff: heatDiff,
          fuel: fuel)

        heater.massFlow = storage.massFlow
      } else {  // No Fuel Available -> Discharge directly with reduced TB load

        (supply, parasitics) = Storage.perform(
          storage: &storage,
          solarField: &solarField,
          steamTurbine: &steamTurbine,
          powerBlock: &powerBlock,
          mode: .discharge, heat: &heat
        )

        powerBlock.formJoint(solarField, storage)
      }  // STORAGE: dischargeToHeater < Qrel < dischargeToTurbine; Fuel/NoFuel

      heat.storage.megaWatt = supply

      electricalParasitics.storage = parasitics

    } else if heatDiff < 0,  //heater.operationMode != .freezeProtection,
      storage.charge.ratio < Storage.parameter.dischargeToHeater
    {
      heatDiff =
        (heat.production + heat.wasteHeatRecovery).megaWatt
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
        heatDiff: heatDiff,
        fuel: fuel)
    }
  }

  private mutating func heating(
    solarField: SolarField,
    heater: inout Heater,
    powerBlock: inout PowerBlock,
    storage: Storage,
    heatDiff: Double,
    fuel: Double
  ) {
    let energy = heater(
      temperatureOutlet: solarField.temperature.outlet,
      temperatureInlet: powerBlock.temperature.inlet,
      massFlowStorage: storage.massFlow,
      modeStorage: storage.operationMode,
      demand: heatDiff, fuelAvailable: fuel, heat: heat
    )

    fuelConsumption.heater = energy.fuel
    heat.heater.megaWatt = energy.heat
    electricalParasitics.heater = energy.electric

    powerBlock.formJoint(solarField, heater)
  }

  private mutating func heating(
    powerBlock: inout PowerBlock,
    heater: inout Heater,
    storage: Storage,
    solarField: SolarField,
    heatDiff: Double,
    fuel: Double
  ) {
    let energy = heater(
      temperatureOutlet: solarField.temperature.outlet,
      temperatureInlet: powerBlock.temperature.inlet,
      massFlowStorage: storage.massFlow,
      modeStorage: storage.operationMode,
      demand: heatDiff, fuelAvailable: fuel, heat: heat
    )

    fuelConsumption.heater = energy.fuel
    heat.heater.megaWatt = energy.heat
    electricalParasitics.heater = energy.electric

    powerBlock.add(heater)
  }

  private mutating func updateHeater(
    _ heater: inout Heater,
    solarField: inout SolarField,
    powerBlock: inout PowerBlock,
    gasTurbine: GasTurbine,
    steamTurbine: inout SteamTurbine,
    storage: inout Storage,
    _ heatDiff: inout Double,
    _ fuel: Double
  ) {
    if case .pure = gasTurbine.operationMode {
      // Plant updates in Pure CC Mode now again without RH!!
      // demand * WasteHeatRecovery.parameter.effPure * (1 / gasTurbine.efficiency- 1))
      // heat supplied by the WHR system

    } else if case .integrated = gasTurbine.operationMode {
      // Plant does not update in Pure CC Mode
      let energy =
        electricalEnergy.gasTurbineGross
        * (1
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
        heatDiff: heatDiff,
        fuel: fuel)
    } else if case .noOperation = gasTurbine.operationMode {
      // GasTurbine does not update at all (Load<Min?)
      heating(
        solarField: solarField,
        heater: &heater,
        powerBlock: &powerBlock,
        storage: storage,
        heatDiff: heatDiff,
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

      heatDiff =
        (heat.production + heat.wasteHeatRecovery).megaWatt
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
        heatDiff: heatDiff,
        fuel: fuel)
    }

    if heater.massFlow.isNearZero == false {
      heat.production.kiloWatt = powerBlock.massFlow.rate * powerBlock.deltaHeat
    }
  }

  // MARK: - Boiler

  private mutating func updateBoiler(
    _ boiler: inout Boiler, _ heatDiff: inout Double
  ) {
    var Qsf_load: Double

    let adjustmentFactor = Simulation.adjustmentFactor

    let efficiency = SteamTurbine.parameter.efficiencyNominal

    if case .solarOnly = Control.whichOptimization {

      if heat.production.megaWatt < adjustmentFactor.efficiencyHeater,
        heat.production.megaWatt >= adjustmentFactor.efficiencyBoiler
      {
        switch boiler.operationMode {
        case .startUp, .SI, .NI: break
        default: boiler.operationMode = .unknown
        }

        heatDiff = heat.production.megaWatt - heat.demand.megaWatt

        if Boiler.parameter.booster {  // booster superheater

          if heat.heater.megaWatt == Design.layout.heater {
            Qsf_load = 0.769
          } else {
            Qsf_load =
              heat.production.megaWatt
              / (Design.layout.heatExchanger / efficiency)
          }
        }
        // H2OinBO.temperature.inlet = H2OinPB.temperature.outlet
      } else {
        boiler.operationMode = .noOperation(hours: 0)
      }
    }

    if heat.heater.megaWatt == Design.layout.heater {
      Qsf_load = 0.769
    } else {
      Qsf_load = heat.production.megaWatt / (Design.layout.heatExchanger / efficiency)
    }

    let energy = boiler(demand: heatDiff, Qsf_load: Qsf_load, fuelAvailable: 0)

    heat.boiler.megaWatt = energy.heat
    fuelConsumption.boiler = energy.fuel
    electricalParasitics.boiler = energy.electric

    // predefined fuel consumption in *.pfc-file
    if OperationRestriction.fuelStrategy.isPredefined {
      if (heat.heatExchanger.megaWatt + heat.boiler.megaWatt) > 110 {
        heat.boiler.megaWatt = 105 - heat.heatExchanger.megaWatt
      }

      heat.production =
        (heat.heatExchanger + heat.wasteHeatRecovery)
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
