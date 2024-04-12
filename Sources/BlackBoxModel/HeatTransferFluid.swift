//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Utilities
import Units
import Libc

public typealias Heat = Double
public typealias Pressure = Double

extension HeatTransferFluid {

  public static let VP1 = HeatTransferFluid(
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

  public static let XLP = HeatTransferFluid(
    name: "Helisol XLP", freezeTemperature: 0.0,
    heatCapacity: [
      -4.10349394308805, 0.131924308102715, -0.00125262719213376,
      6.35344114963126e-06, -1.78368416423495e-08, 2.62912713651709e-11,
      -1.58828198049302e-14,
    ],
    dens: [
      1060.8315717428923, 0.9138783244416118, -0.0077057779217284406,
      1.436514787256371e-05, -1.0360181673055996e-08
    ],
    visco: [
      -0.0194013913496905, 0.000430698361240265, -3.4891264389988e-06,
      1.43896557396696e-08, -3.25124460239875e-11, 3.84423262823152e-14,
      -1.86465176227281e-17,
    ], thermCon: [0.14246307960332, -0.00028822299651568, 2.975073706781e-07],
    maxTemperature: 450.0,
    h_T: [
      -88.469529331749, 3.93395842253904, -0.0230480305214602,
      0.000120735120072059, -3.3225451556988e-07, 4.78450915832572e-10,
      -2.80342523341999e-13,
    ],
    T_h: [
      -0.245746704987653, 0.543040467737289, 0.000573657916311544,
      -2.35758605126147e-06, 3.85253198875837e-09, -3.13429657069657e-12,
      1.0194510189767e-15,
    ], useEnthalpy: true
  )
}

/// The Heat Transfer Fluid is characterized through maximum operating temperature,
/// freeze temperature, specific heat capacity, viscosity, thermal conductivity,
/// enthalpy, and density as a function of temperature.
public struct HeatTransferFluid: CustomStringConvertible, Equatable {
  /// Product designation
  public let name: String
  /// Freezing point
  public let freezeTemperature: Temperature
  public let heatCapacity: [Double]
  let density: [Double]
  let viscosity: [Double]
  let thermCon: [Double]
  /// Permissible maximum temperature
  public let maxTemperature: Temperature
  /// Coefficients for calculating the enthalpy as a function of temperature
  let enthalpyFromTemperature: Polynomial
  /// Coefficients for calculating the temperature as a function of enthalpy
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
    let degree: Double =
      useEnthalpy
      ? temperature(enthalpy: heat, degree: t.celsius)
      : temperature(specificHeat: heat, degree: t.celsius)
    return Temperature(celsius: degree)
  }

  public func density(_ temperature: Temperature) -> Double {
    precondition(
      temperature.kelvin > freezeTemperature.kelvin,
      "\(temperature) is below freezing point of the htf")
    if density.count > 3 {
      return Polynomial(density)(temperature)
    } else {
      return density[0] + density[1] * temperature.celsius
            + density[2] * temperature.celsius * temperature.celsius
    }
  }

  public func enthalpy(_ temperature: Temperature) -> Double {
    precondition(temperature.kelvin > freezeTemperature.kelvin)
    return enthalpyFromTemperature.callAsFunction(temperature.celsius)
  }

  public func temperature(_ enthalpy: Double) -> Temperature {
    let celsius = temperatureFromEnthalpy.callAsFunction(enthalpy)
    precondition(
      celsius > freezeTemperature.celsius,
      "Fell below freezing point.\n")
    return Temperature(celsius: celsius)
  }

  public func temperature(specificHeat: Double, degree: Double) -> Double {
    let t = degree
    let cp = heatCapacity
    if cp[1] > 0 {
      return
        ((2 * specificHeat + 2 * cp[0] * t) / cp[1] + t * t
        + (cp[0] / cp[1]) * (cp[0] / cp[1])).squareRoot() - cp[0] / cp[1]
    } else {
      return
        -((2 * specificHeat + 2 * cp[0] * t) / cp[1] + t * t
        + (cp[0] / cp[1]) * (cp[0] / cp[1])).squareRoot() - cp[0] / cp[1]
    }
  }

  public func temperature(enthalpy: Double, degree: Double) -> Double {
    let h1 = enthalpyFromTemperature.callAsFunction(degree)
    let h2 = enthalpy + h1
    let temperature = temperatureFromEnthalpy.callAsFunction(h2)
    return temperature
  }

  static func change(
    from high: Double, to low: Double, heatCapacity: [Double]
  ) -> Double {
    var q = heatCapacity[0] * (high - low)
    q += heatCapacity[1] / 2 * (high * high - low * low)
    return q
  }

  static func change(
    from high: Double, to low: Double, enthalpy: [Double]
  ) -> Double {
    var (h1, h2) = (0.0, 0.0)
    for (i, c) in enthalpy.enumerated() {
      h1 += c * pow(low, Double(i))
      h2 += c * pow(high, Double(i))
    }
    return h2 - h1
  }

  public var description: String {
    "Description:" * name
      + "Freezing Point [°C]:" * String(format: "%.1f", freezeTemperature.celsius)
      + "Specific Heat as a Function of Temperature; cp(T) = c0+c1*T\n"
      + "c0:" * String(format: "%G", heatCapacity[0])
      + "c1:" * String(format: "%G", heatCapacity[1])
      + "Calculate with Enthalpy:" * (useEnthalpy ? "YES" : "NO")
      + (enthalpyFromTemperature.isEmpty == false
        ? "Enthalpy as function on Temperature"
          + "\n\(enthalpyFromTemperature)" : "")
      + (temperatureFromEnthalpy.isEmpty == false
        ? "Temperature as function on Enthalpy"
          + "\n\(temperatureFromEnthalpy)" : "")
      + "Density as a Function of Temperature; roh(T) = c0+c1*T+c1*T^2"
      + "\n\(Polynomial(density))"
      + "Viscosity as a Function of Temperature; eta(T) = c0+c1*T+c1*T^2"
      + "\n\(Polynomial(viscosity))"
      + "Conductivity as a Function of Temperature; lamda(T) = c0+c1*T+c1*T^2"
      + "\n\(Polynomial(thermCon))"
      + "Maximum Operating Temperature [°C]:"
      * String(format: "%.1f", maxTemperature.celsius)
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
