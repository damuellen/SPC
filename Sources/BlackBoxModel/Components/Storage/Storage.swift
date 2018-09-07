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

public struct Storage: Component {
  /// Contains all data needed to simulate the operation of the storage
  public struct PerformanceData: HeatCycle {
    var operationMode: OperationMode
    var temperature: (inlet: Temperature, outlet: Temperature)
    var temperatureTanks: (cold: Temperature, hot: Temperature)
    var massFlow: MassFlow
    var heatRelease: Double
    var mass: (cold: Double, hot: Double)
    var dTHTF_HotSalt, dTHTF_ColdSalt: Temperature
    var massSaltRatio: Double
    var tempertureColdOut: Double
    var minMass: Double
    var heatSalt: (cold: Double, hot: Double)
    var massSalt: Double
    var heat: Double
    var heatStored: Double
    var heatLossStorage: Double
    var heatProductionLoad: Double
    var QoutLoad: Double
    var Lmax: Ratio

    public enum OperationMode: String, CustomStringConvertible {
      case noOperation, discharge, freezeProtection, preheat, charging, fossilCharge

      public var description: String {
        return rawValue
      }

      var isFreezeProtection: Bool {
        return self ~= .freezeProtection
      }
    }
  }

  static let initialState = PerformanceData(
    operationMode: .noOperation,
    temperature: (Simulation.initialValues.temperatureOfHTFinPipes,
                  Simulation.initialValues.temperatureOfHTFinPipes),
    temperatureTanks: (566.0, 666.0),
    massFlow: 0.0, heatRelease: 0,
    mass: (0, 0),
    massSaltRatio: 0,
    tempertureColdOut: 0,
    minMass: 0,
    massSalt: 0,
    heatLossStorage: 0,
    heatProductionLoad: 0
  )

  public static var parameter: Parameter = ParameterDefaults.st

  public static func minmass(status: Storage.PerformanceData) -> Double {
    switch Storage.parameter.definedBy {
    case .hours:
      let minmass = Design.layout.storage * parameter.dischargeToTurbine
        * HeatExchanger.parameter.sccHTFheat * 1_000 * 3_600
        / (status.heatSalt.hot - status.heatSalt.cold)

      HeatExchanger.parameter.temperature.h2o.inlet.max = Temperature(
        parameter.startLoad.hot * Design.layout.storage
          * HeatExchanger.parameter.sccHTFheat * 1_000 * 3_600
          / (status.heatSalt.hot - status.heatSalt.cold) + minmass
      ) // Factor 1.1
      HeatExchanger.parameter.temperature.h2o.inlet.min = Temperature(
        parameter.startLoad.cold * Design.layout.storage
          * HeatExchanger.parameter.sccHTFheat * 1_000 * 3_600
          / (status.heatSalt.hot - status.heatSalt.cold) + minmass
      )
      return minmass

    case .cap:
      let minmass = Design.layout.storage_cap
        * parameter.dischargeToTurbine * 1_000 * 3_600
        / (status.heatSalt.hot - status.heatSalt.cold)

      HeatExchanger.parameter.temperature.h2o.inlet.max = Temperature(
        parameter.startLoad.hot * Design.layout.storage_cap * 1_000 * 3_600
          / (status.heatSalt.hot - status.heatSalt.cold) + minmass
      ) // Factor 1.1
      HeatExchanger.parameter.temperature.h2o.inlet.min = Temperature(
        parameter.startLoad.cold * Design.layout.storage_cap * 1_000 * 3_600
          / (status.heatSalt.hot - status.heatSalt.cold) + minmass
      )
      return minmass

    case .ton:
      let minmass = Design.layout.storage_ton * parameter.dischargeToTurbine
      HeatExchanger.parameter.temperature.h2o.inlet.max = Temperature(
        (parameter.startLoad.hot * Design.layout.storage_ton + minmass) * 1_000
      )
      HeatExchanger.parameter.temperature.h2o.inlet.min = Temperature(
        (parameter.startLoad.cold * Design.layout.storage_ton + minmass) * 1_000
      )
      return minmass
    }
  }

  /// Calculates the parasitics of the tes
  private static func parasitics(_ status: inout PerformanceData) -> Double {
    var parasitics = 0.0
    var timeminutessum = 0
    var timeminutesold = 0
    let solarField = SolarField.parameter
    let heatExchanger = HeatExchanger.parameter
    let storage = Storage.parameter

    let time = TimeStep.current
    if storage.auxConsCurve {
      // old model:
      let rohMean = htf.density(status.averageTemperature)
      let rohDP = htf.density(Temperature.average(
        heatExchanger.temperature.htf.inlet.max,
        heatExchanger.temperature.htf.outlet.max)
      )
      let PrL = parameter.pressureLoss * rohDP / rohMean
        * (status.massFlow.share(of: parameter.massFlow).ratio) ** 2

      parasitics = PrL * status.massFlow.rate / rohMean
        / parameter.pumpEfficiency / 10e6

      if case .discharge = status.operationMode {
         // added as user input, by no input stoc.DischrgParFac = 2
        parasitics = parasitics * parameter.DischrgParFac
        timeminutessum = 0
      } else if case .noOperation = status.operationMode {

        if time.minute != timeminutesold { // formula changed
          if time.minute == 0 { // new hour
            timeminutessum += 60 + time.minute - timeminutesold // timeminutessum + 5
          } else {
            timeminutessum += time.minute - timeminutesold
          }
        }

        for (_, power) in zip(parameter.heatTracingTime, parameter.heatTracingPower) {
          // FIXME: if timeminutessum > time * 60 {
          parasitics += power / 1_000
          // }
        }
      } else {
        // parasitics = parasitics // Indien 1.5
        timeminutessum = 0
      }
      timeminutesold = time.minute
    } else { // new model
      // all this shall be done only one time
      // definedBy internal parameters
      /// exponent for nth order decay of aux power consumption
      let expn = 3.0
      /// accounting for different head for certain charge levels (e.g. charge mode 0% level -> 35 % less Aux. Power)
      let level = 0.35
      /// accounting for a reduction in Aux. Power for low charge level and low flow ->20% less
      let level2 = 0.2
      /// minimal aux. power consumption for very low salt flows in charge mode
      let lowCh = 0.12
      /// minimal aux. power consumption for very low salt flows in discharge mode
      let lowDc = 0.25
      /// TES parasitics for design case during discharge
      let designAuxEX = 0.29
      /// TES parasitics for design case during charge
      let designAuxIN = 0.57

      // calculate design salt massflows:
      status.heatSalt.hot = salt.enthalpy(parameter.designTemperature.hot)

      status.heatSalt.cold = salt.enthalpy(parameter.designTemperature.cold)
      // charge:
      let designCharging = (parameter.massFlow.rate * htf.heatDelta(
        parameter.designTemperature.hot + status.dTHTF_HotSalt,
        parameter.designTemperature.cold + status.dTHTF_ColdSalt) / 1_000)
        * parameter.heatExchangerEfficiency

      var designChargingMassSalt = designCharging
        / (status.heatSalt.hot - status.heatSalt.cold) * 1_000 // kg/s
      designChargingMassSalt *= hourFraction * 3_600 // kg in time step (5 minutes)
      // discharge:
      let QoutLoad = parameter.fixedLoadDischarge == 0
        ? Ratio(0.97)
        : Ratio(parameter.fixedLoadDischarge)

      let heatexDes = (((solarField.massFlow.max - parameter.massFlow)
        .adjusted(with: QoutLoad).rate
        / parameter.heatExchangerEfficiency) * htf.heatDelta(
          parameter.designTemperature.hot - status.dTHTF_HotSalt,
          parameter.designTemperature.cold - status.dTHTF_ColdSalt) / 1_000)
        * parameter.heatExchangerEfficiency // design charging power

      var designEXmassSalt = heatexDes / (status.heatSalt.hot - status.heatSalt.cold) // kg/s
      designEXmassSalt *= hourFraction * 3_600 * 1_000 // kg in time step (5 minutes)
      // all this shall be done only one time_____________________________________________________

      if case .discharge = status.operationMode {
        status.massSaltRatio = (status.massSalt / designEXmassSalt)
        // if storage.massSaltRatio > 1, case .charging = previous?.operationMode {
        // storage.massSaltRatio = 1
        // has to be check in detail how to determine salt mass flow if it's the first discharge after charging!!
        // }
        parasitics = ((1 - lowDc) * designAuxEX
          * status.massSaltRatio ** expn + lowDc * designAuxEX)
          * (1 - level * status.heatRelease)
          * ((1 - level2) + level2 * status.massSaltRatio)
        timeminutessum = 0
      } else if case .charging = status.operationMode {
        status.massSaltRatio = (status.massSalt / designChargingMassSalt)
        // has to be check in detail how to determine salt mass flow if it's the first charge after discharging!!
        // if let previousMode = Storage.previous?.operationMode,
        //  case .ex = previousMode {
        //  storage.massSaltRatio = 1
        // }
        parasitics = ((1 - lowCh) * designAuxIN
          * status.massSaltRatio ** expn + lowCh * designAuxIN)
          * ((1 - level) + level * status.heatRelease)
          * ((1 - level2) + level2 * status.massSaltRatio)
        timeminutessum = 0
        // FIXME: storage.OldOpMode = .in
      } else if case .noOperation = status.operationMode {
        parasitics = 0
        let timeminutessum = 0.0
        if time.minute != timeminutesold {
          if time.minute == 0 { // new hour
            // FIXME: timeminutessum = timeminutessum + 60 + time.minutes! - timeminutesold // timeminutessum + 5
          } else {
            // FIXME: timeminutessum = timeminutessum + time.minutes! - timeminutesold
          }
        }
        // new heat tracing defined by user:
        for (time, pow) in zip(parameter.heatTracingTime,
                               parameter.heatTracingPower) {
          if timeminutessum > time * 60 {
            parasitics += pow / 1_000
          }
        }
      }
      timeminutesold = time.minute
    }

    return parasitics
  }

