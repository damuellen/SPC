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
import Foundation
import Meteo

public enum Plant {

  static var availability = Availability.withDefaults()
  static var thermal = ThermalEnergy()
  private(set) static var fuelConsumption = FuelConsumption()
  private(set) static var electricalParasitics = Parasitics()

  private(set) static var electric = ElectricEnergy()
  private(set) static var location: Location!
  private(set) static var ambientTemperature = Temperature()
  static var gridDemand: Ratio = 1.0

  static let initialState = PerformanceData()

  static func setLocation(_ location: Location) {
    Plant.location = location
  }

  static func update(_ status: inout Plant.PerformanceData, meteo: MeteoData) {
    ambientTemperature = Temperature(celsius: meteo.temperature)
    let solarField = SolarField.parameter
    let steamTurbine = SteamTurbine.parameter
    let storage = Storage.parameter

    // storage.mass.hot = heatExchanger.temperature.h2o.inlet.max
    // storage.mass.cold = heatExchanger.temperature.h2o.inlet.min

    status.powerBlock.setTemperature(inlet:
      status.solarField.temperature.outlet
    )
    
    status.storage.salt.massFlow.cold.rate = storage.startLoad.cold
    status.storage.salt.massFlow.hot.rate = storage.startLoad.hot
    
    // storage.temperatureTank.hot = heatExchanger.temperature.h2o.outlet.max
    // storage.temperatureTank.cold = heatExchanger.temperature.h2o.outlet.max
    electricalParasitics.solarField = SolarField.parasitics(status.solarField)
    var electricalParasiticsAssumed: Double = 0.0
    if Design.hasGasTurbine {
      // for SEGS plant Demand is set to max SteamTurbine Power
      electric.demand = gridDemand.ratio
        * (Design.layout.powerBlock - Design.layout.gasTurbine)
      // Electric demand scc
      electricalParasiticsAssumed = electric.demand
        * Simulation.parameter.electricalParasitics
      // Iter. start val. for parasitics, 10% demand
      electric.demand += electricalParasiticsAssumed
    } else {
      electric.demand = gridDemand.ratio * steamTurbine.power.max
    }
    // Iteration to account for correct parasitics
    iteration(&status, meteo, goal: electricalParasiticsAssumed)

    if Design.hasStorage {
      thermal.storage.megaWatt = Storage.operate(
        storage: &status.storage,
        powerBlock: &status.powerBlock,
        steamTurbine: status.steamTurbine,
        thermal: thermal.storage.megaWatt,
        availability: availability
      )
    }
    
    /// Net electric power
    electric.net = electric.gross - electric.parasitics

    if electric.net < 0 {
      electric.consum = -electric.net
      electric.net = 0
    } else {
      electric.consum = 0
    }

    if Design.hasGasTurbine {
      electric.demand = gridDemand.ratio
        * (Design.layout.powerBlock - Design.layout.gasTurbine)
    } else {
      electric.demand = gridDemand.ratio * steamTurbine.power.max
    }

    if true /* Ctl.AS = 1 */ && thermal.solar.watt > 0 {
      // Average HTF temp. in loop [K]
      thermal.solar.watt = thermal.solar.watt
        + (1 - solarField.SSFHL / solarField.pipeHeatLosses)
        * SolarField.pipeHeatLoss(
          average: status.solarField.header.averageTemperature,
          ambient: ambientTemperature)
        * status.solarField.area
    }
    // H2OinHX.temperature.inlet = H2OinPB.temperature.outlet
  }

