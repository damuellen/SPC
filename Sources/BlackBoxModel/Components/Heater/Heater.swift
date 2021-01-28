//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import DateGenerator
/// Contains all data needed to simulate the operation of the heater
public struct Heater: Parameterizable, HeatTransfer {  

  var name: String = Heater.parameter.name

  var massFlow: MassFlow = .zero
  
  var temperature: (inlet: Temperature, outlet: Temperature)
  
  var operationMode: OperationMode

  public enum OperationMode {
    case normal(Ratio)
    case charge(Ratio)
    case reheat
    case freezeProtection(Ratio)
    case
      noOperation, maintenance, unknown

    var isFreezeProtection: Bool {
      if case .freezeProtection(_) = self { return true }
      return false
    }

    var load: Ratio {
      switch self {
      case let .normal(load), let .charge(load), let .freezeProtection(load):
        return load
      default:
        return .zero
      }
    }
  }
  /// working conditions of the heater at start
  static let initialState = Heater(
    temperature: Simulation.startTemperature,
    operationMode: .noOperation
  )

  public static var parameter: Parameter = ParameterDefaults.hr

  /// Returns the parasitics of the heater.
  /// - Parameter load: Depends on the current load.
  /// - Returns: Electric parasitics in MW
  static func parasitics(estimateFrom load: Ratio) -> Double {
    parameter.nominalElectricalParasitics
      * (parameter.electricalParasitics[0]
        + parameter.electricalParasitics[1] * load.quotient)
  }

  mutating func massFlow(from c: HeatTransfer) {
     massFlow.rate = min(c.massFlow.rate, Heater.parameter.maximumMassFlow)
  }

