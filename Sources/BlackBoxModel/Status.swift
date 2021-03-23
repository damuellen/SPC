//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

public struct Status: CustomStringConvertible, MeasurementsConvertible {

  internal(set) public var collector = Collector.initialState
  internal(set) public var solarField = SolarField.initialState
  internal(set) public var heatExchanger = HeatExchanger.initialState
  internal(set) public var powerBlock = PowerBlock.initialState
  internal(set) public var steamTurbine = SteamTurbine.initialState
  internal(set) public var heater = Heater.initialState
  internal(set) public var boiler = Boiler.initialState
  internal(set) public var gasTurbine = GasTurbine.initialState
  internal(set) public var storage = Storage.initialState

  public var description: String {
    "\nCollector:\n\(collector)\n\n"
      + (Design.hasSolarField ? "Solar Field:\n\(solarField)\n\n" : "")
      + "Heat Exchanger:\n\(heatExchanger)\n\n"
      + "Power Block:\n\(powerBlock)\n\n"
      + "Steam Turbine:\n\(steamTurbine)\n\n"
      + (Design.hasHeater ? "Heater:\n\(heater)\n\n" : "")
      + (Design.hasBoiler ? "Boiler:\n\(boiler)\n\n" : "")
      + (Design.hasGasTurbine ? "Gas Turbine:\n\(gasTurbine)\n\n" : "")
      + (Design.hasStorage ? "Storage:\n\(storage)\n" : "")
  }

  static var modes: [String] {
    ["SolarField", "Storage", "Heater"]
  }

  var modes: [String] {
    [
      solarField.operationMode.description,
      storage.operationMode.description,
      heater.operationMode.rawValue
    ]
  }

  var numericalForm: [Double] {
    let values = collector.numericalForm //+ storage.salt.numericalForm
     + (storage as MeasurementsConvertible).numericalForm
     + (solarField as MeasurementsConvertible).numericalForm
    let flows = (storage as HeatTransfer).numericalForm
     + heater.numericalForm
     + powerBlock.cycle.numericalForm 
     + heatExchanger.numericalForm
     + solarField.header.numericalForm 
    let loops = solarField.loops.flatMap(\.numericalForm)
    return values + flows + loops
  }

  static var columns: [(name: String, unit: String)] {
    let values: [(name: String, unit: String)] =
      [("|Massflow", "kg/s"), ("|Tin", "degC"), ("|Tout", "degC")]
    return Collector.columns //+ Storage.Salt.columns 
      + Storage.columns + SolarField.columns + [
      "Storage", "Heater", "PowerBlock", "HeatExchanger", "SolarField",
      "DesignLoop", "NearLoop", "AvgLoop", "FarLoop",
    ].flatMap { name in
      values.map { value in (name + value.name, value.unit) }
    }
  }
}