  private static func freezeProtection(
    _ status: inout Plant.PerformanceData, _ fuel: Double, _ heatDiff: Double)
  {

    let solarField = SolarField.parameter
    let freezeTemperature = solarField.HTF.freezeTemperature
    
    switch status.heater.operationMode {
    case .normal, .reheat: break
    default:
      if status.solarField.header.temperature.outlet <
        freezeTemperature + Simulation.parameter.dfreezeTemperatureHeat,
        status.storage.massFlow.isNearZero
      { // No freeze protection heater use anymore if storage is in operation
        status.heater.setTemperature(inlet:
          status.powerBlock.temperature.inlet
        )
        status.heater.massFlow = status.powerBlock.massFlow
        status.heater.operationMode = .freezeProtection
        Heater.update(status, demand: 1, fuelAvailable: fuel) { result in
          status.heater = result.status
          thermal.heater.megaWatt = result.supply
          electricalParasitics.heater = result.parasitics
          fuelConsumption.heater = result.fuel
        }
      }
      switch status.heater.operationMode {
      case .freezeProtection:
        status.powerBlock.setTemperature(outlet:
          status.heater.temperature.outlet
        )
      case .normal, .reheat: break
      default:
        if status.solarField.header.outletTemperature
          > freezeTemperature.kelvin
          + Simulation.parameter.dfreezeTemperatureHeat.kelvin
        {
          status.heater.operationMode = .noOperation

          Heater.update(status, demand: heatDiff, fuelAvailable: fuel)
          { result in
            status.heater = result.status
            thermal.heater.megaWatt = result.supply
            electricalParasitics.heater = result.parasitics
            fuelConsumption.heater = result.fuel
          }
        }
      }
    }
  }

  private static func powerBlockFunction(
    _ status: inout Plant.PerformanceData, _ heatDiff: inout Double)
  {
    let heatExchanger = HeatExchanger.parameter
    let solarField = SolarField.parameter
    // Iteration: Find the right powerBlock.temperature.inlet and temperature.outlet
    repeat {
      
      if Design.hasSolarField {
        
        if status.solarField.insolationAbsorber > 0 {
          
          thermal.solar.megaWatt = status.solarField.massFlow.rate *
            solarField.HTF.heatAdded(
              status.solarField.temperature.outlet,
              status.solarField.temperature.inlet) / 1_000
        } else {
          // added to avoid Q.solar > 0 during some night and freeze protection time
          thermal.solar = 0.0
        }
        #warning("The implementation here differs from PCT")
        status.powerBlock.setTemperature(inlet:
          status.solarField.temperature.outlet
        )
        status.powerBlock.massFlow = status.solarField.header.massFlow
        
        if thermal.solar.watt > 0 {
          if case .startUp = status.steamTurbine.operationMode {
            thermal.production = 0.0
          } else {
            thermal.production = thermal.solar
          }
        } else if case .freezeProtection = status.solarField.operationMode {
          thermal.solar = 0.0
          thermal.production = 0.0
        } else {
          thermal.solar = 0.0
          thermal.production = 0.0
          status.powerBlock.massFlow = 0.0
          status.solarField.header.massFlow = 0.0
        }
      }
      let fuel = Availability.fuel
      if Design.hasStorage {
        Storage.update(
          &status, demand: thermal.demand.megaWatt, fuelAvailable: fuel
        ) { result in
          thermal.storage.megaWatt = result.supply
          thermal.demand.megaWatt = result.demand
          fuelConsumption.heater = result.fuel
        }
        let (thermalPower, sto) = Storage.calculate(status.storage)
        status.storage = sto
        thermal.storage.megaWatt = thermalPower
        if status.storage.heat > 0 { // Energy surplus
          if status.storage.charge.ratio < Storage.parameter.chargeTo,
            status.solarField.header.massFlow >= status.powerBlock.massFlow
          { // 1.1
            thermal.production = thermal.solar
            thermal.production += thermal.storage
          } else { // heat cannot be stored
            thermal.production.megaWatt = thermal.solar.megaWatt - status.storage.heat
          }
        } else { // Energy deficit
          thermal.production = thermal.solar
          thermal.production += thermal.storage
        }
      }
      
      if Design.hasGasTurbine {
        electric.gasTurbineGross = GasTurbine.update(&status, fuel: fuel)
      }
      
      if Design.hasHeater && !Design.hasBoiler {
        heaterFunction(&status, electric.gasTurbineGross, &heatDiff, fuel)
      }
      
      freezeProtection(&status, fuel, heatDiff) // Heater.OPmode != "OP"
      // HX: powerBlock.temperature.inlet is known now, so calc. the real heatExchanger.temperature.outlet and thermal.production
      
      let storageFreeze = status.storage.operationMode.isFreezeProtection
      let solarFieldFreeze = status.solarField.operationMode.isFreezeProtection
      let heaterAntiFreeze = status.heater.operationMode.isFreezeProtection
      
      if status.powerBlock.temperature.inlet
        < heatExchanger.temperature.htf.inlet.min
        || status.powerBlock.massFlow.rate == 0
        || storageFreeze
      { // bypass HX
        if heaterAntiFreeze == false,
          solarFieldFreeze || storageFreeze
        {
          if Design.hasGasTurbine {
            status.powerBlock.setTemperaturOutletEqualToInlet()
          } else {
            let TLPB = 0.0 // 0.38 * (TpowerBlock.status - meteo.temperature) / 100 * (30 / Design.layout.powerBlock) ** 0.5 // 0.38
            
            let massFlow =  max(
              (status.solarField.massFlow + status.powerBlock.massFlow).rate,
              0.1)
            
            status.powerBlock.setInletTemperature(kelvin:
              (status.solarField.massFlow.rate
                * status.solarField.outletTemperature
                + status.powerBlock.massFlow.rate
                * status.storage.outletTemperature) / massFlow
            )
            #warning("The implementation here differs from PCT")
            // FIXME: Was ist Tstatus ?????????
            
            status.powerBlock.setOutletTemperature(kelvin:
              (status.powerBlock.massFlow.rate
                * Double(period) * status.powerBlock.inletTemperature
                + status.powerBlock.outletTemperature
                * (solarField.HTFmass
                  - status.powerBlock.massFlow.rate * Double(period)))
                / solarField.HTFmass - TLPB
            )
          }
        }
        thermal.production = 0.0
        thermal.heatExchanger = 0.0
        status.heatExchanger.massFlow = 0.0
        break
      }
      
      status.heatExchanger.massFlow = status.powerBlock.massFlow
      status.heatExchanger.setTemperature(inlet:
        status.powerBlock.temperature.inlet
      )
      
      thermal.heatExchanger.megaWatt = HeatExchanger.update(
        &status.heatExchanger,
        steamTurbine: status.steamTurbine,
        storage: status.storage
      )
      
      if Design.hasGasTurbine, Design.hasStorage,
        thermal.heatExchanger.megaWatt > heatExchanger.sccHTFheat
      {
        thermal.dump.megaWatt += thermal.heatExchanger.megaWatt
          - heatExchanger.sccHTFheat
        thermal.heatExchanger.megaWatt = heatExchanger.sccHTFheat
      }
      status.powerBlock.setTemperature(outlet:
        status.heatExchanger.temperature.outlet
      )
      
    } while abs((status.powerBlock.outletTemperature
      - status.heatExchanger.outletTemperature))
      > Simulation.parameter.tempTolerance.kelvin
  }
  
