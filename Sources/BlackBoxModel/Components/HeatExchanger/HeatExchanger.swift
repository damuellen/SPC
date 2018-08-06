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
    case let .noOperation(hours): return "No Operation for \(hours) hours"
    case .SI: return "SI"
    case .startUp: return "StartUp"
    case .scheduledMaintenance: return "Scheduled Maintenance"
    case .coldStartUp: return "Cold StartUp"
    case .warmStartUp: return "Warm StartUp"
    }
  }
}

public enum HeatExchanger: Component {
  /// a struct for operation-relevant data of the heat exchanger
  public struct PerformanceData: HeatCycle, CustomStringConvertible {
    var operationMode: OperationMode
    var temperature: (inlet: Temperature, outlet: Temperature)
    var massFlow: MassFlow
    var totalMassFlow, heatIn, heatOut, heatToTES: Double

    public enum OperationMode: Equatable {
      case noOperation(hours: Double), SI, startUp, scheduledMaintenance, coldStartUp, warmStartUp

      public static func == (lhs: OperationMode, rhs: OperationMode) -> Bool {
        switch (lhs, rhs) {
        case let (.noOperation(lhs), noOperation(rhs)): return lhs == rhs
        default: return lhs.rawValue == rhs.rawValue
        }
      }
    }

    public var description: String {
      return "\(operationMode), "
        + String(format: "Mfl: %.1fkg/s, ", massFlow.rate)
        + String(format: "In: %.1f°C, ", temperature.inlet.celsius)
        + String(format: "Out: %.1f°C", temperature.outlet.celsius)
    }
  }

  /// working conditions of the heat exchanger at start
  static let initialState = PerformanceData(
    operationMode: .SI,
    temperature: (inlet: Temperature(celsius: 30.0),
                  outlet: Temperature(celsius: 30.0)),
    massFlow: 0.0,
    totalMassFlow: 0.0,
    heatIn: 0.0,
    heatOut: 0.0,
    heatToTES: 0.0
  )

  static var parameter: Parameter = ParameterDefaults.hx

  static func limit(_ temperatureFactor: Double) -> Double {
    var temperatureFactor = temperatureFactor
    if temperatureFactor > 1.1 { temperatureFactor = 1.1 }
    if temperatureFactor < 0 { temperatureFactor = 0 }
    return temperatureFactor
  }

