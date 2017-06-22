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

extension WasteHeatRecovery {
  public struct Parameter: ModelParameter, Codable {
    let name: String
    let operation: Operation
    
    public enum Operation: String, Codable {
      case pure, integrated
    }
    
    let efficiencyNominal: Double
    let efficiencyPure: Double
    var ratioHTF: Double
    let efficiencySolar: Coefficients
    let efficiencyGasTurbine: Coefficients
  }
}

extension WasteHeatRecovery.Parameter: CustomStringConvertible {
  public var description: String {
    var d = ""
    d += "Operation Mode :" >< operation.rawValue
    d += "Efficiency in Hybrid Mode :" >< "\(efficiencyNominal * 100)"
    d += "Efficiency in CC Mode:" >< "\(efficiencyPure * 100)"
    d += "Ratio Fossil/Solar Thermal Contribution :" >< "\(ratioHTF)"
    d += "Efficiency(Solar-Load) = c0+c1*load+c2*load^2+c3*load^3+c4*load^4)\n"
    d += "c0:" >< "\(efficiencySolar[0])"
    d += "c1:" >< "\(efficiencySolar[1])"
    d += "c2:" >< "\(efficiencySolar[2])"
    d += "c3:" >< "\(efficiencySolar[3])"
    d += "c4:" >< "\(efficiencySolar[4])"
    d += "Efficiency(GT-Load) = c0+c1*load+c2*load^2+c3*load^3+c4*load^4)\n"
    d += "c0:" >< "\(efficiencyGasTurbine[0])"
    d += "c1:" >< "\(efficiencyGasTurbine[1])"
    d += "c2:" >< "\(efficiencyGasTurbine[2])"
    d += "c3:" >< "\(efficiencyGasTurbine[3])"
    d += "c4:" >< "\(efficiencyGasTurbine[4])"
    return d
  }
}

extension WasteHeatRecovery.Parameter: TextConfigInitializable {
  public init(file: TextConfigFile)throws {
    let row: (Int)throws -> Double = { try file.double(row: $0) }
    self.name = file.name
    self.operation = .integrated
    self.efficiencyNominal = try row(13)
    self.efficiencyPure = try row(16)
    self.ratioHTF = try row(19)
    self.efficiencySolar = .init(try file.doubles(rows: 32, 35, 38, 41, 44))
    self.efficiencyGasTurbine = .init(try file.doubles(rows: 47, 50, 53, 56, 59))
    
  }
}