  static func update(_ status: inout Plant.PerformanceData,
                     mode: PerformanceData.OperationMode) {
    status.storage.operationMode = mode

    func outletTemperature(_ status: Storage.PerformanceData) -> Temperature {
      var temp: Double
      if parameter.temperatureDischarge2[1] > 0 {
        temp = status.heatRelease > 0.5
          ? 1 : parameter.temperatureDischarge2[status.heatRelease]
        temp *= parameter.designTemperature.hot.kelvin
          - parameter.temperatureDischarge[1]
      } else {
        temp = -Temperature.absoluteZeroCelsius
        if status.heatRelease < 0 {
          temp += parameter.temperatureDischarge[0]
            - (parameter.designTemperature.hot.kelvin
              - status.temperatureTanks.hot.kelvin)
        } else {
          temp += parameter.temperatureCharge[0]
            - (parameter.designTemperature.hot.kelvin
              - status.temperatureTanks.hot.kelvin)
          // adjust of HTF outlet temp. with status hot tank temp.
        }
      }
      return Temperature(celsius: temp)
    }

    let nightHour = 12.0

    if Plant.thermal.solar > 0 {
      status.solarField.header.massFlow = status.solarField.massFlow
    } else if case .freezeProtection = status.solarField.operationMode {
      status.solarField.header.massFlow = status.solarField.massFlow
    } else {
      status.solarField.header.massFlow = 0.0
    }

    switch status.storage.operationMode { // = storage.OPmode
    case .charging: storageCharging(&status)
    case .fossilCharge: storageFossilCharge(&status)
    case .discharge: storageDischarge(&status, nightHour, outletTemperature)
    case .preheat: storagePreheat(&status, outletTemperature)
    case .freezeProtection: storageFreezeProtection(&status)
    case .noOperation:
      // Temperatures remain constant
      Plant.thermal.storage = 0
      status.storage.massFlow = MassFlow()
      Plant.electricalParasitics.storage = 0
    }

    // Storage Heat Losses: Check calculation
    if parameter.temperatureCharge.coefficients[1] > 0 {
      // it does not get in here usually.
      if parameter.temperatureCharge.coefficients[2] > 0 {
        let StoFit = status.storage.heatRelease <= 0
          ? parameter.heatlossCst[status.storage.heatRelease]
          : parameter.heatlossC0to1[status.storage.heatRelease]

        status.storage.heatLossStorage = StoFit
          * 3_600 * 0.0000001 * Design.layout.storage // [MW]
      } else {
        status.storage.heatLossStorage = parameter.heatlossCst[0] / 1_000
          * (status.storage.heatRelease * (parameter.designTemperature.hot
            - parameter.designTemperature.cold).kelvin
            + parameter.designTemperature.cold.kelvin)
          / parameter.designTemperature.hot.kelvin
      }
    } else {
      status.storage.heatLossStorage = 0
    }
  }

