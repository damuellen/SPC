//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import DateExtensions
import Units

/// A namespace for the main routines of the simulation.
public struct Plant {

  var heatFlow = ThermalEnergy()

  var electricity = ElectricPower()

  var fuelConsumption = FuelConsumption()

  var electricalParasitics = Parasitics()

  public static let initialState = Status()

  var performance: PlantPerformance { .init(self) }

  mutating func perform(_ status: inout Status, ambient: Temperature) {

    func demandStorageStrategy() -> Double {
      switch Storage.parameter.strategy {
      case .demand:
        return SteamTurbine.parameter.power.max
      case .shifter:
        return SteamTurbine.parameter.power.max * GridDemand.current.ratio
      case .always:
        return electricity.demand
      }
    }

    func constraintLoad(_ steamTurbine: inout SteamTurbine) -> Double? {
      guard steamTurbine.load < Availability.current.value.powerBlock
        else { return nil }

      status.steamTurbine.load = Availability.current.value.powerBlock
      // The turbine load has changed recalculation of efficiency
      let (_, efficiency) = SteamTurbine.perform(
        load: status.steamTurbine.load,
        heatExchanger: status.heatExchanger.temperature.inlet,
        ambient: ambient
      )

      return min(
        SteamTurbine.parameter.power.max * steamTurbine.load.quotient / efficiency,
        HeatExchanger.parameter.heatFlowHTF)
    }

    func powerBlockElectricalParasitics(_ efficiency: Double)
      -> (powerBlock: Double, shared: Double)
    {
      let energy =
        heatFlow.production.megaWatt - SteamTurbine.parameter.power.max
        / efficiency

      let powerBlock = PowerBlock.parasitics(
        heat: energy, steamTurbine: status.steamTurbine, temperature: ambient
      )
      let parasitics = PowerBlock.parameter.electricalParasiticsShared
      if heatFlow.production.watt == 0 {  // added to separate shared facilities parasitics
        return (powerBlock, parasitics[0])
      } else {
        return (powerBlock, parasitics[1])
      }
    }

    let minLoad = SteamTurbine.minLoad(atTemperature: ambient)
    let minPower = SteamTurbine.minPower(atTemperature: ambient)

    var deviation: Double
    var parasiticsAssumed = electricity.estimateDemand()

    if Design.hasStorage {
      electricity.demand = demandStorageStrategy()
    }

    var step = 0
    var factor = 0.0
    // Iteration to account for correct parasitics
    Iteration: repeat {
      step += 1
      factor = Double(step / 10) + 1

      let loadForDemand =
        (electricity.demand - Design.layout.gasTurbine)
        / SteamTurbine.parameter.power.max

      status.steamTurbine.load = Ratio(loadForDemand)
      // The turbine load has changed recalculation of efficiency
      var (_, efficiency) = SteamTurbine.perform(
        load: status.steamTurbine.load,
        heatExchanger: status.heatExchanger.temperature.inlet,
        ambient: ambient
      )
      // The required thermal power to meet the electricity demand
      heatFlow.demand.megaWatt = min(
        (electricity.demand / efficiency),
        HeatExchanger.parameter.heatFlowHTF)

      /*  heatFlow.demand.megaWatt =
        (constraintLoad(&steamTurbine) ?? heatFlow.demand.megaWatt
        / Simulation.adjustmentFactor.heatLossH2O)
        / HeatExchanger.parameter.efficiency*/

      if Design.hasSolarField {
        // Calculation of the heat supplied by the solar field
        heatFlow.solarProduction(status.solarField)
        status.powerBlock.massFlow(from: status.solarField)
      }

      // Attempt to use the heat exchanger
      status.powerBlock.temperatureOutlet(
        heatExchanger: &status.heatExchanger,
        mode: status.storage.operationMode
      )

      if Design.hasStorage {
        // Heat flow rate of storage
        heatFlow = status.storage.demandStrategy(
          powerBlock: &status.powerBlock,
          heatFlow: heatFlow
        )
      }

      // Check if heating is necessary
      checkForFreezeProtection(
        heater: &status.heater,
        storage: status.storage,
        solarField: status.solarField
      )

      if case .freezeProtection = status.heater.operationMode {
        status.powerBlock.outletTemperature(output: status.heater)
      }
      // Find the right temperature for inlet and outlet of powerblock
      powerBlockTemperature(&status, ambient: ambient)

      heatFlow.production = heatFlow.heatExchanger + heatFlow.wasteHeatRecovery
      /// Therm heat demand is lower after HX
      heatFlow.demand.watt *= HeatExchanger.parameter.efficiency
      /// Unavoidable losses in Power Block
      heatFlow.production.watt *= Simulation.adjustmentFactor.heatLossH2O

      if Design.hasBoiler { update(boiler: &status.boiler) }

      status.steamTurbine.load = max(status.steamTurbine.load, minLoad)

      (_, efficiency) = SteamTurbine.perform(
        load: status.steamTurbine.load,
        heatExchanger: status.heatExchanger.temperature.inlet,
        ambient: ambient
      )

      if heatFlow.production.megaWatt < minPower / efficiency {
        heatFlow.production = 0.0
        /*  debugPrint("""
         \(DateTime.current)
         "Damping (SteamTurbine underload): \(heatFlow.production.megaWatt) MWH,th.
         """)*/
      }
      // Electrical gross power of steam turbine
      electricity.steamTurbineGross = status.steamTurbine(
        heatFlow: heatFlow,
        heater: status.heater,
        heatExchanger: status.heatExchanger,
        temperature: ambient
      )

      if case .startUp(_, _) = status.steamTurbine.operationMode {
        heatFlow.startUp = heatFlow.heatExchanger
      } else {
        heatFlow.startUp = .zero
      }

      if OperationRestriction.fuelStrategy.isPredefined {
        let steamTurbine = SteamTurbine.parameter.power.max
        if fuelConsumption.combined > 0
          && electricity.steamTurbineGross
            > steamTurbine + 1
        {
          electricity.steamTurbineGross = steamTurbine + 1
        }
        if fuelConsumption.combined > 0, heatFlow.solar.watt > 0,
          electricity.steamTurbineGross > steamTurbine - 1
        {
          electricity.steamTurbineGross = steamTurbine - 1
        }
      }

      electricity.gross = electricity.steamTurbineGross
      electricity.gross += electricity.gasTurbineGross

      let (powerBlock, shared) = powerBlockElectricalParasitics(efficiency)
      electricalParasitics.powerBlock = powerBlock
      electricalParasitics.shared = shared
      electricity.totalize(parasitics: electricalParasitics)

      deviation = abs(parasiticsAssumed - electricity.parasitics)
      parasiticsAssumed = electricity.parasitics
      assert(step < 4, "Too many iterations")
      if heatFlow.production.isZero { break }
    } while deviation > Simulation.parameter.electricalTolerance * factor
  }

