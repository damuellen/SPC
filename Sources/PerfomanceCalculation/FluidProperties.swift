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
  freezeTemperature: 12,
  heatCapacity: [1.4856, 0.0028],
  dens: [1074.964, -0.6740513, -0.000650017],
  visco: [ -0.000201537, 0.1273247, -0.7167957],
  thermCon: [0.1378081, -0.0000841485, -0.0000001788],
  maxTemperature: 393.0,
  h_T: [-0.62677, 1.51129, 0.0012941, 0.000000123697, 0],
  T_h: [0.58315, 0.65556, -0.00032293, 0.00000019425, -0.000000000061133],
  useEnthalpy: true)

var salt = FluidProperties(
  name: "Solar Salt",
  freezeTemperature: 240,
  heatCapacity: [1.44657, 0.000171715],
  dens: [1969.9, -0.603505, 0],
  visco: [0.0175373, -0.0000701716, 0.0000000762774],
  thermCon: [0.44152, 0.00019, 0],
  maxTemperature: 400.0,
  h_T: [], T_h: [],
  useEnthalpy: false)

/*
 The Heat Transfer Fluid is characterized through maximum operating temperature,
 freeze temperature, specific heat capacity, viscosity, thermal conductivity
 and density as a function of temperature.
 */
public struct FluidProperties {
  let name: String
  let freezeTemperature: Temperature
  let heatCapacity: [Double]
  let dens: [Double]
  let visco: [Double]
  let thermCon: [Double]
  let maxTemperature: Temperature
  let h_T: [Double]
  let T_h: [Double]
  let useEnthalpy: Bool
  let heatTransfered: (Temperature, Temperature) -> Heat
  let temperatureDelta: (Double, Temperature) -> Temperature
  
  public init(name: String, freezeTemperature: Double,
              heatCapacity: [Double], dens: [Double], visco: [Double],
              thermCon: [Double], maxTemperature: Double,
              h_T: [Double], T_h: [Double], useEnthalpy: Bool) {
    
    self.name = name
    self.freezeTemperature = Temperature(freezeTemperature)
    self.heatCapacity = heatCapacity
    self.dens = dens
    self.visco = visco
    self.thermCon = thermCon
    self.maxTemperature = Temperature(maxTemperature)
    self.h_T = h_T
    self.T_h = T_h
    
    if useEnthalpy {
      self.useEnthalpy = true
      self.heatTransfered = { (high: Temperature, low: Temperature) -> Double in
        FluidProperties.heatTransfer(from: high.value, to: low.value, enthalpy: h_T)
      }
      self.temperatureDelta = {
        (heatFlow: Double, temperature: Temperature) -> Temperature in
        Temperature(FluidProperties.temperatureFromHeatFlow(
          heatFlow, temperature.value, enthalpy: (h_T, T_h)))
      }
    } else {
      self.useEnthalpy = false
      self.heatTransfered = { (high: Temperature, low: Temperature) -> Double in
        FluidProperties.heatTransfer(
          from: high.toCelsius, to: low.toCelsius, heatCapacity: heatCapacity)
      }
      self.temperatureDelta = {
        (heatFlow: Double, temperature: Temperature) -> Temperature in
        Temperature(FluidProperties.temperatureFromHeatFlow(
          heatFlow, temperature.value, heatCapacity: heatCapacity))
      }
    }
  }
  
  func density(_ temperature: Temperature) -> Double {
    assert(temperature.value > freezeTemperature.toKelvin)
    return dens[0] + dens[1] * temperature.toCelsius
      + dens[2] * temperature.toCelsius ** 2
  }
  
