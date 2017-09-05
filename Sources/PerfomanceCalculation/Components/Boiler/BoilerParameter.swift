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

extension Boiler {
  public struct Parameter: ComponentParameter, Codable {
    let name: String
    let nominalTemperatureOut, minLoad, nominalElectricalParasitics: Double
    
    public struct StartParameter: Codable {
      public struct Values: Codable {
        let cold, warm: Double
      }
      let hours: Values
      let energy: Values
    }
    
    let start: StartParameter
    let electricalParasitics, efficiency: Coefficients
    let booster = true
  }
}

extension Boiler.Parameter: CustomStringConvertible {
  public var description: String {

    var d: String = ""
    d += "Nominal Outlet Temperature [°]:"
      >< "\(nominalTemperatureOut)"
    d += "Minimum Load [%]:"
      >< "\(minLoad * 100)"
    d += "Cold Start-up necessary after [h]:"
      >< "\(start.hours.cold)"
    d += "Energy needed for Cold Start-up [MWh]:"
      >< "\(start.energy.cold)"
    d += "Warm Start-up necessary after [h]:"
      >< "\(start.hours.warm)"
    d += "Energy needed for Warm Start-up [MWh]:"
      >< "\(start.energy.warm)"
    d += "Parasitics at Full Load [MW]:"
      >< "\(nominalElectricalParasitics)"
    d += "Parasitic Energy Coefficients; Parasitics(Load) = Parasitics(100%)*(c0+c1*load)"
    d += "c0:" >< "\(electricalParasitics[0])"
    d += "c1:" >< "\(electricalParasitics[1])"
    d += "Efficiency; Efficiency(Load) = c0+c1*load+c2*load^2+c3*load^3+c4*load^4)"
    d += "c0:" >< "\(efficiency[0])"
    d += "c1:" >< "\(efficiency[1])"
    d += "c2:" >< "\(efficiency[2])"
    d += "c3:" >< "\(efficiency[3])"
    d += "c4:" >< "\(efficiency[4])"
    d += "Booster Superheater (if NO regular boiler selected):"
      >< (booster ? "YES" : "NO")
    return d
  }
}

extension Boiler.Parameter: TextConfigInitializable {
  public init(file: TextConfigFile)throws {
    let row: (Int)throws -> Double = { try file.parseDouble(row: $0) }
    self.name = file.name
    self.nominalTemperatureOut = try row(10)
    self.minLoad = try row(13)
    self.start = try .init(hours: .init(cold: row(16), warm: row(25)),
                           energy: .init(cold: row(22), warm: row(31)))
    self.nominalElectricalParasitics = try row(34)
    self.electricalParasitics = try [row(37), row(40)]
    self.efficiency = try [row(50), row(53), row(56), row(59), row(62)]
  }
}
