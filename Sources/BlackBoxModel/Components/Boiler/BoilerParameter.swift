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

extension Boiler {
  public struct Parameter: ComponentParameter, Codable, Equatable {
    let name: String
    let nominalTemperatureOut, minLoad, nominalElectricalParasitics: Double

    public struct StartParameter: Codable, Equatable {
      public struct Values: Codable, Equatable {
        let cold, warm: Double
      }
      let hours: Values
      let energy: Values
    }

    let start: StartParameter
    let electricalParasitics, efficiency: Polynomial
    var booster = true
  }
}

extension Boiler.Parameter: CustomStringConvertible {
  public var description: String {
    "Nominal Outlet Temperature [°]:" >< "\(nominalTemperatureOut)"
    + "Minimum Load [%]:" >< "\(minLoad * 100)"
    + "Cold Start-up necessary after [h]:" >< "\(start.hours.cold)"
    + "Energy needed for Cold Start-up [MWh]:" >< "\(start.energy.cold)"
    + "Warm Start-up necessary after [h]:" >< "\(start.hours.warm)"
    + "Energy needed for Warm Start-up [MWh]:" >< "\(start.energy.warm)"
    + "Parasitics at Full Load [MW]:" >< "\(nominalElectricalParasitics)"
    + "Parasitic Energy Coefficients; "
    + "Parasitics(Load) = Parasitics(100%)*(c0+c1*load)\n"
    + "c0:" >< "\(electricalParasitics[0])"
    + "c1:" >< "\(electricalParasitics[1])"
    + "Efficiency; "
    + "Efficiency(Load) = c0+c1*load+c2*load^2+c3*load^3+c4*load^4)\n"
    + "\(efficiency)"
    + "Booster Superheater (if NO regular boiler selected):"
    >< (booster ? "YES" : "NO")
  }
}

extension Boiler.Parameter: TextConfigInitializable {
  public init(file: TextConfigFile) throws {
    let line: (Int) throws -> Double = { try file.parseDouble(line: $0) }
    name = file.name
    nominalTemperatureOut = try line(10)
    minLoad = try line(13)
    start = try .init(hours: .init(cold: line(16), warm: line(25)),
                      energy: .init(cold: line(22), warm: line(31)))
    nominalElectricalParasitics = try line(34)
    electricalParasitics = try [line(37), line(40)]
    efficiency = try [line(50), line(53), line(56), line(59), line(62)]
  }
}
