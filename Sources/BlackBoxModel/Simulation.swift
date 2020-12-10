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
import Meteo

public enum Simulation {
  static var isStart = true

  public static var initialValues = InitValues(
    temperatureOfHTFinPipes: Temperature(celsius: 100.0),
    temperatureOfHTFinHCE: Temperature(celsius: 50.0),
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

  public static var time = Time(
    isLeapYear: false,
    firstDateOfOperation: nil,
    lastDateOfOperation: nil,
    holidays: [],
    steps: .every5minutes
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
    let line: (Int) throws -> Double = { try file.parseDouble(line: $0) }
    self.temperatureOfHTFinPipes = try Temperature(celsius: line(7))
    self.temperatureOfHTFinHCE = try Temperature(celsius: line(10))
    self.massFlowInSolarField = try MassFlow(line(13))
  }
}
