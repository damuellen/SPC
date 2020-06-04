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

public struct PowerBlock: Component, HeatCycle {
  /// Contains all data needed to simulate the operation of the power block    
  var cycle: HeatTransfer = .init(name: PowerBlock.parameter.name)
  
  public enum OperationMode {
    case scheduledMaintenance
  }
  
  static let initialState = PowerBlock()
  
  public static var parameter: Parameter = ParameterDefaults.pb
  
  /// Calculate parasitic power in PB
  static func parasitics(
    heat: Double,
    steamTurbine: SteamTurbine,
    temperature: Temperature)
    -> Double
  {
    var electricalParasitics = 0.0
    let load = Ratio(1) //steamTurbine.load
    if load.ratio >= 0.01 {

      electricalParasitics = parameter.fixElectricalParasitics
      electricalParasitics += parameter.nominalElectricalParasitics
        * parameter.electricalParasitics(load)
    } else if heat > 0, load.isZero {
      // parasitics during start-up sequence
      // Strange effect of this function over gross output!!
      // "strange effect" is due to interation "Abs(electricalParasiticsAssumed
      // - electricEnergy.parasitics) < Simulation.parameter.electricalTolerance"
      electricalParasitics = parameter.startUpElectricalParasitics
    }
    
    // if Heater.parameter.operationMode {
    // if variable exist, then project Shams-1 is calculated. commented,
    // same for shams as for any project. check!
    switch load.ratio { // Step function for Cooling Towers -
    case 0:
      if case .scheduledMaintenance = steamTurbine.operationMode {
        electricalParasitics = 0 // add sched. maint. parasitics as a parameter
      } else if heat == 0 { // night TEST
        electricalParasitics = parameter.fixElectricalParasitics0
      }
    case 0 ... 0.5:
      electricalParasitics += parameter.electricalParasiticsStep[0]
    case 0.5 ... 1:
      electricalParasitics += parameter.electricalParasiticsStep[1]
    default: break
    }
    
    // parasitics for ACC:
    if load.ratio > 0 {
      // only during operation
      var electricalParasiticsACC = parameter.electricalParasiticsACC(load)
      
      if parameter.electricalParasiticsACCTamb.coefficients.isEmpty == false {
        var adjustmentACC = parameter.electricalParasiticsACCTamb
          .evaluated(temperature.celsius)
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
    var totalMassFlow = massFlow
  
    repeat {
      #warning("Check this")
      temperature.outlet = HeatExchanger.outletTemperature(self, self)

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
      outletTemperatureInlet()
    } else {
      let tlpb = 0.0
      // 0.38 * (TpowerBlock.status - meteo.temperature) / 100 * (30 / Design.layout.powerBlock) ** 0.5 // 0.38
      
      let mf = max(0.1, (solarField.massFlow + massFlow).rate)
      let inlet = (solarField.massFlow.rate * solarField.outletTemperature
        + massFlow.rate * storage.outletTemperature) / mf
      if inlet > 0 {
        inletTemperature(kelvin: inlet)
      }
      #warning("The implementation here differs from PCT")
      // FIXME: Was ist Tstatus ?????????
      let sec = Double(period)
      let outlet = (massFlow.rate * sec
        * inletTemperature + outletTemperature
        * (SolarField.parameter.HTFmass - massFlow.rate * sec))
        / SolarField.parameter.HTFmass - tlpb
      
      outletTemperature(kelvin: outlet)
      if inlet > 0 {
        outletTemperature(kelvin: inlet)
      }
    }
  }
}

let h_261: Double = 484.17458693
// 1.51129 * 261.0 + 1.2941 / 1_000 * 261.0 ** 2.0
// + 1.23697 / 10.0 ** 7.0 * 261.0 ** 3.0 - 0.62677 // kJ/kg

