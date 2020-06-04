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

public struct HeatExchanger: Component, HeatCycle {
  /// Contains all data needed to simulate the operation of the heat exchanger
  var operationMode: OperationMode
  
  var cycle: HeatTransfer = .init(name: HeatExchanger.parameter.name)
  
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

  /// working conditions of the heat exchanger at start
  static let initialState = HeatExchanger(
    operationMode: .SI, heatOut: 0.0, heatToTES: 0.0
  )

  public static var parameter: Parameter = ParameterDefaults.hx

  static func clamp(_ temperatureFactor: Double) -> Double {
    var temperatureFactor = temperatureFactor
    if temperatureFactor > 1.1 { temperatureFactor = 1.1 }
    if temperatureFactor < 0 { temperatureFactor = 0 }
    return temperatureFactor
  }

  /// power function based on MAN-Turbo and OHL data with pinch point tool
  static func temperatureFactor(
    temperature: Temperature, load: Ratio, max: Temperature) -> Double
  {
    return clamp(((0.0007592419869 * (temperature.kelvin / max.kelvin)
      * 666 + 0.4943825893223) * load.ratio ** (0.0001400823882
        * (temperature.kelvin / max.kelvin)
        * 666 - 0.0110227028559)) - 0.000151639) // function is based on 393°C
  }
  
  /// Update HeatExchanger.temperature.outlet
  mutating func callAsFunction(
    steamTurbine: SteamTurbine,
    storage: Storage) -> Double
  {
    let parameter = HeatExchanger.parameter
    let solarField = SolarField.parameter
    let load = steamTurbine.load ?? .zero
    let htf = solarField.HTF
    if parameter.name.hasPrefix("Heat Exchanger HTF-H2O - BK") {
      self.outletTemperature(kelvin:
        parameter.temperature.htf.outlet.max.kelvin
          - (120 - 169 * load.ratio + 49 * load.ratio ** 2)
      )
      if self.temperature.outlet < parameter.temperature.htf.outlet.min {
        self.setTemperature(outlet: parameter.temperature.htf.outlet.min)
      }
    } else {
      if parameter.useAndsolFunction {
        let massFlowLoad = self.massFlow.share(of: solarField.massFlow.max)

        let factor = HeatExchanger.temperatureFactor(
          temperature: self.temperature.inlet, load: massFlowLoad,
          max: parameter.temperature.htf.inlet.max)

        self.setTemperature(outlet:
           parameter.temperature.htf.outlet.max.adjusted(factor)
        )
      } else {
        let p = parameter
        let temp = parameter.temperature
        switch (p.ToutMassFlow, p.ToutTin, p.ToutTinMassFlow) {
        case let (ToutMassFlow?, ToutTin?, .none):
          let massFlowLoad = self.massFlow.share(of: solarField.massFlow.max)

          var factor = ToutMassFlow(massFlowLoad)
          factor *= ToutTin(temperature.inlet)
          factor = HeatExchanger.clamp(factor)
          setTemperature(outlet:
            parameter.temperature.htf.outlet.max.adjusted(factor)
          )
        case let (ToutMassFlow?, .none, .none):
          outletTemperature(kelvin:
            temp.htf.outlet.min.kelvin + temp.range.outlet.kelvin
            * (temperature.inlet - temp.htf.inlet.min).kelvin
            / temp.range.inlet.kelvin)

          let massFlowLoad = massFlow.share(of: solarField.massFlow.max)

          var factor = ToutMassFlow(massFlowLoad)
          factor = HeatExchanger.clamp(factor)
          outletTemperature(kelvin: factor * self.outletTemperature)
        case let (_, _, ToutTinMassFlow?):
          let massFlowLoad = massFlow.share(of: solarField.massFlow.max)

          // power function based on MAN-Turbo and OHL data with pinch point tool
          var factor = ((ToutTinMassFlow[0]
              * (self.inletTemperature / temp.htf.inlet.max.kelvin)
              * 666 + ToutTinMassFlow[1])
            * massFlowLoad.ratio ** (ToutTinMassFlow[2]
              * (self.inletTemperature / temp.htf.inlet.max.kelvin)
              * 666 + ToutTinMassFlow[3])) + ToutTinMassFlow[4]
          factor = HeatExchanger.clamp(factor)
          self.setTemperature(outlet:
            temp.htf.outlet.max.adjusted(factor)
          )
        case let (_, ToutTin?, _):
          var factor = ToutTin(temperature.inlet)
          factor = HeatExchanger.clamp(factor)
          self.setTemperature(outlet:
            temp.htf.outlet.max.adjusted(factor)
          )
        default:
// CHECK: the value of HTFoutTmax should be dependent on storage charging but only on PB self
          self.outletTemperature(kelvin:
            temp.htf.outlet.min.kelvin + temp.range.outlet.kelvin
            * (self.inletTemperature - temp.htf.inlet.min.kelvin)
            / temp.range.inlet.kelvin)
        }
      }
    }

    // Update HeatExchanger.temperature.outlet and massFlow
    if case .discharge = storage.operationMode,
      outletTemperature < (261 - Temperature.absoluteZeroCelsius) {
      // added to simulate a bypass on the PB-self if the expected
      // outlet temperture is so low that the salt to TES could freeze
      let totalMassFlow = massFlow

      for i in 1...  where heatToTES > h_261 {
        // reduce massflow to PB in 5% every step until enthalpy is
        setMassFlow(rate: totalMassFlow.rate * (1 - (Double(i) / 20)))
        let load = massFlow.share(of: solarField.massFlow.max)

        if parameter.useAndsolFunction {
          // check how big massflow load can be (5% more than design?)
          let factor = HeatExchanger.temperatureFactor(
            temperature: temperature.inlet, load: load,
            max: parameter.temperature.htf.inlet.max
          )

          setTemperature(outlet:
            parameter.temperature.htf.outlet.max.adjusted(factor)
          )
        } else if let ToutMassFlow = parameter.ToutMassFlow,
          let ToutTin = parameter.ToutTin {

          var factor = ToutMassFlow(load)
          factor *= ToutTin(temperature.inlet)
          factor = HeatExchanger.clamp(factor)
          setTemperature(outlet:
            parameter.temperature.htf.outlet.max.adjusted(factor)
          )
        } else if let ToutMassFlow = parameter.ToutMassFlow {
          // if Tout is dependant on massflow, recalculate Tout
          let factor = HeatExchanger.clamp(ToutMassFlow(load))

          temperature.outlet.adjust(withFactor: factor)
        } else if let c = parameter.ToutTinMassFlow {
          // power function based on MAN-Turbo and OHL data with pinch point tool
          var factor = ((c[0] * inletTemperature + c[1])
            * load.ratio ** (c[2] * inletTemperature + c[3])) + c[4]
          factor = HeatExchanger.clamp(factor)
          setTemperature(outlet:
            parameter.temperature.htf.outlet.max.adjusted(factor)
          )
        }

        heatOut = htf.enthalpy(temperature.outlet)
        let bypassMassFlow = totalMassFlow - massFlow
        let bypass_h = htf.enthalpy(temperature.inlet)
        heatToTES = (bypassMassFlow.rate * bypass_h
          + massFlow.rate * heatOut)
          / (bypassMassFlow + massFlow).rate
      }

      setTemperature(outlet: htf.temperature(heatToTES))
    }
    let heat = massFlow.rate * deltaHeat / 1_000
    return -heat * parameter.efficiency
  }
  /// Calculates the outlet temperature of the power block
  static var outletTemperature = outletTemperatureFunction()
  
