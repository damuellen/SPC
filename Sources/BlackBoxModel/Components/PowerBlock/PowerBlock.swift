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

public enum PowerBlock: Component {
  /// Contains all data needed to simulate the operation of the power block
  public struct PerformanceData: Equatable, HeatCycle,
    CustomStringConvertible {
    var operationMode: OperationMode
    var load: Ratio
    var massFlow: MassFlow
    var temperature: (inlet: Temperature, outlet: Temperature)
    var totalMassFlow: MassFlow
    var heatIn: Double

    public enum OperationMode {
      case scheduledMaintenance
    }

    public static func == (lhs: PerformanceData, rhs: PerformanceData) -> Bool {
      return lhs.operationMode == rhs.operationMode && lhs.load == rhs.load
    }

    public var description: String {
      return "\(operationMode), "
        + "Load: \(load), "
        + String(format: "Mfl: %.1fkg/s, ", massFlow.rate)
        + String(format: "In: %.1f°C ", temperature.inlet.celsius)
        + String(format: "Out: %.1f°C", temperature.outlet.celsius)
    }
  }

  static let initialState = PerformanceData(
    operationMode: .scheduledMaintenance,
    load: 0.0,
    massFlow: 0.0,
    temperature: (inlet: Simulation.initialValues.temperatureOfHTFinPipes,
                  outlet: Simulation.initialValues.temperatureOfHTFinPipes),
    totalMassFlow: 0.0,
    heatIn: 0
  )

  public static var parameter: Parameter = ParameterDefaults.pb

  /// Calculates the parasitics of the gas turbine which only depends on the current load
  private static func parasitics(
    at load: Ratio, heat: Double,
    steamTurbine: SteamTurbine.PerformanceData
  ) -> Double { // Calc. parasitic power in PB: -

    var electricalParasitics = 0.0

    if steamTurbine.load.ratio >= 0.01 {
      electricalParasitics = parameter.fixelectricalParasitics
      electricalParasitics += parameter.nominalElectricalParasitics
        * parameter.electricalParasitics[load]
    } else if heat > 0, load.isZero {
      // parasitics during start-up sequence
      // Strange effect of this function over gross output!!
      // "strange effect" is due to interation "Abs(electricalParasiticsAssumed
      // - electricEnergy.parasitics) < Simulation.parameter.electricalTolerance"
      electricalParasitics = parameter.startUpelectricalParasitics
    }

    // if Heater.parameter.operationMode {
    // if variable exist, then project Shams-1 is calculated. commented,
    // same for shams as for any project. check!
    switch steamTurbine.load.ratio { // Step function for Cooling Towers -
    case 0.5 ... 1:
      electricalParasitics += parameter.electricalParasiticsStep[1]
    case 0 ... 0.5:
      electricalParasitics += parameter.electricalParasiticsStep[0]
    case 0:
      if steamTurbine.isMaintained {
        electricalParasitics = 0 // add sched. maint. parasitics as a parameter
      } else if heat == 0 { // night TEST
        electricalParasitics = parameter.fixElectricalParasitics0
      }
    default: break
    }

    // parasitics for ACC:
    if steamTurbine.load.ratio >= 0.01 {
      // only during operation
      var electricalParasiticsACC = parameter.electricalParasiticsACC[load]

      if parameter.electricalParasiticsACCTamb.coefficients.isEmpty == false {
        var adjustmentACC = parameter.electricalParasiticsACCTamb
          .apply(Plant.ambientTemperature.celsius)
        // ambient temp is larger than design, ACC max. consumption fixed to nominal
        if adjustmentACC > 1 {
          adjustmentACC = 1
        }
        electricalParasiticsACC *= adjustmentACC
      }
    }

    electricalParasitics += parameter.nominalElectricalParasiticsACC
    return electricalParasitics // + 0.005 * steamTurbine.load * parameter.power.max

    // return parameter.fixelectricalParasitics
    // electricalParasitics += parameter.nominalElectricalParasitics
    // * (parameter.electricalParasitics[0] + parameter.electricalParasitics[1]
    // * steamTurbine.load + parameter.electricalParasitics[2] * steamTurbine.load ** 2)
  }
  /// Calculates the Electric gross, Parasitic
  static func update(_ status: inout Plant.PerformanceData,
                     heat: inout Double,
                     electricalParasitics _: inout Double,
                     Qsto: Double, meteo: MeteoData) -> Double {

    let steamTurbine = SteamTurbine.parameter
    var turbineStandStillTime = 0.0
    if steamTurbine.hotStartUpTime == 0 {
      // parameter.hotStartUpTime = 75 // default value
    }
    var turbineStartUpTime = 0.0
    var turbineStartUpEnergy = 0.0
    var qneu = 0.0
    var maxLoad = Ratio(0)
    // new startup is only necessary, if turbine is out of operation for more than 20 minutes
    if heat <= 0 || Simulation.isStart {
      // no heat to turbine !!!
      // || (steamTurbine.Op = 0 && SimBegin) added for BL1 black box model
      if case .noOperation = status.steamTurbine.operationMode, Simulation.isStart {
        turbineStandStillTime = steamTurbine.hotStartUpTime + 5
      }
      Simulation.isStart = false
      // added and variable declared global, still to be checked!!

      // if currentDate.minutes! != timeold {
      turbineStandStillTime = turbineStandStillTime + hourFraction * 60 // 5 minutes steps usually
      // }

      // timeold = minutes
      status.steamTurbine.load = 0.0
      return 0
    } else {
      // Energy is coming to the Turbine
      if (turbineStartUpTime >= steamTurbine.startUpTime
        && turbineStartUpEnergy >= steamTurbine.startUpEnergy)
        || turbineStandStillTime < steamTurbine.hotStartUpTime
        || Simulation.isStart
      {
        Simulation.isStart = false // added for  black box model
        // modification due to turbine degradation
        status.steamTurbine.load = Ratio(
          heat / (steamTurbine.power.max / steamTurbine.efficiencyNominal)
        )

        status.steamTurbine.load = Ratio(
          heat * SteamTurbine.efficiency(status, maxLoad: &maxLoad)
            / steamTurbine.power.max
        )
      } else {
        // Start Up sequence: Energy is lost / Dumped
        status.steamTurbine.load = 0.0
        let startUpeff = cos(status.collector.theta) * status.collector.efficiency
        qneu = (Double(meteo.dni) * startUpeff - status.solarField.heatLosses)
          * Design.layout.solarField * Double(SolarField.parameter.numberOfSCAsInRow)
          * 2 * Collector.parameter.areaSCAnet / 1_000_000

        if Qsto > 0 {
          qneu = qneu + Qsto
        }
        if status.heater.massFlow.rate > 0 {
          qneu = heat
        }
        // if time.minute != timeold_b {
        // added to sum startup time only when time changes,
        // effect: reduction of approx. 3% net output! turbineStartUpTime
        // must be reduced to about the half for projects older than this version
        turbineStartUpTime = turbineStartUpTime + hourFraction * 60
        turbineStartUpEnergy = turbineStartUpEnergy + qneu * hourFraction
        // added to sum startup heat only when time changes, effect: reduction
        // of approx. 1% net output! turbineStartUpEnergy must be reduced
        // to about the half for projects older than this version to
        // obtain similar results
        // }
        // timeold_b = minutes
        // turbineStartUpTime = turbineStartUpTime + hourFraction * 60
        // commented and replaced as shown above
        // turbineStartUpEnergy = turbineStartUpEnergy + qneu * hourFraction
        // qneu stat heat,commented and placed above after comparing
        // time.minutes! to avoid summing up inside an iteration
      }
      return heat
    }
  }