  static func calculate(status: inout Storage.PerformanceData,
                        powerBlock: inout PowerBlock.PerformanceData,
                        steamTurbine: SteamTurbine.PerformanceData) {
    let solarField = SolarField.parameter


    let coldTankHeatLoss = parameter.heatLoss.cold
      * (status.temperatureTanks.cold.kelvin)
      / (parameter.designTemperature.cold.kelvin - 27)

    let hotTankHeatLoss = parameter.heatLoss.hot
      * (status.temperatureTanks.hot.kelvin)
      / (parameter.designTemperature.hot.kelvin - 27)

    status.heatSalt.cold = salt.enthalpy(parameter.designTemperature.cold)
    status.heatSalt.hot = salt.enthalpy(parameter.designTemperature.hot)

    switch parameter.definedBy {
    case .hours:
      // Plant.availability[currentDate.month].storage added here to apply TES availability on capacity and not on charge load
      status.massSalt = Design.layout.storage
        * Plant.availability.value.storage.ratio
        * (1 + parameter.dischargeToTurbine)

      status.massSalt *= HeatExchanger.parameter.sccHTFheat * 3_600 * 1_000
        / (status.heatSalt.hot - status.heatSalt.cold)
    case .cap:
      status.massSalt = Design.layout.storage_cap
        * Plant.availability.value.storage.ratio
        * (1 + parameter.dischargeToTurbine)

      status.massSalt *= 1_000 * 3_600
        / (status.heatSalt.hot - status.heatSalt.cold)
    case .ton:
      status.massSalt = Design.layout.storage_ton
        * Plant.availability.value.storage.ratio

      status.massSalt *= 1_000 * (1 + parameter.dischargeToTurbine)
    }

    //   Saltmass = parameter.heatLossConstants0[3]

    if parameter.temperatureCharge[1] > 0 { // it doesnt get in here usually, therefore not updated yet
      status.heatStored = status.heatStored - status.heatLossStorage
        * hourFraction - Plant.thermal.storage * hourFraction
      status.heatRelease = status.heatStored
        / (Design.layout.storage * HeatExchanger.parameter.sccHTFheat)
    } else {
      switch status.operationMode {
      case .charging:
        // Hot salt is storage.temperature.inlet - dTHTF_HotSalt
        status.heatSalt.hot = salt.enthalpy(
          status.temperature.inlet - status.dTHTF_HotSalt
        )
        status.heatSalt.cold = salt.enthalpy(status.temperatureTanks.cold)

        status.massSalt = -Plant.thermal.storage
          / (status.heatSalt.hot - status.heatSalt.cold)
          * hourFraction * 3_600 * 1_000

        status.mass.cold = status.mass.cold - status.massSalt
        status.minMass = self.minmass(status: status)
        // added to avoid negative or too low mass and therefore no heat losses.
        if status.mass.cold < status.minMass {
          status.massSalt -= status.minMass - status.mass.cold
        }

        if status.massSalt < 10 {
          status.massSalt = 0
          
          status.mass.cold = self.minmass(status: status)

          status.mass.hot = status.massSalt + status.mass.hot

          status.heatRelease = parameter.chargeTo
        } else {
          status.mass.hot = status.massSalt + status.mass.hot

          status.heatRelease = status.mass.hot * (parameter.designTemperature.hot
            - parameter.designTemperature.cold).kelvin
            / (status.massSalt * (parameter.designTemperature.hot
              - parameter.designTemperature.cold).kelvin)
        }
        if status.mass.hot > 0 {
          status.temperatureTanks.hot = Temperature((status.massSalt
            * (status.temperature.inlet - status.dTHTF_HotSalt).kelvin
            + status.mass.hot * status.temperatureTanks.hot.kelvin)
            / (status.massSalt + status.mass.hot))
        } else {
          status.temperatureTanks.hot = status.temperatureTanks.hot
        }

      case .fossilCharge:
        // check if changes have to be done related to salt temperature
        status.heatSalt.hot = salt.enthalpy(parameter.designTemperature.hot)

        status.heatSalt.cold = salt.enthalpy(status.temperatureTanks.cold)

        status.massSalt = -Plant.thermal.storage
          / (status.heatSalt.hot - status.heatSalt.cold)
          * hourFraction * 3_600 * 1_000

        status.mass.cold = status.mass.cold - status.massSalt

        status.mass.hot = status.massSalt + status.mass.hot

        status.heatRelease = status.mass.hot * (parameter.designTemperature.hot
          - parameter.designTemperature.cold).kelvin
          / (status.massSalt * (parameter.designTemperature.hot
            - parameter.designTemperature.cold).kelvin)

        if status.mass.hot > 0 {
          status.temperatureTanks.hot = Temperature((status.massSalt
            * parameter.designTemperature.hot.kelvin
            + status.mass.hot * status.temperatureTanks.hot.kelvin)
            / (status.massSalt + status.mass.hot))
        } else {
          status.temperatureTanks.hot = status.temperatureTanks.hot
        }

      case .discharge:
        status.heatSalt.hot = salt.enthalpy(status.temperatureTanks.hot)

        status.heatSalt.cold = salt.enthalpy(
          status.temperature.inlet + status.dTHTF_ColdSalt
        )
        status.massSalt = Plant.thermal.storage
          / (status.heatSalt.hot - status.heatSalt.cold)
          * hourFraction * 3_600 * 1_000

        status.mass.hot = -status.massSalt + status.mass.hot
        status.minMass = self.minmass(status: status)
        // added to avoid negative or too low mass and therefore no heat losses
        if status.mass.hot < status.minMass {
          status.massSalt -= (status.minMass - status.mass.hot)

          if status.massSalt < 10 {
            status.massSalt = 0
          }
          Plant.thermal.storage = status.massSalt
            * (status.heatSalt.hot - status.heatSalt.cold)
            / hourFraction / 3_600 / 1_000
          status.mass.hot = status.minMass
          status.mass.cold = status.mass.cold + status.massSalt
          status.heatRelease = parameter.dischargeToTurbine
        } else {
          status.mass.cold = status.mass.cold + status.massSalt
          status.heatRelease = status.mass.hot * (parameter.designTemperature.hot
            - parameter.designTemperature.cold).kelvin / (status.massSalt *
              (parameter.designTemperature.hot
                - parameter.designTemperature.cold).kelvin)
        }
        if status.mass.cold > 0 {
          // cold salt is storage.temperature.inlet + dTHTF_ColdSalt
          status.temperatureTanks.cold = Temperature((status.massSalt
            * (status.temperature.inlet + status.dTHTF_ColdSalt).kelvin
            + status.mass.cold * status.temperatureTanks.cold.kelvin)
            / (status.massSalt + status.mass.cold))
        }
      case .preheat:
        status.heatSalt.hot = salt.enthalpy(status.temperatureTanks.hot)
        status.heatSalt.cold = salt.enthalpy(parameter.designTemperature.cold)

        status.massSalt = Plant.thermal.storage
          / (status.heatSalt.hot - status.heatSalt.cold)
          * hourFraction * 3_600 * 1_000

        status.mass.hot -= status.massSalt
        status.mass.cold += status.massSalt

        status.heatRelease = status.mass.hot * (parameter.designTemperature.hot
          - parameter.designTemperature.cold).kelvin
          / (status.massSalt * (parameter.designTemperature.hot
            - parameter.designTemperature.cold).kelvin)

        status.temperatureTanks.cold = Temperature(
          (status.massSalt * parameter.designTemperature.cold.kelvin
            + status.mass.cold * status.temperatureTanks.cold.kelvin)
            / (status.massSalt + status.mass.cold)
        )
      case .freezeProtection:
        let splitfactor = parameter.HTF == .hiXL ? 0.4 : 1

        status.massSalt = solarField.antiFreezeFlow.rate * hourFraction * 3_600

        status.temperatureTanks.cold = Temperature(
          (splitfactor * status.massSalt
            * powerBlock.outletTemperature
            + status.mass.cold * status.temperatureTanks.cold.kelvin)
            / (splitfactor * status.massSalt + status.mass.cold)
        )

        status.tempertureColdOut = splitfactor
          * status.temperatureTanks.cold.kelvin
          + (1 - splitfactor) * powerBlock.outletTemperature
        // powerBlock.temperature.outlet = storage.temperatureTank.cold
      case .noOperation:
        if parameter.stepSizeIteration < -90,
          status.temperatureTanks.cold < parameter.designTemperature.cold,
          powerBlock.temperature.outlet > status.temperatureTanks.cold,
          status.mass.cold > 0
        {
          status.massSalt = powerBlock.massFlow.rate * hourFraction * 3_600

          status.temperatureTanks.cold = Temperature(
            (status.massSalt * powerBlock.outletTemperature
              + status.mass.cold * status.temperatureTanks.cold.kelvin)
              / (status.massSalt + status.mass.cold)
          )
          // status.operationMode = .sc
        }
      }

      // Storage Heat Losses:
      if steamTurbine.isMaintained {
      } else {
        if status.mass.hot > 0 {
          // parameter.dischargeToTurbine * Saltmass {
          // enthalpy before cooling down
          status.heatSalt.hot = salt.enthalpy(status.temperatureTanks.hot)
          // enthalpy after cooling down
          status.heatSalt.hot = status.heatSalt.hot - hotTankHeatLoss
            * Double(period) / status.mass.hot
          // temp after cool down
          status.temperatureTanks.hot = Temperature(celsius:
            (-salt.heatCapacity[0] + (salt.heatCapacity[0] ** 2
              - 4 * (salt.heatCapacity[1] * 0.5)
              * (-350.5536 - status.heatSalt.hot)) ** 0.5)
              / (2 * salt.heatCapacity[1] * 0.5))
        }
        if status.mass.cold > parameter.dischargeToTurbine * status.massSalt {
          // enthalpy before cooling down
          status.heatSalt.cold = salt.enthalpy(status.temperatureTanks.cold)
          // enthalpy after cooling down
          status.heatSalt.cold = status.heatSalt.cold - coldTankHeatLoss
            * Double(period) / status.mass.cold
          // temp after cool down
          status.temperatureTanks.cold = Temperature(celsius:
            (-salt.heatCapacity[0] + (salt.heatCapacity[0] ** 2
              - 4 * (salt.heatCapacity[1] * 0.5)
              * (-350.5536 - status.heatSalt.cold)) ** 0.5)
              / (2 * salt.heatCapacity[1] * 0.5))
        }
      }
    }

    if Plant.thermal.storage < 0 {
      if case .freezeProtection = status.operationMode {
        // FIXME: powerBlock.temperature.outlet // = powerBlock.temperature.outlet
      } else if case .charging = status.operationMode {
        // if storage.operationMode = "IN" added to avoid Tmix during TES discharge (valid for indirect storage), check!
        powerBlock.temperature.outlet = htf.mixingTemperature(
          outlet: powerBlock, with: status
        )
      }
    }
    // FIXME: HeatExchanger.storage.H2OinTmax = storage.mass.hot
    // FIXME: HeatExchanger.storage.H2OinTmin = storage.mass.cold
    // FIXME: HeatExchanger.storage.H2OoutTmax = storage.temperatureTank.hot
    // FIXME: HeatExchanger.storage.H2OoutTmin = storage.temperatureTank.cold
  }