  private mutating func account(heater: Heater.Consumptions) {
    fuelConsumption.heater = heater.fuel
    heatFlow.heater.megaWatt = heater.heatFlow
    electricalParasitics.heater = heater.electric
  }

  private mutating func checkForFreezeProtection(
    heater: inout Heater, storage: Storage, solarField: SolarField
  ) {
    // if [.normal, .reheat].contains(heater.operationMode) { return }
    let freezeTemperature = SolarField.parameter.HTF.freezeTemperature

    if solarField.header.temperature.outlet < freezeTemperature
      + Simulation.parameter.dfreezeTemperatureHeat,
      storage.massFlow.isZero
    {  // No freeze protection heater use anymore if storage is in operation
      heater.massFlow(from: solarField)

      heater.operationMode = .freezeProtection(1.0)

      let consumptions = heater(
        storage: storage.massFlow,
        mode: storage.operationMode,
        heatFlow: heatFlow
      )

      account(heater: consumptions)
    }

    if solarField.minTemperature > freezeTemperature.kelvin
      + Simulation.parameter.dfreezeTemperatureHeat
    {
      heater.operationMode = .noOperation

      let consumptions = heater(
        storage: storage.massFlow,
        mode: storage.operationMode,
        heatFlow: heatFlow
      )

      account(heater: consumptions)
    }
  }