  func mixingTemperature(outlet m1: MassFlow, with m2: MassFlow) -> Temperature {
    let (t1, t2) = (m1.temperature.outlet.value, m2.temperature.outlet.value)
    let (m1, m2) = (m1.massFlow, m2.massFlow)
    guard m1 + m2 > 0 else { return Temperature((t1 + t2) / 2) }
    let cap1 = heatCapacity[0] + heatCapacity[1] * t1
    let cap2 = heatCapacity[0] + heatCapacity[1] * t2
    return Temperature((m1 * cap1 * t1 + m2 * cap2 * t2) / (m1 * cap1 + m2 * cap2))
  }
  
  func mixingTemperature(inlet m1: MassFlow, with m2: MassFlow) -> Temperature {
    let (t1, t2) = (m1.temperature.inlet.value, m2.temperature.outlet.value)
    let (m1, m2) = (m1.massFlow, m2.massFlow)
    guard m1 + m2 > 0 else { return Temperature((t1 + t2) / 2) }
    let cap1 = heatCapacity[0] + heatCapacity[1] * t1
    let cap2 = heatCapacity[0] + heatCapacity[1] * t2
    return Temperature((m1 * cap1 * t1 + m2 * cap2 * t2) / (m1 * cap1 + m2 * cap2))
  }

  private static func temperatureFromHeatFlow(
    _ heatFlow: Double, _ temperature: Double,
    heatCapacity: [Double]) -> Double {
    
    let t = Temperature(temperature).toCelsius
    let cp = heatCapacity
    if cp[1] > 0 {
      return sqrt((2 * heatFlow + 2 * cp[0] * t) / cp[1] + t ** 2
        + (cp[0] / cp[1]) ** 2) - cp[0] / cp[1].toKelvin
    } else {
      return -sqrt((2 * heatFlow + 2 * cp[0] * t) / cp[1] + t ** 2
        + (cp[0] / cp[1]) ** 2) - cp[0] / cp[1].toKelvin}
  }

  private static func temperatureFromHeatFlow(
    _ heatFlow: Double, _ temperature: Double,
    enthalpy: ([Double], [Double])) -> Double {
    
    let t = Temperature(temperature).toCelsius
    let (h_T, T_h) = enthalpy
    let h1 = h_T[0] + h_T[1] * t + h_T[2] * t ** 2
      + h_T[3] * t ** 3 + h_T[4] * t ** 4
    let h2 = heatFlow + h1
    return (T_h[0] + T_h[1] * h2 + T_h[2] * h2 ** 2
      + T_h[3] * h2 ** 3 + T_h[4] * h2 ** 4).toKelvin
  }

  private static func heatTransfer(
    from high: Double, to low: Double, heatCapacity: [Double]) -> Double {
    var q = heatCapacity[0] * (high - low)
    q += heatCapacity[1] / 2 * (pow((high.toCelsius), 2) - pow((low.toCelsius), 2))
    return q
  }
  
  private static func heatTransfer(
    from high: Double, to low: Double, enthalpy: [Double]) -> Double {
    var (h1, h2) = (0.0, 0.0)
    let (low, high) = (low.toCelsius, high.toCelsius)
    for (i, v) in enthalpy.enumerated() {
      h1 += v * pow(low, Double(i))
      h2 += v * pow(high, Double(i))
    }
    return h2 - h1
  }
  
