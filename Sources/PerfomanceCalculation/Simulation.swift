//
//  Copyright (c) 2017 Daniel Müllenborn. All rights reserved.
//  Distributed under the The Non-Profit Open Software License version 3.0
//  http://opensource.org/licenses/NPOSL-3.0
//
//  This project is NOT free software. It is open source, you are allowed to
//  modify it (if you keep the license), but it may not be commercially
//  distributed other than under the conditions noted above.
//

import Foundation
import Meteo
import Config

let adjustmentFactor = Simulation.AdjustmentFactor(
  efficiencySolarField: 1, efficiencyTurbine: 1,
  efficiencyHeater: 1, efficiencyBoiler: 1,
  heatLossHCE: 1, heatLossHTF: 1, heatLossH2O: 1,
  electricalParasitics: 1)

public enum Simulation {
  
  static var initialValues = InitValues(
    temperatureOfHTFinPipes: 100.0.toKelvin,
    temperatureOfHTFinHCE: 50.0.toKelvin,
    massFlowInSolarField: 0)
  
  static var tariff = Tariff(
    name: "",
    abbreviation: "",
    energyPayment: 1,
    energieCost: 1,
    capacityPaymentPercent: 1,
    capacityPayment: 1,
    bonusPaymentPercent: 1,
    bonusPayment: 1,
    asAvailableCapacity: 1)
  
  static var time = Time(
    isLeapYear: false,
    firstDateOfOperation: nil,
    lastDateOfOperation: nil,
    holidays: [],
    steps: .every5minutes)
  
  static var parameter = Simulation.Parameter(
    dfreezeTemperaturePump: 151.0,
    dfreezeTemperatureHeat: 40.0,
    minTemperatureRaiseStartUp: 0.0,
    tempTolerance: 1.0,
    minInsolationRaiseStartUp: 0,
    heatTolerance: 4,
    timeTolerance: 1,
    massTolerance: 0.5,
    minInsolation: 250,
    maxToPowerBlock: 0,
    minInsolationForBoiler: 0,
    electricalTolerance: 0.5,
    electricalParasitics: 8.5 / 100,
    HLtempTolerance: 0.1,
    adjustmentFactor: adjustmentFactor)
}

public struct InitValues: Codable {
  let temperatureOfHTFinPipes,
  temperatureOfHTFinHCE,
  massFlowInSolarField: Double
}

public extension InitValues {
  public init(file: TextConfigFile)throws {
    let row: (Int)throws -> Double = { try file.parseDouble(row: $0) }
    self.temperatureOfHTFinPipes = try row(6)
    self.temperatureOfHTFinHCE = try row(9)
    self.massFlowInSolarField = try row(12)
  }
}

