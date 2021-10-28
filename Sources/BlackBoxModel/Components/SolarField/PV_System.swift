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
import Physics

/// The PV_System struct wraps the functions of the pv system components.
///
/// This simplifies the API by eliminating the need for a user to specify
/// arguments such as module and inverter properties.
public struct PV {
  public var array = Array()
  public var inverter = Inverter()
  public var transformer = Transformer()

  /// Net output of the pv system.
  ///
  /// - Parameter radiation: Effective solar irradiation
  /// - Parameter ambient: Temperature of the environment
  /// - Parameter windSpeed: Apparent speed of wind
  func callAsFunction(
    radiation effective: Double, ambient: Temperature, windSpeed: Double
  ) -> Double {
    guard effective > 15 else { return transformer(ac: .zero) }
    var dc = array(radiation: effective, ambient: ambient, windSpeed: 0.0)
    if dc.power > 0 {
      var efficiency = inverter(power: dc.power, voltage: dc.voltage)
      if efficiency.isNaN {
        let cell = array.panel.cell.temperature(
          radiation: effective, ambient: ambient, windSpeed: windSpeed,
          nominalPower: array.panel.nominalPower, panelArea: array.panel.area)
                dc = PowerPoint(
        current: dc.current,
        voltage: min(dc.voltage, inverter.voltageLevels[0] - 1e-6))
        let shift = Double(array.panelsPerString) * 1e-6
        var iterations = 0
        while efficiency.isNaN && iterations < 50000 {
          iterations += 1
          //print(dc)
          dc = array(
            voltage: dc.voltage + shift, radiation: effective, cell: cell)

          efficiency = inverter(power: dc.power, voltage: dc.voltage)
        }
        if efficiency.isNaN { efficiency = 0 }
      }

      let ratio = Ratio(percent: efficiency)
      let power = min(dc.power * ratio.quotient, inverter.maxPower)
      return transformer(ac: power)
    } else {
      return transformer(ac: .zero)
    }
  }

  /// Represents a group of modules with the same orientation and module type.
  public struct Array {
    /// Number of panels per string
    let panelsPerString: Int
    /// Number of strings
    let strings: Int
    /// Number of inverters
    let inverters: Int
    /// Panel type
    let panel: Panel

    let lossAtSTC: Double

    let degradation: Double = 0
    let unavailability: Double = 0
    /// Creates a pv array
    public init() {
      self.panelsPerString = 26
      self.strings = 295
      self.inverters = 1
      self.panel = Panel()
      self.lossAtSTC = 0.43e-3
    }
    /// Calculate the maximum power point of the array.
    func callAsFunction(
      radiation: Double, ambient: Temperature, windSpeed: Double
    ) -> PowerPoint {
      let mpp = panel(
        radiation: radiation, ambient: ambient, windSpeed: windSpeed)
      /// Panel losses due to degradation, unavailability and losses in the copper
      let voltageDrop = (mpp.voltage / mpp.current * lossAtSTC) * mpp.current
      let losses = (1 - degradation) * (1 - unavailability)
      return PowerPoint(
        current: mpp.current * losses * Double(strings) * Double(inverters),
        voltage: (mpp.voltage - voltageDrop) * Double(panelsPerString))
    }
    /// Find new point within the I-V curve using the single diode model.
    func callAsFunction(voltage: Double, radiation: Double, cell: Temperature)
      -> PowerPoint
    {
      let current = panel.currentFrom(
        voltage: voltage / Double(panelsPerString),
        radiation: radiation,
        cell_T: cell)

      return PowerPoint(
        current: current * Double(strings) * Double(inverters),
        voltage: voltage)
    }
  }

  /// Represents a transformer with its losses.
  public struct Transformer {
    let injectionLossFractionAtST: Double
    let resistiveLossAtSTC: Double
    let ironLoss: Double
    /// Creates a transformer
    public init() {
      self.injectionLossFractionAtST = 0.006
      self.resistiveLossAtSTC = 0.01
      self.ironLoss = 14.83E3
    }
    /// Calculates power losses in transformer.
    func callAsFunction(ac power: Double) -> Double {
      if power > .zero {
        return power
          * (1 - resistiveLossAtSTC)
          * (1 - injectionLossFractionAtST) - ironLoss
      } else {
        return -ironLoss
      }
    }
  }

  /// Convert DC power and voltage to AC power
  ///
  /// Performance is described at three DC input voltage levels
  public struct Inverter {
    public let voltageRange: ClosedRange<Double>
    public let maxPower: Double

    let dc_power: [Double]
    let voltageLevels: [Double]

    let maxVoltage: [Double]
    let nomVoltage: [Double]
    let minVoltage: [Double]

    public init() {
      self.voltageRange = 915...1200
      self.maxPower = 2550e3
      self.dc_power = [
        12e3, 132.302e3, 260.896e3, 518.503e3, 776.492e3, 1293.49e3, 1941.82e3,
        2591.46e3
      ]
      self.voltageLevels = [1200, 990, 915]

      self.maxVoltage = [80, 95.7, 97.35, 98.13, 98.33, 98.44, 98.38, 98.31]
      self.nomVoltage = [80, 96.37, 97.74, 98.36, 98.52, 98.57, 98.49, 98.4]
      self.minVoltage = [80, 96.82, 98.01, 98.53, 98.67, 98.7, 98.62, 98.54]
    }
    /// Determines the efficiency of an inverter given the DC power and DC voltage.
    public func callAsFunction(power: Double, voltage: Double) -> Double {
      func biInterpolate(
        _ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double, _ v11: Double,
        _ v12: Double, _ v21: Double, _ v22: Double, _ x: Double, _ y: Double
      ) -> Double {
        let fxy1 = (x2 - x) / (x2 - x1) * v11 + (x - x1) / (x2 - x1) * v21
        let fxy2 = (x2 - x) / (x2 - x1) * v12 + (x - x1) / (x2 - x1) * v22
        return (y2 - y) / (y2 - y1) * fxy1 + (y - y1) / (y2 - y1) * fxy2
      }

      guard let p1 = dc_power.lastIndex(where: { $0 <= power }), // lower bound
      let p2 = dc_power.firstIndex(where: { $0 >= power }) // upper bound
      else {  return .nan }
      guard let _ = voltageLevels.first(where: { $0 > voltage }), // Overvoltage
      let v2 = voltageLevels.first(where: { $0 < voltage }) // Undervoltage
      else { return .nan }

      let v1: Double
      let v11: [Double]
      let v21: [Double]

      if voltage > voltageLevels[1] {
        v1 = voltageLevels[0]
        v11 = maxVoltage
        v21 = nomVoltage
      } else {
        v1 = voltageLevels[1]
        v11 = nomVoltage
        v21 = minVoltage
      }

      let efficiency = biInterpolate(
        dc_power[p1], v1, dc_power[p2], v2,
        v11[p1], v21[p1], v11[p2], v21[p2],
        power, voltage
      )
      return efficiency
    }
  }
}
