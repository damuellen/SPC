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

enum Plant {
  static var location: Location!
  static var ambientTemperature = Temperature()
  static var availability = Availability.withDefaults()
  static var electricEnergy = ElectricEnergy()
  static var electricalParasitics = Parasitics()
  static var thermal = ThermalEnergy()
  static var fuelFlow = FuelConsumption()
  static var demand: Ratio = 1.0
  static let initialState = PerformanceData()

  static func update(_ status: inout Plant.PerformanceData, at _: TimeStep,
                     fuel: inout Double, meteo: MeteoData) {
    self.ambientTemperature = Temperature(celsius: meteo.temperature)

    // storage.mass.hot = heatExchanger.temperature.h2o.inlet.max
    // storage.mass.cold = heatExchanger.temperature.h2o.inlet.min

    status.storage.mass.hot = storage.startLoad.hot
    status.storage.mass.cold = storage.startLoad.cold
    // storage.temperatureTank.hot = heatExchanger.temperature.h2o.outlet.max
    // storage.temperatureTank.cold = heatExchanger.temperature.h2o.outlet.max

    var electricalParasiticsAssumed: Double = 0.0
    if Design.hasGasTurbine {
      // for SEGS plant Demand is set to max SteamTurbine Power (because of spanish new legislation)
      self.electricEnergy.demand = self.demand.ratio * (Design.layout.powerBlock - Design.layout.gasTurbine)
      // Electric demand scc
      electricalParasiticsAssumed = self.electricEnergy.demand
        * Simulation.parameter.electricalParasitics
      // Iter. start val. for parasitics, 10% demand
      self.electricEnergy.demand += electricalParasiticsAssumed
    } else {
      self.electricEnergy.demand = self.demand.ratio * steamTurbine.power.max
      // added to try to limit output to demand file
    }
    var dumping: Double = 0.0

    // Iteration to account for correct parasitics
    iteration(&status, &fuel, meteo, &dumping, &electricalParasiticsAssumed)

    if Design.hasStorage {
      Storage.calculate(storage: &status.storage,
                        powerBlock: &status.powerBlock,
                        steamTurbine: status.steamTurbine)
    }

    self.thermal.dump += dumping

    self.electricEnergy.net = self.electricEnergy.gross - self.electricEnergy.parasitics // - Net electric power -

    if self.electricEnergy.net < 0 {
      self.electricEnergy.consum = -self.electricEnergy.net
      self.electricEnergy.net = 0
    } else {
      self.electricEnergy.consum = 0
    }

    if Design.hasGasTurbine {
      self.electricEnergy.demand = self.demand.ratio
        * (Design.layout.powerBlock - Design.layout.gasTurbine) // just for WriteOpRep
    } else {
      self.electricEnergy.demand = steamTurbine.power.max
    }

    if true /* Ctl.AS = 1 */ && self.thermal.solar > 0 {
      // Average HTF temp. in loop [K]
      self.thermal.solar = self.thermal.solar
        + (1 - solarField.SSFHL / solarField.pipeHeatLosses)
        * SolarField.pipeHeatLoss(status.solarField.header.averageTemperature,
                                  ambient: self.ambientTemperature)
        * Design.layout.solarField
        * Double(solarField.numberOfSCAsInRow)
        * 2 * collector.areaSCAnet / 1_000_000
    }
    // H2OinHX.temperature.inlet = H2OinPB.temperature.outlet
  }

