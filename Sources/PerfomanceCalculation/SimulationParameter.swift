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
import Config

extension Simulation {
  public struct Parameter: Codable  {
    let dfreezeTemperaturePump, dfreezeTemperatureHeat,
    minTemperatureRaiseStartUp, minInsolationRaiseStartUp,
    heatTolerance, tempTolerance, timeTolerance, massTolerance,
    minInsolation, maxToPowerBlock, minInsolationForBoiler,
    electricalTolerance, electricalParasitics, HLtempTolerance: Double
    let adjustmentFactor: AdjustmentFactor
  }
  
  public struct AdjustmentFactor: Codable {
    let efficiencySolarField, efficiencyTurbine, efficiencyHeater,
    efficiencyBoiler, heatLossHCE, heatLossHTF, heatLossH2O,
    electricalParasitics: Double
  }
}

extension Simulation.Parameter: CustomStringConvertible {
  public var description: String {
    var d = ""
    d += "Delta T for Start-Up of Anti-Freeze Pumping:"
      >< "\(dfreezeTemperaturePump)"
    d += "Delta T for Start-Up of Anti-Freeze Heating:"
      >< "\(dfreezeTemperatureHeat)"
    d += "Minimum Raise of Temperature for Start-Up [K]:"
      >< "\(minTemperatureRaiseStartUp)"
    d += "Minimum Raise of Insolation for Start-Up [W/m²]:"
      >< "\(minInsolationRaiseStartUp)"
    d += "Iteration Tolerance for Electrical Production meeting demand [MW]:"
      >< "\(heatTolerance)"
    d += "Tolerance for Temperature Iteration [K]:"
      >< "\(tempTolerance)"
    d += "Tolerance for Time Iteration [min]:"
      >< "\(timeTolerance)"
    d += "Tolerance for Mass Iteration [kg]:"
      >< "\(massTolerance)"
    d += "Minimum Insolation for Start-Up [W/m²]:"
      >< "\(minInsolation)"
    d += "Adjustment factor for Solar Field Efficiency:"
      >< "\(adjustmentFactor.efficiencySolarField)"
    d += "Adjustment factor for HCE heat Losses:"
      >< "\(adjustmentFactor.heatLossHCE)"
    d += "Adjustment factor for Heat Losses in Piping and HTF- System:"
      >< "\(adjustmentFactor.heatLossHTF)"
    d += "Adjustment factor for Heat Losses in Power Block:"
      >< "\(adjustmentFactor.heatLossH2O)"
    d += "Adjustment factor for Turbine Efficiency:"
      >< "\(adjustmentFactor.efficiencyTurbine)"
    d += "Adjustment factor for Parasitic Power:"
      >< "\(adjustmentFactor.electricalParasitics)"
    d += "Maximal heat input to power block (Boiler Operation):"
      >< "\(maxToPowerBlock)"
    d += "Minimal heat from solar field for boiler start-up:"
      >< "\(minInsolationForBoiler)"
    d += "Iteration Tolerance for Electrical Production [MW]:"
      >< "\(electricalTolerance)"
    d += "Iteration Start Value for Parasitics [% of production]:"
      >< "\(electricalParasitics * 100)"
    d += "Tolerance for Temperature Drop in Hot Header Iteration [K]:"
      >< "\(HLtempTolerance)"
    return d
  }
}

extension Simulation.Parameter: TextConfigInitializable {
  
  public init(file: TextConfigFile)throws {
    let row: (Int)throws -> Double = { try file.double(row: $0) }
    let adjustmentFactor = Simulation.AdjustmentFactor(
      efficiencySolarField: try row(34),
      efficiencyTurbine: try row(46),
      efficiencyHeater: try row(52),
      efficiencyBoiler: try row(55),
      heatLossHCE: try row(61),
      heatLossHTF: try row(40),
      heatLossH2O: try row(43),
      electricalParasitics: try row(61) / 100)

    self = Simulation.Parameter(
      dfreezeTemperaturePump: try row(6),
      dfreezeTemperatureHeat: try row(9),
      minTemperatureRaiseStartUp: try row(12),
      minInsolationRaiseStartUp: try row(16),
      heatTolerance: try row(18),
      tempTolerance: try row(21),
      timeTolerance: try row(24),
      massTolerance: try row(27),
      minInsolation: try row(31),
      maxToPowerBlock: try row(15),
      minInsolationForBoiler: try row(16),
      electricalTolerance: try row(58),
      electricalParasitics: try row(18),
      HLtempTolerance: 0.1,
      adjustmentFactor: adjustmentFactor)
  }
}

