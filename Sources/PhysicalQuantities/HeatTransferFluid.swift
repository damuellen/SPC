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
import Libc

public typealias Heat = Double
public typealias Pressure = Double

public let VP1 = HeatTransferFluid(
  name: "Therminol VP1",
  freezeTemperature: 12,
  heatCapacity: [1.4856, 0.0028],
  dens: [1074.964, -0.6740513, -0.000650017],
  visco: [-0.000201537, 0.1273247, -0.7167957],
  thermCon: [0.1378081, -8.41485e-05, -1.788e-07],
  maxTemperature: 393.0,
  h_T: [-0.62677, 1.51129, 0.0012941, 1.23697e-07, 0],
  T_h: [0.58315, 0.65556, -0.00032293, 1.9425e-07, -6.1133e-11],
  useEnthalpy: false
)

public let HELISOL_XLP = HeatTransferFluid(
  name: "Helisol XLP",
  freezeTemperature: 0.0,
  heatCapacity: [
    -1.58828198049302E-14,
    2.62912713651709E-11,
    -1.78368416423495E-08,
    6.35344114963126E-06,
    -1.25262719213376E-03,
    1.31924308102715E-01,
    -4.10349394308805E+00,
  ].reversed(),
  dens: [
    2.58818883828842E-12,
    -4.41892055919859E-09,
    3.06805664086603E-06,
    -1.11688325387582E-03,
    2.23959978961942E-01,
    -2.44772025890099E+01,
    1.98218481500559E+03,
  ].reversed(),
  visco: [
    -1.86465176227281E-17,
    3.84423262823152E-14,
    -3.25124460239875E-11,
    1.43896557396696E-08,
    -3.48912643899880E-06,
    4.30698361240265E-04,
    -1.94013913496905E-02,
  ].reversed(),
  thermCon: [
    2.9750737067810E-07,
    -2.8822299651568E-04,
    1.4246307960332E-01,
  ].reversed(),
  maxTemperature: 450.0,
  h_T: [
    -2.80342523341999E-13,
    4.78450915832572E-10,
    -3.32254515569880E-07,
    1.20735120072059E-04,
    -2.30480305214602E-02,
    3.93395842253904E+00,
    -8.84695293317490E+01,
  ].reversed(),
  T_h: [
    1.01945101897670E-15,
    -3.13429657069657E-12,
    3.85253198875837E-09,
    -2.35758605126147E-06,
    5.73657916311544E-04,
    5.43040467737289E-01,
    -2.45746704987653E-01,
  ].reversed(),
  useEnthalpy: true
)

/// The Heat Transfer Fluid is characterized through maximum operating temperature,
/// freeze temperature, specific heat capacity, viscosity, thermal conductivity,
/// enthalpy, and density as a function of temperature.
public struct HeatTransferFluid: CustomStringConvertible, Equatable {

  public let name: String
  public let freezeTemperature: Temperature
  public let heatCapacity: [Double]
  let density: [Double]
  let viscosity: [Double]
  let thermCon: [Double]
  public let maxTemperature: Temperature
  let enthalpyFromTemperature: Polynomial
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
    self.enthalpyFromTemperature = Polynomial(h_T)
    self.temperatureFromEnthalpy = Polynomial(T_h)