  private mutating func powerBlockTemperature(
   _ status: inout Status, ambient: Temperature
  ) {
    let tolerance = Simulation.parameter.tempTolerance

    Iteration: while true {
      if Design.hasStorage {
        // Demand for operation of the storage
        heatFlow.toStorage = status.storage.chargeOrDischarge(heatFlow.storage)

        determineStorageMode(&status)

        let parasitics: Power
        (heatFlow.storage, parasitics) = Storage.perform(
          storage: &status.storage,
          solarField: &status.solarField,
          steamTurbine: &status.steamTurbine,
          powerBlock: &status.powerBlock,
          heatFlow: &heatFlow
        )

        electricalParasitics.storage = parasitics.megaWatt

        let solarField = status.solarField.operationMode
        let storage = status.storage.operationMode
        // Adjustment of the powerblock mass flow
        switch (solarField, storage) {
          case (.track, .discharge), (.defocus(_), .discharge):
            status.powerBlock.heatTransfer(from: status.solarField, and: status.storage)
          case (_, .discharge):
            status.powerBlock.massFlow(from: status.storage)
          case (_, .charge):
            status.powerBlock.massFlow =
              status.solarField.massFlow - status.storage.massFlow
          case (_, _): break
        }

        status.powerBlock.massFlow.adjust(factor:
          Storage.parameter.heatExchangerEfficiency
        )
        // recalculate thermal power given by TES
        status.storage.recalculate(&heatFlow.storage)
      }

      if Design.hasHeater {
        update(
          heater: &status.heater,
          solarField: &status.solarField,
          powerBlock: &status.powerBlock,
          steamTurbine: &status.steamTurbine,
          storage: &status.storage
        )
      }

      if status.powerBlock.temperature.inlet
        < HeatExchanger.parameter.temperature.htf.inlet.min
        || status.powerBlock.massFlow == .zero // status.storage.operationMode.isFreezeProtection
      {
        if status.heater.operationMode.isFreezeProtection == false {
          status.powerBlock.temperatureLoss(
            for: Simulation.time.steps.interval,
            wrt: status.solarField, status.storage
          )
        }
        heatFlow.production = .zero
        heatFlow.heatExchanger = .zero
        status.heatExchanger.massFlow = .zero

        break Iteration
      }

      status.heatExchanger.massFlow(in: status.powerBlock)

      heatFlow.heatExchanger.megaWatt = status.heatExchanger(
        load: status.steamTurbine.load,
        storage: status.storage
      )

      status.powerBlock.outletTemperature(output: status.heatExchanger)

      if Design.hasGasTurbine, Design.hasStorage,
        heatFlow.heatExchanger.megaWatt > HeatExchanger.parameter.heatFlowHTF
      {
        heatFlow.dumping.megaWatt += heatFlow.heatExchanger.megaWatt
          - HeatExchanger.parameter.heatFlowHTF

        heatFlow.heatExchanger.megaWatt = HeatExchanger.parameter.heatFlowHTF
      }

      if abs(status.powerBlock.outlet - status.heatExchanger.outlet)
        < tolerance
      {
        break Iteration
      }

      status.powerBlock.outletTemperature(output: status.heatExchanger)
    }
  }

  // MARK: - Heater

  private mutating func update(
    heater: inout Heater,
    solarField: inout SolarField,
    powerBlock: inout PowerBlock,
    gasTurbine: GasTurbine,
    storage: inout Storage
  ) {
    if case .pure = gasTurbine.operationMode {
      // Plant updates in Pure CC Mode now again without RH!!
      // demand * WasteHeatRecovery.parameter.effPure * (1 / gasTurbine.efficiency- 1))
      // heat supplied by the WHR system

    } else if case .integrated = gasTurbine.operationMode {
      // Plant does not update in Pure CC Mode
      let power =
        electricity.gasTurbineGross
        * (1 / GasTurbine.efficiency(at: gasTurbine.load) - 1)
        * WasteHeatRecovery.parameter.efficiencyNominal
        / WasteHeatRecovery.parameter.ratioHTF
      /// necessary HTF share
      let _ = heatFlow.production.megaWatt - power

      heater.inletTemperature(output: powerBlock)
      let consumptions = heater(
        storage: storage.massFlow,
        mode: storage.operationMode,
        heatFlow: heatFlow
      )

      account(heater: consumptions)

      powerBlock.heatTransfer(from: heater)
    } else if case .noOperation = gasTurbine.operationMode {
      // GasTurbine does not update at all (Load<Min?)
      heater.inletTemperature(output: solarField)
      let consumptions = heater(
        storage: storage.massFlow,
        mode: storage.operationMode,
        heatFlow: heatFlow
      )

      account(heater: consumptions)

      powerBlock.heatTransfer(from: solarField, and: heater)
    }
  }

