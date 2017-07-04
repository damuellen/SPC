//
//  Copyright (c) 2017 Daniel Müllenborn. All rights reserved.
//  Distributed under the The Non-Profit Open Software License version 3.0
//  http://opensource.org/licenses/NPOSL-3.0
//
//  This project is NOT free software. It is open source, you are allowed to
//  modify it (if you keep the license), but it may not be commercially
//  distributed other than under the conditions noted above.
//

import Foundation

extension Boiler.Instance: CustomDebugStringConvertible {
  var debugDescription: String { return "\(workingConditions.current)" }
}

public enum Boiler: Model {
  
  final class Instance {
    // A singleton class holding the state of the boiler
    fileprivate static let shared = Instance()
    var parameter: Boiler.Parameter!
    var workingConditions: (previous: PerformanceData?, current: PerformanceData)
    
    private init() {
      workingConditions = (nil, initialState)
    }
  }
  
  /// a struct for operation-relevant data of the boiler
  public struct PerformanceData {
    var operationMode: OperationMode
    var isMaintained: Bool
    var load: Ratio
    var heatFlow: Double
    var startEnergy: Double
    //var startEnergyOld: Double
    
    public enum OperationMode {
      case noOperation(hours: Double)
      case SI, NI, startUp, scheduledMaintenance,
      coldStartUp, warmStartUp, operating
    }
  }
  
  fileprivate static let initialState = PerformanceData(
    operationMode: .noOperation(hours: 0),
    isMaintained: false,
    load: 0.0,
    heatFlow: 0.0,
    startEnergy: 0.0)
   // startEnergyOld: 0.0)
  
  /// Returns the current working conditions of the boiler
  public static var status: PerformanceData {
    get { return Instance.shared.workingConditions.current }
    set {
      Instance.shared.workingConditions =
        (Instance.shared.workingConditions.current, newValue)
    }
  }
  
  /// Returns all previous working conditions of the boiler
  public static var previous: PerformanceData? {
    return Instance.shared.workingConditions.previous
  }
  
  public static var parameter: Boiler.Parameter {
    get { return Instance.shared.parameter }
    set { Instance.shared.parameter = newValue }
  }
  
  /// Returns the parasitics of the gas turbine based on her working conditions
  /// - SeeAlso: `Boiler.parasitics(load:)`
  public static var parasitics: Double {
    return Boiler.parasitics(at: status.load)
  }
  
  /// Calculates the efficiency of the boiler which only depends on his current load
  private static func efficiency(load: Ratio) -> Double {
    let efficiency = Boiler.parameter.efficiency[load]
    // debugPrint("boiler efficiency at \(efficiency)")
    precondition(efficiency < 1, "boiler efficiency at over 100%")
    return efficiency
  }
  
  /// Calculates the parasitics of the gas turbine which only depends on the current load
  private static func parasitics(at load: Ratio) -> Double {
    return load.value > 0.0
      ? Boiler.parameter.nominalElectricalParasitics *
        (Boiler.parameter.electricalParasitics[0] +
          Boiler.parameter.electricalParasitics[1] * load.value)
      : 0.0
  }
  
