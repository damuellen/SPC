//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import DateGenerator
/// A namespace for the main routines of the simulation.
public struct Plant {

  var heat = ThermalPower()

  var electricity = ElectricPower()

  var fuelConsumption = FuelConsumption()

  var electricalParasitics = Parasitics()

  public static let initialState = Status()

  mutating func performance() -> Performance {
    electricity.net = electricity.gross
    electricity.net -= electricity.parasitics

    if electricity.net < 0 {
      electricity.consum = -electricity.net
      electricity.net = 0
    } else {
      electricity.consum = 0
    }

    return Performance(
      thermal: heat, electric: electricity,
      fuel: fuelConsumption, parasitics: electricalParasitics)
  }

  // MARK: - SolarField

  static func requiredMassFlow() -> MassFlow {
    let heatExchanger = HeatExchanger.parameter
    let steamTurbine = SteamTurbine.parameter
    // added to reduced SOF massflow with electrical demand
    return MassFlow(GridDemand.current.ratio
      * (steamTurbine.power.max / steamTurbine.efficiencyNominal
        / heatExchanger.efficiency) * 1_000 / heatExchanger.heatDesign)    
  }

  /// Calculation of the heat supplied by the solar field
  private mutating func perform(
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
        heat.startUp = heat.solar
        heat.production = 0.0
      } else {
        heat.startUp = 0.0
        heat.production = heat.solar
      }
    } else if case .freezeProtection = solarField.operationMode {
  //    heat.solar = 0.0
      heat.production = 0.0
    } else {
   //   heat.solar = 0.0
      heat.production = 0.0
      return 0.0
    }
    return solarField.massFlow
  }

  // MARK: - PowerBlock

  mutating func perform(_ status: inout Status, ambient: Temperature) {

    @discardableResult func estimateElectricalEnergyDemand() -> Double {
      var estimate = 0.0
      if Design.hasGasTurbine {
        electricity.demand =
          GridDemand.current.ratio
          * (Design.layout.powerBlock - Design.layout.gasTurbine)
        estimate =
          electricity.demand
          * Simulation.parameter.electricalParasitics
        // Iter. start val. for parasitics, 10% demand
        electricity.demand += estimate
      } else {
        let steamTurbine = SteamTurbine.parameter.power.max
        electricity.demand = GridDemand.current.ratio * steamTurbine
        estimate = electricity.storage
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
        return electricity.demand
      }
    }

    func checkAvailability(_ steamTurbine: inout SteamTurbine) -> Double? {
      guard steamTurbine.load < Availability.current.value.powerBlock
        else { return nil }

      status.steamTurbine.load = Availability.current.value.powerBlock
      // The turbine load has changed recalculation of efficiency
      let (_, efficiency) = SteamTurbine.perform(
        status.steamTurbine.load, heat,
        status.boiler.operationMode,
        status.gasTurbine.operationMode,
        status.heatExchanger.temperature.inlet,
        ambient)

      return min(
        SteamTurbine.parameter.power.max * steamTurbine.load.quotient / efficiency,
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
      electricity.solarField = electricalParasitics.solarField
      electricity.storage = electricalParasitics.storage

      // electricPerformance.parasiticsBU =
      // electricalParasitics.heater + electricalParasitics.boiler
      electricity.powerBlock = electricalParasitics.powerBlock
      electricity.shared = electricalParasitics.shared

      electricity.parasitics =
        electricity.solarField
        + electricity.gasTurbine
        + electricalParasitics.powerBlock
        + electricalParasitics.shared

      electricity.parasitics *=
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
        (electricity.demand + Design.layout.gasTurbine)
        / SteamTurbine.parameter.power.max

      status.steamTurbine.load = Ratio(load)
      // The turbine load has changed recalculation of efficiency
      var (_, efficiency) = SteamTurbine.perform(
        status.steamTurbine.load, heat,
        status.boiler.operationMode, 
        status.gasTurbine.operationMode,
        status.heatExchanger.temperature.inlet,
        ambient
      )

      let demand = demandStrategyStorage()

      heat.demand.megaWatt = min(
        (demand / efficiency),
        HeatExchanger.parameter.sccHTFheat)

      /*  heat.demand.megaWatt =
        (checkAvailability(&steamTurbine) ?? heat.demand.megaWatt
        / Simulation.adjustmentFactor.heatLossH2O)
        / HeatExchanger.parameter.efficiency*/

      status.powerBlock.inletTemperature(outlet: status.solarField)

      Plant.outletTemperature(
        powerBlock: &status.powerBlock,
        heatExchanger: &status.heatExchanger,
        status.storage
      )

      if Design.hasSolarField {
        status.powerBlock.massFlow = perform(
          status.solarField, status.collector, status.steamTurbine
        )
      //  status.powerBlock.massFlow = status.solarField.massFlow
      }

      if Design.hasStorage {
        heat.demand.megaWatt = Storage.demandStrategy(
          storage: &status.storage,
          powerBlock: &status.powerBlock,          
          demand: heat.demand,
          production: heat.production
        )
      }

      var heatDiff = powerBlockTemperature(&status, ambient: ambient)

      heat.production = heat.heatExchanger + heat.wasteHeatRecovery
      /// Therm heat demand is lower after HX
      heat.demand.watt *= HeatExchanger.parameter.efficiency
      /// Unavoidable losses in Power Block
      heat.production.watt *= Simulation.adjustmentFactor.heatLossH2O

      if Design.hasBoiler { updateBoiler(&status.boiler, &heatDiff) }

      (_, efficiency) = SteamTurbine.perform(
        status.steamTurbine.load, heat,
        status.boiler.operationMode, status.gasTurbine.operationMode,
        status.heatExchanger.temperature.inlet, ambient
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

      let minLoad: Ratio
      if SteamTurbine.parameter.minPowerFromTemp.isInapplicable {
        //#warning("The implementation here differs from PCT")
        minLoad = Ratio(
          SteamTurbine.parameter.power.min
          / SteamTurbine.parameter.power.max)
      } else {
        minLoad = Ratio(
          SteamTurbine.parameter.minPowerFromTemp(ambient)
          / SteamTurbine.parameter.power.max)
      }
      status.steamTurbine.load = max(
        status.steamTurbine.load, minLoad
      )
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
          status.steamTurbine.load, heat,
          status.boiler.operationMode,
          status.gasTurbine.operationMode,
          status.heatExchanger.temperature.inlet, ambient
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

      electricity.steamTurbineGross = status.steamTurbine(
        heater: status.heater,
        modeBoiler: status.boiler.operationMode,
        modeGasTurbine: status.gasTurbine.operationMode,
        heatExchanger: status.heatExchanger,
        temperature: ambient, heat: heat
      )

      if OperationRestriction.fuelStrategy.isPredefined {
        let steamTurbine = SteamTurbine.parameter.power.max
        if fuelConsumption.combined > 0
          && electricity.steamTurbineGross
            > steamTurbine + 1
        {
          electricity.steamTurbineGross = steamTurbine + 1
        }
        if fuelConsumption.combined > 0, heat.solar.watt > 0,
          electricity.steamTurbineGross > steamTurbine - 1
        {
          electricity.steamTurbineGross = steamTurbine - 1
        }
      }

      if Design.hasStorage {
        if case .always = Storage.parameter.strategy {
        }  // new restriction of production
        else if electricity.steamTurbineGross > electricity.demand {
          heat.dumping.megaWatt =
            electricity.steamTurbineGross
            - electricity.demand
          electricity.steamTurbineGross = electricity.demand
        }
      } else { /* if Heater.parameter.operationMode */
        // following uncomment for Shams-1.
        if electricity.steamTurbineGross > electricity.demand {
          let electricEnergyFactor =
            electricity.demand
            / electricity.steamTurbineGross

          heat.dumping.megaWatt =
            electricity.steamTurbineGross
            - electricity.demand * electricEnergyFactor

          // reduction necessary for every project without storage
          heat.solar.watt *= electricEnergyFactor
          heat.heatExchanger.watt *= electricEnergyFactor

          heatDiff *= electricEnergyFactor
          var Qsf_load = 1.0
          Qsf_load *= electricEnergyFactor

          let fuel = Availability.fuel

          let energy = status.boiler(
            demand: heatDiff, Qsf_load: Qsf_load, fuelAvailable: fuel
          )
          heat.boiler.megaWatt = energy.heat
          fuelConsumption.boiler = energy.fuel
          electricalParasitics.boiler = energy.electric

          electricity.steamTurbineGross = status.steamTurbine(
            heater: status.heater, 
            modeBoiler: status.boiler.operationMode,
            modeGasTurbine: status.gasTurbine.operationMode,
            heatExchanger: status.heatExchanger,
            temperature: ambient, heat: heat
          )
        }
      }

      electricity.gross = electricity.steamTurbineGross
      electricity.gross += electricity.gasTurbineGross

      let (powerBlock, shared) = powerBlockElectricalParasitics(efficiency)
      electricalParasitics.powerBlock = powerBlock
      electricalParasitics.shared = shared
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

      deviation = abs(parasiticsAssumed - electricity.parasitics)
      parasiticsAssumed = electricity.parasitics

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
      heater.inletTemperature(outlet: solarField)
      heater.massFlow = solarField.massFlow

      heater.operationMode = .freezeProtection(1.0)

      let energy = heater(
        storage: storage.massFlow,
        mode: storage.operationMode,
        demand: heatDiff,
        fuelAvailable: fuel,
        heat: heat
      )

      fuelConsumption.heater = energy.fuel
      heat.heater.megaWatt = energy.heat
      electricalParasitics.heater = energy.electric
    }

    if solarField.minTemperature
      > freezeTemperature.kelvin
      + Simulation.parameter.dfreezeTemperatureHeat
    {
      heater.operationMode = .noOperation
      heater.inletTemperature(outlet: solarField)

      let energy = heater(
        storage: storage.massFlow,
        mode: storage.operationMode,
        demand: heatDiff,
        fuelAvailable: fuel,
        heat: heat
      )

      fuelConsumption.heater = energy.fuel
      heat.heater.megaWatt = energy.heat
      electricalParasitics.heater = energy.electric
    }
    
    if case .freezeProtection = heater.operationMode {
      powerBlock.outletTemperature(outlet: heater)
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
      powerBlock.temperature.outlet = HeatExchanger
        .temperatureOutlet(powerBlock, heatExchanger)

      if case .discharge = storage.operationMode,
        powerBlock.temperature.outlet.isLower(than: 534.0)
      {
        let result = powerBlock.heatExchangerBypass()
        heatExchanger.heatOut = result.heatOut
        heatExchanger.heatToTES = result.heatToTES
      }
    } else {
      powerBlock.outletTemperatureFromInlet()
    }
  }

  private mutating func powerBlockTemperature(
   _ status: inout Status,
   ambient: Temperature) -> Double
  {
    // Iteration: Find the right temperature for inlet and outlet of powerblock
    let fuel = Availability.fuel
    var heatDiff: Double = 0.0
    let tolerance = Simulation.parameter.tempTolerance

    if Design.hasGasTurbine {
      electricity.gasTurbineGross = GasTurbine.perform(
        //        storage: &storage,
        //        powerBlock: &powerBlock,
        boiler: status.boiler.operationMode,
        gasTurbine: &status.gasTurbine,
        heatExchanger: status.heatExchanger,
        steamTurbine: &status.steamTurbine,
        temperature: ambient, fuel: fuel, plant: &self
      )
    }

    // Calculation of the heat supplied by the solar field
    Iteration: while true {
      if Design.hasStorage {
        // Demand for operation of the storage and adjustment of the powerblock mass flow
        updateStorage(&status, fuelAvailable: fuel)

        let thermal = -status.storage.massFlow.rate * status.storage.deltaHeat / 1_000

        heat.storage.megaWatt = status.storage.calculate(thermal)

        if status.storage.heat > 0 {  // Performance surplus
          if status.storage.charge < Storage.parameter.chargeTo,
            status.solarField.massFlow >= status.powerBlock.designMassFlow
          {  // 1.1
            heat.production = heat.solar
            heat.production += heat.storage
          } else {  // heat cannot be stored
            heat.production.megaWatt -= status.storage.heat
          }
        } else {  // Performance deficit
          heat.production = heat.solar
          heat.production += heat.storage
        }
      }

      if Design.hasHeater && !Design.hasBoiler {
        updateHeater(
          &status.heater,
          solarField: &status.solarField,
          powerBlock: &status.powerBlock,
          gasTurbine: status.gasTurbine,
          steamTurbine: &status.steamTurbine,
          storage: &status.storage,
          &heatDiff, fuel
        )
      }

      checkForFreezeProtection(
        heater: &status.heater,
        powerBlock: &status.powerBlock,
        storage: status.storage,
        solarField: status.solarField,
        heatDiff, fuel
      )

      if status.powerBlock.temperature.inlet
        < HeatExchanger.parameter.temperature.htf.inlet.min
        || status.powerBlock.massFlow.rate == 0 // status.storage.operationMode.isFreezeProtection
        || status.solarField.operationMode.isFreezeProtection
      {
        if status.heater.operationMode.isFreezeProtection == false {
          status.powerBlock.temperatureLoss(wrt: status.solarField, status.storage)
        }
        heat.production = 0.0
        heat.heatExchanger = 0.0
        status.heatExchanger.massFlow = 0.0
        
        break Iteration
      }

      status.heatExchanger.massFlow = status.powerBlock.massFlow
      
      status.heatExchanger.setTemperature(inlet: status.powerBlock.temperature.inlet)

      heat.heatExchanger.megaWatt = status.heatExchanger(
        steamTurbine: status.steamTurbine, storage: status.storage
      )

      status.powerBlock.outletTemperature(outlet: status.heatExchanger)

      if Design.hasGasTurbine, Design.hasStorage,
        heat.heatExchanger.megaWatt > HeatExchanger.parameter.sccHTFheat
      {
        heat.dumping.megaWatt +=
          heat.heatExchanger.megaWatt
          - HeatExchanger.parameter.sccHTFheat

        heat.heatExchanger.megaWatt = HeatExchanger.parameter.sccHTFheat
      }

      if abs(status.powerBlock.outletTemperature - status.heatExchanger.outletTemperature)
        < tolerance
      {
        break Iteration
      }

     // status.powerBlock.outletTemperature(outlet: status.heatExchanger)
    }
    return heatDiff
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
    if heatDiff < .zero,
      storage.charge < Storage.parameter.dischargeToTurbine,
      storage.charge > Storage.parameter.dischargeToHeater
    {
      // Direct Discharging to SteamTurbine
      var supply: Power
      var parasitics: Power
      if fuel > .zero {  // Fuel available, Storage for Pre-Heating
        storage.operationMode = .preheat
        (supply, parasitics) = Storage.perform(
          storage: &storage,
          solarField: &solarField,
          steamTurbine: &steamTurbine,
          powerBlock: &powerBlock,
          heat: &heat
        )

        heater.inletTemperature(outlet: storage)

        heater.operationMode = .unknown

        heatDiff =
          heat.production.megaWatt
          + heat.storage.megaWatt - heat.demand.megaWatt

        let energy = heater(
          storage: storage.massFlow,
          mode: storage.operationMode,
          demand: heatDiff, fuelAvailable: fuel, heat: heat
        )

        fuelConsumption.heater = energy.fuel
        heat.heater.megaWatt = energy.heat
        electricalParasitics.heater = energy.electric
      } else {  // No Fuel Available -> Discharge directly with reduced TB load
        storage.operationMode = .discharge
        (supply, parasitics) = Storage.perform(
          storage: &storage,
          solarField: &solarField,
          steamTurbine: &steamTurbine,
          powerBlock: &powerBlock,
          heat: &heat
        )

        powerBlock.formJoint(solarField, storage)
      }  // STORAGE: dischargeToHeater < Qrel < dischargeToTurbine; Fuel/NoFuel

      heat.storage = supply

      electricalParasitics.storage = parasitics.megaWatt

    } else if heatDiff < .zero,  //heater.operationMode != .freezeProtection,
      storage.charge < Storage.parameter.dischargeToHeater
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

      heater.inletTemperature(outlet: solarField)

      let energy = heater(
        storage: storage.massFlow,
        mode: storage.operationMode,
        demand: heatDiff, 
        fuelAvailable: fuel,
        heat: heat
      )

      fuelConsumption.heater = energy.fuel
      heat.heater.megaWatt = energy.heat
      electricalParasitics.heater = energy.electric

      powerBlock.formJoint(solarField, heater)
    }
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
      let power =
        electricity.gasTurbineGross
        * (1
          / GasTurbine.efficiency(at: gasTurbine.load) - 1)
        * WasteHeatRecovery.parameter.efficiencyNominal
        / WasteHeatRecovery.parameter.ratioHTF
      /// necessary HTF share
      heatDiff = heat.production.megaWatt - power

      heater.inletTemperature(inlet: powerBlock)

      let energy = heater(
        storage: storage.massFlow,
        mode: storage.operationMode,
        demand: heatDiff, fuelAvailable: fuel, heat: heat
      )

      fuelConsumption.heater = energy.fuel
      heat.heater.megaWatt = energy.heat
      electricalParasitics.heater = energy.electric

      powerBlock.merge(heater)
    } else if case .noOperation = gasTurbine.operationMode {
      // GasTurbine does not update at all (Load<Min?)
      heater.inletTemperature(outlet: solarField)

      let energy = heater(
        storage: storage.massFlow,
        mode: storage.operationMode,
        demand: heatDiff, fuelAvailable: fuel, heat: heat
      )

      fuelConsumption.heater = energy.fuel
      heat.heater.megaWatt = energy.heat
      electricalParasitics.heater = energy.electric

      powerBlock.formJoint(solarField, heater)
    }

    if Design.hasStorage {
      heating(
        storage: &storage,
        solarField: &solarField,
        powerBlock: &powerBlock,
        heater: &heater,
        steamTurbine: &steamTurbine,
        heatDiff: &heatDiff,
        fuel: fuel
      )
    } else {
      heatDiff =
        (heat.production + heat.wasteHeatRecovery).megaWatt
        / HeatExchanger.parameter.efficiency - heat.demand.megaWatt

      if heat.production.watt == 0 {
        // use heater only in parallel with solar field and not as stand alone.
        if Heater.parameter.onlyWithSolarField { heatDiff = 0 }
      }

      heater.inletTemperature(outlet: solarField)

      let energy = heater(
        storage: storage.massFlow,
        mode: storage.operationMode,
        demand: heatDiff, fuelAvailable: fuel, heat: heat
      )

      fuelConsumption.heater = energy.fuel
      heat.heater.megaWatt = energy.heat
      electricalParasitics.heater = energy.electric

      powerBlock.formJoint(solarField, heater)
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

  mutating func updateStorage(_ status: inout Status, fuelAvailable: Double) {    
    let parameter = Storage.parameter
    var supply: Power
    var parasitics: Power
    var fuel = 0.0

    // **************************  Energy surplus  *****************************
    if status.storage.heat > .zero {

      if status.storage.charge < parameter.chargeTo,
        status.solarField.massFlow >= status.powerBlock.designMassFlow // SolarField.parameter.maxMassFlow
      {
        status.storage.operationMode = .charging
      } else { // heat cannot be stored
        status.storage.operationMode = .noOperation
      }
      (supply, parasitics) = Storage.perform(
        storage: &status.storage,
        solarField: &status.solarField,
        steamTurbine: &status.steamTurbine,
        powerBlock: &status.powerBlock,
        heat: &heat
      )
      status.powerBlock.inletTemperature(outlet: status.solarField)
      heat.storage = supply
      fuelConsumption.heater = 0
      electricalParasitics.storage = parasitics.megaWatt
      return
    }
    
    // **************************  Energy deficit  *****************************
    var peakTariff: Bool
    let time = DateTime.current
    // check when to discharge TES
    if case .shifter = parameter.strategy { // only for Shifter
      if time.month < parameter.startexcep || time.month > parameter.endexcep
      { // Oct to March
        peakTariff = time.hour >= parameter.dischargeWinter
      } else { // April to Sept
        peakTariff = time.hour >= parameter.dischargeSummer
      }
    } else { // not shifter
      peakTariff = true // dont care about time to discharge
    }

    //#warning("The implementation here differs from PCT")
    if peakTariff,// status.storage.operationMode = .freezeProtection,
      status.storage.charge > parameter.dischargeToTurbine,
      status.storage.heat < 1 * parameter.heatdiff * heat.demand.megaWatt
    { // added dicharge only after peak hours
      // previous discharge condition commented:
      // if storage.heatrel > parameter.dischargeToTurbine
      // && storage.operationMode != .freezeProtection
      // && heatdiff < -1 * parameter.heatdiff * thermal.demand {
      // Discharge directly!! // 04.07.0 -0.25&& heatdiff < -0.25 * thermal.dem
      if status.powerBlock.designMassFlow < status.solarField.massFlow {
        // there are cases, during cloudy days when mode .discharge although
        // massflow in SOF is higher that in PB.
      }
      var supply: Power
      var parasitics: Power
      status.storage.operationMode = .discharge
      (supply, parasitics) = Storage.perform(
        storage: &status.storage,
        solarField: &status.solarField,
        steamTurbine: &status.steamTurbine,
        powerBlock: &status.powerBlock,
        heat: &heat
      )
      
      if [.operating, .freezeProtection]
        .contains(status.solarField.operationMode)
      {
        status.powerBlock.temperature.inlet =
          SolarField.parameter.HTF.mixingTemperature(status.solarField, status.storage)

        status.powerBlock.massFlow = status.solarField.massFlow
        status.powerBlock.massFlow += status.storage.massFlow
        status.powerBlock.massFlow.adjust(factor: parameter.heatExchangerEfficiency)
        
      } else if status.storage.massFlow.isNearZero == false {
        
        status.powerBlock.inletTemperature(outlet: status.storage)

        status.powerBlock.massFlow = status.storage.massFlow
        status.powerBlock.massFlow.adjust(factor: parameter.heatExchangerEfficiency)
      } else {
        status.powerBlock.massFlow = .init() // set to zero
      }
      heat.storage = supply
      fuelConsumption.heater = 0
      electricalParasitics.storage = parasitics.megaWatt
      return
    }

    // heat can only be provided with heater on
    if (parameter.FC == 0 && DateTime.current.isNighttime
      && status.storage.charge < parameter.chargeTo
      && status.powerBlock.inletTemperature > 665
      && Storage.isFossilChargingAllowed(at: time)
      && OperationRestriction.fuelStrategy.isPredefined == false)
 //     || (OperationRestriction.fuelStrategy.isPredefined && fuelAvailable > 0)
    {
      //#warning("Check this")
      status.heater.operationMode = .freezeProtection(1.0)

      if OperationRestriction.fuelStrategy.isPredefined == false {
      //  fuelAvailable = .infinity
      }
      status.heater.temperature.inlet = status.powerBlock.temperature.inlet
      let energy = status.heater(
        storage: status.storage.massFlow,
        mode: status.storage.operationMode,
        demand: heat.demand.megaWatt,
        fuelAvailable: fuelAvailable, heat: heat
      )
      fuel = energy.fuel
      heat.heater.megaWatt = energy.heat
      electricalParasitics.heater = energy.electric
      
      status.powerBlock.designMassFlow = status.heater.massFlow

      status.storage.operationMode = .freezeProtection
    } else if case .freezeProtection = status.solarField.operationMode,
      status.storage.charge > 0.35 && parameter.FP == 0
    {
      status.storage.operationMode = .freezeProtection
    
    (supply, parasitics) = Storage.perform(
      storage: &status.storage,
      solarField: &status.solarField,
      steamTurbine: &status.steamTurbine,
      powerBlock: &status.powerBlock,
      heat: &heat
    )
    
    status.powerBlock.inletTemperature(outlet: status.storage)
    heat.storage = supply
    fuelConsumption.heater = fuel
    electricalParasitics.storage = parasitics.megaWatt
    } else {
      status.storage.operationMode = .noOperation
    }
      
    // check why to circulate HTF in SF
    //#warning("Storage.parasitics")
  // FIXME  plant.electricalParasitics.solarField = SolarField.parameter.antiFreezeParastics

  }
}
