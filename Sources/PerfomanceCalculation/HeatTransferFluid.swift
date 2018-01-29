//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation
import Config

var htf = HeatTransferFluid(
  name: "Therminol",
  freezeTemperature: 12,
  heatCapacity: [1.4856, 0.0028],
  dens: [1074.964, -0.6740513, -0.000650017],
  visco: [-0.000201537, 0.1273247, -0.7167957],
  thermCon: [0.1378081, -8.41485e-05, -1.788e-07],
  maxTemperature: 393.0,
  h_T: [-0.62677, 1.51129, 0.0012941, 1.23697e-07, 0],
  T_h: [0.58315, 0.65556, -0.00032293, 1.9425e-07, -6.1133e-11],
  useEnthalpy: true)

var salt = HeatTransferFluid(
  name: "Solar Salt",
  freezeTemperature: 240.0,
  heatCapacity: [1.44657, 0.000171715],
  dens: [1969.9, -0.603505, 0],
  visco: [0.0175373, -7.01716e-05, 7.62774e-08],
  thermCon: [0.44152, 0.00019, 0],
  maxTemperature: 400.0,
  h_T: [], T_h: [],
  useEnthalpy: false)

/*
 The Heat Transfer Fluid is characterized through maximum operating temperature,
 freeze temperature, specific heat capacity, viscosity, thermal conductivity
 and density as a function of temperature.
 */
public struct HeatTransferFluid {
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
  let heatDelta: (Temperature, Temperature) -> Heat
  let temperatureDelta: (Double, Temperature) -> Temperature
  
  public init(name: String, freezeTemperature: Double,
              heatCapacity: [Double], dens: [Double], visco: [Double],
              thermCon: [Double], maxTemperature: Double,
              h_T: [Double], T_h: [Double], useEnthalpy: Bool) {
    
    self.name = name
    self.freezeTemperature = Temperature(celsius: freezeTemperature)
    self.heatCapacity = heatCapacity
    self.dens = dens
    self.visco = visco
    self.thermCon = thermCon
    self.maxTemperature = Temperature(celsius: maxTemperature)
    self.h_T = h_T
    self.T_h = T_h
    
    if useEnthalpy, !h_T.isEmpty, !T_h.isEmpty {
      self.useEnthalpy = true
      self.heatDelta = { (high: Temperature, low: Temperature) -> Double in
        HeatTransferFluid.heatTransfer(from: high.celsius,
                                     to: low.celsius,
                                     coefficients: h_T)
      }
      self.temperatureDelta = {
        (heatFlow: Double, temperature: Temperature) -> Temperature in
        Temperature(celsius: HeatTransferFluid.temperatureFromEnthalpy(
          heatFlow, temperature.celsius, coefficients: (h_T, T_h)))
      }
    } else {
      precondition(!heatCapacity.isEmpty)
      self.useEnthalpy = false
      self.heatDelta = { (high: Temperature, low: Temperature) -> Double in
        HeatTransferFluid.heatTransfer(
          from: high.celsius, to: low.celsius, heatCapacity: heatCapacity)
      }
      self.temperatureDelta = {
        (specificHeat: Double, temperature: Temperature) -> Temperature in
        Temperature(celsius: HeatTransferFluid.temperatureFromHeatCapacity(
          specificHeat, temperature.celsius, coefficients: heatCapacity))
      }
    }
  }
  
  func density(_ temperature: Temperature) -> Double {
    assert(temperature.kelvin > freezeTemperature.kelvin)
    return dens[0] + dens[1] * temperature.celsius
      + dens[2] * temperature.celsius * temperature.celsius
  }
  
  func mixingTemperature(
    outlet m1: HeatTransfer, with m2: HeatTransfer) -> Temperature {
    let (t1, t2) = (m1.temperature.outlet.kelvin, m2.temperature.outlet.kelvin)
    let (m1, m2) = (m1.massFlow.rate, m2.massFlow.rate)
    guard m1 + m2 > 0 else { return Temperature((t1 + t2) / 2) }
    let cap1 = fma(heatCapacity[1], t1, heatCapacity[0])
    let cap2 = fma(heatCapacity[1], t2, heatCapacity[0])
    return Temperature((m1 * cap1 * t1 + m2 * cap2 * t2) / (m1 * cap1 + m2 * cap2))
  }
  
  func mixingTemperature(
    inlet m1: HeatTransfer, with m2: HeatTransfer) -> Temperature {
    let (t1, t2) = (m1.temperature.inlet.kelvin, m2.temperature.outlet.kelvin)
    let (m1, m2) = (m1.massFlow.rate, m2.massFlow.rate)
    guard m1 + m2 > 0 else { return Temperature((t1 + t2) / 2) }
    let cap1 = fma(heatCapacity[1], t1, heatCapacity[0])
    let cap2 = fma(heatCapacity[1], t2, heatCapacity[0])
    return Temperature((m1 * cap1 * t1 + m2 * cap2 * t2) / (m1 * cap1 + m2 * cap2))
  }
  
  private static func temperatureFromHeatCapacity(
    _ specificHeat: Double, _ temperature: Double,
    coefficients: [Double]) -> Double {
    
    let t = temperature
    let cp = coefficients
    if cp[1] > 0 {
      return sqrt((2 * specificHeat + 2 * cp[0] * t) / cp[1] + t ** 2
        + (cp[0] / cp[1]) ** 2) - cp[0] / cp[1]
    } else {
      return -sqrt((2 * specificHeat + 2 * cp[0] * t) / cp[1] + t ** 2
        + (cp[0] / cp[1]) ** 2) - cp[0] / cp[1]
    }
  }
  
