// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import DateExtensions
import Units

/**
 A namespace for the main routines of the simulation.

 The `Plant` struct contains the core functionalities for simulating the behavior of a power plant or energy system. It takes into consideration various factors such as thermal and electrical parasitics, available power, efficiency, and the behavior of different components. The simulation aims to achieve the desired electrical demand while operating within specific constraints.

 The main function of the simulation is performed by the `perform` method. It takes the current status of the power plant or energy system and the ambient temperature as input parameters. The simulation iteratively calculates the behavior of the system until the electrical parasitics converge within a certain tolerance level. The number of iterations is limited to prevent excessive looping.

 The simulation process involves the following steps:

 1. Calculates the load required to meet the electrical demand based on the provided ambient temperature and the available power of the steam turbine.
 2. Calculates the required thermal power to meet the electricity demand.
 3. If there is a solar field, calculates the heat supplied by the solar field and updates the power block's mass flow accordingly.
 4. Attempts to use the heat exchanger and calculates the outlet temperature of the power block.
 5. If there is a storage system, calculates the heat flow rate of the storage.
 6. Checks if heating is necessary and performs freeze protection if required.
 7. Determines the right temperature for the inlet and outlet of the power block.
 8. Calculates heat flows, thermal demands, and efficiency factors.
 9. Integrates the boiler if available.
 10. Adjusts the steam turbine load based on constraints and updates the efficiency accordingly.
 11. Calculates the gross electrical power of the steam turbine.
 12. Considers predefined operation restrictions on the fuel strategy if applicable.
 13. Calculates the total electrical parasitics of the power block and updates the electrical demand.

 The simulation continues in an iterative manner until the electrical parasitics converge within a certain tolerance level. The tolerance level is influenced by the ambient temperature, and the number of iterations is limited to prevent excessive processing.

 The simulation process is supported by helper functions such as `powerBlockElectricalParasitics`, which calculates the electrical parasitics of the power block.

 The `determineStorageMode` function is used to determine the storage mode based on certain conditions and constraints. The electricity demand storage strategy is determined by the `demandStorageStrategy` function, which calculates the demand based on the storage strategy defined in the `Storage.parameter`.

 The `integrate` functions are used to integrate various components such as the heater, solar field, power block, steam turbine, and storage system, depending on their operation modes and states. The integration process involves updating the energy flows and performing calculations based on the current status of the system.

 This simulation is designed to efficiently evaluate the behavior of power plants or energy systems, considering various factors and constraints, to achieve the desired electrical demand while optimizing efficiency and minimizing parasitic losses.
 */
struct Plant {
  /// Represents the thermal energy flow in the system.
  var heatFlow = ThermalEnergy()
  /// Represents the electrical power generation and consumption in the system.
  var electricity = ElectricPower()
  /// Tracks the fuel consumption in the system.
  var fuelConsumption = FuelConsumption()
  /// Represents the electrical parasitics in the system.
  var electricalParasitics = Parasitics()

  /// Initial state of the simulation
  public static let initialState = Status()
  /// Provides access to the plant's performance
  var performance: PlantPerformance { .init(self) }

