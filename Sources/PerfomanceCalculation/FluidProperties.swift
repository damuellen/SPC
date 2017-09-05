//
//  Copyright (c) 2017 Daniel Müllenborn. All rights reserved.
//  Distributed under the The Non-Profit Open Software License version 3.0
//  http://opensource.org/licenses/NPOSL-3.0
//
//  This project is NOT free software. It is open source, you are allowed to
//  modify it (if you keep the license), but it may not be commercially
//  distributed other than under the conditions noted above.
//

import Foundation
import Config

var htf = FluidProperties(
  name: "Therminol",
  freezeTemperature: 12 + 0,
  heatCapacity: [1.4856, 0.0028],
  dens: [1074.964, -0.6740513, -0.000650017],
  visco: [ -0.000201537, 0.1273247, -0.7167957],
  thermCon: [0.1378081, -0.0000841485, -0.0000001788],
  maxTemperature: 393.toKelvin,
  h_T: [-0.62677, 1.51129, 0.0012941, 0.000000123697, 0],
  T_h: [0.58315, 0.65556, -0.00032293, 0.00000019425, -0.000000000061133],
  withEnthalpy: true)

var salt = FluidProperties(
  name: "Solar Salt",
  freezeTemperature: 240 + 0,
  heatCapacity: [1.44657, 0.000171715],
  dens: [1969.9, -0.603505, 0],
  visco: [0.0175373, -0.0000701716, 0.0000000762774],
  thermCon: [0.44152, 0.00019, 0],
  maxTemperature: 400, h_T: [], T_h: [], withEnthalpy: false)

/*
 The Heat Transfer Fluid is characterized through maximum operating temperature,
 freeze temperature, specific heat capacity, viscosity, thermal conductivity
 and density as a function of temperature.
 */
public struct FluidProperties {
  let name: String
  let freezeTemperature: Double
  let heatCapacity: [Double]
  let dens: [Double]
  let visco: [Double]
  let thermCon: [Double]
  let maxTemperature: Double
  var h_T: [Double]
  var T_h: [Double]
  
  var withEnthalpy = true

  lazy var heatTransfered: (Double, Double) -> Double = enthalpyChange
  lazy var temperature: (Double, Double) -> Double = fromEnthalpy
  
  public init(name: String, freezeTemperature: Double, heatCapacity: [Double],
              dens: [Double], visco: [Double], thermCon: [Double],
              maxTemperature: Double, h_T: [Double], T_h: [Double], withEnthalpy: Bool) {
    self.name = name
    self.freezeTemperature = freezeTemperature
    self.heatCapacity = heatCapacity
    self.dens = dens
    self.visco = visco
    self.thermCon = thermCon
    self.maxTemperature = maxTemperature
    self.h_T = h_T
    self.T_h = T_h
    if !withEnthalpy {
      self.withEnthalpy = false
      self.heatTransfered = specificHeat
      self.temperature = fromHeatCapacity
    }
  }
  
  func density(_ temperature: Double) -> Double {
    return dens[0] + dens[1] * (temperature.toCelsius)
      + dens[2] * (temperature.toCelsius) ** 2
  }
  
  func mixing(outlet m1: MassFlow, with m2: MassFlow) -> Temperature {
    let (t1, t2) = (m1.temperature.outlet, m2.temperature.outlet)
    let (m1, m2) = (m1.massFlow, m2.massFlow)
    guard m1 + m2 > 0 else { return (t1 + t2) / 2 }
    let cap1 = heatCapacity[0] + heatCapacity[1] * t1
    let cap2 = heatCapacity[0] + heatCapacity[1] * t2
    return (m1 * cap1 * t1 + m2 * cap2 * t2) / (m1 * cap1 + m2 * cap2)
  }
  
  func mixing(inlet m1: MassFlow, with m2: MassFlow) -> Temperature {
    let (t1, t2) = (m1.temperature.inlet, m2.temperature.outlet)
    let (m1, m2) = (m1.massFlow, m2.massFlow)
    guard m1 + m2 > 0 else { return (t1 + t2) / 2 }
    let cap1 = heatCapacity[0] + heatCapacity[1] * t1
    let cap2 = heatCapacity[0] + heatCapacity[1] * t2
    return (m1 * cap1 * t1 + m2 * cap2 * t2) / (m1 * cap1 + m2 * cap2)
  }

  private func fromHeatCapacity(_ heatFlow: Double, _ temperature: Double) -> Temperature {
    let kelvin = temperature.toCelsius
    let cp = heatCapacity
    if cp[1] > 0 {
      return sqrt((2 * heatFlow + 2 * cp[0] * kelvin) / cp[1] + kelvin ** 2
        + (cp[0] / cp[1]) ** 2) - cp[0] / cp[1].toKelvin
    } else {
      return -sqrt((2 * heatFlow + 2 * cp[0] * kelvin) / cp[1] + kelvin ** 2
        + (cp[0] / cp[1]) ** 2) - cp[0] / cp[1].toKelvin}
  }

  private func fromEnthalpy(_ heatFlow: Double, _ temperature: Double) -> Double {
    let kelvin = temperature.toCelsius
    let h1 = h_T[0] + h_T[1] * kelvin + h_T[2] * kelvin ** 2
      + h_T[3] * kelvin ** 3 + h_T[4] * kelvin ** 4
    let h2 = heatFlow + h1
    return (T_h[0] + T_h[1] * h2 + T_h[2] * h2 ** 2
      + T_h[3] * h2 ** 3 + T_h[4] * h2 ** 4).toKelvin
  }

