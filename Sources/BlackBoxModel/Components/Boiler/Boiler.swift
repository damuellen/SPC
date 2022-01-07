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
import DateGenerator
import Physics

/// This struct contains the state as well as the functions for mapping the boiler
public struct Boiler: Parameterizable {
  /// Returns the operating state
  public internal(set) var operationMode: OperationMode

  var isMaintained: Bool
  /// Returns the load applied
  public internal(set) var load: Ratio

  var startEnergy: Double
  // var startEnergyOld: Double

  public enum OperationMode {

    case noOperation(hours: Double)

    case SI, NI, startUp, scheduledMaintenance,
      coldStartUp, warmStartUp, operating, unknown
  }
  /// Returns the fixed initial state.
  static let initialState = Boiler(
    operationMode: .noOperation(hours: 0),
    isMaintained: false,
    load: 0.0,
    startEnergy: 0.0
  )
  // startEnergyOld: 0.0)
  /// Returns the static parameters
  public static var parameter: Parameter = ParameterDefaults.bo

  /// Calculates the efficiency of the boiler which only depends on his current load
  static func efficiency(at load: Ratio) -> Double {
    let efficiency = Boiler.parameter.efficiency(load)
    // debugPrint("boiler efficiency at \(efficiency)")
    precondition(efficiency < 1, "Perpetuum mobile boiler efficiency at over 100%")
    return efficiency
  }

  /// Calculates the parasitics of the boiler which only depends on the current load
  static func parasitics(estimateFrom load: Ratio) -> Double {
    return load.isZero ? 0 :
      parameter.nominalElectricalParasitics *
      (parameter.electricalParasitics[0] +
        parameter.electricalParasitics[1] * load.quotient)
  }

  mutating func callAsFunction(
    demand: Double, Qsf_load: Double, fuelAvailable: Double)
    -> Plant.Performance<Boiler>
  {
    let parameter = Boiler.parameter

    var thermalPower = 0.0

    var fuel = 0.0

    var parasitics = 0.0

    if case .noOperation = operationMode { /* || heat >= 0 */

      if isMaintained {

        operationMode = .scheduledMaintenance
        return Plant.Performance(
          heatFlow: thermalPower, electric: parasitics, fuel: fuel
        )
      }

      let fuel = Boiler.noOperation(&self, fuelAvailable: fuelAvailable)
      return Plant.Performance(
        heatFlow: thermalPower, electric: parasitics, fuel: fuel
      )
    }

    if case .SI = operationMode {
      operationMode = .startUp
      // if let startEnergyOld = boiler.startEnergy {
      //   boiler.startEnergy = startEnergyOld
      // }
    } else if case .NI = operationMode {
      operationMode = .noOperation(hours: Simulation.time.steps.fraction)
    }

    if isMaintained { // From here: operation is requested:
      debugPrint("""
        \(DateTime.current)
        Scheduled maintenance of Boiler disables requested operation.
        """)

      operationMode = .scheduledMaintenance

      let fuel = Boiler.noOperation(&self, fuelAvailable: fuelAvailable)

      return Plant.Performance(
        heatFlow: thermalPower, electric: parasitics, fuel: fuel
      )
    }

    if -demand / Design.layout.boiler < parameter.minLoad
      || fuelAvailable == 0
    { // Check if underload
      debugPrint("""
        \(DateTime.current)
        Boiler operation requested but not performed because of underload.
        """)

      let fuel = Boiler.noOperation(&self, fuelAvailable: fuelAvailable)

      return Plant.Performance(
        heatFlow: thermalPower, electric: parasitics, fuel: fuel
      )
    }

    // Normal operation requested:
    var heatAvailable: Double

    if parameter.booster {
      heatAvailable = -demand // * Availability.current[calendar].boiler
    } else {
      heatAvailable = Qsf_load * Design.layout.boiler
    }
    //heatAvailable = heatAvailable.limited(by: Design.layout.boiler)

    load = Ratio(heatAvailable / Design.layout.boiler)
    // The fuel needed
    let fuelNeed = heatAvailable / Boiler.efficiency(at: load)
      * Simulation.time.steps.fraction

    let totalFuelNeed: Double

    switch operationMode {
    // The total fuel:  production and startup [MWh]
    case let .noOperation(hours) where hours >= parameter.start.hours.cold:
      operationMode = .coldStartUp

      totalFuelNeed = fuelNeed + Boiler.parameter.start.energy.cold

    case let .noOperation(hours) where hours >= parameter.start.hours.warm:
      operationMode = .warmStartUp

      totalFuelNeed = fuelNeed + parameter.start.energy.warm

    case let .noOperation(hours)  where hours >= 0:
      operationMode = .operating

      totalFuelNeed = fuelNeed // no additional fuel needed.

    default:
      if startEnergy.isZero {

        operationMode = .operating

        totalFuelNeed = fuelNeed // no additional fuel needed.
      } else {

        operationMode = .startUp

        totalFuelNeed = fuelNeed + startEnergy
      }
    }

    if OperationRestriction.fuelStrategy.isPredefined {
      // FIXME	if time.minutes! = 55 {
      // FIXME		var fuelold = fuel
      // FIXME	}
    }

    if fuelAvailable < totalFuelNeed { // Check if sufficient fuel avail.
      load(fuel: &fuel, fuelAvailable: fuelAvailable)
      if load.quotient < parameter.minLoad {
        debugPrint("""
          \(DateTime.current)
          BO operation requested but insufficient fuel.
          """)
        let fuel = Boiler.noOperation(&self, fuelAvailable: fuelAvailable)

        return Plant.Performance(
          heatFlow: thermalPower, electric: parasitics, fuel: fuel
        )
      }
    }

    // Normal operation possible:

    // FIXME: H2Ov.temperature.outlet  = Boiler.parameter.nomTout
    if OperationRestriction.fuelStrategy.isPredefined { // predefined fuel consumption in *.pfc-file
      // Fuel flow [MW] in this hour fraction
      fuel = fuelAvailable / Simulation.time.steps.fraction

      thermalPower = fuel // FIXME Plant.fuelConsumption.boiler
        * Boiler.efficiency(at: load) // net thermal power [MW]
    } else {
      fuel = totalFuelNeed / Simulation.time.steps.fraction // Fuel flow [MW] in this hour fraction
      thermalPower = fuel // FIXME Plant.fuelConsumption.boiler
        / Simulation.time.steps.fraction * Boiler.efficiency(at: load) // net thermal power [MW]
    }

    parasitics = Boiler.parasitics(estimateFrom: load)

    return Plant.Performance(
      heatFlow: thermalPower, electric: parasitics, fuel: fuel
    )
  }

