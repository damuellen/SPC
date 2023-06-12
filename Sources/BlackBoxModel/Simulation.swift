//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Meteo
import Utilities

public enum Simulation {
  static var isStart = true

  static var startTemperature =
   (Simulation.initialValues.temperatureOfHTFinPipes,
    Simulation.initialValues.temperatureOfHTFinPipes)

  public static var initialValues = InitValues(
    temperatureOfHTFinPipes: Temperature(celsius: 300.0),
    temperatureOfHTFinHCE: Temperature(celsius: 250.0),
    massFlowInSolarField: 0.0
  )

  static var tariff = Tariff(
    name: "",
    abbreviation: "",
    energyPayment: 1.0,
    energieCost: 1.0,
    capacityPaymentPercent: 1.0,
    capacityPayment: 1.0,
    bonusPaymentPercent: 1.0,
    bonusPayment: 1.0,
    asAvailableCapacity: 1.0
  )

  public static var time = Period(
    isLeapYear: false,
    dateInterval: nil,
    holidays: [],
    steps: .fiveMinutes
  )

  public static var parameter = Simulation.Parameter(
    dfreezeTemperaturePump: 151.0,
    dfreezeTemperatureHeat: 40.0,
    minTemperatureRaiseStartUp: 1.0,
    tempTolerance: 1.0,
    minInsolationRaiseStartUp: 1.0,
    heatTolerance: 4,
    timeTolerance: 1.0,
    massTolerance: 0.5,
    minInsolation: 150,
    maxToPowerBlock: 0,
    minInsolationForBoiler: 0,
    electricalTolerance: 0.5,
    electricalParasitics: 8.5 / 100,
    HLtempTolerance: 0.5,
    adjustmentFactor: adjustmentFactor
  )

  public static var adjustmentFactor = Simulation.AdjustmentFactors(
    efficiencySolarField: 1.0,
    efficiencyTurbine: 1.0,
    efficiencyHeater: 1.0,
    efficiencyBoiler: 1.0,
    heatLossHCE: 1.0, heatLossHTF: 1.0, heatLossH2O: 1.0,
    electricalParasitics: 1.0
  )
}

public struct InitValues: Codable {
  let temperatureOfHTFinPipes,
    temperatureOfHTFinHCE: Temperature
  let massFlowInSolarField: MassFlow
   
}

extension InitValues {
  public init(file: TextConfigFile) throws {
    let ln: (Int) throws -> Double = { try file.readDouble(lineNumber: $0) }
    self.temperatureOfHTFinPipes = try Temperature(celsius: ln(7))
    self.temperatureOfHTFinHCE = try Temperature(celsius: ln(10))
    self.massFlowInSolarField = try MassFlow(ln(13))
  }
}

extension InitValues: CustomStringConvertible {
  public var description: String {
    "HTF Temperature in Header [°C]:"
    * String(format: "%.1f", temperatureOfHTFinPipes.celsius)
    + "HTF Temperature in Collector [°C]:"
    * String(format: "%.1f", temperatureOfHTFinHCE.celsius)
    + "Mass Flow in Solar Field [kg/s]:"
    * String(format: "%.1f", massFlowInSolarField.rate)
  }
}