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

public struct PerformanceLog: Comparable {
  
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
  }
  
  private func range(of interval: DateInterval) -> Range<Int> {
    var start = calendar.ordinality(of: .hour, in: .year, for: interval.start)! - 1
    var end = calendar.ordinality(of: .hour, in: .year, for: interval.end)! - 1
    start *= self.interval.rawValue
    end *= self.interval.rawValue
    return start..<end
  }
  
  public subscript(
    keyPath: KeyPath<Energy, Double>, interval: DateInterval) -> [Double]
  {
    if energyHistory.isEmpty { return [] }
    let r = range(of: interval).clamped(to: energyHistory.indices)
    return energyHistory[r].map { $0[keyPath: keyPath] }
  }
  
  public subscript(
    keyPath: KeyPath<PerformanceData, Double>, interval: DateInterval) -> [Double]
  {
    if performanceHistory.isEmpty { return [] }
    let r = range(of: interval).clamped(to: performanceHistory.indices)
    return performanceHistory[r].map { $0[keyPath: keyPath] }
  }
}
