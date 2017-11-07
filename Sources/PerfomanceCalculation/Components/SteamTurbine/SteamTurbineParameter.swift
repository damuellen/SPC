//
//  Copyright (c) 2017 Daniel Müllenborn. All rights reserved.
//  Distributed under the The Non-Profit Open Software License version 3.0
//  http://opensource.org/licenses/NPOSL-3.0
//
//  This project is NOT free software. It is open source, you are allowed to
//  modify it (if you keep the license), but it may not be commercially
//  distributed other than under the conditions noted above.
//

import Config

extension SteamTurbine {
  public struct Parameter: ComponentParameter, Codable {
    let name: String
    var power: PowerRange
    let efficiencyNominal, efficiencyBoiler, efficiencySCC: Double
    let efficiency, efficiencyTemperature: Coefficients
    let startUpTime, startUpEnergy: Double
    let PminT: [Double]
    //let PminfT: Double
    let PminLim, hotStartUpTime: Double
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
      >< "\(power.min)"
    d += "Minimum Electrical Power (lower limit) [MW] :"
      >< "\(PminLim)"
    d += "Min. Power; Power(Tamb) = PowerNom*(c0+c1*Tamb+c2*Tamb^2+c3*Tamb^3+c4*Tamb^4)\n"
    d += "c0:" >< "\(PminT[0])"
    d += "c1:" >< "\(PminT[1])"
    d += "c2:" >< "\(PminT[2])"
    d += "c3:" >< "\(PminT[3])"
    d += "c4:" >< "\(PminT[4])"
    d += "Efficiency in Solar Mode:"
      >< "\(efficiencyNominal * 100)"
    d += "Efficiency in Boiler Mode:"
      >< "\(efficiencyBoiler * 100)"
    d += "Efficiency in ISCCS Mode:"
      >< "\(efficiencySCC * 100)"
    d += "Efficiency; Efficiency(Load) = c0+c1*load+c2*load^2+c3*load^3+c4*load^4\n"
    d += "c0:" >< "\(efficiency[0])"
    d += "c1:" >< "\(efficiency[1])"
    d += "c2:" >< "\(efficiency[2])"
    d += "c3:" >< "\(efficiency[3])"
    d += "c4:" >< "\(efficiency[4])"
    d += "Efficiency; Efficiency(Temperature) = c0+c1*T+c2*T^2+c3*T^3+c4*T^4\n"
    d += "c0:" >< "\(efficiencyTemperature[0])"
    d += "c1:" >< "\(efficiencyTemperature[1])"
    d += "c2:" >< "\(efficiencyTemperature[2])"
    d += "c3:" >< "\(efficiencyTemperature[3])"
    d += "c4:" >< "\(efficiencyTemperature[4])"
    d += "Efficiency; Efficiency(Wet Bulb Temp.) = c0+c1*T+c2*T^2\n"
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
    d += "Efficiency; Efficiency(HTF_Tin) = A * HTF_Tin ( °C ) ^ B * corrFactor\n"
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
  public init(file: TextConfigFile)throws {
    let row: (Int)throws -> Double = { try file.parseDouble(row: $0) }
    self.name = file.name
    self.power = try .init(range: row(10) ... row(13))
    self.efficiencyNominal = try row(32)
    self.efficiencyBoiler = try row(35)
    self.efficiencySCC = try row(38)
    self.efficiency = try [row(45), row(48), row(51), row(54), row(57)]
    self.efficiencyTemperature = try [row(64), row(67), row(70), row(73), row(76)]
    self.startUpTime = try row(83)
    self.startUpEnergy = try row(86)
    self.PminT = [0, 0, 0, 0, 0]
    self.PminLim = 0
    self.hotStartUpTime = 0
    self.efficiencyWetBulb = .init(values: 0, 0, 0, 0, 0, 0)
    self.WetBulbTstep = 0
    self.efficiencytempIn_A = 0
    self.efficiencytempIn_B = 0
    self.efficiencytempIn_cf = 0
  }
}