  static var maxLoad = Ratio(0)

  static func update(_ status: inout Plant.PerformanceData, fuel: Double) {
    let solarField = SolarField.parameter
    let heatExchanger = HeatExchanger.parameter
    let steamTurbine = SteamTurbine.parameter

    if case .always = parameter.strategy {
      // if demand is selected, variable is called Alw but calculation is done as demand, error comes from older version // "Dem"
      status.powerBlock.massFlow = MassFlow(Plant.thermal.demand
        / (htf.heatDelta(heatExchanger.temperature.htf.inlet.max,
                         heatExchanger.temperature.htf.outlet.max) / 1_000)
      )
      if status.powerBlock.massFlow.isNearZero == false { // to avoid negative massflows
        status.storage.heat = 0
        status.powerBlock.massFlow = status.solarField.header.massFlow
      }
    } else {
      status.storage.heat = Plant.thermal.production - Plant.thermal.demand // [MW]
      if parameter.heatExchangerRestrictedMin {
        // added to avoid input to storage lower than minimal HX// s capacity
        Plant.thermal.toStorageMin = parameter.heatExchangerMinCapacity
          * heatExchanger.sccHTFheat
          * (1 - parameter.massFlow.rate / solarField.massFlow.max.rate)
          / (parameter.massFlow.rate / solarField.massFlow.max.rate)

        if case 0..<Plant.thermal.toStorageMin = status.storage.heat {
          Plant.thermal.demand -= (Plant.thermal.toStorageMin - status.storage.heat)

          status.powerBlock.massFlow = MassFlow(Plant.thermal.demand
            / (htf.heatDelta(heatExchanger.temperature.htf.inlet.max,
                             heatExchanger.temperature.htf.outlet.max) / 1_000)
          )
          status.storage.heat = Plant.thermal.toStorageMin
        }
      }
    }
    if case .demand = parameter.strategy {
      // if Always is selected, variable is called "Dem" but calculation is done as "Always", error comes from older version // "Alw" {
      status.powerBlock.massFlow = MassFlow(heatExchanger.sccHTFheat
        / (htf.heatDelta(heatExchanger.temperature.htf.inlet.max,
                         heatExchanger.temperature.htf.outlet.max) / 1_000)
      )

      if status.powerBlock.massFlow < 0.0 { // to avoid negative massflows
        status.storage.heat = 0
        status.powerBlock.massFlow = status.solarField.header.massFlow
      } else {
        status.storage.heat = Plant.thermal.production - heatExchanger.sccHTFheat
        // changed back as thermal.production - heatExchanger.sccHTFheat// thermal.demand
        if parameter.heatExchangerRestrictedMin {
          // added to avoid input to storage lower than minimal HXs capacity
          Plant.thermal.toStorageMin = heatExchanger.sccHTFheat
            * (1 - parameter.massFlow.rate / solarField.massFlow.max.rate)
            / (parameter.massFlow.rate / solarField.massFlow.max.rate)

          if status.storage.heat > 0 && status.storage.heat < Plant.thermal.toStorageMin {
            status.powerBlock.massFlow = MassFlow((heatExchanger.sccHTFheat
              - (Plant.thermal.toStorageMin - status.storage.heat))
              / (htf.heatDelta(heatExchanger.temperature.htf.inlet.max,
                               heatExchanger.temperature.htf.outlet.max) / 1_000)
            )
            status.storage.heat = Plant.thermal.toStorageMin
          }
        }
      }
    }
    // parameter.strategy = "Ful" // Booster or Shifter
    if case .shifter = parameter.strategy {
      // new calculation of shifter, old kept and commented below this:
      let time = TimeStep.current
      if time.month < parameter.startexcep
        || time.month > parameter.endexcep
      {
        status.storage.heatProductionLoad = parameter.heatProductionLoadWinter
        if dniDay > parameter.badDNIwinter * 1_000 {
          // sunny day, TES can be fully charged also by running TB at full load
          status.storage.heatProductionLoad = 1
        }
      } else {
        status.storage.heatProductionLoad = parameter.heatProductionLoadSummer
        if dniDay > parameter.badDNIsummer * 1_000 {
          // sunny day, TES can be fully charged also by running TB at full load
          status.storage.heatProductionLoad = 1
        }
      }

      if Plant.thermal.production > 0 { // Qsol > 0
        if Plant.thermal.production < Plant.thermal.demand,
          status.storage.heatRelease < parameter.chargeTo,
          time.hour < 17
        {
          // Qsol not enough for POB demand load (e.g. at the beginning of the day)
          status.powerBlock.massFlow = MassFlow(min(
            status.storage.heatProductionLoad * Plant.thermal.demand,
            Plant.thermal.production) / (htf.heatDelta(
              heatExchanger.temperature.htf.inlet.max,
              heatExchanger.temperature.htf.outlet.max) / 1_000)
          )
          status.storage.heat = Plant.thermal.production - min(
            status.storage.heatProductionLoad * Plant.thermal.demand,
            Plant.thermal.production
          )
          // TES gets the rest available
          if parameter.heatExchangerRestrictedMax {
            status.storage.heat = min(status.storage.heat,
                                      parameter.heatExchangerCapacity)
          } else {
            let value = steamTurbine.power.max
              / steamTurbine.efficiencyNominal
              / heatExchanger.efficiency
            if status.storage.heat > value {
              status.storage.heat = value
            }
          }
        } else if Plant.thermal.production < Plant.thermal.demand,
          status.storage.heatRelease >= parameter.chargeTo
        {
          // Qsol not enough for POB demand load (e.g. at the end of the day) and TES is full
          status.powerBlock.massFlow = MassFlow(
            Plant.thermal.demand / (htf.heatDelta(
              heatExchanger.temperature.htf.inlet.max,
              heatExchanger.temperature.htf.outlet.max) / 1_000)
          )
          // send all to POB and if needed discharge TES

          status.storage.heat = Plant.thermal.production - Plant.thermal.demand
          // TES provides the rest available
          // check what if TES is full and POB could get more than 50% of design!!
          if parameter.heatExchangerRestrictedMax {
            status.storage.heat = max(status.storage.heat,
                                      -parameter.heatExchangerCapacity)
          } else { // signs below changed
            let value = steamTurbine.power.max
              / steamTurbine.efficiencyNominal
              / heatExchanger.efficiency
            if status.storage.heat > -value {
              status.storage.heat = -value
            }
          }
        } else if Plant.thermal.production > Plant.thermal.demand,
          status.storage.heatRelease < parameter.chargeTo,
          status.solarField.header.massFlow >= status.powerBlock.massFlow
        {
          // more Qsol than needed by POB and TES is not full
          status.powerBlock.massFlow = MassFlow(
            (status.storage.heatProductionLoad * Plant.thermal.demand)
              / (htf.heatDelta(heatExchanger.temperature.htf.inlet.max,
                               heatExchanger.temperature.htf.outlet.max) / 1_000)
          )
          // from avail heat cover first 50% of POB demand
          status.storage.heat = Plant.thermal.production -
            (status.storage.heatProductionLoad * Plant.thermal.demand)
          // TES gets the rest available
          if parameter.heatExchangerRestrictedMax,
            status.storage.heat > parameter.heatExchangerCapacity {
            // rest heat to TES is too high, use more heat to POB
            status.powerBlock.massFlow = MassFlow(
              (Plant.thermal.production - parameter.heatExchangerCapacity)
                / (htf.heatDelta(heatExchanger.temperature.htf.inlet.max,
                                 heatExchanger.temperature.htf.outlet.max) / 1_000)
            )
            // from avail heat cover first 50% of POB demand

            status.storage.heat = parameter.heatExchangerCapacity
            // TES gets max heat input
          }
        }
      } else {
        if case .hours = parameter.definedBy {
          // condition added. It usually doesn't get in here. therefore, not correctly programmed yet
          if Plant.thermal.production > Plant.thermal.demand,
            status.storage.heatRelease > 1 * steamTurbine.power.max
              / steamTurbine.efficiencyNominal / Design.layout.storage {
            Plant.thermal.demand = steamTurbine.power.max
              * Plant.availability.value.powerBlock.ratio
              / SteamTurbine.efficiency(status, maxLoad: &maxLoad)
            var thermalDiff = Plant.thermal.production - Plant.thermal.demand // [MW]
            // power to charge TES rest after operation POB at full load commented
            // heatdiff = max(thermal.production, thermal.demand)
            // maximal power to TES desing POB thermal input (just to check how it works)
            let heat = steamTurbine.power.max
              / steamTurbine.efficiencyNominal
              / heatExchanger.efficiency

            if thermalDiff > heat {
              thermalDiff = heat // commented in case of degradated powerblock
              // if heatdiff > steamTurbine.power.max / steamTurbine.efficiencyNominalOriginal / heatExchanger.efficiency {
              // heatdiff = steamTurbine.power.max / steamTurbine.efficiencyNominalOriginal / heatExchanger.efficiency
              // in case of degradated powerblock
              status.powerBlock.massFlow = MassFlow(
                (Plant.thermal.production - thermalDiff)
                  / (htf.heatDelta(
                    heatExchanger.temperature.htf.inlet.max,
                    heatExchanger.temperature.htf.outlet.max) / 1_000)
              )
            }
          }
        }
      }
    }

    if status.storage.heat > 0 { // Energy surplus
      if status.storage.heatRelease < parameter.chargeTo,
        status.solarField.header.massFlow >= status.powerBlock.massFlow {
        Storage.update(&status, mode: .charging)
      } else { // heat cannot be stored
        Storage.update(&status, mode: .noOperation)
      }
      status.powerBlock.temperature.inlet = status.solarField.header.temperature.outlet
    } else { // Energy deficit
      var peakTariff: Bool
      let time = TimeStep.current
      // check when to discharge TES
      if case .shifter = parameter.strategy { // only for Shifter
        if time.month < parameter.startexcep || time.month > parameter.endexcep { // Oct to March
          peakTariff = time.hour >= parameter.dischrgWinter
        } else { // April to Sept
          peakTariff = time.hour >= parameter.dischrgSummer
        }
      } else { // not shifter
        peakTariff = true // dont care about time to discharge
      }

      if peakTariff, status.storage.operationMode.isFreezeProtection == false,
        status.storage.heatRelease > parameter.dischargeToTurbine,
        status.storage.heat < -1 * parameter.heatdiff * Plant.thermal.demand
      { // added dicharge only after peak hours
        // previous discharge condition commented:
        // if storage.heatrel > parameter.dischargeToTurbine && storage.operationMode != .freezeProtection && heatdiff < -1 * parameter.heatdiff * thermal.demand {
        // Discharge directly!! // 04.07.0 -0.25&& heatdiff < -0.25 * thermal.dem
        if status.powerBlock.massFlow < status.solarField.header.massFlow {
          // there are cases, during cloudy days when OpMode is "EX" although massflow in SOF is higher that in PB.
        }
        Storage.update(&status, mode: .discharge)

        if [.operating, .freezeProtection].contains(status.solarField.operationMode) {
          status.powerBlock.temperature.inlet = htf.mixingTemperature(
            outlet: status.solarField, with: status.storage
          )
          status.powerBlock.massFlow = status.storage.massFlow
          status.powerBlock.massFlow += status.solarField.header.massFlow
          status.powerBlock.massFlow.adjust(with: parameter.heatExchangerEfficiency)
        } else if status.storage.massFlow.isNearZero == false {
          status.powerBlock.temperature.inlet = status.storage.temperature.outlet
          status.powerBlock.massFlow = status.storage.massFlow
          status.powerBlock.massFlow.adjust(with: parameter.heatExchangerEfficiency)
        } else {
          status.powerBlock.massFlow = .init() // set to zero
        }
      } else { // heat can only be provided with heater on
        if (parameter.FC == 0 && status.collector.parabolicElevation < 0.011
          && status.storage.heatRelease < parameter.chargeTo
          && !(status.powerBlock.inletTemperature > 665)
          && status.steamTurbine.isMaintained
          && Storage.isFossilChargingAllowed(at: time)
          && Fuelmode.isPredefined == false) || (Fuelmode.isPredefined && fuel > 0)
        {
          status.heater.operationMode = .freezeProtection

          if Fuelmode.isPredefined == false {
            let fuel = Double.greatestFiniteMagnitude

            Heater.update(&status, thermalPower: &Plant.thermal.heater,
                          fuel: &Plant.fuelConsumption.heater,
                          demand: 1, fuelAvailable: fuel)

            Plant.electricalParasitics.heater = Heater
              .parasitics(estimateFrom: status.heater.load)

            status.powerBlock.massFlow = status.heater.massFlow

            Storage.update(&status, mode: .freezeProtection)

            status.powerBlock.temperature.inlet = status.storage.temperature.outlet
            // check why to circulate HTF in SF
            Plant.electricalParasitics.solarField = solarField.antiFreezeParastics
          } else if case .freezeProtection = status.solarField.operationMode,
            status.storage.heatRelease > -0.35 && parameter.FP == 0 {
            Storage.update(&status, mode: .freezeProtection)
          } else {
            Storage.update(&status, mode: .noOperation)
          }
        }
      }

      Plant.thermal.storage = status.storage.massFlow.rate
        * htf.heatDelta(status.storage.temperature.outlet,
                        status.storage.temperature.inlet) / 1_000

      // Check if the required heat is contained in TES, if not recalculate thermal.storage

      if case .discharge = status.storage.operationMode {
        status.storage.heatSalt.hot = salt.enthalpy(status.storage.temperatureTanks.hot)

        status.storage.heatSalt.cold = salt.enthalpy(
          status.storage.temperature.inlet + status.storage.dTHTF_ColdSalt
        )

        status.storage.massSalt = Plant.thermal.storage / (status.storage.heatSalt.hot
          - status.storage.heatSalt.cold) * hourFraction * 3_600 * 1_000

        if (status.storage.mass.hot - status.storage.massSalt) < status.storage.minMass {
          // added to avoid negative or too low salt mass
          status.storage.massSalt -= -status.storage.minMass + status.storage.mass.hot
        }

        if status.storage.massSalt < 10 {
          status.storage.massSalt = 0
          // recalculate thermal power given by TES:
          Plant.thermal.storage = status.storage.massSalt
            * (status.storage.heatSalt.hot - status.storage.heatSalt.cold)
            / hourFraction / 3_600 / 1_000
        }
      }
      if case .charging = status.storage.operationMode {
        status.storage.heatSalt.hot = salt.enthalpy(
          status.storage.temperature.inlet - status.storage.dTHTF_HotSalt
        )

        status.storage.heatSalt.cold = salt.enthalpy(status.storage.temperatureTanks.cold)

        status.storage.massSalt = -Plant.thermal.storage
          / (status.storage.heatSalt.hot - status.storage.heatSalt.cold)
          * hourFraction * 3_600 * 1_000

        if (status.storage.mass.cold - status.storage.massSalt) < status.storage.minMass {
          status.storage.massSalt = status.storage.massSalt
            - (-status.storage.minMass + status.storage.mass.cold)

          if status.storage.massSalt < 10 { status.storage.massSalt = 0
            // recalculate thermal power given by TES:
            Plant.thermal.storage = -status.storage.massSalt
              * (status.storage.heatSalt.hot - status.storage.heatSalt.cold)
              / hourFraction / 3_600 / 1_000
          }
        }
      }

      if status.storage.heat > 0 { // Energy surplus
        if status.storage.heatRelease < parameter.chargeTo,
          status.solarField.header.massFlow >= status.powerBlock.massFlow
        { // 1.1
          Plant.thermal.production = Plant.thermal.solar
          Plant.thermal.production += Plant.thermal.storage
        } else { // heat cannot be stored
          Plant.thermal.production = Plant.thermal.solar - status.storage.heat
        }
      } else {
        Plant.thermal.production = Plant.thermal.solar
        Plant.thermal.production += Plant.thermal.storage
      }
    }
  }

