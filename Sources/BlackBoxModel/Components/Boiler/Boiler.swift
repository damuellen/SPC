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

public enum Boiler: Component {
  /// a struct for operation-relevant data of the boiler
  public struct PerformanceData {
    var operationMode: OperationMode
    var isMaintained: Bool
    var load: Ratio
    var startEnergy: Double
    // var startEnergyOld: Double

    public enum OperationMode {
      case noOperation(hours: Double)
      case SI, NI, startUp, scheduledMaintenance,
        coldStartUp, warmStartUp, operating, unknown
    }
  }

  static let initialState = PerformanceData(
    operationMode: .noOperation(hours: 0),
    isMaintained: false,
    load: 0.0,
    startEnergy: 0.0
  )
  // startEnergyOld: 0.0)

  static var parameter: Parameter = ParameterDefaults.bo

  /// Returns the parasitics of the gas turbine based on her working conditions
  /// - SeeAlso: `Boiler.parasitics(load:)`
  public static func parasitics(boiler: Boiler.PerformanceData) -> Double {
    return Boiler.parasitics(at: boiler.load)
  }

  /// Calculates the efficiency of the boiler which only depends on his current load
  private static func efficiency(at load: Ratio) -> Double {
    let efficiency = Boiler.parameter.efficiency[load]
    // debugPrint("boiler efficiency at \(efficiency)")
    assert(efficiency < 1, "boiler efficiency at over 100%")
    return efficiency
  }

  /// Calculates the parasitics of the gas turbine which only depends on the current load
  private static func parasitics(at load: Ratio) -> Double {
    return load.ratio.isZero ? 0 :
      Boiler.parameter.nominalElectricalParasitics *
      (Boiler.parameter.electricalParasitics[0] +
        Boiler.parameter.electricalParasitics[1] * load.ratio)
  }

  public static func update(_ status: inout Boiler.PerformanceData,
                            heatFlow: Double,
                            Qsf_load: Double,
                            fuel: inout Double) -> Double {
    if case .noOperation = status.operationMode { /* || heat >= 0 */
      if status.isMaintained {
        status.operationMode = .scheduledMaintenance
        return 0.0
      }
      Boiler.noOperation(&status, fuel)
      return 0.0
    }

    if case .SI = status.operationMode {
      status.operationMode = .startUp
      // if let startEnergyOld = boiler.startEnergy {
      //   boiler.startEnergy = startEnergyOld
      // }
    } else if case .NI = status.operationMode {
      status.operationMode = .noOperation(hours: hourFraction)
    }

    if status.isMaintained { // From here: operation is requested:
      Log.infoMessage("Scheduled maintenance of BO disables requested operation. \(TimeStep.current)")
      status.operationMode = .scheduledMaintenance
      Boiler.noOperation(&status, fuel)
      return 0.0
    }

    if -heatFlow / Design.layout.boiler < parameter.minLoad || fuel == 0 { // Check if underload
      Log.infoMessage("BO operation requested but not performed because of BO underload. \(TimeStep.current)")
      Boiler.noOperation(&status, fuel)
      return 0.0
    }

    // Normal operation requested:
    var heatAvailable: Double

    if Boiler.parameter.booster {
      heatAvailable = min(-heatFlow, Design.layout.boiler) // * Plant.availability[calendar].boiler
    } else {
      // ≈
      heatAvailable = min(Qsf_load * Design.layout.boiler, Design.layout.boiler)
    }

    status.load = Ratio(heatAvailable / Design.layout.boiler)
    let fuelNeed = heatAvailable / efficiency(at: status.load) * hourFraction // The fuel needed

    let totalFuelNeed: Double

    switch status.operationMode {
    // The total fuel:  production and startup [MWh]
    case let .noOperation(hours)
      where hours >= parameter.start.hours.cold:
      status.operationMode = .coldStartUp
      totalFuelNeed = fuelNeed + parameter.start.energy.cold
    case let .noOperation(hours)
      where hours >= parameter.start.hours.warm:
      status.operationMode = .warmStartUp
      totalFuelNeed = fuelNeed + parameter.start.energy.warm
    case let .noOperation(hours)
      where hours >= 0:
      status.operationMode = .operating
      totalFuelNeed = fuelNeed // no additional fuel needed.
    default:
      if status.startEnergy == 0 {
        status.operationMode = .operating
        totalFuelNeed = fuelNeed // no additional fuel needed.
      } else {
        status.operationMode = .startUp
        totalFuelNeed = fuelNeed + status.startEnergy
      }
    }

    if Fuelmode.isPredefined {
      // FIXME	if time.minutes! = 55 {
      // FIXME		var fuelold = fuel
      // FIXME	}
    }

    if fuel < totalFuelNeed { // Check if sufficient fuel avail.
      Boiler.load(&status, fuel: &fuel)
      if status.load.ratio < parameter.minLoad {
        Log.infoMessage("BO operation requested but insufficient fuel. \(TimeStep.current)")
        Boiler.noOperation(&status, fuel)
        return 0.0
      }
    }

    // Normal operation possible:

    // FIXME: H2Ov.temperature.outlet  = Boiler.parameter.nomTout
    if Fuelmode.isPredefined { // predefined fuel consumption in *.pfc-file
      Plant.fuel.boiler = fuel / hourFraction // Fuel flow [MW] in this hour fraction
      return Plant.fuel.boiler * Boiler.efficiency(at: status.load) // net thermal power [MW]
    } else {
      Plant.fuel.boiler = totalFuelNeed / hourFraction // Fuel flow [MW] in this hour fraction
      return Plant.fuel.boiler / hourFraction * Boiler.efficiency(at: status.load) // net thermal power [MW]
    }
  }

