//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
  
public struct PerformanceData: CustomStringConvertible {

  public var collector = Collector.initialState,
  solarField = SolarField.initialState,
  heatExchanger = HeatExchanger.initialState,
  powerBlock = PowerBlock.initialState,
  steamTurbine = SteamTurbine.initialState,
  heater = Heater.initialState,
  boiler = Boiler.initialState,
  gasTurbine = GasTurbine.initialState,
  storage = Storage.initialState
  
  public init() {}
  
  public var description: String {
    return "\nCollector:\n\(collector)\n\n"
      + (Design.hasSolarField ? "Solar Field:\n\(solarField)\n\n" : "")
      + "Heat Exchanger:\n\(heatExchanger)\n\n"
      + (Design.hasPowerBlock ? "Power Block:\n\(powerBlock)\n\n" : "")
      + "Steam Turbine:\n\(steamTurbine)\n\n"
      + (Design.hasHeater ? "Heater:\n\(heater)\n\n" : "")
      + (Design.hasBoiler ? "Boiler:\n\(boiler)\n\n" : "")
      + (Design.hasGasTurbine ? "Gas Turbine:\n\(gasTurbine)\n\n" : "")
      + (Design.hasStorage ? "Storage:\n\(storage)\n" : "")
  }
  
  var csv: String {
    let values = storage.values + heater.values + powerBlock.values
      + heatExchanger.values + solarField.values
      + solarField.loops[0].values + solarField.loops[1].values
      + solarField.loops[2].values + solarField.loops[3].values
    return values.joined(separator: .separator)
  }
  
  static var columns: [(String, String)] {
    let values: [(name: String, unit: String)] =
      [("|Massflow", "kg/s"), ("|Tin", "degC"), ("|Tout", "degC")]
    return [
      "Storage", "Heater", "PowerBlock", "HeatExchanger", "SolarField",
      "DesignLoop", "NearLoop", "AvgLoop", "FarLoop"].flatMap { name in
        values.map { value in (name + value.name, value.unit) } }
  }
}