  private static func storageCharging(_ status: inout Plant.PerformanceData) {
    let heatExchanger = HeatExchanger.parameter
    let storage = Storage.parameter
    status.storage.temperature.inlet = status.solarField.temperature.outlet
    // the powerBlock.massFlow is only an ideal value, for maximal dT, isnt it wrong?
    status.storage.massFlow = status.solarField.massFlow - status.powerBlock.massFlow
    status.storage.massFlow.adjust(with: storage.heatExchangerEfficiency)
    // * Plant.availability[calendar].storage taken out of the formula and included in TES capacity calculation
    var StoFit = 0.0
    if storage.temperatureCharge.coefficients[1] > 0 { // usually = 0
      StoFit = status.storage.heatRelease < 0.5
        ? 1 : storage.temperatureCharge2[status.storage.heatRelease]
      StoFit *= storage.designTemperature.cold.kelvin
        - storage.temperatureCharge.coefficients[2]
    } else {
      StoFit = -Temperature.absoluteZeroCelsius
      StoFit += storage.temperatureCharge.coefficients[0]
        - (storage.designTemperature.cold
          - status.storage.temperatureTanks.cold).kelvin
    }
    status.storage.temperature.outlet = Temperature(StoFit)

    Plant.thermal.storage = status.storage.massFlow.rate
      * htf.heatDelta(status.storage.temperature.outlet,
                      status.storage.temperature.inlet) / 1_000

    if storage.heatExchangerRestrictedMax,
      abs(Plant.thermal.storage) > storage.heatExchangerCapacity
    {

      Plant.thermal.storage *= storage.heatExchangerCapacity

      status.storage.massFlow = MassFlow(Plant.thermal.storage /
        htf.heatDelta(status.storage.temperature.outlet,
                      status.storage.temperature.inlet) * 1_000)
      // FIXME: powerBlock.massFlow = powerBlock.massFlow
      // added to avoid increase in PB massFlow
      if case .demand = storage.strategy { // (always)
        // too much power from sun, dump
        Plant.thermal.dump += Plant.thermal.production
          - heatExchanger.sccHTFheat + Plant.thermal.storage
      } else {
        Plant.thermal.dump += Plant.thermal.production
          - Plant.thermal.demand + Plant.thermal.storage
      }
      status.solarField.header.massFlow = status.powerBlock.massFlow
      status.solarField.header.massFlow += status.storage.massFlow
      // reduce HTF massflow in SF

      Plant.thermal.solar = status.solarField.heatTransfered(with: htf)
      Plant.thermal.production = Plant.thermal.solar
    }

    Plant.electricalParasitics.storage = Storage.parasitics(&status.storage)
  }

