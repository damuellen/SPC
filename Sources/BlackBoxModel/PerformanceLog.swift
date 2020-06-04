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
import Foundation

public struct PerformanceLog: CustomStringConvertible, Comparable {

  public let report: String
  
  let energyTotal: Energy
  
  let radiation: SolarRadiation
  
  let energyHistory: [Energy]
  
  let performanceHistory: [PerformanceData]
  
  public let layout: Layout
  
  public var thermal: ThermalEnergy { energyTotal.thermal }
  
  public var electric: ElectricPower { energyTotal.electric }
  
  public var fitness: Double { return layout.solarField / electric.net }
  
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
       performanceHistory: [PerformanceData] = [])
  {
    self.energyTotal = energy
    self.radiation = radiation
    self.energyHistory = energyHistory
    self.performanceHistory = performanceHistory
    self.layout = Design.layout
    self.report = PerformanceReport.create(energy: energy, radiation: radiation)
  }
  
  public subscript(
    keyPath: KeyPath<Energy, Double>, ofDay day: Int) -> [Double]
  {
    if energyHistory.isEmpty { return [] }
    let count = interval.rawValue * 24
    let start = (day - 1) * count
    let end = day * count
    return energyHistory[start..<end].map { $0[keyPath: keyPath] }
  }
  
  public subscript(
    keyPath: KeyPath<PerformanceData, Double>, ofDay day: Int) -> [Double]
  {
    if performanceHistory.isEmpty { return [] }
    let count = interval.rawValue * 24
    let start = (day - 1) * count
    let end = day * count
    return performanceHistory[start..<end].map { $0[keyPath: keyPath] }
  }
  
  public var description: String {
    return report
  }
}