  private static func temperatureFromEnthalpy(
    _ enthalpy: Double, _ temperature: Double,
    coefficients: ([Double], [Double])) -> Double {
    let (h_T, T_h) = coefficients
    var h1 = 0.0
    for coefficient in h_T.reversed() {
      h1 = fma(h1, temperature, coefficient)
    }
    let h2 = enthalpy + h1
    var temperature = 0.0
    for coefficient in T_h.reversed() {
      temperature = fma(temperature, h2, coefficient)
    }
    return temperature
  }
  
  private static func heatTransfer(
    from high: Double, to low: Double, heatCapacity: [Double]) -> Double {
    var q = heatCapacity[0] * (high - low)
    q += heatCapacity[1] / 2 * (pow((high), 2) - pow((low), 2))
    return q
  }
  
  private static func heatTransfer(
    from high: Double, to low: Double, coefficients: [Double]) -> Double {
    var (h1, h2) = (0.0, 0.0)
    for (i, c) in coefficients.enumerated() {
      h1 += c * pow(low, Double(i))
      h2 += c * pow(high, Double(i))
    }
    return h2 - h1
  }
  
  public var description: String {
    var d = ""
    d += "Description:\t\(name)\n"
    d += "Freezing Point [°C]:"
      >< "\(freezeTemperature.celsius)"
    d += "Specific Heat as a Function of Temperature; cp(T) = c0+c1*T\n"
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
    d += "Density as a Function of Temperature; roh(T) = c0+c1*T+c1*T^2\n"
    for (i, c) in dens.enumerated() {
      d += "c\(i):" >< String(format:"%.6E", c)
    }
    d += "Viscosity as a Function of Temperature; eta(T) = c0+c1*T+c1*T^2\n"
    for (i, c) in visco.enumerated() {
      d += "c\(i):" >< String(format:"%.6E", c)
    }
    d += "Conductivity as a Function of Temperature; lamda(T) = c0+c1*T+c1*T^2\n"
    for (i, c) in thermCon.enumerated() {
      d += "c\(i):" >< String(format:"%.6E", c)
    }
    d += "Maximum Operating Temperature [°C]:" >< "\(maxTemperature.celsius)"
    return d
  }
}

public enum StorageFluid: String {
  case hiXL = "HitecXL"
  case xlt600 = "XLT600"
  case th66 = "TH66"
  case solarSalt = "SolarSalt"
}

extension HeatTransferFluid: Codable {
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
    self.freezeTemperature = try values.decode(Temperature.self,
                                               forKey: .freezeTemperature)
    let heatCapacity = try values.decode(Array<Double>.self,
                                         forKey: .heatCapacity)
    self.heatCapacity = heatCapacity
    self.dens = try values.decode(Array<Double>.self, forKey: .dens)
    self.visco = try values.decode(Array<Double>.self, forKey: .visco)
    self.thermCon = try values.decode(Array<Double>.self, forKey: .thermCon)
    self.maxTemperature = try values.decode(Temperature.self,
                                            forKey: .maxTemperature)
    let h_T = try values.decode(Array<Double>.self, forKey: .h_T)
    self.h_T = h_T
    let T_h = try values.decode(Array<Double>.self, forKey: .T_h)
    self.T_h = T_h
    self.useEnthalpy = try values.decode(Bool.self, forKey: .withEnthalpy)
    
    if useEnthalpy, !h_T.isEmpty, !T_h.isEmpty {
      self.heatDelta = { (high: Temperature, low: Temperature) -> Double in
        HeatTransferFluid.heatTransfer(
          from: high.kelvin, to: low.kelvin, coefficients: h_T)
      }
      self.temperatureDelta = {
        (enthalpy: Double, temperature: Temperature) -> Temperature in
        Temperature(HeatTransferFluid.temperatureFromEnthalpy(
          enthalpy, temperature.kelvin, coefficients: (h_T, T_h) ))
      }
    } else {
      precondition(!heatCapacity.isEmpty)
      self.heatDelta = { (high: Temperature, low: Temperature) -> Double in
        HeatTransferFluid.heatTransfer(
          from: high.kelvin, to: low.kelvin, heatCapacity: heatCapacity)
      }
      self.temperatureDelta = {
        (specificHeat: Double, temperature: Temperature) -> Temperature in
        Temperature(HeatTransferFluid.temperatureFromHeatCapacity(
          specificHeat, temperature.kelvin, coefficients: heatCapacity))
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

extension HeatTransferFluid {
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
      self.heatDelta = { (high: Temperature, low: Temperature) -> Heat in
        HeatTransferFluid.heatTransfer(
          from: high.celsius, to: low.celsius, coefficients: h_T)
      }
      self.temperatureDelta = {
        (enthalpy: Double, temperature: Temperature) -> Temperature in
        Temperature(celsius: HeatTransferFluid.temperatureFromEnthalpy(
          enthalpy, temperature.celsius, coefficients: (h_T, T_h) ))
      }
    } else {
      self.useEnthalpy = false
      self.h_T = []
      self.T_h = []
      self.heatDelta = { (high: Temperature, low: Temperature) -> Heat in
        HeatTransferFluid.heatTransfer(
          from: high.celsius, to: low.celsius, coefficients: heatCapacity)
      }
      self.temperatureDelta = {
        (specificHeat: Double, temperature: Temperature) -> Temperature in
        Temperature(celsius: HeatTransferFluid.temperatureFromHeatCapacity(
          specificHeat, temperature.celsius, coefficients: heatCapacity))
      }
    }
  }
}
