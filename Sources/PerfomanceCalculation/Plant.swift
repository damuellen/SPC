//
//  Copyright (c) 2017 Daniel Müllenborn. All rights reserved.
//  Distributed under the The Non-Profit Open Software License version 3.0
//  http://opensource.org/licenses/NPOSL-3.0
//
//  This project is NOT free software. It is open source, you are allowed to
//  modify it (if you keep the license), but it may not be commercially
//  distributed other than under the conditions noted above.
//

import Foundation
import Meteo
import Config

enum Plant {

  static var location: Location!
  static var ambientTemperature = Temperature.zero
  static var availability = Availability.withDefaults()
  static var electricEnergy = ElectricEnergy()
  static var electricalParasitics = Components()
  static var heatFlow = HeatFlow()
  static var fuel = FuelConsumption()
  
  static func operate(demand: Double,
                      availableFuel: inout Double,
                      meteo: MeteoData,
                      boiler: inout Boiler.PerformanceData,
                      powerBlock: inout PowerBlock.PerformanceData,
                      solarField: inout SolarField.PerformanceData,
                      steamTurbine: inout SteamTurbine.PerformanceData,
                      heater: inout Heater.PerformanceData,
                      heatExchanger: inout HeatExchanger.PerformanceData,
                      storage: inout Storage.PerformanceData) {

    ambientTemperature = Temperature(meteo.temperature.toKelvin)

    // storage.mass.hot = HeatExchanger.parameter.temperature.h2o.inlet.max
    // storage.mass.cold = HeatExchanger.parameter.temperature.h2o.inlet.min
    
    // storage.mass.hot = Storage.parameter.startLoad.hot
    // storage.mass.cold = Storage.parameter.startLoad.cold
    storage.temperatureTank.hot = HeatExchanger.parameter.temperature.h2o.outlet.max
    storage.temperatureTank.cold = HeatExchanger.parameter.temperature.h2o.outlet.max
    
    var Pmin: Double = 0.0
    for i in SteamTurbine.parameter.PminT.indices {
      Pmin += (SteamTurbine.parameter.PminT[i] * (ambientTemperature.value ** Double(i)))
    }
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
      
      steamTurbine.load = Ratio(max(0, (electricEnergy.demand + Design.layout.gasTurbine)
        / SteamTurbine.parameter.power.max)) // TB Load

      switch Storage.parameter.strategy {
      case .demand:
        heatFlow.demand = min(
          HeatExchanger.parameter.SCCHTFheatFlow,
          SteamTurbine.parameter.power.max / SteamTurbine.efficiency)
      // * demand deleted, should be 100% demand (?)// comparison with HX cap. written to restrict HX capacity
      case .shifter:
        heatFlow.demand = min(
          HeatExchanger.parameter.SCCHTFheatFlow,
          SteamTurbine.parameter.power.max * demand / SteamTurbine.efficiency)
      // strategy ful added again, same as always? comparison with HX cap. written to restrict HX capacity
      default:
        heatFlow.demand = min(HeatExchanger.parameter.SCCHTFheatFlow,
                              electricEnergy.demand / SteamTurbine.efficiency)
        //  demand deleted since is calculated before in electricEnergy.demand
        //  demand added because electricEnergy.demand is only SteamTurbine.parameter.power.max
        //  steamTurbine.load // wird hier jetzt mit electricEnergy.demand berechnet,
        //  comparison with HX cap. written to restrict HX capacity
      }
      
      if steamTurbine.isMaintained {
        steamTurbine.load = 0.0
        electricEnergy.demand = 0
        heatFlow.demand = 0
      } else if steamTurbine.load > Plant.availability[PerformanceCalculator.dateTime].powerBlock { // - TB Load > Availability -
        steamTurbine.load = Plant.availability[PerformanceCalculator.dateTime].powerBlock
        heatFlow.demand = min(
          HeatExchanger.parameter.SCCHTFheatFlow,
          SteamTurbine.parameter.power.max
            * Plant.availability[PerformanceCalculator.dateTime].powerBlock.value
            / SteamTurbine.efficiency)
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
      if powerBlock.massFlow > 0 {
        
        if powerBlock.temperature.inlet >= HeatExchanger.parameter.temperature.htf.inlet.min {
          
          HeatExchanger.operate(powerBlock: &powerBlock)
          // Line 236
          if case .ex = storage.operationMode, powerBlock.temperature.outlet.isLower(than: 261.toKelvin) {
            // added to simulate a bypass on the PB-HX if the expected outlet temp is so low that the salt to TES could freeze
            let totalMassFlow = powerBlock.massFlow
            for _ in 1 ... 100 {
              let massFlowLoad = Ratio(powerBlock.massFlow / SolarField.parameter.massFlow.max)
              
              if HeatExchanger.parameter.Tout_f_Mfl,
                !HeatExchanger.parameter.Tout_f_Tin,
                !HeatExchanger.parameter.useAndsolFunction,
                let ToutMassFlow = HeatExchanger.parameter.ToutMassFlow {
                
                // if temperature.outlet is dependant on massflow, recalculate temperature.outlet
                var temperaturFactor = ToutMassFlow[massFlowLoad]
                if temperaturFactor > 1 { temperaturFactor = 1 }
                powerBlock.temperature.outlet = HeatExchanger.parameter.temperature.htf.outlet.max
                  .adjusted(with: temperaturFactor)
                
              } else if HeatExchanger.parameter.Tout_f_Mfl,
                HeatExchanger.parameter.Tout_f_Tin,
                !HeatExchanger.parameter.useAndsolFunction,
                let ToutMassFlow = HeatExchanger.parameter.ToutMassFlow,
                let ToutTin = HeatExchanger.parameter.ToutTin {
                
                var temperaturFactor = ToutMassFlow[massFlowLoad]
                temperaturFactor *= ToutTin[powerBlock.temperature.inlet]
                powerBlock.temperature.outlet = HeatExchanger.parameter.temperature.htf.outlet.max
                  .adjusted(with: temperaturFactor)
                
              } else if HeatExchanger.parameter.useAndsolFunction {
                var temperaturFactor = (
                  (0.0007592419869 * (powerBlock.temperature.inlet.value
                  / HeatExchanger.parameter.temperature.htf.inlet.max.value)
                  * 666 + 0.4943825893223)
                  * massFlowLoad.value ** (0.0001400823882
                    * (powerBlock.temperature.inlet.value
                    / HeatExchanger.parameter.temperature.htf.inlet.max.value)
                    * 666 - 0.0110227028559)) - 0.000151639
                // temperature.inlet changed to (Fluid.parameter.temperature.inlet / HeatExchanger.parameter.temperature.htf.inlet.max) * 666 because function is based on 393°C temperature.inlet
                temperaturFactor = HeatExchanger.setLimits(temperaturFactor)
                powerBlock.temperature.outlet = HeatExchanger.parameter.temperature.htf.outlet.max
                  .adjusted(with: temperaturFactor)
                
              } else if HeatExchanger.parameter.Tout_exp_Tin_Mfl,
                let ToutTinMassFlow = HeatExchanger.parameter.ToutTinMassFlow {
                
                var temperaturFactor = (ToutTinMassFlow[0]
                  * (powerBlock.temperature.inlet.value
                    / HeatExchanger.parameter.temperature.htf.inlet.max.value)
                  * 666 + ToutTinMassFlow[1])
                  * massFlowLoad.value ** (ToutTinMassFlow[2]
                    * (powerBlock.temperature.inlet.value
                      / HeatExchanger.parameter.temperature.htf.inlet.max.value) * 666
                    + ToutTinMassFlow[3]) + ToutTinMassFlow[4]
                // temperature.inlet changed to (Fluid.parameter.temperature.inlet / HeatExchanger.parameter.temperature.htf.inlet.max) * 666 because function is based on 393°C temperature.inlet
                temperaturFactor = HeatExchanger.setLimits(temperaturFactor)
                powerBlock.temperature.outlet = HeatExchanger.parameter.temperature.htf.outlet.max
                  .adjusted(with: temperaturFactor)
              }
              let HX_hout = 1.51129 * (powerBlock.temperature.outlet.toCelsius)
                + 1.2941 / 1_000 * (powerBlock.temperature.outlet.toCelsius) ** 2
                + 1.23697 / 10 ** 7 * (powerBlock.temperature.outlet.toCelsius) ** 3
                - 0.62677 // kJ/kg
              let BypassmassFlow = totalMassFlow - powerBlock.massFlow
              let Bypass_h = 1.51129 * (powerBlock.temperature.inlet.toCelsius)
                + 1.2941 / 1_000 * (powerBlock.temperature.inlet.toCelsius) ** 2
                + 1.23697 / 10 ** 7 * (powerBlock.temperature.inlet.toCelsius) ** 3
                - 0.62677 // kJ/kg
              let h_261 = 1.51129 * 261 + 1.2941 / 1_000 * 261 ** 2 + 1.23697
                / 10 ** 7 * 261 ** 3 - 0.62677 // kJ/kg
              heatExchanger.htoTES = (BypassmassFlow * Bypass_h + powerBlock.massFlow * HX_hout)
                / (BypassmassFlow + powerBlock.massFlow)
              
              if heatExchanger.htoTES < h_261 {
                break
              }
              
            }// Line 281
            powerBlock.temperature.outlet = Temperature((-0.000000000061133
              * heatExchanger.htoTES ** 4 + 0.00000019425
              * heatExchanger.htoTES ** 3 - 0.00032293
              * heatExchanger.htoTES ** 2 + 0.65556
              * heatExchanger.htoTES + 0.58315).toKelvin)
          }
        }
      }
      var heatdiff: Double = 0.0
      // Iteration: Find the right powerBlock.status.temperature.inlet and temperature.outlet
      innerLoop: while true {
        
        if Design.hasSolarField {
          heatFlow.solar = solarField.header.massFlow
            * htf.heatTransfered(solarField.header.temperature.outlet,
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
              powerBlock.massFlow = 0
              solarField.header.massFlow = 0
            }
          }
        } else {
          heatFlow.solar = 0
          heatFlow.production = 0
          powerBlock.massFlow = 0
          solarField.header.massFlow = 0
        }
        
        Storage.operate(&storage,
                        powerBlock: &powerBlock,
                        heater: &heater,
                        solarField: &solarField,
                        availableFuel: &availableFuel,
                        fuel: &fuel,
                        heatFlow: &heatFlow)
        
        var supplyGasTurbine: Double = 0.0
        if Design.hasGasTurbine {
          supplyGasTurbine = GasTurbine.operate(
            availableFuel: &availableFuel,
            fuel: &fuel,
            electricEnergy: &electricEnergy,
            heatFlow: &heatFlow,
            steamTurbine: &steamTurbine)
        }
        
        if Design.hasHeater && !Design.hasBoiler { // Heater designed as primary backup
          // if Design.heater {  // supplementary HTF heater for Shams-1. Commented
          
          //   heatdiff = 0
          // restart variable to avoid errors due to Boiler.  added for Shams-1
          if case .pc = GasTurbine.status.operationMode {
            // Plant operates in Pure CC Mode now again without RH!!
            // demand * WasteHeatRecovery.parameter.effPure * (1 / GasTurbine.status.efficiency- 1)) heat supplied by the WHR system
          } else if case .ic = GasTurbine.status.operationMode { // Plant does not operate in Pure CC Mode
            let HTFheat = (supplyGasTurbine * (1 / GasTurbine.efficiency - 1)
              * WasteHeatRecovery.parameter.efficiencyNominal
              / WasteHeatRecovery.parameter.ratioHTF)
            heatdiff = heatFlow.production - HTFheat // -^- necessary HTF share
            heater.operationMode = .unknown
            heater.temperature.inlet = powerBlock.temperature.outlet
            heatFlow.heater = Heater.operate(&heater, demand: heatdiff,
                                             availableFuel: availableFuel,
                                             fuelFlow: &fuel.heater)
            electricalParasitics.heater = Heater.parasitics
            powerBlock.temperature.inlet = htf.mixingTemperature(
              inlet: powerBlock, with: heater)
            powerBlock.massFlow = powerBlock.massFlow + heater.massFlow
          } else if case .noOperation = GasTurbine.status.operationMode {
            // GasTurbine does not operate at all (Load<Min?)
            heatFlow.heater = Heater.operate(&heater, demand: 0,
                                             availableFuel: availableFuel,
                                             fuelFlow: &fuel.heater)
            electricalParasitics.heater = Heater.parasitics
            powerBlock.temperature.inlet = htf.mixingTemperature(
              outlet: solarField, with: heater)
            powerBlock.massFlow = solarField.header.massFlow + heater.massFlow
          } else { // GasTurbine.status.OPmode is neither IC nor PC
            // Line 429 STO STO STO STO STO
            
            if Design.hasStorage {
              if heatdiff < 0, storage.heatrel < Storage.parameter.dischargeToTurbine,
                storage.heatrel > Storage.parameter.dischargeToHeater {
                // Direct Discharging to SteamTurbine and heatdiff > 0 (Energy Surplus) see above
                if availableFuel > 0 { // Fuel available, Storage for Pre-Heating
                  Storage.operate(&storage, mode: .ph, solarField: &solarField, heatFlow: &heatFlow)
                  //Storage.operate(mode: .ph, heatdiff, powerBlock.massFlow, hourFraction, heatFlow.storage)
                  heater.temperature.inlet = storage.temperature.outlet
                  heater.operationMode = .unknown
                  heatdiff = heatFlow.production + heatFlow.storage - heatFlow.demand
                  heatFlow.heater = Heater.operate(&heater, demand: heatdiff,
                                                   availableFuel: availableFuel,
                                                   fuelFlow: &fuel.heater)
                  electricalParasitics.heater = Heater.parasitics
                  heater.massFlow = storage.massFlow
                  powerBlock.temperature.inlet = htf.mixingTemperature(
                    outlet: solarField, with: heater)
                  powerBlock.massFlow = solarField.header.massFlow + heater.massFlow
                } else { // NO Fuel Available -> Discharge directly with reduced TB load!
                  Storage.operate(&storage,mode: .discharge, solarField: &solarField, heatFlow: &heatFlow)
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
                  if Heater.parameter.onlyWithSolarField { // added as user input
                    heatdiff = 0
                  }
                }
                heater.operationMode = .unknown
                heater.temperature.inlet = powerBlock.temperature.outlet
                heatFlow.heater = Heater.operate(&heater, demand: heatdiff,
                                                 availableFuel: availableFuel,
                                                 fuelFlow: &fuel.heater)
                electricalParasitics.heater = Heater.parasitics
                powerBlock.temperature.inlet = htf.mixingTemperature(
                  outlet: solarField, with: heater)
                powerBlock.massFlow = solarField.header.massFlow + heater.massFlow
              }
              
            } else { // No Storage
              heatdiff = heatFlow.production + heatFlow.wasteHeatRecovery
                / HeatExchanger.parameter.efficiency - heatFlow.demand
              
              if heatFlow.production == 0 {
                // use heater only in parallel with solar field and not as stand alone.
                if Heater.parameter.onlyWithSolarField { // added as user input
                  heatdiff = 0
                }
              }
              
              heater.operationMode = .unknown
              heater.temperature.inlet = powerBlock.temperature.outlet
              heatFlow.heater = Heater.operate(&heater, demand: heatdiff,
                                               availableFuel: availableFuel,
                                               fuelFlow: &fuel.heater)
              electricalParasitics.heater = Heater.parasitics
              if solarField.header.massFlow + heater.massFlow == 0 {
                powerBlock.temperature.inlet = powerBlock.temperature.inlet // Freeze Protection
              } else {
                powerBlock.temperature.inlet = htf.mixingTemperature(
                  outlet: solarField, with: heater)
              }
              powerBlock.massFlow = solarField.header.massFlow + heater.massFlow
            }
          }
          
          if heater.massFlow > 0 {
            heatFlow.production = powerBlock.massFlow * htf.heatTransfered(
              powerBlock.temperature.inlet, powerBlock.temperature.outlet) / 1_000
          }
        } // Line 535
        
        // Freeze Protection
        switch heater.operationMode {
        case .normal , .reheat:
          break
        default:
          if solarField.header.temperature.outlet <
            htf.freezeTemperature + Simulation.parameter.dfreezeTemperatureHeat,
            storage.massFlow == 0 { // No freeze protection heater use anymore if storage is in operation
            
            heater.temperature.inlet = powerBlock.temperature.inlet
            heater.massFlow = powerBlock.massFlow
            heater.operationMode = .freezeProtection
            heatFlow.heater = Heater.operate(&heater, demand: .greatestFiniteMagnitude,
                                             availableFuel: availableFuel,
                                             fuelFlow: &fuel.heater)
            electricalParasitics.heater = Heater.parasitics
            switch heater.operationMode {
            case .freezeProtection:
              powerBlock.temperature.outlet = heater.temperature.outlet
            case .normal, .reheat: break
            default:
              if solarField.header.temperature.outlet.value > htf.freezeTemperature.value
                + Simulation.parameter.dfreezeTemperatureHeat.value {
                heater.operationMode = .noOperation
                heatFlow.heater = Heater.operate(&heater, demand: 0,
                                                 availableFuel: availableFuel,
                                                 fuelFlow: &fuel.heater)
                electricalParasitics.heater = Heater.parasitics
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
        
        if powerBlock.temperature.inlet < HeatExchanger.parameter.temperature.htf.inlet.min
          || powerBlock.massFlow == 0
          || storageNearFreeze {
          // bypass HX
          
          if !heaterAntiFreeze && solarFieldNearFreeze || storageNearFreeze {

            if Design.hasGasTurbine {
              powerBlock.temperature.outlet = powerBlock.temperature.inlet
            } else {
              let TLPB = 0.0 // 0.38 * (TpowerBlock.status - meteo.temperature) / 100 * (30 / Design.layout.powerBlock) ** 0.5 // 0.38
              powerBlock.temperature.inlet = Temperature((solarField.header.massFlow
                * solarField.header.temperature.outlet.value
                + powerBlock.massFlow * storage.temperature.outlet.value)
                / (solarField.header.massFlow + powerBlock.massFlow))
              
              // FIXME Was ist Tstatus ?????????
              
              powerBlock.temperature.outlet = Temperature(powerBlock.massFlow
                * Double(period) * powerBlock.temperature.inlet.value /* + TpowerBlock.status */
                * (SolarField.parameter.HTFmass - powerBlock.massFlow * Double(period))
                / SolarField.parameter.HTFmass - TLPB)
              /* TpowerBlock.status = powerBlock.temperature.outlet */
            }
          }
          heatFlow.production = 0
          heatFlow.heatExchanger = 0
          heatExchanger.massFlow = 0
        //  break innerLoop
        }
        
        heatExchanger.massFlow = powerBlock.massFlow
        heatExchanger.temperature.inlet = powerBlock.temperature.inlet
        HeatExchanger.operate(&heatExchanger)
        
        if Design.hasGasTurbine,
          Design.hasStorage,
          heatFlow.heatExchanger > HeatExchanger.parameter.SCCHTFheatFlow {
          heatFlow.dump += heatFlow.heatExchanger - HeatExchanger.parameter.SCCHTFheatFlow
          heatFlow.heatExchanger = HeatExchanger.parameter.SCCHTFheatFlow
        }
        
        if abs((powerBlock.temperature.outlet - heatExchanger.temperature.outlet).value) < Simulation.parameter.tempTolerance.value {
          break innerLoop
        }
        
        powerBlock.temperature.outlet = heatExchanger.temperature.outlet
        // TpowerBlock.status = powerBlock.temperature.outlet
      } // Iteration ends: Find the right powerBlock.status.temperature.inlet and temperature.outlet
      
      // FIXME   H2OinPB = H2OinHX
      
      heatFlow.production = heatFlow.heatExchanger + heatFlow.wasteHeatRecovery
      heatFlow.demand *= HeatExchanger.parameter.efficiency // Therm heat demand is lower after HX:
      heatFlow.production *= Simulation.parameter.adjustmentFactor.heatLossH2O // - Unavoidable losses in Power Block -
      
      if Design.hasBoiler { // - if Boiler is designed -
        /*
         if Ctl.WhichOptim > 1 {
         if (heatFlow.production < Simulation.parameter.adjustmentFactor.efficiencyHeater
         && heatFlow.production >= Simulation.parameter.adjustmentFactor.efficiencyBoiler) {
         
         switch Boiler.status.operationMode {
         case .startUp, .SI ,.NI:
         break
         default:
         Boiler.status.operationMode = .unknown
         }
         
         heatdiff = heatFlow.production - heatFlow.demand
         if Boiler.parameter.booster { // booster superheater
         if heatFlow.heater == Design.layout.heater { // Firm Output case
         // for shams-1 769% of the boiler load is used during firm output. no time to find a nice formula. sorry!
         var Qsf_load = 0.769
         } else {
         var Qsf_load = heatFlow.production / (Design.layout.heatExchanger / SteamTurbine.parameter.efficiencyNominal)
         }
         }
         H2OinBO.temperature.inlet = H2OinPB.temperature.outlet
         } else {
         Boiler.status.operationMode = .noOperation(hours: 0)
         }
         }
         
         if Heater.parameter.operationMode { // Shams project
         // first 30 minutes during PB startup no gas is used. Not considered for firm output (HR >0)
         if SteamTurbinestartUpTime <= 30 && heatFlow.heater = 0 {
         heatdiff = 0
         }
         }
         */
        var Qsf_load: Double
        if heatFlow.heater == Design.layout.heater { // Firm Output case
          // for shams-1 769% of the boiler load is used during firm output. no time to find a nice formula. sorry!
          Qsf_load = 0.769
        } else {
          Qsf_load = heatFlow.production
            / (Design.layout.heatExchanger / SteamTurbine.parameter.efficiencyNominal)
        }
        
        heatFlow.boiler = Boiler.operate(
          &boiler, heatFlow: heatdiff, Qsf_load: Qsf_load,
          availableFuel: &availableFuel, fuelFlow: &fuel.boiler)
        electricalParasitics.boiler = Boiler.parasitics
        if Fuelmode == "predefined" { // predif ined fuel consumption in *.pfc-file
          if (heatFlow.heatExchanger + heatFlow.boiler) > 110 {
            heatFlow.boiler = 105 - heatFlow.heatExchanger
          }
          
          heatFlow.production = (heatFlow.heatExchanger + heatFlow.wasteHeatRecovery)
            * Simulation.parameter.adjustmentFactor.heatLossH2O + heatFlow.boiler
        }
      }
      // *************  From here: use only heatFlow.production !  ************************
      
      // Check if thermal heat is within acceptable limits
      
      if heatFlow.production - SteamTurbine.parameter.power.max / SteamTurbine.efficiency
        > Simulation.parameter.heatTolerance { // TB.Overload
        // report = " Overloading TB: " + Str$(heatFlow.production - SteamTurbine.parameter.power.max / SteamTurbine.parameter.efficiencyNominal) + " MWH,th\n"
      } else if heatFlow.production - heatFlow.demand > 2 * Simulation.parameter.heatTolerance {
        // report = " Production > demand: " + Str$(heatFlow.production - heatFlow.demand) + " MWH,th\n"
      }
      
      if (SteamTurbine.parameter.PminT[0] == 1 && SteamTurbine.parameter.PminT[1] == 0
        && SteamTurbine.parameter.PminT[2] == 0 && SteamTurbine.parameter.PminT[3] == 0
        && SteamTurbine.parameter.PminT[4] == 0)
        || (SteamTurbine.parameter.PminT[0] == 0 && SteamTurbine.parameter.PminT[1] == 0
          && SteamTurbine.parameter.PminT[2] == 0 && SteamTurbine.parameter.PminT[3] == 0
          && SteamTurbine.parameter.PminT[4] == 0) {
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
      if (SteamTurbine.parameter.PminT[0] == 1 && SteamTurbine.parameter.PminT[1] == 0
        && SteamTurbine.parameter.PminT[2] == 0 && SteamTurbine.parameter.PminT[3] == 0
        && SteamTurbine.parameter.PminT[4] == 0)
        || (SteamTurbine.parameter.PminT[0] == 0 && SteamTurbine.parameter.PminT[1] == 0
          && SteamTurbine.parameter.PminT[2] == 0 && SteamTurbine.parameter.PminT[3] == 0
          && SteamTurbine.parameter.PminT[4] == 0) {
        
        if 0 < heatFlow.production
          && heatFlow.production < SteamTurbine.parameter.power.min / SteamTurbine.parameter.efficiencyNominal {
          // report = "Damping (SteamTurbine underload):" + (heatFlow.production) + "MWH,th\n"
          // not used !!! Qblank = heatFlow.production
          heatFlow.production = 0
        }
      } else {
        if 0 < heatFlow.production && heatFlow.production < steamTurbine.PminfT / SteamTurbine.efficiency {
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
        steamTurbine: &SteamTurbine.status,
        Qsto: qad, meteo: meteo)
        * SteamTurbine.efficiency
      
      if heatFlow.production == 0 { // added to separate shared facilities parasitics
        electricalParasitics.shared = PowerBlock.parameter.electricalParasiticsShared[0] // no operation
      } else {
        electricalParasitics.shared = PowerBlock.parameter.electricalParasiticsShared[1] // operation and start up
      }
      
      if Fuelmode == "predefined" { // predifined fuel consumption in *.pfc-file
        if fuel.combined > 0 && electricEnergy.steamTurbineGross > SteamTurbine.parameter.power.max + 1 {
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
          heatFlow.production = heatFlow.production
            * (electricEnergy.demand / electricEnergy.steamTurbineGross)
          heatdiff = heatdiff * (electricEnergy.demand / electricEnergy.steamTurbineGross)
          var Qsf_load: Double = 0.0 // FIXME
          Qsf_load *= (electricEnergy.demand / electricEnergy.steamTurbineGross)
          
          heatFlow.boiler = Boiler.operate(
            &boiler, heatFlow: heatdiff, Qsf_load: Qsf_load,
            availableFuel: &availableFuel, fuelFlow: &fuel.boiler)
          
          electricalParasitics.boiler = Boiler.parasitics
          heatFlow.solar = heatFlow.solar
            * (electricEnergy.demand / electricEnergy.steamTurbineGross)
          // reduction in Qsol should be necessary for every project withoput storage
          heatFlow.heatExchanger = heatFlow.heatExchanger
            * (electricEnergy.demand / electricEnergy.steamTurbineGross)
          
          let qad = heatFlow.storage + heatFlow.boiler
          
          electricEnergy.steamTurbineGross = PowerBlock.operate(
            heat: &heatFlow.production,
            electricalParasitics: &electricalParasitics.powerBlock,
            steamTurbine: &SteamTurbine.status,
            Qsto: qad, meteo: meteo) * SteamTurbine.efficiency
          
          if heatFlow.production == 0 { // added to separate shared facilities parasitics
            electricalParasitics.shared = PowerBlock.parameter.electricalParasiticsShared[0]
          } else {
            electricalParasitics.shared = PowerBlock.parameter.electricalParasiticsShared[1]
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
      
      electricEnergy.parasitics *= Simulation.parameter.adjustmentFactor.electricalParasitics
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
        if case .startUp = Boiler.status.operationMode {
          Boiler.status.operationMode = .SI
        } else if case .noOperation = Boiler.status.operationMode {
          Boiler.status.operationMode = .NI
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
      electricEnergy.demand = demand * (Design.layout.powerBlock - Design.layout.gasTurbine) // just for WriteOpRep
    } else {
      electricEnergy.demand = SteamTurbine.parameter.power.max
    }
    
    if true /* Ctl.AS = 1 */&& heatFlow.solar > 0 {
      // Average HTF temp. in loop [K]
      let averageTemperature = Temperature(
        (solarField.header.temperature.inlet + solarField.header.temperature.outlet).value / 2)
      
      heatFlow.solar = heatFlow.solar
        + (1 - SolarField.parameter.SSFHL / SolarField.parameter.pipeHL)
        * SolarField.pipeHeatLoss(averageTemperature, ambient: Temperature(meteo.temperature))
        * Design.layout.solarField
        * Double(SolarField.parameter.numberOfSCAsInRow)
        * 2 * Collector.parameter.areaSCAnet / 1_000_000
    }
    // H2OinHX.temperature.inlet = H2OinPB.temperature.outlet
  }
}