  private static func load(_ status: inout PerformanceData,
                           fuel: inout Double) {
    switch (status.operationMode, status.isMaintained) {
    case (let .noOperation(hours), false):
      status.operationMode = .noOperation(hours: hours + hourFraction)
    case (_, true):
      status.operationMode = .scheduledMaintenance
    default:
      break
    }

    // Calc. the fuel avail. for production only:
    switch status.operationMode {
    case let .noOperation(hours)
      where hours >= Boiler.parameter.start.hours.cold:
      fuel -= Boiler.parameter.start.energy.cold
    case let .noOperation(hours)
      where hours >= Boiler.parameter.start.hours.warm:
      fuel -= Boiler.parameter.start.energy.warm
    default:
      Plant.fuel.boiler = fuel
      if 0.5 * fuel < status.startEnergy {
        fuel = 0.5 * fuel
        status.startEnergy -= fuel
      } else {
        fuel -= status.startEnergy
        status.startEnergy = 0
        status.operationMode = .operating
      }
    }

    if fuel == 0 {
      status.startEnergy = -fuel
      status.load = 0.0
      // electricalParasitics = 0
      //  boiler.thermal = 0
      return
    }

    // Iteration to get possible load with the fuel avail. for production:
    var load = 0.0
    repeat {
      if Fuelmode.isPredefined { // predefined fuel consumption in *.pfc-file
        load = fuel / (Design.layout.boiler * hourFraction)
        status.load = Ratio(fuel / (Design.layout.boiler * hourFraction))
      } else {
        load = fuel * Boiler.efficiency(at: status.load) / Design.layout.boiler
        status.load = Ratio(fuel
          * Boiler.efficiency(at: Ratio(load)) / Design.layout.boiler)
      }
    } while abs(load - status.load.ratio) < 0.01
  }

  private static func noOperation(_ boiler: inout Boiler.PerformanceData,
                                  _ fuel: Double) {
    if case .startUp = boiler.operationMode {
      Plant.fuel.boiler = fuel
    } else {
      boiler.operationMode = .noOperation(hours: hourFraction)
      Plant.fuel.boiler = 0
      boiler.load = Ratio(0)
      // FIXME: H2Ov.massFlow = 0
    }
  }
}

extension Boiler.PerformanceData: CustomStringConvertible {
  public var description: String {
    return "\(operationMode), "
      + "Maintenance: \(isMaintained ? "Yes" : "No"), "
      + "Load: \(load), "
      + String(format: "Start Energy: %.1f", startEnergy)
  }
}

extension Boiler.PerformanceData.OperationMode: RawRepresentable, CustomStringConvertible {
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

  public var description: String {
    return self.rawValue
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
