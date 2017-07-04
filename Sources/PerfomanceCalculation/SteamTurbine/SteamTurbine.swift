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

extension SteamTurbine.Instance: CustomDebugStringConvertible {
  var debugDescription: String {
    return parameter.description + "\n\(workingConditions.current)"
  }
}

extension SteamTurbine.PerformanceData: CustomDebugStringConvertible {
  public var debugDescription: String {
    var d: String = ""
    d += "Operation mode:" >< "\(operationMode)"
    d += "Load:" >< "\(load)"
    d += "Is maintained:" >< "\(isMaintained)"
    d += "Back pressure:" >< "\(backPressure)"
    d += "Op:" >< "\(Op)"
    d += "PminfT:" >< "\(PminfT)"
    return d
  }
}

public enum SteamTurbine: Model {
  
  final class Instance {
    // A singleton class holding the state of the steam turbine
    fileprivate static let shared = Instance()
    var parameter: SteamTurbine.Parameter!
    var workingConditions: (previous: PerformanceData?, current: PerformanceData)
    
    private init() {
      workingConditions = (nil, initialState)
    }
  }

  /// a struct for operation-relevant data of the steam turbine
  public struct PerformanceData {
    var operationMode: OperationMode
    var load: Ratio
    var isMaintained: Bool
    var backPressure: Double
    var Op: Double
    var PminfT: Double
    public enum OperationMode {
      case noOperation(hours: Double), SM
    }
  }

  static let initialState = PerformanceData(
    operationMode: .noOperation(hours: 6),
    load: 0.0,
    isMaintained: false,
    backPressure: 0,
    Op: 0,
    PminfT: 0)

  /// Returns the current working conditions of the steam turbine
  public static var status: PerformanceData {
    get { return Instance.shared.workingConditions.current }
    set {
      Instance.shared.workingConditions =
       (Instance.shared.workingConditions.current, newValue) 
    }
  }

  /// Returns the previous working conditions of the steam
  public static var previous: PerformanceData? {
    return Instance.shared.workingConditions.previous
  }

  public static var parameter: SteamTurbine.Parameter {
    get { return Instance.shared.parameter }
    set { Instance.shared.parameter = newValue }
  }

  /// Current load of the steam turbine
  public static var load: Ratio {
    get { return status.load }
    set { status.load = newValue }
  }

  /// Returns the efficiency of the steam turbine based on her working conditions
  /// - SeeAlso: `SteamTurbine.efficiency(load:Lmax:)`
  public static var efficiency: Double {
    return SteamTurbine.efficiencyFor(load: load, Lmax: load)
  }

  static func efficiencyFor(load: Ratio, Lmax: Ratio) -> Double {
    guard load.value > 0 else { return 0.0 }

    var load = load
    var Lmax = Lmax.value
    var parameter = SteamTurbine.parameter
    
    var maxEfficiency: Double

    if case .operating = Boiler.status.operationMode {
      // this restriction was planned to simulate an specific case, not correct for every case with Boiler

      if Boiler.status.heatFlow > 50 || SolarField.status.heatFlow == 0 {
        maxEfficiency = parameter.efficiencyBoiler
      } else {
        maxEfficiency = (Boiler.status.heatFlow * parameter.efficiencyBoiler
          + 4 * HeatExchanger.status.heatFlow * parameter.efficiencyNominal)
          / (Boiler.status.heatFlow + 4 * HeatExchanger.status.heatFlow)
        // maxEfficiency = parameter.effnom
      }
    } else if case .ic = GasTurbine.status.operationMode {
      maxEfficiency = parameter.efficiencySCC
    } else {
      if HeatExchanger.status.temperature.inlet == 0 {
        HeatExchanger.status.temperature.inlet = 274
      }

      if parameter.efficiencytempIn_A == 0
        && parameter.efficiencytempIn_B == 0 {
        parameter.efficiencytempIn_A = 0.2383
        parameter.efficiencytempIn_B = 0.2404
        parameter.efficiencytempIn_cf = 1
      }

      if parameter.efficiencytempIn_cf == 0 {
        parameter.efficiencytempIn_cf = 1
      }

      maxEfficiency = parameter.efficiencyNominal
        * (parameter.efficiencytempIn_A
          * pow((HeatExchanger.status.temperature.inlet.toCelsius),
                parameter.efficiencytempIn_B))
        * parameter.efficiencytempIn_cf
    }

    if case .pc = GasTurbine.status.operationMode {
      maxEfficiency = parameter.efficiencySCC
    }

    // Dependency of Heat Rate on Ambient Temperature  - DRY COOLING -
    if parameter.efficiencyTemperature[1] >= 1 {

      let (DCFactor, MaxDCLoad) = DryCooling.operate(
        Tamb: Plant.ambientTemperature, steamTurbine: &status)
      Lmax = MaxDCLoad.value

      if load.value > MaxDCLoad.value {
        load = MaxDCLoad
      }
    }
    // Dependency of Heat Rate on Ambient Temperature  - DRY COOLING -
    // now a polynom offourth degree -
    var efficiency = parameter.efficiency[load.value]

    if !parameter.efficiencyTemperature.coefficients.isEmpty {
      efficiency *= parameter.efficiencyTemperature[Plant.ambientTemperature]
    }

    let wetBulbTemperature = 1.1
    var correctionWetBulbTemperature = 0.0
    // wet bulb temperature effect
    if parameter.efficiencyWetBulb.coefficients.isEmpty {
      correctionWetBulbTemperature = 1.0
    } else {
      if wetBulbTemperature < parameter.WetBulbTstep {
        for i in 0 ... 2 {
          correctionWetBulbTemperature += parameter.efficiencyWetBulb[i]
            * pow(wetBulbTemperature, Double(i))
        }
      } else {
        for i in 3 ... 5 {
          correctionWetBulbTemperature += parameter.efficiencyWetBulb[i]
            * pow(wetBulbTemperature, Double(i - 3))
        }
      }
    }
    let adjustmentFactor = Simulation.parameter.adjustmentFactor.efficiencyTurbine
    if parameter.efficiencyTemperature[1] >= 1 {
      return efficiency * maxEfficiency * adjustmentFactor //  / DCFactor
    } else {
      return efficiency * maxEfficiency * adjustmentFactor * correctionWetBulbTemperature
    }
  }
}
