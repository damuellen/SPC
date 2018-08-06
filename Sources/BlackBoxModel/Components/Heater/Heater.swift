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

extension Heater.PerformanceData: CustomStringConvertible {
  public var description: String {
    return "\(operationMode), "
      + "Maintenance: \(isMaintained ? "Yes" : "No"), "
      + String(format: "Load: %.1f, ", load.percentage)
      + String(format: "Mfl: %.1fkg/s, ", massFlow.rate)
      + String(format: "In: %.1f°C, ", temperature.inlet.celsius)
      + String(format: "Out: %.1f°C", temperature.outlet.celsius)
  }
}

public enum Heater: Component {
  /// a struct for operation-relevant data of the heater
  public struct PerformanceData: Equatable, HeatCycle {
    var operationMode: OperationMode
    var isMaintained: Bool
    var load: Ratio
    var temperature: (inlet: Temperature, outlet: Temperature)
    var massFlow: MassFlow
    var totalMassFlow: Double

    public enum OperationMode: String, CustomStringConvertible {
      case normal, charge, reheat, freezeProtection,
        noOperation, maintenance, unknown

      public var description: String {
        return rawValue
      }

      var isFreezeProtection: Bool {
        return self ~= .freezeProtection
      }
    }

    public static func == (lhs: PerformanceData, rhs: PerformanceData) -> Bool {
      return lhs.operationMode == rhs.operationMode
        && lhs.isMaintained == rhs.isMaintained
        && lhs.load == rhs.load
        && lhs.temperature == rhs.temperature
        && lhs.massFlow == rhs.massFlow
        && lhs.totalMassFlow == rhs.totalMassFlow
    }
  }

  /// working conditions of the heater at start
  static let initialState = PerformanceData(
    operationMode: .normal,
    isMaintained: false,
    load: 0.0,
    temperature: (inlet: Simulation.initialValues.temperatureOfHTFinPipes,
                  outlet: Simulation.initialValues.temperatureOfHTFinPipes),
    massFlow: 0.0,
    totalMassFlow: 0.0
  )

  static var parameter: Parameter = ParameterDefaults.hr

  /// Calculates the parasitics of the heater which only depends on the current load
  static func parasitics(at load: Ratio) -> Double {
    return parameter.nominalElectricalParasitics *
      (parameter.electricalParasitics[0]
        + parameter.electricalParasitics[1] * load.ratio)
  }

  fileprivate static func noOperation(_ heater: inout Heater.PerformanceData) {
    heater.operationMode = .noOperation
    heater.load = 0.0
    heater.massFlow = 0.0
  }