  public static func update(_ status: inout HeatExchanger.PerformanceData,
                            steamTurbine: SteamTurbine.PerformanceData,
                            storage: Storage.PerformanceData) -> Double {
    let solarField = SolarField.parameter

    if parameter.name.hasPrefix("Heat Exchanger HTF-H2O - BK") {
      status.temperature.outlet = Temperature(
        parameter.temperature.htf.outlet.max.kelvin
          - (120 - 169 * steamTurbine.load.ratio
            + 49 * steamTurbine.load.ratio ** 2)
      )

      if status.temperature.outlet < parameter.temperature.htf.outlet.min {
        status.temperature.outlet = parameter.temperature.htf.outlet.min
      }
    } else {
      if parameter.useAndsolFunction {
        let massFlowLoad = status.massFlow.share(of: solarField.massFlow.max)
        // assert(massFlowLoad > 1) // check how big massflow load can be (5% more than design?)

        // power function based on MAN-Turbo and OHL data with  pinch point tool
        var temperatureFactor = ((0.0007592419869
            * status.temperature.inlet.kelvin + 0.4943825893223)
          * massFlowLoad.ratio ** (0.0001400823882
            * status.temperature.inlet.kelvin - 0.0110227028559)) - 0.000151639

        temperatureFactor = ((0.0007592419869 * (status.temperature.inlet.kelvin
            / parameter.temperature.htf.inlet.max.kelvin) * 666 + 0.4943825893223)
          * massFlowLoad.ratio ** (0.0001400823882 * (status.temperature.inlet.kelvin
              / parameter.temperature.htf.inlet.max.kelvin) * 666 - 0.0110227028559))
          - 0.000151639 // function is based on 393°C Tin

        status.temperature.outlet = Temperature(limit(temperatureFactor) *
          parameter.temperature.htf.outlet.max.kelvin)
      } else {
        switch (parameter.ToutMassFlow, parameter.ToutTin, parameter.ToutTinMassFlow) {
        case let (ToutMassFlow?, ToutTin?, .none):

          let massFlowLoad = status.massFlow.share(of: solarField.massFlow.max)

          var temperatureFactor = ToutMassFlow[massFlowLoad]
          temperatureFactor *= ToutTin[status.temperature.inlet]

          status.temperature.outlet = Temperature(temperatureFactor *
            parameter.temperature.htf.outlet.max.kelvin)

        case let (ToutMassFlow?, .none, .none):
          let temp = parameter.temperature
          status.temperature.outlet = Temperature(temp.htf.outlet.min.kelvin
            + (temp.htf.outlet.max - temp.htf.outlet.min).kelvin
            * (status.temperature.inlet - temp.htf.inlet.min).kelvin
            / (temp.htf.inlet.max - temp.htf.inlet.min).kelvin)

          let massFlowLoad = status.massFlow.share(of: solarField.massFlow.max)

          let temperatureFactor = ToutMassFlow[massFlowLoad]

          status.temperature.outlet = Temperature(status.temperature.outlet.kelvin *
            limit(temperatureFactor))
        case let (_, _, ToutTinMassFlow?):
          let temp = parameter.temperature
          let massFlowLoad = status.massFlow.share(of: solarField.massFlow.max)

          // power function based on MAN-Turbo and OHL data with  pinch point tool
          let temperatureFactor = ((ToutTinMassFlow[0]
              * (status.temperature.inlet.kelvin / temp.htf.inlet.max.kelvin)
              * 666 + ToutTinMassFlow[1])
            * massFlowLoad.ratio ** (ToutTinMassFlow[2]
              * (status.temperature.inlet.kelvin / temp.htf.inlet.max.kelvin)
              * 666 + ToutTinMassFlow[3])) + ToutTinMassFlow[4]

          status.temperature.outlet = temp.htf.outlet.max
            .adjusted(with: limit(temperatureFactor))

        case let (_, ToutTin?, _):

          let temperatureFactor = ToutTin[status.temperature.inlet]

          status.temperature.outlet = parameter.temperature.htf.outlet.max
            .adjusted(with: temperatureFactor)

        default:
          let temp = parameter.temperature
          // CHECK: the value of HTFoutTmax should be dependent on storage charging but only on PB HX
          status.temperature.outlet = Temperature(temp.htf.outlet.min.kelvin
            + (temp.htf.outlet.max - temp.htf.outlet.min).kelvin
            * (status.temperature.inlet.kelvin - temp.htf.inlet.min.kelvin)
            / (temp.htf.inlet.max.kelvin - temp.htf.inlet.min.kelvin))
        }
      }
    }

    if case .discharge = storage.operationMode,
      status.temperature.outlet.kelvin < (261.toKelvin) {
      // added to simulate a bypass on the PB-HX if the expected outlet temp is so low that the salt to TES could freeze
      let totalMassFlow = status.massFlow
      let h_261 = 1.51129 * 261 + 1.2941 / 1_000 * 261 ** 2
        + 1.23697 / 10 ** 7 * 261 ** 3 - 0.62677 // kJ/kg

      for i in 0 ..< 100 where status.heatToTES > h_261 {
        // reduce massflow to PB in 5% every step until enthalpy is
        status.massFlow = MassFlow(totalMassFlow.rate * (1 - (Double(i) / 20)))
        let massFlowLoad = status.massFlow.share(of: solarField.massFlow.max)

        if let ToutMassFlow = parameter.ToutMassFlow,
          let ToutTin = parameter.ToutTin,
          parameter.useAndsolFunction == false {
          var temperatureFactor = ToutMassFlow[massFlowLoad]
          temperatureFactor *= ToutTin[status.temperature.inlet]

          status.temperature.outlet =
            parameter.temperature.htf.outlet.max.adjusted(with: temperatureFactor)
        } else if let ToutMassFlow = parameter.ToutMassFlow,
          parameter.useAndsolFunction == false {
          // if Tout is dependant on massflow, recalculate Tout
          let temperatureFactor = ToutMassFlow[massFlowLoad]

          status.temperature.outlet.adjust(with: temperatureFactor)
        } else if parameter.useAndsolFunction {
          // check how big massflow load can be (5% more than design?)
          let temperatureFactor = ((0.0007592419869
              * (status.temperature.inlet.kelvin / parameter.temperature.htf.inlet.max.kelvin)
              * 666 + 0.4943825893223) * massFlowLoad.ratio ** (0.0001400823882
            * (status.temperature.inlet.kelvin / parameter.temperature.htf.inlet.max.kelvin)
            * 666 - 0.0110227028559)) - 0.000151639

          status.temperature.outlet =
            parameter.temperature.htf.outlet.max.adjusted(with: limit(temperatureFactor))
        } else if let ToutTinMassFlow = parameter.ToutTinMassFlow {
          // power function based on MAN-Turbo and OHL data with pinch point tool
          let temperatureFactor = ((ToutTinMassFlow[0]
              * status.temperature.inlet.kelvin + ToutTinMassFlow[1])
            * massFlowLoad.ratio ** (ToutTinMassFlow[2]
              * status.temperature.inlet.kelvin + ToutTinMassFlow[3]))
            + ToutTinMassFlow[4]

          status.temperature.outlet =
            parameter.temperature.htf.outlet.max.adjusted(with: limit(temperatureFactor))
        }

        status.heatOut = 1.51129 * (status.temperature.outlet.celsius)
          + 1.2941 / 1_000 * (status.temperature.outlet.celsius) ** 2
          + 1.23697 / 10 ** 7 * (status.temperature.outlet.celsius) ** 3
          - 0.62677 // kJ/kg
        let bypassMassFlow = totalMassFlow - status.massFlow
        let bypass_h = 1.51129 * (status.temperature.inlet.celsius)
          + 1.2941 / 1_000 * (status.temperature.inlet.celsius) ** 2
          + 1.23697 / 10 ** 7 * (status.temperature.inlet.celsius) ** 3
          - 0.62677 // kJ/kg
        status.heatToTES = (bypassMassFlow.rate * bypass_h + status.massFlow.rate * status.heatOut)
          / (bypassMassFlow + status.massFlow).rate
      }

      status.temperature.outlet = Temperature((-0.000000000061133
          * status.heatToTES ** 4 + 0.00000019425
          * status.heatToTES ** 3 - 0.00032293
          * status.heatToTES ** 2 + 0.65556
          * status.heatToTES + 0.58315).toKelvin)
    }

    return status.heatTransfered(with: htf) / 1_000 * parameter.efficiency
  }

