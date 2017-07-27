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

extension PowerBlock {
  public struct Parameter: ComponentParameter, Codable {
    let name: String
    let fixelectricalParasitics: Double
    let nominalElectricalParasitics: Double
    let fixElectricalParasitics0: Double
    let startUpelectricalParasitics: Double
    let nominalElectricalParasiticsACC: Double
    let electricalParasiticsShared, electricalParasiticsStep,
    electricalParasitics, electricalParasiticsACC,
    electricalParasiticsACCTamb: Coefficients
  }
}
extension PowerBlock.Parameter: CustomStringConvertible {
  public var description: String {
    var d: String = ""
    d += "Fixed Parasitics for Load = 0 [MW]:"
      >< "\(fixElectricalParasitics0)"
    d += "Parasitics during PB Start-Up [MW]:"
      >< "\(startUpelectricalParasitics)"
    d += "Fixed Parasitics (Load > 0) [MW]:"
      >< "\(fixelectricalParasitics)"
    d += "Nominal Parasitics (Load = 1)[MW]:"
      >< "\(nominalElectricalParasiticsACC)"
    d += "Parasitic ; Parasitics(Load) = Parasitics(100%)*(c0+c1*load)"
    d += "c0:" >< "\(electricalParasitics[0])"
    d += "c1:" >< "\(electricalParasitics[1])"
    d += "c2:" >< "\(electricalParasitics[2])"
    d += "Parasitics of Cooling Tower for load < 50% [MW]:"
      >< "\(electricalParasiticsStep[0])"
    d += "Parasitics of Cooling Tower for load > 50% [MW]:"
      >< "\(electricalParasiticsStep[1])"
    d += "Parasitics of Shared Facilities for load = 0 [MW]:"
      >< "\(electricalParasiticsShared[0])"
    d += "Parasitics of Shared Facilities for load > 0 [MW]:"
      >< "\(electricalParasiticsShared[1])"
    d += "Nominal Parasitics of ACC [MW]:"
      >< "\(nominalElectricalParasiticsACC)"
    d += "ACC Parasitic f(Load) = ParasiticsACC(100%)*(c0+c1*load+c2*load^2+...)"
    d += "c0:" >< "\(electricalParasiticsACC[0])"
    d += "c1:" >< "\(electricalParasiticsACC[1])"
    d += "c2:" >< "\(electricalParasiticsACC[2])"
    d += "c3:" >< "\(electricalParasiticsACC[3])"
    d += "c4:" >< "\(electricalParasiticsACC[4])"
    d += "ACC Parasitic f(Tamb) = ParasiticsACC(100%)*(c0+c1*Tamb+c2*Tamb^2+...)"
    d += "c0:" >< "\(electricalParasiticsACCTamb[0])"
    d += "c1:" >< "\(electricalParasiticsACCTamb[1])"
    d += "c2:" >< "\(electricalParasiticsACCTamb[2])"
    d += "c3:" >< "\(electricalParasiticsACCTamb[3])"
    d += "c4:" >< "\(electricalParasiticsACCTamb[4])"
    return d
  }
}

extension PowerBlock.Parameter: TextConfigInitializable {
  public init(file: TextConfigFile)throws {
    let row: (Int)throws -> Double = { try file.double(row: $0) }
    self.name = file.name
    self.fixelectricalParasitics = try row(10)
    self.nominalElectricalParasitics = try row(13)
    self.electricalParasitics = .init(try file.doubles(rows: 16, 19))
    self.electricalParasiticsStep = .init(try file.doubles(rows: 22, 25))
    self.fixElectricalParasitics0 = try row(28)
    self.startUpelectricalParasitics = try row(31)
    self.nominalElectricalParasiticsACC = try row(39)
    self.electricalParasiticsShared = .init(try file.doubles(rows: 34, 37))
    self.electricalParasiticsACC = .init(try file.doubles(rows: 41, 43, 45, 47))
    self.electricalParasiticsACCTamb = .init(try file.doubles(rows: 49, 51, 53, 55))
    
  }
}