  static func heatExchangerBypass(_ status: inout Plant.PerformanceData) {
    let heatExchanger = HeatExchanger.parameter

    // added to simulate a bypass on the PB-HX if the expected outlet temp is so low that the salt to TES could freeze
    status.powerBlock.totalMassFlow = status.powerBlock.massFlow
    let maxTemperature = heatExchanger.temperature.htf.inlet.max.kelvin

    repeat {

      let massFlowLoad = status.powerBlock.massFlow.share(
        of: SolarField.parameter.massFlow.max
      )

      if heatExchanger.Tout_exp_Tin_Mfl,
        let ToutTinMassFlow = heatExchanger.ToutTinMassFlow
      {
        var temperaturFactor = (ToutTinMassFlow[0]
          * (status.powerBlock.inletTemperature
            / maxTemperature)
          * 666 + ToutTinMassFlow[1])
          * massFlowLoad.ratio ** (ToutTinMassFlow[2]
            * (status.powerBlock.inletTemperature
              / maxTemperature)
            * 666 + ToutTinMassFlow[3]) + ToutTinMassFlow[4]

        temperaturFactor = HeatExchanger.limit(temperaturFactor)

        status.powerBlock.temperature.outlet =
          heatExchanger.temperature.htf.outlet.max
            .adjusted(with: temperaturFactor)

      } else if heatExchanger.useAndsolFunction {
        var temperaturFactor = HeatExchanger.temperatureFactor(
          temperature: status.powerBlock.temperature.inlet, load: massFlowLoad,
          maxTemperature: heatExchanger.temperature.htf.inlet.max)

        temperaturFactor = HeatExchanger.limit(temperaturFactor)

        status.powerBlock.temperature.outlet =
          heatExchanger.temperature.htf.outlet.max
            .adjusted(with: temperaturFactor)

      } else if heatExchanger.Tout_f_Tin == false,
        heatExchanger.Tout_f_Mfl,
        let ToutMassFlow = heatExchanger.ToutMassFlow
      {
        // if temperature.outlet is dependant on massflow, recalculate temperature.outlet
        var temperaturFactor = ToutMassFlow[massFlowLoad]

        if temperaturFactor > 1 { temperaturFactor = 1 }

        status.powerBlock.temperature.outlet =
          heatExchanger.temperature.htf.outlet.max
            .adjusted(with: temperaturFactor)

      } else if heatExchanger.Tout_f_Mfl,
        heatExchanger.Tout_f_Tin,
        let ToutMassFlow = heatExchanger.ToutMassFlow,
        let ToutTin = heatExchanger.ToutTin
      {
        var temperaturFactor = ToutMassFlow[massFlowLoad]

        temperaturFactor *= ToutTin[status.powerBlock.temperature.inlet]

        status.powerBlock.temperature.outlet =
          heatExchanger.temperature.htf.outlet.max
            .adjusted(with: temperaturFactor)
      }

      status.heatExchanger.heatOut = htf.enthalpyFrom(status.powerBlock.temperature.outlet)

      let bypassMassFlow = status.powerBlock.totalMassFlow - status.powerBlock.massFlow
      let Bypass_h = htf.enthalpyFrom(status.powerBlock.temperature.inlet)

      status.heatExchanger.heatToTES = (bypassMassFlow.rate * Bypass_h
        + status.powerBlock.massFlow.rate * status.heatExchanger.heatOut)
        / (bypassMassFlow + status.powerBlock.massFlow).rate

    } while status.heatExchanger.heatToTES > h_261

    status.powerBlock.temperature.outlet =
      htf.temperatureFrom(status.heatExchanger.heatToTES)
  }
}
