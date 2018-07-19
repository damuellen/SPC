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
    case .noOperation(let hours): return "No Operation for \(hours) hours"
    case .SI: return "SI"
    case .startUp: return "StartUp"
    case .scheduledMaintenance: return "Scheduled Maintenance"
    case .coldStartUp: return "Cold StartUp"
    case .warmStartUp: return "Warm StartUp"
    }
  }
}

public enum HeatExchanger: Component {
  
  final class Instance {
    // A singleton class holding the state of the heat exchanger
    fileprivate static let shared = Instance()
    var parameter: HeatExchanger.Parameter!
  }

  /// a struct for operation-relevant data of the heat exchanger
  public struct PerformanceData: Equatable, HeatCycle, CustomStringConvertible {
    var name = ""
    var operationMode: OperationMode
    var temperature: (inlet: Temperature, outlet: Temperature)
    var massFlow: MassFlow
    var totalMassFlow, heatIn, heatOut, heatToTES: Double

    public enum OperationMode: Equatable {
      case noOperation(hours: Double), SI, startUp, scheduledMaintenance, coldStartUp, warmStartUp
      
      public static func ==(lhs: OperationMode, rhs: OperationMode) -> Bool {
        switch (lhs, rhs) {
          case (.noOperation(let lhs), noOperation(let rhs)): return lhs == rhs
        default: return lhs.rawValue == rhs.rawValue
        }
      }
    }
    
    public var description: String {
      return "\(operationMode), "
        + String(format:"Mfl: %.1fkg/s, ", massFlow.rate)
        + String(format:"In: %.1f°C, ", temperature.inlet.celsius)
        + String(format:"Out: %.1f°C", temperature.outlet.celsius)
    }
    
    public static func ==(lhs: PerformanceData, rhs: PerformanceData) -> Bool {
      return lhs.operationMode == rhs.operationMode
        && lhs.temperature == rhs.temperature
        && lhs.massFlow == rhs.massFlow
        && lhs.totalMassFlow == rhs.totalMassFlow
        && lhs.heatIn == rhs.heatIn
        && lhs.heatOut == rhs.heatOut
        && lhs.heatToTES == rhs.heatToTES
    }
  }

  /// working conditions of the heat exchanger at start
  static let initialState = PerformanceData(
    name: "",
    operationMode: .SI,
    temperature: (inlet: Temperature(celsius: 30.0),
                  outlet: Temperature(celsius: 30.0)),
    massFlow: 0.0,
    totalMassFlow: 0.0,
    heatIn: 0.0,
    heatOut: 0.0,
    heatToTES: 0.0)

  static var parameter: Parameter = ParameterDefaults.hx
  
  static func limit(_ temperatureFactor: Double) -> Double {
    var temperatureFactor = temperatureFactor
    if temperatureFactor > 1.1 { temperatureFactor = 1.1 }
    if temperatureFactor < 0 { temperatureFactor = 0 }
    return temperatureFactor
  }
  