  /// This function is the core of the power plant simulation. It iteratively simulates
  /// the behavior of the system to achieve the desired electrical demand while
  /// considering various factors such as thermal and electrical parasitics,
  /// efficiency, and the behavior of different components.
  ///
  /// - Parameters:
  ///   - status: The current status of the power plant, which contains information about various components and their states.
  ///   - ambient: The ambient temperature at which the simulation is being performed.
  mutating func perform(_ status: inout Status, ambient: Temperature) {
    /// A helper function to calculate load capacity for the steam turbine based on certain conditions.
    func loadCapacity(steamTurbine: inout SteamTurbine) -> Double? {
      guard steamTurbine.load < Availability.current.value.powerBlock
        else { return nil }

      // The turbine load has changed recalculation of efficiency
      steamTurbine.efficiency(
        heatExchanger: status.heatExchanger.temperature.inlet,
        ambient: ambient
      )

      return min(
        SteamTurbine.parameter.power.max 
          * steamTurbine.load.quotient / steamTurbine.efficiency.quotient,
        HeatExchanger.parameter.heatFlowHTF)
    }
    func powerBlockElectricalParasitics(_ efficiency: Ratio)
      -> (powerBlock: Double, shared: Double)
    {
      let energy =
        heatFlow.production.megaWatt - SteamTurbine.parameter.power.max
        / efficiency.quotient

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

    /// A variable to store the deviation during the iteration process
    var deviation: Double
    /// Estimate of electrical parasitics
    var parasiticsAssumed = electricity.estimateDemand()

    if Design.hasStorage {
      /// Setting electricity demand based on storage strategy
      electricity.demand = demandStorageStrategy()
    }

    var step = 0
    var factor = 0.0
    // Iteration to account for correct parasitics
    Iteration: repeat {
      // The simulation iteration process starts here.
      step += 1
      factor = Double(step / 10) + 1
      if heatFlow.heatExchanger.isZero == false {
        let loadForDemand = max(minLoad,
          Ratio((electricity.demand - Design.layout.gasTurbine)
          / SteamTurbine.parameter.power.max))

        status.steamTurbine.load = min(loadForDemand, Availability.current.value.powerBlock)
        // The turbine load has changed recalculation of efficiency
        status.steamTurbine.efficiency(
          heatExchanger: status.heatExchanger.temperature.inlet,
          ambient: ambient
        )
      }
      // The required thermal power to meet the electricity demand
      heatFlow.demand.megaWatt = min(
        (electricity.demand / status.steamTurbine.efficiency.quotient),
        HeatExchanger.parameter.heatFlowHTF)
    
      if Design.hasSolarField {
        // Calculation of the heat supplied by the solar field
        heatFlow.solarProduction(status.solarField)
        status.powerBlock.massFlow = status.solarField.massFlow
        status.powerBlock.inletTemperature(outlet: status.solarField)
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
        integrate(
          heater: &status.heater,
          solarField: &status.solarField,
          powerBlock: &status.powerBlock,
          steamTurbine: &status.steamTurbine,
          storage: &status.storage
        )
      }

      // Check if heating is necessary
      checkForFreezeProtection(
        heater: &status.heater,
        storage: status.storage,
        solarField: status.solarField
      )

      if case .freezeProtection = status.heater.operationMode {
        status.powerBlock.temperature.outlet = status.heater.temperature.outlet
      }
      // Find the right temperature for inlet and outlet of powerblock
      powerBlockTemperature(&status, ambient: ambient)

      heatFlow.production = heatFlow.heatExchanger + heatFlow.wasteHeatRecovery
      /// Therm heat demand is lower after HX
      heatFlow.demand.watt *= HeatExchanger.parameter.efficiency
      /// Unavoidable losses in Power Block
      heatFlow.production.watt *= Simulation.adjustmentFactor.heatLossH2O

      if Design.hasBoiler { integrate(boiler: &status.boiler) }

      if heatFlow.production.megaWatt < minPower / status.steamTurbine.efficiency.quotient {
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

      if case .startUp = status.steamTurbine.operationMode {
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

      let (powerBlock, shared) = powerBlockElectricalParasitics(status.steamTurbine.efficiency)
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
      + Simulation.parameter.deltaFreezeTemperatureHeat,
      storage.massFlow.isZero
    {  // No freeze protection heater use anymore if storage is in operation
      heater.adjust(massFlow: solarField)

      heater.change(mode: .freezeProtection(1.0))

      let consumptions = heater(
        storage: storage.massFlow,
        mode: storage.operationMode,
        heatFlow: heatFlow
      )

      account(heater: consumptions)
    }

    if solarField.minTemperature > freezeTemperature.kelvin
      + Simulation.parameter.deltaFreezeTemperatureHeat
    {
      heater.change(mode: .noOperation)

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
          status.powerBlock.massFlow = status.storage.massFlow
          status.powerBlock.inletTemperature(outlet: status.storage)
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
      integrate(
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

      return
    }

    status.heatExchanger.massFlow = status.powerBlock.massFlow
    status.heatExchanger.inletTemperature(inlet: status.powerBlock)

    heatFlow.heatExchanger.megaWatt = status.heatExchanger(
      load: status.steamTurbine.load,
      storage: status.storage
    )
    status.powerBlock.temperature = status.heatExchanger.temperature

    if Design.hasGasTurbine, Design.hasStorage,
      heatFlow.heatExchanger.megaWatt > HeatExchanger.parameter.heatFlowHTF
    {
      heatFlow.dumping.megaWatt += heatFlow.heatExchanger.megaWatt
        - HeatExchanger.parameter.heatFlowHTF

      heatFlow.heatExchanger.megaWatt = HeatExchanger.parameter.heatFlowHTF
    }
  }

  // MARK: - Heater

  private mutating func integrate(
    heater: inout Heater,
    solarField: inout SolarField,
    powerBlock: inout PowerBlock,
    storage: inout Storage,
    gasTurbine: GasTurbine
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

      heater.inletTemperature(outlet: powerBlock)
      let consumptions = heater(
        storage: storage.massFlow,
        mode: storage.operationMode,
        heatFlow: heatFlow
      )

      account(heater: consumptions)

      powerBlock.heatTransfer(from: heater)
    } else if case .noOperation = gasTurbine.operationMode {
      // GasTurbine does not update at all (Load<Min?)
      heater.inletTemperature(outlet: solarField)
      let consumptions = heater(
        storage: storage.massFlow,
        mode: storage.operationMode,
        heatFlow: heatFlow
      )

      account(heater: consumptions)

      powerBlock.heatTransfer(from: solarField, and: heater)
    }
  }

  private mutating func integrate(
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

          heater.inletTemperature(outlet: storage)

          heater.change(mode: .unknown)

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

        heater.inletTemperature(outlet: solarField)

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

      heater.inletTemperature(outlet: solarField)

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

  private mutating func integrate(boiler: inout Boiler) {
    var Qsf_load: Double

    let adjustmentFactor = Simulation.adjustmentFactor

    let efficiency = SteamTurbine.parameter.efficiencyNominal

    if case .solarOnly = Control.whichOptimization {

      if heatFlow.production.megaWatt < adjustmentFactor.efficiencyHeater,
        heatFlow.production.megaWatt >= adjustmentFactor.efficiencyBoiler
      {
        switch boiler.operationMode {
        case .startUp, .SI, .NI: break
        default: boiler.change(mode: .unknown)
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
        boiler.change(mode: .noOperation(hours: 0))
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

  /// A helper function to determine the electricity demand storage strategy.
  /// Returns the calculated demand based on the strategy.
  private func demandStorageStrategy() -> Double {
    switch Storage.parameter.strategy {
    case .demand:
      return SteamTurbine.parameter.power.max
    case .shifter:
      return SteamTurbine.parameter.power.max * GridDemand.current.ratio
    case .always:
      return electricity.demand
    }
  }
  /// A function to determine the storage mode based on certain conditions.
  /// The function involves several condition checks and adjustments based on the status of the system.
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
      status.heater.change(mode: .freezeProtection(1.0))

      if OperationRestriction.fuelStrategy.isPredefined == false {
      //  fuelAvailable = .infinity
      }
      status.heater.inletTemperature(inlet: status.powerBlock)

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
