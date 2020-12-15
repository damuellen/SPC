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

extension Simulation {
  public struct Parameter: Codable {
    let dfreezeTemperaturePump, dfreezeTemperatureHeat,
      minTemperatureRaiseStartUp, tempTolerance: Temperature
    let minInsolationRaiseStartUp, heatTolerance, timeTolerance, massTolerance,
      minInsolation, maxToPowerBlock, minInsolationForBoiler,
      electricalTolerance, electricalParasitics, HLtempTolerance: Double
    public var adjustmentFactor: AdjustmentFactors
  }

  public struct AdjustmentFactors: Codable {
    public var efficiencySolarField, efficiencyTurbine, efficiencyHeater,
      efficiencyBoiler, heatLossHCE, heatLossHTF, heatLossH2O,
      electricalParasitics: Double
  }
}

extension Simulation.AdjustmentFactors: CustomStringConvertible {
  public var description: String {
    "Adjustment factor for Solar Field Efficiency:" * efficiencySolarField.description
    + "Adjustment factor for HCE heat Losses:" * heatLossHCE.description
    + "Adjustment factor for Heat Losses in Piping and HTF- System:" * heatLossHTF.description
    + "Adjustment factor for Heat Losses in Power Block:" * heatLossH2O.description
    + "Adjustment factor for Turbine Efficiency:" * efficiencyTurbine.description
    + "Adjustment factor for Parasitic Power:" * electricalParasitics.description
  }
}

extension Simulation.Parameter: CustomStringConvertible {
  public var description: String {
    "Delta T for Start-Up of Anti-Freeze Pumping:"
    * dfreezeTemperaturePump.celsius.description
    + "Delta T for Start-Up of Anti-Freeze Heating:"
    * dfreezeTemperatureHeat.celsius.description
    + "Minimum Raise of Temperature for Start-Up [K]:"
    * minTemperatureRaiseStartUp.celsius.description
    + "Minimum Raise of Insolation for Start-Up [W/m²]:"
    * minInsolationRaiseStartUp.description
    + "Iteration Tolerance for Electrical Production meeting demand [MW]:"
    * heatTolerance.description
    + "Tolerance for Temperature Iteration [K]:" * tempTolerance.description
    + "Tolerance for Time Iteration [min]:" * timeTolerance.description
    + "Tolerance for Mass Iteration [kg]:" * massTolerance.description
    + "Minimum Insolation for Start-Up [W/m²]:" * minInsolation.description
    + "\(adjustmentFactor)"
    + "Maximal heat input to power block (Boiler Operation):"
    * maxToPowerBlock.description
    + "Minimal heat from solar field for boiler start-up:"
    * minInsolationForBoiler.description
    + "Iteration Tolerance for Electrical Production [MW]:"
    * electricalTolerance.description
    + "Iteration Start Value for Parasitics [% of production]:"
    * "\(electricalParasitics * 100)"
    + "Tolerance for Temperature Drop in Hot Header Iteration [K]:"
    * HLtempTolerance.description
  }
}

extension Simulation.Parameter: TextConfigInitializable {
  public init(file: TextConfigFile) throws {
    let ln: (Int) throws -> Double = { try file.double(line: $0) }
    let adjustmentFactor = try Simulation.AdjustmentFactors(
      efficiencySolarField: ln(34),
      efficiencyTurbine: ln(46),
      efficiencyHeater: ln(52),
      efficiencyBoiler: ln(55),
      heatLossHCE: ln(61),
      heatLossHTF: ln(40),
      heatLossH2O: ln(43),
      electricalParasitics: ln(61) / 100
    )

    self = try Simulation.Parameter(
      dfreezeTemperaturePump: Temperature(celsius: ln(7)),
      dfreezeTemperatureHeat: Temperature(celsius: ln(10)),
      minTemperatureRaiseStartUp: Temperature(celsius: ln(13)),
      tempTolerance: Temperature(ln(22)),
      minInsolationRaiseStartUp: ln(16),
      heatTolerance: ln(19),
      timeTolerance: ln(25),
      massTolerance: ln(28),
      minInsolation: ln(31),
      maxToPowerBlock: ln(16),
      minInsolationForBoiler: ln(16),
      electricalTolerance: ln(58),
      electricalParasitics: ln(19),
      HLtempTolerance: 0.1,
      adjustmentFactor: adjustmentFactor
    )
  }
}