  private static func storageFossilCharge(_ status: inout Plant.PerformanceData) {
    let storage = Storage.parameter
    // heat can be stored

    status.storage.temperature.inlet = Heater.parameter.nominalTemperatureOut
    status.storage.massFlow = status.powerBlock.massFlow

    var StoFit: Double
    if storage.temperatureCharge.coefficients[1] > 0 { // usually = 0
      StoFit = status.storage.heatRelease < 0.5
        ? 1 : storage.temperatureCharge2[status.storage.heatRelease]
      StoFit *= storage.designTemperature.cold.kelvin
        - storage.temperatureCharge.coefficients[2]
    } else {
      StoFit = -Temperature.absoluteZeroCelsius
      StoFit += storage.temperatureCharge.coefficients[0]
        - (storage.designTemperature.cold
          - status.storage.temperatureTanks.cold).kelvin
    }
    status.storage.temperature.outlet = Temperature(StoFit)

    Plant.thermal.storage = -status.storage.heatTransfered(with: htf) // [MW]
    // limit the size of the salt-oil heat exchanger
    if storage.heatExchangerRestrictedMax,
      abs(Plant.thermal.storage) > storage.heatExchangerCapacity
    {
      Plant.thermal.storage *= storage.heatExchangerCapacity

      status.storage.massFlow = MassFlow(Plant.thermal.storage / htf.heatDelta(
        status.storage.temperature.outlet, status.storage.temperature.inlet
        ) * 1_000)

      status.powerBlock.massFlow = status.storage.massFlow
    }

    Plant.electricalParasitics.storage = Storage.parasitics(&status.storage)
  }