  static func update(powerBlock: inout PowerBlock.PerformanceData,
                     hx: HeatExchanger.PerformanceData) {
    let solarField = SolarField.parameter

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
            - parameter.temperature.htf.inlet.min).kelvin
      )
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
            - parameter.temperature.htf.inlet.min).kelvin
      )

      let massFlowLoad = powerBlock.massFlow.share(of: solarField.massFlow.max)

      let temperaturFactor = Ratio(ToutMassFlow[massFlowLoad.ratio])

      powerBlock.temperature.outlet.adjust(with: temperaturFactor)
    } else if parameter.Tout_f_Mfl && parameter.Tout_f_Tin,
      let ToutMassFlow = parameter.ToutMassFlow,
      let ToutTin = parameter.ToutTin {
      let massFlowLoad = powerBlock.massFlow.share(of: solarField.massFlow.max)

      var temperaturFactor = ToutMassFlow[massFlowLoad.ratio]
      temperaturFactor *= ToutTin[hx.temperature.inlet]

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

      powerBlock.temperature.outlet = parameter.temperature.htf.outlet.max
        .adjusted(with: limit(temperaturFactor))
    } else if let ToutTin = parameter.ToutTin {
      let temperaturFactor = Ratio(ToutTin[hx.temperature.inlet])
      powerBlock.temperature.outlet =
        parameter.temperature.htf.outlet.max.adjusted(with: temperaturFactor)
    }
  }
}
