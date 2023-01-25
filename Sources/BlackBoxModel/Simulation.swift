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
    energyPayment: 1,
    energieCost: 1,
    capacityPaymentPercent: 1,
    capacityPayment: 1,
    bonusPaymentPercent: 1,
    bonusPayment: 1,
    asAvailableCapacity: 1
  )

  public static var time = Year(
    isLeapYear: false,
    firstDateOfOperation: nil,
    lastDateOfOperation: nil,
    holidays: [],
    steps: .fiveMinutes
  )

  public static var parameter = Simulation.Parameter(
    dfreezeTemperaturePump: 151.0,
    dfreezeTemperatureHeat: 40.0,
    minTemperatureRaiseStartUp: 1.0,
    tempTolerance: 1.0,
    minInsolationRaiseStartUp: 1,
    heatTolerance: 4,
    timeTolerance: 1,
    massTolerance: 0.5,
    minInsolation: 200,
    maxToPowerBlock: 0,
    minInsolationForBoiler: 0,
    electricalTolerance: 0.5,
    electricalParasitics: 8.5 / 100,
    HLtempTolerance: 0.2,
    adjustmentFactor: adjustmentFactor
  )

  public static var adjustmentFactor = Simulation.AdjustmentFactors(
    efficiencySolarField: 1, efficiencyTurbine: 1,
    efficiencyHeater: 1, efficiencyBoiler: 1,
    heatLossHCE: 1, heatLossHTF: 1, heatLossH2O: 1,
    electricalParasitics: 1
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
    * temperatureOfHTFinPipes.celsius.description
    + "HTF Temperature in Collector [°C]:"
    * temperatureOfHTFinHCE.celsius.description
    + "Mass Flow in Solar Field [kg/s]:"
    * massFlowInSolarField.rate.description
  }
}