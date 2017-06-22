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

extension Heater.Instance: CustomDebugStringConvertible {
  var debugDescription: String { return "\(workingConditions.current)" }
}

public enum Heater: Model {
  
  final class Instance {
    // A singleton class holding the state of the heater
    static let shared = Instance()
    var parameter: Heater.Parameter!
    var workingConditions: (previous: PerformanceData?, current: PerformanceData)
    
    private init() {
      workingConditions = (nil, initialState)
    }
  }

  /// a struct for operation-relevant data of the heater
  public struct PerformanceData: MassFlow {
    var operationMode: OperationMode
    var isMaintained: Bool
    var load: Ratio
    var heatFlow: Double
    var temperature: (inlet: Double, outlet: Double)
    var massFlow, totalMassFlow, hin: Double

    public enum OperationMode {
      case normal, charge, reheat, freezeProtection, noOperation, maintenance, unknown
    }
  }

  /// working conditions of the heater at start
  fileprivate static let initialState = PerformanceData(
    operationMode: .noOperation,
    isMaintained: false,
    load: 0.0,
    heatFlow: 0.0,
    temperature: (200, 200),
    massFlow: 0.0,
    totalMassFlow: 0.0,
    hin: 0.0)

  /// Returns the current working conditions of the heater
  public static var status: PerformanceData {
    get { return Instance.shared.workingConditions.current }
    set {
      Instance.shared.workingConditions =
       (Instance.shared.workingConditions.current, newValue) 
    }
  }

  /// Returns the previous working conditions of the heater
  private static var previous: PerformanceData? {
    return Instance.shared.workingConditions.previous
  }

  public static var parameter: Heater.Parameter {
    get { return Instance.shared.parameter }
    set { Instance.shared.parameter = newValue }
  }

  public static var parasitics: Double { return parasitics(at: status.load) }

  /// Calculates the parasitics of the heater which only depends on the current load
  private static func parasitics(at load: Ratio) -> Double {
    return parameter.nominalElectricalParasitics *
      (parameter.electricalParasitics[0] + parameter.electricalParasitics[1] * load.value)
  }

  fileprivate static func noOperation(_ heater: inout Heater.PerformanceData) {
    heater.operationMode = .noOperation
    heater.load = 0.0
    heater.massFlow = 0.0
  }
  
  public static func operate(demand heat: Double,
                             availableFuel: Double,
                             fuelFlow: inout Double) -> Double {
    // Freeze protection is always possible: massFlow fixed
    var heater = status
    defer { status = heater }
    if case .charge = heater.operationMode {
      // Fossil charge of storage

      if Fuelmode == "predefined" {
        // fuel consumption is predefined
        fuelFlow = availableFuel / hourFraction / 2
        // The fuelfl avl. [MW]
        heater.heatFlow = fuelFlow * parameter.efficiency // * Simulation.parameter.AdjEffHR
        // net thermal power avail [MW]
        heater.load = Ratio(heater.heatFlow / Design.layout.heater) // load avail.

        guard heater.load.value > parameter.minLoad else {
          ////report = "HR operation requested but not performed because of HR underload.\n"
          noOperation(&heater)
          return 0
        }

        // Normal operation possible -
        
        heater.operationMode = .normal
        // if Reheating, then do not change displayed operating status / mode
        heater.temperature.outlet = parameter.nomTemperatureOut

        // Calc. mass flow that can be achieved [kg/sec] = [MJ/sec] * 1000 / [kJ/kg]

        if Design.hasStorage, case .ph = Storage.status.operationMode {
          heater.massFlow = Storage.status.massFlow
        } else {
          heater.massFlow = heater.heatFlow * 1_000
            / htf.heatTransfered(heater.temperature.outlet,
                                 PowerBlock.status.temperature.inlet)
        }
      } else {
        if PowerBlock.status.temperature.inlet == parameter.nomTemperatureOut {
          PowerBlock.status.temperature.inlet = -1 // FIXME
        }

        heater.massFlow = Design.layout.heater
          / htf.heatTransfered(parameter.nomTemperatureOut,
                               PowerBlock.status.temperature.inlet)

        fuelFlow = Design.layout.heater / parameter.efficiency
        heater.load = 1.0
        // Parasitic power [MW]

        heater.heatFlow = Design.layout.heater
        // return
      }
    } else if case .freezeProtection = heater.operationMode {
      heater.heatFlow = heater.massFlow * htf.heatTransfered(
        parameter.antiFreezeTemperature, heater.temperature.inlet) / 1_000

      if heater.heatFlow > Design.layout.heater {
        heater.heatFlow = Design.layout.heater
        heater.temperature.outlet = htf.temperature(
          heater.heatFlow * 1_000 / heater.massFlow, heater.temperature.inlet)
      } else {
        heater.temperature.outlet = parameter.antiFreezeTemperature
      }
      // [MW]=[kg/sec]*[kJ/kg]/1000
      fuelFlow = heater.heatFlow / parameter.efficiency
      heater.load = Ratio(heater.heatFlow / Design.layout.heater)

      // return

      // No operation requested or QProd > QNeed
    } else if case .noOperation = heater.operationMode { /* || heat >= 0 */
      noOperation(&heater)
      if heater.isMaintained {
        heater.operationMode = .maintenance
      }
      heater.temperature.outlet = SolarField.status.temperature.outlet
      return 0
    } else if heater.isMaintained {
      // operation is requested
      ////report = "Sched. maintnc. of HR disables requested operation.\n"
      noOperation(&heater)
      heater.operationMode = .maintenance
      return 0
    } else {
      // Normal operation requested  The fuel flow needed [MW]
      fuelFlow = min(-heat, Design.layout.heater) / parameter.efficiency
        / Simulation.parameter.adjustmentFactor.efficiencyHeater
      // The fuelfl avl. [MW]
      fuelFlow = min(availableFuel, fuelFlow * hourFraction) / hourFraction
      // net thermal power avail [MW]
      heater.heatFlow = fuelFlow * parameter.efficiency
        * Simulation.parameter.adjustmentFactor.efficiencyHeater
      heater.load = Ratio(heater.heatFlow / Design.layout.heater) // load avail.

      // if heateroperationMode { // added, shams-1
      if heater.load.value < parameter.minLoad {
        heater.load = Ratio(parameter.minLoad)
        heater.heatFlow = heater.load.value * Design.layout.heater
        fuelFlow = heater.heatFlow / parameter.efficiency
      }
      // }

      guard heater.load.value > parameter.minLoad else {
        // ////report = "HR operation requested but not performed because of HR underload.\n"
        noOperation(&heater)
        return 0
      }

      // Normal operation possible
      if case .reheat = heater.operationMode {
        heater.operationMode = .normal
      }
      // if Reheating, then do not change displayed operating status / mode
      heater.temperature.outlet = parameter.nomTemperatureOut
      // Calc. mass flow that can be achieved [kg/sec] = [MJ/sec] * 1000 / [kJ/kg]

      if Design.hasStorage, case .ph = Storage.status.operationMode {
        heater.massFlow = Storage.status.massFlow
      } else {
        heater.massFlow = heater.heatFlow * 1_000
          / htf.heatTransfered(heater.temperature.outlet,
                               heater.temperature.inlet)
      }
      return (heater.heatFlow)
    }
    noOperation(&heater)
    return 0
  }
}