  static func iteration(_ status: inout Plant.PerformanceData,
                        _ fuel: inout Double,
                        _ meteo: MeteoData,
                        _ dumping: inout Double,
                        _ electricalParasiticsAssumed: inout Double) {
    var maxLoad = Ratio(0)
    // Iteration to account for correct parasitics
    outerLoop: for _ in 1 ... 10 {
      if Design.hasGasTurbine {
        self.electricEnergy.demand = self.demand.ratio
        self.electricEnergy.demand *= (Design.layout.powerBlock - Design.layout.gasTurbine)
        self.electricEnergy.demand += self.electricEnergy.demand
          * Simulation.parameter.electricalParasitics // ist hier nochmals neu von oben eingefügt worden
      } else {
        self.electricEnergy.demand = Plant.demand.ratio * steamTurbine.power.max
        // added to try to limit output to demand file
      }

      status.steamTurbine.load = Ratio((self.electricEnergy.demand + Design.layout.gasTurbine)
        / steamTurbine.power.max)
      let efficiency = SteamTurbine.efficiency(&status, maxLoad: &maxLoad)
      switch storage.strategy {
      case .demand:
        self.thermal.demand = 20 // min(heatExchanger.sccHTFthermal,
      //  steamTurbine.power.max / efficiency)
      // * demand deleted, should be 100% demand (?)// comparison with HX cap. written to restrict HX capacity
      case .shifter:
        self.thermal.demand = min(heatExchanger.sccHTFthermal,
                                  steamTurbine.power.max * self.demand.ratio / efficiency)
      // strategy ful added again, same as always? comparison with HX cap. written to restrict HX capacity
      default:
        self.thermal.demand = min(heatExchanger.sccHTFthermal,
                                  self.electricEnergy.demand / efficiency)
        //  demand deleted since is calculated before in electricEnergy.demand
        //  demand added because electricEnergy.demand is only steamTurbine.power.max
        //  steamTurbine.load // wird hier jetzt mit electricEnergy.demand berechnet,
        //  comparison with HX cap. written to restrict HX capacity
      }

      if status.steamTurbine.isMaintained {
        status.steamTurbine.load = 0.0
        self.electricEnergy.demand = 0
        self.thermal.demand = 0
      } else if status.steamTurbine.load > Plant.availability.value.powerBlock {
        // - TB Load > Availability -
        status.steamTurbine.load = Plant.availability.value.powerBlock
        self.thermal.demand = min(
          heatExchanger.sccHTFthermal,
          steamTurbine.power.max
            * Plant.availability.value.powerBlock.ratio
            / SteamTurbine.efficiency(&status, maxLoad: &maxLoad)
        )
        // comparison with HX cap. written to restrict HX capacity
      }

      self.thermal.demand = (self.thermal.demand / Simulation.adjustmentFactor.heatLossH2O)
        / heatExchanger.efficiency // + Simulation.parameter.energyTolerance)
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
      if !status.powerBlock.massFlow.isNearZero {
        if status.powerBlock.temperature.inlet >= heatExchanger.temperature.htf.inlet.min {
          self.heatExchangerFunction(&status)
        }
      }
      var heatdiff: Double = 0.0
      // Iteration: Find the right powerBlock.temperature.inlet and temperature.outlet
      innerLoop: while true {
        if Design.hasSolarField {
          self.thermal.solar = status.solarField.heatTransfered(with: htf) / 1_000

          let irradianceCosTheta = Double(meteo.dni) * status.collector.cosTheta

          if irradianceCosTheta <= 0 { // added to avoid Q.solar > 0 during some night and freeze protection time
            self.thermal.solar = 0
          }
          #warning("The implementation here differs from PCT")
          status.powerBlock.temperature.inlet = status.solarField.header.temperature.outlet
          status.powerBlock.massFlow = status.solarField.header.massFlow
          if abs(self.thermal.solar) > 0 { // Line 313
            self.thermal.production = self.thermal.solar
            //     status.powerBlock.temperature.inlet = status.solarField.header.temperature.outlet
            //   status.powerBlock.massFlow = status.solarField.header.massFlow
          } else { // if thermal.solar < 0
            if case .freezeProtection = status.solarField.operationMode {
              thermal.solar = 0
              thermal.production = 0
              //    status.powerBlock.massFlow = status.solarField.header.massFlow
              //    status.powerBlock.temperature.inlet = status.solarField.header.temperature.outlet
            } else {
              self.thermal.solar = 0
              self.thermal.production = 0
              status.powerBlock.massFlow = 0.0
              status.solarField.header.massFlow = 0.0
            }
          }
        } else {
          self.thermal.solar = 0
          self.thermal.production = 0
          status.powerBlock.massFlow = 0.0
          status.solarField.header.massFlow = 0.0
        }

        if true { // Design.hasStorage {
          Storage.update(&status, fuel: &fuel, fuelConsumption: &self.fuelFlow, thermal: &self.thermal)
        }
        var supplyGasTurbine: Double = 0.0
        if Design.hasGasTurbine {
          supplyGasTurbine = GasTurbine.update(
            &status, fuel: &fuel, fuelFlow: &self.fuelFlow,
            electricEnergy: &self.electricEnergy, thermal: &self.thermal
          )
        }

        if Design.hasHeater && !Design.hasBoiler {
          self.heaterFunction(&status, supplyGasTurbine, &heatdiff, fuel, self.demand.ratio)
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

            Heater.update(&status, demand: 1, fuel: fuel,
                          thermal: &self.thermal, fuelFlow: &self.fuelFlow.heater)

            self.electricalParasitics.heater = Heater.parasitics(at: status.heater.load)

            switch status.heater.operationMode {
            case .freezeProtection:
              status.powerBlock.temperature.outlet = status.heater.temperature.outlet
            case .normal, .reheat: break
            default:
              if status.solarField.header.temperature.outlet.kelvin
                > htf.freezeTemperature.kelvin
                + Simulation.parameter.dfreezeTemperatureHeat.kelvin {
                status.heater.operationMode = .noOperation

                Heater.update(&status, demand: 0, fuel: fuel,
                              thermal: &self.thermal, fuelFlow: &self.fuelFlow.heater)

                self.electricalParasitics.heater = Heater.parasitics(at: status.heater.load)
              }
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
          || storageNearFreeze {
          // bypass HX

          if !heaterAntiFreeze && solarFieldNearFreeze || storageNearFreeze {
            if Design.hasGasTurbine {
              status.powerBlock.temperature.outlet = status.powerBlock.temperature.inlet
            } else {
              let TLPB = 0.0 // 0.38 * (TpowerBlock.status - meteo.temperature) / 100 * (30 / Design.layout.powerBlock) ** 0.5 // 0.38

              status.powerBlock.temperature.inlet = Temperature(
                (status.solarField.header.massFlow.rate
                  * status.solarField.header.temperature.outlet.kelvin
                  + status.powerBlock.massFlow.rate
                  * status.storage.temperature.outlet.kelvin)
                  / (status.solarField.header.massFlow
                    + status.powerBlock.massFlow).rate
              )
              #warning("The implementation here differs from PCT")
              // FIXME: Was ist Tstatus ?????????

              status.powerBlock.temperature.outlet = Temperature(
                (status.powerBlock.massFlow.rate
                  * Double(period) * status.powerBlock.temperature.inlet.kelvin
                  + status.powerBlock.temperature.outlet.kelvin
                  * (solarField.HTFmass
                    - status.powerBlock.massFlow.rate * Double(period)))
                  / solarField.HTFmass - TLPB
              )
            }
          }
          self.thermal.production = 0
          self.thermal.heatExchanger = 0
          status.heatExchanger.massFlow = 0.0
          break innerLoop
        }

        status.heatExchanger.massFlow = status.powerBlock.massFlow
        status.heatExchanger.temperature.inlet = status.powerBlock.temperature.inlet

        self.thermal.heatExchanger = HeatExchanger.update(
          &status.heatExchanger, steamTurbine: status.steamTurbine,
          storage: status.storage
        )

        if Design.hasGasTurbine,
          Design.hasStorage,
          self.thermal.heatExchanger > heatExchanger.sccHTFthermal {
          self.thermal.dump += self.thermal.heatExchanger - heatExchanger.sccHTFthermal
          self.thermal.heatExchanger = heatExchanger.sccHTFthermal
        }

        if abs((status.powerBlock.temperature.outlet.kelvin - status.heatExchanger.temperature.outlet.kelvin))
          < Simulation.parameter.tempTolerance.kelvin {
          break innerLoop
        }

        status.powerBlock.temperature.outlet = status.heatExchanger.temperature.outlet
        // TpowerBlock.status = powerBlock.temperature.outlet
      } // Iteration ends: Find the right powerBlock.temperature.inlet and temperature.outlet

      // FIXME: H2OinPB = H2OinHX

      self.thermal.production = self.thermal.heatExchanger + self.thermal.wasteHeatRecovery
      self.thermal.demand *= heatExchanger.efficiency
      // Therm heat demand is lower after HX:
      self.thermal.production *= Simulation.adjustmentFactor.heatLossH2O
      // - Unavoidable losses in Power Block -
      var Qsf_load = 0.0
      if Design.hasBoiler { // - if Boiler is designed -
        let adjustmentFactor = Simulation.adjustmentFactor
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

        if self.thermal.heater == Design.layout.heater { // Firm Output case
          // for shams-1 769% of the boiler load is used during firm output. no time to find a nice formula. sorry!
          Qsf_load = 0.769
        } else {
          Qsf_load = self.thermal.production / (Design.layout.heatExchanger
            / steamTurbine.efficiencyNominal)
        }

        self.thermal.boiler = Boiler.update(
          &status.boiler, thermal: heatdiff, Qsf_load: Qsf_load,
          fuel: &fuel, fuelFlow: &self.fuelFlow.boiler
        )

        self.electricalParasitics.boiler = Boiler.parasitics(boiler: status.boiler)

        if Fuelmode.isPredefined { // predefined fuel consumption in *.pfc-file
          if (self.thermal.heatExchanger + self.thermal.boiler) > 110 {
            self.thermal.boiler = 105 - self.thermal.heatExchanger
          }

          self.thermal.production = (self.thermal.heatExchanger + self.thermal.wasteHeatRecovery)
            * adjustmentFactor.heatLossH2O + self.thermal.boiler
        }
      }

      if self.thermal.production - steamTurbine.power.max
        / SteamTurbine.efficiency(&status, maxLoad: &maxLoad)
        > Simulation.parameter.heatTolerance { // TB.Overload
        //  print(TimeStep.current, "Overloading TB: \(thermal.production - steamTurbine.power.max / SteamTurbine.efficiency(&status, maxLoad: &maxLoad)) MWH,th\n")
      } else if self.thermal.production - self.thermal.demand > 2 * Simulation.parameter.heatTolerance {
        //  print(TimeStep.current, "Production > demand: \(thermal.production - thermal.demand) MWH,th\n")
      }
      let PminT = steamTurbine.minPowerFromTemp
      let minLoad: Double
      if (PminT[0] == 1 || PminT[0] == 0)
        && PminT[1] == 0 && PminT[2] == 0 && PminT[3] == 0 && PminT[4] == 0 {
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
        && PminT[1] == 0 && PminT[2] == 0 && PminT[3] == 0 && PminT[4] == 0 {
        if 0 < self.thermal.production
          && self.thermal.production
          < steamTurbine.power.min
          / steamTurbine.efficiencyNominal {
          print(TimeStep.current, "Damping (SteamTurbine underload): \(self.thermal.production) MWH,th")
          // not used !!! Qblank = thermal.production
          self.thermal.production = 0
        }
      } else {
        var minPower = steamTurbine.minPowerFromTemp[ambientTemperature]
        var maxLoad = Ratio(0)
        minPower = max(steamTurbine.power.nominal * minPower, steamTurbine.power.min)
        if 0 < self.thermal.production && self.thermal.production
          < minPower / SteamTurbine.efficiency(&status, maxLoad: &maxLoad) {
          // efficiency at min. load instead of nominal, has effect for dry cooling!
          print(TimeStep.current, "Damping (SteamTurbine underload): \(self.thermal.production) MWH,th")
          // not used !!! Qblank = thermal.production
          self.thermal.production = 0
        }
      }

      let qad = thermal.storage + thermal.boiler

      electricEnergy.steamTurbineGross = PowerBlock.update(
        &status, heat: &thermal.production,
        electricalParasitics: &electricalParasitics.powerBlock,
        Qsto: qad, meteo: meteo
      )
        * SteamTurbine.efficiency(&status, maxLoad: &maxLoad)

      if self.thermal.production == 0 { // added to separate shared facilities parasitics
        self.electricalParasitics.shared = PowerBlock.parameter.electricalParasiticsShared[0] // no operation
      } else {
        self.electricalParasitics.shared = PowerBlock.parameter.electricalParasiticsShared[1] // operation and start up
      }

      if Fuelmode.isPredefined { // predifined fuel consumption in *.pfc-file
        if self.fuelFlow.combined > 0 && self.electricEnergy.steamTurbineGross
          > steamTurbine.power.max + 1 {
          self.electricEnergy.steamTurbineGross = steamTurbine.power.max + 1
        }
        if self.fuelFlow.combined > 0, self.thermal.solar > 0,
          self.electricEnergy.steamTurbineGross > steamTurbine.power.max - 1 {
          self.electricEnergy.steamTurbineGross = steamTurbine.power.max - 1
        }
      }

      if Design.hasStorage {
        if case .always = storage.strategy {}
        else if self.electricEnergy.steamTurbineGross > self.electricEnergy.demand { // new restriction of production
          dumping = self.electricEnergy.steamTurbineGross - self.electricEnergy.demand
          self.electricEnergy.steamTurbineGross = self.electricEnergy.demand
        }
      } else { /* if Heater.parameter.operationMode */ // following uncomment for Shams-1.
        if self.electricEnergy.steamTurbineGross > self.electricEnergy.demand {
          let electricEnergyFactor = electricEnergy.demand / electricEnergy.steamTurbineGross
          dumping = electricEnergy.steamTurbineGross - electricEnergy.demand
            * electricEnergyFactor
          heatdiff *= electricEnergyFactor
          Qsf_load *= electricEnergyFactor

          thermal.boiler = Boiler.update(
            &status.boiler, thermal: heatdiff, Qsf_load: Qsf_load,
            fuel: &fuel, fuelFlow: &fuelFlow.boiler
          )

          electricalParasitics.boiler = Boiler.parasitics(boiler: status.boiler)

          thermal.solar *= electricEnergyFactor
          // reduction in Qsol should be necessary for every project withoput storage
          thermal.heatExchanger *= electricEnergyFactor

          let qad = thermal.storage + thermal.boiler

          electricEnergy.steamTurbineGross = PowerBlock.update(
            &status, heat: &thermal.production,
            electricalParasitics: &electricalParasitics.powerBlock,
            Qsto: qad, meteo: meteo
          ) * SteamTurbine.efficiency(&status, maxLoad: &maxLoad)

          if self.thermal.production == 0 {
            // added to separate shared facilities parasitics
            self.electricalParasitics.shared =
              PowerBlock.parameter.electricalParasiticsShared[0]
          } else {
            self.electricalParasitics.shared =
              PowerBlock.parameter.electricalParasiticsShared[1]
          }
        }
      }

      self.electricEnergy.gross = self.electricEnergy.steamTurbineGross
        + self.electricEnergy.gasTurbineGross

      // + GasTurbine = total productionuced electricity
      self.electricEnergy.solarField += self.electricalParasitics.storage
      self.electricEnergy.storage = self.electricalParasitics.storage

      // electricEnergy.parasiticsBU = electricalParasitics.heater + electricalParasitics.boiler
      self.electricEnergy.powerBlock = self.electricalParasitics.powerBlock
      self.electricEnergy.shared = self.electricalParasitics.shared

      self.electricEnergy.parasitics = self.electricEnergy.solarField
        + self.electricEnergy.gasTurbine
        + self.electricalParasitics.powerBlock
        + self.electricalParasitics.shared

      self.electricEnergy.parasitics *=
        Simulation.adjustmentFactor.electricalParasitics
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
        if self.thermal.heater > 0 {
          // oldHR = thermal.heater
        }
        break outerLoop
      }

      electricalParasiticsAssumed = self.electricEnergy.parasitics

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
    if case .discharge = status.storage.operationMode,
      status.powerBlock.temperature.outlet.isLower(than: 534.0) {
      // added to simulate a bypass on the PB-HX if the expected outlet temp is so low that the salt to TES could freeze
      let totalMassFlow = status.powerBlock.massFlow
      for _ in 1 ... 100 {
        let massFlowLoad = status.powerBlock.massFlow.share(
          of: solarField.massFlow.max
        )

        if heatExchanger.Tout_f_Mfl,
          !heatExchanger.Tout_f_Tin,
          !heatExchanger.useAndsolFunction,
          let ToutMassFlow = heatExchanger.ToutMassFlow {
          // if temperature.outlet is dependant on massflow, recalculate temperature.outlet
          var temperaturFactor = ToutMassFlow[massFlowLoad]
          if temperaturFactor > 1 { temperaturFactor = 1 }
          status.powerBlock.temperature.outlet =
            heatExchanger.temperature.htf.outlet.max
            .adjusted(with: temperaturFactor)
        } else if heatExchanger.Tout_f_Mfl,
          heatExchanger.Tout_f_Tin,
          !heatExchanger.useAndsolFunction,
          let ToutMassFlow = heatExchanger.ToutMassFlow,
          let ToutTin = heatExchanger.ToutTin {
          var temperaturFactor = ToutMassFlow[massFlowLoad]
          temperaturFactor *= ToutTin[status.powerBlock.temperature.inlet]
          status.powerBlock.temperature.outlet =
            heatExchanger.temperature.htf.outlet.max
            .adjusted(with: temperaturFactor)
        } else if heatExchanger.useAndsolFunction {
          var temperaturFactor = (
            (0.0007592419869 * (status.powerBlock.temperature.inlet.kelvin
                / heatExchanger.temperature.htf.inlet.max.kelvin)
              * 666 + 0.4943825893223)
              * massFlowLoad.ratio ** (0.0001400823882
                * (status.powerBlock.temperature.inlet.kelvin
                  / heatExchanger.temperature.htf.inlet.max.kelvin)
                * 666 - 0.0110227028559)
          ) - 0.000151639
          temperaturFactor = HeatExchanger.limit(temperaturFactor)
          status.powerBlock.temperature.outlet =
            heatExchanger.temperature.htf.outlet.max
            .adjusted(with: temperaturFactor)
        } else if heatExchanger.Tout_exp_Tin_Mfl,
          let ToutTinMassFlow = heatExchanger.ToutTinMassFlow {
          var temperaturFactor = (ToutTinMassFlow[0]
            * (status.powerBlock.temperature.inlet.kelvin
              / heatExchanger.temperature.htf.inlet.max.kelvin)
            * 666 + ToutTinMassFlow[1])
            * massFlowLoad.ratio ** (ToutTinMassFlow[2]
              * (status.powerBlock.temperature.inlet.kelvin
                / heatExchanger.temperature.htf.inlet.max.kelvin)
              * 666 + ToutTinMassFlow[3]) + ToutTinMassFlow[4]
          temperaturFactor = HeatExchanger.limit(temperaturFactor)
          status.powerBlock.temperature.outlet =
            heatExchanger.temperature.htf.outlet.max
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
      } // Line 281
      status.powerBlock.temperature.outlet = Temperature(celsius: -0.61133e-10
        * status.heatExchanger.heatToTES ** 4 + 0.00000019425
        * status.heatExchanger.heatToTES ** 3 - 0.00032293
        * status.heatExchanger.heatToTES ** 2 + 0.65556
        * status.heatExchanger.heatToTES + 0.58315)
    }
  }

  static func heaterFunction(_ status: inout Plant.PerformanceData,
                             _ supplyGasTurbine: Double,
                             _ heatdiff: inout Double,
                             _ fuel: Double,
                             _ demand: Double) {
    // Heater designed as primary backup
    // if Design.heater {  // supplementary HTF heater for Shams-1. Commented
    func heaterUpdate(_ status: inout Plant.PerformanceData, _ heatdiff: Double, _ availableFuel: Double) {
      // status.heater.operationMode = .unknown

      status.heater.temperature.inlet = status.powerBlock.temperature.outlet

      Heater.update(&status, demand: heatdiff, fuel: availableFuel,
                    thermal: &self.thermal, fuelFlow: &self.fuelFlow.heater)

      self.electricalParasitics.heater = Heater.parasitics(at: status.heater.load)
    }
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

      heaterUpdate(&status, heatdiff, fuel)

      status.powerBlock.temperature.inlet = htf.mixingTemperature(
        inlet: status.powerBlock, with: status.heater
      )

      status.powerBlock.massFlow += status.heater.massFlow
    } else if case .noOperation = status.gasTurbine.operationMode {
      // GasTurbine does not update at all (Load<Min?)
      Heater.update(&status, demand: 0, fuel: fuel,
                    thermal: &thermal, fuelFlow: &fuelFlow.heater)

      electricalParasitics.heater = Heater.parasitics(at: status.heater.load)

      status.powerBlock.temperature.inlet = htf.mixingTemperature(
        outlet: status.solarField, with: status.heater
      )

      status.powerBlock.massFlow = status.solarField.header.massFlow
      status.powerBlock.massFlow += status.heater.massFlow
    } else { // gasTurbine.OPmode is neither IC nor PC
      // Line 429 STO STO STO STO STO

      if false { // Design.hasStorage {
        if heatdiff < 0,
          status.storage.heatRelease < storage.dischargeToTurbine,
          status.storage.heatRelease > storage.dischargeToHeater {
          // Direct Discharging to SteamTurbine and heatdiff > 0 (Energy Surplus) see above
          if fuel > 0 { // Fuel available, Storage for Pre-Heating
            Storage.update(&status, mode: .preheat, thermal: &self.thermal)
            // Storage.update(mode: .ph, heatdiff, powerBlock.massFlow, hourFraction, thermal.storage)
            status.heater.temperature.inlet = status.storage.temperature.outlet

            status.heater.operationMode = .unknown

            heatdiff = self.thermal.production + self.thermal.storage - self.thermal.demand

            Heater.update(&status, demand: heatdiff, fuel: fuel,
                          thermal: &self.thermal, fuelFlow: &self.fuelFlow.heater)

            self.electricalParasitics.heater = Heater.parasitics(at: status.heater.load)

            status.heater.massFlow = status.storage.massFlow

            status.powerBlock.temperature.inlet = htf.mixingTemperature(
              outlet: status.solarField, with: status.heater
            )

            status.powerBlock.massFlow = status.solarField.header.massFlow
            status.powerBlock.massFlow += status.heater.massFlow
          } else { // NO Fuel Available -> Discharge directly with reduced TB load!
            Storage.update(&status, mode: .discharge, thermal: &self.thermal)

            status.powerBlock.temperature.inlet = htf.mixingTemperature(
              outlet: status.solarField, with: status.storage
            )

            status.powerBlock.massFlow = status.storage.massFlow
            status.powerBlock.massFlow += status.solarField.header.massFlow
          } // STORAGE: dischargeToHeater < Qrel < dischargeToTurbine;  Fuel/NoFuel
        } else if heatdiff < 0, status.storage.heatRelease < storage.dischargeToHeater,
          status.heater.operationMode != .freezeProtection {
          // = Storage is empty!! && Heater.operationMode != .freezeProtection // <= added instead of "<"
          heatdiff = self.thermal.production + self.thermal.wasteHeatRecovery
            / heatExchanger.efficiency - demand * self.thermal.demand
          // added to avoid heater use is storage is selected and checkbox marked:
          if self.thermal.production == 0 { // use heater only in parallel with solar field and not as stand alone.
            // heatdiff = 0 // commented to use gas not only in paralell to SF (for AH1)
            if Heater.parameter.onlyWithSolarField {
              heatdiff = 0
            }
          }
          heaterUpdate(&status, heatdiff, fuel)

          status.powerBlock.temperature.inlet = htf.mixingTemperature(
            outlet: status.solarField, with: status.heater
          )

          status.powerBlock.massFlow = status.solarField.massFlow
          status.powerBlock.massFlow += status.heater.massFlow
        }
      } else { // No Storage
        heatdiff = self.thermal.production + self.thermal.wasteHeatRecovery
          / heatExchanger.efficiency - self.thermal.demand

        if self.thermal.production == 0 {
          // use heater only in parallel with solar field and not as stand alone.
          if Heater.parameter.onlyWithSolarField {
            heatdiff = 0
          }
        }

        heaterUpdate(&status, heatdiff, fuel)

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

    if !status.heater.massFlow.isNearZero {
      self.thermal.production = status.powerBlock.heatTransfered(with: htf) / 1_000
    }
  }

  static func updateComponentsParameter() {
    // Turbine Gross Power is no longer an input parameter.
    // It is now calculated from Design.layout.powerBlock plus parasitics
    // old TB files can still be used. From now 0 is put in as Gross Power in the TB files
    if steamTurbine.power.max == 0 {
      steamTurbine.power.max = Design.layout.powerBlock
        + powerBlock.fixelectricalParasitics
        + powerBlock.nominalElectricalParasitics
        + powerBlock.electricalParasiticsStep[1]
    }

    if Design.hasGasTurbine {
      heatExchanger.sccHTFthermal = Design.layout.heatExchanger
        / steamTurbine.efficiencySCC / heatExchanger.sccEff

      solarField.massFlow.max = MassFlow(
        heatExchanger.sccHTFthermal * 1_000
          / htf.heatDelta(heatExchanger.scc.htf.outlet.max,
                          heatExchanger.scc.htf.inlet.max)
      )

      WasteHeatRecovery.parameter.ratioHTF = heatExchanger.sccHTFthermal
        / (steamTurbine.power.max - heatExchanger.sccHTFthermal)
    } else {
      if Design.layout.heatExchanger != Design.layout.powerBlock {
        heatExchanger.sccHTFthermal = Design.layout.heatExchanger
          / steamTurbine.efficiencyNominal
          / heatExchanger.efficiency
      } else {
        heatExchanger.sccHTFthermal = steamTurbine.power.max
          / steamTurbine.efficiencyNominal
          / heatExchanger.efficiency
      }
      solarField.massFlow.max = MassFlow(
        heatExchanger.sccHTFthermal * 1_000
          / htf.heatDelta(heatExchanger.temperature.htf.inlet.max,
                          heatExchanger.temperature.htf.outlet.max)
      )
    }

    if Design.hasSolarField {
      solarField.edgeFactor += [solarField.distanceSCA / 2
        * (1 - 1 / Double(solarField.numberOfSCAsInRow))
        / collector.lengthSCA] // Constants
      solarField.edgeFactor += [(1.0 + 1.0
          / Double(solarField.numberOfSCAsInRow))
        / collector.lengthSCA / 2]
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
      return "Collector:\n\(self.collector)\n\n"
        + "Boiler:\n\(self.boiler)\n\n"
        + "Power Block:\n\(self.powerBlock)\n\n"
        + "Solar Field:\n\(self.solarField)\n\n"
        + "Steam Turbine:\n\(self.steamTurbine)\n\n"
        + "Heater:\n\(self.heater)\n\n"
        + "Heat Exchanger:\n\(self.heatExchanger)\n\n"
        + "Gas Turbine:\n\(self.gasTurbine)\n\n"
        + "Storage:\n\(self.storage)\n"
    }
  }
}
