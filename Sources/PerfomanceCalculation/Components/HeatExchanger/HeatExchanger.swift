//
//  Copyright (c) 2017 Daniel Müllenborn. All rights reserved.
//  Distributed under the The Non-Profit Open Software License version 3.0
//  http://opensource.org/licenses/NPOSL-3.0
//
//  This project is NOT free software. It is open source, you are allowed to
//  modify it (if you keep the license), but it may not be commercially
//  distributed other than under the conditions noted above.
//

import Foundation

extension HeatExchanger.Instance: CustomDebugStringConvertible {
  var debugDescription: String { return "\(workingConditions.current)" }
}

extension HeatExchanger.PerformanceData.OperationMode: RawRepresentable {
  public typealias RawValue = String
  
  public init?(rawValue: RawValue) {
    switch rawValue {
    case "noOperation": self = .noOperation(hours: 0)
    case "SI": self = .SI
    case "startUp": self = .startUp
    case "SM": self = .SM
    case "coldStartUp": self = .coldStartUp
    case "warmStartUp": self = .warmStartUp
    default: return nil
    }
  }
  
  public var rawValue: RawValue {
    switch self {
    case .noOperation(let hours): return "No Operation for \(hours) hours"
    case .SI: return "SI"
    case .startUp: return "StartUp"
    case .SM: return "SM"
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
    var workingConditions: (previous: PerformanceData?, current: PerformanceData)
    
    private init() {
      workingConditions = (nil, initialState)
    }
  }

  /// a struct for operation-relevant data of the heat exchanger
  public struct PerformanceData: Equatable, MassFlow, WorkingConditions, CustomStringConvertible {
    var operationMode: OperationMode
    var heatFlow: Double = 0.0
    var temperature: (inlet: Temperature, outlet: Temperature)
    var massFlow, totalMassFlow, hin, htoTES: Double

    public enum OperationMode: Equatable {
      case noOperation(hours: Double), SI, startUp, SM, coldStartUp, warmStartUp
      
      public static func ==(lhs: OperationMode, rhs: OperationMode) -> Bool {
        switch (lhs, rhs) {
          case (.noOperation(let lhs), noOperation(let rhs)): return lhs == rhs
        default: return lhs.rawValue == rhs.rawValue
        }
      }
    }
    
    public var description: String {
      return "Mode: \(operationMode)"
        + String(format:"Heat Flow: %.1f ", heatFlow)
        + String(format:"Mass Flow: %.1f ", massFlow)
        + String(format:"Inlet: %.1f ", temperature.inlet.value)
        + String(format:"Outlet: %.1f", temperature.outlet.value)
    }
    
    public static func ==(lhs: PerformanceData, rhs: PerformanceData) -> Bool {
      return lhs.operationMode == rhs.operationMode
        && lhs.heatFlow == rhs.heatFlow
        && lhs.temperature == rhs.temperature
        && lhs.massFlow == rhs.massFlow
        && lhs.totalMassFlow == rhs.totalMassFlow
        && lhs.hin == rhs.hin
        && lhs.htoTES == rhs.htoTES
    }
  }

  /// working conditions of the heat exchanger at start
  fileprivate static let initialState = PerformanceData(
    operationMode: .SI,
    heatFlow: 0.0,
    temperature: (0.0, 0.0),
    massFlow: 0.0,
    totalMassFlow: 0.0,
    hin: 0.0,
    htoTES: 0.0)

  /// Returns the current working conditions of the heat exchanger
  public static var status: PerformanceData {
    get { return Instance.shared.workingConditions.current }
    set {
      if Instance.shared.workingConditions.current != newValue {
        #if DEBUG
          print("Solarfield status changed at \(PerformanceCalculator.dateTime):")
          print(Instance.shared.workingConditions.current)
        #endif
        Instance.shared.workingConditions =
          (Instance.shared.workingConditions.current, newValue)
      }
    }
  }

  /// Returns the previous working conditions of the heat exchanger
  public static var previous: PerformanceData? {
    return Instance.shared.workingConditions.previous
  }

  public static var parameter: HeatExchanger.Parameter {
    get { return Instance.shared.parameter }
    set { Instance.shared.parameter = newValue }
  }
  
  static func setLimits(_ temperatureFactor: Double) -> Double {
    var temperatureFactor = temperatureFactor
    if temperatureFactor > 1.1 { temperatureFactor = 1.1 }
    if temperatureFactor < 0 { temperatureFactor = 0 }
    return temperatureFactor
  }
  
  public static func operate(_ hx: inout HeatExchanger.PerformanceData) {
    
    if parameter.name.hasPrefix("Heat Exchanger HTF-H2O - BK") {
      hx.temperature.outlet = Temperature(parameter.temperature.htf.outlet.max.value
        - (120 - 169 * SteamTurbine.status.load.value
          + 49 * SteamTurbine.status.load.value ** 2))

      if hx.temperature.outlet < parameter.temperature.htf.outlet.min {
        hx.temperature.outlet = parameter.temperature.htf.outlet.min
      }
    } else {
      if parameter.useAndsolFunction {
        let massFlowLoad = (hx.massFlow / SolarField.parameter.massFlow.max)
        assert(massFlowLoad > 1) // check how big massflow load can be (5% more than design?)

        // power function based on MAN-Turbo and OHL data with  pinch point tool
        var temperatureFactor = ((0.0007592419869
          * hx.temperature.inlet.value + 0.4943825893223)
          * massFlowLoad ** (0.0001400823882
            * hx.temperature.inlet.value - 0.0110227028559)) - 0.000151639

        temperatureFactor = ((0.0007592419869 * (hx.temperature.inlet.value
            / parameter.temperature.htf.inlet.max.value) * 666 + 0.4943825893223)
          * massFlowLoad ** (0.0001400823882 * (hx.temperature.inlet.value
              / parameter.temperature.htf.inlet.max.value) * 666 - 0.0110227028559))
          - 0.000151639 // function is based on 393°C Tin

        hx.temperature.outlet = Temperature(setLimits(temperatureFactor) *
          parameter.temperature.htf.outlet.max.value)
      } else {
        switch (parameter.ToutMassFlow, parameter.ToutTin, parameter.ToutTinMassFlow) {

        case let (ToutMassFlow?, ToutTin?, .none):

          let massFlowLoad = Ratio(hx.massFlow / SolarField.parameter.massFlow.max)

          var temperatureFactor = ToutMassFlow[massFlowLoad]
          temperatureFactor *= ToutTin[hx.temperature.inlet]

          hx.temperature.outlet = Temperature(temperatureFactor *
            parameter.temperature.htf.outlet.max.value)

        case let (ToutMassFlow?, .none, .none):
          let temp = parameter.temperature
          hx.temperature.outlet = Temperature(temp.htf.outlet.min.value
            + (temp.htf.outlet.max - temp.htf.outlet.min).value
            * (hx.temperature.inlet - temp.htf.inlet.min).value
            / (temp.htf.inlet.max - temp.htf.inlet.min).value)

          let massFlowLoad = Ratio(hx.massFlow / SolarField.parameter.massFlow.max)

          let temperatureFactor = ToutMassFlow[massFlowLoad]

          hx.temperature.outlet = Temperature(hx.temperature.outlet.value *
            setLimits(temperatureFactor))
        case let (_, _, ToutTinMassFlow?):
          let temp = parameter.temperature
          let massFlowLoad = Ratio(hx.massFlow / SolarField.parameter.massFlow.max)

          // power function based on MAN-Turbo and OHL data with  pinch point tool
          let temperatureFactor = ((ToutTinMassFlow[0]
              * (hx.temperature.inlet.value / temp.htf.inlet.max.value)
              * 666 + ToutTinMassFlow[1])
            * massFlowLoad.value ** (ToutTinMassFlow[2]
            * (hx.temperature.inlet.value / temp.htf.inlet.max.value)
            * 666 + ToutTinMassFlow[3])) + ToutTinMassFlow[4]

          hx.temperature.outlet = temp.htf.outlet.max
            .adjusted(with: setLimits(temperatureFactor))

        case let (_, ToutTin?, _):

          let temperatureFactor = ToutTin[hx.temperature.inlet]

          hx.temperature.outlet = parameter.temperature.htf.outlet.max
            .adjusted(with: temperatureFactor)

        default:
          let temp = parameter.temperature
          // CHECK: the value of HTFoutTmax should be dependent on storage charging but only on PB HX
          hx.temperature.outlet = Temperature(temp.htf.outlet.min.value
            + (temp.htf.outlet.max - temp.htf.outlet.min).value
            * (hx.temperature.inlet - temp.htf.inlet.min).value
            / (temp.htf.inlet.max - temp.htf.inlet.min).value)
        }
      }
    }

    if case .discharge = Storage.status.operationMode,
      hx.temperature.outlet.value < (261.toKelvin) {
      // added to simulate a bypass on the PB-HX if the expected outlet temp is so low that the salt to TES could freeze
      let totalMassFlow = hx.massFlow
      let h_261 = 1.51129 * 261 + 1.2941 / 1_000 * 261 ** 2
        + 1.23697 / 10 ** 7 * 261 ** 3 - 0.62677 // kJ/kg

      for i in 0 ..< 100 where HeatExchanger.status.htoTES > h_261 {
        // reduce massflow to PB in 5% every step until enthalpy is
        hx.massFlow = totalMassFlow * (1 - (Double(i) / 20))
        let massFlowLoad = Ratio(hx.massFlow / SolarField.parameter.massFlow.max)

        if let ToutMassFlow = parameter.ToutMassFlow,
          let ToutTin = parameter.ToutTin,
          !parameter.useAndsolFunction {
          var temperatureFactor = ToutMassFlow[massFlowLoad]
          temperatureFactor *= ToutTin[hx.temperature.inlet]

          hx.temperature.outlet = parameter.temperature.htf.outlet.max.adjusted(
            with: temperatureFactor)
        } else if let ToutMassFlow = parameter.ToutMassFlow,
          !parameter.useAndsolFunction {
          // if Tout is dependant on massflow, recalculate Tout
          let temperatureFactor = ToutMassFlow[massFlowLoad]

          hx.temperature.outlet = hx.temperature.outlet.adjusted(with: temperatureFactor)
        } else if parameter.useAndsolFunction {
          // check how big massflow load can be (5% more than design?)
          let temperatureFactor = ((0.0007592419869
              * (hx.temperature.inlet.value / parameter.temperature.htf.inlet.max.value)
              * 666 + 0.4943825893223) * massFlowLoad.value ** (0.0001400823882
            * (hx.temperature.inlet.value / parameter.temperature.htf.inlet.max.value)
            * 666 - 0.0110227028559)) - 0.000151639

          hx.temperature.outlet = parameter.temperature.htf.outlet.max.adjusted(
            with: setLimits(temperatureFactor))
        } else if let ToutTinMassFlow = parameter.ToutTinMassFlow {
          // power function based on MAN-Turbo and OHL data with pinch point tool
          let temperatureFactor = ((ToutTinMassFlow[0]
            * hx.temperature.inlet.value + ToutTinMassFlow[1])
            * massFlowLoad.value ** (ToutTinMassFlow[2]
              * hx.temperature.inlet.value + ToutTinMassFlow[3]))
            + ToutTinMassFlow[4]

          hx.temperature.outlet = Temperature(
            parameter.temperature.htf.outlet.max.value * setLimits(temperatureFactor))
        }

        let HX_hout = 1.51129 * (hx.temperature.outlet.toCelsius)
          + 1.2941 / 1_000 * (hx.temperature.outlet.toCelsius) ** 2
          + 1.23697 / 10 ** 7 * (hx.temperature.outlet.toCelsius) ** 3
          - 0.62677 // kJ/kg
        let bypassMassFlow = totalMassFlow - hx.massFlow
        let bypass_h = 1.51129 * (hx.temperature.inlet.toCelsius)
          + 1.2941 / 1_000 * (hx.temperature.inlet.toCelsius) ** 2
          + 1.23697 / 10 ** 7 * (hx.temperature.inlet.toCelsius) ** 3
          - 0.62677 // kJ/kg
        hx.htoTES = (bypassMassFlow * bypass_h + hx.massFlow * HX_hout)
          / (bypassMassFlow + hx.massFlow)
      }

      hx.temperature.outlet = Temperature((-0.000000000061133
        * HeatExchanger.status.htoTES ** 4 + 0.00000019425
        * HeatExchanger.status.htoTES ** 3 - 0.00032293
        * HeatExchanger.status.htoTES ** 2 + 0.65556
        * HeatExchanger.status.htoTES + 0.58315).toKelvin)
    }
    hx.heatFlow = hx.massFlow * htf.heatTransfered(
      hx.temperature.inlet, hx.temperature.outlet)
      / 1_000 * parameter.efficiency
  }
  
  static func operate(powerBlock: inout PowerBlock.PerformanceData) {
    
    let heatExchanger = HeatExchanger.status
    
    if !parameter.Tout_f_Mfl,
      !parameter.Tout_f_Tin,
      !parameter.useAndsolFunction,
      !parameter.Tout_exp_Tin_Mfl { // old method
      powerBlock.temperature.outlet = Temperature(
        parameter.temperature.htf.outlet.min.value
        + (parameter.temperature.htf.outlet.max
          - parameter.temperature.htf.outlet.min).value
        * (powerBlock.temperature.inlet
          - parameter.temperature.htf.inlet.min).value
        / (parameter.temperature.htf.inlet.max
          - parameter.temperature.htf.inlet.min).value)
      // CHECK: the value of HTFoutTmax should be dependent on storage charging but only on PB HX!
      
    } else if parameter.Tout_exp_Tin_Mfl,
      !parameter.Tout_f_Tin,
      let ToutMassFlow = parameter.ToutMassFlow {
      
      
      powerBlock.temperature.outlet = Temperature(
        parameter.temperature.htf.outlet.min.value
        + (parameter.temperature.htf.outlet.max
          - parameter.temperature.htf.outlet.min).value
        * (powerBlock.temperature.inlet
          - parameter.temperature.htf.inlet.min).value
        / (parameter.temperature.htf.inlet.max
          - parameter.temperature.htf.inlet.min).value)
      
      let massFlowLoad = Ratio(
        powerBlock.massFlow / SolarField.parameter.massFlow.max)
      
      let temperaturFactor = Ratio(ToutMassFlow[massFlowLoad.value])
      
      powerBlock.temperature.outlet.adjust(with: temperaturFactor)
      
    } else if parameter.Tout_f_Mfl && parameter.Tout_f_Tin,
      let ToutMassFlow = parameter.ToutMassFlow,
      let ToutTin = parameter.ToutTin {
      
      let massFlowLoad = Ratio(
        powerBlock.massFlow / SolarField.parameter.massFlow.max)
      
      var temperaturFactor = ToutMassFlow[massFlowLoad.value]
      temperaturFactor *= ToutTin[heatExchanger.temperature.inlet]
      
      powerBlock.temperature.outlet =
        parameter.temperature.htf.outlet.max.adjusted(with: temperaturFactor)
      
    } else if parameter.useAndsolFunction {
      
      let massFlowLoad = Ratio(
        powerBlock.massFlow / SolarField.parameter.massFlow.max)
      
      let temperaturFactor = ((0.0007592419869
        * (powerBlock.temperature.inlet.value
          / parameter.temperature.htf.inlet.max.value)
        * 666 + 0.4943825893223)
        * massFlowLoad.value ** (0.0001400823882
          * (powerBlock.temperature.inlet.value
            / parameter.temperature.htf.inlet.max.value)
          * 666 - 0.0110227028559)) - 0.000151639
      // temperature.inlet changed to (Fluid.parameter.temperature.inlet / parameter.temperature.htf.inlet.max) * 666 because function is based on 393°C temperature.inlet
      
      powerBlock.temperature.outlet = parameter.temperature.htf.outlet.max
        .adjusted(with: setLimits(temperaturFactor))
      
    } else if parameter.Tout_exp_Tin_Mfl,
      let ToutTinMassFlow = parameter.ToutTinMassFlow {
      
      let massFlowLoad = Ratio(powerBlock.massFlow
        / SolarField.parameter.massFlow.max)
      
      let temperaturFactor = ((ToutTinMassFlow[0]
        * (powerBlock.temperature.inlet.value / parameter.temperature.htf.inlet.max.value)
        * 666 + ToutTinMassFlow[1]) * massFlowLoad.value
        ** (ToutTinMassFlow[2] * (powerBlock.temperature.inlet.value
          / parameter.temperature.htf.inlet.max.value)
          * 666 + ToutTinMassFlow[3]))
        + ToutTinMassFlow[4]
      // temperature.inlet changed to (Fluid.parameter.temperature.inlet / parameter.temperature.htf.inlet.max) * 666 because function is based on 393°C temperature.inlet
      
      powerBlock.temperature.outlet = parameter.temperature.htf.outlet.max
        .adjusted(with: setLimits(temperaturFactor))
    } else if let ToutTin = parameter.ToutTin {
      
      let temperaturFactor = Ratio(ToutTin[heatExchanger.temperature.inlet])
      powerBlock.temperature.outlet = Temperature( temperaturFactor.value *
        parameter.temperature.htf.outlet.max.value)
    }
  }
}