  static func update(_ status: inout Plant.PerformanceData,
                     demand heat: Double,
                     fuel: Double) {
    // Freeze protection is always possible: massFlow fixed
    if case .charge = status.heater.operationMode {
      // Fossil charge of storage
      if Fuelmode.isPredefined {
        // fuel consumption is predefined
        Plant.fuel.heater = fuel / hourFraction / 2
        // The fuelfl avl. [MW]
        Plant.thermal.heater = Plant.fuel.heater * parameter.efficiency
          * Simulation.adjustmentFactor.efficiencyHeater
        // net thermal power avail [MW]
        status.heater.load = Ratio(Plant.thermal.heater / Design.layout.heater) // load avail.

        guard status.heater.load.ratio > parameter.minLoad else {
          Log.infoMessage("HR operation requested but not performed because of HR underload. \(TimeStep.current)")
          noOperation(&status.heater)
          Plant.thermal.heater = 0
          return
        }
        // Normal operation possible -
        status.heater.operationMode = .normal
        // if Reheating, then do not change displayed operating status / mode
        status.heater.temperature.outlet = parameter.nominalTemperatureOut

        // Calc. mass flow that can be achieved [kg/sec] = [MJ/sec] * 1000 / [kJ/kg]

        if Design.hasStorage, case .preheat = status.storage.operationMode {
          status.heater.massFlow = status.storage.massFlow
        } else {
          status.heater.massFlow = MassFlow(Plant.thermal.heater * 1_000
            / htf.heatDelta(status.heater.temperature.outlet,
                            status.powerBlock.temperature.inlet))
        }
      } else {
        if status.powerBlock.temperature.inlet == parameter.nominalTemperatureOut {
          status.powerBlock.temperature.inlet = -1.0 // FIXME:
        }
        status.heater.massFlow = MassFlow(Design.layout.heater
          / htf.heatDelta(parameter.nominalTemperatureOut,
                          status.powerBlock.temperature.inlet))

        Plant.fuel.heater = Design.layout.heater / parameter.efficiency
        status.heater.load = 1.0
        // Parasitic power [MW]
        Plant.thermal.heater = Design.layout.heater
        // return
      }
    } else if case .freezeProtection = status.heater.operationMode {
      Plant.thermal.heater = status.heater.massFlow.rate * htf.heatDelta(
        parameter.antiFreezeTemperature, status.heater.temperature.inlet
      ) / 1_000

      if Plant.thermal.heater > Design.layout.heater {
        Plant.thermal.heater = Design.layout.heater
        if status.heater.massFlow.rate > 0 {
          status.heater.temperature.outlet = htf.temperatureDelta(
            Plant.thermal.heater * 1_000 / status.heater.massFlow.rate,
            status.heater.temperature.inlet
          )
        }
      } else {
        status.heater.temperature.outlet = parameter.antiFreezeTemperature
      }
      Plant.fuel.heater = Plant.thermal.heater / parameter.efficiency
      status.heater.load = Ratio(Plant.thermal.heater / Design.layout.heater)
      // No operation requested or QProd > QNeed
    } else if case .noOperation = status.heater.operationMode { /* || heat >= 0 */
      noOperation(&status.heater)
      if status.heater.isMaintained {
        status.heater.operationMode = .maintenance
      }
      status.heater.temperature.outlet = status.solarField.header.temperature.outlet
      Plant.thermal.heater = 0
    } else if status.heater.isMaintained {
      // operation is requested
      Log.infoMessage("Sched. maintnc. of HR disables requested operation. \(TimeStep.current)")
      self.noOperation(&status.heater)
      status.heater.operationMode = .maintenance
      Plant.thermal.heater = 0
    } else {
      // Normal operation requested  The fuel flow needed [MW]
      let heat = heat < Design.layout.heater ? heat : -Design.layout.heater
      Plant.fuel.heater = heat / parameter.efficiency
        / Simulation.adjustmentFactor.efficiencyHeater
      // The fuelfl avl. [MW]
      let fuel = min(fuel, Plant.fuel.heater * hourFraction) / hourFraction

      Plant.fuel.heater = max(fuel, Design.layout.heater)
      // net thermal power avail [MW]
      Plant.thermal.heater = Plant.fuel.heater * parameter.efficiency
        * Simulation.adjustmentFactor.efficiencyHeater

      status.heater.load = Ratio(abs(Plant.thermal.heater / Design.layout.heater)) // load avail.

      if status.heater.load.ratio < parameter.minLoad {
        status.heater.load = Ratio(parameter.minLoad)
        Plant.thermal.heater = status.heater.load.ratio * Design.layout.heater
        Plant.fuel.heater = Plant.thermal.heater / parameter.efficiency
      }

      // Normal operation possible
      if case .reheat = status.heater.operationMode {
        status.heater.operationMode = .normal
      }
      // if Reheating, then do not change displayed operating status / mode
      status.heater.temperature.outlet = parameter.nominalTemperatureOut
      // Calc. mass flow that can be achieved [kg/sec] = [MJ/sec] * 1000 / [kJ/kg]
      if Design.hasStorage, case .preheat = status.storage.operationMode {
        status.heater.massFlow = status.storage.massFlow
      } else {
        status.heater.massFlow = MassFlow((Plant.thermal.heater * 1_000
            / htf.heatDelta(status.heater.temperature.outlet,
                            status.heater.temperature.inlet)))
      }
    }
    self.noOperation(&status.heater)
  }
}