  static func iteration(_ status: inout Plant.PerformanceData,
                        _ meteo: MeteoData,
                        goal: Double)  {

    let heatExchanger = HeatExchanger.parameter
    let steamTurbine = SteamTurbine.parameter
    let storage = Storage.parameter
    
    var electricalParasiticsAssumed = goal
    // Iteration to account for correct parasitics
    for _ in 1 ... 100 {
      if Design.hasGasTurbine {
        electric.demand = gridDemand.ratio *
          (Design.layout.powerBlock - Design.layout.gasTurbine)
          + electric.demand * Simulation.parameter.electricalParasitics
      } else {
        electric.demand = gridDemand.ratio * steamTurbine.power.max
      }

      status.steamTurbine.load.ratio = 
        (electric.demand + Design.layout.gasTurbine) / steamTurbine.power.max
      var (maxLoad, st) = SteamTurbine.calculate(status)
      status.steamTurbine = st
      
      switch storage.strategy {
      case .demand:
        thermal.demand.megaWatt = min(
          heatExchanger.sccHTFheat,
          steamTurbine.power.max / st.efficiency
        )
      case .shifter:
        thermal.demand.megaWatt = min(
          heatExchanger.sccHTFheat,
          steamTurbine.power.max * gridDemand.ratio / st.efficiency
        )
      case .always:
        thermal.demand.megaWatt = min(
          heatExchanger.sccHTFheat,
          electric.demand / st.efficiency
        )
      }

      if status.steamTurbine.load > availability.value.powerBlock {
        status.steamTurbine.load = availability.value.powerBlock
        let (_, st) = SteamTurbine.calculate(status)
        status.steamTurbine = st
        thermal.demand.megaWatt = min(
          steamTurbine.power.max * st.load.ratio / st.efficiency,
          heatExchanger.sccHTFheat
        )
      }

      thermal.demand.megaWatt = (thermal.demand.megaWatt
        / Simulation.adjustmentFactor.heatLossH2O) / heatExchanger.efficiency

      // For the scc mode it must be checked whether the solar heat is enough to
      // cover the demand; if not, priority is to switch on the Gas SteamTurbine:
      // this has to be done before the heater is put into action
      /*
       if thermal.demand > 0 && availableFuel > 0 && Design.hasHeater {
       status.powerBlock.temperature.outlet = heatExchanger.temperature.htf.outlet.max
       }

       if availableFuel > 0 { // Important change done! only valid for OU1!!!
       status.powerBlock.temperature.outlet = heatExchanger.temperature.htf.outlet.max
       }
       */
      // it seems that the current.temperature.outlet calculated below
      // does not have great influence on the results.
      // It is used for calculating the HTF temp to heater when generating
      // steam directly with gas of during solar field freeze protection
      if status.powerBlock.massFlow.isNearZero == false {
        if status.powerBlock.temperature.inlet
          >= heatExchanger.temperature.htf.inlet.min
        {
          status.powerBlock.temperature.outlet = HeatExchanger
            .outletTemperature(status.powerBlock, status.heatExchanger)
          if case .discharge = status.storage.operationMode,
            status.powerBlock.temperature.outlet.isLower(than: 534.0) {
            let result = PowerBlock.heatExchangerBypass(status)
            status.powerBlock = result.powerBlock
            status.heatExchanger.heatOut = result.heatOut
            status.heatExchanger.heatToTES = result.heatToTES
          }
        }
      }
      var heatDiff: Double = 0.0
      
      powerBlockFunction(&status, &heatDiff)
      // FIXME: H2OinPB = H2OinHX

      thermal.production = thermal.heatExchanger + thermal.wasteHeatRecovery
      thermal.demand.watt *= heatExchanger.efficiency
      // Therm heat demand is lower after HX:
      thermal.production.watt *= Simulation.adjustmentFactor.heatLossH2O
      // - Unavoidable losses in Power Block -

      if Design.hasBoiler {
        boilerFunction(&status.boiler, &heatDiff, steamTurbine)
      }
      
      (maxLoad, st) = SteamTurbine.calculate(status)
      status.steamTurbine = st
      let heat = thermal.production.megaWatt
        - steamTurbine.power.max / st.efficiency
      let diff = thermal.production.megaWatt - thermal.demand.megaWatt
      if heat > Simulation.parameter.heatTolerance { // TB.Overload
      /*  💬.infoMessage("""
          \(TimeStep.current)
          Overloading TB: \(heat) MWH,th
          """)*/
      } else if heatDiff
        > 2 * Simulation.parameter.heatTolerance
      {
        💬.infoMessage("""
          \(TimeStep.current)
          Production > demand: \(diff) MWH,th
          """)
      }
      
      let PminT = steamTurbine.minPowerFromTemp
      let minLoad: Double
      if (PminT[0] == 1 || PminT[0] == 0)
        && PminT[1] == 0 && PminT[2] == 0 && PminT[3] == 0 && PminT[4] == 0
      {
        #warning("The implementation here differs from PCT")
        minLoad = steamTurbine.power.min / steamTurbine.power.max
      } else {
        minLoad = steamTurbine.minPowerFromTemp[ambientTemperature]
          / steamTurbine.power.max
      }
      
      if (PminT[0] == 1 || PminT[0] == 0)
        && PminT[1] == 0 && PminT[2] == 0 && PminT[3] == 0 && PminT[4] == 0
      {
        if thermal.production.megaWatt > 0, thermal.production.megaWatt
            < steamTurbine.power.min / steamTurbine.efficiencyNominal
        {
       /*   💬.infoMessage("""
            \(TimeStep.current)
            "Damping (SteamTurbine underload): \(thermal.production) MWH,th.
            """)*/
          // not used !!! Qblank = thermal.production
          thermal.production = 0.0
        }
      } else {
        var minPower = steamTurbine.minPowerFromTemp[ambientTemperature]

        minPower = max(steamTurbine.power.nominal * minPower,
                       steamTurbine.power.min)
        let (maxLoad, st) = SteamTurbine.calculate(status)
        status.steamTurbine = st
        if thermal.production.megaWatt > 0,
          thermal.production.megaWatt < minPower / st.efficiency
        {
        // efficiency at min. load instead of nominal, has effect for dry cooling!
       /*   💬.infoMessage("""
            \(TimeStep.current)
            "Damping (SteamTurbine underload): \(thermal.production) MWH,th.
            """)*/
          // not used !!! Qblank = thermal.production
          thermal.production = 0.0
        }
      }
      SteamTurbine.update(
        status, heat: thermal.production.megaWatt, meteo: meteo
      ) { result in
        status.steamTurbine =  result.status
        electric.steamTurbineGross = result.gross
      }
      electricalParasitics.powerBlock = PowerBlock.parasitics(
          heat: heat, steamTurbine: status.steamTurbine
      )

      let powerBlock = PowerBlock.parameter
      // added to separate shared facilities parasitics
      if thermal.heatExchanger.watt == 0 {
        // no operation
        electricalParasitics.shared = powerBlock.electricalParasiticsShared[0]
      } else {
        // operation and start up
        electricalParasitics.shared = powerBlock.electricalParasiticsShared[1]
      }

      if Fuelmode.isPredefined {
        if Plant.fuelConsumption.combined > 0 && electric.steamTurbineGross
          > steamTurbine.power.max + 1 {
          electric.steamTurbineGross = steamTurbine.power.max + 1
        }
        if Plant.fuelConsumption.combined > 0, thermal.solar.watt > 0,
          electric.steamTurbineGross > steamTurbine.power.max - 1 {
          electric.steamTurbineGross = steamTurbine.power.max - 1
        }
      }

      if Design.hasStorage {
        if case .always = storage.strategy {} // new restriction of production
        else if electric.steamTurbineGross > electric.demand {
          thermal.dump.megaWatt = electric.steamTurbineGross - electric.demand
          electric.steamTurbineGross = electric.demand
        }
      } else { /* if Heater.parameter.operationMode */ // following uncomment for Shams-1.
        if electric.steamTurbineGross > electric.demand {
          let electricEnergyFactor = electric.demand
            / electric.steamTurbineGross

          thermal.dump.megaWatt = electric.steamTurbineGross - electric.demand
            * electricEnergyFactor

          heatDiff *= electricEnergyFactor
          var Qsf_load = 0.0
          Qsf_load *= electricEnergyFactor

          Boiler.update(
            status.boiler, heatFlow: heatDiff, Qsf_load: Qsf_load,
            fuelAvailable: Availability.fuel
          ) { result in
            status.boiler = result.status
            thermal.boiler.megaWatt = result.supply
            fuelConsumption.boiler = result.fuel
            electricalParasitics.boiler = result.parasitics
          }
          thermal.solar.watt *= electricEnergyFactor
          // reduction in Qsol should be necessary for every project without storage
          thermal.heatExchanger.watt *= electricEnergyFactor
          
          SteamTurbine.update(
            status, heat: thermal.production.megaWatt, meteo: meteo
          ) { result in
            status.steamTurbine = result.status
            electric.steamTurbineGross = result.gross
          }
          electricalParasitics.powerBlock = PowerBlock.parasitics(
            heat: heat, steamTurbine: status.steamTurbine
          )

          if thermal.production.watt == 0 {
            // added to separate shared facilities parasitics
            electricalParasitics.shared =
              PowerBlock.parameter.electricalParasiticsShared[0]
          } else {
            electricalParasitics.shared =
              PowerBlock.parameter.electricalParasiticsShared[1]
          }
        }
      }

      electric.gross = electric.steamTurbineGross + electric.gasTurbineGross

      // + GasTurbine = total productionuced electricity
      electric.solarField += electricalParasitics.storage
      electric.storage = electricalParasitics.storage

      // electricEnergy.parasiticsBU = electricalParasitics.heater + electricalParasitics.boiler
      electric.powerBlock = electricalParasitics.powerBlock
      electric.shared = electricalParasitics.shared

      electric.parasitics = electric.solarField
        + electric.gasTurbine
        + electricalParasitics.powerBlock
        + electricalParasitics.shared

      electric.parasitics *= Simulation.adjustmentFactor.electricalParasitics
      let deviation = abs(electricalParasiticsAssumed - electric.parasitics)
      electricalParasiticsAssumed = electric.parasitics
      if deviation < 3 * Simulation.parameter.electricalTolerance {
        /*
         if Heater.parameter.operationMode = 3 {
         if FirmOutput {
         DSumHR = DSumHR + thermal.heater
         YSumHR = YSumHR + thermal.heater
         } else {
         ConsHours = ConsHours + (1 * CalcTime% / 3_600)
         }
         } else {
         DSumHR = DSumHR + thermal.heater
         YSumHR = YSumHR + thermal.heater
         }*/
        if thermal.heater.watt > 0 {
          // oldHR = thermal.heater
        }
        break
      }

      if case .startUp = status.steamTurbine.operationMode {
        thermal.production = 0.0
      }
      
      if Design.hasBoiler {
        if case .startUp = status.boiler.operationMode {
          status.boiler.operationMode = .SI
        } else if case .noOperation = status.boiler.operationMode {
          status.boiler.operationMode = .NI
        }
      }
    }
  }
  
