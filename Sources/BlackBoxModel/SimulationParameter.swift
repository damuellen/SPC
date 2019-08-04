//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Config
import Foundation

extension Simulation {
  public struct Parameter: Codable {
    let dfreezeTemperaturePump, dfreezeTemperatureHeat,
      minTemperatureRaiseStartUp, tempTolerance: Temperature
    let minInsolationRaiseStartUp, heatTolerance, timeTolerance, massTolerance,
      minInsolation, maxToPowerBlock, minInsolationForBoiler,
      electricalTolerance, electricalParasitics, HLtempTolerance: Double
    public var adjustmentFactor: AdjustmentFactor
  }

  public struct AdjustmentFactor: Codable {
    public var efficiencySolarField, efficiencyTurbine, efficiencyHeater,
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
  public init(file: TextConfigFile) throws {
    let line: (Int) throws -> Double = { try file.parseDouble(line: $0) }
    let adjustmentFactor = try Simulation.AdjustmentFactor(
      efficiencySolarField: line(34),
      efficiencyTurbine: line(46),
      efficiencyHeater: line(52),
      efficiencyBoiler: line(55),
      heatLossHCE: line(61),
      heatLossHTF: line(40),
      heatLossH2O: line(43),
      electricalParasitics: line(61) / 100
    )

    self = try Simulation.Parameter(
      dfreezeTemperaturePump: Temperature(celsius: line(7)),
      dfreezeTemperatureHeat: Temperature(celsius: line(10)),
      minTemperatureRaiseStartUp: Temperature(celsius: line(13)),
      tempTolerance: Temperature(line(22)),
      minInsolationRaiseStartUp: line(16),
      heatTolerance: line(19),
      timeTolerance: line(25),
      massTolerance: line(28),
      minInsolation: line(31),
      maxToPowerBlock: line(16),
      minInsolationForBoiler: line(16),
      electricalTolerance: line(58),
      electricalParasitics: line(19),
      HLtempTolerance: 0.1,
      adjustmentFactor: adjustmentFactor
    )
  }
}