  private mutating func update(
    heater: inout Heater,
    solarField: inout SolarField,
    powerBlock: inout PowerBlock,
    steamTurbine: inout SteamTurbine,
    storage: inout Storage
  ) {
    if Design.hasStorage {

      if heatFlow.balance < .zero,
        storage.relativeCharge < Storage.parameter.dischargeToTurbine,
        storage.relativeCharge > Storage.parameter.dischargeToHeater
      {
        // Direct Discharging to SteamTurbine
        var parasitics: Power
        if Availability.fuel > .zero {  // Fuel available, Storage for Pre-Heating
          storage.operationMode = .preheat

          (heatFlow.storage, parasitics) = Storage.perform(
            storage: &storage,
            solarField: &solarField,
            steamTurbine: &steamTurbine,
            powerBlock: &powerBlock,
            heatFlow: &heatFlow
          )

          heater.inletTemperature(output: storage)

          heater.operationMode = .unknown

          //let heatDiff = heatFlow.production.megaWatt + heatFlow.storage.megaWatt - heatFlow.demand.megaWatt

          let consumptions = heater(
            storage: storage.massFlow,
            mode: storage.operationMode,
            heatFlow: heatFlow
          )

          account(heater: consumptions)
        } else {  // No Fuel Available -> Discharge directly with reduced TB load
          storage.operationMode = .discharge(load: steamTurbine.load)

          (heatFlow.storage, parasitics) = Storage.perform(
            storage: &storage,
            solarField: &solarField,
            steamTurbine: &steamTurbine,
            powerBlock: &powerBlock,
            heatFlow: &heatFlow
          )

          powerBlock.heatTransfer(from: solarField, and: storage)
        }  // STORAGE: dischargeToHeater < Qrel < dischargeToTurbine; Fuel/NoFuel

        electricalParasitics.storage = parasitics.megaWatt

      } else if heatFlow.balance < .zero,  //heater.operationMode != .freezeProtection,
        storage.relativeCharge < Storage.parameter.dischargeToHeater
      {
      //  heatDiff =
       //   (heatFlow.production + heatFlow.wasteHeatRecovery).megaWatt
      //    / HeatExchanger.parameter.efficiency
      //    - GridDemand.current.ratio * heatFlow.demand.megaWatt
        // added to avoid heater use is storage is selected and checkbox marked:
        if heatFlow.production.isZero, Heater.parameter.onlyWithSolarField {
          // use heater only in parallel with solar field and not as stand alone.
          // heatdiff = 0
          // commented to use gas not only in parallel to SF (for AH1)
        //  heatDiff = 0
        }

        heater.inletTemperature(output: solarField)

        let consumptions = heater(
          storage: storage.massFlow,
          mode: storage.operationMode,
          heatFlow: heatFlow
        )

        account(heater: consumptions)

        powerBlock.heatTransfer(from: solarField, and: heater)
      }

    } else {
   //   heatDiff =
     //   (heatFlow.production + heatFlow.wasteHeatRecovery).megaWatt
     //   / HeatExchanger.parameter.efficiency - heatFlow.demand.megaWatt

      if heatFlow.production.watt == 0 {
        // use heater only in parallel with solar field and not as stand alone.
      //  if Heater.parameter.onlyWithSolarField { heatDiff = 0 }
      }

      heater.inletTemperature(output: solarField)

      let consumptions = heater(
        storage: storage.massFlow,
        mode: storage.operationMode,
        heatFlow: heatFlow
      )

      account(heater: consumptions)

      powerBlock.heatTransfer(from: solarField, and: heater)
    }

    if heater.massFlow.isZero == false {
      heatFlow.production.kiloWatt = powerBlock.massFlow.rate * powerBlock.heat
    }
  }

  // MARK: - Boiler

  private mutating func account(boiler: Boiler.Consumptions) {
    fuelConsumption.heater = boiler.fuel
    heatFlow.heater.megaWatt = boiler.heatFlow
    electricalParasitics.heater = boiler.electric
  }