  private static func storageDischarge(
    _ status: inout Plant.PerformanceData, _ nightHour: Double,
    _ outletTemperature: (Storage.PerformanceData) -> Temperature) {
    let steamTurbine = SteamTurbine.parameter
    let storage = Storage.parameter
    var time = TimeStep.current
    // calculate discharge rate only once per day, directly after sunset

    if status.collector.parabolicElevation > 0
      && status.collector.parabolicElevation < 3 && storage.isVariable
    {
      switch storage.definedBy {
      case .hours:
        status.storage.heatStored = status.storage.heatRelease * Design.layout.storage
          * steamTurbine.power.max / steamTurbine.efficiencyNominal
      case .cap:
        status.storage.heatStored = status.storage.heatRelease * Design.layout.storage_cap
      case .ton:
        status.storage.heatSalt.hot = salt.enthalpy(storage.designTemperature.hot)

        status.storage.heatSalt.cold = salt.enthalpy(storage.designTemperature.cold)

        status.storage.heatStored = status.storage.heatRelease * Design.layout.storage_ton
          * (status.storage.heatSalt.hot - status.storage.heatSalt.cold)
          * (storage.designTemperature.hot - storage.designTemperature.cold).kelvin / 3_600
      }

      // QoutLoad controls the load of the TES during discharge. Before was fixed to 0.97
      status.storage.QoutLoad = status.storage.heatStored / nightHour
        / (steamTurbine.power.max / steamTurbine.efficiencyNominal)

      if status.storage.QoutLoad < storage.MinDis {
        status.storage.QoutLoad = storage.MinDis
      } else if status.storage.QoutLoad > 1 {
        status.storage.QoutLoad = 1
      }
    }
    // if no previous calculation has been done and TES must be discharged
    if status.storage.QoutLoad == 0 && storage.isVariable {
      switch storage.definedBy {
      case .hours:
        status.storage.heatStored = status.storage.heatRelease * Design.layout.storage
          * steamTurbine.power.max / steamTurbine.efficiencyNominal
      case .cap:
        status.storage.heatStored = status.storage.heatRelease * Design.layout.storage_cap
      case .ton:
        status.storage.heatSalt.hot = salt.enthalpy(storage.designTemperature.hot)
        status.storage.heatSalt.cold = salt.enthalpy(storage.designTemperature.cold)
        status.storage.heatStored = status.storage.heatRelease * Design.layout.storage_ton
          * (status.storage.heatSalt.hot - status.storage.heatSalt.cold)
          * (storage.designTemperature.hot - storage.designTemperature.cold).kelvin / 3_600
      }

      // QoutLoad controls the load of the TES during discharge.
      status.storage.QoutLoad = status.storage.heatStored / nightHour
        / (steamTurbine.power.max / steamTurbine.efficiencyNominal)

      if status.storage.QoutLoad < storage.MinDis {
        status.storage.QoutLoad = storage.MinDis
      } else if status.storage.QoutLoad > 1 {
        status.storage.QoutLoad = 1
      }
    }
    // fixed discharge
    if storage.isVariable == false {
      // avoid user error by no input
      status.storage.QoutLoad = storage.fixedLoadDischarge == 0
        ? 0.97 : storage.fixedLoadDischarge
    }

    switch status.solarField.operationMode {
    case .freezeProtection:
      status.storage.massFlow = MassFlow(status.storage.QoutLoad
        * status.powerBlock.massFlow.rate / storage.heatExchangerEfficiency)

    case .operating where status.solarField.massFlow.rate > 0:
      // Mass flow is correctd by parameter.Hx this factor is new
      status.storage.massFlow = MassFlow(status.powerBlock.massFlow.rate
        / storage.heatExchangerEfficiency - status.solarField.massFlow.rate)
    // * 0.97 deleted after separating combined from storage only operation
    default:
      // if demand < 1 { // only for OU1!?
      //  storage.massFlow = powerBlock.massFlow * 1.3
      //    / parameter.heatExchangerEfficiency
      // for OU1 adjust to demand file and not TES design parameter.s. CHECK! 1.3 to get right results
      // } else {
      // added to control TES discharge during night
      status.storage.massFlow = MassFlow(status.storage.QoutLoad
        * status.powerBlock.massFlow.rate / storage.heatExchangerEfficiency)
      // }
    }

    // used for parasitics
    status.storage.temperature.inlet = status.powerBlock.temperature.outlet
    status.storage.temperature.outlet = outletTemperature(status.storage)

    while true {
      defer { status.storage.massFlow.adjust(with: 0.97) } // reduce 5%
      Plant.thermal.storage = status.storage.massFlow.rate
        * htf.heatDelta(status.storage.temperature.outlet,
                        status.storage.temperature.inlet) / 1_000

      if storage.heatExchangerRestrictedMax,
        abs(Plant.thermal.storage) > storage.heatExchangerCapacity
      {
        Plant.thermal.storage *= storage.heatExchangerCapacity
        status.storage.massFlow = MassFlow(Plant.thermal.storage /
          htf.temperatureDelta(status.storage.outletTemperature,
                               status.storage.temperature.inlet).kelvin * 1_000)
        if case .freezeProtection = status.solarField.operationMode {
          // reduction of HTF Mass flow during storage discharging due to results of Heat Balance
          status.powerBlock.massFlow = MassFlow(status.storage.massFlow.rate
            * parameter.heatExchangerEfficiency / 0.97) // - solarField.massFlow
        } else {
          // Mass flow is correctd by new factor
          status.powerBlock.massFlow = MassFlow(
            (status.storage.massFlow + status.solarField.massFlow).rate
              * storage.heatExchangerEfficiency / 0.97
          )
        }
      }

      status.steamTurbine.load = Ratio((Plant.thermal.solar + Plant.thermal.storage)
        / (steamTurbine.power.max
          / SteamTurbine.efficiency(status, maxLoad: &status.storage.Lmax)))

      let mixTemp = htf.mixingTemperature(outlet: status.solarField,
                                          with: status.storage)

      let minTemp = Temperature(celsius: 310.0) // TurbineTempLoad(SteamTurbine.storage.load)

      if mixTemp.kelvin > (minTemp - Simulation.parameter.tempTolerance).kelvin * 2 {
        Plant.thermal.storage = status.storage.massFlow.rate
          * htf.heatDelta(status.storage.temperature.outlet,
                          status.storage.temperature.inlet) / 1_000
        //Plant.electricalParasitics.storage = Storage.parasitics(&status.storage)
        break
      } else if status.storage.massFlow.rate <= 0.05 * status.powerBlock.massFlow.rate {
        Plant.thermal.storage = 0
        status.storage.operationMode = .noOperation
        //Plant.electricalParasitics.storage = 0
        status.storage.massFlow = 0.0
        break
      }
    }
  }

  private static func storageFreezeProtection(_ status: inout Plant.PerformanceData) {
    let solarField = SolarField.parameter
    let storage = Storage.parameter
    let splitfactor: Ratio = 0.4
    status.storage.massFlow = solarField.antiFreezeFlow.adjusted(with: splitfactor)

    status.solarField.header.massFlow = solarField.antiFreezeFlow
    // used for parasitics
    status.storage.temperature.inlet = status.powerBlock.temperature.outlet
    var StoFit = 0.0
    if storage.temperatureCharge[1] > 0 {
      if storage.temperatureDischarge.indices.contains(2) {
        status.storage.temperature.outlet = status.storage.temperature.inlet
      } else {
        StoFit = status.storage.heatRelease > 0.5
          ? 1 : storage.temperatureCharge2[status.storage.heatRelease]
        status.storage.temperature.outlet = Temperature(
          StoFit * storage.designTemperature.hot.kelvin
        )
      }
      status.storage.temperature.outlet = Temperature(
        splitfactor.ratio * status.storage.outletTemperature
          + (1 - splitfactor.ratio) * status.storage.inletTemperature
      )
    } else {
      status.storage.temperature.outlet =
        status.storage.temperatureTanks.cold
    }
    Plant.electricalParasitics.storage = Storage.parasitics(&status.storage)
  }