  public static func update(_ hx: inout HeatExchanger.PerformanceData,
                            steamTurbine: SteamTurbine.PerformanceData,
                            storage: Storage.PerformanceData) -> Double {
    
    if parameter.name.hasPrefix("Heat Exchanger HTF-H2O - BK") {
      hx.temperature.outlet = Temperature(
        parameter.temperature.htf.outlet.max.kelvin
        - (120 - 169 * steamTurbine.load.ratio
          + 49 * steamTurbine.load.ratio ** 2))

      if hx.temperature.outlet < parameter.temperature.htf.outlet.min {
        hx.temperature.outlet = parameter.temperature.htf.outlet.min
      }
    } else {
      if parameter.useAndsolFunction {
        let massFlowLoad = hx.massFlow.share(of: solarField.massFlow.max)
       // assert(massFlowLoad > 1) // check how big massflow load can be (5% more than design?)

        // power function based on MAN-Turbo and OHL data with  pinch point tool
        var temperatureFactor = ((0.0007592419869
          * hx.temperature.inlet.kelvin + 0.4943825893223)
          * massFlowLoad.ratio ** (0.0001400823882
            * hx.temperature.inlet.kelvin - 0.0110227028559)) - 0.000151639

        temperatureFactor = ((0.0007592419869 * (hx.temperature.inlet.kelvin
            / parameter.temperature.htf.inlet.max.kelvin) * 666 + 0.4943825893223)
          * massFlowLoad.ratio ** (0.0001400823882 * (hx.temperature.inlet.kelvin
              / parameter.temperature.htf.inlet.max.kelvin) * 666 - 0.0110227028559))
          - 0.000151639 // function is based on 393°C Tin

        hx.temperature.outlet = Temperature(limit(temperatureFactor) *
          parameter.temperature.htf.outlet.max.kelvin)
      } else {
        switch (parameter.ToutMassFlow, parameter.ToutTin, parameter.ToutTinMassFlow) {

        case let (ToutMassFlow?, ToutTin?, .none):

          let massFlowLoad = hx.massFlow.share(of: solarField.massFlow.max)

          var temperatureFactor = ToutMassFlow[massFlowLoad]
          temperatureFactor *= ToutTin[hx.temperature.inlet]

          hx.temperature.outlet = Temperature(temperatureFactor *
            parameter.temperature.htf.outlet.max.kelvin)

        case let (ToutMassFlow?, .none, .none):
          let temp = parameter.temperature
          hx.temperature.outlet = Temperature(temp.htf.outlet.min.kelvin
            + (temp.htf.outlet.max - temp.htf.outlet.min).kelvin
            * (hx.temperature.inlet - temp.htf.inlet.min).kelvin
            / (temp.htf.inlet.max - temp.htf.inlet.min).kelvin)

          let massFlowLoad = hx.massFlow.share(of: solarField.massFlow.max)

          let temperatureFactor = ToutMassFlow[massFlowLoad]

          hx.temperature.outlet = Temperature(hx.temperature.outlet.kelvin *
            limit(temperatureFactor))
        case let (_, _, ToutTinMassFlow?):
          let temp = parameter.temperature
          let massFlowLoad = hx.massFlow.share(of: solarField.massFlow.max)

          // power function based on MAN-Turbo and OHL data with  pinch point tool
          let temperatureFactor = ((ToutTinMassFlow[0]
              * (hx.temperature.inlet.kelvin / temp.htf.inlet.max.kelvin)
              * 666 + ToutTinMassFlow[1])
            * massFlowLoad.ratio ** (ToutTinMassFlow[2]
            * (hx.temperature.inlet.kelvin / temp.htf.inlet.max.kelvin)
            * 666 + ToutTinMassFlow[3])) + ToutTinMassFlow[4]

          hx.temperature.outlet = temp.htf.outlet.max
            .adjusted(with: limit(temperatureFactor))

        case let (_, ToutTin?, _):

          let temperatureFactor = ToutTin[hx.temperature.inlet]

          hx.temperature.outlet = parameter.temperature.htf.outlet.max
            .adjusted(with: temperatureFactor)

        default:
          let temp = parameter.temperature
          // CHECK: the value of HTFoutTmax should be dependent on storage charging but only on PB HX
          hx.temperature.outlet = Temperature(temp.htf.outlet.min.kelvin
            + (temp.htf.outlet.max - temp.htf.outlet.min).kelvin
            * (hx.temperature.inlet.kelvin - temp.htf.inlet.min.kelvin)
            / (temp.htf.inlet.max.kelvin - temp.htf.inlet.min.kelvin))
        }
      }
    }
    
    if case .discharge = storage.operationMode,
      hx.temperature.outlet.kelvin < (261.toKelvin) {
      // added to simulate a bypass on the PB-HX if the expected outlet temp is so low that the salt to TES could freeze
      let totalMassFlow = hx.massFlow
      let h_261 = 1.51129 * 261 + 1.2941 / 1_000 * 261 ** 2
        + 1.23697 / 10 ** 7 * 261 ** 3 - 0.62677 // kJ/kg

      for i in 0 ..< 100 where hx.heatToTES > h_261 {
        // reduce massflow to PB in 5% every step until enthalpy is
        hx.massFlow = MassFlow(totalMassFlow.rate * (1 - (Double(i) / 20)))
        let massFlowLoad = hx.massFlow.share(of: solarField.massFlow.max)

        if let ToutMassFlow = parameter.ToutMassFlow,
          let ToutTin = parameter.ToutTin,
          parameter.useAndsolFunction == false {
          var temperatureFactor = ToutMassFlow[massFlowLoad]
          temperatureFactor *= ToutTin[hx.temperature.inlet]

          hx.temperature.outlet = parameter.temperature.htf.outlet.max.adjusted(
            with: temperatureFactor)
        } else if let ToutMassFlow = parameter.ToutMassFlow,
          parameter.useAndsolFunction == false {
          // if Tout is dependant on massflow, recalculate Tout
          let temperatureFactor = ToutMassFlow[massFlowLoad]

          hx.temperature.outlet.adjust(with: temperatureFactor)
        } else if parameter.useAndsolFunction {
          // check how big massflow load can be (5% more than design?)
          let temperatureFactor = ((0.0007592419869
              * (hx.temperature.inlet.kelvin / parameter.temperature.htf.inlet.max.kelvin)
              * 666 + 0.4943825893223) * massFlowLoad.ratio ** (0.0001400823882
            * (hx.temperature.inlet.kelvin / parameter.temperature.htf.inlet.max.kelvin)
            * 666 - 0.0110227028559)) - 0.000151639

          hx.temperature.outlet = parameter.temperature.htf.outlet.max.adjusted(
            with: limit(temperatureFactor))
        } else if let ToutTinMassFlow = parameter.ToutTinMassFlow {
          // power function based on MAN-Turbo and OHL data with pinch point tool
          let temperatureFactor = ((ToutTinMassFlow[0]
            * hx.temperature.inlet.kelvin + ToutTinMassFlow[1])
            * massFlowLoad.ratio ** (ToutTinMassFlow[2]
              * hx.temperature.inlet.kelvin + ToutTinMassFlow[3]))
            + ToutTinMassFlow[4]

          hx.temperature.outlet = Temperature(
            parameter.temperature.htf.outlet.max.kelvin * limit(temperatureFactor))
        }

        hx.heatOut = 1.51129 * (hx.temperature.outlet.celsius)
          + 1.2941 / 1_000 * (hx.temperature.outlet.celsius) ** 2
          + 1.23697 / 10 ** 7 * (hx.temperature.outlet.celsius) ** 3
          - 0.62677 // kJ/kg
        let bypassMassFlow = totalMassFlow - hx.massFlow
        let bypass_h = 1.51129 * (hx.temperature.inlet.celsius)
          + 1.2941 / 1_000 * (hx.temperature.inlet.celsius) ** 2
          + 1.23697 / 10 ** 7 * (hx.temperature.inlet.celsius) ** 3
          - 0.62677 // kJ/kg
        hx.heatToTES = (bypassMassFlow.rate * bypass_h + hx.massFlow.rate * hx.heatOut)
          / (bypassMassFlow + hx.massFlow).rate
      }

      hx.temperature.outlet = Temperature((-0.000000000061133
        * hx.heatToTES ** 4 + 0.00000019425
        * hx.heatToTES ** 3 - 0.00032293
        * hx.heatToTES ** 2 + 0.65556
        * hx.heatToTES + 0.58315).toKelvin)
    }
    
    return hx.heatTransfered(with: htf) / 1_000 * parameter.efficiency
  }
  
