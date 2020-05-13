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

public struct Heater: Component, HeatCycle {
  /// Contains all data needed to simulate the operation of the heater

  var operationMode: OperationMode

  var cycle: HeatTransfer = .init(name: Heater.parameter.name)

  public enum OperationMode {
    case normal(Ratio), charge(Ratio), reheat, freezeProtection(Ratio),
      noOperation, maintenance, unknown

    var isFreezeProtection: Bool {
      if case .freezeProtection(_) = self { return true }
      return false
    }
    
    var load: Ratio {
      switch self {
      case let .normal(load),let .charge(load),let .freezeProtection(load):
        return load
      default:
        return .zero
      }
    }
  }
  /// working conditions of the heater at start
  static let initialState = Heater(operationMode: .noOperation)

  public static var parameter: Parameter = ParameterDefaults.hr

  /// Calculates the parasitics of the heater which only depends on the current load
  static func parasitics(estimateFrom load: Ratio) -> Double {
    return parameter.nominalElectricalParasitics *
      (parameter.electricalParasitics[0]
        + parameter.electricalParasitics[1] * load.ratio)
  }

  /// Calculates the thermal power and fuel consumption
  mutating func callAsFunction(
    temperatureOutlet: Temperature,
    temperatureInlet: Temperature,
    massFlowStorage: MassFlow,
    modeStorage: Storage.OperationMode,    
    demand: Double, 
    fuelAvailable: Double,
    heat: ThermalEnergy)
    -> EnergyTransfer<Heater>
  {
    let htf = SolarField.parameter.HTF
    let parameter = Heater.parameter
    var fuel = 0.0, thermalPower = 0.0, parasitics = 0.0, load = 0.0
    massFlow.rate = min(massFlow.rate, parameter.maximumMassFlow)
    // Freeze protection is always possible: massFlow fixed
    if case .charge = operationMode {
      // Fossil charge of storage
      if OperationRestriction.fuelStrategy.isPredefined {
        // fuel consumption is predefined
        fuel = fuelAvailable / Simulation.time.steps.fraction / 2
        // The fuelfl avl. [MW]
        thermalPower = fuel * parameter.efficiency
          * Simulation.adjustmentFactor.efficiencyHeater
        // net thermal power avail [MW]
        load = heat.heater.megaWatt / Design.layout.heater
        operationMode = .normal(Ratio(load))

        guard load > parameter.minLoad else {
          debugPrint("""
            \(TimeStep.current)
            HR operation requested but not performed because of HR underload.
            """)
          operationMode = .noOperation; massFlow = 0.0
          thermalPower = 0
          let energy = EnergyTransfer<Heater>(
            heat: thermalPower, electric: parasitics, fuel: fuel
          )
          return energy
        }
        // Normal operation possible -
        
        // if Reheating, then do not change displayed operating status / mode
        temperature.outlet = parameter.nominalTemperatureOut

        // Calc. mass flow that can be achieved [kg/sec] = [MJ/sec] * 1000 / [kJ/kg]

        if Design.hasStorage, case .preheat = modeStorage {
          massFlow = massFlowStorage
        } else {
          setMassFlow(rate: thermalPower * 1_000
            / htf.deltaHeat(temperature.outlet, temperatureInlet)
          )
        }
      } else {
        setMassFlow(rate: Design.layout.heater / htf.deltaHeat(
          parameter.nominalTemperatureOut, temperatureInlet)
        )
        fuel = Design.layout.heater / parameter.efficiency
        load = 1
        operationMode = .charge(Ratio(load))
        // Parasitic power [MW]
        thermalPower = Design.layout.heater
        // return
      }
    } else if case .freezeProtection = operationMode {
      thermalPower = massFlow.rate * htf.deltaHeat(
        parameter.antiFreezeTemperature, temperature.inlet
      ) / 1_000

      if thermalPower > Design.layout.heater {
        thermalPower = Design.layout.heater
        if massFlow.rate > 0 {
          temperature.outlet = htf.temperature(
            abs(thermalPower) * 1_000 / massFlow.rate,
            temperature.inlet
          )
        }
      } else {
        temperature.outlet = parameter.antiFreezeTemperature
      }
      thermalPower = heat.heater.megaWatt / parameter.efficiency

      load = heat.heater.megaWatt / Design.layout.heater
      operationMode = .freezeProtection(Ratio(load))
      // No operation requested or QProd > QNeed
    } else if case .noOperation = operationMode { /* || heat >= 0 */
      massFlow = 0.0
    //  if isMaintained {
     //   operationMode = .maintenance
    //  }
      temperature.outlet = temperatureOutlet

      thermalPower = 0
    } else if case .maintenance = operationMode {
      // operation is requested
      debugPrint("""
        \(TimeStep.current)
        Sched. maintnc. of HR disables requested operation.
        """)
      operationMode = .noOperation
      massFlow = 0.0
      operationMode = .maintenance
      thermalPower = 0
    } else {
      // Normal operation requested  The fuel flow needed [MW]
      fuel = max(-demand, Design.layout.heater) / parameter.efficiency
        / Simulation.adjustmentFactor.efficiencyHeater
      // The fuelfl avl. [MW]
      fuel = min(fuel * Simulation.time.steps.fraction, fuelAvailable)
        / Simulation.time.steps.fraction

      /// net thermal power avail [MW]
      thermalPower = fuel * parameter.efficiency
        * Simulation.adjustmentFactor.efficiencyHeater

      load = abs(thermalPower / Design.layout.heater) // load avail.

      if load < parameter.minLoad {
        load = parameter.minLoad
        thermalPower = load * Design.layout.heater
        fuel = thermalPower / parameter.efficiency
      }

      // Normal operation possible
      if case .reheat = operationMode {
        operationMode = .normal(Ratio(load))
      }
      // if Reheating, then do not change displayed operating status / mode
      setTemperature(outlet: parameter.nominalTemperatureOut)
      // Calc. mass flow that can be achieved [kg/sec] = [MJ/sec] * 1000 / [kJ/kg]
      if Design.hasStorage, case .preheat = modeStorage {
        massFlow = massFlowStorage
      } else {
        setMassFlow(rate: thermalPower * 1_000 / deltaHeat)
      }
    }
    parasitics = Heater.parasitics(estimateFrom: Ratio(load))
    let energy = EnergyTransfer<Heater>(
      heat: thermalPower, electric: parasitics, fuel: fuel
    )
    return energy
  }
}
