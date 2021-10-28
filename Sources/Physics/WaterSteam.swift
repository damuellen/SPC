//
//  Copyright 2021 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import CIAPWSIF97

/// IAPWS formulations of the thermodynamic properties of water and steam.
public struct WaterSteam: Codable {
  public var temperature: Temperature
  public var pressure: Double
  public var massFlow: Double
  public var enthalpy: Double

  public init(
    temperature: Temperature,
    pressure: Double,
    massFlow: Double,
    enthalpy: Double
  ) {
    self.temperature = temperature
    self.pressure = pressure
    self.massFlow = massFlow
    self.enthalpy = enthalpy
  }
  /// Temperature on boiling point curve.
  public static func temperature(pressure: Double) -> Temperature {
    let p = pressure / 10
    return Temperature(Ts_p(p))
  }

  /// Specific enthalpy [kJ/kg] on the boiling point curve.
  public static func enthalpyLiquid(pressure: Double) -> Double {
    let p = pressure / 10
    let t = Ts_p(p)
    return h_pT(p, t, 1)
  }

  /// Specific enthalpy [kJ/kg] on the dew point curve.
  public static func enthalpyVapor(pressure: Double) -> Double {
    let p = pressure / 10
    let t = Ts_p(p)
    return h_pT(p, t, 2)
  }

  public static func enthalpy(pressure: Double, temperature: Temperature) -> Double {
    let p = pressure / 10
    let t = temperature.kelvin
    let r = region_pT(p, t)
    return h_pT(p, t, r)
  }

  public static func temperature(pressure: Double, enthalpy: Double) -> Temperature {
    let p = pressure / 10
    let h = enthalpy
    return Temperature(T_ph(p, h))
  }
}

extension WaterSteam {
  public init(temperature: Temperature, pressure: Double, massFlow: Double) {
    self.temperature = temperature
    self.pressure = pressure
    self.massFlow = massFlow
    self.enthalpy = WaterSteam.enthalpy(
      pressure: pressure, temperature: temperature
    )
  }

  public init(enthalpy: Double, pressure: Double, massFlow: Double) {
    self.pressure = pressure
    self.massFlow = massFlow
    self.enthalpy = enthalpy
    self.temperature = WaterSteam.temperature(
      pressure: pressure, enthalpy: enthalpy
    )
  }

  public init() {
    self.pressure = 0
    self.massFlow = 0
    self.enthalpy = 0
    self.temperature = Temperature(celsius: 0)
  }
}
