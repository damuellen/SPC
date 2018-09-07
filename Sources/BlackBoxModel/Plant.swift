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
  static var fuelConsumption = FuelConsumption()
  static var electricalParasitics = Parasitics()

  private(set) static var electric = ElectricEnergy()
  private(set) static var location: Location!
  private(set) static var ambientTemperature = Temperature()
  static var demand: Ratio = 1.0

  static let initialState = PerformanceData()

  static func setLocation(_ location: Location) {
    Plant.location = location
  }

  static func update(_ status: inout Plant.PerformanceData, 
                     fuel: Double, meteo: MeteoData) {
    ambientTemperature = Temperature(celsius: meteo.temperature)
    let solarField = SolarField.parameter
    let steamTurbine = SteamTurbine.parameter
    let storage = Storage.parameter
    let collector = Collector.parameter

    // storage.mass.hot = heatExchanger.temperature.h2o.inlet.max
    // storage.mass.cold = heatExchanger.temperature.h2o.inlet.min

    status.storage.mass.hot = storage.startLoad.hot
    status.storage.mass.cold = storage.startLoad.cold
    // storage.temperatureTank.hot = heatExchanger.temperature.h2o.outlet.max
    // storage.temperatureTank.cold = heatExchanger.temperature.h2o.outlet.max

    var electricalParasiticsAssumed: Double = 0.0
    if Design.hasGasTurbine {
      // for SEGS plant Demand is set to max SteamTurbine Power (because of spanish new legislation)
      electric.demand = demand.ratio * (Design.layout.powerBlock - Design.layout.gasTurbine)
      // Electric demand scc
      electricalParasiticsAssumed = electric.demand
        * Simulation.parameter.electricalParasitics
      // Iter. start val. for parasitics, 10% demand
      electric.demand += electricalParasiticsAssumed
    } else {
      electric.demand = demand.ratio * steamTurbine.power.max
    }
    // Iteration to account for correct parasitics
    iteration(&status, fuel, meteo, &thermal.dump, electricalParasiticsAssumed)

    if Design.hasStorage {
      Storage.calculate(status: &status.storage,
                        powerBlock: &status.powerBlock,
                        steamTurbine: status.steamTurbine)
    }

    electric.net = electric.gross - electric.parasitics // - Net electric power -

    if electric.net < 0 {
      electric.consum = -electric.net
      electric.net = 0
    } else {
      electric.consum = 0
    }

    if Design.hasGasTurbine {
      electric.demand = demand.ratio
        * (Design.layout.powerBlock - Design.layout.gasTurbine)
    } else {
      electric.demand = demand.ratio * steamTurbine.power.max
    }

    if true /* Ctl.AS = 1 */ && thermal.solar > 0 {
      // Average HTF temp. in loop [K]
      thermal.solar = thermal.solar
        + (1 - solarField.SSFHL / solarField.pipeHeatLosses)
        * SolarField.pipeHeatLoss(
          average: status.solarField.header.averageTemperature,
          ambient: ambientTemperature)
        * Design.layout.solarField
        * Double(solarField.numberOfSCAsInRow)
        * 2 * collector.areaSCAnet / 1_000_000
    }
    // H2OinHX.temperature.inlet = H2OinPB.temperature.outlet
  }

  static func iteration(_ status: inout Plant.PerformanceData,
                        _ fuel: Double,
                        _ meteo: MeteoData,
                        _ dumping: inout Double,
                        _ electricalParasiticsAssumed: Double) {
    let solarField = SolarField.parameter
    let heatExchanger = HeatExchanger.parameter
    let steamTurbine = SteamTurbine.parameter
    let storage = Storage.parameter
    
    var maxLoad = Ratio(0)
    // Iteration to account for correct parasitics
    outerLoop: for _ in 1 ... 100 {
      if Design.hasGasTurbine {
        electric.demand = demand.ratio
        electric.demand *= (Design.layout.powerBlock - Design.layout.gasTurbine)
        electric.demand += electric.demand
          * Simulation.parameter.electricalParasitics
      } else {
        electric.demand = demand.ratio * steamTurbine.power.max
      }

      status.steamTurbine.load = Ratio(
        (electric.demand + Design.layout.gasTurbine) / steamTurbine.power.max)

      let efficiency = SteamTurbine.efficiency(status, maxLoad: &maxLoad)

      switch storage.strategy {
      case .demand:
        thermal.demand = min(heatExchanger.sccHTFheat,
                             steamTurbine.power.max / efficiency)
      // * demand deleted, should be 100% demand (?)// comparison with HX cap. written to restrict HX capacity
      case .shifter:
        thermal.demand = min(heatExchanger.sccHTFheat,
                             steamTurbine.power.max * demand.ratio / efficiency)
      // strategy ful added again, same as always? comparison with HX cap. written to restrict HX capacity
      case .always:
        thermal.demand = min(heatExchanger.sccHTFheat,
                             electric.demand / efficiency)
        //  demand deleted since is calculated before in electricEnergy.demand
        //  demand added because electricEnergy.demand is only steamTurbine.power.max
        //  steamTurbine.load // wird hier jetzt mit electricEnergy.demand berechnet,
        //  comparison with HX cap. written to restrict HX capacity
      }

      if status.steamTurbine.isMaintained {
        status.steamTurbine.load = 0.0
        electric.demand = 0
        thermal.demand = 0
      } else if status.steamTurbine.load > Plant.availability.value.powerBlock {
        // - TB Load > Availability -
        status.steamTurbine.load = Plant.availability.value.powerBlock
        thermal.demand = min(
          heatExchanger.sccHTFheat,
          steamTurbine.power.max
            * Plant.availability.value.powerBlock.ratio
            / SteamTurbine.efficiency(status, maxLoad: &maxLoad)
        )
        // comparison with HX cap. written to restrict HX capacity
      }

      thermal.demand = (thermal.demand
        / Simulation.adjustmentFactor.heatLossH2O) / heatExchanger.efficiency
      // + Simulation.parameter.energyTolerance)
      // steam losses + Thermal demand higher before HX // + inaccuracies
      // ::::::::::::::: HTF - Loop ::::::::::::::::::::::::::::::::::::::::::::
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
      // it seems that the current.temperature.outlet calculated below does not have great influence on the results.
      // It is used for calculating the HTF temp to heater when generating steam directly with gas of during solar field freeze protection
      if status.powerBlock.massFlow.isNearZero == false {
        if status.powerBlock.temperature.inlet
          >= heatExchanger.temperature.htf.inlet.min
        {
          HeatExchanger.update(powerBlock: &status.powerBlock,
                               hx: status.heatExchanger)

          if case .discharge = status.storage.operationMode,
            status.powerBlock.temperature.outlet.isLower(than: 534.0) {
            PowerBlock.heatExchangerBypass(&status)
          }
        }
      }
      var heatDiff: Double = 0.0
      // Iteration: Find the right powerBlock.temperature.inlet and temperature.outlet
      innerLoop: repeat {
        if Design.hasSolarField {
          thermal.solar = status.solarField.heatTransfered(with: htf) / 1_000

          let irradianceCosTheta = Double(meteo.dni) * status.collector.cosTheta

          if irradianceCosTheta <= 0 { // added to avoid Q.solar > 0 during some night and freeze protection time
            thermal.solar = 0
          }
          #warning("The implementation here differs from PCT")
          status.powerBlock.temperature.inlet = status.solarField.header.temperature.outlet

          status.powerBlock.massFlow = status.solarField.header.massFlow

          if abs(thermal.solar) > 0 { // Line 313
            thermal.production = thermal.solar
            //     status.powerBlock.temperature.inlet = status.solarField.header.temperature.outlet
            //   status.powerBlock.massFlow = status.solarField.header.massFlow
          } else if case .freezeProtection = status.solarField.operationMode {
            thermal.solar = 0
            thermal.production = 0
            //    status.powerBlock.massFlow = status.solarField.header.massFlow
            //    status.powerBlock.temperature.inlet = status.solarField.header.temperature.outlet
          } else {
            thermal.solar = 0
            thermal.production = 0
            status.powerBlock.massFlow = 0.0
            status.solarField.header.massFlow = 0.0
          }

        } else {
          thermal.solar = 0
          thermal.production = 0
          status.powerBlock.massFlow = 0.0
          status.solarField.header.massFlow = 0.0
        }

        if Design.hasStorage {
          Storage.update(&status, fuel: fuel)
        }

        if Design.hasGasTurbine {
          electric.gasTurbineGross = GasTurbine.update(&status, fuel: fuel)
        }

        if Design.hasHeater && !Design.hasBoiler {
          heaterFunction(&status, electric.gasTurbineGross, &heatDiff, fuel)
        } // Line 535

        // Freeze Protection
        switch status.heater.operationMode {
        case .normal, .reheat:
          break
        default:
          if status.solarField.header.temperature.outlet <
            htf.freezeTemperature + Simulation.parameter.dfreezeTemperatureHeat,
            status.storage.massFlow.isNearZero
          { // No freeze protection heater use anymore if storage is in operation
            status.heater.temperature.inlet = status.powerBlock.temperature.inlet
            status.heater.massFlow = status.powerBlock.massFlow
            status.heater.operationMode = .freezeProtection

            Heater.update(&status, thermalPower: &thermal.heater,
                          fuel: &fuelConsumption.heater,
                          demand: heatDiff, fuelAvailable: fuel
            )
            electricalParasitics.heater = Heater.parasitics(
              estimateFrom: status.heater.load)

          }
          switch status.heater.operationMode {
          case .freezeProtection:
            status.powerBlock.temperature.outlet = status.heater.temperature.outlet
          case .normal, .reheat: break
          default:
            if status.solarField.header.outletTemperature
              > htf.freezeTemperature.kelvin
              + Simulation.parameter.dfreezeTemperatureHeat.kelvin
            {
              status.heater.operationMode = .noOperation

              Heater.update(&status, thermalPower: &thermal.heater,
                            fuel: &fuelConsumption.heater,
                            demand: heatDiff, fuelAvailable: fuel
              )
              electricalParasitics.heater = Heater.parasitics(
                estimateFrom: status.heater.load)
            }

          }
        } // Heater.OPmode != "OP"
        // Freeze Protection

        // HX: powerBlock.temperature.inlet is known now, so calc. the real heatExchanger.temperature.outlet and thermal.production

        let storageNearFreeze = status.storage.operationMode.isFreezeProtection
        let solarFieldNearFreeze = status.solarField.operationMode.isFreezeProtection
        let heaterAntiFreeze = status.heater.operationMode.isFreezeProtection

        if status.powerBlock.temperature.inlet
          < heatExchanger.temperature.htf.inlet.min
          || status.powerBlock.massFlow.rate == 0
          || storageNearFreeze
        { // bypass HX
          if heaterAntiFreeze == false,
            solarFieldNearFreeze || storageNearFreeze
          {
            if Design.hasGasTurbine {
              status.powerBlock.temperature.outlet = status.powerBlock.temperature.inlet
            } else {
              let TLPB = 0.0 // 0.38 * (TpowerBlock.status - meteo.temperature) / 100 * (30 / Design.layout.powerBlock) ** 0.5 // 0.38

              var mfl = (status.solarField.header.massFlow
                + status.powerBlock.massFlow).rate

              mfl = mfl == 0 ? 0.1 : mfl

              status.powerBlock.temperature.inlet = Temperature(
                (status.solarField.header.massFlow.rate
                  * status.solarField.header.outletTemperature
                  + status.powerBlock.massFlow.rate
                  * status.storage.outletTemperature)
                  / mfl
              )
              #warning("The implementation here differs from PCT")
              // FIXME: Was ist Tstatus ?????????

              status.powerBlock.temperature.outlet = Temperature(
                (status.powerBlock.massFlow.rate
                  * Double(period) * status.powerBlock.inletTemperature
                  + status.powerBlock.outletTemperature
                  * (solarField.HTFmass
                    - status.powerBlock.massFlow.rate * Double(period)))
                  / solarField.HTFmass - TLPB
              )
            }
          }
          thermal.production = 0
          thermal.heatExchanger = 0
          status.heatExchanger.massFlow = 0.0
          break innerLoop
        }

        status.heatExchanger.massFlow = status.powerBlock.massFlow
        status.heatExchanger.temperature.inlet = status.powerBlock.temperature.inlet

        thermal.heatExchanger = HeatExchanger.update(
          &status.heatExchanger,
          steamTurbine: status.steamTurbine,
          storage: status.storage
        )

        if Design.hasGasTurbine, Design.hasStorage,
          thermal.heatExchanger > heatExchanger.sccHTFheat
        {
          thermal.dump += thermal.heatExchanger - heatExchanger.sccHTFheat
          thermal.heatExchanger = heatExchanger.sccHTFheat
        }
        status.powerBlock.temperature.outlet = status.heatExchanger.temperature.outlet

      } while abs((status.powerBlock.outletTemperature - status.heatExchanger.outletTemperature))
        > Simulation.parameter.tempTolerance.kelvin

      // FIXME: H2OinPB = H2OinHX

      thermal.production = thermal.heatExchanger + thermal.wasteHeatRecovery
      thermal.demand *= heatExchanger.efficiency
      // Therm heat demand is lower after HX:
      thermal.production *= Simulation.adjustmentFactor.heatLossH2O
      // - Unavoidable losses in Power Block -
      var Qsf_load = 0.0
      if Design.hasBoiler { // - if Boiler is designed -
        let adjustmentFactor = Simulation.adjustmentFactor
        if case .solarOnly = Control.whichOptimization {
          if thermal.production < adjustmentFactor.efficiencyHeater,
            thermal.production >= adjustmentFactor.efficiencyBoiler
          {
            switch status.boiler.operationMode {
            case .startUp, .SI, .NI:
              break
            default:
              status.boiler.operationMode = .unknown
            }

            heatDiff = thermal.production - thermal.demand
            if Boiler.parameter.booster { // booster superheater
              if thermal.heater == Design.layout.heater { // Firm Output case
                // for shams-1 769% of the boiler load is used during firm output. no time to find a nice formula. sorry!
                Qsf_load = 0.769
              } else {
                Qsf_load = thermal.production / (Design.layout.heatExchanger
                  / steamTurbine.efficiencyNominal)
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
          Qsf_load = thermal.production /
            (Design.layout.heatExchanger / steamTurbine.efficiencyNominal)
        }

        thermal.boiler = Boiler.update(
          &status.boiler, fuel: &fuelConsumption.boiler,
          heatFlow: heatDiff, Qsf_load: Qsf_load, fuelAvailable: fuel
        )

        electricalParasitics.boiler = Boiler.parasitics(estimate: status.boiler)

        if Fuelmode.isPredefined { // predefined fuel consumption in *.pfc-file
          if (thermal.heatExchanger + thermal.boiler) > 110 {
            thermal.boiler = 105 - thermal.heatExchanger
          }

          thermal.production = (thermal.heatExchanger + thermal.wasteHeatRecovery)
            * adjustmentFactor.heatLossH2O + thermal.boiler
        }
      }
      let heat = thermal.production - steamTurbine.power.max
        / SteamTurbine.efficiency(status, maxLoad: &maxLoad)
      if heat > Simulation.parameter.heatTolerance { // TB.Overload
        print(TimeStep.current, "Overloading TB: \(heat) MWH,th\n")
      } else if thermal.production - thermal.demand > 2 * Simulation.parameter.heatTolerance {
          print(TimeStep.current, "Production > demand: \(thermal.production - thermal.demand) MWH,th\n")
      }
      let PminT = steamTurbine.minPowerFromTemp
      let minLoad: Double
      if (PminT[0] == 1 || PminT[0] == 0)
        && PminT[1] == 0 && PminT[2] == 0 && PminT[3] == 0 && PminT[4] == 0
      {
        #warning("The implementation here differs from PCT")
        minLoad = steamTurbine.power.min / steamTurbine.power.max
      } else {
        minLoad = steamTurbine.minPowerFromTemp[ambientTemperature] / steamTurbine.power.max
      } /*
       var Lmax = 0.0
       if Heater.parameter.operationMode {
       steamTurbine.efficiencyFirmOutput = SteamTurbine.efficiency(minLoad, maxLoad: &Lmax) // only for shams-1

       if Heater.parameter.operationMode { // Changed for Dry Cooling
       steamTurbine.efficiencyFirmOutput = SteamTurbine.efficiency(minLoad, maxLoad: &Lmax) // only for shams-1
       } else {
       steamTurbine.efficiencyFirmOutput = steamTurbine.efficiencyNominal
       }
       }
       // not used !!! var Qblank: Double
       */
      if (PminT[0] == 1 || PminT[0] == 0)
        && PminT[1] == 0 && PminT[2] == 0 && PminT[3] == 0 && PminT[4] == 0
      {
        if 0 < thermal.production && thermal.production
          < steamTurbine.power.min / steamTurbine.efficiencyNominal {
          💬.infoMessage(
"Damping (SteamTurbine underload): \(thermal.production) MWH,th. \(TimeStep.current)")
          // not used !!! Qblank = thermal.production
          thermal.production = 0
        }
      } else {
        var minPower = steamTurbine.minPowerFromTemp[ambientTemperature]
        var maxLoad = Ratio(0)
        minPower = max(steamTurbine.power.nominal * minPower, steamTurbine.power.min)
        if 0 < thermal.production && thermal.production
          < minPower / SteamTurbine.efficiency(status, maxLoad: &maxLoad) {
          // efficiency at min. load instead of nominal, has effect for dry cooling!
          💬.infoMessage(
"Damping (SteamTurbine underload): \(thermal.production) MWH,th. \(TimeStep.current)")
          // not used !!! Qblank = thermal.production
          thermal.production = 0
        }
      }

      let qad = thermal.storage + thermal.boiler

      electric.steamTurbineGross = PowerBlock.update(
        &status, heat: &thermal.production,
        electricalParasitics: &electricalParasitics.powerBlock,
        Qsto: qad, meteo: meteo
      )
        * SteamTurbine.efficiency(status, maxLoad: &maxLoad)

      if thermal.production == 0 { // added to separate shared facilities parasitics
        electricalParasitics.shared = PowerBlock.parameter.electricalParasiticsShared[0] // no operation
      } else {
        electricalParasitics.shared = PowerBlock.parameter.electricalParasiticsShared[1] // operation and start up
      }

      if Fuelmode.isPredefined { // predifined fuel consumption in *.pfc-file
        if Plant.fuelConsumption.combined > 0 && electric.steamTurbineGross
          > steamTurbine.power.max + 1 {
          electric.steamTurbineGross = steamTurbine.power.max + 1
        }
        if Plant.fuelConsumption.combined > 0, thermal.solar > 0,
          electric.steamTurbineGross > steamTurbine.power.max - 1 {
          electric.steamTurbineGross = steamTurbine.power.max - 1
        }
      }

      if Design.hasStorage {
        if case .always = storage.strategy {}
        else if electric.steamTurbineGross > electric.demand { // new restriction of production
          dumping = electric.steamTurbineGross - electric.demand
          electric.steamTurbineGross = electric.demand
        }
      } else { /* if Heater.parameter.operationMode */ // following uncomment for Shams-1.
        if electric.steamTurbineGross > electric.demand {
          let electricEnergyFactor = electric.demand / electric.steamTurbineGross
          dumping = electric.steamTurbineGross - electric.demand
            * electricEnergyFactor
          heatDiff *= electricEnergyFactor
          Qsf_load *= electricEnergyFactor

          thermal.boiler = Boiler.update(
            &status.boiler, fuel: &fuelConsumption.boiler,
            heatFlow: heatDiff, Qsf_load: Qsf_load, fuelAvailable: fuel
          )

          electricalParasitics.boiler = Boiler.parasitics(estimate: status.boiler)

          thermal.solar *= electricEnergyFactor
          // reduction in Qsol should be necessary for every project withoput storage
          thermal.heatExchanger *= electricEnergyFactor

          let qad = thermal.storage + thermal.boiler

          electric.steamTurbineGross = PowerBlock.update(
            &status, heat: &thermal.production,
            electricalParasitics: &electricalParasitics.powerBlock,
            Qsto: qad, meteo: meteo
          )
            * SteamTurbine.efficiency(status, maxLoad: &maxLoad)

          if thermal.production == 0 {
            // added to separate shared facilities parasitics
            electricalParasitics.shared =
              PowerBlock.parameter.electricalParasiticsShared[0]
          } else {
            electricalParasitics.shared =
              PowerBlock.parameter.electricalParasiticsShared[1]
          }
        }
      }

      electric.gross = electric.steamTurbineGross
        + electric.gasTurbineGross

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

      electric.parasitics *=
        Simulation.adjustmentFactor.electricalParasitics
      let diff = abs(electricalParasiticsAssumed - electric.parasitics)

      if diff < 3 * Simulation.parameter.electricalTolerance {
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
          // oldHR = thermal.heater
        }
        break outerLoop
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

  static func heaterFunction(_ status: inout Plant.PerformanceData,
                             _ supplyGasTurbine: Double,
                             _ heatdiff: inout Double,
                             _ fuel: Double) {
    let storage = Storage.parameter
    //   heatdiff = 0
    // restart variable to avoid errors due to Boiler.  added for Shams-1
    if case .pc = status.gasTurbine.operationMode {
      // Plant updates in Pure CC Mode now again without RH!!
      // demand * WasteHeatRecovery.parameter.effPure * (1 / gasTurbine.efficiency- 1)) heat supplied by the WHR system
    } else if case .ic = status.gasTurbine.operationMode { // Plant does not update in Pure CC Mode
      let HTFenergy = supplyGasTurbine * (1
        / GasTurbine.efficiency(at: status.gasTurbine.load) - 1)
        * WasteHeatRecovery.parameter.efficiencyNominal
        / WasteHeatRecovery.parameter.ratioHTF

      heatdiff = thermal.production - HTFenergy // -^- necessary HTF share

      status.heater.temperature.inlet = status.powerBlock.temperature.outlet
      Heater.update(&status, thermalPower: &thermal.heater,
                    fuel: &fuelConsumption.heater,
                    demand: heatdiff, fuelAvailable: fuel)
      electricalParasitics.heater = Heater.parasitics(estimateFrom: status.heater.load)

      status.powerBlock.temperature.inlet = htf.mixingTemperature(
        inlet: status.powerBlock, with: status.heater
      )

      status.powerBlock.massFlow += status.heater.massFlow
    } else if case .noOperation = status.gasTurbine.operationMode {
      // GasTurbine does not update at all (Load<Min?)
      Heater.update(&status, thermalPower: &thermal.heater,
                    fuel: &fuelConsumption.heater,
                    demand: heatdiff, fuelAvailable: fuel)

      electricalParasitics.heater = Heater.parasitics(estimateFrom: status.heater.load)

      status.powerBlock.temperature.inlet = htf.mixingTemperature(
        outlet: status.solarField, with: status.heater
      )

      status.powerBlock.massFlow = status.solarField.header.massFlow
      status.powerBlock.massFlow += status.heater.massFlow
    } else { // gasTurbine.OPmode is neither IC nor PC
      // Line 429 STO STO STO STO STO

      if Design.hasStorage {
        if heatdiff < 0,
          status.storage.heatRelease < storage.dischargeToTurbine,
          status.storage.heatRelease > storage.dischargeToHeater
        {
          // Direct Discharging to SteamTurbine and heatdiff > 0 (Energy Surplus) see above
          if fuel > 0 { // Fuel available, Storage for Pre-Heating
            Storage.update(&status, mode: .preheat)

            status.heater.temperature.inlet = status.storage.temperature.outlet

            status.heater.operationMode = .unknown

            heatdiff = thermal.production + thermal.storage - thermal.demand

            Heater.update(&status, thermalPower: &thermal.heater,
                          fuel: &fuelConsumption.heater,
                          demand: heatdiff, fuelAvailable: fuel
            )
            electricalParasitics.heater = Heater.parasitics(estimateFrom: status.heater.load)

            status.heater.massFlow = status.storage.massFlow

            status.powerBlock.temperature.inlet = htf.mixingTemperature(
              outlet: status.solarField, with: status.heater
            )

            status.powerBlock.massFlow = status.solarField.header.massFlow
            status.powerBlock.massFlow += status.heater.massFlow
          } else { // NO Fuel Available -> Discharge directly with reduced TB load!
            Storage.update(&status, mode: .discharge)

            status.powerBlock.temperature.inlet = htf.mixingTemperature(
              outlet: status.solarField, with: status.storage
            )

            status.powerBlock.massFlow = status.storage.massFlow
            status.powerBlock.massFlow += status.solarField.header.massFlow
          } // STORAGE: dischargeToHeater < Qrel < dischargeToTurbine;  Fuel/NoFuel
        } else if heatdiff < 0, status.storage.heatRelease < Storage.parameter.dischargeToHeater,
          status.heater.operationMode != .freezeProtection
        {
          // = Storage is empty!! && Heater.operationMode != .freezeProtection // <= added instead of "<"
          heatdiff = thermal.production + thermal.wasteHeatRecovery
            / HeatExchanger.parameter.efficiency - demand.ratio * thermal.demand
          // added to avoid heater use is storage is selected and checkbox marked:
          if thermal.production == 0 { // use heater only in parallel with solar field and not as stand alone.
            // heatdiff = 0 // commented to use gas not only in paralell to SF (for AH1)
            if Heater.parameter.onlyWithSolarField {
              heatdiff = 0
            }
          }
          status.heater.temperature.inlet = status.powerBlock.temperature.outlet
          Heater.update(&status, thermalPower: &thermal.heater,
                        fuel: &fuelConsumption.heater,
                        demand: heatdiff, fuelAvailable: fuel
          )
          electricalParasitics.heater = Heater.parasitics(estimateFrom: status.heater.load)

          status.powerBlock.temperature.inlet = htf.mixingTemperature(
            outlet: status.solarField, with: status.heater
          )

          status.powerBlock.massFlow = status.solarField.massFlow
          status.powerBlock.massFlow += status.heater.massFlow
        }
      } else { // No Storage
        heatdiff = thermal.production + thermal.wasteHeatRecovery
          / HeatExchanger.parameter.efficiency - thermal.demand

        if thermal.production == 0 {
          // use heater only in parallel with solar field and not as stand alone.
          if Heater.parameter.onlyWithSolarField {
            heatdiff = 0
          }
        }
        
        status.heater.temperature.inlet = status.powerBlock.temperature.outlet
        Heater.update(&status, thermalPower: &thermal.heater,
                      fuel: &fuelConsumption.heater,
                      demand: heatdiff, fuelAvailable: fuel)
        electricalParasitics.heater = Heater.parasitics(estimateFrom: status.heater.load)

        if (status.solarField.header.massFlow + status.heater.massFlow).isNearZero {
          status.powerBlock.temperature.inlet = status.powerBlock.temperature.inlet // Freeze Protection
        } else {
          status.powerBlock.temperature.inlet = htf.mixingTemperature(
            outlet: status.solarField, with: status.heater
          )
        }
        status.powerBlock.massFlow = status.solarField.massFlow
        status.powerBlock.massFlow += status.heater.massFlow
      }
    }

    if status.heater.massFlow.isNearZero == false{
      thermal.production = status.powerBlock.heatTransfered(with: htf) / 1_000
    }
  }

  static func reset() {
    thermal = ThermalEnergy()
    fuelConsumption = FuelConsumption()
    electricalParasitics = Parasitics()
    electric = ElectricEnergy()
    demand = 1.0
    SolarField.lastDNI = 0.0
    SolarField.temperatureLast = Temperature()
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
          / htf.heatDelta(heatExchanger.scc.htf.outlet.max,
                          heatExchanger.scc.htf.inlet.max)
      )

      WasteHeatRecovery.parameter.ratioHTF = heatExchanger.sccHTFheat
        / (steamTurbine.power.max - heatExchanger.sccHTFheat)
    } else {
      if Design.layout.heatExchanger != Design.layout.powerBlock {
        HeatExchanger.parameter.sccHTFheat = Design.layout.heatExchanger
          / steamTurbine.efficiencyNominal
          / heatExchanger.efficiency
      } else {
        HeatExchanger.parameter.sccHTFheat = steamTurbine.power.max
          / steamTurbine.efficiencyNominal
          / heatExchanger.efficiency
      }
      SolarField.parameter.massFlow.max = MassFlow(
        heatExchanger.sccHTFheat * 1_000
          / htf.heatDelta(heatExchanger.temperature.htf.inlet.max,
                          heatExchanger.temperature.htf.outlet.max)
      )
    }

    if Design.hasSolarField {
      SolarField.parameter.edgeFactor = [solarField.distanceSCA / 2
        * (1 - 1 / Double(solarField.numberOfSCAsInRow))
        / Collector.parameter.lengthSCA] // Constants
      SolarField.parameter.edgeFactor += [(1.0 + 1.0
          / Double(solarField.numberOfSCAsInRow))
        / Collector.parameter.lengthSCA / 2]
    }
  }
}
