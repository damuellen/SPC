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

public enum HeatExchanger: Component {
  /// Contains all data needed to simulate the operation of the heat exchanger
  public struct PerformanceData: HeatCycle {
    
    var operationMode: OperationMode
    
    var temperature: (inlet: Temperature, outlet: Temperature)
    
    var massFlow: MassFlow
    
    var heatOut, heatToTES: Double
    
    public enum OperationMode: Equatable {
      case noOperation(hours: Double), SI, startUp,
      scheduledMaintenance, coldStartUp, warmStartUp

      public static func == (lhs: OperationMode, rhs: OperationMode) -> Bool {
        switch (lhs, rhs) {
        case let (.noOperation(lhs), noOperation(rhs)): return lhs == rhs
        default: return lhs.rawValue == rhs.rawValue
        }
      }
    }
  }

  /// working conditions of the heat exchanger at start
  static let initialState = PerformanceData(
    operationMode: .SI,
    temperature: (inlet: Temperature(celsius: 30.0),
                  outlet: Temperature(celsius: 30.0)),
    massFlow: 0.0,
    heatOut: 0.0,
    heatToTES: 0.0
  )

  public static var parameter: Parameter = ParameterDefaults.hx

  static func clamp(_ temperatureFactor: Double) -> Double {
    var temperatureFactor = temperatureFactor
    if temperatureFactor > 1.1 { temperatureFactor = 1.1 }
    if temperatureFactor < 0 { temperatureFactor = 0 }
    return temperatureFactor
  }

  /// power function based on MAN-Turbo and OHL data with pinch point tool
  private static func temperatureFactor(temperature: Temperature,
                                load: Ratio,
                                maxTemperature: Temperature) -> Double {
    return clamp(((0.0007592419869
      * (temperature.kelvin / maxTemperature.kelvin)
      * 666 + 0.4943825893223) * load.ratio ** (0.0001400823882
        * (temperature.kelvin / maxTemperature.kelvin)
        * 666 - 0.0110227028559)) - 0.000151639) // function is based on 393°C
  }
  
