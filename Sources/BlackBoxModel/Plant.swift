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
  static var electricalParasitics = Parasitics()
  static var thermal = ThermalEnergy()
  static var fuel = FuelConsumption()
  
  static let initialState = PerformanceData()

  static func update(_ status: inout Plant.PerformanceData,
                     at timeStep: TimeStep, demand: Double,
                     availableFuel: inout Double, meteo: MeteoData) {
    
    ambientTemperature = Temperature(celsius: meteo.temperature)

    // storage.mass.hot = HeatExchanger.parameter.temperature.h2o.inlet.max
    // storage.mass.cold = HeatExchanger.parameter.temperature.h2o.inlet.min
    
    // storage.mass.hot = Storage.parameter.startLoad.hot
    // storage.mass.cold = Storage.parameter.startLoad.cold
    // storage.temperatureTank.hot = HeatExchanger.parameter.temperature.h2o.outlet.max
    // storage.temperatureTank.cold = HeatExchanger.parameter.temperature.h2o.outlet.max
    
    let Pmin = SteamTurbine.parameter.PminT[ambientTemperature]

    status.steamTurbine.PminfT = max(SteamTurbine.parameter.power.min * Pmin, SteamTurbine.parameter.PminLim)
    
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
    iteration(&status, demand, &availableFuel, meteo, &dumping, &electricalParasiticsAssumed)
    
    if Design.hasStorage {
      Storage.calculate(storage: &status.storage, powerBlock: &status.powerBlock, steamTurbine: status.steamTurbine)
    }
    
    thermal.dump += dumping
    
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
    
    if true /* Ctl.AS = 1 */&& thermal.solar > 0 {
      // Average HTF temp. in loop [K]
      thermal.solar = thermal.solar
        + (1 - SolarField.parameter.SSFHL / SolarField.parameter.pipeHL)
        * SolarField.pipeHeatLoss(
          status.solarField.header.averageTemperature, ambient: ambientTemperature)
        * Design.layout.solarField
        * Double(SolarField.parameter.numberOfSCAsInRow)
        * 2 * Collector.parameter.areaSCAnet / 1_000_000
    }
    // H2OinHX.temperature.inlet = H2OinPB.temperature.outlet
  }
  
  static func iteration(_ status: inout Plant.PerformanceData,
                        _ demand: Double,
                        _ availableFuel: inout Double,
                        _ meteo: MeteoData,
                        _ dumping: inout Double,
                        _ electricalParasiticsAssumed: inout Double) {
    
    // Iteration to account for correct parasitics
    outerLoop: for _ in 1 ... 10 {

      if Design.hasGasTurbine {
        electricEnergy.demand = demand * (Design.layout.powerBlock - Design.layout.gasTurbine)
        electricEnergy.demand += electricEnergy.demand
          * Simulation.parameter.electricalParasitics // ist hier nochmals neu von oben eingefügt worden
      } else {
        electricEnergy.demand = demand * SteamTurbine.parameter.power.max
        // added to try to limit output to demand file
      }
      
      status.steamTurbine.load = Ratio((electricEnergy.demand + Design.layout.gasTurbine)
        / SteamTurbine.parameter.power.max) // TB Load
      let efficiency = SteamTurbine.efficiency(&status, Lmax: 1.0)
      switch Storage.parameter.strategy {
      case .demand:
        thermal.demand = min(
          HeatExchanger.parameter.SCCHTFthermal,
          SteamTurbine.parameter.power.max / efficiency)
        assert(thermal.demand != -.infinity)
      // * demand deleted, should be 100% demand (?)// comparison with HX cap. written to restrict HX capacity
      case .shifter:
        thermal.demand = min(
          HeatExchanger.parameter.SCCHTFthermal,
          SteamTurbine.parameter.power.max * demand / efficiency)
      // strategy ful added again, same as always? comparison with HX cap. written to restrict HX capacity
      default:
        thermal.demand = min(HeatExchanger.parameter.SCCHTFthermal,
                             electricEnergy.demand / efficiency)
        //  demand deleted since is calculated before in electricEnergy.demand
        //  demand added because electricEnergy.demand is only SteamTurbine.parameter.power.max
        //  steamTurbine.load // wird hier jetzt mit electricEnergy.demand berechnet,
        //  comparison with HX cap. written to restrict HX capacity
      }
      
      if status.steamTurbine.isMaintained {
        status.steamTurbine.load = 0.0
        electricEnergy.demand = 0
        thermal.demand = 0
      } else if status.steamTurbine.load > Plant.availability.value.powerBlock { // - TB Load > Availability -
        status.steamTurbine.load = Plant.availability.value.powerBlock
        thermal.demand = min(
          HeatExchanger.parameter.SCCHTFthermal,
          SteamTurbine.parameter.power.max
            * Plant.availability.value.powerBlock.ratio
            / SteamTurbine.efficiency(&status, Lmax: 1.0))
        // comparison with HX cap. written to restrict HX capacity
      }
      
      thermal.demand = (thermal.demand / Simulation.parameter.adjustmentFactor.heatLossH2O)
        / HeatExchanger.parameter.efficiency // + Simulation.parameter.energyTolerance)
      // steam losses + Thermal demand higher before HX // + inaccuracies
      // ::::::::::::::: HTF - Loop :::::::::::::::::::::::::::::::::::::::::::::::
      // For the SCC mode it must be checked whether the solar heat is enough to
      // cover the demand; if not, priority is to switch on the Gas SteamTurbine: this has
      // to be done before the heater is put into action
      
      if thermal.demand > 0 && availableFuel > 0 && Design.hasHeater {
        status.powerBlock.temperature.outlet = HeatExchanger.parameter.temperature.htf.outlet.max
      }
      
      if availableFuel > 0 { // Important change done! only valid for OU1!!!
        status.powerBlock.temperature.outlet = HeatExchanger.parameter.temperature.htf.outlet.max
      }
      
      // it seems that the current.temperature.outlet calculated below does not have great influence on the results.
      // It is used for calculating the HTF temp to heater when generating steam directly with gas of during solar field freeze protection
      if !status.powerBlock.massFlow.isNearZero {
        
        if status.powerBlock.temperature.inlet >= HeatExchanger.parameter.temperature.htf.inlet.min {
          heatExchangerFunction(&status)
        }
      }
      var heatdiff: Double = 0.0
      // Iteration: Find the right powerBlock.temperature.inlet and temperature.outlet
      innerLoop: while true {

        if Design.hasSolarField {
          thermal.solar = -status.solarField.thermal(fluid: htf) / 1_000
          
          let ICosTheta = Double(meteo.dni) * status.collector.cosTheta
          
          if ICosTheta <= 0 { // added to avoid Q.solar > 0 during some night and freeze protection time
            thermal.solar = 0
          }
          if abs(thermal.solar) > 0 {// Line 313
            thermal.production = thermal.solar
            status.powerBlock.temperature.inlet = status.solarField.header.temperature.outlet
            status.powerBlock.massFlow = status.solarField.header.massFlow
          } else { // if thermal.solar < 0
            if case .freezeProtection = status.solarField.operationMode {
              thermal.solar = 0
              thermal.production = 0
              status.powerBlock.massFlow = status.solarField.header.massFlow
              status.powerBlock.temperature.inlet = status.solarField.header.temperature.outlet
            } else {
              thermal.solar = 0
              thermal.production = 0
              status.powerBlock.massFlow = 0.0
              status.solarField.header.massFlow = 0.0
            }
          }
        } else {
          thermal.solar = 0
          thermal.production = 0
          status.powerBlock.massFlow = 0.0
          status.solarField.header.massFlow = 0.0
        }
        
        if Design.hasStorage {
          Storage.update(&status, availableFuel: &availableFuel, fuel: &fuel, thermal: &thermal)
        }
        var supplyGasTurbine: Double = 0.0
        if Design.hasGasTurbine {
          supplyGasTurbine = GasTurbine.update(
            &status, availableFuel: &availableFuel, fuel: &fuel,
            electricEnergy: &electricEnergy, thermal: &thermal)
        }
        
        if Design.hasHeater && !Design.hasBoiler {
          heaterFunction(&status, supplyGasTurbine, &heatdiff, availableFuel, demand)
        } // Line 535
        
        // Freeze Protection
        switch status.heater.operationMode {
        case .normal, .reheat:
          break
        default:
          if status.solarField.header.temperature.outlet <
            htf.freezeTemperature + Simulation.parameter.dfreezeTemperatureHeat,
            status.storage.massFlow.isNearZero { // No freeze protection heater use anymore if storage is in operation
            
            status.heater.temperature.inlet = status.powerBlock.temperature.inlet
            status.heater.massFlow = status.powerBlock.massFlow
            status.heater.operationMode = .freezeProtection
            
            Heater.update(&status, demand: 1, availableFuel: availableFuel,
                          thermal: &thermal, fuelFlow: &fuel.heater)
            electricalParasitics.heater = Heater.parasitics(at: status.heater.load)
            
            switch status.heater.operationMode {
            case .freezeProtection:
              status.powerBlock.temperature.outlet = status.heater.temperature.outlet
            case .normal, .reheat: break
            default:
              if status.solarField.header.temperature.outlet.kelvin
                > htf.freezeTemperature.kelvin
                + Simulation.parameter.dfreezeTemperatureHeat.kelvin {
                status.heater.operationMode = .noOperation
                Heater.update(&status, demand: 0, availableFuel: availableFuel,
                              thermal: &thermal, fuelFlow: &fuel.heater)
                electricalParasitics.heater = Heater.parasitics(at: status.heater.load)
              }
            }
          }
        }// Heater.OPmode != "OP"
        // Freeze Protection
        
        // HX: powerBlock.temperature.inlet is known now, so calc. the real heatExchanger.temperature.outlet and thermal.production
        
        var storageNearFreeze = false
        if case .freezeProtection = status.storage.operationMode {
          storageNearFreeze = true
        }
        var solarFieldNearFreeze = false
        if case .freezeProtection = status.solarField.operationMode {
          solarFieldNearFreeze = true
        }
        var heaterAntiFreeze = false
        if case .freezeProtection = status.heater.operationMode {
          heaterAntiFreeze = true
        }
        
        if status.powerBlock.temperature.inlet
          < HeatExchanger.parameter.temperature.htf.inlet.min
          || status.powerBlock.massFlow.rate == 0
          || storageNearFreeze {
          // bypass HX
          
          if !heaterAntiFreeze && solarFieldNearFreeze || storageNearFreeze {
            
            if Design.hasGasTurbine {
              status.powerBlock.temperature.outlet = status.powerBlock.temperature.inlet
            } else {
              let TLPB = 0.0 // 0.38 * (TpowerBlock.status - meteo.temperature) / 100 * (30 / Design.layout.powerBlock) ** 0.5 // 0.38
              
              status.powerBlock.temperature.inlet =
                Temperature((status.solarField.header.massFlow.rate
                  * status.solarField.header.temperature.outlet.kelvin
                  + status.powerBlock.massFlow.rate * status.storage.temperature.outlet.kelvin)
                  / (status.solarField.header.massFlow + status.powerBlock.massFlow).rate)
              
              // FIXME Was ist Tstatus ?????????
              
              let x = status.powerBlock.massFlow.rate
                * Double(period) * status.powerBlock.temperature.inlet.kelvin
                + status.powerBlock.temperature.outlet.kelvin
                * (SolarField.parameter.HTFmass
                  - status.powerBlock.massFlow.rate * Double(period))
                / SolarField.parameter.HTFmass - TLPB
              status.powerBlock.temperature.outlet = Temperature(x)
            }
          }
          thermal.production = 0
          thermal.heatExchanger = 0
          status.heatExchanger.massFlow = 0.0
          break innerLoop
        }
        
        status.heatExchanger.massFlow = status.powerBlock.massFlow
        status.heatExchanger.temperature.inlet = status.powerBlock.temperature.inlet
        
        Plant.thermal.heatExchanger = HeatExchanger.update(
          &status.heatExchanger, steamTurbine: status.steamTurbine, storage: status.storage)
        
        if Design.hasGasTurbine,
          Design.hasStorage,
          thermal.heatExchanger > HeatExchanger.parameter.SCCHTFthermal {
          thermal.dump += thermal.heatExchanger - HeatExchanger.parameter.SCCHTFthermal
          thermal.heatExchanger = HeatExchanger.parameter.SCCHTFthermal
        }
        
        if abs((status.powerBlock.temperature.outlet.kelvin - status.heatExchanger.temperature.outlet.kelvin))
          < Simulation.parameter.tempTolerance.kelvin {
          break innerLoop
        }
        
        status.powerBlock.temperature.outlet = status.heatExchanger.temperature.outlet
        // TpowerBlock.status = powerBlock.temperature.outlet
      } // Iteration ends: Find the right powerBlock.temperature.inlet and temperature.outlet
      
      // FIXME   H2OinPB = H2OinHX
      
      thermal.production = thermal.heatExchanger + thermal.wasteHeatRecovery
      thermal.demand *= HeatExchanger.parameter.efficiency
      // Therm heat demand is lower after HX:
      thermal.production *= Simulation.parameter.adjustmentFactor.heatLossH2O
      // - Unavoidable losses in Power Block -
      var Qsf_load = 0.0
      if Design.hasBoiler { // - if Boiler is designed -
        
        let adjustmentFactor = Simulation.parameter.adjustmentFactor
        if case .solarOnly = Control.whichOptimization {
          
          if thermal.production < adjustmentFactor.efficiencyHeater,
            thermal.production >= adjustmentFactor.efficiencyBoiler {
            
            switch status.boiler.operationMode {
            case .startUp, .SI, .NI:
              break
            default:
              status.boiler.operationMode = .unknown
            }
            
            heatdiff = thermal.production - thermal.demand
            if Boiler.parameter.booster { // booster superheater
              if thermal.heater == Design.layout.heater { // Firm Output case
                // for shams-1 769% of the boiler load is used during firm output. no time to find a nice formula. sorry!
                Qsf_load = 0.769
              } else {
                Qsf_load = thermal.production / (Design.layout.heatExchanger
                    / SteamTurbine.parameter.efficiencyNominal)
              }
            }
            
            // H2OinBO.temperature.inlet = H2OinPB.temperature.outlet
          } else {
            status.boiler.operationMode = .noOperation(hours: 0)
          }
        }
        /*
         if Heater.parameter.operationMode { // Shams project
         // first 30 minutes during PB startup no gas is used. Not considered for firm output (HR >0)
         if SteamTurbinestartUpTime <= 30 && thermal.heater = 0 {
         heatdiff = 0
         }
         }
         */
        
        if thermal.heater == Design.layout.heater { // Firm Output case
          // for shams-1 769% of the boiler load is used during firm output. no time to find a nice formula. sorry!
          Qsf_load = 0.769
        } else {
          Qsf_load = thermal.production / (Design.layout.heatExchanger
              / SteamTurbine.parameter.efficiencyNominal)
        }
        
        thermal.boiler = Boiler.update(
          &status.boiler, thermal: heatdiff, Qsf_load: Qsf_load,
          availableFuel: &availableFuel, fuelFlow: &fuel.boiler)
        electricalParasitics.boiler = Boiler.parasitics(boiler: status.boiler)
        if Fuelmode == "predefined" { // predefined fuel consumption in *.pfc-file
          if (thermal.heatExchanger + thermal.boiler) > 110 {
            thermal.boiler = 105 - thermal.heatExchanger
          }
          
          thermal.production = (thermal.heatExchanger + thermal.wasteHeatRecovery)
            * adjustmentFactor.heatLossH2O + thermal.boiler
        }
      }
      // *************  From here: use only thermal.production !  ************************
      
      // Check if thermal heat is within acceptable limits
      
      if thermal.production - SteamTurbine.parameter.power.max
        / SteamTurbine.efficiency(&status, Lmax: 1.0)
        > Simulation.parameter.heatTolerance { // TB.Overload
        // report = " Overloading TB: " + Str$(thermal.production - SteamTurbine.parameter.power.max / SteamTurbine.parameter.efficiencyNominal) + " MWH,th\n"
      } else if thermal.production - thermal.demand > 2 * Simulation.parameter.heatTolerance {
        // report = " Production > demand: " + Str$(thermal.production - thermal.demand) + " MWH,th\n"
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
        
        if 0 < thermal.production
          && thermal.production
          < SteamTurbine.parameter.power.min
          / SteamTurbine.parameter.efficiencyNominal {
          // report = "Damping (SteamTurbine underload):" + (thermal.production) + "MWH,th\n"
          // not used !!! Qblank = thermal.production
          thermal.production = 0
        }
      } else {
        if 0 < thermal.production && thermal.production
          < status.steamTurbine.PminfT / SteamTurbine.efficiency(&status, Lmax: 1.0) {
          // efficiency at min. load instead of nominal, has effect for dry cooling!
          // report = "Damping (SteamTurbine underload):" + (thermal.production) + "MWH,th\n"
          // not used !!! Qblank = thermal.production
          thermal.production = 0
        }
      }
      
      let qad = thermal.storage + thermal.boiler
      
      electricEnergy.steamTurbineGross = PowerBlock.update(
        &status, heat: &thermal.production,
        electricalParasitics: &electricalParasitics.powerBlock,
        Qsto: qad, meteo: meteo)
        * SteamTurbine.efficiency(&status, Lmax: 1.0)
      
      if thermal.production == 0 { // added to separate shared facilities parasitics
        electricalParasitics.shared = PowerBlock.parameter.electricalParasiticsShared[0] // no operation
      } else {
        electricalParasitics.shared = PowerBlock.parameter.electricalParasiticsShared[1] // operation and start up
      }
      
      if Fuelmode == "predefined" { // predifined fuel consumption in *.pfc-file
        if fuel.combined > 0 && electricEnergy.steamTurbineGross
          > SteamTurbine.parameter.power.max + 1 {
          electricEnergy.steamTurbineGross = SteamTurbine.parameter.power.max + 1
        }
        if fuel.combined > 0, thermal.solar > 0,
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
          heatdiff *= electricEnergy.demand / electricEnergy.steamTurbineGross
          Qsf_load *= electricEnergy.demand / electricEnergy.steamTurbineGross
          
          thermal.boiler = Boiler.update(
            &status.boiler, thermal: heatdiff, Qsf_load: Qsf_load,
            availableFuel: &availableFuel, fuelFlow: &fuel.boiler)
          
          electricalParasitics.boiler = Boiler.parasitics(boiler: status.boiler)
          
          thermal.solar *= electricEnergy.demand / electricEnergy.steamTurbineGross
          // reduction in Qsol should be necessary for every project withoput storage
          thermal.heatExchanger *= electricEnergy.demand / electricEnergy.steamTurbineGross
          
          let qad = thermal.storage + thermal.boiler
          
          electricEnergy.steamTurbineGross = PowerBlock.update(
            &status, heat: &thermal.production,
            electricalParasitics: &electricalParasitics.powerBlock,
            Qsto: qad, meteo: meteo) * SteamTurbine.efficiency(&status, Lmax: 1.0)
          
          if thermal.production == 0 { // added to separate shared facilities parasitics
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
      electricEnergy.solarField += electricalParasitics.storage
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
         DSumHR = DSumHR + thermal.heater
         YSumHR = YSumHR + thermal.heater
         } else {
         ConsHours = ConsHours + (1 * CalcTime% / 3_600)
         }
         } else {
         DSumHR = DSumHR + thermal.heater
         YSumHR = YSumHR + thermal.heater
         }*/
        if thermal.heater > 0 {
          //oldHR = thermal.heater
        }
        break outerLoop
      }
      
      electricalParasiticsAssumed = electricEnergy.parasitics
      
      if Design.hasBoiler {
        if case .startUp = status.boiler.operationMode {
          status.boiler.operationMode = .SI
        } else if case .noOperation = status.boiler.operationMode {
          status.boiler.operationMode = .NI
        }
      }
    }
  }

  static func heatExchangerFunction(_ status: inout Plant.PerformanceData) {
    HeatExchanger.update(powerBlock: &status.powerBlock,
                         heatExchanger: status.heatExchanger)
    // Line 236
    if case .ex = status.storage.operationMode,
      status.powerBlock.temperature.outlet.isLower(than: 534.0) {
      // added to simulate a bypass on the PB-HX if the expected outlet temp is so low that the salt to TES could freeze
      let totalMassFlow = status.powerBlock.massFlow
      for _ in 1 ... 100 {
        let massFlowLoad = status.powerBlock.massFlow.share(
          of: SolarField.parameter.massFlow.max)
        
        if HeatExchanger.parameter.Tout_f_Mfl,
          !HeatExchanger.parameter.Tout_f_Tin,
          !HeatExchanger.parameter.useAndsolFunction,
          let ToutMassFlow = HeatExchanger.parameter.ToutMassFlow {
          
          // if temperature.outlet is dependant on massflow, recalculate temperature.outlet
          var temperaturFactor = ToutMassFlow[massFlowLoad]
          if temperaturFactor > 1 { temperaturFactor = 1 }
          status.powerBlock.temperature.outlet =
            HeatExchanger.parameter.temperature.htf.outlet.max
              .adjusted(with: temperaturFactor)
          
        } else if HeatExchanger.parameter.Tout_f_Mfl,
          HeatExchanger.parameter.Tout_f_Tin,
          !HeatExchanger.parameter.useAndsolFunction,
          let ToutMassFlow = HeatExchanger.parameter.ToutMassFlow,
          let ToutTin = HeatExchanger.parameter.ToutTin {
          
          var temperaturFactor = ToutMassFlow[massFlowLoad]
          temperaturFactor *= ToutTin[status.powerBlock.temperature.inlet]
          status.powerBlock.temperature.outlet =
            HeatExchanger.parameter.temperature.htf.outlet.max
              .adjusted(with: temperaturFactor)
          
        } else if HeatExchanger.parameter.useAndsolFunction {
          
          var temperaturFactor = (
            (0.0007592419869 * (status.powerBlock.temperature.inlet.kelvin
              / HeatExchanger.parameter.temperature.htf.inlet.max.kelvin)
              * 666 + 0.4943825893223)
              * massFlowLoad.ratio ** (0.0001400823882
                * (status.powerBlock.temperature.inlet.kelvin
                  / HeatExchanger.parameter.temperature.htf.inlet.max.kelvin)
                * 666 - 0.0110227028559)) - 0.000151639
          // temperature.inlet changed to (Fluid.parameter.temperature.inlet / HeatExchanger.parameter.temperature.htf.inlet.max) * 666 because function is based on 393°C temperature.inlet
          temperaturFactor = HeatExchanger.limit(temperaturFactor)
          status.powerBlock.temperature.outlet =
            HeatExchanger.parameter.temperature.htf.outlet.max
              .adjusted(with: temperaturFactor)
          
        } else if HeatExchanger.parameter.Tout_exp_Tin_Mfl,
          let ToutTinMassFlow = HeatExchanger.parameter.ToutTinMassFlow {
          
          var temperaturFactor = (ToutTinMassFlow[0]
            * (status.powerBlock.temperature.inlet.kelvin
              / HeatExchanger.parameter.temperature.htf.inlet.max.kelvin)
            * 666 + ToutTinMassFlow[1])
            * massFlowLoad.ratio ** (ToutTinMassFlow[2]
              * (status.powerBlock.temperature.inlet.kelvin
                / HeatExchanger.parameter.temperature.htf.inlet.max.kelvin)
              * 666 + ToutTinMassFlow[3]) + ToutTinMassFlow[4]
          // temperature.inlet changed to (Fluid.parameter.temperature.inlet / HeatExchanger.parameter.temperature.htf.inlet.max) * 666 because function is based on 393°C temperature.inlet
          temperaturFactor = HeatExchanger.limit(temperaturFactor)
          status.powerBlock.temperature.outlet =
            HeatExchanger.parameter.temperature.htf.outlet.max
              .adjusted(with: temperaturFactor)
        }
        
        let outlet = status.powerBlock.temperature.outlet.celsius
        status.heatExchanger.heatOut = 1.51129 * outlet
          + 1.2941 / 1_000 * outlet ** 2
          + 1.23697 / 10 ** 7 * outlet ** 3
          - 0.62677 // kJ/kg
        
        let BypassmassFlow = totalMassFlow - status.powerBlock.massFlow
        let inlet = status.powerBlock.temperature.inlet.celsius
        
        let Bypass_h = 1.51129 * inlet + 1.2941 / 1_000 * inlet ** 2
          + 1.23697 / 10 ** 7 * inlet ** 3 - 0.62677 // kJ/kg
        
        let h_261 = 1.51129 * 261 + 1.2941 / 1_000 * 261 ** 2 + 1.23697
          / 10 ** 7 * 261 ** 3 - 0.62677 // kJ/kg
        
        status.heatExchanger.heatToTES = (BypassmassFlow.rate * Bypass_h
          + status.powerBlock.massFlow.rate * status.heatExchanger.heatOut)
          / (BypassmassFlow + status.powerBlock.massFlow).rate
        
        if status.heatExchanger.heatToTES < h_261 {
          break
        }
        
      }// Line 281
      status.powerBlock.temperature.outlet = Temperature((-0.61133E-10
        * status.heatExchanger.heatToTES ** 4 + 0.00000019425
        * status.heatExchanger.heatToTES ** 3 - 0.00032293
        * status.heatExchanger.heatToTES ** 2 + 0.65556
        * status.heatExchanger.heatToTES + 0.58315).toKelvin)
    }
  }
  
  static func heaterFunction(_ status: inout Plant.PerformanceData,
                             _ supplyGasTurbine: Double,
                             _ heatdiff: inout Double,
                             _ availableFuel: Double,
                             _ demand: Double) {
    // Heater designed as primary backup
    // if Design.heater {  // supplementary HTF heater for Shams-1. Commented
    
    //   heatdiff = 0
    // restart variable to avoid errors due to Boiler.  added for Shams-1
    if case .pc = status.gasTurbine.operationMode {
      // Plant updates in Pure CC Mode now again without RH!!
      // demand * WasteHeatRecovery.parameter.effPure * (1 / gasTurbine.efficiency- 1)) heat supplied by the WHR system
    } else if case .ic = status.gasTurbine.operationMode { // Plant does not update in Pure CC Mode
      let HTFenergy = (supplyGasTurbine * (1
        / GasTurbine.efficiency(at: status.gasTurbine.load) - 1)
        * WasteHeatRecovery.parameter.efficiencyNominal
        / WasteHeatRecovery.parameter.ratioHTF)
      
      heatdiff = thermal.production - HTFenergy // -^- necessary HTF share
      
      status.heater.operationMode = .unknown
      
      status.heater.temperature.inlet = status.powerBlock.temperature.outlet
      
      Heater.update(&status, demand: heatdiff, availableFuel: availableFuel,
                     thermal: &thermal, fuelFlow: &fuel.heater)
      
      electricalParasitics.heater = Heater.parasitics(at: status.heater.load)
      
      status.powerBlock.temperature.inlet = htf.mixingTemperature(
        inlet: status.powerBlock, with: status.heater)
      
      status.powerBlock.massFlow = status.powerBlock.massFlow + status.heater.massFlow
    } else if case .noOperation = status.gasTurbine.operationMode {
      // GasTurbine does not update at all (Load<Min?)
      Heater.update(&status, demand: 0, availableFuel: availableFuel,
                    thermal: &thermal, fuelFlow: &fuel.heater)
      
      electricalParasitics.heater = Heater.parasitics(at: status.heater.load)
      
      status.powerBlock.temperature.inlet = htf.mixingTemperature(
        outlet: status.solarField, with: status.heater)
      
      status.powerBlock.massFlow = status.solarField.header.massFlow + status.heater.massFlow
    } else { // gasTurbine.OPmode is neither IC nor PC
      // Line 429 STO STO STO STO STO
      
      if Design.hasStorage {
        if heatdiff < 0,
          status.storage.heatrel < Storage.parameter.dischargeToTurbine,
          status.storage.heatrel > Storage.parameter.dischargeToHeater {
          // Direct Discharging to SteamTurbine and heatdiff > 0 (Energy Surplus) see above
          if availableFuel > 0 { // Fuel available, Storage for Pre-Heating
            
            Storage.update(&status, mode: .ph, thermal: &thermal)
            //Storage.update(mode: .ph, heatdiff, powerBlock.massFlow, hourFraction, thermal.storage)
            status.heater.temperature.inlet = status.storage.temperature.outlet
            
            status.heater.operationMode = .unknown
            
            heatdiff = thermal.production + thermal.storage - thermal.demand
            
            Heater.update(&status, demand: heatdiff, availableFuel: availableFuel,
                          thermal: &thermal, fuelFlow: &fuel.heater)
            
            electricalParasitics.heater = Heater.parasitics(at: status.heater.load)
            
            status.heater.massFlow = status.storage.massFlow
            
            status.powerBlock.temperature.inlet = htf.mixingTemperature(
              outlet: status.solarField, with: status.heater)
            
            status.powerBlock.massFlow = status.solarField.header.massFlow + status.heater.massFlow
            
          } else { // NO Fuel Available -> Discharge directly with reduced TB load!
            
            Storage.update(&status, mode: .discharge, thermal: &thermal)
            //Storage.update(mode: .discharge, heatdiff, powerBlock.massFlow, hourFraction, thermal.storage)
            status.powerBlock.temperature.inlet = htf.mixingTemperature(
              outlet: status.solarField, with: status.storage)
            
            status.powerBlock.massFlow = status.storage.massFlow + status.solarField.header.massFlow
          } // STORAGE: dischargeToHeater < Qrel < dischargeToTurbine;  Fuel/NoFuel
        } else if heatdiff < 0, status.storage.heatrel < Storage.parameter.dischargeToHeater,
          status.heater.operationMode != .freezeProtection {
          // = Storage is empty!! && Heater.operationMode != .freezeProtection // <= added instead of "<"
          heatdiff = thermal.production + thermal.wasteHeatRecovery
            / HeatExchanger.parameter.efficiency - demand * thermal.demand
          // added to avoid heater use is storage is selected and checkbox marked:
          if thermal.production == 0 { // use heater only in parallel with solar field and not as stand alone.
            // heatdiff = 0 // commented to use gas not only in paralell to SF (for AH1)
            if Heater.parameter.onlyWithSolarField {
              heatdiff = 0
            }
          }
          status.heater.operationMode = .unknown
          
          status.heater.temperature.inlet = status.powerBlock.temperature.outlet
          
          Heater.update(&status, demand: heatdiff, availableFuel: availableFuel,
                        thermal: &thermal, fuelFlow: &fuel.heater)
          
          electricalParasitics.heater = Heater.parasitics(at: status.heater.load)
          
          status.powerBlock.temperature.inlet = htf.mixingTemperature(
            outlet: status.solarField, with: status.heater)
          
          status.powerBlock.massFlow = status.solarField.header.massFlow + status.heater.massFlow
        }
        
      } else { // No Storage
        heatdiff = thermal.production + thermal.wasteHeatRecovery
          / HeatExchanger.parameter.efficiency - thermal.demand
        
        assert((heatdiff != .infinity))
        
        if thermal.production == 0 {
          // use heater only in parallel with solar field and not as stand alone.
          if Heater.parameter.onlyWithSolarField {
            heatdiff = 0
          }
        }
        
        status.heater.operationMode = .unknown
        
        status.heater.temperature.inlet = status.powerBlock.temperature.outlet
        
        Heater.update(&status, demand: heatdiff, availableFuel: availableFuel,
                      thermal: &thermal, fuelFlow: &fuel.heater)
        
        electricalParasitics.heater = Heater.parasitics(at: status.heater.load)
        
        if (status.solarField.header.massFlow + status.heater.massFlow).isNearZero {
          status.powerBlock.temperature.inlet = status.powerBlock.temperature.inlet // Freeze Protection
        } else {
          status.powerBlock.temperature.inlet = htf.mixingTemperature(
            outlet: status.solarField, with: status.heater)
        }
        status.powerBlock.massFlow = status.solarField.header.massFlow + status.heater.massFlow
      }
    }
    
    if !status.heater.massFlow.isNearZero {
      thermal.production = status.powerBlock.thermal(fluid: htf) / 1_000
    }
  }
  
  static func configure() {
    // Turbine Gross Power is no longer an input parameter.
    // It is now calculated from Design.layout.powerBlock plus parasitics
    // old TB files can still be used. From now 0 is put in as Gross Power in the TB files
    if SteamTurbine.parameter.power.max == 0 {
      SteamTurbine.parameter.power.max = Design.layout.powerBlock
        + PowerBlock.parameter.fixelectricalParasitics
        + PowerBlock.parameter.nominalElectricalParasitics
        + PowerBlock.parameter.electricalParasiticsStep[1]
    }
    
    if Design.hasGasTurbine {
      HeatExchanger.parameter.SCCHTFthermal = Design.layout.heatExchanger
        / SteamTurbine.parameter.efficiencySCC / HeatExchanger.parameter.SCCEff
      
      SolarField.parameter.massFlow.max = MassFlow(
        HeatExchanger.parameter.SCCHTFthermal * 1_000
          / htf.heatDelta(HeatExchanger.parameter.scc.htf.outlet.max,
                           HeatExchanger.parameter.scc.htf.inlet.max)
      )
      
      WasteHeatRecovery.parameter.ratioHTF = HeatExchanger.parameter.SCCHTFthermal
        / (SteamTurbine.parameter.power.max - HeatExchanger.parameter.SCCHTFthermal)
    } else {
      if Design.layout.heatExchanger != Design.layout.powerBlock {
        
        HeatExchanger.parameter.SCCHTFthermal = Design.layout.heatExchanger
          / SteamTurbine.parameter.efficiencyNominal
          / HeatExchanger.parameter.efficiency
      } else {
        
        HeatExchanger.parameter.SCCHTFthermal =
          SteamTurbine.parameter.power.max
          / SteamTurbine.parameter.efficiencyNominal
          / HeatExchanger.parameter.efficiency
      }
      SolarField.parameter.massFlow.max = MassFlow(
        HeatExchanger.parameter.SCCHTFthermal * 1_000
          / htf.heatDelta(HeatExchanger.parameter.temperature.htf.inlet.max,
                          HeatExchanger.parameter.temperature.htf.outlet.max)
      )
    }
    
    if Design.hasSolarField {
      SolarField.parameter.edgeFactor += [SolarField.parameter.distanceSCA / 2
        * (1 - 1 / Double(SolarField.parameter.numberOfSCAsInRow))
        / Collector.parameter.lengthSCA] // Constants
      SolarField.parameter.edgeFactor += [(1.0 + 1.0
        / Double(SolarField.parameter.numberOfSCAsInRow))
        / Collector.parameter.lengthSCA / 2]
    }
  }
}

extension Plant {
  
  struct PerformanceData: CustomStringConvertible {
    var collector = Collector.initialState,
    boiler = Boiler.initialState,
    powerBlock = PowerBlock.initialState,
    solarField = SolarField.initialState,
    steamTurbine = SteamTurbine.initialState,
    heater = Heater.initialState,
    heatExchanger = HeatExchanger.initialState,
    gasTurbine = GasTurbine.initialState,
    storage = Storage.initialState
    
    init() {}
    
    public var description: String {
      return "Collector:\n\(collector)\n\n"
      + "Boiler:\n\(boiler)\n\n"
      + "Power Block:\n\(powerBlock)\n\n"
      + "Solar Field:\n\(solarField)\n\n"
      + "Steam Turbine:\n\(steamTurbine)\n\n"
      + "Heater:\n\(heater)\n\n"
      + "Heat Exchanger:\n\(heatExchanger)\n\n"
      + "Gas Turbine:\n\(gasTurbine)\n\n"
      + "Storage:\n\(storage)\n"
    }
  }
}
