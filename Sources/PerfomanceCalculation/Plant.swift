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
import Meteo
import Config

enum Plant {
  
  static var location: Location!
  static var ambientTemperature = Temperature()
  static var availability = Availability.withDefaults()
  static var electricEnergy = ElectricEnergy()
  static var electricalParasitics = Components()
  static var heatFlow = HeatFlow()
  static var fuel = FuelConsumption()
  
  static func operate(
    at calendarDay: CalendarDay,
    demand: Double,
    availableFuel: inout Double,
    meteo: MeteoData,
    boiler: inout Boiler.PerformanceData,
    powerBlock: inout PowerBlock.PerformanceData,
    solarField: inout SolarField.PerformanceData,
    steamTurbine: inout SteamTurbine.PerformanceData,
    heater: inout Heater.PerformanceData,
    heatExchanger: inout HeatExchanger.PerformanceData,
    gasTurbine: inout GasTurbine.PerformanceData,
    storage: inout Storage.PerformanceData) {
    
    ambientTemperature = Temperature(celsius: meteo.temperature)
    
    // storage.mass.hot = HeatExchanger.parameter.temperature.h2o.inlet.max
    // storage.mass.cold = HeatExchanger.parameter.temperature.h2o.inlet.min
    
    // storage.mass.hot = Storage.parameter.startLoad.hot
    // storage.mass.cold = Storage.parameter.startLoad.cold
    // storage.temperatureTank.hot = HeatExchanger.parameter.temperature.h2o.outlet.max
    // storage.temperatureTank.cold = HeatExchanger.parameter.temperature.h2o.outlet.max
    
    let Pmin = SteamTurbine.parameter.PminT[ambientTemperature]

    steamTurbine.PminfT = max(SteamTurbine.parameter.power.min * Pmin, SteamTurbine.parameter.PminLim)
    
    var electricalParasiticsAssumed: Double = 0.0
    if Design.hasGasTurbine {
      // for SEGS plant Demand is set to max SteamTurbine Power (because of spanish new legislation)
      electricEnergy.demand = demand * (Design.layout.powerBlock - Design.layout.gasTurbine)
      // Electric demand SCC
      electricalParasiticsAssumed = electricEnergy.demand
        * Simulation.parameter.electricalParasitics
      // Iter. start val. for parasitics, 10% demand
      electricEnergy.demand += electricalParasiticsAssumed
    } else {
      electricEnergy.demand = demand * SteamTurbine.parameter.power.max
      // added to try to limit output to demand file
    }
    var dumping: Double = 0.0
    
    // Iteration to account for correct parasitics
    outerLoop: for _ in 1 ... 100 {
      if Design.hasGasTurbine {
        electricEnergy.demand = demand * (Design.layout.powerBlock - Design.layout.gasTurbine)
        electricEnergy.demand += electricEnergy.demand
          * Simulation.parameter.electricalParasitics // ist hier nochmals neu von oben eingefügt worden
      } else {
        electricEnergy.demand = SteamTurbine.parameter.power.max
        // added to try to limit output to demand file
      }
      
      steamTurbine.load = Ratio((electricEnergy.demand + Design.layout.gasTurbine)
        / SteamTurbine.parameter.power.max) // TB Load
      
      switch Storage.parameter.strategy {
      case .demand:
        heatFlow.demand = min(
          HeatExchanger.parameter.SCCHTFheatFlow,
          SteamTurbine.parameter.power.max
            / SteamTurbine.efficiency(at: steamTurbine.load, Lmax: 1.0,
                                      boiler: boiler, gasTurbine: gasTurbine,
                                      heatExchanger: heatExchanger))
      // * demand deleted, should be 100% demand (?)// comparison with HX cap. written to restrict HX capacity
      case .shifter:
        heatFlow.demand = min(
          HeatExchanger.parameter.SCCHTFheatFlow,
          SteamTurbine.parameter.power.max * demand
            / SteamTurbine.efficiency(at: steamTurbine.load, Lmax: 1.0,
                                      boiler: boiler, gasTurbine: gasTurbine,
                                      heatExchanger: heatExchanger))
      // strategy ful added again, same as always? comparison with HX cap. written to restrict HX capacity
      default:
        heatFlow.demand = min(HeatExchanger.parameter.SCCHTFheatFlow,
                              electricEnergy.demand
                                / SteamTurbine.efficiency(
                                  at: steamTurbine.load, Lmax: 1.0,
                                  boiler: boiler, gasTurbine: gasTurbine,
                                  heatExchanger: heatExchanger))
        //  demand deleted since is calculated before in electricEnergy.demand
        //  demand added because electricEnergy.demand is only SteamTurbine.parameter.power.max
        //  steamTurbine.load // wird hier jetzt mit electricEnergy.demand berechnet,
        //  comparison with HX cap. written to restrict HX capacity
      }
      
      if steamTurbine.isMaintained {
        steamTurbine.load = 0.0
        electricEnergy.demand = 0
        heatFlow.demand = 0
      } else if steamTurbine.load > Plant.availability[calendarDay].powerBlock { // - TB Load > Availability -
        steamTurbine.load = Plant.availability[calendarDay].powerBlock
        heatFlow.demand = min(
          HeatExchanger.parameter.SCCHTFheatFlow,
          SteamTurbine.parameter.power.max
            * Plant.availability[calendarDay].powerBlock.ratio
            / SteamTurbine.efficiency(at: steamTurbine.load, Lmax: 1.0,
                                      boiler: boiler, gasTurbine: gasTurbine,
                                      heatExchanger: heatExchanger))
        // comparison with HX cap. written to restrict HX capacity
      }
      
      heatFlow.demand = (heatFlow.demand / Simulation.parameter.adjustmentFactor.heatLossH2O)
        / HeatExchanger.parameter.efficiency // + Simulation.parameter.energyTolerance)
      // steam losses + Thermal demand higher before HX // + inaccuracies
      // ::::::::::::::: HTF - Loop :::::::::::::::::::::::::::::::::::::::::::::::
      // For the SCC mode it must be checked whether the solar heat is enough to
      // cover the demand; if not, priority is to switch on the Gas SteamTurbine: this has
      // to be done before the heater is put into action
      
      if heatFlow.demand > 0 && availableFuel > 0 && Design.hasHeater {
        powerBlock.temperature.outlet = HeatExchanger.parameter.temperature.htf.outlet.max
      }
      
      if availableFuel > 0 { // Important change done! only valid for OU1!!!
        powerBlock.temperature.outlet = HeatExchanger.parameter.temperature.htf.outlet.max
      }
      
      // it seems that the current.temperature.outlet calculated below does not have great influence on the results.
      // It is used for calculating the HTF temp to heater when generating steam directly with gas of during solar field freeze protection
      if !powerBlock.massFlow.isNearZero {
        
        if powerBlock.temperature.inlet >= HeatExchanger.parameter.temperature.htf.inlet.min {
          
          HeatExchanger.operate(powerBlock: &powerBlock)
          // Line 236
          if case .ex = storage.operationMode, powerBlock.temperature.outlet.isLower(than: 261.toKelvin) {
            // added to simulate a bypass on the PB-HX if the expected outlet temp is so low that the salt to TES could freeze
            let totalMassFlow = powerBlock.massFlow
            for _ in 1 ... 100 {
              let massFlowLoad = powerBlock.massFlow.share(
                of: SolarField.parameter.massFlow.max)
              
              if HeatExchanger.parameter.Tout_f_Mfl,
                !HeatExchanger.parameter.Tout_f_Tin,
                !HeatExchanger.parameter.useAndsolFunction,
                let ToutMassFlow = HeatExchanger.parameter.ToutMassFlow {
                
                // if temperature.outlet is dependant on massflow, recalculate temperature.outlet
                var temperaturFactor = ToutMassFlow[massFlowLoad]
                if temperaturFactor > 1 { temperaturFactor = 1 }
                powerBlock.temperature.outlet =
                  HeatExchanger.parameter.temperature.htf.outlet.max
                  .adjusted(with: temperaturFactor)
                
              } else if HeatExchanger.parameter.Tout_f_Mfl,
                HeatExchanger.parameter.Tout_f_Tin,
                !HeatExchanger.parameter.useAndsolFunction,
                let ToutMassFlow = HeatExchanger.parameter.ToutMassFlow,
                let ToutTin = HeatExchanger.parameter.ToutTin {
                
                var temperaturFactor = ToutMassFlow[massFlowLoad]
                temperaturFactor *= ToutTin[powerBlock.temperature.inlet]
                powerBlock.temperature.outlet =
                  HeatExchanger.parameter.temperature.htf.outlet.max
                  .adjusted(with: temperaturFactor)
                
              } else if HeatExchanger.parameter.useAndsolFunction {
                var temperaturFactor = (
                  (0.0007592419869 * (powerBlock.temperature.inlet.kelvin
                    / HeatExchanger.parameter.temperature.htf.inlet.max.kelvin)
                    * 666 + 0.4943825893223)
                    * massFlowLoad.ratio ** (0.0001400823882
                      * (powerBlock.temperature.inlet.kelvin
                        / HeatExchanger.parameter.temperature.htf.inlet.max.kelvin)
                      * 666 - 0.0110227028559)) - 0.000151639
                // temperature.inlet changed to (Fluid.parameter.temperature.inlet / HeatExchanger.parameter.temperature.htf.inlet.max) * 666 because function is based on 393°C temperature.inlet
                temperaturFactor = HeatExchanger.setLimits(temperaturFactor)
                powerBlock.temperature.outlet =
                  HeatExchanger.parameter.temperature.htf.outlet.max
                  .adjusted(with: temperaturFactor)
                
              } else if HeatExchanger.parameter.Tout_exp_Tin_Mfl,
                let ToutTinMassFlow = HeatExchanger.parameter.ToutTinMassFlow {
                
                var temperaturFactor = (ToutTinMassFlow[0]
                  * (powerBlock.temperature.inlet.kelvin
                    / HeatExchanger.parameter.temperature.htf.inlet.max.kelvin)
                  * 666 + ToutTinMassFlow[1])
                  * massFlowLoad.ratio ** (ToutTinMassFlow[2]
                    * (powerBlock.temperature.inlet.kelvin
                      / HeatExchanger.parameter.temperature.htf.inlet.max.kelvin)
                    * 666 + ToutTinMassFlow[3]) + ToutTinMassFlow[4]
                // temperature.inlet changed to (Fluid.parameter.temperature.inlet / HeatExchanger.parameter.temperature.htf.inlet.max) * 666 because function is based on 393°C temperature.inlet
                temperaturFactor = HeatExchanger.setLimits(temperaturFactor)
                powerBlock.temperature.outlet =
                  HeatExchanger.parameter.temperature.htf.outlet.max
                  .adjusted(with: temperaturFactor)
              }
              let outlet = powerBlock.temperature.outlet.celsius
              heatExchanger.heatOut = 1.51129 * outlet
                + 1.2941 / 1_000 * outlet ** 2
                + 1.23697 / 10 ** 7 * outlet ** 3
                - 0.62677 // kJ/kg
              let BypassmassFlow = totalMassFlow - powerBlock.massFlow
              let inlet = powerBlock.temperature.inlet.celsius
              let Bypass_h = 1.51129 * inlet
                + 1.2941 / 1_000 * inlet ** 2
                + 1.23697 / 10 ** 7 * inlet ** 3
                - 0.62677 // kJ/kg
              let h_261 = 1.51129 * 261 + 1.2941 / 1_000 * 261 ** 2 + 1.23697
                / 10 ** 7 * 261 ** 3 - 0.62677 // kJ/kg
              heatExchanger.heatToTES = (BypassmassFlow.rate * Bypass_h
                + powerBlock.massFlow.rate * heatExchanger.heatOut)
                / (BypassmassFlow + powerBlock.massFlow).rate
              
              if heatExchanger.heatToTES < h_261 {
                break
              }
              
            }// Line 281
            powerBlock.temperature.outlet = Temperature((-0.000000000061133
              * heatExchanger.heatToTES ** 4 + 0.00000019425
              * heatExchanger.heatToTES ** 3 - 0.00032293
              * heatExchanger.heatToTES ** 2 + 0.65556
              * heatExchanger.heatToTES + 0.58315).toKelvin)
          }
        }
      }
      var heatdiff: Double = 0.0
      // Iteration: Find the right powerBlock.temperature.inlet and temperature.outlet
      innerLoop: while true {
        
        if Design.hasSolarField {
          heatFlow.solar = solarField.header.massFlow.rate
            * htf.heatDelta(solarField.header.temperature.outlet,
                            solarField.header.temperature.inlet) / 1_000
          
          let ICosTheta = Double(meteo.dni) * cos(Collector.theta)
          if ICosTheta == 0 { // added to avoid Q.solar > 0 during some night and freeze protection time
            heatFlow.solar = 0
          } 
          if heatFlow.solar > 0 {// Line 313
            heatFlow.production = heatFlow.solar
            powerBlock.temperature.inlet = solarField.header.temperature.outlet
            powerBlock.massFlow = solarField.header.massFlow
          } else { // if heatFlow.solar < 0
            if case .freezeProtection = solarField.operationMode {
              heatFlow.solar = 0
              heatFlow.production = 0
              powerBlock.massFlow = solarField.header.massFlow
              powerBlock.temperature.inlet = solarField.header.temperature.outlet
            } else {
              heatFlow.solar = 100
              heatFlow.production = 100
              powerBlock.massFlow = 0.0
              solarField.header.massFlow = 0.0
            }
          }
        } else {
          heatFlow.solar = 0
          heatFlow.production = 0
          powerBlock.massFlow = 0.0
          solarField.header.massFlow = 0.0
        }
        
        if Design.hasStorage {
          Storage.operate(
            &storage, powerBlock: &powerBlock, steamTurbine: &steamTurbine,
            heater: &heater, solarField: &solarField, boiler: boiler,
            gasTurbine: gasTurbine, heatExchanger: heatExchanger,
            availableFuel: &availableFuel, fuel: &fuel, heatFlow: &heatFlow)
        }
        var supplyGasTurbine: Double = 0.0
        if Design.hasGasTurbine {
          supplyGasTurbine = GasTurbine.operate(
            gasTurbine: &gasTurbine, availableFuel: &availableFuel,
            fuel: &fuel,
            electricEnergy: &electricEnergy,
            heatFlow: &heatFlow,
            boiler: boiler,
            steamTurbine: &steamTurbine, heatExchanger: heatExchanger)
        }
        
        if Design.hasHeater && !Design.hasBoiler { // Heater designed as primary backup
          // if Design.heater {  // supplementary HTF heater for Shams-1. Commented
          
          //   heatdiff = 0
          // restart variable to avoid errors due to Boiler.  added for Shams-1
          if case .pc = gasTurbine.operationMode {
            // Plant operates in Pure CC Mode now again without RH!!
            // demand * WasteHeatRecovery.parameter.effPure * (1 / gasTurbine.efficiency- 1)) heat supplied by the WHR system
          } else if case .ic = gasTurbine.operationMode { // Plant does not operate in Pure CC Mode
            let HTFenergy = (supplyGasTurbine * (1
              / GasTurbine.efficiency(at: gasTurbine.load) - 1)
              * WasteHeatRecovery.parameter.efficiencyNominal
              / WasteHeatRecovery.parameter.ratioHTF)
            heatdiff = heatFlow.production - HTFenergy // -^- necessary HTF share
            heater.operationMode = .unknown
            heater.temperature.inlet = powerBlock.temperature.outlet
            Heater.operate(&heater, powerBlock: &powerBlock,
                           steamTurbine: steamTurbine, storage: storage,
                           solarField: solarField,
                           demand: heatdiff,
                           availableFuel: availableFuel,
                           heatFlow: &heatFlow,
                           fuelFlow: &fuel.heater)
            electricalParasitics.heater = Heater.parasitics(at: heater.load)
            powerBlock.temperature.inlet = htf.mixingTemperature(
              inlet: powerBlock, with: heater)
            powerBlock.massFlow = powerBlock.massFlow + heater.massFlow
          } else if case .noOperation = gasTurbine.operationMode {
            // GasTurbine does not operate at all (Load<Min?)
            Heater.operate(&heater, powerBlock: &powerBlock,
                           steamTurbine: steamTurbine, storage: storage,
                           solarField: solarField,
                           demand: 0,
                           availableFuel: availableFuel,
                           heatFlow: &heatFlow,
                           fuelFlow: &fuel.heater)
            electricalParasitics.heater = Heater.parasitics(at: heater.load)
            powerBlock.temperature.inlet = htf.mixingTemperature(
              outlet: solarField, with: heater)
            powerBlock.massFlow = solarField.header.massFlow + heater.massFlow
          } else { // gasTurbine.OPmode is neither IC nor PC
            // Line 429 STO STO STO STO STO
            
            if Design.hasStorage {
              if heatdiff < 0,
                storage.heatrel < Storage.parameter.dischargeToTurbine,
                storage.heatrel > Storage.parameter.dischargeToHeater {
                // Direct Discharging to SteamTurbine and heatdiff > 0 (Energy Surplus) see above
                if availableFuel > 0 { // Fuel available, Storage for Pre-Heating
                  Storage.operate(
                    &storage, mode: .ph, boiler: boiler,
                    gasTurbine: gasTurbine, heatExchanger: heatExchanger,
                    powerBlock: &powerBlock, steamTurbine: &steamTurbine,
                    solarField: &solarField, heatFlow: &heatFlow)
                  //Storage.operate(mode: .ph, heatdiff, powerBlock.massFlow, hourFraction, heatFlow.storage)
                  heater.temperature.inlet = storage.temperature.outlet
                  heater.operationMode = .unknown
                  heatdiff = heatFlow.production + heatFlow.storage - heatFlow.demand
                  Heater.operate(&heater, powerBlock: &powerBlock,
                                 steamTurbine: steamTurbine, storage: storage,
                                 solarField: solarField,
                                 demand: heatdiff,
                                 availableFuel: availableFuel,
                                 heatFlow: &heatFlow,
                                 fuelFlow: &fuel.heater)
                  electricalParasitics.heater = Heater.parasitics(at: heater.load)
                  heater.massFlow = storage.massFlow
                  powerBlock.temperature.inlet = htf.mixingTemperature(
                    outlet: solarField, with: heater)
                  powerBlock.massFlow = solarField.header.massFlow + heater.massFlow
                } else { // NO Fuel Available -> Discharge directly with reduced TB load!
                  Storage.operate(
                    &storage, mode: .discharge, boiler: boiler,
                    gasTurbine: gasTurbine, heatExchanger: heatExchanger,
                    powerBlock: &powerBlock, steamTurbine: &steamTurbine,
                    solarField: &solarField, heatFlow: &heatFlow)
                  //Storage.operate(mode: .discharge, heatdiff, powerBlock.massFlow, hourFraction, heatFlow.storage)
                  powerBlock.temperature.inlet = htf.mixingTemperature(
                    outlet: solarField, with: storage)
                  powerBlock.massFlow = storage.massFlow + solarField.header.massFlow
                } // STORAGE: dischargeToHeater < Qrel < dischargeToTurbine;  Fuel/NoFuel
              } else if heatdiff < 0, storage.heatrel < Storage.parameter.dischargeToHeater,
                heater.operationMode != .freezeProtection {
                // = Storage is empty!! && Heater.operationMode != .freezeProtection // <= added instead of "<"
                heatdiff = heatFlow.production + heatFlow.wasteHeatRecovery
                  / HeatExchanger.parameter.efficiency - demand * heatFlow.demand
                // added to avoid heater use is storage is selected and checkbox marked:
                if heatFlow.production == 0 { // use heater only in parallel with solar field and not as stand alone.
                  // heatdiff = 0 // commented to use gas not only in paralell to SF (for AH1)
                  if Heater.parameter.onlyWithSolarField {
                    heatdiff = 0
                  }
                }
                heater.operationMode = .unknown
                heater.temperature.inlet = powerBlock.temperature.outlet
                Heater.operate(&heater, powerBlock: &powerBlock,
                               steamTurbine: steamTurbine, storage: storage,
                               solarField: solarField,
                               demand: heatdiff,
                               availableFuel: availableFuel,
                               heatFlow: &heatFlow,
                               fuelFlow: &fuel.heater)
                electricalParasitics.heater = Heater.parasitics(at: heater.load)
                powerBlock.temperature.inlet = htf.mixingTemperature(
                  outlet: solarField, with: heater)
                powerBlock.massFlow = solarField.header.massFlow + heater.massFlow
              }
              
            } else { // No Storage
              heatdiff = heatFlow.production + heatFlow.wasteHeatRecovery
                / HeatExchanger.parameter.efficiency - heatFlow.demand
              
              if heatFlow.production == 0 {
                // use heater only in parallel with solar field and not as stand alone.
                if Heater.parameter.onlyWithSolarField {
                  heatdiff = 0
                }
              }
              
              heater.operationMode = .unknown
              heater.temperature.inlet = powerBlock.temperature.outlet
              Heater.operate(&heater, powerBlock: &powerBlock,
                             steamTurbine: steamTurbine, storage: storage,
                             solarField: solarField,
                             demand: heatdiff,
                             availableFuel: availableFuel,
                             heatFlow: &heatFlow,
                             fuelFlow: &fuel.heater)
              electricalParasitics.heater = Heater.parasitics(at: heater.load)
              if (solarField.header.massFlow + heater.massFlow).isNearZero {
                powerBlock.temperature.inlet = powerBlock.temperature.inlet // Freeze Protection
              } else {
                powerBlock.temperature.inlet = htf.mixingTemperature(
                  outlet: solarField, with: heater)
              }
              powerBlock.massFlow = solarField.header.massFlow + heater.massFlow
            }
          }
          
          if !heater.massFlow.isNearZero {
            heatFlow.production = powerBlock.massFlow.rate
              * htf.heatDelta(powerBlock.temperature.inlet,
                              powerBlock.temperature.outlet) / 1_000
          }
        } // Line 535
        
        // Freeze Protection
        switch heater.operationMode {
        case .normal , .reheat:
          break
        default:
          if solarField.header.temperature.outlet <
            htf.freezeTemperature + Simulation.parameter.dfreezeTemperatureHeat,
            storage.massFlow.isNearZero { // No freeze protection heater use anymore if storage is in operation
            
            heater.temperature.inlet = powerBlock.temperature.inlet
            heater.massFlow = powerBlock.massFlow
            heater.operationMode = .freezeProtection
            Heater.operate(&heater, powerBlock: &powerBlock,
                           steamTurbine: steamTurbine, storage: storage,
                           solarField: solarField,
                           demand: .greatestFiniteMagnitude,
                           availableFuel: availableFuel,
                           heatFlow: &heatFlow,
                           fuelFlow: &fuel.heater)
            electricalParasitics.heater = Heater.parasitics(at: heater.load)
            switch heater.operationMode {
            case .freezeProtection:
              powerBlock.temperature.outlet = heater.temperature.outlet
            case .normal, .reheat: break
            default:
              if solarField.header.temperature.outlet.kelvin
                > htf.freezeTemperature.kelvin
                + Simulation.parameter.dfreezeTemperatureHeat.kelvin {
                heater.operationMode = .noOperation
                Heater.operate(&heater, powerBlock: &powerBlock,
                               steamTurbine: steamTurbine, storage: storage,
                               solarField: solarField,
                               demand: 0,
                               availableFuel: availableFuel,
                               heatFlow: &heatFlow,
                               fuelFlow: &fuel.heater)
                electricalParasitics.heater = Heater.parasitics(at: heater.load)
              }
            }
          }
        }// Heater.OPmode != "OP"
        // Freeze Protection
        
        // HX: powerBlock.temperature.inlet is known now, so calc. the real heatExchanger.temperature.outlet and heatFlow.production
        
        var storageNearFreeze = false
        if case .freezeProtection = storage.operationMode {
          storageNearFreeze = true
        }
        var solarFieldNearFreeze = false
        if case .freezeProtection = solarField.operationMode {
          solarFieldNearFreeze = true
        }
        var heaterAntiFreeze = false
        if case .freezeProtection = heater.operationMode {
          heaterAntiFreeze = true
        }
        
        if powerBlock.temperature.inlet
          < HeatExchanger.parameter.temperature.htf.inlet.min
          || powerBlock.massFlow.rate == 0
          || storageNearFreeze {
          // bypass HX
          
          if !heaterAntiFreeze && solarFieldNearFreeze || storageNearFreeze {
            
            if Design.hasGasTurbine {
              powerBlock.temperature.outlet = powerBlock.temperature.inlet
            } else {
              let TLPB = 0.0 // 0.38 * (TpowerBlock.status - meteo.temperature) / 100 * (30 / Design.layout.powerBlock) ** 0.5 // 0.38
              powerBlock.temperature.inlet =
                Temperature((solarField.header.massFlow.rate
                * solarField.header.temperature.outlet.kelvin
                + powerBlock.massFlow.rate * storage.temperature.outlet.kelvin)
                / (solarField.header.massFlow + powerBlock.massFlow).rate)
              
              // FIXME Was ist Tstatus ?????????
              
              powerBlock.temperature.outlet =
                Temperature(powerBlock.massFlow.rate
                * Double(period) * powerBlock.temperature.inlet.kelvin
                  + powerBlock.temperature.outlet.kelvin
                * (SolarField.parameter.HTFmass
                  - powerBlock.massFlow.rate * Double(period))
                / SolarField.parameter.HTFmass - TLPB)
            }
          }
          heatFlow.production = 0
          heatFlow.heatExchanger = 0
          heatExchanger.massFlow = 0.0
          //break innerLoop //FIXME why is this slower
        }
        
        heatExchanger.massFlow = powerBlock.massFlow
        heatExchanger.massFlow = 100.0 // FIXME added for testing
        heatExchanger.temperature.inlet = powerBlock.temperature.inlet
        Plant.heatFlow.heatExchanger = HeatExchanger.operate(
          &heatExchanger, steamTurbine: steamTurbine, storage: storage)
        
        if Design.hasGasTurbine,
          Design.hasStorage,
          heatFlow.heatExchanger > HeatExchanger.parameter.SCCHTFheatFlow {
          heatFlow.dump += heatFlow.heatExchanger - HeatExchanger.parameter.SCCHTFheatFlow
          heatFlow.heatExchanger = HeatExchanger.parameter.SCCHTFheatFlow
        }
        
        if abs((powerBlock.temperature.outlet - heatExchanger.temperature.outlet).kelvin)
          < Simulation.parameter.tempTolerance.kelvin {
          break innerLoop
        }
        
        powerBlock.temperature.outlet = heatExchanger.temperature.outlet
        // TpowerBlock.status = powerBlock.temperature.outlet
      } // Iteration ends: Find the right powerBlock.temperature.inlet and temperature.outlet
      
      // FIXME   H2OinPB = H2OinHX
      
      heatFlow.production = heatFlow.heatExchanger + heatFlow.wasteHeatRecovery
      heatFlow.demand *= HeatExchanger.parameter.efficiency
      // Therm heat demand is lower after HX:
      heatFlow.production *= Simulation.parameter.adjustmentFactor.heatLossH2O
      // - Unavoidable losses in Power Block -
      var Qsf_load = 0.0
      if Design.hasBoiler { // - if Boiler is designed -
        let adjustmentFactor = Simulation.parameter.adjustmentFactor
        if case .solarOnly = Control.whichOptimization {
         
          if heatFlow.production < adjustmentFactor.efficiencyHeater,
            heatFlow.production >= adjustmentFactor.efficiencyBoiler {
            
            switch boiler.operationMode {
            case .startUp, .SI, .NI:
              break
            default:
              boiler.operationMode = .unknown
            }
            
            heatdiff = heatFlow.production - heatFlow.demand
            if Boiler.parameter.booster { // booster superheater
              if heatFlow.heater == Design.layout.heater { // Firm Output case
                // for shams-1 769% of the boiler load is used during firm output. no time to find a nice formula. sorry!
                Qsf_load = 0.769
              } else {
                Qsf_load = heatFlow.production
                  / (Design.layout.heatExchanger
                    / SteamTurbine.parameter.efficiencyNominal)
              }
            }
            
            // H2OinBO.temperature.inlet = H2OinPB.temperature.outlet
          } else {
            boiler.operationMode = .noOperation(hours: 0)
          }
        }
        /*
         if Heater.parameter.operationMode { // Shams project
         // first 30 minutes during PB startup no gas is used. Not considered for firm output (HR >0)
         if SteamTurbinestartUpTime <= 30 && heatFlow.heater = 0 {
         heatdiff = 0
         }
         }
         */
        
        if heatFlow.heater == Design.layout.heater { // Firm Output case
          // for shams-1 769% of the boiler load is used during firm output. no time to find a nice formula. sorry!
          Qsf_load = 0.769
        } else {
          Qsf_load = heatFlow.production
            / (Design.layout.heatExchanger
              / SteamTurbine.parameter.efficiencyNominal)
        }
        
        heatFlow.boiler = Boiler.operate(
          &boiler, heatFlow: heatdiff, Qsf_load: Qsf_load,
          availableFuel: &availableFuel, fuelFlow: &fuel.boiler)
        electricalParasitics.boiler = Boiler.parasitics(boiler: boiler)
        if Fuelmode == "predefined" { // predefined fuel consumption in *.pfc-file
          if (heatFlow.heatExchanger + heatFlow.boiler) > 110 {
            heatFlow.boiler = 105 - heatFlow.heatExchanger
          }
          
          heatFlow.production = (heatFlow.heatExchanger + heatFlow.wasteHeatRecovery)
            * adjustmentFactor.heatLossH2O + heatFlow.boiler
        }
      }
      // *************  From here: use only heatFlow.production !  ************************
      
      // Check if thermal heat is witheatIn acceptable limits
      
      if heatFlow.production - SteamTurbine.parameter.power.max
        / SteamTurbine.efficiency(at: steamTurbine.load, Lmax: 1.0,
                                  boiler: boiler, gasTurbine: gasTurbine,
                                  heatExchanger: heatExchanger)
        > Simulation.parameter.heatTolerance { // TB.Overload
        // report = " Overloading TB: " + Str$(heatFlow.production - SteamTurbine.parameter.power.max / SteamTurbine.parameter.efficiencyNominal) + " MWH,th\n"
      } else if heatFlow.production - heatFlow.demand > 2 * Simulation.parameter.heatTolerance {
        // report = " Production > demand: " + Str$(heatFlow.production - heatFlow.demand) + " MWH,th\n"
      }
      let PminT = SteamTurbine.parameter.PminT
      if (PminT[0] == 1 || PminT[0] == 0)
        && PminT[1] == 0 && PminT[2] == 0 && PminT[3] == 0 && PminT[4] == 0 {
        
        // FIXME SteamTurbine.parameter.PminLim = SteamTurbine.parameter.pressure.min / SteamTurbine.parameter.power.max
      } else {
        // FIXME SteamTurbine.parameter.PminLim = SteamTurbine.parameter.PminfT / SteamTurbine.parameter.power.max
      }
      
      /* if Heater.parameter.operationMode {
       SteamTurbine.parameter.efficiencyFirmOutput = SteamTurbine.efficiency(SteamTurbine.parameter.Lmin, Lmax) // only for shams-1
       
       if Heater.parameter.operationMode { // Changed for Dry Cooling
       SteamTurbine.parameter.efficiencyFirmOutput = SteamTurbine.efficiencyFor(SteamTurbine.parameter.Lmin, Lmax: Lmax) // only for shams-1
       } else {
       SteamTurbine.parameter.efficiencyFirmOutput = SteamTurbine.parameter.efficiencyNominal
       }
       */
      // not used !!! var Qblank: Double
      
      if (PminT[0] == 1 || PminT[0] == 0)
        && PminT[1] == 0 && PminT[2] == 0 && PminT[3] == 0 && PminT[4] == 0 {
        
        if 0 < heatFlow.production
          && heatFlow.production
          < SteamTurbine.parameter.power.min
          / SteamTurbine.parameter.efficiencyNominal {
          // report = "Damping (SteamTurbine underload):" + (heatFlow.production) + "MWH,th\n"
          // not used !!! Qblank = heatFlow.production
          heatFlow.production = 0
        }
      } else {
        if 0 < heatFlow.production && heatFlow.production
          < steamTurbine.PminfT / SteamTurbine.efficiency(
            at: steamTurbine.load, Lmax: 1.0,
            boiler: boiler, gasTurbine: gasTurbine, heatExchanger: heatExchanger) {
          // efficiency at min. load instead of nominal, has effect for dry cooling!
          // report = "Damping (SteamTurbine underload):" + (heatFlow.production) + "MWH,th\n"
          // not used !!! Qblank = heatFlow.production
          heatFlow.production = 0
        }
      }
      
      let qad = heatFlow.storage + heatFlow.boiler
      
      electricEnergy.steamTurbineGross = PowerBlock.operate(
        heat: &heatFlow.production,
        electricalParasitics: &electricalParasitics.powerBlock,
        steamTurbine: &steamTurbine, gasTurbine: gasTurbine,
        heatExchanger: heatExchanger, solarField: solarField,
        heater: heater, boiler: boiler,
        Qsto: qad, meteo: meteo)
        * SteamTurbine.efficiency(at: steamTurbine.load, Lmax: 1.0,
                                  boiler: boiler, gasTurbine: gasTurbine,
                                  heatExchanger: heatExchanger)
      
      if heatFlow.production == 0 { // added to separate shared facilities parasitics
        electricalParasitics.shared = PowerBlock.parameter.electricalParasiticsShared[0] // no operation
      } else {
        electricalParasitics.shared = PowerBlock.parameter.electricalParasiticsShared[1] // operation and start up
      }
      
      if Fuelmode == "predefined" { // predifined fuel consumption in *.pfc-file
        if fuel.combined > 0 && electricEnergy.steamTurbineGross
          > SteamTurbine.parameter.power.max + 1 {
          electricEnergy.steamTurbineGross = SteamTurbine.parameter.power.max + 1
        }
        if fuel.combined > 0, heatFlow.solar > 0,
          electricEnergy.steamTurbineGross > SteamTurbine.parameter.power.max - 1 {
          electricEnergy.steamTurbineGross = SteamTurbine.parameter.power.max - 1
        }
      }
      
      if Design.hasStorage {
        if case .always = Storage.parameter.strategy {}
        else if electricEnergy.steamTurbineGross > electricEnergy.demand { // new restriction of production
          dumping = electricEnergy.steamTurbineGross - electricEnergy.demand
          electricEnergy.steamTurbineGross = electricEnergy.demand
        }
      } else { /* if Heater.parameter.operationMode */ // following uncomment for Shams-1.
        if electricEnergy.steamTurbineGross > electricEnergy.demand {
          dumping = electricEnergy.steamTurbineGross - electricEnergy.demand
            * (electricEnergy.demand / electricEnergy.steamTurbineGross)
          heatdiff = heatdiff * (electricEnergy.demand / electricEnergy.steamTurbineGross)
          Qsf_load *= (electricEnergy.demand / electricEnergy.steamTurbineGross)
          
          heatFlow.boiler = Boiler.operate(
            &boiler, heatFlow: heatdiff, Qsf_load: Qsf_load,
            availableFuel: &availableFuel, fuelFlow: &fuel.boiler)
          
          electricalParasitics.boiler = Boiler.parasitics(boiler: boiler)
          heatFlow.solar = heatFlow.solar
            * (electricEnergy.demand / electricEnergy.steamTurbineGross)
          // reduction in Qsol should be necessary for every project withoput storage
          heatFlow.heatExchanger = heatFlow.heatExchanger
            * (electricEnergy.demand / electricEnergy.steamTurbineGross)
          
          let qad = heatFlow.storage + heatFlow.boiler
          
          electricEnergy.steamTurbineGross = PowerBlock.operate(
            heat: &heatFlow.production,
            electricalParasitics: &electricalParasitics.powerBlock,
            steamTurbine: &SteamTurbine.status, gasTurbine: gasTurbine,
            heatExchanger: heatExchanger, solarField: solarField, heater: heater,
            boiler: boiler,
            Qsto: qad, meteo: meteo) * SteamTurbine.efficiency(
              at: steamTurbine.load, Lmax: 1.0,
              boiler: boiler, gasTurbine: gasTurbine, heatExchanger: heatExchanger)
          
          if heatFlow.production == 0 { // added to separate shared facilities parasitics
            electricalParasitics.shared =
              PowerBlock.parameter.electricalParasiticsShared[0]
          } else {
            electricalParasitics.shared =
              PowerBlock.parameter.electricalParasiticsShared[1]
          }
        }
      }
      
      electricEnergy.gross = electricEnergy.steamTurbineGross
        + electricEnergy.gasTurbineGross
      
      // + GasTurbine = total productionuced electricity
      electricEnergy.solarField = electricalParasitics.solarField
        + electricalParasitics.storage
      electricEnergy.storage = electricalParasitics.storage
      
      // electricEnergy.parasiticsBU = electricalParasitics.heater + electricalParasitics.boiler
      electricEnergy.powerBlock = electricalParasitics.powerBlock
      electricEnergy.shared = electricalParasitics.shared
      
      electricEnergy.parasitics = electricEnergy.solarField
        + electricEnergy.gasTurbine
        + electricalParasitics.powerBlock
        + electricalParasitics.shared
      
      electricEnergy.parasitics *=
        Simulation.parameter.adjustmentFactor.electricalParasitics
      let parasitics = abs(electricalParasiticsAssumed - electricEnergy.parasitics)
      if parasitics < 3 * Simulation.parameter.electricalTolerance {
        /*
         if Heater.parameter.operationMode = 3 {
         if FirmOutput {
         DSumHR = DSumHR + heatFlow.heater
         YSumHR = YSumHR + heatFlow.heater
         } else {
         ConsHours = ConsHours + (1 * CalcTime% / 3_600)
         }
         } else {
         DSumHR = DSumHR + heatFlow.heater
         YSumHR = YSumHR + heatFlow.heater
         }*/
        if heatFlow.heater > 0 {
          //oldHR = heatFlow.heater
        }
        break outerLoop
      }
      
      electricalParasiticsAssumed = electricEnergy.parasitics
      
      if Design.hasBoiler {
        if case .startUp = boiler.operationMode {
          boiler.operationMode = .SI
        } else if case .noOperation = boiler.operationMode {
          boiler.operationMode = .NI
        }
      }
    } // Iteration to account for correct parasitics
    heatFlow.dump += dumping
    
    electricEnergy.net = electricEnergy.gross - electricEnergy.parasitics // - Net electric power -
    
    if electricEnergy.net < 0 {
      electricEnergy.consum = -electricEnergy.net
      electricEnergy.net = 0
    } else {
      electricEnergy.consum = 0
    }
    
    if Design.hasGasTurbine {
      electricEnergy.demand = demand
        * (Design.layout.powerBlock - Design.layout.gasTurbine) // just for WriteOpRep
    } else {
      electricEnergy.demand = SteamTurbine.parameter.power.max
    }
    
    if true /* Ctl.AS = 1 */&& heatFlow.solar > 0 {
      // Average HTF temp. in loop [K]
      heatFlow.solar = heatFlow.solar
        + (1 - SolarField.parameter.SSFHL / SolarField.parameter.pipeHL)
        * SolarField.pipeHeatLoss(
          solarField.header.averageTemperature, ambient: ambientTemperature)
        * Design.layout.solarField
        * Double(SolarField.parameter.numberOfSCAsInRow)
        * 2 * Collector.parameter.areaSCAnet / 1_000_000
    }
    // H2OinHX.temperature.inlet = H2OinPB.temperature.outlet
  }
}
