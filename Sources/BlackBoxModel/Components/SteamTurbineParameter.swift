// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import Utilities

extension SteamTurbine {
  /// A struct representing the parameters of the steam turbine.
  struct Parameter: Codable {
    /// The name of the steam turbine parameter set.
    let name: String
    /// The power range of the steam turbine.
    var power: PowerRange
    /// The nominal efficiency of the steam turbine in solar mode.
    let efficiencyNominal: Double
    /// The efficiency of the steam turbine in boiler mode.
    let efficiencyBoiler: Double
    /// The efficiency of the steam turbine in ISCCS mode.
    let efficiencySCC: Double
    /// The efficiency of the steam turbine with respect to load.
    let efficiency: Polynomial
    /// The efficiency of the steam turbine with respect to temperature.
    let efficiencyTemperature: Polynomial
    /// The time required for the steam turbine start-up (in minutes).
    let startUpTime: Int
    /// The energy required for the steam turbine start-up (in MWh).
    let startUpEnergy: Double
    /// The minimum power output of the steam turbine with respect to temperature.
    let minPowerFromTemp: Polynomial
    /// The time required for hot start-up (in minutes).
    var hotStartUpTime: Int = 75
    /// The efficiency of the steam turbine with respect to wet bulb temperature.
    let efficiencyWetBulb: Polynomial
    /// The step size of wet bulb temperature (in °C).
    let WetBulbTstep: Double
    /// The coefficient 'A' of the efficiency equation with respect to HTF_Tin.
    var efficiencyTempIn_A: Double
    /// The coefficient 'B' of the efficiency equation with respect to HTF_Tin.
    var efficiencyTempIn_B: Double
    /// The correction factor of the efficiency equation with respect to HTF_Tin.
    var efficiencyTempIn_cf: Double
  }
}

extension SteamTurbine.Parameter: CustomStringConvertible {
  /// A description of the `SteamTurbine.Parameter` instance.
  public var description: String {
    "Description:" * name + "Maximum Electrical Power [MW]:"
      * power.max.description + "Minimum Electrical Power (nominal) [MW]:"
      * power.nominal.description
      + "Minimum Electrical Power (lower limit) [MW]:" * power.min.description
      + "Min. Power;\nPower(Tamb) = PowerNom*(c0+c1*Tamb+c2*Tamb^2+c3*Tamb^3+c4*Tamb^4)"
      + "\n\(minPowerFromTemp)" + "Efficiency in Solar Mode:"
      * (efficiencyNominal * 100).description + "Efficiency in Boiler Mode:"
      * (efficiencyBoiler * 100).description + "Efficiency in ISCCS Mode:"
      * (efficiencySCC * 100).description
      + "Efficiency;\nEfficiency(Load) = c0+c1*load+c2*load^2+c3*load^3+c4*load^4"
      + "\n\(efficiency)"
      + "Efficiency;\nEfficiency(Temperature) = c0+c1*T+c2*T^2+c3*T^3+c4*T^4"
      + "\n\(efficiencyTemperature)"
      + "Efficiency;\nEfficiency(Wet Bulb Temp.) = c0+c1*T+c2*T^2\n"
      + "Below Wet Bulb Temperature (°C):" * "\(WetBulbTstep)" + "c0:"
      * efficiencyWetBulb[0].description + "c1:"
      * efficiencyWetBulb[1].description + "c2:"
      * efficiencyWetBulb[2].description + "Above Wet Bulb Temperature (°C):"
      * "\(WetBulbTstep)" + "c0:" * efficiencyWetBulb[3].description + "c1:"
      * efficiencyWetBulb[4].description + "c2:"
      * efficiencyWetBulb[5].description
      + "Efficiency;\nEfficiency(HTF_Tin) = A * HTF_Tin ( °C ) ^ B * corrFactor\n"
      + "A" * efficiencyTempIn_A.description + "B"
      * efficiencyTempIn_B.description + "Correction Factor:"
      * efficiencyTempIn_cf.description + "Time for Start-Up [min]:"
      * startUpTime.description + "Energy for Start-Up [MWh]:"
      * startUpEnergy.description
      + "Stand Still Time for Hot Start-up <= [min]:"
      * hotStartUpTime.description
  }
}

extension SteamTurbine.Parameter: TextConfigInitializable {
  /// Creates a `SteamTurbine.Parameter` instance using the data from a `TextConfigFile`.
  /// - Parameter file: The `TextConfigFile` containing the data for the parameter.
  init(file: TextConfigFile) throws {
    let ln: (Int) throws -> Double = { try file.readDouble(lineNumber: $0) }
    name = file.name
    power = try .init(range: ln(13)...ln(10), nom: 0)
    efficiencyNominal = try ln(32) / 100
    efficiencyBoiler = try ln(35) / 100
    efficiencySCC = try ln(38)
    efficiency = try [ln(45), ln(48), ln(51), ln(54), ln(57)]
    efficiencyTemperature = try [ln(64), ln(67), ln(70), ln(73), ln(76)]
    startUpTime = try Int(ln(83))
    startUpEnergy = try ln(86)
    minPowerFromTemp = [1]
    hotStartUpTime = 75
    efficiencyWetBulb = [0, 0, 0, 0, 0, 0]
    WetBulbTstep = 0
    efficiencyTempIn_A = 0.2383
    efficiencyTempIn_B = 0.2404
    efficiencyTempIn_cf = 1
  }
}
