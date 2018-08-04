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

  public static func update(_ boiler: inout Boiler.PerformanceData,
                            thermal: Double,
                            Qsf_load: Double,
                            fuel: inout Double,
                            fuelFlow: inout Double) -> Double {
    if case .noOperation = boiler.operationMode { /* || heat >= 0 */
      if boiler.isMaintained {
        boiler.operationMode = .scheduledMaintenance
        return 0.0
      }
      noOperation(&boiler, &fuelFlow, fuel)
      return 0.0
    }

    if case .SI = boiler.operationMode {
      boiler.operationMode = .startUp
      // if let startEnergyOld = boiler.startEnergy {
      //   boiler.startEnergy = startEnergyOld
      // }
    } else if case .NI = boiler.operationMode {
      boiler.operationMode = .noOperation(hours: hourFraction)
    }

    if boiler.isMaintained { // From here: operation is requested:
      print(TimeStep.current, "Scheduled maintenance of BO disables requested operation")
      boiler.operationMode = .scheduledMaintenance
      self.noOperation(&boiler, &fuelFlow, fuel)
      return 0.0
    }

    if -thermal / Design.layout.boiler < self.parameter.minLoad || fuel == 0 { // Check if underload
      print(TimeStep.current, "BO operation requested but not performed because of BO underload.")
      self.noOperation(&boiler, &fuelFlow, fuel)
      return 0.0
    }

    // Normal operation requested:
    var heatAvailable: Double

    if Boiler.parameter.booster {
      heatAvailable = min(-thermal, Design.layout.boiler) // * Plant.availability[calendar].boiler
    } else {
      // ≈
      heatAvailable = min(Qsf_load * Design.layout.boiler, Design.layout.boiler)
    }

    boiler.load = Ratio(heatAvailable / Design.layout.boiler)
    let fuelNeed = heatAvailable / efficiency(at: boiler.load) * hourFraction // The fuel needed

    let totalFuelNeed: Double

    switch boiler.operationMode {
    // The total fuel:  production and startup [MWh]
    case let .noOperation(hours)
      where hours >= self.parameter.start.hours.cold:
      boiler.operationMode = .coldStartUp
      totalFuelNeed = fuelNeed + self.parameter.start.energy.cold
    case let .noOperation(hours)
      where hours >= self.parameter.start.hours.warm:
      boiler.operationMode = .warmStartUp
      totalFuelNeed = fuelNeed + self.parameter.start.energy.warm
    case let .noOperation(hours)
      where hours >= 0:
      boiler.operationMode = .operating
      totalFuelNeed = fuelNeed // no additional fuel needed.
    default:
      if boiler.startEnergy == 0 {
        boiler.operationMode = .operating
        totalFuelNeed = fuelNeed // no additional fuel needed.
      } else {
        boiler.operationMode = .startUp
        totalFuelNeed = fuelNeed + boiler.startEnergy
      }
    }

    if Fuelmode.isPredefined {
      // FIXME	if time.minutes! = 55 {
      // FIXME		var fuelold = fuel
      // FIXME	}
    }

    if fuel < totalFuelNeed { // Check if sufficient fuel avail.
      self.load(of: &boiler, fuel: &fuel, fuelFlow: &fuelFlow)
      if boiler.load.ratio < self.parameter.minLoad {
        print(TimeStep.current, "BO operation requested but insufficient fuel.")
        self.noOperation(&boiler, &fuelFlow, fuel)
        return 0.0
      }
    }

    // Normal operation possible:

    // FIXME: H2Ov.temperature.outlet  = Boiler.parameter.nomTout
    if Fuelmode.isPredefined { // predefined fuel consumption in *.pfc-file
      fuelFlow = fuel / hourFraction // Fuel flow [MW] in this hour fraction
      return fuelFlow * self.efficiency(at: boiler.load) // net thermal power [MW]
    } else {
      fuelFlow = totalFuelNeed / hourFraction // Fuel flow [MW] in this hour fraction
      return fuelNeed / hourFraction * self.efficiency(at: boiler.load) // net thermal power [MW]
    }
  }

  private static func load(of boiler: inout PerformanceData,
                           fuel: inout Double,
                           fuelFlow: inout Double) {
    switch (boiler.operationMode, boiler.isMaintained) {
    case (let .noOperation(hours), false):
      boiler.operationMode = .noOperation(hours: hours + hourFraction)
    case (_, true):
      boiler.operationMode = .scheduledMaintenance
    default:
      break
    }

    // Calc. the fuel avail. for production only:
    switch boiler.operationMode {
    case let .noOperation(hours)
      where hours >= Boiler.parameter.start.hours.cold:
      fuel -= Boiler.parameter.start.energy.cold
    case let .noOperation(hours)
      where hours >= Boiler.parameter.start.hours.warm:
      fuel -= Boiler.parameter.start.energy.warm
    default:
      fuelFlow = fuel
      if 0.5 * fuel < boiler.startEnergy {
        fuel = 0.5 * fuel
        boiler.startEnergy -= fuel
      } else {
        fuel -= boiler.startEnergy
        boiler.startEnergy = 0
        boiler.operationMode = .operating
      }
    }

    if fuel == 0 {
      boiler.startEnergy = -fuel
      boiler.load = 0.0
      // electricalParasitics = 0
      //  boiler.thermal = 0
      return
    }

    // Iteration to get possible load with the fuel avail. for production:
    var load = 0.0
    repeat {
      if Fuelmode.isPredefined { // predefined fuel consumption in *.pfc-file
        load = fuel / (Design.layout.boiler * hourFraction)
        boiler.load = Ratio(fuel / (Design.layout.boiler * hourFraction))
      } else {
        load = fuel * self.efficiency(at: boiler.load) / Design.layout.boiler
        boiler.load = Ratio(fuel
          * Boiler.efficiency(at: Ratio(load)) / Design.layout.boiler)
      }
    } while abs(load - boiler.load.ratio) < 0.01
  }

  private static func noOperation(_ boiler: inout Boiler.PerformanceData,
                                  _ fuelFlow: inout Double,
                                  _ fuel: Double) {
    if case .startUp = boiler.operationMode {
      fuelFlow = fuel
    } else {
      boiler.operationMode = .noOperation(hours: hourFraction)
      fuelFlow = 0
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