  static func update(powerBlock: inout PowerBlock.PerformanceData,
                     heatExchanger: HeatExchanger.PerformanceData) {

    if parameter.Tout_f_Mfl == false,
      parameter.Tout_f_Tin == false,
      parameter.useAndsolFunction == false,
      parameter.Tout_exp_Tin_Mfl == false { // old method
      powerBlock.temperature.outlet = Temperature(
        parameter.temperature.htf.outlet.min.kelvin
        + (parameter.temperature.htf.outlet.max
          - parameter.temperature.htf.outlet.min).kelvin
        * (powerBlock.temperature.inlet
          - parameter.temperature.htf.inlet.min).kelvin
        / (parameter.temperature.htf.inlet.max
          - parameter.temperature.htf.inlet.min).kelvin)
      // CHECK: the value of HTFoutTmax should be dependent on storage charging but only on PB HX!
      
    } else if parameter.Tout_exp_Tin_Mfl,
      parameter.Tout_f_Tin == false,
      let ToutMassFlow = parameter.ToutMassFlow {
      
      powerBlock.temperature.outlet = Temperature(
        parameter.temperature.htf.outlet.min.kelvin
        + (parameter.temperature.htf.outlet.max
          - parameter.temperature.htf.outlet.min).kelvin
        * (powerBlock.temperature.inlet
          - parameter.temperature.htf.inlet.min).kelvin
        / (parameter.temperature.htf.inlet.max
          - parameter.temperature.htf.inlet.min).kelvin)
      
      let massFlowLoad = powerBlock.massFlow.share(of: solarField.massFlow.max)
      
      let temperaturFactor = Ratio(ToutMassFlow[massFlowLoad.ratio])
      
      powerBlock.temperature.outlet.adjust(with: temperaturFactor)
      
    } else if parameter.Tout_f_Mfl && parameter.Tout_f_Tin,
      let ToutMassFlow = parameter.ToutMassFlow,
      let ToutTin = parameter.ToutTin {
      
      let massFlowLoad = powerBlock.massFlow.share(of: solarField.massFlow.max)
      
      var temperaturFactor = ToutMassFlow[massFlowLoad.ratio]
      temperaturFactor *= ToutTin[heatExchanger.temperature.inlet]
      
      powerBlock.temperature.outlet =
        parameter.temperature.htf.outlet.max.adjusted(with: temperaturFactor)
      
    } else if parameter.useAndsolFunction {
      
      let massFlowLoad = powerBlock.massFlow.share(of: solarField.massFlow.max)
      
      let temperaturFactor = ((0.0007592419869
        * (powerBlock.temperature.inlet.kelvin
          / parameter.temperature.htf.inlet.max.kelvin)
        * 666 + 0.4943825893223)
        * massFlowLoad.ratio ** (0.0001400823882
          * (powerBlock.temperature.inlet.kelvin
            / parameter.temperature.htf.inlet.max.kelvin)
          * 666 - 0.0110227028559)) - 0.000151639
      // temperature.inlet changed to (Fluid.parameter.temperature.inlet / parameter.temperature.htf.inlet.max) * 666 because function is based on 393°C temperature.inlet
      
      powerBlock.temperature.outlet = parameter.temperature.htf.outlet.max
        .adjusted(with: limit(temperaturFactor))
      
    } else if parameter.Tout_exp_Tin_Mfl,
      let coefficients = parameter.ToutTinMassFlow {
      
      let massFlowLoad = powerBlock.massFlow.share(of: solarField.massFlow.max)
      
      let temperaturFactor = ((coefficients[0]
        * (powerBlock.temperature.inlet.kelvin / parameter.temperature.htf.inlet.max.kelvin)
        * 666 + coefficients[1]) * massFlowLoad.ratio
        ** (coefficients[2] * (powerBlock.temperature.inlet.kelvin
          / parameter.temperature.htf.inlet.max.kelvin)
          * 666 + coefficients[3]))
        + coefficients[4]
      // temperature.inlet changed to (Fluid.parameter.temperature.inlet / parameter.temperature.htf.inlet.max) * 666 because function is based on 393°C temperature.inlet
      
      powerBlock.temperature.outlet = parameter.temperature.htf.outlet.max
        .adjusted(with: limit(temperaturFactor))
    } else if let ToutTin = parameter.ToutTin {
      
      let temperaturFactor = Ratio(ToutTin[heatExchanger.temperature.inlet])
      powerBlock.temperature.outlet = Temperature( temperaturFactor.ratio *
        parameter.temperature.htf.outlet.max.kelvin)
    }
  }
}
