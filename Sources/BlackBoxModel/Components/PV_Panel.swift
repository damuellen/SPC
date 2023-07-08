//
//  Copyright 2021 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
import Libc
import Units

extension PV {
  /// Wraps low-level functions for solving the single diode equation.
  public struct Cell {
    /// Radiation at Standard Test Conditions
    static let radiation_at_STC = 1000.0
    /// Temperature at Standard Test Conditions
    static let temperature_at_STC = Temperature(celsius: 25.0)
    /// Boltzman constant
    static let k = 1.3806488E-23
    /// Electron charge in coulombs
    static let q = 1.60217646E-19
    /// Short circuit current in Amperes
    let Isc: Double
    /// Single diode model series resistor in Ohms
    let Rs: Double
    /// Single diode model RshRef resistor in Ohms
    let RshRef: Double
    /// Single diode model shunt resistor when Ginc = 0 in Ohms
    let Rsh0: Double
    /// Short circuit curent variaton in A/ºC
    let muIsc: Double
    /// Saturation current reference
    let Ioref: Double
    let gamma: Double
    let Egap: Double

    init() {
      self.Isc = 9.517
      self.Rs = 0.272
      self.RshRef = 3000
      self.Rsh0 = 10000
      self.muIsc = 5.7E-3
      self.Ioref = 0.012E-9
      self.gamma = 0.96
      self.Egap = 1.12
    }

    func callAsFunction(
      radiation: Double, temperature: Temperature) -> (Double, Double, Double) {
      let Iph = photocurrent(radiation: radiation, temperature: temperature)
      let Rsh = Rshunt(radiation: radiation, temperature: temperature)
      let Io = saturationCurrent(temperature: temperature)
      return (Iph, Rsh, Io)
    }

    /// Returns the radiation equivalent current within the single diode model.
    func photocurrent(radiation: Double, temperature: Temperature) -> Double {
      (radiation / Cell.radiation_at_STC)
        * (Isc - muIsc * (temperature - Cell.temperature_at_STC).kelvin)
    }
    /// Returns the corrected saturation current of the diode within the single diode model.
    func saturationCurrent(temperature: Temperature) -> Double {
      Ioref * pow(temperature.kelvin / Cell.temperature_at_STC.kelvin, 3)
        * exp(
          Cell.q * Egap / (gamma * Cell.k)
            * ((1 / Cell.temperature_at_STC.kelvin) - (1 / temperature.kelvin)))
    }
    /// Returns the corrected Rshunt of the single diode model.
    func Rshunt(radiation: Double, temperature: Temperature) -> Double {
      RshRef + (Rsh0 - RshRef) * exp(5.5 * radiation / Cell.radiation_at_STC)
    }
  }

  public struct PowerPoint: CustomStringConvertible {
    let current: Double
    let voltage: Double
    let power: Double

    static var zero: PowerPoint = .init(current: 0, voltage: 0)

    public var description: String {
      String(format: "Vmp: %03.2f", voltage) + "\t"
      + String(format: "Imp: %03.2f", current) + "\t"
      + String(format: "Pmp: %03.2f", power)
    }

    init(current: Double, voltage: Double) {
      self.current = current
      self.voltage = voltage
      self.power = abs(current * voltage)
    }
  }

  public struct Panel {
    let cell: Cell
    /// Nominal power in Watts
    let nominalPower: Double
    /// Panel Area in m^2
    let area: Double
    /// Number of cells of the panel
    let numberOfCells: Int

    public init() {
      self.cell = Cell()
      self.nominalPower = 390
      self.area = 1.972
      self.numberOfCells = 76
    }
    
    /// Returns the temperature of the panel.
    func temperature(
      radiation: Double, ambient: Temperature, windSpeed: Double) -> Temperature {
      /// Absorption coefficient of the module
      let alpha = 0.9
      let efficiency = nominalPower / (area * Cell.radiation_at_STC)
      /// Constant heat transfer component
      let Uc = 20.0
      /// Convective heat transfer component
      let Uv = 0.0
      let U = Uc + Uv * windSpeed
      return ambient + ((1 / U) * alpha * radiation * (1 - efficiency))
    }
    /// The voltage from a current point within the I-V curve using the single diode model
    func voltageFrom(current: Double, radiation: Double, cell_T: Temperature) -> Double {
      let nVth =
        cell.gamma * Double(numberOfCells) * Cell.k * cell_T.kelvin / Cell.q

      let I = cell.photocurrent(radiation: radiation, temperature: cell_T)
      let Rsh = cell.Rshunt(radiation: radiation, temperature: cell_T)

      let argW = (I * Rsh / nVth) * exp(Rsh * (-current + I + I) / nVth)
      var inputterm = lambertW(argW)

      if inputterm.isNaN {
        let logargW =
          log(I) + log(Rsh) + Rsh * (I + I - current) / nVth - log(nVth)

        var w = logargW
        let K = Int(log10(w))

        for _ in 0..<(3 * K) { w *= (1 - log(w) + logargW) / (1.0 + w) }
        inputterm = w
      }
      return Rsh
        * (-current * (cell.Rs / Rsh + 1.0) + I - nVth / Rsh * inputterm + I)
    }
    /// The current from a voltage value within the I-V curve using the single diode model
    func currentFrom(voltage: Double, radiation: Double, cell_T: Temperature) -> Double {
      // The cells are connected in parallel, the voltage splits.
      let voltage = voltage / Double(numberOfCells)
      let nVth =
        cell.gamma * Double(numberOfCells) * Cell.k * cell_T.kelvin / Cell.q

      let (Iph, Rsh, Isat) = cell(radiation: radiation, temperature: cell_T)

      let argW =
        cell.Rs * Isat
        * exp(Rsh * (cell.Rs * (Iph + Isat) + voltage) / (nVth * (cell.Rs + Rsh)))
      let inputterm = lambertW(argW)
      return -voltage / (cell.Rs + Rsh) - (nVth / cell.Rs) * inputterm + Rsh
        * (Iph + Isat) / (cell.Rs + Rsh)
    }

