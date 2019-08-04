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

public struct PerformanceLog: CustomStringConvertible, Comparable {

  public let report: String
  
  let energy: Energy
  
  let radiation: SolarRadiation
  
  let energyHistory: [Energy]
  
  let performanceHistory: [Plant.PerformanceData]
  
  public let layout: Layout
  
  public var thermal: ThermalEnergy {
    return energy.thermal
  }
  
  public var electric: ElectricPower {
    return energy.electric
  }
  
  public var fitness: Double {
    return layout.solarField / electric.net
  }
  
  public static func < (lhs: PerformanceLog, rhs: PerformanceLog) -> Bool {
    return lhs.fitness < rhs.fitness
  }
  
  public static func ==(lhs: PerformanceLog, rhs: PerformanceLog) -> Bool {
    return lhs.fitness == rhs.fitness
  }
    
  private let interval = Simulation.time.steps
  
  init(energy: Energy,
       radiation: SolarRadiation,
       energyHistory: [Energy] = [],
       performanceHistory: [Plant.PerformanceData] = [])
  {
    self.energy = energy
    self.radiation = radiation
    self.energyHistory = energyHistory
    self.performanceHistory = performanceHistory
    self.layout = Design.layout
    self.report = PerformanceLog.makeReport(energy: energy, radiation: radiation)
  }
  
  public subscript(
    keyPath: KeyPath<Energy, Double>, ofDay day: Int) -> [Double]
  {
    if energyHistory.isEmpty { return [] }
    let count = interval.rawValue * 24
    let rangeStart = (day - 1) * count
    let rangeEnd = day * count
    return energyHistory[rangeStart..<rangeEnd].map { $0[keyPath: keyPath] }
  }
  
  public subscript(
    keyPath: KeyPath<Plant.PerformanceData, Double>, ofDay day: Int) -> [Double]
  {
    if performanceHistory.isEmpty { return [] }
    let count = interval.rawValue * 24
    let rangeStart = (day - 1) * count
    let rangeEnd = day * count
    return performanceHistory[rangeStart..<rangeEnd].map { $0[keyPath: keyPath] }
  }
  
  public var description: String {
    return layout.description + radiation.description
      + energy.thermal.description + energy.parasitics.description
      + energy.electric.description + energy.fuel.description
  }
}