  private static func outletTemperatureFunction()
    -> (PowerBlock, HeatCycle) -> Temperature
  {
    let solarField = SolarField.parameter

    if parameter.useAndsolFunction {
      return {
        (pb: PowerBlock, _: HeatCycle) -> Temperature in
        let massFlowLoad = pb.massFlow.share(of: solarField.massFlow.max)
        let factor = temperatureFactor(
          temperature: pb.temperature.inlet, load: massFlowLoad,
          max: parameter.temperature.htf.inlet.max)
        
        return parameter.temperature.htf.outlet.max
          .adjusted(factor)
      }
    } else if parameter.Tout_exp_Tin_Mfl,
      parameter.Tout_f_Tin == false,
      let ToutMassFlow = parameter.ToutMassFlow
    {
      return {
        (pb: PowerBlock, _: HeatCycle) -> Temperature in
        let massFlowLoad = pb.massFlow.share(of: solarField.massFlow.max)
        
        let factor = Ratio(ToutMassFlow(massFlowLoad.ratio))
        
        let temp = parameter.temperature

        return Temperature(
          (temp.htf.outlet.min.kelvin + temp.range.outlet.kelvin
            * (pb.temperature.inlet - temp.htf.inlet.min).kelvin
            / temp.range.inlet.kelvin) * factor.ratio
        )
      }
    } else if parameter.Tout_f_Mfl && parameter.Tout_f_Tin,
      let ToutMassFlow = parameter.ToutMassFlow,
      let ToutTin = parameter.ToutTin
    {
      return {
        (pb: PowerBlock, hx: HeatCycle) -> Temperature in
        let massFlowLoad = pb.massFlow.share(of: solarField.massFlow.max)
        var factor = ToutMassFlow(massFlowLoad.ratio)
        factor *= ToutTin(hx.temperature.inlet)
        
        return parameter.temperature.htf.outlet.max
          .adjusted(clamp(factor))
      }
    } else if parameter.Tout_exp_Tin_Mfl,
      let c = parameter.ToutTinMassFlow
    {
      return {
        (pb: PowerBlock, _: HeatCycle) -> Temperature in
        let massFlowLoad = pb.massFlow.share(of: solarField.massFlow.max)
        let factor = ((c[0] * (pb.inletTemperature
          / parameter.temperature.htf.inlet.max.kelvin) * 666 + c[1])
          * massFlowLoad.ratio ** (c[2] * (pb.inletTemperature
            / parameter.temperature.htf.inlet.max.kelvin) * 666 + c[3])) + c[4]
        
        return parameter.temperature.htf.outlet.max
          .adjusted(clamp(factor))
      }
    } else if let ToutTin = parameter.ToutTin {
      return { (_: PowerBlock,
        hx: HeatCycle) -> Temperature in
        let factor = Ratio(ToutTin(hx.temperature.inlet))
        
        return parameter.temperature.htf.outlet.max.adjusted(factor)
      }
    }
    return {
      (pb: PowerBlock, _: HeatCycle) -> Temperature in
      let temp = parameter.temperature
      return Temperature(
        temp.htf.outlet.min.kelvin + temp.range.outlet.kelvin
          * (pb.temperature.inlet - temp.htf.inlet.min).kelvin
          / temp.range.inlet.kelvin
      )
    }
  }
}

extension HeatExchanger.OperationMode: RawRepresentable {
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