  private static func heaterFunction(_ status: inout Plant.PerformanceData,
                                     _ supplyGasTurbine: Double,
                                     _ heatdiff: inout Double,
                                     _ fuel: Double) {
    let solarField = SolarField.parameter
    let storage = Storage.parameter

    // restart variable to avoid errors due to Boiler.  added for Shams-1
    if case .pure = status.gasTurbine.operationMode {
      // Plant updates in Pure CC Mode now again without RH!!
      // demand * WasteHeatRecovery.parameter.effPure * (1 / gasTurbine.efficiency- 1)) heat supplied by the WHR system
    } else if case .integrated = status.gasTurbine.operationMode {
      // Plant does not update in Pure CC Mode
      let HTFenergy = supplyGasTurbine * (1
        / GasTurbine.efficiency(at: status.gasTurbine.load) - 1)
        * WasteHeatRecovery.parameter.efficiencyNominal
        / WasteHeatRecovery.parameter.ratioHTF

      heatdiff = thermal.production.megaWatt - HTFenergy // -^- necessary HTF share

      status.heater.setTemperature(
        inlet: status.powerBlock.temperature.outlet
      )

      Heater.update(status, demand: heatdiff, fuelAvailable: fuel) { result in
        status.heater = result.status
        thermal.heater.megaWatt = result.supply
        electricalParasitics.heater = result.parasitics
        fuelConsumption.heater = result.fuel
      }
      status.powerBlock.temperature.inlet =
        solarField.HTF.mixingTemperature(
          inlet: status.powerBlock, with: status.heater
      )
      status.powerBlock.massFlow += status.heater.massFlow
    } else if case .noOperation = status.gasTurbine.operationMode {
      // GasTurbine does not update at all (Load<Min?)
      Heater.update(status, demand: heatdiff, fuelAvailable: fuel) { result in
        status.heater = result.status
        thermal.heater.megaWatt = result.supply
        electricalParasitics.heater = result.parasitics
        fuelConsumption.heater = result.fuel
      }
      status.powerBlock.temperature.inlet =
        solarField.HTF.mixingTemperature(
          outlet: status.solarField, with: status.heater
      )
      status.powerBlock.merge(massFlows: status.solarField, status.heater)
    } else { // gasTurbine.OPmode is neither IC nor PC
      // Line 429 STO STO STO STO STO

      if Design.hasStorage {
        if heatdiff < 0,
          status.storage.charge.ratio < storage.dischargeToTurbine,
          status.storage.charge.ratio > storage.dischargeToHeater
        {
          // Direct Discharging to SteamTurbine
          var supply, parasitics: Double
          if fuel > 0 { // Fuel available, Storage for Pre-Heating
            (supply, parasitics) = Storage.update(&status, mode: .preheat)

            status.heater.setTemperature(inlet:
              status.storage.temperature.outlet
            )

            status.heater.operationMode = .unknown

            heatdiff = thermal.production.megaWatt
              + thermal.storage.megaWatt - thermal.demand.megaWatt

            Heater.update(status, demand: heatdiff, fuelAvailable: fuel)
            { result in
              status.heater = result.status
              thermal.heater.megaWatt = result.supply
              electricalParasitics.heater = result.parasitics
              fuelConsumption.heater = result.fuel
            }
            status.heater.massFlow = status.storage.massFlow

            status.powerBlock.temperature.inlet =
              solarField.HTF.mixingTemperature(
                outlet: status.solarField, with: status.heater
            )
            status.powerBlock.merge(massFlows:
              status.solarField, status.heater
            )
          } else {
            // NO Fuel Available -> Discharge directly with reduced TB load!
            (supply, parasitics) = Storage.update(&status, mode: .discharge)

            status.powerBlock.temperature.inlet =
              solarField.HTF.mixingTemperature(outlet:
                status.solarField, with: status.storage
            )
            status.powerBlock.merge(massFlows:
              status.storage, status.solarField
            )
          } // STORAGE: dischargeToHeater < Qrel < dischargeToTurbine;  Fuel/NoFuel
          thermal.storage.megaWatt = supply
          electricalParasitics.storage = parasitics
        } else if heatdiff < 0,
          status.storage.charge.ratio < storage.dischargeToHeater,
          status.heater.operationMode != .freezeProtection
        {
          // = Storage is empty!! && Heater.operationMode != .freezeProtection // <= added instead of "<"
          heatdiff = (thermal.production + thermal.wasteHeatRecovery).megaWatt
            / HeatExchanger.parameter.efficiency
            - gridDemand.ratio * thermal.demand.megaWatt
          // added to avoid heater use is storage is selected and checkbox marked:
          if thermal.production.watt == 0 { // use heater only in parallel with solar field and not as stand alone.
            // heatdiff = 0 // commented to use gas not only in paralell to SF (for AH1)
            if Heater.parameter.onlyWithSolarField {
              heatdiff = 0
            }
          }
          status.heater.setTemperature(inlet:
            status.powerBlock.temperature.outlet
          )

          Heater.update(status, demand: heatdiff, fuelAvailable: fuel)
          { result in
            status.heater = result.status
            thermal.heater.megaWatt = result.supply
            electricalParasitics.heater = result.parasitics
            fuelConsumption.heater = result.fuel
          }
          status.powerBlock.temperature.inlet =
            solarField.HTF.mixingTemperature(
              outlet: status.solarField, with: status.heater)

          status.powerBlock.merge(massFlows: status.solarField, status.heater)
        }
      } else { // No Storage
        heatdiff = thermal.production.megaWatt
          + thermal.wasteHeatRecovery.megaWatt
          / HeatExchanger.parameter.efficiency
          - thermal.demand.megaWatt

        if thermal.production.watt == 0 {
          // use heater only in parallel with solar field and not as stand alone.
          if Heater.parameter.onlyWithSolarField {
            heatdiff = 0
          }
        }
        
        status.heater.setTemperature(inlet:
          status.powerBlock.temperature.outlet
        )

        Heater.update(status, demand: heatdiff, fuelAvailable: fuel) { result in
          status.heater = result.status
          thermal.heater.megaWatt = result.supply
          electricalParasitics.heater = result.parasitics
          fuelConsumption.heater = result.fuel
        }
        
        if (status.solarField.massFlow + status.heater.massFlow).isNearZero {
          // Freeze Protection
        } else {
          status.powerBlock.temperature.inlet =
            solarField.HTF.mixingTemperature(
              outlet: status.solarField, with: status.heater)
        }
        status.powerBlock.merge(massFlows: status.solarField, status.heater)
      }
    }

    if status.heater.massFlow.isNearZero == false {
      thermal.production.megaWatt = status.powerBlock.massFlow.rate *
        SolarField.parameter.HTF.heatAdded(
          status.powerBlock.temperature.outlet,
          status.powerBlock.temperature.inlet) / 1_000
    }
  }

