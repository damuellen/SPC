//
//  Copyright 2023 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import DateExtensions
import Units

extension Heater: CustomStringConvertible {  
  public var description: String {
    "  Mode:".padding(30) + "\(operationMode)\n" + "\(self.cycle)"
  }
}

/// A struct representing the heater component with state and functions for mapping the heater.
public struct Heater: Parameterizable, HeatTransfer {

  /// The name of the heater.
  var name: String = Heater.parameter.name

  /// The mass flow rate of the heater.
  public internal(set) var massFlow: MassFlow = .zero

  /// The temperature at the inlet and outlet of the heater.
  public internal(set) var temperature: (inlet: Temperature, outlet: Temperature)

  /// The current operating mode of the heater.
  public internal(set) var operationMode: OperationMode

  /// The possible operating modes of the heater.
  public enum OperationMode {
    case normal(Ratio)
    case charge(Ratio)
    case reheat
    case freezeProtection(Ratio)
    case noOperation
    case maintenance
    case unknown

    /// Checks if the operation mode represents freeze protection.
    var isFreezeProtection: Bool {
      if case .freezeProtection(_) = self { return true }
      return false
    }

    /// Returns the load applied in the current operating mode.
    var load: Ratio {
      switch self {
      case let .normal(load), let .charge(load), let .freezeProtection(load):
        return load
      default:
        return .zero
      }
    }
  }

  /// A structure to store heater consumptions.
  struct Consumptions {
    var heatFlow, electric, fuel: Double
  }

  /// The initial state of the heater at startup.
  static let initialState = Heater(
    temperature: Simulation.startTemperature,
    operationMode: .noOperation
  )

  /// The parameter settings for the heater.
  public static var parameter: Parameter = Parameters.hr

  /// Returns the electric parasitics of the heater based on the load.
  ///
  /// - Parameter load: The load at which to estimate the parasitics.
  /// - Returns: The electric parasitics in MW.
  static func parasitics(estimateFrom load: Ratio) -> Double {
    parameter.nominalElectricalParasitics
      * (parameter.electricalParasitics[0]
        + parameter.electricalParasitics[1] * load.quotient)
  }

  /// Updates the mass flow based on the heat transfer component.
  ///
  /// - Parameter c: The heat transfer component.
  mutating func massFlow(from c: HeatTransfer) {
     massFlow.rate = min(c.massFlow.rate, Heater.parameter.maximumMassFlow)
  }