  /// Update HeatExchanger.temperature.outlet
  static func perform(_ hx: inout PerformanceData,
                      steamTurbine: SteamTurbine.PerformanceData,
                      storage: Storage.PerformanceData) -> Double {
    let solarField = SolarField.parameter
    let htf = solarField.HTF
    if parameter.name.hasPrefix("Heat Exchanger HTF-H2O - BK") {
      hx.outletTemperature(kelvin:
        parameter.temperature.htf.outlet.max.kelvin
          - (120 - 169 * steamTurbine.load.ratio
            + 49 * steamTurbine.load.ratio ** 2)
      )
      if hx.temperature.outlet < parameter.temperature.htf.outlet.min {
        hx.setTemperature(outlet: parameter.temperature.htf.outlet.min)
      }
    } else {
      if parameter.useAndsolFunction {
        let massFlowLoad = hx.massFlow.share(of: solarField.massFlow.max)

        let factor = temperatureFactor(
          temperature: hx.temperature.inlet, load: massFlowLoad,
          maxTemperature: parameter.temperature.htf.inlet.max)

        hx.setTemperature(outlet:
           parameter.temperature.htf.outlet.max.adjusted(with: factor)
        )
      } else {
        let p = parameter
        let temp = parameter.temperature
        switch (p.ToutMassFlow, p.ToutTin, p.ToutTinMassFlow) {
        case let (ToutMassFlow?, ToutTin?, .none):
          let massFlowLoad = hx.massFlow.share(of: solarField.massFlow.max)

          var factor = ToutMassFlow[massFlowLoad]
          factor *= ToutTin[hx.temperature.inlet]

          hx.setTemperature(outlet:
            parameter.temperature.htf.outlet.max.adjusted(with: clamp(factor))
          )
        case let (ToutMassFlow?, .none, .none):
          hx.outletTemperature(kelvin:
            temp.htf.outlet.min.kelvin + temp.designDelta.outlet.kelvin
            * (hx.temperature.inlet - temp.htf.inlet.min).kelvin
            / temp.designDelta.inlet.kelvin)

          let massFlowLoad = hx.massFlow.share(of: solarField.massFlow.max)

          let factor = ToutMassFlow[massFlowLoad]

          hx.outletTemperature(kelvin: clamp(factor) * hx.outletTemperature)
        case let (_, _, ToutTinMassFlow?):
          let massFlowLoad = hx.massFlow.share(of: solarField.massFlow.max)

          // power function based on MAN-Turbo and OHL data with pinch point tool
          let factor = ((ToutTinMassFlow[0]
              * (hx.inletTemperature / temp.htf.inlet.max.kelvin)
              * 666 + ToutTinMassFlow[1])
            * massFlowLoad.ratio ** (ToutTinMassFlow[2]
              * (hx.inletTemperature / temp.htf.inlet.max.kelvin)
              * 666 + ToutTinMassFlow[3])) + ToutTinMassFlow[4]

          hx.setTemperature(outlet:
            temp.htf.outlet.max.adjusted(with: clamp(factor))
          )
        case let (_, ToutTin?, _):
          let factor = ToutTin[hx.temperature.inlet]

          hx.setTemperature(outlet:
            temp.htf.outlet.max.adjusted(with: clamp(factor))
          )
        default:
// CHECK: the value of HTFoutTmax should be dependent on storage charging but only on PB HX
          hx.outletTemperature(kelvin:
            temp.htf.outlet.min.kelvin + temp.designDelta.outlet.kelvin
            * (hx.inletTemperature - temp.htf.inlet.min.kelvin)
            / temp.designDelta.inlet.kelvin)
        }
      }
    }

    // Update HeatExchanger.temperature.outlet and massFlow

    if case .discharge = storage.operationMode,
      hx.outletTemperature < (261.toKelvin) {
      // added to simulate a bypass on the PB-HX if the expected
      // outlet temperture is so low that the salt to TES could freeze
      let totalMassFlow = hx.massFlow

      for i in 1...  where hx.heatToTES > h_261 {
        // reduce massflow to PB in 5% every step until enthalpy is
        hx.setMassFlow(rate: totalMassFlow.rate * (1 - (Double(i) / 20)))
        let massFlowLoad = hx.massFlow.share(of: solarField.massFlow.max)

        if parameter.useAndsolFunction {
          // check how big massflow load can be (5% more than design?)
          let factor = temperatureFactor(
            temperature: hx.temperature.inlet, load: massFlowLoad,
            maxTemperature: parameter.temperature.htf.inlet.max)

          hx.setTemperature(outlet:
            parameter.temperature.htf.outlet.max.adjusted(with: factor)
          )
        } else if let ToutMassFlow = parameter.ToutMassFlow,
          let ToutTin = parameter.ToutTin {

          var factor = ToutMassFlow[massFlowLoad]
          factor *= ToutTin[hx.temperature.inlet]

          hx.setTemperature(outlet:
            parameter.temperature.htf.outlet.max.adjusted(with: clamp(factor))
          )
        } else if let ToutMassFlow = parameter.ToutMassFlow {
          // if Tout is dependant on massflow, recalculate Tout
          let factor = clamp(ToutMassFlow[massFlowLoad])

          hx.temperature.outlet.adjust(withFactor: factor)
        } else if let ToutTinMassFlow = parameter.ToutTinMassFlow {
          // power function based on MAN-Turbo and OHL data with pinch point tool
          let factor = ((ToutTinMassFlow[0]
              * hx.inletTemperature + ToutTinMassFlow[1])
            * massFlowLoad.ratio ** (ToutTinMassFlow[2]
              * hx.inletTemperature + ToutTinMassFlow[3]))
            + ToutTinMassFlow[4]

          hx.setTemperature(outlet:
            parameter.temperature.htf.outlet.max.adjusted(with: clamp(factor))
          )
        }

        hx.heatOut = htf.enthalpy(hx.temperature.outlet)
        let bypassMassFlow = totalMassFlow - hx.massFlow
        let bypass_h = htf.enthalpy(hx.temperature.inlet)
        hx.heatToTES = (bypassMassFlow.rate * bypass_h
          + hx.massFlow.rate * hx.heatOut)
          / (bypassMassFlow + hx.massFlow).rate
      }

      hx.setTemperature(outlet: htf.temperature(hx.heatToTES))
    }
    let heat = hx.massFlow.rate * SolarField.parameter.HTF.deltaHeat(
       hx.temperature.outlet, hx.temperature.inlet) / 1_000
    return -heat * parameter.efficiency
  }
  /// Calculates the outlet temperature of the power block
  static var outletTemperature = outletTemperatureFunction()
  
