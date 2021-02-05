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

  var heatFlow = ThermalEnergy()

  var electricity = ElectricPower()

  var fuelConsumption = FuelConsumption()

  var electricalParasitics = Parasitics()

  public static let initialState = Status()

  var performance: Performance {
    Performance(
      thermal: heatFlow, electric: electricity,
      fuel: fuelConsumption, parasitics: electricalParasitics)
  }

  // MARK: - SolarField

  /// Calculation of the heat supplied by the solar field
  private mutating func perform(
    _ solarField: SolarField,
    _ collector: Collector,
    _ steamTurbine: SteamTurbine
  ) -> MassFlow {
    heatFlow.solar.kiloWatt = solarField.massFlow.rate * solarField.heat

    if heatFlow.solar > .zero {
      if case .startUp = steamTurbine.operationMode {
        heatFlow.startUp = heatFlow.solar
        heatFlow.production = .zero
      } else {
        heatFlow.startUp = .zero
        heatFlow.production = heatFlow.solar
      }
    } else if case .freezeProtection = solarField.operationMode {
      heatFlow.solar = .zero
      heatFlow.production = heatFlow.solar
    } else {
      heatFlow.production = heatFlow.solar
      heatFlow.production = .zero
      return .zero
    }
    return solarField.massFlow
  }

  // MARK: - PowerBlock

  mutating func perform(_ status: inout Status, ambient: Temperature) {

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

    func constraintLoad(_ steamTurbine: inout SteamTurbine) -> Double? {
      guard steamTurbine.load < Availability.current.value.powerBlock
        else { return nil }

      status.steamTurbine.load = Availability.current.value.powerBlock
      // The turbine load has changed recalculation of efficiency
      let (_, efficiency) = SteamTurbine.perform(
        status.steamTurbine.load, heatFlow,
        status.boiler.operationMode,
        status.gasTurbine.operationMode,
        status.heatExchanger.temperature.inlet,
        ambient)

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
        heat: energy, steamTurbine: status.steamTurbine,
        temperature: ambient
      )
      let parasitics = PowerBlock.parameter.electricalParasiticsShared
      if heatFlow.production.watt == 0 {  // added to separate shared facilities parasitics
        return (powerBlock, parasitics[0])
      } else {
        return (powerBlock, parasitics[1])
      }
    }

    let minLoad = SteamTurbine.minLoad(ambient: ambient)
    let minPower = SteamTurbine.minPower(ambient: ambient) 

    var deviation: Double
    var parasiticsAssumed = electricity.estimateDemand()
    var step = 0
    var factor = 0.0
    // Iteration to account for correct parasitics
    Iteration: repeat {
      step += 1
      factor = Double(step / 10) + 1
      electricity.estimateDemand()
      electricity.demand = demandStrategyStorage()

      let load =
        (electricity.demand - Design.layout.gasTurbine)
        / SteamTurbine.parameter.power.max

      status.steamTurbine.load = Ratio(load)
      // The turbine load has changed recalculation of efficiency
      var (_, efficiency) = SteamTurbine.perform(
        status.steamTurbine.load, heatFlow,
        status.boiler.operationMode, 
        status.gasTurbine.operationMode,
        status.heatExchanger.temperature.inlet,
        ambient
      )

      heatFlow.demand.megaWatt = min(
        (electricity.demand / efficiency),
        HeatExchanger.parameter.heatFlowHTF)

      /*  heatFlow.demand.megaWatt =
        (checkAvailability(&steamTurbine) ?? heatFlow.demand.megaWatt
        / Simulation.adjustmentFactor.heatLossH2O)
        / HeatExchanger.parameter.efficiency*/

      status.powerBlock.inletTemperature(outlet: status.solarField)

      status.powerBlock.temperatureOutlet(
        heatExchanger: &status.heatExchanger,
        mode: status.storage.operationMode
      )

      if Design.hasSolarField {
        status.solarField.massFlow = perform(
          status.solarField, status.collector, status.steamTurbine
        )
        status.powerBlock.massFlow = status.solarField.massFlow
      }

      if Design.hasStorage {
        heatFlow = Storage.demandStrategy(
          storage: &status.storage,
          powerBlock: &status.powerBlock,          
          heatFlow: heatFlow
        )
      }

      var heatDiff = powerBlockTemperature(&status, ambient: ambient)

      heatFlow.production = heatFlow.heatExchanger + heatFlow.wasteHeatRecovery
      /// Therm heat demand is lower after HX
      heatFlow.demand.watt *= HeatExchanger.parameter.efficiency
      /// Unavoidable losses in Power Block
      heatFlow.production.watt *= Simulation.adjustmentFactor.heatLossH2O

      if Design.hasBoiler { updateBoiler(&status.boiler, &heatDiff) }

      status.steamTurbine.load = max(status.steamTurbine.load, minLoad)

      (_, efficiency) = SteamTurbine.perform(
        status.steamTurbine.load, heatFlow,
        status.boiler.operationMode,
        status.gasTurbine.operationMode,
        status.heatExchanger.temperature.inlet, ambient
      )

      if heatFlow.production.megaWatt < minPower / efficiency {
        heatFlow.production = 0.0
        /*  debugPrint("""
         \(DateTime.current)
         "Damping (SteamTurbine underload): \(heatFlow.production.megaWatt) MWH,th.
         """)*/
      }

      electricity.steamTurbineGross = status.steamTurbine(
        heater: status.heater,
        modeBoiler: status.boiler.operationMode,
        modeGasTurbine: status.gasTurbine.operationMode,
        heatExchanger: status.heatExchanger,
        temperature: ambient, heatFlow: heatFlow
      )

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
    } while deviation > Simulation.parameter.electricalTolerance * factor
    
    if Design.hasStorage {
      // Calculate the operating state of the salt
      status.storage.calculate(thermal: &heatFlow.storage.megaWatt, status.powerBlock)
      status.storage.heatlosses()
    } 
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
        heatDiff: heatDiff,
        fuelAvailable: fuel,
        heatFlow: heatFlow
      )

      fuelConsumption.heater = energy.fuel
      heatFlow.heater.megaWatt = energy.heatFlow
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
        heatDiff: heatDiff,
        fuelAvailable: fuel,
        heatFlow: heatFlow
      )

      fuelConsumption.heater = energy.fuel
      heatFlow.heater.megaWatt = energy.heatFlow
      electricalParasitics.heater = energy.electric
    }
    
    if case .freezeProtection = heater.operationMode {
      powerBlock.outletTemperature(outlet: heater)
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

        let thermal = status.storage.massFlow.rate * abs(status.storage.heat) / 1_000

        heatFlow.storage.megaWatt = status.storage.calculate(thermal)

        if heatFlow.storage > .zero {  // Performance surplus
          if status.storage.relativeCharge < Storage.parameter.chargeTo,
            status.solarField.massFlow >= status.powerBlock.designMassFlow
          {  // 1.1
            heatFlow.production = heatFlow.solar
            heatFlow.production += heatFlow.storage
          } else {  // heat cannot be stored
            heatFlow.production -= heatFlow.storage
          }
        } else {  // Performance deficit
          heatFlow.production = heatFlow.solar
          heatFlow.production += heatFlow.storage
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
        || status.powerBlock.massFlow == .zero // status.storage.operationMode.isFreezeProtection
        || status.solarField.operationMode.isFreezeProtection
      {
        if status.heater.operationMode.isFreezeProtection == false {
          status.powerBlock.temperatureLoss(wrt: status.solarField, status.storage)
        }
        heatFlow.production = .zero
        heatFlow.heatExchanger = .zero
        status.heatExchanger.massFlow = .zero

        break Iteration
      }

      status.heatExchanger.massFlow = status.powerBlock.massFlow
      
      status.heatExchanger.setTemperature(inlet: status.powerBlock.temperature.inlet)

      heatFlow.heatExchanger.megaWatt = status.heatExchanger(
        load: status.steamTurbine.load,
        designMassFlow: status.powerBlock.designMassFlow,
        storage: status.storage
      )

      status.powerBlock.outletTemperature(outlet: status.heatExchanger)

      if Design.hasGasTurbine, Design.hasStorage,
        heatFlow.heatExchanger.megaWatt > HeatExchanger.parameter.heatFlowHTF
      {
        heatFlow.dumping.megaWatt += heatFlow.heatExchanger.megaWatt
          - HeatExchanger.parameter.heatFlowHTF

        heatFlow.heatExchanger.megaWatt = HeatExchanger.parameter.heatFlowHTF
      }

      if abs(status.powerBlock.outletTemperature - status.heatExchanger.outletTemperature)
        < tolerance
      {
        break Iteration
      }

      status.powerBlock.outletTemperature(outlet: status.heatExchanger)
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
      storage.relativeCharge < Storage.parameter.dischargeToTurbine,
      storage.relativeCharge > Storage.parameter.dischargeToHeater
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
          heatFlow: &heatFlow
        )

        heater.inletTemperature(outlet: storage)

        heater.operationMode = .unknown

        heatDiff =
          heatFlow.production.megaWatt
          + heatFlow.storage.megaWatt - heatFlow.demand.megaWatt

        let energy = heater(
          storage: storage.massFlow,
          mode: storage.operationMode,
          heatDiff: heatDiff,
          fuelAvailable: fuel,
          heatFlow: heatFlow
        )

        fuelConsumption.heater = energy.fuel
        heatFlow.heater.megaWatt = energy.heatFlow
        electricalParasitics.heater = energy.electric
      } else {  // No Fuel Available -> Discharge directly with reduced TB load
        storage.operationMode = .discharge
        (supply, parasitics) = Storage.perform(
          storage: &storage,
          solarField: &solarField,
          steamTurbine: &steamTurbine,
          powerBlock: &powerBlock,
          heatFlow: &heatFlow
        )

        powerBlock.formJoint(solarField, storage)
      }  // STORAGE: dischargeToHeater < Qrel < dischargeToTurbine; Fuel/NoFuel

      heatFlow.storage = supply

      electricalParasitics.storage = parasitics.megaWatt

    } else if heatDiff < .zero,  //heater.operationMode != .freezeProtection,
      storage.relativeCharge < Storage.parameter.dischargeToHeater
    {
      heatDiff =
        (heatFlow.production + heatFlow.wasteHeatRecovery).megaWatt
        / HeatExchanger.parameter.efficiency
        - GridDemand.current.ratio * heatFlow.demand.megaWatt
      // added to avoid heater use is storage is selected and checkbox marked:
      if heatFlow.production.watt == 0, Heater.parameter.onlyWithSolarField {
        // use heater only in parallel with solar field and not as stand alone.
        // heatdiff = 0
        // commented to use gas not only in parallel to SF (for AH1)
        heatDiff = 0
      }

      heater.inletTemperature(outlet: solarField)

      let energy = heater(
        storage: storage.massFlow,
        mode: storage.operationMode,
        heatDiff: heatDiff, 
        fuelAvailable: fuel,
        heatFlow: heatFlow
      )

      fuelConsumption.heater = energy.fuel
      heatFlow.heater.megaWatt = energy.heatFlow
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
      heatDiff = heatFlow.production.megaWatt - power

      heater.inletTemperature(inlet: powerBlock)

      let energy = heater(
        storage: storage.massFlow,
        mode: storage.operationMode,
        heatDiff: heatDiff, fuelAvailable: fuel, heatFlow: heatFlow
      )

      fuelConsumption.heater = energy.fuel
      heatFlow.heater.megaWatt = energy.heatFlow
      electricalParasitics.heater = energy.electric

      powerBlock.merge(heater)
    } else if case .noOperation = gasTurbine.operationMode {
      // GasTurbine does not update at all (Load<Min?)
      heater.inletTemperature(outlet: solarField)

      let energy = heater(
        storage: storage.massFlow,
        mode: storage.operationMode,
        heatDiff: heatDiff,
        fuelAvailable: fuel, heatFlow: heatFlow
      )

      fuelConsumption.heater = energy.fuel
      heatFlow.heater.megaWatt = energy.heatFlow
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
        (heatFlow.production + heatFlow.wasteHeatRecovery).megaWatt
        / HeatExchanger.parameter.efficiency - heatFlow.demand.megaWatt

      if heatFlow.production.watt == 0 {
        // use heater only in parallel with solar field and not as stand alone.
        if Heater.parameter.onlyWithSolarField { heatDiff = 0 }
      }

      heater.inletTemperature(outlet: solarField)

      let energy = heater(
        storage: storage.massFlow,
        mode: storage.operationMode,
        heatDiff: heatDiff, fuelAvailable: fuel, heatFlow: heatFlow
      )

      fuelConsumption.heater = energy.fuel
      heatFlow.heater.megaWatt = energy.heatFlow
      electricalParasitics.heater = energy.electric

      powerBlock.formJoint(solarField, heater)
    }

    if heater.massFlow.isNearZero == false {
      heatFlow.production.kiloWatt = powerBlock.massFlow.rate * powerBlock.heat
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

      if heatFlow.production.megaWatt < adjustmentFactor.efficiencyHeater,
        heatFlow.production.megaWatt >= adjustmentFactor.efficiencyBoiler
      {
        switch boiler.operationMode {
        case .startUp, .SI, .NI: break
        default: boiler.operationMode = .unknown
        }

        heatDiff = heatFlow.production.megaWatt - heatFlow.demand.megaWatt

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
      Qsf_load = heatFlow.production.megaWatt / (Design.layout.heatExchanger / efficiency)
    }

    let energy = boiler(demand: heatDiff, Qsf_load: Qsf_load, fuelAvailable: 0)

    heatFlow.boiler.megaWatt = energy.heatFlow
    fuelConsumption.boiler = energy.fuel
    electricalParasitics.boiler = energy.electric

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

  mutating func updateStorage(_ status: inout Status, fuelAvailable: Double) {    
    let parameter = Storage.parameter
    let summerMonths = Storage.parameter.exception
    let time = DateTime.current
    var parasitics: Power

    status.storage.chargeOrDischarge(heatFlow.storage)

    if case .charging = status.storage.operationMode, 
      status.solarField.massFlow < status.powerBlock.designMassFlow 
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
      if case .shifter = parameter.strategy { // only for Shifter
        if (summerMonths.contains(time.month) 
          && time.hour < parameter.dischargeSummer)
          || time.hour < parameter.dischargeWinter { 
          status.storage.operationMode = .noOperation
        }
      } 
    }

    if status.powerBlock.massFlow < status.powerBlock.designMassFlow {
  //    status.powerBlock.massFlow = status.powerBlock.designMassFlow 
      // there are cases, during cloudy days when mode .discharge although
      // massflow in SOF is higher that in PB.
    }

    if case .freezeProtection = status.solarField.operationMode,
      status.storage.relativeCharge > 0.35 && parameter.FP == 0
    {
      status.storage.operationMode = .freezeProtection
    }

    (heatFlow.storage, parasitics) = Storage.perform(
      storage: &status.storage,
      solarField: &status.solarField,
      steamTurbine: &status.steamTurbine,
      powerBlock: &status.powerBlock,
      heatFlow: &heatFlow
    )

    electricalParasitics.storage = parasitics.megaWatt

    if [.operating, .freezeProtection].contains(status.solarField.operationMode)
    {
     status.powerBlock.temperature.inlet =
        SolarField.parameter.HTF.mixingOutlets(status.solarField, status.storage)

      status.powerBlock.massFlow = status.solarField.massFlow
      status.powerBlock.massFlow += status.storage.massFlow
     // status.powerBlock.massFlow.adjust(factor: parameter.heatExchangerEfficiency)
      
    } else if status.storage.massFlow.isNearZero == false {
      
      status.powerBlock.inletTemperature(outlet: status.storage)

      status.powerBlock.massFlow = status.storage.massFlow
      status.powerBlock.massFlow.adjust(factor: parameter.heatExchangerEfficiency)
    } else {
      status.powerBlock.massFlow = .zero
    }

    // heat can only be provided with heater on
    if (parameter.FC == 0 && DateTime.current.isNighttime
      && status.storage.relativeCharge < parameter.chargeTo
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
      status.heater.inletTemperature(inlet: status.powerBlock)

      let energy = status.heater(
        storage: status.storage.massFlow,
        mode: status.storage.operationMode,
        heatDiff: heatFlow.demand.megaWatt,
        fuelAvailable: fuelAvailable, heatFlow: heatFlow
      )

      fuelConsumption.heater = energy.fuel
      heatFlow.heater.megaWatt = energy.heatFlow
      electricalParasitics.heater = energy.electric
      
      status.powerBlock.designMassFlow = status.heater.massFlow

      status.storage.operationMode = .freezeProtection
    } 
    
    // check why to circulate HTF in SF
    //#warning("Storage.parasitics")
  // FIXME  plant.electricalParasitics.solarField = SolarField.parameter.antiFreezeParastics

  }
}
