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

extension SteamTurbine {
  public struct Parameter: ComponentParameter, Codable {
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
    "Description:" >< name
    + "Maximum Electrical Power [MW]:" >< "\(power.max)"
    + "Minimum Electrical Power (nominal) [MW]:" >< "\(power.nominal)"
    + "Minimum Electrical Power (lower limit) [MW] :" >< "\(power.min)"
    + "Min. Power;\nPower(Tamb) = PowerNom*(c0+c1*Tamb+c2*Tamb^2+c3*Tamb^3+c4*Tamb^4)"
    + "\n\(minPowerFromTemp)"
    + "Efficiency in Solar Mode:" >< "\(efficiencyNominal * 100)"
    + "Efficiency in Boiler Mode:" >< "\(efficiencyBoiler * 100)"
    + "Efficiency in IsccS Mode:" >< "\(efficiencySCC * 100)"
    + "Efficiency;\nEfficiency(Load) = c0+c1*load+c2*load^2+c3*load^3+c4*load^4"
    + "\n\(efficiency)"
    + "Efficiency;\nEfficiency(Temperature) = c0+c1*T+c2*T^2+c3*T^3+c4*T^4"
    + "\n\(efficiencyTemperature)"
    + "Efficiency;\nEfficiency(Wet Bulb Temp.) = c0+c1*T+c2*T^2\n"
    + "Below Wet Bulb Temperature: (°C)" >< "(WetBulbTstep)"
    + "c0:" >< "\(efficiencyWetBulb[0])"
    + "c1:" >< "\(efficiencyWetBulb[1])"
    + "c2:" >< "\(efficiencyWetBulb[2])"
    + "Above Wet Bulb Temperature: (°C)" >< "(WetBulbTstep)"
    + "c0:" >< "\(efficiencyWetBulb[3])"
    + "c1:" >< "\(efficiencyWetBulb[4])"
    + "c2:" >< "\(efficiencyWetBulb[5])"
    + "Efficiency;\nEfficiency(HTF_Tin) = A * HTF_Tin ( °C ) ^ B * corrFactor\n"
    + "A" >< "\(efficiencyTempIn_A)"
    + "B" >< "\(efficiencyTempIn_B)"
    + "corr factor:" >< "\(efficiencyTempIn_cf)"
    + "Time for Start-Up [min]:" >< "\(startUpTime)"
    + "Energy for Start-Up [MWh]:" >< "\(startUpEnergy)"
    + "Stand Still Time for Hot Start-up <= [min]:"
    >< "\(hotStartUpTime)"
  }
}

extension SteamTurbine.Parameter: TextConfigInitializable {
  public init(file: TextConfigFile) throws {
    let line: (Int) throws -> Double = { try file.parseDouble(line: $0) }
    name = file.name
    power = try .init(range: line(13)...line(10), nom: 0)
    efficiencyNominal = try line(32) / 100
    efficiencyBoiler = try line(35) / 100
    efficiencySCC = try line(38)
    efficiency = try [line(45), line(48), line(51), line(54), line(57)]
    efficiencyTemperature = try [line(64), line(67), line(70), line(73), line(76)]
    startUpTime = try Int(line(83))
    startUpEnergy = try line(86)
    minPowerFromTemp = [1]
    hotStartUpTime = 75
    efficiencyWetBulb = .init(values: 0, 0, 0, 0, 0, 0)
    WetBulbTstep = 0
    efficiencyTempIn_A = 0
    efficiencyTempIn_B = 0
    efficiencyTempIn_cf = 0
  }
}