  private mutating func update(boiler: inout Boiler) {
    var Qsf_load: Double

    let adjustmentFactor = Simulation.adjustmentFactor

    let efficiency = SteamTurbine.parameter.efficiencyNominal

    if case .solarOnly = Control.whichOptimization {

      if heatFlow.production.megaWatt < adjustmentFactor.efficiencyHeater,
        heatFlow.production.megaWatt >= adjustmentFactor.efficiencyBoiler
      {
        switch boiler.operationMode {
        case .startUp, .SI, .NI: break
        default: boiler.operationMode = .unknown
        }

        if Boiler.parameter.booster {  // booster superheater

          if heatFlow.heater.megaWatt == Design.layout.heater {
            Qsf_load = 0.769
          } else {
            Qsf_load =
              heatFlow.production.megaWatt
              / (Design.layout.heatExchanger / efficiency)
          }
        }
        // H2OinBO.temperature.inlet = H2OinPB.temperature.outlet
      } else {
        boiler.operationMode = .noOperation(hours: 0)
      }
    }

    if heatFlow.heater.megaWatt == Design.layout.heater {
      Qsf_load = 0.769
    } else {
      Qsf_load = heatFlow.production.megaWatt
      / (Design.layout.heatExchanger / efficiency)
    }

    let consumptions = boiler(
      demand: heatFlow.balance.megaWatt,
      Qsf_load: Qsf_load
    )

    account(boiler: consumptions)

    // predefined fuel consumption in *.pfc-file
    if OperationRestriction.fuelStrategy.isPredefined {
      if (heatFlow.heatExchanger.megaWatt + heatFlow.boiler.megaWatt) > 110 {
        heatFlow.boiler.megaWatt = 105 - heatFlow.heatExchanger.megaWatt
      }

      heatFlow.production =
        (heatFlow.heatExchanger + heatFlow.wasteHeatRecovery)
        * adjustmentFactor.heatLossH2O + heatFlow.boiler
    }
  }

  mutating func determineStorageMode(_ status: inout Status) {
    let parameter = Storage.parameter
    let summerMonths = Storage.parameter.exception
    let time = DateTime.current
    // energy can only be provided with heater on
    if (parameter.fossilCharging && DateTime.current.isNighttime
      && status.storage.relativeCharge < parameter.chargeTo
      && status.powerBlock.inlet > 665
      && Storage.isFossilChargingAllowed(at: time)
      && OperationRestriction.fuelStrategy.isPredefined == false)
   // ||(OperationRestriction.fuelStrategy.isPredefined && fuelAvailable > 0)
    {
      //#warning("Check this")
      status.heater.operationMode = .freezeProtection(1.0)

      if OperationRestriction.fuelStrategy.isPredefined == false {
      //  fuelAvailable = .infinity
      }
      status.heater.inletTemperature(input: status.powerBlock)

      let consumptions = status.heater(
        storage: status.storage.massFlow,
        mode: status.storage.operationMode,
        heatFlow: heatFlow
      )

      account(heater: consumptions)

      status.powerBlock.massFlow = status.heater.massFlow

      status.storage.operationMode = .freezeProtection
    }

    if status.solarField.operationMode.isFreezeProtection,
      status.storage.relativeCharge > 0.35, parameter.freezeProtection
    {
      status.storage.operationMode = .freezeProtection
    }

    if case .charge = status.storage.operationMode,
      status.solarField.massFlow < HeatExchanger.designMassFlow
    {
      status.storage.operationMode = .noOperation
    }

    if case .discharge = status.storage.operationMode,
      -heatFlow.storage.megaWatt < 1 * parameter.heatdiff * heatFlow.demand.megaWatt
    {
      status.storage.operationMode = .noOperation
    }

    if case .discharge = status.storage.operationMode {
      // check when to discharge TES
      if case .shifter = parameter.strategy {
        if (summerMonths.contains(time.month)
          && time.hour < parameter.dischargeSummer)
          || time.hour < parameter.dischargeWinter {
          status.storage.operationMode = .noOperation
        }
      }
    }
    // check why to circulate HTF in SF
    //#warning("Storage.parasitics")
  // FIXME  plant.electricalParasitics.solarField = SolarField.parameter.antiFreezeParastics
  }
}
