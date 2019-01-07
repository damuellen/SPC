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

public enum Heater: Component {
  /// Contains all data needed to simulate the operation of the heater
  public struct PerformanceData: Equatable, HeatCycle, CustomStringConvertible {

    var operationMode: OperationMode

    var isMaintained: Bool

    var load: Ratio

    var temperature: (inlet: Temperature, outlet: Temperature) 

    var massFlow: MassFlow

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
    }
    
    public var description: String {
      return "\(operationMode), "
        + "Maintenance: \(isMaintained ? "Yes" : "No"), "
        + String(format: "Load: %.1f, ", load.percentage)
        + String(format: "Mfl: %.1fkg/s, ", massFlow.rate)
        + String(format: "Tin: %.1f°C, ", temperature.inlet.celsius)
        + String(format: "Tout: %.1f°C", temperature.outlet.celsius)
    }
  }

  /// working conditions of the heater at start
  static let initialState = PerformanceData(
    operationMode: .noOperation,
    isMaintained: false,
    load: 0.0,
    temperature: (inlet: Simulation.initialValues.temperatureOfHTFinPipes,
                  outlet: Simulation.initialValues.temperatureOfHTFinPipes),
    massFlow: 0.0
  )

  public static var parameter: Parameter = ParameterDefaults.hr

  /// Calculates the parasitics of the heater which only depends on the current load
  static func parasitics(estimateFrom load: Ratio) -> Double {
    return parameter.nominalElectricalParasitics *
      (parameter.electricalParasitics[0]
        + parameter.electricalParasitics[1] * load.ratio)
  }

  fileprivate static func noOperation(_ heater: inout Heater.PerformanceData) {
    heater.operationMode = .noOperation
    heater.load = 0.0
    heater.massFlow = 0.0
  }
  /// Calculates the thermal power and fuel consumption
  static func update(_ status: Plant.PerformanceData,
                     demand: Double,
                     fuelAvailable: Double,
                     result: (Status<PerformanceData>) -> ())
  {
    let htf = SolarField.parameter.HTF,
    powerBlock = status.powerBlock,
    storage = status.storage,
    solarField = status.solarField

    var heater = status.heater
    
    var fuel = 0.0, thermalPower = 0.0, parasitics = 0.0

    heater.massFlow.rate = heater.massFlow.rate
      .limited(by: parameter.maximumMassFlow)
    // Freeze protection is always possible: massFlow fixed
    if case .charge = heater.operationMode {
      // Fossil charge of storage
      if Fuelmode.isPredefined {
        // fuel consumption is predefined
        fuel = fuelAvailable / hourFraction / 2
        // The fuelfl avl. [MW]
        thermalPower = fuel * parameter.efficiency
          * Simulation.adjustmentFactor.efficiencyHeater
        // net thermal power avail [MW]
        heater.load.ratio = Plant.heat.heater.megaWatt / Design.layout.heater

        guard heater.load.ratio > parameter.minLoad else {
          💬.infoMessage("""
            \(TimeStep.current)
            HR operation requested but not performed because of HR underload.
            """)
          noOperation(&heater)
          thermalPower = 0
          result((thermalPower, demand, parasitics, fuel, heater))
          return
        }
        // Normal operation possible -
        heater.operationMode = .normal
        // if Reheating, then do not change displayed operating status / mode
        heater.temperature.outlet = parameter.nominalTemperatureOut

        // Calc. mass flow that can be achieved [kg/sec] = [MJ/sec] * 1000 / [kJ/kg]

        if Design.hasStorage, case .preheat = storage.operationMode {
          heater.massFlow = storage.massFlow
        } else {
          heater.massFlow(rate: thermalPower * 1_000 / htf.deltaHeat(
              heater.temperature.outlet, powerBlock.temperature.inlet
            )
          )
        }
      } else {
        heater.massFlow(rate:
          Design.layout.heater / htf.deltaHeat(
            parameter.nominalTemperatureOut,
            powerBlock.temperature.inlet
          )
        )
        fuel = Design.layout.heater / parameter.efficiency
        heater.load = 1.0
        // Parasitic power [MW]
        thermalPower = Design.layout.heater
        // return
      }
    } else if case .freezeProtection = heater.operationMode {
      thermalPower = heater.massFlow.rate * htf.deltaHeat(
        parameter.antiFreezeTemperature, heater.temperature.inlet
      ) / 1_000

      if thermalPower > Design.layout.heater {
        thermalPower = Design.layout.heater
        if heater.massFlow.rate > 0 {
          heater.temperature.outlet = htf.temperature(
            abs(thermalPower) * 1_000 / heater.massFlow.rate,
            heater.temperature.inlet
          )
        }
      } else {
        heater.temperature.outlet = parameter.antiFreezeTemperature
      }
      thermalPower = Plant.heat.heater.megaWatt / parameter.efficiency

      heater.load.ratio = Plant.heat.heater.megaWatt / Design.layout.heater
      // No operation requested or QProd > QNeed
    } else if case .noOperation = heater.operationMode { /* || heat >= 0 */
      noOperation(&heater)
      if heater.isMaintained {
        heater.operationMode = .maintenance
      }
      heater.setTemperature(outlet:
        solarField.header.temperature.outlet
      )
      thermalPower = 0
    } else if heater.isMaintained {
      // operation is requested
      💬.infoMessage("""
        \(TimeStep.current)
        Sched. maintnc. of HR disables requested operation.
        """)
      self.noOperation(&heater)
      heater.operationMode = .maintenance
      thermalPower = 0
    } else {
      // Normal operation requested  The fuel flow needed [MW]
      fuel = max(-demand, Design.layout.heater) / parameter.efficiency
        / Simulation.adjustmentFactor.efficiencyHeater
      // The fuelfl avl. [MW]
      fuel = (fuel * hourFraction).limited(by: fuelAvailable) / hourFraction

      /// net thermal power avail [MW]
      thermalPower = fuel * parameter.efficiency
        * Simulation.adjustmentFactor.efficiencyHeater

      heater.load.ratio = abs(thermalPower / Design.layout.heater) // load avail.

      if heater.load.ratio < parameter.minLoad {
        heater.load.ratio = parameter.minLoad

        thermalPower = heater.load.ratio * Design.layout.heater
        fuel = thermalPower / parameter.efficiency
      }

      // Normal operation possible
      if case .reheat = heater.operationMode {
        heater.operationMode = .normal
      }
      // if Reheating, then do not change displayed operating status / mode
      heater.setTemperature(outlet: parameter.nominalTemperatureOut)
      // Calc. mass flow that can be achieved [kg/sec] = [MJ/sec] * 1000 / [kJ/kg]
      if Design.hasStorage, case .preheat = storage.operationMode {
        heater.massFlow = storage.massFlow
      } else {
        heater.massFlow(rate: thermalPower * 1_000 
          / htf.deltaHeat(heater.temperature.outlet, heater.temperature.inlet)
        )
      }
    }
    parasitics = self.parasitics(estimateFrom: heater.load)
    
    result((thermalPower, demand, parasitics, fuel, heater))
  }
}
