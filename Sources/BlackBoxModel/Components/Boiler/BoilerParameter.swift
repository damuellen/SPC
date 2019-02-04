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
    d += "Parasitic Energy Coefficients;\nParasitics(Load) = Parasitics(100%)*(c0+c1*load)"
    d += "c0:" >< "\(electricalParasitics[0])"
    d += "c1:" >< "\(electricalParasitics[1])"
    d += "Efficiency;\nEfficiency(Load) = c0+c1*load+c2*load^2+c3*load^3+c4*load^4)"
    for (i, c) in efficiency.coefficients.enumerated() {
      d += "c\(i):" >< String(format: "%.6E", c)
    }
    d += "Booster Superheater (if NO regular boiler selected):"
      >< (booster ? "YES" : "NO")
    return d
  }
}

extension Boiler.Parameter: TextConfigInitializable {
  public init(file: TextConfigFile) throws {
    let row: (Int) throws -> Double = { try file.parseDouble(row: $0) }
    name = file.name
    nominalTemperatureOut = try row(10)
    minLoad = try row(13)
    start = try .init(hours: .init(cold: row(16), warm: row(25)),
                      energy: .init(cold: row(22), warm: row(31)))
    nominalElectricalParasitics = try row(34)
    electricalParasitics = try [row(37), row(40)]
    efficiency = try [row(50), row(53), row(56), row(59), row(62)]
  }
}
