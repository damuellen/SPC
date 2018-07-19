//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Config

protocol ComponentParameter {}

protocol Component {
  associatedtype Parameter: ComponentParameter
  // associatedtype Data: WorkingConditions
  static var parameter: Parameter { get set }
  // static var status: Data { get }
  static func update(parameter: Parameter)
}

extension Component {
  static func update(parameter: Parameter) {
    self.parameter = parameter
  }
}

var solarField = SolarField.parameter
var heater = Heater.parameter
var heatExchanger = HeatExchanger.parameter
var boiler = Boiler.parameter
var gasTurbine = GasTurbine.parameter
var steamTurbine = SteamTurbine.parameter
var powerBlock = PowerBlock.parameter
var storage = Storage.parameter
var collector = Collector.parameter
