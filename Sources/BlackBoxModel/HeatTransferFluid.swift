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

/// The Heat Transfer Fluid is characterized through maximum operating temperature,
/// freeze temperature, specific heat capacity, viscosity, thermal conductivity,
/// enthalpy, and density as a function of temperature.
public struct HeatTransferFluid: CustomStringConvertible, Equatable {
  static var parameter = ParameterDefaults.HTF
  let name: String
  let freezeTemperature: Temperature
  let heatCapacity: [Double]
  let density: [Double]
  let viscosity: [Double]
  let thermCon: [Double]
  let maxTemperature: Temperature
  let enthaplyFromTemperature: Polynomial
  let temperatureFromEnthalpy: Polynomial
  let useEnthalpy: Bool

  public init(
    name: String, freezeTemperature: Double,
    heatCapacity: [Double], dens: [Double],
    visco: [Double], thermCon: [Double], maxTemperature: Double,
    h_T: [Double], T_h: [Double], useEnthalpy: Bool = true
  ) {
    self.name = name
    self.freezeTemperature = Temperature(celsius: freezeTemperature)
    self.heatCapacity = heatCapacity
    self.density = dens
    self.viscosity = visco
    self.thermCon = thermCon
    self.maxTemperature = Temperature(celsius: maxTemperature)
    self.enthaplyFromTemperature = Polynomial(h_T)
    self.temperatureFromEnthalpy = Polynomial(T_h)

    if useEnthalpy, !h_T.isEmpty, !T_h.isEmpty {
      self.useEnthalpy = true
    } else {
      assert(!heatCapacity.isEmpty)
      self.useEnthalpy = false
    }
  }

  func deltaHeat(_ flow: HeatCycle) -> Heat {
    deltaHeat(flow.temperature.outlet, flow.temperature.inlet)
  }

  @inline(__always)
  func deltaHeat(_ t1: Temperature, _ t2: Temperature) -> Heat {
    if useEnthalpy {
      return HeatTransferFluid.heatExchanged(
        from: t1.celsius, to: t2.celsius,
        coefficients: enthaplyFromTemperature.coefficients
      )
    }
    return HeatTransferFluid.heatExchanged(
      from: t1.celsius, to: t2.celsius, heatCapacity: heatCapacity
    )
  }

  @inline(__always)
  func temperature(_ heat: Heat, _ t: Temperature) -> Temperature {
    if useEnthalpy {
      return Temperature(
        celsius: HeatTransferFluid.temperatureFromEnthalpy(
          heat, t.celsius,
          coefficients: (
            enthaplyFromTemperature.coefficients,
            temperatureFromEnthalpy.coefficients
          ))
      )
    }
    return Temperature(
      celsius: HeatTransferFluid.temperatureFromHeatCapacity(
        heat, t.celsius, coefficients: heatCapacity)
    )
  }

  func density(_ temperature: Temperature) -> Double {
    precondition(
      temperature.kelvin > freezeTemperature.kelvin,
      "\(temperature) is below freezing point of the htf")
    return density[0] + density[1] * temperature.celsius
      + density[2] * temperature.celsius * temperature.celsius
  }

  func enthalpy(_ temperature: Temperature) -> Double {
    precondition(temperature.kelvin > freezeTemperature.kelvin)
    return enthaplyFromTemperature(temperature.celsius)
  }

  func temperature(_ enthalpy: Double) -> Temperature {
    return Temperature(celsius: temperatureFromEnthalpy(enthalpy))
  }

  func mixingTemperature(_ f1: HeatCycle, _ f2: HeatCycle)
    -> Temperature
  {
    let (t1, t2) = (f1.outletTemperature, f2.outletTemperature)
    let (mf1, mf2) = (f1.massFlow.rate, f2.massFlow.rate)
    guard mf1 + mf2 > 0 else { return Temperature((t1 + t2) / 2) }
    let cap1 = heatCapacity[0].addingProduct(heatCapacity[1], t1)
    let cap2 = heatCapacity[0].addingProduct(heatCapacity[1], t2)
    let t = (mf1 * cap1 * t1 + mf2 * cap2 * t2) / (mf1 * cap1 + mf2 * cap2)
    precondition(t > freezeTemperature.kelvin, "Fell below freezing point.\n")
    return Temperature(t)
  }