  /// Calculates the thermal power and fuel consumption of the heater based on the given parameters.
  ///
  /// - Parameters:
  ///   - storage: The mass flow rate of the storage component.
  ///   - mode: The operation mode of the storage component.
  ///   - heatFlow: The thermal energy data for the heater.
  /// - Returns: A `Heater.Consumptions` object containing the thermal power, electric parasitics, and fuel consumption.
  mutating func callAsFunction(
    storage: MassFlow,
    mode: Storage.OperationMode,
    heatFlow: ThermalEnergy
  )
    -> Heater.Consumptions
  {
    let htf = SolarField.parameter.HTF
    let parameter = Heater.parameter
    var fuel = 0.0
    var thermalPower = Power()
    var parasitics = 0.0
    var load = Ratio(1.0)

    // Handle freeze protection mode: mass flow is fixed
    if case .charge = operationMode {
      // Fossil charge of storage
      if OperationRestriction.fuelStrategy.isPredefined {
        // Fuel consumption is predefined
        fuel = Availability.fuel / Simulation.time.steps.fraction / 2
        // Calculate net thermal power available [MW]
        thermalPower.megaWatt =
          fuel * parameter.efficiency.quotient
          * Simulation.adjustmentFactor.efficiencyHeater
        load = Ratio(heatFlow.heater.megaWatt / Design.layout.heater)
        operationMode = .normal(load)

        // Check if the load is greater than the minimum load for the heater
        guard load > parameter.minLoad else {
          debugPrint(
            """
            \(DateTime.current)
            HR operation requested but not performed because of HR underload.
            """)
          operationMode = .noOperation
          massFlow = 0.0
          thermalPower = .zero
          let energy = Heater.Consumptions(
            heatFlow: thermalPower.megaWatt, electric: parasitics, fuel: fuel
          )
          return energy
        }
        // Normal operation is possible

        // If Reheating, then do not change the displayed operating status/mode
        temperature.outlet = parameter.nominalTemperatureOut

        // Calculate mass flow that can be achieved [kg/sec] = [MJ/sec] * 1000 / [kJ/kg]
        if Design.hasStorage, case .preheat = mode {
          massFlow = storage
        } else {
          massFlow.rate = thermalPower.kiloWatt
            / htf.heatContent(temperature.outlet, temperature.inlet)
        }
      } else {
        // Use default mass flow and fuel consumption based on heater design
        massFlow.rate = Design.layout.heater
          / htf.heatContent(parameter.nominalTemperatureOut, temperature.inlet)

        fuel = Design.layout.heater / parameter.efficiency.quotient
        load = Ratio(1)
        operationMode = .charge(load)
        // Parasitic power [MW]
        thermalPower.megaWatt = Design.layout.heater
        // return
      }
    } else if case .freezeProtection = operationMode {
      // Calculate thermal power based on mass flow and outlet temperature in freeze protection mode
      thermalPower.kiloWatt =
        massFlow.rate * htf.heatContent(
          parameter.antiFreezeTemperature, temperature.inlet
        )

      // Check if thermal power exceeds the heater design capacity
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

      // Set the load to the thermal power as a percentage of the heater design capacity
      load = Ratio(min(thermalPower.megaWatt / Design.layout.heater, 1.0))
      operationMode = .freezeProtection(load)
      // No operation requested or thermal power exceeds the demand
    } else if case .noOperation = operationMode {
      massFlow = .zero
      //  if isMaintained {
      //   operationMode = .maintenance
      //  }
      uniformTemperature()
      thermalPower = .zero
    } else if case .maintenance = operationMode {
      // Operation is requested, but the heater is under maintenance
      debugPrint(
        """
        \(DateTime.current)
        Sched. maintnc. of HR disables requested operation.
        """)
      operationMode = .noOperation
      massFlow = .zero
      uniformTemperature()
      thermalPower = .zero
    } else {
      // Normal operation is requested
      // Calculate the fuel flow needed [MW]

      fuel =
        max(heatFlow.balance.megaWatt, Design.layout.heater)
        / parameter.efficiency.quotient
        / Simulation.adjustmentFactor.efficiencyHeater
      // The fuelfl avl. [MW]
      fuel =
        min(fuel * Simulation.time.steps.fraction, Availability.fuel)
        / Simulation.time.steps.fraction

      /// Net thermal power available [MW]
      thermalPower.megaWatt =
        fuel * parameter.efficiency.quotient
        * Simulation.adjustmentFactor.efficiencyHeater

      // Set the load to the thermal power as a percentage of the heater design capacity
      load = Ratio(min(thermalPower.megaWatt / Design.layout.heater, 1.0))

      // Check if the load is below the minimum load for the heater
      if load < parameter.minLoad {
        load = parameter.minLoad
        thermalPower.megaWatt = load.quotient * Design.layout.heater
        fuel = thermalPower.megaWatt / parameter.efficiency.quotient
      }

      // Normal operation is possible
      if case .reheat = operationMode {
        operationMode = .normal(load)
      }
      // If Reheating, then do not change the displayed operating status/mode
      setTemperature(outlet: parameter.nominalTemperatureOut)
      // Calculate mass flow that can be achieved [kg/sec] = [MJ/sec] * 1000 / [kJ/kg]
      if Design.hasStorage, case .preheat = mode {
        massFlow = storage
      } else {
        massFlow.rate = thermalPower.kiloWatt / heat
      }
    }
    // Calculate parasitics based on the current load
    parasitics = load > .zero ? Heater.parasitics(estimateFrom: load) : 0
    let energy = Heater.Consumptions(
      heatFlow: thermalPower.megaWatt, electric: parasitics, fuel: fuel
    )
    return energy
  }
}

extension Heater.OperationMode: RawRepresentable {
  public typealias RawValue = String

  /// Initializes an `Heater.OperationMode` based on its raw value.
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

  /// The raw value representation of the `Heater.OperationMode`.
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