  private static func storagePreheat(
    _ status: inout Plant.PerformanceData,
    _ outletTemperature: (Storage.PerformanceData) -> Temperature) {
    // the rest is heated by SF
    let storage = Storage.parameter

    status.storage.massFlow = status.powerBlock.massFlow - status.solarField.massFlow
    status.storage.temperature.inlet = status.powerBlock.temperature.outlet
    status.storage.temperature.outlet = outletTemperature(status.storage)

    Plant.thermal.storage = status.storage.massFlow.rate
      * htf.heatDelta(status.storage.temperature.outlet,
                      status.storage.temperature.inlet) / 1_000
    // limit the size of the salt-oil heat exchanger
    if storage.heatExchangerRestrictedMax,
      abs(Plant.thermal.storage) > storage.heatExchangerCapacity
    {
      Plant.thermal.storage = Plant.thermal.storage * storage.heatExchangerCapacity

      status.storage.massFlow = MassFlow(Plant.thermal.storage
        / htf.heatDelta(status.storage.temperature.outlet,
                        status.storage.temperature.inlet) * 1_000)
      // go StorageOutletTemp
      Plant.thermal.storage = -status.storage.heatTransfered(with: htf)
    }

    Plant.electricalParasitics.storage = Storage.parasitics(&status.storage)
  }

  static func isFossilChargingAllowed(at time: TimeStep) -> Bool {
    return (time.month < parameter.FCstopM || (time.month == parameter.FCstopM
      && time.day < parameter.FCstopD) || ((time.month == parameter.FCstartM
        && time.day > parameter.FCstartD) || time.month > parameter.FCstartM)
      && (time.month < parameter.FCstopM2 || (time.month == parameter.FCstopM2
        && time.day < parameter.FCstopD2) || (time.month > parameter.FCstartM2
          || (time.month == parameter.FCstartM2 && time.day > parameter.FCstartD2))))
  }
}

extension HeatTransferFluid {
  fileprivate func enthalpy(_ temperature: Temperature) -> Double {
    return heatCapacity[0] * temperature.kelvin
      + 0.5 * heatCapacity[1] * temperature.kelvin ** 2 - 350.5536
  }
}

extension Storage.PerformanceData {
  init(operationMode: OperationMode,
       temperature: (inlet: Temperature, outlet: Temperature),
       temperatureTanks: (cold: Temperature, hot: Temperature),
       massFlow: MassFlow, heatRelease: Double,
       mass: (cold: Double, hot: Double), massSaltRatio: Double,
       tempertureColdOut: Double, minMass: Double, massSalt: Double,
       heatLossStorage: Double, heatProductionLoad: Double) {
    self.operationMode = operationMode
    self.temperature = temperature
    self.temperatureTanks = temperatureTanks
    self.massFlow = massFlow
    self.heatRelease = heatRelease
    self.QoutLoad = 0
    self.heat = 0
    self.Lmax = Ratio(1)

    self.mass = mass
    self.massSaltRatio = massSaltRatio
    self.tempertureColdOut = tempertureColdOut
    self.minMass = minMass
    self.massSalt = massSalt
    self.heatLossStorage = heatLossStorage
    self.heatProductionLoad = heatProductionLoad
    let storage = Storage.parameter
    let solarField = SolarField.parameter
    /// Initial state of storage
    if Design.hasStorage {
      heatStored = Design.layout.storage * storage.heatStoredrel

      SolarField.parameter.massFlow.max = MassFlow(
        100 / storage.massFlow.rate * solarField.massFlow.max.rate
      )

      Storage.parameter.massFlow = MassFlow(
        (1 - storage.massFlow.rate / 100) * solarField.massFlow.max.rate
      )
    }
    heatStored = 0
    // solarField.massFlow.min = MassFlow(
    //   solarField.massFlow.min.rate / 100 * solarField.massFlow.max.rate
    // )

    // solarField.antiFreezeFlow = MassFlow(
    //   solarField.antiFreezeFlow.rate / 100 * solarField.massFlow.max.rate
    // )

    if solarField.pumpParastics.isEmpty {
      if solarField.massFlow.max.rate < 900 {
        // calculation of solar field parasitics with empirical correlation derived from solar field model
        SolarField.parameter.pumpParasticsFullLoad = (
          0.000000047327 * Design.layout.solarField ** 4
            - 0.000020044 * Design.layout.solarField ** 3
            + 0.0032862 * Design.layout.solarField ** 2
            - 0.24086 * Design.layout.solarField + 8.2152)
          * (0.7103 * (solarField.massFlow.max.rate / 597) ** 3
            - 0.8236 * (solarField.massFlow.max.rate / 597) ** 2
            + 1.464 * (solarField.massFlow.max.rate / 597) - 0.3508)
      } else {
        SolarField.parameter.pumpParasticsFullLoad = (
          0.0000055 * solarField.massFlow.max.rate ** 2
            - 0.0074 * solarField.massFlow.max.rate + 4.4)
          * (-0.000001656 * Design.layout.solarField ** 3 + 0.0007981
            * Design.layout.solarField ** 2 - 0.1322
            * Design.layout.solarField + 8.428)
      }
      SolarField.parameter.HTFmass = (93300 + 11328 * Design.layout.solarField)
        * (0.63 * (solarField.massFlow.max.rate / 597) + 0.38)
    }
    // check if it should be left so or changed to the real achieved temp. ( < 393 °C)
    // heatExchanger.temperature.htf.inlet.max = heatExchanger.HTFinTmax
    // heatExchanger.temperature.htf.inlet.min = heatExchanger.HTFinTmin
    // heatExchanger.temperature.htf.outlet.max = heatExchanger.HTFoutTmax
    // HeatExchanger.storage.HTFoutTmin = heatExchanger.HTFoutTmin never used
    heatSalt = (0, 0)
    dTHTF_HotSalt = .init(0)
    dTHTF_ColdSalt = .init(0)

    if storage.stepSizeIteration == -99.99 {
      heatSalt.hot = salt.enthalpy(storage.designTemperature.hot)
      heatSalt.cold = salt.enthalpy(storage.designTemperature.cold)

      HeatExchanger.parameter.temperature.h2o.inlet.max = Temperature(
        storage.startTemperature.hot.kelvin
      )
      HeatExchanger.parameter.temperature.h2o.inlet.min = Temperature(
        storage.startTemperature.cold.kelvin
      )

      if storage.temperatureCharge[1] == 0 {
        /* self.dTHTF_HotSalt = Temperature(celsius: storage.temperatureCharge[0])
         self.dTHTF_ColdSalt = Temperature(celsius: storage.temperatureCharge[0])
         storage.temperatureCharge.coefficients[0] = storage.designTemperature.hot.kelvin
         - storage.temperatureCharge.coefficients[0] // meaning is HTFTout(EX) = HotTankDes - dT
         storage.temperatureDischarge.coefficients[0] = storage.temperatureCharge.coefficients[0]
         storage.temperatureCharge.coefficients[0] = storage.designTemperature.cold.kelvin
         - storage.temperatureCharge.coefficients[0] // meaning is HTFTout(IN) = ColdTankDes + dT
         storage.temperatureCharge.coefficients[0] = storage.temperatureCharge[0]*/
      }
    }
  }
}