  func mixingTemperature(inlet f1: HeatCycle, with f2: HeatCycle)
    -> Temperature
  {
    let (t1, t2) = (f1.inletTemperature, f2.outletTemperature)
    let (mf1, mf2) = (f1.massFlow.rate, f2.massFlow.rate)
    guard mf1 + mf2 > 0 else { return Temperature((t1 + t2) / 2) }
    let cap1 = heatCapacity[0].addingProduct(heatCapacity[1], t1)
    let cap2 = heatCapacity[0].addingProduct(heatCapacity[1], t2)
    let t = (mf1 * cap1 * t1 + mf2 * cap2 * t2) / (mf1 * cap1 + mf2 * cap2)
    precondition(t > freezeTemperature.kelvin, "Fell below freezing point.\n")
    return Temperature(t)
  }

  @_transparent private static func temperatureFromHeatCapacity(
    _ specificHeat: Double, _ temperature: Double, coefficients: [Double]
  )
    -> Double
  {
    let t = temperature
    let cp = coefficients
    if cp[1] > 0 {
      return (
        (2 * specificHeat + 2 * cp[0] * t) / cp[1] + t ** 2
          + (cp[0] / cp[1]) ** 2).squareRoot() - cp[0] / cp[1]
    } else {
      return -(
        (2 * specificHeat + 2 * cp[0] * t) / cp[1] + t ** 2
          + (cp[0] / cp[1]) ** 2).squareRoot() - cp[0] / cp[1]
    }
  }

  private static func temperatureFromEnthalpy(
    _ enthalpy: Double, _ temperature: Double,
    coefficients: ([Double], [Double])
  )
    -> Double
  {
    let (h_T, T_h) = coefficients
    var h1 = 0.0
    for coefficient in h_T.reversed() {
      h1 = coefficient.addingProduct(h1, temperature)
    }
    let h2 = enthalpy + h1
    var temperature = 0.0
    for coefficient in T_h.reversed() {
      temperature = coefficient.addingProduct(h2, temperature)
    }
    return temperature
  }

  private static func heatExchanged(
    from high: Double, to low: Double, heatCapacity: [Double]
  )
    -> Double
  {
    var q = heatCapacity[0] * (high - low)
    q += heatCapacity[1] / 2 * (high * high - low * low)
    return q
  }

  @_transparent private static func heatExchanged(
    from high: Double, to low: Double, coefficients: [Double]
  )
    -> Double
  {
    var (h1, h2) = (0.0, 0.0)
    for (i, c) in coefficients.enumerated() {
      h1 += c * (low ** Double(i))
      h2 += c * (high ** Double(i))
    }
    return h2 - h1
  }

  public var description: String {
    var d = ""
    d += "Description:" >< name
    d += "Freezing Point [°C]:" >< "\(freezeTemperature.celsius)"
    d += "Specific Heat as a Function of Temperature; cp(T) = c0+c1*T\n"
    d += "c0:" >< "\(heatCapacity[0])"
    d += "c1:" >< "\(heatCapacity[1])"
    d += "Calculate with Enthalpy:" >< "\(useEnthalpy ? "YES" : "NO")"
    if enthaplyFromTemperature.isEmpty == false {
      d += "Enthalpy as function on Temperature\n"
      for (i, c) in enthaplyFromTemperature.coefficients.enumerated() {
        d += "c\(i):" >< String(format: "%.6E", c)
      }
    }
    if temperatureFromEnthalpy.isEmpty == false {
      d += "Temperature as function on Enthalpy\n"
      for (i, c) in temperatureFromEnthalpy.coefficients.enumerated() {
        d += "c\(i):" >< String(format: "%.6E", c)
      }
    }
    d += "Density as a Function of Temperature; roh(T) = c0+c1*T+c1*T^2\n"
    for (i, c) in density.enumerated() {
      d += "c\(i):" >< String(format: "%.6E", c)
    }
    d += "Viscosity as a Function of Temperature; eta(T) = c0+c1*T+c1*T^2\n"
    for (i, c) in viscosity.enumerated() {
      d += "c\(i):" >< String(format: "%.6E", c)
    }
    d += "Conductivity as a Function of Temperature; lamda(T) = c0+c1*T+c1*T^2\n"
    for (i, c) in thermCon.enumerated() {
      d += "c\(i):" >< String(format: "%.6E", c)
    }
    d += "Maximum Operating Temperature [°C]:" >< "\(maxTemperature.celsius)"
    return d
  }
}