  private func enthalpyChange(from high: Double, to low: Double) -> Double {
    var h1 = 0.0
    for (i, v) in h_T.enumerated() {
      h1 += v * pow(low.toKelvin, Double(i))
      
    }
    var h2 = 0.0
    for (i, v) in h_T.enumerated() {
      h2 += v * pow(high.toKelvin, Double(i))
    }
    return h2 - h1
  }

  private func specificHeat(from high: Double, to low: Double) -> Double {
    var q = heatCapacity[0] * (high - low)
    q += heatCapacity[1] / 2 * (pow((high - 263.1), 2) - pow((low - 263.1), 2))
    return q
  }
  
  public var description: String {
    var d = ""
    d += "name:" + name + "\n"
    d += "Freezing Point [°C]:"
      >< "\(freezeTemperature.toCelsius)"
    d += "Specific Heat as a Function of Temperature; cp(T) = c0+c1*T"
    d += "c0:" >< "\(heatCapacity[0])"
    d += "c1:" >< "\(heatCapacity[1])"
    d += "Calculate with Enthalpy: \(withEnthalpy.description)"
    if !h_T.isEmpty {
      d += "Enthalpy as function on Temperature"
      for (i, c) in h_T.enumerated() { d += "c\(i):" >< "\(c)" }
    }
    if !T_h.isEmpty {
      d += "Temperature as function on Enthalpy"
      for (i, c) in T_h.enumerated() { d += "c\(i):" >< "\(c)" }
    }
    d += "Density as a Function of Temperature; roh(T) = c0+c1*T+c1*T^2"
    d += "c0:" >< "\(dens[0])"
    d += "c1:" >< "\(dens[1])"
    d += "c2:" >< "\(dens[2])"
    d += "Viscosity as a Function of Temperature; eta(T) = c0+c1*T+c1*T^2"
    d += "c0:" >< "\(visco[0])"
    d += "c1:" >< "\(visco[1])"
    d += "c2:" >< "\(visco[2])"
    d += "Conductivity as a Function of Temperature; lamda(T) = c0+c1*T+c1*T^2"
    d += "c0:" >< "\(thermCon[0])"
    d += "c1:" >< "\(thermCon[1])"
    d += "c2:" >< "\(thermCon[2])"
    d += "Maximum Operating Temperature [°C]:" >< "\(maxTemperature.toCelsius)"
    return d
  }
}

public enum StorageFluid: String {
  case hiXL = "HitecXL"
  case xlt600 = "XLT600"
  case th66 = "TH66"
  case solarSalt = "SolarSalt"
}

extension FluidProperties: Codable {
  enum CodingKeys: String, CodingKey {
    case name
    case freezeTemperature
    case heatCapacity
    case dens
    case visco
    case thermCon
    case maxTemperature
    case h_T, T_h
    case withEnthalpy
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.name = try values.decode(String.self, forKey: .name)
    self.freezeTemperature = try values.decode(Double.self, forKey: .freezeTemperature)
    self.heatCapacity = try values.decode(Array<Double>.self, forKey: .heatCapacity)
    self.dens = try values.decode(Array<Double>.self, forKey: .dens)
    self.visco = try values.decode(Array<Double>.self, forKey: .visco)
    self.thermCon = try values.decode(Array<Double>.self, forKey: .thermCon)
    self.maxTemperature = try values.decode(Double.self, forKey: .maxTemperature)
    self.h_T = try values.decode(Array<Double>.self, forKey: .h_T)
    self.T_h = try values.decode(Array<Double>.self, forKey: .T_h)
    self.withEnthalpy = try values.decode(Bool.self, forKey: .withEnthalpy)
    if !withEnthalpy {
      self.withEnthalpy = false
      self.heatTransfered = specificHeat
      self.temperature = fromHeatCapacity
    }
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encode(freezeTemperature, forKey: .freezeTemperature)
    try container.encode(heatCapacity, forKey: .heatCapacity)
    try container.encode(dens, forKey: .dens)
    try container.encode(visco, forKey: .visco)
    try container.encode(thermCon, forKey: .thermCon)
    try container.encode(maxTemperature, forKey: .maxTemperature)
    try container.encode(h_T, forKey: .h_T)
    try container.encode(T_h, forKey: .T_h)
    try container.encode(withEnthalpy, forKey: .withEnthalpy)
  }
}

extension FluidProperties {
  public init(file: TextConfigFile, includesEnthalpy: Bool)throws {
    let row: (Int)throws -> Double = { try file.parseDouble(row: $0) }
    self.name = file.name
    self.freezeTemperature = try row(10)
    self.heatCapacity = [try row(13), try row(15)]
    self.dens = [try row(18), try row(21), try row(24)]
    self.visco = [try row(27), try row(30), try row(33)]
    self.thermCon = [try row(36), try row(39), try row(42)]
    self.maxTemperature = try row(45).toKelvin
    if includesEnthalpy {
      self.h_T = [
        try row(47), try row(48), try row(49), try row(50), try row(51)
      ]
      self.T_h = [
        try row(53), try row(54), try row(55), try row(56), try row(57)
      ]
      self.withEnthalpy = try row(59) > 0 ? true : false
    } else {
      self.h_T = []
      self.T_h = []
    }
    if !includesEnthalpy {
      self.withEnthalpy = false
      self.heatTransfered = specificHeat
      self.temperature = fromHeatCapacity
    }
  }
}