  private static func boilerFunction(_ boiler: inout Boiler.PerformanceData,
                                     _ heatDiff: inout Double,
                                     _ steamTurbine: SteamTurbine.Parameter) {
    var Qsf_load: Double
    let adjustmentFactor = Simulation.adjustmentFactor
    if case .solarOnly = Control.whichOptimization {
      if thermal.production.megaWatt < adjustmentFactor.efficiencyHeater,
        thermal.production.megaWatt >= adjustmentFactor.efficiencyBoiler
      {
        switch boiler.operationMode {
        case .startUp, .SI, .NI:
          break
        default:
          boiler.operationMode = .unknown
        }
        
        heatDiff = thermal.production.megaWatt - thermal.demand.megaWatt
        if Boiler.parameter.booster { // booster superheater
          if thermal.heater.megaWatt == Design.layout.heater { // Firm Output case
            // for shams-1 769% of the boiler load is used during firm output.
            // no time to find a nice formula. sorry!
            Qsf_load = 0.769
          } else {
            Qsf_load = thermal.production.megaWatt
              / (Design.layout.heatExchanger / steamTurbine.efficiencyNominal)
          }
        }
        // H2OinBO.temperature.inlet = H2OinPB.temperature.outlet
      } else {
        boiler.operationMode = .noOperation(hours: 0)
      }
    }
    
    if thermal.heater.megaWatt == Design.layout.heater { // Firm Output case
      // for shams-1 769% of the boiler load is used during firm output.
      // no time to find a nice formula. sorry!
      Qsf_load = 0.769
    } else {
      Qsf_load = thermal.production.megaWatt /
        (Design.layout.heatExchanger / steamTurbine.efficiencyNominal)
    }
    Boiler.update(boiler, heatFlow: heatDiff,
                  Qsf_load: Qsf_load, fuelAvailable: 0
    ) { result in
      boiler = result.status
      thermal.boiler.megaWatt = result.supply
    }
    
    if Fuelmode.isPredefined { // predefined fuel consumption in *.pfc-file
      if (thermal.heatExchanger.megaWatt + thermal.boiler.megaWatt) > 110 {
        thermal.boiler.megaWatt = 105 - thermal.heatExchanger.megaWatt
      }
      
      thermal.production = (thermal.heatExchanger + thermal.wasteHeatRecovery)
        * adjustmentFactor.heatLossH2O + thermal.boiler
    }
  }
  