public enum StorageMedium: String {
  case hiXL = "HitecXL"
  case xlt600 = "XLT600"
  case th66 = "TH66"
  case solarSalt = "SolarSalt"

  var properties: HeatTransferFluid {
    switch self {
    case .solarSalt:
      return HeatTransferFluid(
        name: "Solar Salt",
        freezeTemperature: 240.0,
        heatCapacity: [1.44657, 0.000171715],
        dens: [1969.9, -0.603505, 0],
        visco: [0.0175373, -7.01716e-05, 7.62774e-08],
        thermCon: [0.44152, 0.00019, 0],
        maxTemperature: 400.0,
        h_T: [], T_h: [],
        useEnthalpy: false
      )
    default:
      fatalError()
    }
  }
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
    name = try values.decode(String.self, forKey: .name)
    freezeTemperature = try values.decode(Temperature.self, forKey: .freezeTemperature)
    heatCapacity = try values.decode(Array<Double>.self, forKey: .heatCapacity)

    density = try values.decode(Array<Double>.self, forKey: .dens)
    viscosity = try values.decode(Array<Double>.self, forKey: .visco)
    thermCon = try values.decode(Array<Double>.self, forKey: .thermCon)
    maxTemperature = try values.decode(
      Temperature.self,
      forKey: .maxTemperature)
    let h_T = try values.decode(Array<Double>.self, forKey: .h_T)
    enthaplyFromTemperature = Polynomial(h_T)
    let T_h = try values.decode(Array<Double>.self, forKey: .T_h)
    temperatureFromEnthalpy = Polynomial(T_h)
    useEnthalpy = try values.decode(Bool.self, forKey: .withEnthalpy)

    if self.useEnthalpy, !h_T.isEmpty, !T_h.isEmpty {
    } else {
      let cp = heatCapacity
      assert(!cp.isEmpty)
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)    
    try container.encode(name, forKey: .name)
    try container.encode(freezeTemperature, forKey: .freezeTemperature)
    try container.encode(heatCapacity, forKey: .heatCapacity)
    try container.encode(density, forKey: .dens)
    try container.encode(viscosity, forKey: .visco)
    try container.encode(thermCon, forKey: .thermCon)
    try container.encode(maxTemperature, forKey: .maxTemperature)
    try container.encode(enthaplyFromTemperature, forKey: .h_T)
    try container.encode(temperatureFromEnthalpy, forKey: .T_h)
    try container.encode(useEnthalpy, forKey: .withEnthalpy)
  }
}

extension HeatTransferFluid {
  public init(file: TextConfigFile, includesEnthalpy: Bool) throws {
    let line: (Int) throws -> Double = { try file.parseDouble(line: $0) }
    self.name = file.name
    self.freezeTemperature = try Temperature(line(10))
    let heatCapacity = try [line(13), line(15)]
    self.heatCapacity = heatCapacity
    density = try [try line(18), try line(21), line(24)]
    viscosity = try [line(27), line(30), line(33)]
    thermCon = try [line(36), line(39), line(42)]
    maxTemperature = try Temperature(line(45))  // .toKelvin
    if includesEnthalpy {
      let h_T = try [line(47), line(48), line(49), line(50), line(51)]
      enthaplyFromTemperature = Polynomial(h_T)
      let T_h = try [line(53), line(54), line(55), line(56), line(57)]
      temperatureFromEnthalpy = Polynomial(T_h)
      useEnthalpy = try line(59) > 0 ? true : false

    } else {
      self.useEnthalpy = false
      self.enthaplyFromTemperature = []
      self.temperatureFromEnthalpy = []
    }
  }
}
