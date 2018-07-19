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
import Config

extension Simulation {
  public struct Parameter: Codable  {
    let dfreezeTemperaturePump, dfreezeTemperatureHeat,
    minTemperatureRaiseStartUp, tempTolerance: Temperature
    let minInsolationRaiseStartUp, heatTolerance, timeTolerance, massTolerance,
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
    let row: (Int)throws -> Double = { try file.parseDouble(row: $0) }
    let adjustmentFactor = try Simulation.AdjustmentFactor(
      efficiencySolarField: row(34),
      efficiencyTurbine: row(46),
      efficiencyHeater: row(52),
      efficiencyBoiler: row(55),
      heatLossHCE: row(61),
      heatLossHTF: row(40),
      heatLossH2O: row(43),
      electricalParasitics: row(61) / 100)

    self = try Simulation.Parameter(
      dfreezeTemperaturePump: Temperature(celsius: row(7)),
      dfreezeTemperatureHeat: Temperature(celsius: row(10)),
      minTemperatureRaiseStartUp: Temperature(celsius: row(13)),
      tempTolerance: Temperature(row(22)),
      minInsolationRaiseStartUp: row(16),
      heatTolerance: row(19),
      timeTolerance: row(25),
      massTolerance: row(28),
      minInsolation: row(31),
      maxToPowerBlock: row(16),
      minInsolationForBoiler: row(16),
      electricalTolerance: row(58),
      electricalParasitics: row(19),
      HLtempTolerance: 0.1,
      adjustmentFactor: adjustmentFactor)
  }
}