  static func reset() {
    thermal = ThermalEnergy()
    fuelConsumption = FuelConsumption()
    electricalParasitics = Parasitics()
    electric = ElectricEnergy()
    gridDemand = 1.0
    SolarField.lastDNI = 0.0
    SolarField.last = SolarField.initialState.loops
  }

  static private var componentsNeedUpdate = true
  public static func updateComponentsParameter() {
    guard componentsNeedUpdate else { return }
    componentsNeedUpdate = false
    let solarField = SolarField.parameter
    let heatExchanger = HeatExchanger.parameter
    let steamTurbine = SteamTurbine.parameter
    let powerBlock = PowerBlock.parameter

    if steamTurbine.power.max == 0 {
      SteamTurbine.parameter.power.max = Design.layout.powerBlock
        + powerBlock.fixelectricalParasitics
        + powerBlock.nominalElectricalParasitics
        + powerBlock.electricalParasiticsStep[1]
    }

    if Design.hasGasTurbine {
      HeatExchanger.parameter.sccHTFheat = Design.layout.heatExchanger
        / steamTurbine.efficiencySCC / heatExchanger.sccEff

      SolarField.parameter.massFlow.max = MassFlow(
        heatExchanger.sccHTFheat * 1_000
          / solarField.HTF.heatAdded(heatExchanger.scc.htf.outlet.max,
                                     heatExchanger.scc.htf.inlet.max)
      )
      WasteHeatRecovery.parameter.ratioHTF = heatExchanger.sccHTFheat
        / (steamTurbine.power.max - heatExchanger.sccHTFheat)
    } else {
      if Design.layout.heatExchanger != Design.layout.powerBlock {
        HeatExchanger.parameter.sccHTFheat = Design.layout.heatExchanger
          / steamTurbine.efficiencyNominal / heatExchanger.efficiency
      } else {
        HeatExchanger.parameter.sccHTFheat = steamTurbine.power.max
          / steamTurbine.efficiencyNominal / heatExchanger.efficiency
      }
      SolarField.parameter.massFlow.max = MassFlow(
        heatExchanger.sccHTFheat * 1_000
          / solarField.HTF.heatAdded(heatExchanger.temperature.htf.inlet.max,
                                     heatExchanger.temperature.htf.outlet.max)
      )
    }

    if Design.hasSolarField {
      SolarField.parameter.edgeFactor = [solarField.distanceSCA / 2
        * (1 - 1 / Double(solarField.numberOfSCAsInRow))
        / Collector.parameter.lengthSCA,
        (1.0 + 1.0 / Double(solarField.numberOfSCAsInRow))
        / Collector.parameter.lengthSCA / 2
      ]
    }
  }
}