    func callAsFunction(
      radiation: Double, ambient: Temperature, windSpeed: Double
    ) -> PowerPoint {
      let cell_T = temperature(
        radiation: radiation, ambient: ambient, windSpeed: windSpeed)
      let nVth =
        cell.gamma * Double(numberOfCells) * Cell.k * cell_T.kelvin / Cell.q

      let (Iph, Rsh, Isat) = cell(radiation: radiation, temperature: cell_T)
      /// Returns Imp, Vmp, Pmp for the IV curve described by input parameters.
      return Mpp_bisect(Iph: Iph, Io: Isat, a: nVth, Rsh: Rsh)
    }

    private func Mpp_bisect(
      Iph: Double, Io: Double, a: Double, Rsh: Double
    ) -> PowerPoint {
      let Imp = Imp_bisect(Iph: Iph, Io: Io, nVth: a, Rs: cell.Rs, Rsh: Rsh)
      let z = phi_exact(Imp: Imp, IL: Iph, Io: Io, a: a, Rsh: Rsh)
      let Vmp = (Iph + Io - Imp) * Rsh - Imp * cell.Rs - a * z
      return PowerPoint(current: Imp, voltage: Vmp)
    }
    /// Calculates the value of Imp (current at maximum power point) for an IV
    /// curve with parameters Iph, Io, a, Rs, Rsh. Imp is found as the value of
    /// I for which g(I)=dP/dV (I) = 0.
    private func Imp_bisect(
      Iph: Double, Io: Double, nVth: Double, Rs: Double, Rsh: Double
    ) -> Double {
      /// Set up lower and upper bounds on I_mp
      var A = 0.0
      var B = Iph + Io
      /// Detect when lower and upper bounds are not consistent with finding
      /// the zero of dP/dV
      var gA = g(I: A, Iph: Iph, Io: Io, a: nVth, Rs: Rs, Rsh: Rsh)
      let gB = g(I: B, Iph: Iph, Io: Io, a: nVth, Rs: Rs, Rsh: Rsh)
      // This will set Imp values where gA*gB>0 to NaN
      if gA * gB > 0 { A = .nan }
      /// Midpoint is initial guess for I_mp
      var p = (A + B) / 2
      /// Value of dP/dV at initial guess p
      var err = g(I: p, Iph: Iph, Io: Io, a: nVth, Rs: Rs, Rsh: Rsh)
      /// Set precision of estimate of Imp to 1e-6 (A)
      let tolerance = 1e-6
      while abs(B - A) > tolerance {
        /// Value of dP/dV at left endpoint
        gA = g(I: A, Iph: Iph, Io: Io, a: nVth, Rs: Rs, Rsh: Rsh)
        if gA * err > .zero { A = p } else { B = p }
        p = (A + B) / 2
        err = g(I: p, Iph: Iph, Io: Io, a: nVth, Rs: Rs, Rsh: Rsh)
      }
      return p
    }
    /// Calculates dP/dV exactly, using p=I*V=I*V(I), where V=V(I) uses the
    /// Lambert's W function W(phi) ([2], Eq. 3).
    private func g(
      I: Double, Iph: Double, Io: Double, a: Double, Rs: Double, Rsh: Double
    ) -> Double {
      /// calculate W(phi)
      let z = phi_exact(Imp: I, IL: Iph, Io: Io, a: a, Rsh: Rsh)
      /// calculate dP/dV
      return (Iph + Io - 2 * I) * Rsh - 2 * I * Rs - a * z + I * Rsh * z
        / (1 + z)
    }
    /// Calculates W(phi) where phi is the argument of the
    /// Lambert W function in V = V(I) at I=I_mp ([2], Eq. 3).
    /// Formula for phi is given in code below as argw.
    private func phi_exact(
      Imp: Double, IL: Double, Io: Double, a: Double, Rsh: Double
    ) -> Double {
      let argw = Rsh * Io / a * exp(Rsh * (IL + Io - Imp) / a)

      guard argw > .zero else { return .nan }
      var tmp = lambertW(argw)
      // Only re-compute LambertW if it overflowed
      if tmp.isNaN {
        let logargW = log(Rsh) + log(Io) - log(a) + Rsh * (IL + Io - Imp) / a
        var x = logargW
        let K = Int(log10(x))
        for _ in 0..<K { x = x * ((1 - log(x)) + logargW) / (1 + x) }
        tmp = x
      }
      return tmp
    }
  }
}

/// Implementation of the Lambert W function, which is a special function that is the inverse of the function f(w) = w * exp(w). 
/// 
/// The Lambert W function is used in various mathematical and scientific applications, including solving equations involving exponential and logarithmic functions.
func lambertW(_ z: Double) -> Double {
  var tmp: Double
  var c1: Double
  var c2: Double
  var w1: Double
  var dw: Double
  var z = z
  var w = z

  if abs(z + 0.367879441171442) <= 1.5 {
    w = sqrt(5.43656365691809 * w + 2) - 1
  } else {
    if z == 0 { z = 1 }
    tmp = log(z)
    w = tmp - log(tmp)
  }
  w1 = w
  for _ in 1...36 {
    c1 = exp(w)
    c2 = w * c1 - z
    if w != -1 { w1 = w + 1 }
    dw = c2 / (c1 * w1 - ((w + 2) * c2 / (2 * w1)))
    w = w - dw
    if abs(dw) < 7e-17 * (2 + abs(w1)) { break }
  }
  return w
}
