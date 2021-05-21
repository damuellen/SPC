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

struct Cell {
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
  let Ioref: Double
  let gamma: Double
  let Egap: Double

  public struct PowerPoint {
    let current: Double
    let voltage: Double
    let power: Double

    static var zero: PowerPoint = .init(current: 0, voltage: 0)

    init(current: Double, voltage: Double) {
      self.current = current
      self.voltage = voltage
      self.power = current * voltage
    }
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

struct Panel {
  let cell: Cell
  /// Nominal power in Watts
  let nominalPower: Double
  /// Panel Area in m^2
  let area: Double
  /// Number of cells of the panel
  let numberOfCells: Int

  func voltage(radiation: Double, temperature: Temperature, current: Double)
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

  func current(radiation: Double, temperature: Temperature, voltage: Double)
    -> Double
  {
    let nVth =
      cell.gamma * Double(numberOfCells) * Cell.k * temperature.kelvin / Cell.q

    let Iph = cell.photocurrent(radiation: radiation, temperature: temperature)
    let Rsh = cell.Rshunt(radiation: radiation, temperature: temperature)
    let I0 = cell.photocurrent(radiation: radiation, temperature: temperature)

    let argW =
      cell.Rs * I0
      * exp(Rsh * (cell.Rs * (Iph + I0) + voltage) / (nVth * (cell.Rs + Rsh)))
    let inputterm = lambertW(argW)
    return -voltage / (cell.Rs + Rsh) - (nVth / cell.Rs) * inputterm + Rsh
      * (Iph + I0) / (cell.Rs + Rsh)
  }

  public func maxPowerPoint(
    radiation: Double, ambient: Temperature, windSpeed: Double
  ) -> Cell.PowerPoint {
    guard radiation > .zero else { return .zero }
    let cell_temp = cell.temperature(
      radiation: radiation, ambient: ambient, windSpeed: windSpeed,
      nominalPower: nominalPower, panelArea: area)

    let nVth =
      cell.gamma * Double(numberOfCells) * Cell.k * cell_temp.kelvin / Cell.q

    let Iph = cell.photocurrent(radiation: radiation, temperature: cell_temp)
    let Rsh = cell.Rshunt(radiation: radiation, temperature: cell_temp)
    let I0 = cell.saturationCurrent(temperature: cell_temp)
    return bisect(Iph: Iph, Io: I0, a: nVth, Rsh: Rsh)
  }

  public func maxPowerPoint(radiation: Double, temperature: Temperature)
    -> Cell.PowerPoint
  {
    guard radiation > .zero else { return .zero }

    let nVth =
      cell.gamma * Double(numberOfCells) * Cell.k * temperature.kelvin / Cell.q

    let Iph = cell.photocurrent(radiation: radiation, temperature: temperature)
    let Rsh = cell.Rshunt(radiation: radiation, temperature: temperature)
    let I0 = cell.saturationCurrent(temperature: temperature)
    return bisect(Iph: Iph, Io: I0, a: nVth, Rsh: Rsh)
  }

  func bisect(Iph: Double, Io: Double, a: Double, Rsh: Double) -> Cell.PowerPoint {
    let Imp = calc_Imp_bisect(Iph, Io, a, cell.Rs, Rsh)
    let z = calc_phi_exact(Imp, Iph, Io, a, Rsh)
    let Vmp = (Iph + Io - Imp) * Rsh - Imp * cell.Rs - a * z
    return Cell.PowerPoint(current: Imp, voltage: Vmp)
  }

  //  func calc_Voc(Iph: Double, Io: Double, nVth: Double, Rs: Double, Rsh: Double) -> Double {
  //    V_from_I(Rsh, Rs, nVth, 0, Io, Iph)
  //  }

  func calc_Imp_bisect(
    _ Iph: Double, _ Io: Double, _ nVth: Double, _ Rs: Double, _ Rsh: Double
  ) -> Double {
    var A = 0.0
    var B = Iph + Io

    var gA = g(A, Iph, Io, nVth, Rs, Rsh)
    var gB = g(B, Iph, Io, nVth, Rs, Rsh)

    if gA * gB > 0 { A = .nan }

    var p = (A + B) / 2
    var err = g(p, Iph, Io, nVth, Rs, Rsh)

    while abs(B - A) > 1e-6 {
      gA = g(A, Iph, Io, nVth, Rs, Rsh)

      if gA * err > .zero { A = p } else { B = p }

      p = (A + B) / 2

      err = g(p, Iph, Io, nVth, Rs, Rsh)
    }

    return p
  }

  func g(
    _ I: Double, _ Iph: Double, _ Io: Double, _ a: Double, _ Rs: Double,
    _ Rsh: Double
  ) -> Double {
    let z = calc_phi_exact(I, Iph, Io, a, Rsh)
    return (Iph + Io - 2 * I) * Rsh - 2 * I * Rs - a * z + I * Rsh * z
      / (1 + z)
  }

  func calc_phi_exact(
    _ Imp: Double, _ IL: Double, _ Io: Double, _ a: Double, _ Rsh: Double
  ) -> Double {
    let argw = Rsh * Io / a * exp(Rsh * (IL + Io - Imp) / a)

    guard argw >= .zero else { return .nan }
    var tmp = lambertW(argw)

    if tmp.isNaN {
      let logargW = log(Rsh) + log(Io) - log(a) + Rsh * (IL + Io - Imp) / a
      var x = logargW
      let K = Int(log10(x))
      for _ in 0..<(3 * K) { x = x * ((1 - log(x)) + logargW) / (1 + x) }
      tmp = x
    }

    return tmp
  }
}

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