  private mutating func load(fuel: inout Double, fuelAvailable: Double)
  {
    let parameter = Boiler.parameter
    switch (operationMode, isMaintained) {
    case (let .noOperation(hours), false):
      let hourFraction = hours + Simulation.time.steps.fraction
      operationMode = .noOperation(hours: hourFraction)
    case (_, true):
      operationMode = .scheduledMaintenance
    default:
      break
    }

    // Calc. the fuel avail. for production only:
    switch operationMode {
    case let .noOperation(hours) where hours >= parameter.start.hours.cold:
      fuel -= parameter.start.energy.cold
    case let .noOperation(hours) where hours >= parameter.start.hours.warm:
      fuel -= parameter.start.energy.warm
    default:
      fuel = fuelAvailable
      if 0.5 * fuel < startEnergy {

        fuel = 0.5 * fuel

        startEnergy -= fuel

      } else {

        fuel -= startEnergy

        startEnergy = 0

        operationMode = .operating
      }
    }

    if fuel == 0 {
      startEnergy = -fuel

      load = 0.0
      // electricalParasitics = 0
      // boiler.thermal = 0
      return
    }

    if OperationRestriction.fuelStrategy.isPredefined { // predefined fuel consumption in *.pfc-file
      load = Ratio(fuel / (Design.layout.boiler * Simulation.time.steps.fraction))
      return
    }

    // Iteration to get possible load with the fuel avail. for production:
    var newLoad = Ratio(0)
    repeat {
        newLoad = Ratio(fuel * Boiler.efficiency(at: load) / Design.layout.boiler)
        load = Ratio(fuel * Boiler.efficiency(at: newLoad) / Design.layout.boiler)
    } while abs(newLoad.quotient - load.quotient) < 0.01
  }

  private static func noOperation(
    _ boiler: inout Boiler, fuelAvailable: Double
    ) -> Double
  {
    var fuel = 0.0
    if case .startUp = boiler.operationMode {
      fuel = fuelAvailable
    } else {
      boiler.operationMode = .noOperation(hours: Simulation.time.steps.fraction)
      fuel = 0
      boiler.load = .zero
      // FIXME: H2Ov.massFlow = 0
    }
    return fuel
  }

  static func performSteamTurbine(
    _ heatFlow: ThermalEnergy,
    _ gasTurbine: GasTurbine.OperationMode,
    _ heatExchanger: Temperature,
    _ ambient: Temperature
  ) -> Double {
    let parameter = SteamTurbine.parameter
    let efficiency: Double
    if heatFlow.boiler.megaWatt > 50 || heatFlow.solar.watt == 0 {
      efficiency = parameter.efficiencyBoiler
    } else {
      efficiency =
        (heatFlow.boiler.megaWatt
          * parameter.efficiencyBoiler + 4.0
          * heatFlow.heatExchanger.megaWatt
          * parameter.efficiencyNominal)
        / (heatFlow.boiler.megaWatt + 4.0
          * heatFlow.heatExchanger.megaWatt)
      // maxEfficiency = parameter.effnom
    }
    let adjustmentFactor = Simulation.adjustmentFactor.efficiencyTurbine
    return (efficiency * adjustmentFactor)
  }
}

extension Boiler: CustomStringConvertible {
  public var description: String {
    "\(operationMode),\n"
      + "Maintenance: \(isMaintained ? "Yes" : "No"), "
      + "Load: \(load), "
      + String(format: "Start Performance: %.1f", startEnergy)
  }
}

extension Boiler.OperationMode: RawRepresentable {
  public typealias RawValue = String

  public init?(rawValue: RawValue) {
    switch rawValue {
    case "noOperation": self = .noOperation(hours: 0)
    case "SI": self = .SI
    case "NI": self = .NI
    case "startUp": self = .startUp
    case "Scheduled Maintenance": self = .scheduledMaintenance
    case "Cold StartUp": self = .coldStartUp
    case "Warm StartUp": self = .warmStartUp
    case "operating": self = .operating
    case "unknown": self = .unknown
    default: return nil
    }
  }

  public var rawValue: RawValue {
    switch self {
    case let .noOperation(hours): return "No Operation for \(hours) hours"
    case .SI: return "SI"
    case .NI: return "NI"
    case .startUp: return "startUp"
    case .scheduledMaintenance: return "Scheduled Maintenance"
    case .coldStartUp: return "Cold StartUp"
    case .warmStartUp: return "Warm StartUp"
    case .operating: return "operating"
    case .unknown: return "unknown"
    }
  }
}

extension Boiler.OperationMode: CustomStringConvertible {
  public var description: String {
    return self.rawValue
  }
}
