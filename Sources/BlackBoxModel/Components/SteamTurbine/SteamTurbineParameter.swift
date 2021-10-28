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
import Physics

extension SteamTurbine {
  public struct Parameter: Codable {
    let name: String
    var power: PowerRange
    let efficiencyNominal, efficiencyBoiler, efficiencySCC: Double
    let efficiency, efficiencyTemperature: Polynomial
    let startUpTime: Int
    let startUpEnergy: Double
    let minPowerFromTemp: Polynomial
    var hotStartUpTime: Int = 75
    let efficiencyWetBulb: Polynomial
    let WetBulbTstep: Double
    var efficiencyTempIn_A: Double
    var efficiencyTempIn_B: Double
    var efficiencyTempIn_cf: Double
  }
}

extension SteamTurbine.Parameter: CustomStringConvertible {
  public var description: String {
    "Description:" * name
    + "Maximum Electrical Power [MW]:" * power.max.description
    + "Minimum Electrical Power (nominal) [MW]:" * power.nominal.description
    + "Minimum Electrical Power (lower limit) [MW] :" * power.min.description
    + "Min. Power;\nPower(Tamb) = PowerNom*(c0+c1*Tamb+c2*Tamb^2+c3*Tamb^3+c4*Tamb^4)"
    + "\n\(minPowerFromTemp)"
    + "Efficiency in Solar Mode:" * (efficiencyNominal * 100).description
    + "Efficiency in Boiler Mode:" * (efficiencyBoiler * 100).description
    + "Efficiency in IsccS Mode:" * (efficiencySCC * 100).description
    + "Efficiency;\nEfficiency(Load) = c0+c1*load+c2*load^2+c3*load^3+c4*load^4"
    + "\n\(efficiency)"
    + "Efficiency;\nEfficiency(Temperature) = c0+c1*T+c2*T^2+c3*T^3+c4*T^4"
    + "\n\(efficiencyTemperature)"
    + "Efficiency;\nEfficiency(Wet Bulb Temp.) = c0+c1*T+c2*T^2\n"
    + "Below Wet Bulb Temperature: (°C)" * "(WetBulbTstep)"
    + "c0:" * efficiencyWetBulb[0].description
    + "c1:" * efficiencyWetBulb[1].description
    + "c2:" * efficiencyWetBulb[2].description
    + "Above Wet Bulb Temperature: (°C)" * "(WetBulbTstep)"
    + "c0:" * efficiencyWetBulb[3].description
    + "c1:" * efficiencyWetBulb[4].description
    + "c2:" * efficiencyWetBulb[5].description
    + "Efficiency;\nEfficiency(HTF_Tin) = A * HTF_Tin ( °C ) ^ B * corrFactor\n"
    + "A" * efficiencyTempIn_A.description
    + "B" * efficiencyTempIn_B.description
    + "corr factor:" * efficiencyTempIn_cf.description
    + "Time for Start-Up [min]:" * startUpTime.description
    + "Energy for Start-Up [MWh]:" * startUpEnergy.description
    + "Stand Still Time for Hot Start-up <= [min]:"
    * hotStartUpTime.description
  }
}

extension SteamTurbine.Parameter: TextConfigInitializable {
  public init(file: TextConfigFile) throws {
    let ln: (Int) throws -> Double = { try file.double(line: $0) }
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
