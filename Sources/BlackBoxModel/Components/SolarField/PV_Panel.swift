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
import PhysicalQuantities

extension PV {
  /// Wraps low-level functions for solving the single diode equation.
  public struct Cell {
    static let radiation_at_ST = 1000.0
    static let temperature_at_ST = Temperature(celsius: 25.0)
    static let k = 1.3806488E-23
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

    func temperature(
      radiation: Double, ambient: Temperature, windSpeed: Double,
      nominalPower: Double, panelArea: Double
    ) -> Temperature {
      let alpha = 0.9
      let efficiency = nominalPower / (panelArea * Cell.radiation_at_ST)
      let Uc = 20.0
      let Uv = 0.0
      let U = Uc + Uv * windSpeed
      return ambient + ((1 / U) * alpha * radiation * (1 - efficiency))
    }

    func photocurrent(radiation: Double, temperature: Temperature) -> Double {
      (radiation / Cell.radiation_at_ST)
        * (Isc - muIsc * (temperature - Cell.temperature_at_ST).kelvin)
    }

    func saturationCurrent(temperature: Temperature) -> Double {
      Ioref * pow(temperature.kelvin / Cell.temperature_at_ST.kelvin, 3)
        * exp(
          Cell.q * Egap / (gamma * Cell.k)
            * ((1 / Cell.temperature_at_ST.kelvin) - (1 / temperature.kelvin)))
    }

    func Rshunt(radiation: Double, temperature: Temperature) -> Double {
      RshRef + (Rsh0 - RshRef) * exp(5.5 * radiation / Cell.radiation_at_ST)
    }
  }

  public struct PowerPoint {
    let current: Double
    let voltage: Double
    let power: Double

    static var zero: PowerPoint = .init(current: 0, voltage: 0)

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

    func voltage(current: Double, radiation: Double, temperature: Temperature)
      -> Double
    {
      let nVth =
        cell.gamma * Double(numberOfCells) * Cell.k * temperature.kelvin / Cell.q

      let Iph = cell.photocurrent(radiation: radiation, temperature: temperature)
      let Rsh = cell.Rshunt(radiation: radiation, temperature: temperature)
      let I0 = cell.photocurrent(radiation: radiation, temperature: temperature)

      let argW = (I0 * Rsh / nVth) * exp(Rsh * (-current + Iph + I0) / nVth)
      var inputterm = lambertW(argW)

      if inputterm.isNaN {
        let logargW =
          log(I0) + log(Rsh) + Rsh * (Iph + I0 - current) / nVth - log(nVth)

        var w = logargW
        let K = Int(log10(w))

        for _ in 0..<(3 * K) { w *= (1 - log(w) + logargW) / (1.0 + w) }
        inputterm = w
      }
      return Rsh
        * (-current * (cell.Rs / Rsh + 1.0) + Iph - nVth / Rsh * inputterm + I0)
    }

    func current(voltage: Double, radiation: Double, temperature: Temperature)
      -> Double
    {
      let nVth =
        cell.gamma * Double(numberOfCells) * Cell.k * temperature.kelvin / Cell.q

      let Iph = cell.photocurrent(radiation: radiation, temperature: temperature)
      let Rsh = cell.Rshunt(radiation: radiation, temperature: temperature)
      let I0 = cell.saturationCurrent(temperature: temperature)

      let argW =
        cell.Rs * I0
        * exp(Rsh * (cell.Rs * (Iph + I0) + voltage) / (nVth * (cell.Rs + Rsh)))
      let inputterm = lambertW(argW)
      return -voltage / (cell.Rs + Rsh) - (nVth / cell.Rs) * inputterm + Rsh
        * (Iph + I0) / (cell.Rs + Rsh)
    }

    func power(
      radiation: Double, ambient: Temperature, windSpeed: Double
    ) -> PowerPoint {
      let temperature = cell.temperature(
        radiation: radiation, ambient: ambient, windSpeed: windSpeed,
        nominalPower: nominalPower, panelArea: area)

      let nVth =
        cell.gamma * Double(numberOfCells) * Cell.k * temperature.kelvin / Cell.q

      let Iph = cell.photocurrent(radiation: radiation, temperature: temperature)
      let Rsh = cell.Rshunt(radiation: radiation, temperature: temperature)
      let I0 = cell.saturationCurrent(temperature: temperature)
      return Pmp_bisect(Iph: Iph, Io: I0, a: nVth, Rsh: Rsh)
    }

    private func Pmp_bisect(
      Iph: Double, Io: Double, a: Double, Rsh: Double
    ) -> PowerPoint {
      let Imp = Imp_bisect(Iph: Iph, Io: Io, nVth: a, Rs: cell.Rs, Rsh: Rsh)
      let z = phi_exact(Imp: Imp, IL: Iph, Io: Io, a: a, Rsh: Rsh)
      let Vmp = (Iph + Io - Imp) * Rsh - Imp * cell.Rs - a * z
      return PowerPoint(current: Imp, voltage: Vmp)
    }

    private func Imp_bisect(
      Iph: Double, Io: Double, nVth: Double, Rs: Double, Rsh: Double
    ) -> Double {
      var A = 0.0
      var B = Iph + Io

      var gA = g(I: A, Iph: Iph, Io: Io, a: nVth, Rs: Rs, Rsh: Rsh)
      let gB = g(I: B, Iph: Iph, Io: Io, a: nVth, Rs: Rs, Rsh: Rsh)

      if gA * gB > 0 { A = .nan }

      var p = (A + B) / 2
      var err = g(I: p, Iph: Iph, Io: Io, a: nVth, Rs: Rs, Rsh: Rsh)

      while abs(B - A) > 1e-6 {
        gA = g(I: A, Iph: Iph, Io: Io, a: nVth, Rs: Rs, Rsh: Rsh)
        if gA * err > .zero { A = p } else { B = p }
        p = (A + B) / 2
        err = g(I: p, Iph: Iph, Io: Io, a: nVth, Rs: Rs, Rsh: Rsh)
      }
      return p
    }

    private func g(
      I: Double, Iph: Double, Io: Double, a: Double, Rs: Double, Rsh: Double
    ) -> Double {
      let z = phi_exact(Imp: I, IL: Iph, Io: Io, a: a, Rsh: Rsh)
      return (Iph + Io - 2 * I) * Rsh - 2 * I * Rs - a * z + I * Rsh * z
        / (1 + z)
    }

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

fileprivate func lambertW(_ z: Double) -> Double {
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