  public var description: String {
    var d = ""
    d += "Description:\t\(name)\n"
    d += "Freezing Point [°C]:"
      >< "\(freezeTemperature.toCelsius)"
    d += "Specific Heat as a Function of Temperature; cp(T) = c0+c1*T"
    d += "c0:" >< "\(heatCapacity[0])"
    d += "c1:" >< "\(heatCapacity[1])"
    d += "Calculate with Enthalpy: \(useEnthalpy.description)"
    if !h_T.isEmpty {
      d += "Enthalpy as function on Temperature\n"
      for (i, c) in h_T.enumerated() {
        d += "c\(i):" >< String(format:"%.6E", c)
      }
    }
    if !T_h.isEmpty {
      d += "Temperature as function on Enthalpy\n"
      for (i, c) in T_h.enumerated() {
        d += "c\(i):" >< String(format:"%.6E", c)
      }
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
    self.freezeTemperature = try values.decode(Temperature.self, forKey: .freezeTemperature)
    let heatCapacity = try values.decode(Array<Double>.self, forKey: .heatCapacity)
    self.heatCapacity = heatCapacity
    self.dens = try values.decode(Array<Double>.self, forKey: .dens)
    self.visco = try values.decode(Array<Double>.self, forKey: .visco)
    self.thermCon = try values.decode(Array<Double>.self, forKey: .thermCon)
    self.maxTemperature = try values.decode(Temperature.self, forKey: .maxTemperature)
    let h_T = try values.decode(Array<Double>.self, forKey: .h_T)
    self.h_T = h_T
    let T_h = try values.decode(Array<Double>.self, forKey: .T_h)
    self.T_h = T_h
    self.useEnthalpy = try values.decode(Bool.self, forKey: .withEnthalpy)
    if useEnthalpy {
      self.heatTransfered = { (high: Temperature, low: Temperature) -> Double in
        FluidProperties.heatTransfer(from: high.value, to: low.value, enthalpy: h_T)
      }
      self.temperatureDelta = {
        (heatFlow: Double, temperature: Temperature) -> Temperature in
        Temperature(FluidProperties.temperatureFromHeatFlow(
          heatFlow, temperature.value, enthalpy: (h_T, T_h)
        ))
      }
    } else {
      self.heatTransfered = { (high: Temperature, low: Temperature) -> Double in
        FluidProperties.heatTransfer(
          from: high.value, to: low.value, heatCapacity: heatCapacity)
      }
      self.temperatureDelta = {
        (heatFlow: Double, temperature: Temperature) -> Temperature in
        Temperature(FluidProperties.temperatureFromHeatFlow(
          heatFlow, temperature.value, heatCapacity: heatCapacity
        ))
      }
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
    try container.encode(useEnthalpy, forKey: .withEnthalpy)
  }
}

extension FluidProperties {
  public init(file: TextConfigFile, includesEnthalpy: Bool)throws {
    let row: (Int)throws -> Double = { try file.parseDouble(row: $0) }
    self.name = file.name
    self.freezeTemperature = try Temperature(row(10))
    let heatCapacity = try [row(13), row(15)]
    self.heatCapacity = heatCapacity
    self.dens = try [try row(18), try row(21), row(24)]
    self.visco = try [row(27), row(30), row(33)]
    self.thermCon = try [row(36), row(39), row(42)]
    self.maxTemperature = try Temperature(row(45)) //.toKelvin
    if includesEnthalpy {
      let h_T = try [row(47), row(48), row(49), row(50), row(51)]
      self.h_T = h_T
      let T_h = try [row(53), row(54), row(55), row(56), row(57)]
      self.T_h = T_h
      self.useEnthalpy = try row(59) > 0 ? true : false
      self.heatTransfered = { (high: Temperature, low: Temperature) -> Heat in
        FluidProperties.heatTransfer(
          from: high.value, to: low.value, enthalpy: h_T
        )
      }
      self.temperatureDelta = {
        (heatFlow: Double, temperature: Temperature) -> Temperature in
        Temperature(FluidProperties.temperatureFromHeatFlow(
          heatFlow, temperature.value, enthalpy: (h_T, T_h)
        ))
      }
    } else {
      self.useEnthalpy = false
      self.h_T = []
      self.T_h = []
      self.heatTransfered = { (high: Temperature, low: Temperature) -> Heat in
        FluidProperties.heatTransfer(
          from: high.value, to: low.value, heatCapacity: heatCapacity
        )
      }
      self.temperatureDelta = {
        (heatFlow: Double, temperature: Temperature) -> Temperature in
        Temperature(FluidProperties.temperatureFromHeatFlow(
          heatFlow, temperature.value, heatCapacity: heatCapacity
        ))
      }
    }
  }
}
