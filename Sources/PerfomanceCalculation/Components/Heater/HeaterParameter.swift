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

extension Heater {
  public struct Parameter: ComponentParameter, Codable {
    let name: String
    let efficiency, antiFreezeTemperature,
    nomTemperatureOut, maxMassFlow, minLoad,
    nominalElectricalParasitics: Double
    let electricalParasitics: [Double]
    let onlyWithSolarField: Bool
  }
}

extension Heater.Parameter: CustomStringConvertible {
  public var description: String {
    var d: String = ""
    d += "Description:\t\(name)\n"
    d += "Capacity of HTF-Heater [MW]: \t\(Design.layout.heater)"
    d += "Efficiency [%]:"
      >< "\(efficiency)"
    d += "Outlet Temperature for Freeze Protection [°]:"
      >< "\(antiFreezeTemperature)"
    d += "Nominal Outlet Temperature [°]:"
      >< "\(nomTemperatureOut)"
    d += "Maximum Mass Flow [kg/s]:"
      >< "\(maxMassFlow)"
    d += "Minimum Load [%]:"
      >< "\(minLoad)"
    d += "Parasitics at Full Load [MW]:"
      >< "\(nominalElectricalParasitics)"
    d += "Parasitic Energy Coefficients; Parasitics(Load) = Parasitics(100%)*(c0+c1*load)"
    d += "c0:" >< "\(electricalParasitics[0])"
    d += "c1:" >< "\(electricalParasitics[1])"
    d += "Use Heater in Parallel to SF:"
      >< (onlyWithSolarField ? "YES" : "NO ")
    return d
  }
}

extension Heater.Parameter: TextConfigInitializable {
  public init(file: TextConfigFile)throws {
    let row: (Int)throws -> Double = { try file.parseDouble(row: $0) }
    self.name = file.name
    self.efficiency = try row(10)
    self.antiFreezeTemperature = try row(16)
    self.nomTemperatureOut = try row(19)
    self.maxMassFlow = try row(22)
    self.minLoad = try row(25)
    self.nominalElectricalParasitics = try row(28)
    self.electricalParasitics = [try row(31), try row(34)]
    self.onlyWithSolarField = false
  }
}