  /// Calculates the thermal power and fuel consumption
  mutating func callAsFunction(
    storage: MassFlow,
    mode: Storage.OperationMode,
    demand: Double,
    fuelAvailable: Double,
    heat: ThermalPower
  )
    -> PerformanceData<Heater>
  {
    let htf = SolarField.parameter.HTF
    let parameter = Heater.parameter
    var fuel = 0.0
    var thermalPower = Power()
    var parasitics = 0.0
    var load = Ratio(1.0)

    // Freeze protection is always possible: massFlow fixed
    if case .charge = operationMode {
      // Fossil charge of storage
      if OperationRestriction.fuelStrategy.isPredefined {
        // fuel consumption is predefined
        fuel = fuelAvailable / Simulation.time.steps.fraction / 2
        // The fuelfl avl. [MW]
        thermalPower.megaWatt =
          fuel * parameter.efficiency.quotient
          * Simulation.adjustmentFactor.efficiencyHeater
        // net thermal power avail [MW]
        load = Ratio(heat.heater.megaWatt / Design.layout.heater)
        operationMode = .normal(load)

        guard load > parameter.minLoad else {
          debugPrint(
            """
            \(DateTime.current)
            HR operation requested but not performed because of HR underload.
            """)
          operationMode = .noOperation
          massFlow = 0.0
          thermalPower = .zero
          let energy = PerformanceData<Heater>(
            heat: thermalPower.megaWatt, electric: parasitics, fuel: fuel
          )
          return energy
        }
        // Normal operation possible -

        // if Reheating, then do not change displayed operating status / mode
        temperature.outlet = parameter.nominalTemperatureOut

        // Calc. mass flow that can be achieved [kg/sec] = [MJ/sec] * 1000 / [kJ/kg]
        if Design.hasStorage, case .preheat = mode {
          massFlow = storage
        } else {
          massFlow.rate = thermalPower.kiloWatt
            / htf.deltaHeat(temperature.outlet, temperature.inlet)
        }
      } else {
        massFlow.rate = Design.layout.heater
          / htf.deltaHeat(parameter.nominalTemperatureOut, temperature.inlet)
        
        fuel = Design.layout.heater / parameter.efficiency.quotient
        load = Ratio(1)
        operationMode = .charge(load)
        // Parasitic power [MW]
        thermalPower.megaWatt = Design.layout.heater
        // return
      }
    } else if case .freezeProtection = operationMode {
      thermalPower.kiloWatt =
        massFlow.rate * htf.deltaHeat(
          parameter.antiFreezeTemperature, temperature.inlet
        ) 

      if thermalPower.megaWatt > Design.layout.heater {
        thermalPower = Power(megaWatt: Design.layout.heater)
        if massFlow.rate > 0 {
          temperature.outlet = htf.temperature(
            thermalPower.kiloWatt / massFlow.rate,
            temperature.inlet
          )
        }
      } else {
        temperature.outlet = parameter.antiFreezeTemperature
      }
      thermalPower.watt /= parameter.efficiency.quotient

      load = Ratio(min(thermalPower.megaWatt / Design.layout.heater, 1.0))
      operationMode = .freezeProtection(load)
      // No operation requested or QProd > QNeed
    } else if case .noOperation = operationMode { /* || heat >= 0 */
      massFlow = .zero
      //  if isMaintained {
      //   operationMode = .maintenance
      //  }
      outletTemperatureFromInlet()
      thermalPower = .zero
    } else if case .maintenance = operationMode {
      // operation is requested
      debugPrint(
        """
        \(DateTime.current)
        Sched. maintnc. of HR disables requested operation.
        """)
      operationMode = .noOperation
      massFlow = .zero
      outletTemperatureFromInlet()
      thermalPower = .zero
    } else {
      // Normal operation requested  The fuel flow needed [MW]
      fuel =
        max(-demand, Design.layout.heater) / parameter.efficiency.quotient
        / Simulation.adjustmentFactor.efficiencyHeater
      // The fuelfl avl. [MW]
      fuel =
        min(fuel * Simulation.time.steps.fraction, fuelAvailable)
        / Simulation.time.steps.fraction

      /// net thermal power avail [MW]
      thermalPower.megaWatt =
        fuel * parameter.efficiency.quotient
        * Simulation.adjustmentFactor.efficiencyHeater

      load = Ratio(min(thermalPower.megaWatt / Design.layout.heater, 1.0))  // load avail.

      if load < parameter.minLoad {
        load = parameter.minLoad
        thermalPower.megaWatt = load.quotient * Design.layout.heater
        fuel = thermalPower.megaWatt / parameter.efficiency.quotient
      }

      // Normal operation possible
      if case .reheat = operationMode {
        operationMode = .normal(load)
      }
      // if Reheating, then do not change displayed operating status / mode
      setTemperature(outlet: parameter.nominalTemperatureOut)
      // Calc. mass flow that can be achieved [kg/sec] = [MJ/sec] * 1000 / [kJ/kg]
      if Design.hasStorage, case .preheat = mode {
        massFlow = storage
      } else {
        massFlow.rate = thermalPower.kiloWatt / deltaHeat
      }
    }
    parasitics = load > .zero ? Heater.parasitics(estimateFrom: load) : 0
    let energy = PerformanceData<Heater>(
      heat: thermalPower.megaWatt, electric: parasitics, fuel: fuel
    )
    return energy
  }
}

extension Heater.OperationMode: RawRepresentable {
  public typealias RawValue = String

  public init?(rawValue: RawValue) {
    switch rawValue {
    case "normal(Ratio)": self = .normal(.zero)
    case "charge(Ratio)": self = .normal(.zero)
    case "reheat": self = .reheat
    case "freezeProtection(Ratio)": self = .freezeProtection(.zero)
    case "No Operation": self = .noOperation
    case "Scheduled Maintenance": self = .maintenance
    case "Unknown":  self = .unknown
    default: return nil
    }
  }

  public var rawValue: RawValue {
    switch self {
    case .normal(let load): return "Normal with load: \(load.percentage)"
    case .charge(let load): return "Charge with load: \(load.percentage)"
    case .reheat: return "Reheat"
    case .freezeProtection(let load): return "Freeze protection with load: \(load.percentage)"
    case .noOperation: return "No Operation"
    case .maintenance: return "Scheduled Maintenance"
    case .unknown: return "Unknown"
    }
  }
}
