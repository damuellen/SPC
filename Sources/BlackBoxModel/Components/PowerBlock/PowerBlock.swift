//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Meteo
import Utilities

/// This struct contains the state as well as the functions for mapping the power block
public struct PowerBlock: Parameterizable, HeatTransfer {

  var name: String = PowerBlock.parameter.name

  var massFlow: MassFlow = .zero

  var temperature: (inlet: Temperature, outlet: Temperature)

  var designMassFlow = MassFlow(
    HeatExchanger.parameter.heatFlowHTF * 1_000 / HeatExchanger.capacity
  )

  public enum OperationMode {
    case scheduledMaintenance
  }
  /// Returns the fixed initial state.
  static let initialState = PowerBlock(
    temperature: Simulation.startTemperature
  )
  /// Returns the static parameters
  public static var parameter: Parameter = ParameterDefaults.pb

  static func requiredMassFlow() -> MassFlow {
    MassFlow(GridDemand.current.ratio
      * HeatExchanger.parameter.heatFlowHTF * 1_000 / HeatExchanger.capacity)
  }

  mutating func temperatureOutlet(
    heatExchanger: inout HeatExchanger, mode: Storage.OperationMode
  ) {
    if massFlow > .zero,
      temperature.inlet
        >= HeatExchanger.parameter.temperature.htf.inlet.min
    {

      temperature.outlet = HeatExchanger
        .temperatureOutlet(self, heatExchanger)

      if case .discharge = mode,
        temperature.outlet.isLower(than: 534.0)
      {
        let result = heatExchangerBypass()
        heatExchanger.heatOut = result.heatOut
        heatExchanger.heatToTES = result.heatToTES
      }
    }
  }

  /// Calculate parasitic power of the power block
  static func parasitics(
    heat: Double,
    steamTurbine: SteamTurbine,
    temperature: Temperature)
    -> Double
  {
    var electricalParasitics = 0.0
    let load = steamTurbine.load
    if load >= 0.01 {

      electricalParasitics = parameter.fixElectricalParasitics
      electricalParasitics += parameter.nominalElectricalParasitics
        * parameter.electricalParasitics(load)
    } else if heat > 0, load.isZero {
      // parasitics during start-up sequence
      // Strange effect of this function over gross output!!
      // "strange effect" is due to interation "Abs(electricalParasiticsAssumed
      // - electricPerformance.parasitics) < Simulation.parameter.electricalTolerance"
      electricalParasitics = parameter.startUpElectricalParasitics
    }

    // if Heater.parameter.operationMode {
    // if variable exist, then project Shams-1 is calculated. commented,
    // same for shams as for any project. check!
    switch load.quotient { // Step function for Cooling Towers -
    case 0:
      if case .scheduledMaintenance = steamTurbine.operationMode {
        electricalParasitics = 0 // add sched. maint. parasitics as a parameter
      } else { // night TEST
        electricalParasitics = parameter.fixElectricalParasitics0
      }
    case 0 ... 0.5:
      electricalParasitics += parameter.electricalParasiticsStep[0]
    case 0.5 ... 1:
      electricalParasitics += parameter.electricalParasiticsStep[1]
    default: break
    }

    // parasitics for ACC:
    if load > .zero {
      // only during operation
      var electricalParasiticsACC = parameter.electricalParasiticsACC(load)

      if parameter.electricalParasiticsACCTamb.coefficients.isEmpty == false {
        var adjustmentACC = parameter.electricalParasiticsACCTamb(temperature.celsius)
        // ambient temp is larger than design, ACC max. consumption fixed to nominal
        if adjustmentACC > 1 {
          adjustmentACC = 1
        }
        electricalParasiticsACC *= adjustmentACC
      }
    }

    electricalParasitics += parameter.nominalElectricalParasiticsACC
    return electricalParasitics // + 0.005 * steamTurbine.load * parameter.power.max

    // return parameter.fixElectricalParasitics
    // electricalParasitics += parameter.nominalElectricalParasitics
    // * (parameter.electricalParasitics[0] + parameter.electricalParasitics[1]
    // * steamTurbine.load + parameter.electricalParasitics[2] * steamTurbine.load ** 2)
  }

  mutating func heatExchangerBypass() -> (heatOut: Double, heatToTES: Double)
  {
    let htf = SolarField.parameter.HTF

    var heatOut = 0.0

    var heatToTES = 0.0

    // added to simulate a bypass on the PB-HX if the expected
    // outlet temperature is so low that the salt to TES could freeze
    let totalMassFlow = massFlow

    repeat {
      //#warning("Check this")
      temperature.outlet = HeatExchanger.temperatureOutlet(self, self)

      heatOut = htf.enthalpy(temperature.outlet)

      let bypassMassFlow = totalMassFlow - massFlow
      let Bypass_h = htf.enthalpy(temperature.inlet)

      heatToTES = (bypassMassFlow.rate * Bypass_h + massFlow.rate * heatOut)
        / (bypassMassFlow + massFlow).rate

    } while heatToTES > h_261

    setTemperature(outlet: htf.temperature(heatToTES))
    return (heatOut, heatToTES)
  }

  mutating func temperatureLoss(wrt solarField: SolarField, _ storage: Storage)
  {
    if Design.hasGasTurbine {
      temperatureFromInlet()
    } else {
      let tlpb = 0.0
      // 0.38 * (TpowerBlock.status - meteo.temperature) / 100 * (30 / Design.layout.powerBlock) ** 0.5 // 0.38

      let mf = max(0.1, (solarField.massFlow + storage.massFlow).rate)
      let tin = (solarField.massFlow.rate * solarField.outlet
        + storage.massFlow.rate * storage.outlet) / mf
      if tin > 0 {
        temperature.inlet.kelvin = tin
      }

      let sec = Double(period)
      let HTFmass = SolarField.parameter.HTFmass
      let tout = (massFlow.rate * sec * inlet + outlet
        * (HTFmass - mf * sec)) / HTFmass - tlpb
      if tout > 0 {
        temperature.outlet.kelvin = tout
      }
    }
  }
}

let h_261: Double = 484.17458693
// 1.51129 * 261.0 + 1.2941 / 1_000 * 261.0 ** 2.0
// + 1.23697 / 10.0 ** 7.0 * 261.0 ** 3.0 - 0.62677 // kJ/kg