    if useEnthalpy, !h_T.isEmpty, !T_h.isEmpty {
      self.useEnthalpy = true
    } else {
      assert(!heatCapacity.isEmpty)
      self.useEnthalpy = false
    }
  }

  public func heatContent(_ t1: Temperature, _ t2: Temperature) -> Heat {
    if useEnthalpy {
      return HeatTransferFluid.change(
        from: t1.celsius, to: t2.celsius,
        enthalpy: enthalpyFromTemperature.coefficients
      )
    }
    return HeatTransferFluid.change(
      from: t1.celsius, to: t2.celsius, heatCapacity: heatCapacity
    )
  }

  public func temperature(_ heat: Heat, _ t: Temperature) -> Temperature {
    let degree: Double = useEnthalpy
      ? temperature(enthalpy: heat, degree: t.celsius)
      : temperature(specificHeat: heat, degree: t.celsius)
    return Temperature(celsius: degree)
  }

  public func density(_ temperature: Temperature) -> Double {
    precondition(
      temperature.kelvin > freezeTemperature.kelvin,
      "\(temperature) is below freezing point of the htf")
    return density[0] + density[1] * temperature.celsius
      + density[2] * temperature.celsius * temperature.celsius
  }

  public func enthalpy(_ temperature: Temperature) -> Double {
    precondition(temperature.kelvin > freezeTemperature.kelvin)
    return enthalpyFromTemperature(temperature.celsius)
  }

  public func temperature(_ enthalpy: Double) -> Temperature {
    let celsius = temperatureFromEnthalpy(enthalpy)
    precondition(celsius > freezeTemperature.celsius,
      "Fell below freezing point.\n")
    return Temperature(celsius: celsius)
  }

  public func temperature(specificHeat: Double, degree: Double) -> Double {
    let t = degree
    let cp = heatCapacity
    if cp[1] > 0 {
      return (
        (2 * specificHeat + 2 * cp[0] * t) / cp[1] + t * t
          + (cp[0] / cp[1]) * (cp[0] / cp[1])).squareRoot() - cp[0] / cp[1]
    } else {
      return -(
        (2 * specificHeat + 2 * cp[0] * t) / cp[1] + t * t
          + (cp[0] / cp[1]) * (cp[0] / cp[1])).squareRoot() - cp[0] / cp[1]
    }
  }

  public func temperature(enthalpy: Double, degree: Double) -> Double {
    let h1 = enthalpyFromTemperature(degree)
    let h2 = enthalpy + h1
    let temperature = temperatureFromEnthalpy(h2)
    return temperature
  }

  static func change(
    from high: Double, to low: Double, heatCapacity: [Double]) -> Double
  {
    var q = heatCapacity[0] * (high - low)
    q += heatCapacity[1] / 2 * (high * high - low * low)
    return q
  }

  static func change(
    from high: Double, to low: Double, enthalpy: [Double]) -> Double
  {
    var (h1, h2) = (0.0, 0.0)
    for (i, c) in enthalpy.enumerated() {
      h1 += c * pow(low, Double(i))
      h2 += c * pow(high, Double(i))
    }
    return h2 - h1
  }

  public var description: String {
    "Description:" * name
    + "Freezing Point [°C]:" * freezeTemperature.celsius.description
    + "Specific Heat as a Function of Temperature; cp(T) = c0+c1*T\n"
    + "c0:" * heatCapacity[0].description
    + "c1:" * heatCapacity[1].description
    + "Calculate with Enthalpy:" * (useEnthalpy ? "YES" : "NO")
    + (enthalpyFromTemperature.isEmpty == false ?
    "Enthalpy as function on Temperature"
    + "\n\(enthalpyFromTemperature)" : "")
    + (temperatureFromEnthalpy.isEmpty == false ?
    "Temperature as function on Enthalpy"
    + "\n\(temperatureFromEnthalpy)" : "")
    + "Density as a Function of Temperature; roh(T) = c0+c1*T+c1*T^2"
    + "\n\(Polynomial(density))"
    + "Viscosity as a Function of Temperature; eta(T) = c0+c1*T+c1*T^2"
    + "\n\(Polynomial(viscosity))"
    + "Conductivity as a Function of Temperature; lamda(T) = c0+c1*T+c1*T^2"
    + "\n\(Polynomial(thermCon))"
    + "Maximum Operating Temperature [°C]:"
    * maxTemperature.celsius.description
  }
}

public enum StorageMedium: String {
  case hiXL = "HitecXL"
  case xlt600 = "XLT600"
  case th66 = "TH66"
  case solarSalt = "SolarSalt"

  static var ss = HeatTransferFluid(
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

  public var properties: HeatTransferFluid {
    switch self {
    case .solarSalt:
      return StorageMedium.ss
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
    enthalpyFromTemperature = Polynomial(h_T)
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
    try container.encode(enthalpyFromTemperature, forKey: .h_T)
    try container.encode(temperatureFromEnthalpy, forKey: .T_h)
    try container.encode(useEnthalpy, forKey: .withEnthalpy)
  }
}

extension HeatTransferFluid {
  public init(file: TextConfigFile) throws {
    let ln: (Int) throws -> Double = { try file.double(line: $0) }
    self.name = file.name
    self.freezeTemperature = try Temperature(celsius: ln(10))
    self.heatCapacity = try [ln(13), ln(16)]
    self.density = try [ln(19), ln(22), ln(25)]
    self.viscosity = try [ln(28), ln(31), ln(34)]
    self.thermCon = try [ln(37), ln(40), ln(43)]
    self.maxTemperature = try Temperature(celsius: ln(46))
    /* if includesEnthalpy {
      let h_T = try [ln(47), ln(48), ln(49), ln(50), ln(51)]
      enthaplyFromTemperature = Polynomial(h_T)
      let T_h = try [ln(53), ln(54), ln(55), ln(56), ln(57)]
      temperatureFromEnthalpy = Polynomial(T_h)
      useEnthalpy = try ln(59) > 0 ? true : false

    } else { */
      self.useEnthalpy = false
      self.enthalpyFromTemperature = []
      self.temperatureFromEnthalpy = []
    // }
  }
}