  public static func operate(_ boiler: inout Boiler.PerformanceData,
                             heatFlow: Double,
                             Qsf_load: Double,
                             availableFuel: inout Double,
                             fuelFlow: inout Double) -> Double {

    if case .noOperation = boiler.operationMode { /* || heat >= 0 */
      if boiler.isMaintained {
        boiler.operationMode = .scheduledMaintenance
        return 0.0
      }
      noOperation(&fuelFlow, availableFuel, &boiler)
      return 0.0
    }
    
    if case .SI = boiler.operationMode {
      boiler.operationMode = .startUp
      if let startEnergyOld = Boiler.previous?.startEnergy {
        boiler.startEnergy = startEnergyOld
      }
    } else if case .NI = boiler.operationMode {
      boiler.operationMode = .noOperation(hours: hourFraction)
    }
    
    if boiler.isMaintained { // From here: operation is requested:
      ////report = "Scheduled maintenance of BO disables requested operation"
      boiler.operationMode = .scheduledMaintenance
      noOperation(&fuelFlow, availableFuel, &boiler)
      return 0.0
    }
    
    if -heatFlow / Design.layout.boiler < parameter.minLoad || availableFuel == 0 { // Check if underload
      ////report = "BO operation requested but not performed because of BO underload.\n"
      noOperation(&fuelFlow, availableFuel, &boiler)
      return 0.0
    }
    
    // Normal operation requested:
    var heatAvailable: Double
    
    if Boiler.parameter.booster {
      heatAvailable = min(-heatFlow, Design.layout.boiler) // * Plant.availability[date.month].boiler
    } else {
      // ≈
      heatAvailable = min(Qsf_load * Design.layout.boiler, Design.layout.boiler)
    }
    
    boiler.load = Ratio(heatAvailable / Design.layout.boiler)
    let fuelNeed = heatAvailable / efficiency(load: boiler.load) * hourFraction // The fuel needed
    
    let totalFuelNeed: Double
    
    switch boiler.operationMode {
    // The total fuel:  production and startup [MWh]
    case .noOperation(let hours)
      where hours >= parameter.start.hours.cold:
      boiler.operationMode = .coldStartUp
      totalFuelNeed = fuelNeed + parameter.start.energy.cold
    case .noOperation(let hours)
      where hours >= parameter.start.hours.warm:
      boiler.operationMode = .warmStartUp
      totalFuelNeed = fuelNeed + parameter.start.energy.warm
    case .noOperation(let hours)
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
    
    if Fuelmode == "predefined" {
      // FIXME	if date.minutes = 55 {
      // FIXME		var availableFuelold = availableFuel
      // FIXME	}
    }
    
    if availableFuel < totalFuelNeed { // Check if sufficient fuel avail.
      getLoad(availableFuel: &availableFuel, fuelFlow: &fuelFlow, boiler: &boiler)
      if boiler.load.value < parameter.minLoad {
        ////report = "BO operation requested but insufficient fuel.\n"
        noOperation(&fuelFlow, availableFuel, &boiler)
        return 0.0
      }
    }
    
    // Normal operation possible:
    
    // FIXME   H2Ov.temperature.outlet  = Boiler.parameter.nomTout
    if Fuelmode == "predefined" { // predefined fuel consumption in *.pfc-file
      fuelFlow = availableFuel / hourFraction // Fuel flow [MW] in this hour fraction
      return fuelFlow * efficiency(load: boiler.load) // net thermal power [MW]
    } else {
      fuelFlow = totalFuelNeed / hourFraction // Fuel flow [MW] in this hour fraction
      return fuelNeed / hourFraction * efficiency(load: boiler.load) // net thermal power [MW]
    }
  }
  
  private static func getLoad(availableFuel: inout Double,
                              fuelFlow: inout Double,
                              boiler: inout PerformanceData) {
    switch (boiler.operationMode, boiler.isMaintained) {
    case (.noOperation(let hours), false):
      boiler.operationMode = .noOperation(hours: hours + hourFraction)
    case (_, true):
      boiler.operationMode = .scheduledMaintenance
    default:
      break
    }
    
    // Calc. the fuel avail. for production only:
    switch boiler.operationMode {
    case .noOperation(let hours)
      where hours >= Boiler.parameter.start.hours.cold:
      availableFuel -= Boiler.parameter.start.energy.cold
    case .noOperation(let hours)
      where hours >= Boiler.parameter.start.hours.warm:
      availableFuel -= Boiler.parameter.start.energy.warm
    default:
      fuelFlow = availableFuel
      if 0.5 * availableFuel < boiler.startEnergy {
        availableFuel = 0.5 * availableFuel
        boiler.startEnergy -= availableFuel
      } else {
        availableFuel -= Boiler.status.startEnergy
        boiler.startEnergy = 0
        boiler.operationMode = .operating
      }
    }
    
    if availableFuel == 0 {
      boiler.startEnergy = -availableFuel
      boiler.load = 0.0
      // electricalParasitics = 0
      boiler.heatFlow = 0
      return
    }
    
    // Iteration to get possible load with the fuel avail. for production:
    var load = 0.0
    repeat {
      if Fuelmode == "predefined" { // predefined fuel consumption in *.pfc-file
        load = availableFuel / (Design.layout.boiler * hourFraction)
        boiler.load = Ratio(availableFuel / (Design.layout.boiler * hourFraction))
      } else {
        load = availableFuel * efficiency(load: boiler.load) / Design.layout.boiler
        boiler.load = Ratio(availableFuel
          * Boiler.efficiency(load: Ratio(load)) / Design.layout.boiler)
      }
    } while abs(load - boiler.load.value) < 0.01 // < 2% points difference
  }
  
  private static func noOperation(_ fuelFlow: inout Double,
                                  _ availableFuel: Double,
                                  _ status: inout Boiler.PerformanceData) {
    if case .startUp = status.operationMode {
      fuelFlow = availableFuel
    } else {
      status.operationMode = .noOperation(hours: hourFraction)
      fuelFlow = 0
      status.load = Ratio(0)
      // FIXME H2Ov.massFlow = 0
    }
  }
}
