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

/// The PV_System struct wraps the functions of the pv system components.
///
/// This simplifies the API by eliminating the need for a user to specify
/// arguments such as module and inverter properties.
public struct PV {
  public var array = Array()
  public var inverter = Inverter()
  public var transformer = Transformer()

  /// Net output of the pv system
  ///
  /// - Parameter radiation: Effective solar irradiation
  /// - Parameter ambient: Temperature of the environment
  /// - Parameter windSpeed: Apparent speed of wind
  func callAsFunction(radiation effective: Double, ambient: Temperature, windSpeed: Double)
    -> Double
  {
    guard effective > 10 else { return transformer(ac: .zero) }
    var dc = array(radiation: effective, ambient: ambient, windSpeed: 0.0)
    if dc.power > 0 {
      var efficiency = inverter(power: dc.power, voltage: dc.voltage)
      let cell = array.panel.cell.temperature(
        radiation: effective, ambient: ambient, windSpeed: windSpeed,
        nominalPower: array.panel.nominalPower, panelArea: array.panel.area)

      while efficiency.isNaN {
        dc = array(voltage: dc.voltage * 0.98, radiation: effective, cell: cell)
        efficiency = inverter(power: dc.power, voltage: dc.voltage)
      }
      let acPower = dc.power * efficiency
      return transformer(ac: acPower)
    } else {
      return transformer(ac: .zero)
    }
  }

  /// Represents a group of modules with the same orientation and module type.
  public struct Array {
    let panelsPerString: Int
    let strings: Int
    let inverters: Int
    let panel: Panel

    public init() {
      self.panelsPerString = 27
      self.strings = 295
      self.inverters = 1
      self.panel = Panel()
    }

    func callAsFunction(radiation: Double, ambient: Temperature, windSpeed: Double) -> PowerPoint {
      let pmp = panel.power(radiation: radiation, ambient: ambient, windSpeed: windSpeed)
      return PowerPoint(
        current: pmp.current * Double(strings) * Double(inverters),
        voltage: pmp.voltage * Double(panelsPerString)
      )
    }

    func callAsFunction(voltage: Double, radiation: Double, cell: Temperature) -> PowerPoint
    {
      let current = panel.current(
        voltage: voltage, radiation: radiation, temperature: cell
      )
      return PowerPoint(current: abs(current), voltage: voltage)
    }
  }

  /// Represents a transformer with its losses.
  public struct Transformer {
    let injectionLossFractionAtST: Double
    let resistiveLossAtSTC: Double
    let ironLoss: Double

    public init() {
      self.injectionLossFractionAtST = 0.006
      self.resistiveLossAtSTC = 0.01
      self.ironLoss = 14.83E3
    }

    func callAsFunction(ac power: Double) -> Double {
      if power > .zero {
        return power * (1 - resistiveLossAtSTC) * (1 - injectionLossFractionAtST)
          - ironLoss
      } else {
        return -ironLoss
      }
    }
  }

  /// Convert DC power and voltage to AC power
  ///
  /// Performance is described at three DC input voltage levels
  public struct Inverter {
    let dc_power: [Double]
    let voltageLevels: [Double]

    let maxVoltage: [Double]
    let nomVoltage: [Double]
    let minVoltage: [Double]

    public init() {
      self.dc_power = [12e3, 132.302e3, 260.896e3, 518.503e3, 776.492e3, 1293.49e3, 1941.82e3,2591.46e3]
      self.voltageLevels = [1200, 990, 915]

      self.maxVoltage = [80, 95.7, 97.35, 98.13, 98.33, 98.44, 98.38, 98.31]
      self.nomVoltage = [80, 96.37, 97.74, 98.36, 98.52, 98.57, 98.49, 98.4]
      self.minVoltage = [80, 96.82, 98.01, 98.53, 98.67, 98.7, 98.62, 98.54]
    }
    /// Determines the efficiency of an inverter given the DC power and DC voltage.
    func callAsFunction(power: Double, voltage: Double) -> Double {
      func biInterpolate(
        _ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double, _ v11: Double,
        _ v12: Double, _ v21: Double, _ v22: Double, _ x: Double, _ y: Double
      ) -> Double {
        let fxy1 = (x2 - x) / (x2 - x1) * v11 + (x - x1) / (x2 - x1) * v21
        let fxy2 = (x2 - x) / (x2 - x1) * v12 + (x - x1) / (x2 - x1) * v22
        return (y2 - y) / (y2 - y1) * fxy1 + (y - y1) / (y2 - y1) * fxy2
      }
      guard let p1 = dc_power.lastIndex(where: { $0 < power }),
        let p2 = dc_power.firstIndex(where: { $0 > power }),
        let v = voltageLevels.firstIndex(where: { voltage < $0 })
      else { return .nan }

      let v1: [Double]
      let v2: [Double]

      if v == 0 {
        v1 = maxVoltage
        v2 = nomVoltage
      } else {
        v1 = nomVoltage
        v2 = minVoltage
      }

      let efficiency = biInterpolate(
        dc_power[p1], voltageLevels[v], dc_power[p2], voltageLevels[v + 1],
        v1[p1], v1[p2], v2[p1], v2[p2], power, voltage
      )
      return efficiency
    }
  }
}
