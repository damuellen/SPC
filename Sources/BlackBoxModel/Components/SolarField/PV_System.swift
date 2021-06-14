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
      return transformer(ac: acPower)  //point.Power * performance / 100D - (this.Auxiliares * inverters);
    } else {
      return transformer(ac: .zero)  //-inverter.NightConsumption
    }
  }
}
