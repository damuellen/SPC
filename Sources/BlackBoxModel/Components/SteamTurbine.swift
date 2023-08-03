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
import Meteo
import Utilities

extension SteamTurbine: CustomStringConvertible {
  public var description: String {
    "  Mode:".padding(20) + "\(operationMode)".padding(30)
  }
}

extension SteamTurbine.OperationMode: CustomStringConvertible {
  public var description: String {
    switch self {
      case .noOperation(let minutes): return "No Operation \(minutes)min "
      case .operating(let load): return "Operation \(load.singleBar)"
      case .startUp(let minutes, energy: let energy):
       return "Start up \(minutes)min energy: \(energy)"
      case .scheduledMaintenance: return "Scheduled Maintenance"
    }
  }
}

/// A struct representing the state and functions for mapping the steam turbine
struct SteamTurbine: Parameterizable {
  
  /// The current operating mode of the steam turbine
  private(set) var operationMode: OperationMode
  /// Returns the load applied
  private(set) var load: Ratio {
    get { 
      if case .operating(let load) = operationMode
        { return load } else { return .zero }
    }
    set { operationMode = .operating(newValue) }
  }

  /// The operation mode options for the steam turbine
  enum OperationMode {
    case noOperation(time: Int)
    case startUp(time: Int, energy: Double)
    case scheduledMaintenance
    case operating(Ratio)
  }

  var isOperating: Bool {
    switch operationMode {
    case .operating: return true
    default: return false
    }
  }
  /// Creates a `SteamTurbine` instance with the fixed initial state.
  static let initialState = SteamTurbine(operationMode: .noOperation(time: 0))

  public static var parameter: Parameter = Parameters.tb

  /// Used to sum time only when time step has changed
  private static var oldMinute = 0

  /// Calculates the gross electric output of the steam turbine based on the given thermal energy flow, heater data, heat exchanger data, and ambient temperature.
  /// - Parameters:
  ///   - heatFlow: The thermal energy flow information, representing the heat exchanger's energy in MegaWatt (MW), as `ThermalEnergy`.
  ///   - heater: The heater data used in the calculations, as `Heater`.
  ///   - heatExchanger: The heat exchanger data, including temperature information, as `HeatExchanger`.
  ///   - temperature: The ambient temperature in Celsius, as `Temperature`.
  /// - Returns: The calculated gross electric output of the steam turbine in MegaWatt (MW) as a `Double`.
  mutating func callAsFunction(
    heatFlow: ThermalEnergy,
    heater: Heater,
    heatExchanger: HeatExchanger,
    temperature: Temperature    
  )
    -> Double
  {
    let parameter = SteamTurbine.parameter
    defer { SteamTurbine.oldMinute = DateTime.current.minute }

    let minutes = Int(Simulation.time.steps.fraction * 60)
    if heatFlow.heatExchanger.isZero {
      // Avoid summing up inside an iteration
      if DateTime.current.minute != SteamTurbine.oldMinute {

        if case .noOperation(let standStillTime) = operationMode {
          operationMode = .noOperation(time: standStillTime + minutes)
        } else {
          operationMode = .noOperation(time: minutes)
        }
      }
      return 0

    } else {  // Energy is coming to the turbine

      switch operationMode {
      case .noOperation(let standStillTime):
        if standStillTime < parameter.hotStartUpTime {
          operationMode = .operating(1.0)
        } else {
          operationMode = .startUp(time: 0, energy: 0)
        }
      case .startUp(let startUpTime, let startUpEnergy):
        if startUpTime >= parameter.startUpTime,
          startUpEnergy >= parameter.startUpEnergy
        {
          operationMode = .operating(1.0)
        }
      case .scheduledMaintenance: return 0
      case .operating: break
      }

      if isOperating {
        let efficiency = perform(
          heatExchanger: heatExchanger.temperature.inlet,
          ambient: temperature
        )
        let gross = heatFlow.heatExchanger.megaWatt * efficiency.quotient
        load.quotient = min(load.quotient, gross / parameter.power.max)
        return gross
      } else {  // Start Up sequence: Energy is lost / Dumped
        // Avoid summing up inside an iteration
        if DateTime.current.minute != SteamTurbine.oldMinute {
          if case .startUp(let startUpTime, let startUpEnergy) = operationMode {
            var energy = heatFlow.heatExchanger.megaWatt
            if heater.massFlow > .zero { energy = heatFlow.heatExchanger.megaWatt }

            operationMode = .startUp(
              time: startUpTime + minutes,
              energy: startUpEnergy + energy * Simulation.time.steps.fraction
            )
          }
        }
        return 0
      }
    }
  }