  private static func outletTemperatureFunction()
    -> (PowerBlock.PerformanceData, HeatCycle) -> Temperature
  {
    let solarField = SolarField.parameter

    if parameter.useAndsolFunction {
      return {
        (pb: PowerBlock.PerformanceData, _: HeatCycle) -> Temperature in
        let massFlowLoad = pb.massFlow.share(of: solarField.massFlow.max)
        let factor = temperatureFactor(
          temperature: pb.temperature.inlet, load: massFlowLoad,
          maxTemperature: parameter.temperature.htf.inlet.max)
        
        return parameter.temperature.htf.outlet.max
          .adjusted(with: factor)
      }
    } else if parameter.Tout_exp_Tin_Mfl,
      parameter.Tout_f_Tin == false,
      let ToutMassFlow = parameter.ToutMassFlow
    {
      return {
        (pb: PowerBlock.PerformanceData, _: HeatCycle) -> Temperature in
        let massFlowLoad = pb.massFlow.share(of: solarField.massFlow.max)
        
        let factor = Ratio(ToutMassFlow[massFlowLoad.ratio])
        
        let temp = parameter.temperature

        return Temperature(
          (temp.htf.outlet.min.kelvin + temp.designDelta.outlet.kelvin
            * (pb.temperature.inlet - temp.htf.inlet.min).kelvin
            / temp.designDelta.inlet.kelvin) * factor.ratio
        )
      }
    } else if parameter.Tout_f_Mfl && parameter.Tout_f_Tin,
      let ToutMassFlow = parameter.ToutMassFlow,
      let ToutTin = parameter.ToutTin
    {
      return {
        (pb: PowerBlock.PerformanceData, hx: HeatCycle) -> Temperature in
        let massFlowLoad = pb.massFlow.share(of: solarField.massFlow.max)
        var factor = ToutMassFlow[massFlowLoad.ratio]
        factor *= ToutTin[hx.temperature.inlet]
        
        return parameter.temperature.htf.outlet.max
          .adjusted(with: clamp(factor))
      }
    } else if parameter.Tout_exp_Tin_Mfl,
      let c = parameter.ToutTinMassFlow
    {
      return {
        (pb: PowerBlock.PerformanceData, _: HeatCycle) -> Temperature in
        let massFlowLoad = pb.massFlow.share(of: solarField.massFlow.max)
        let factor = ((c[0] * (pb.inletTemperature
          / parameter.temperature.htf.inlet.max.kelvin) * 666 + c[1])
          * massFlowLoad.ratio ** (c[2] * (pb.inletTemperature
            / parameter.temperature.htf.inlet.max.kelvin) * 666 + c[3])) + c[4]
        
        return parameter.temperature.htf.outlet.max
          .adjusted(with: clamp(factor))
      }
    } else if let ToutTin = parameter.ToutTin {
      return { (_: PowerBlock.PerformanceData,
        hx: HeatCycle) -> Temperature in
        let factor = Ratio(ToutTin[hx.temperature.inlet])
        
        return parameter.temperature.htf.outlet.max.adjusted(with: factor)
      }
    }
    return {
      (pb: PowerBlock.PerformanceData, _: HeatCycle) -> Temperature in
      let temp = parameter.temperature
      return Temperature(
        temp.htf.outlet.min.kelvin + temp.designDelta.outlet.kelvin
          * (pb.temperature.inlet - temp.htf.inlet.min).kelvin
          / temp.designDelta.inlet.kelvin
      )
    }
  }
}

extension HeatExchanger.PerformanceData.OperationMode: RawRepresentable {
  public typealias RawValue = String
  
  public init?(rawValue: RawValue) {
    switch rawValue {
    case "No Operation for 0 hours": self = .noOperation(hours: 0)
    case "SI": self = .SI
    case "StartUp": self = .startUp
    case "Scheduled Maintenanc": self = .scheduledMaintenance
    case "Cold StartUp": self = .coldStartUp
    case "Warm StartUp": self = .warmStartUp
    default: return nil
    }
  }
  
  public var rawValue: RawValue {
    switch self {
    case let .noOperation(hours): return "No Operation for \(hours) hours"
    case .SI: return "SI"
    case .startUp: return "StartUp"
    case .scheduledMaintenance: return "Scheduled Maintenance"
    case .coldStartUp: return "Cold StartUp"
    case .warmStartUp: return "Warm StartUp"
    }
  }
}
