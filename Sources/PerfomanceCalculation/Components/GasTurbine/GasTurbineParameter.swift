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

extension GasTurbine {
  public struct Parameter: ComponentParameter, Codable {
    let name: String
    let Pgross, efficiencyISO, Lmin, altitude: Double
    let EfofLc, loadmaxTc, parasiticsLc: Coefficients
    let designTemperature: Double
  }
}
extension GasTurbine.Parameter: CustomStringConvertible {
  public var description: String {
    var d: String = ""
    d += "Description:\t\(name)\n"
    // d += "Gross Power [MW]: \t\(Pgross * 100 / Design.layout.gasTurbine)"
    d += "Efficiency:"   >< "\(efficiencyISO * 100)"
    d += "Altitude [m]:" >< "\(altitude)"
    d += "Efficiency; Efficiency(Load) = c0+c1*load+c2*load^2+c3*load^3+c4*load^4)"
    d += "c0:" >< "\(EfofLc[0])"
    d += "c1:" >< "\(EfofLc[1])"
    d += "c2:" >< "\(EfofLc[2])"
    d += "c3:" >< "\(EfofLc[3])"
    d += "c4:" >< "\(EfofLc[4])"
    d += "Maximum Power as a func of Temperature; Power(T) = GrossPower*(c0+c1*T+c2*T^2+c3*T^3+c4*T^4)"
    d += "c0:" >< "\(loadmaxTc[0])"
    d += "c1:" >< "\(loadmaxTc[1])"
    d += "c2:" >< "\(loadmaxTc[2])"
    d += "c3:" >< "\(loadmaxTc[3])"
    d += "c4:" >< "\(loadmaxTc[4])"
    d += "Parasitic ; Parasitics(Load) = Parasitcs(100%)*(c0+c1*load+c2*load^2+c3*load^3+c4*load^4)"
    d += "c0:" >< "\(parasiticsLc[0])"
    d += "c1:" >< "\(parasiticsLc[1])"
    d += "c2:" >< "\(parasiticsLc[2])"
    d += "c3:" >< "\(parasiticsLc[3])"
    d += "c4:" >< "\(parasiticsLc[4])"
    return d
  }
}

extension GasTurbine.Parameter: TextConfigInitializable {
  public init(file: TextConfigFile)throws {
    let row: (Int)throws -> Double = { try file.parseDouble(row: $0) }
    self.name = file.name
    self.Pgross = try row(10)
    self.efficiencyISO = try row(13)
    self.Lmin = try row(16)
    self.altitude = try row(19)
    self.EfofLc = try [row(41), row(44), row(47), row(50), row(53)]
    self.loadmaxTc = try [row(60), row(63), row(66), row(69), row(72)]
    self.parasiticsLc = try [row(79), row(82), row(85), row(88), row(91)]
    self.designTemperature = try row(28)
  }
}
