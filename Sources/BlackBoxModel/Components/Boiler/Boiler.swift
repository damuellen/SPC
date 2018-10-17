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
  /// Contains all data needed to simulate the operation of the boiler
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

  public static var parameter: Parameter = ParameterDefaults.bo

  /// Calculates the efficiency of the boiler which only depends on his current load
  private static func efficiency(at load: Ratio) -> Double {
    let efficiency = Boiler.parameter.efficiency[load]
    // debugPrint("boiler efficiency at \(efficiency)")
    precondition(efficiency < 1, "Perpetuum mobile boiler efficiency at over 100%")
    return efficiency
  }

  /// Calculates the parasitics of the boiler which only depends on the current load
  private static func parasitics(estimateFrom load: Ratio) -> Double {
    return load.ratio.isZero ? 0 :
      Boiler.parameter.nominalElectricalParasitics *
      (Boiler.parameter.electricalParasitics[0] +
        Boiler.parameter.electricalParasitics[1] * load.ratio)
  }

  static func update(
    _ status: PerformanceData, heatFlow: Double,
    Qsf_load: Double, fuelAvailable: Double,
    result: (Status<PerformanceData>) ->())
  {
    var boiler = status
    var thermalPower = 0.0
    var fuel = 0.0
    var parasitics = 0.0
    if case .noOperation = status.operationMode { /* || heat >= 0 */
      if boiler.isMaintained {
        boiler.operationMode = .scheduledMaintenance
        result((thermalPower, 0, parasitics, fuel, boiler))
        return
      }
      let fuel = noOperation(&boiler, fuelAvailable: fuelAvailable)
      result((thermalPower, 0, parasitics, fuel, boiler))
      return
    }

    if case .SI = status.operationMode {
      boiler.operationMode = .startUp
      // if let startEnergyOld = boiler.startEnergy {
      //   boiler.startEnergy = startEnergyOld
      // }
    } else if case .NI = status.operationMode {
      boiler.operationMode = .noOperation(hours: hourFraction)
    }

    if status.isMaintained { // From here: operation is requested:
      💬.infoMessage("""
        \(TimeStep.current)
        Scheduled maintenance of Boiler disables requested operation.
        """)
      boiler.operationMode = .scheduledMaintenance
      let fuel = noOperation(&boiler, fuelAvailable: fuelAvailable)
      result((thermalPower, 0, parasitics, fuel, boiler))
      return
    }

    if -heatFlow / Design.layout.boiler < parameter.minLoad
      || fuelAvailable == 0
    { // Check if underload
      💬.infoMessage("""
        \(TimeStep.current)
        Boiler operation requested but not performed because of underload.
        """)
      let fuel = noOperation(&boiler, fuelAvailable: fuelAvailable)
      result((thermalPower, 0, parasitics, fuel, boiler))
      return
    }

    // Normal operation requested:
    var heatAvailable: Double

    if parameter.booster {
      heatAvailable = min(-heatFlow, Design.layout.boiler) // * Plant.availability[calendar].boiler
    } else {
      heatAvailable = min(Qsf_load * Design.layout.boiler, Design.layout.boiler)
    }

    boiler.load.ratio = heatAvailable / Design.layout.boiler
    // The fuel needed
    let fuelNeed = heatAvailable / efficiency(at: status.load) * hourFraction

    let totalFuelNeed: Double

    switch boiler.operationMode {
    // The total fuel:  production and startup [MWh]
    case let .noOperation(hours) where hours >= parameter.start.hours.cold:
      boiler.operationMode = .coldStartUp
      totalFuelNeed = fuelNeed + parameter.start.energy.cold
    case let .noOperation(hours) where hours >= parameter.start.hours.warm:
      boiler.operationMode = .warmStartUp
      totalFuelNeed = fuelNeed + parameter.start.energy.warm
    case let .noOperation(hours)  where hours >= 0:
      boiler.operationMode = .operating
      totalFuelNeed = fuelNeed // no additional fuel needed.
    default:
      if boiler.startEnergy == 0 {
        boiler.operationMode = .operating
        totalFuelNeed = fuelNeed // no additional fuel needed.
      } else {
        boiler.operationMode = .startUp
        totalFuelNeed = fuelNeed + status.startEnergy
      }
    }

    if Fuelmode.isPredefined {
      // FIXME	if time.minutes! = 55 {
      // FIXME		var fuelold = fuel
      // FIXME	}
    }

    if fuelAvailable < totalFuelNeed { // Check if sufficient fuel avail.
      Boiler.load(&boiler, fuel: &fuel, fuelAvailable: fuelAvailable)
      if boiler.load.ratio < parameter.minLoad {
        💬.infoMessage("""
          \(TimeStep.current)
          BO operation requested but insufficient fuel.
          """)
        let fuel = noOperation(&boiler, fuelAvailable: fuelAvailable)
        result((thermalPower, 0, parasitics, fuel, boiler))
        return
      }
    }

    // Normal operation possible:

    // FIXME: H2Ov.temperature.outlet  = Boiler.parameter.nomTout
    if Fuelmode.isPredefined { // predefined fuel consumption in *.pfc-file
      fuel = fuelAvailable / hourFraction // Fuel flow [MW] in this hour fraction
      thermalPower = Plant.fuelConsumption.boiler
        * efficiency(at: status.load) // net thermal power [MW]
    } else {
      fuel = totalFuelNeed / hourFraction // Fuel flow [MW] in this hour fraction
      thermalPower = Plant.fuelConsumption.boiler
        / hourFraction * efficiency(at: status.load) // net thermal power [MW]
    }
    parasitics = self.parasitics(estimateFrom: boiler.load)
    result((thermalPower, 0, parasitics, fuel, boiler))
    return
  }

  private static func load(_ status: inout PerformanceData,
                           fuel: inout Double, fuelAvailable: Double) {
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
    case let .noOperation(hours) where hours >= parameter.start.hours.cold:
      fuel -= parameter.start.energy.cold
    case let .noOperation(hours) where hours >= parameter.start.hours.warm:
      fuel -= parameter.start.energy.warm
    default:
      fuel = fuelAvailable
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
      // boiler.thermal = 0
      return
    }

    // Iteration to get possible load with the fuel avail. for production:
    var load = 0.0
    repeat {
      if Fuelmode.isPredefined { // predefined fuel consumption in *.pfc-file
        load = fuel / (Design.layout.boiler * hourFraction)
        status.load.ratio = fuel / (Design.layout.boiler * hourFraction)
      } else {
        load = fuel * Boiler.efficiency(at: status.load) / Design.layout.boiler
        status.load.ratio = fuel * Boiler.efficiency(at: Ratio(load))
          / Design.layout.boiler
      }
    } while abs(load - status.load.ratio) < 0.01
  }

  private static func noOperation(
    _ boiler: inout Boiler.PerformanceData, fuelAvailable: Double
    ) -> Double
  {
    var fuel = 0.0
    if case .startUp = boiler.operationMode {
      fuel = fuelAvailable
    } else {
      boiler.operationMode = .noOperation(hours: hourFraction)
      fuel = 0
      boiler.load.ratio = 0
      // FIXME: H2Ov.massFlow = 0
    }
    return fuel
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

extension Boiler.PerformanceData.OperationMode: RawRepresentable {
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

extension Boiler.PerformanceData.OperationMode: CustomStringConvertible {
  public var description: String {
    return self.rawValue
  }
}
