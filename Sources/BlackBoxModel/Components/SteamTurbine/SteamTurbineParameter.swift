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
    let efficiency, efficiencyTemperature: Coefficients
    let startUpTime, startUpEnergy: Double
    let minPowerFromTemp: Coefficients
    let hotStartUpTime: Double
    let efficiencyWetBulb: Coefficients
    let WetBulbTstep: Double
    var efficiencytempIn_A: Double
    var efficiencytempIn_B: Double
    var efficiencytempIn_cf: Double
  }
}

extension SteamTurbine.Parameter: CustomStringConvertible {
  public var description: String {
    var d: String = ""
    d += "Description:\t\(name)\n"
    d += "Maximum Electrical Power [MW]:"
      >< "\(power.max)"
    d += "Minimum Electrical Power (nominal) [MW]:"
      >< "\(power.nominal)"
    d += "Minimum Electrical Power (lower limit) [MW] :"
      >< "\(power.min)"
    d += "Min. Power;\nPower(Tamb) = PowerNom*(c0+c1*Tamb+c2*Tamb^2+c3*Tamb^3+c4*Tamb^4)\n"
    for (i, c) in minPowerFromTemp.coefficients.enumerated() {
      d += "c\(i):" >< String(format: "%.6E", c)
    }
    d += "Efficiency in Solar Mode:"
      >< "\(efficiencyNominal * 100)"
    d += "Efficiency in Boiler Mode:"
      >< "\(efficiencyBoiler * 100)"
    d += "Efficiency in IsccS Mode:"
      >< "\(efficiencySCC * 100)"
    d += "Efficiency;\nEfficiency(Load) = c0+c1*load+c2*load^2+c3*load^3+c4*load^4\n"
    for (i, c) in efficiency.coefficients.enumerated() {
      d += "c\(i):" >< String(format: "%.6E", c)
    }
    d += "Efficiency;\nEfficiency(Temperature) = c0+c1*T+c2*T^2+c3*T^3+c4*T^4\n"
    for (i, c) in efficiencyTemperature.coefficients.enumerated() {
      d += "c\(i):" >< String(format: "%.6E", c)
    }
    d += "Efficiency;\nEfficiency(Wet Bulb Temp.) = c0+c1*T+c2*T^2\n"
    d += "Below Wet Bulb Temperature: (°C)"
      >< "(WetBulbTstep)"
    d += "c0:" >< "\(efficiencyWetBulb[0])"
    d += "c1:" >< "\(efficiencyWetBulb[1])"
    d += "c2:" >< "\(efficiencyWetBulb[2])"
    d += "Above Wet Bulb Temperature: (°C)"
      >< "(WetBulbTstep)"
    d += "c0:" >< "\(efficiencyWetBulb[3])"
    d += "c1:" >< "\(efficiencyWetBulb[4])"
    d += "c2:" >< "\(efficiencyWetBulb[5])"
    d += "Efficiency;\nEfficiency(HTF_Tin) = A * HTF_Tin ( °C ) ^ B * corrFactor\n"
    d += "A" >< "\(efficiencytempIn_A)"
    d += "B" >< "\(efficiencytempIn_B)"
    d += "corr factor:"
      >< "\(efficiencytempIn_cf)"
    d += "Time for Start-Up [min]:"
      >< "\(startUpTime)"
    d += "Energy for Start-Up [MWh]:"
      >< "\(startUpEnergy)"
    d += "Stand Still Time for Hot Start-up <= [min]:"
      >< "\(hotStartUpTime)"
    return d
  }
}

extension SteamTurbine.Parameter: TextConfigInitializable {
  public init(file: TextConfigFile) throws {
    let row: (Int) throws -> Double = { try file.parseDouble(row: $0) }
    name = file.name
    power = try .init(range: row(10) ... row(13), nom: 0)
    efficiencyNominal = try row(32)
    efficiencyBoiler = try row(35)
    efficiencySCC = try row(38)
    efficiency = try [row(45), row(48), row(51), row(54), row(57)]
    efficiencyTemperature = try [row(64), row(67), row(70), row(73), row(76)]
    startUpTime = try row(83)
    startUpEnergy = try row(86)
    minPowerFromTemp = [0, 0, 0, 0, 0]
    hotStartUpTime = 0
    efficiencyWetBulb = .init(values: 0, 0, 0, 0, 0, 0)
    WetBulbTstep = 0
    efficiencytempIn_A = 0
    efficiencytempIn_B = 0
    efficiencytempIn_cf = 0
  }
}