  /// Calculates the minimum load that the steam turbine can operate at, based on the given ambient temperature.
  /// - Parameter ambient: The ambient temperature in Celsius.
  /// - Returns: The minimum load as a `Ratio`.
  static func minLoad(atTemperature ambient: Temperature) -> Ratio {
    let minLoad: Ratio
    if SteamTurbine.parameter.minPowerFromTemp.isInapplicable {
      minLoad = Ratio(
        SteamTurbine.parameter.power.min
        / SteamTurbine.parameter.power.max)
    } else {
      minLoad = Ratio(
        SteamTurbine.parameter.minPowerFromTemp(ambient)
        / SteamTurbine.parameter.power.max)
    }
    return minLoad
  }
  /// Calculates the minimum power output that the steam turbine can produce, based on the given ambient temperature.
  /// - Parameter ambient: The ambient temperature in Celsius.
  /// - Returns: The minimum power output in MegaWatt (MW) as a `Double`.
  static func minPower(atTemperature ambient: Temperature) -> Double {
    var minPower: Double
    if SteamTurbine.parameter.minPowerFromTemp.isInapplicable {
      minPower =
        SteamTurbine.parameter.power.min
        / SteamTurbine.parameter.efficiencyNominal
    } else {
      minPower = SteamTurbine.parameter.minPowerFromTemp(ambient)

      minPower = max(
        SteamTurbine.parameter.power.nominal * minPower,
        SteamTurbine.parameter.power.min)
    }
    return minPower
  }

  /// Adjusts the load applied to the steam turbine, ensuring that it does not exceed the available power block capacity.
  /// - Parameter load: The desired load to be applied, represented as a `Ratio`.
  mutating func adjust(load: Ratio) {
    self.load = min(load, Availability.current.value.powerBlock)
  }

  /// Performs the efficiency calculation for the steam turbine.
  /// - Parameters:
  ///   - heatExchanger: The temperature of the heat exchanger inlet in Celsius.
  ///   - ambient: The ambient temperature in Celsius.
  /// - Returns: The efficiency of the steam turbine as a `Ratio`.
  mutating func perform(
    heatExchanger: Temperature,
    ambient: Temperature
  ) -> Ratio {
    let parameter = SteamTurbine.parameter
    let maxEfficiency =
      parameter.efficiencyNominal
      * (parameter.efficiencyTempIn_A
        * heatExchanger.celsius ** parameter.efficiencyTempIn_B)
        * parameter.efficiencyTempIn_cf  

    var dcFactor = 1.0
    
    if parameter.efficiencyTemperature[1] >= 1 {
      
      let (dc, loadMax) = DryCooling.perform(
        steamTurbineLoad: load,
        temperature: ambient
      )

      load.quotient = min(load.quotient, loadMax.quotient)
      dcFactor = dc.quotient
    }

    var efficiency = parameter.efficiency(load)

    if !parameter.efficiencyTemperature.isInapplicable {
      efficiency *= parameter.efficiencyTemperature(ambient.celsius)
    }

    // wet bulb temperature effect

    let wetBulbTemperature = 1.1
    var correctionWetBulbTemperature = 1.0
    
    if parameter.efficiencyWetBulb.coefficients.isEmpty {
      correctionWetBulbTemperature = 1.0
    } else {
      if wetBulbTemperature < parameter.WetBulbTstep {
        for i in 0...2 {
          correctionWetBulbTemperature +=
            parameter.efficiencyWetBulb[i]
            * wetBulbTemperature ** Double(i)
        }
      } else {
        for i in 3...5 {
          correctionWetBulbTemperature +=
            parameter.efficiencyWetBulb[i]
            * wetBulbTemperature ** Double(i - 3)
        }
      }
    }
    
    if parameter.efficiencyTemperature[1] >= 1 {
      efficiency *= maxEfficiency / dcFactor
    } else {
      efficiency *= maxEfficiency * correctionWetBulbTemperature
    }
    efficiency *= Simulation.adjustmentFactor.efficiencyTurbine
    return Ratio(efficiency)
  }
}
