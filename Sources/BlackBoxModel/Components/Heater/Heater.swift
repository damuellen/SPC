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

  /// working conditions of the heater at start
  static let initialState = Heater(
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

  /// Calculates the thermal power and fuel consumption
  mutating func callAsFunction(
    temperatureSolarField: Temperature,
    temperaturePowerBlock: Temperature,
    massFlowStorage: MassFlow,
    modeStorage: Storage.OperationMode,    
    demand: Double, 
    fuelAvailable: Double,
    heat: ThermalEnergy)
    -> EnergyTransfer<Heater>
  {
    let htf = SolarField.parameter.HTF
    let parameter = Heater.parameter
    var fuel = 0.0, thermalPower = 0.0, parasitics = 0.0

    massFlow.rate = massFlow.rate
      .limited(by: parameter.maximumMassFlow)
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
       load.ratio = heat.heater.megaWatt / Design.layout.heater

        guard load.ratio > parameter.minLoad else {
          debugPrint("""
            \(TimeStep.current)
            HR operation requested but not performed because of HR underload.
            """)
          operationMode = .noOperation; load = 0.0; massFlow = 0.0
          thermalPower = 0
          let energy = EnergyTransfer<Heater>(
            heat: thermalPower, electric: parasitics, fuel: fuel
          )
          return energy
        }
        // Normal operation possible -
        operationMode = .normal
        // if Reheating, then do not change displayed operating status / mode
        temperature.outlet = parameter.nominalTemperatureOut

        // Calc. mass flow that can be achieved [kg/sec] = [MJ/sec] * 1000 / [kJ/kg]

        if Design.hasStorage, case .preheat = modeStorage {
          massFlow = massFlowStorage
        } else {
          setMassFlow(rate: thermalPower * 1_000 / htf.deltaHeat(
              temperature.outlet, temperaturePowerBlock
            )
          )
        }
      } else {
        setMassFlow(rate: Design.layout.heater / htf.deltaHeat(
          parameter.nominalTemperatureOut, temperaturePowerBlock)
        )
        fuel = Design.layout.heater / parameter.efficiency
        load = 1.0
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

      load.ratio = heat.heater.megaWatt / Design.layout.heater
      // No operation requested or QProd > QNeed
    } else if case .noOperation = operationMode { /* || heat >= 0 */
      load = 0.0; massFlow = 0.0
      if isMaintained {
        operationMode = .maintenance
      }
      temperature.outlet = temperatureSolarField

      thermalPower = 0
    } else if isMaintained {
      // operation is requested
      debugPrint("""
        \(TimeStep.current)
        Sched. maintnc. of HR disables requested operation.
        """)
      operationMode = .noOperation; load = 0.0; massFlow = 0.0
      operationMode = .maintenance
      thermalPower = 0
    } else {
      // Normal operation requested  The fuel flow needed [MW]
      fuel = max(-demand, Design.layout.heater) / parameter.efficiency
        / Simulation.adjustmentFactor.efficiencyHeater
      // The fuelfl avl. [MW]
      fuel = (fuel * Simulation.time.steps.fraction).limited(by: fuelAvailable)
        / Simulation.time.steps.fraction

      /// net thermal power avail [MW]
      thermalPower = fuel * parameter.efficiency
        * Simulation.adjustmentFactor.efficiencyHeater

      load.ratio = abs(thermalPower / Design.layout.heater) // load avail.

      if load.ratio < parameter.minLoad {
        load.ratio = parameter.minLoad

        thermalPower = load.ratio * Design.layout.heater
        fuel = thermalPower / parameter.efficiency
      }

      // Normal operation possible
      if case .reheat = operationMode {
        operationMode = .normal
      }
      // if Reheating, then do not change displayed operating status / mode
      setTemperature(outlet: parameter.nominalTemperatureOut)
      // Calc. mass flow that can be achieved [kg/sec] = [MJ/sec] * 1000 / [kJ/kg]
      if Design.hasStorage, case .preheat = modeStorage {
        massFlow = massFlowStorage
      } else {
        setMassFlow(rate: thermalPower * 1_000 
          / htf.deltaHeat(self)
        )
      }
    }
    parasitics = Heater.parasitics(estimateFrom: load)
    let energy = EnergyTransfer<Heater>(
      heat: thermalPower, electric: parasitics, fuel: fuel
    )
    return energy
  }
}
