//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation
import Meteo

public struct Recording: CustomStringConvertible, Comparable {

  let designParameter = ParameterSet()

  let performance: PlantPerformance

  let radiation: SolarRadiation

  let performanceHistory: [PlantPerformance]

  let statusHistory: [Status]

  public var layout: Layout { designParameter.layout }

  public var thermal: ThermalEnergy { performance.thermal }

  public var electric: ElectricPower { performance.electric }

  public var fitness: Double { layout.solarField / electric.net }

  public static func < (lhs: Recording, rhs: Recording) -> Bool {
    lhs.fitness < rhs.fitness
  }

  public static func == (lhs: Recording, rhs: Recording) -> Bool {
    lhs.fitness == rhs.fitness
  }

  public var description: String { report() }

  private let interval = Simulation.time.steps

  private let calendar = Calendar(identifier: .gregorian)
  
  init(
    performance: PlantPerformance,
    radiation: SolarRadiation,
    performanceHistory: [PlantPerformance] = [],
    statusHistory: [Status] = []
  ) {
    self.performance = performance
    self.radiation = radiation
    self.performanceHistory = performanceHistory
    self.statusHistory = statusHistory
  }

  private func range(of interval: DateInterval) -> Range<Int> {
    var start = calendar.ordinality(of: .hour, in: .year, for: interval.start)! - 1
    var end = calendar.ordinality(of: .hour, in: .year, for: interval.end)!
    start *= self.interval.rawValue
    end *= self.interval.rawValue
    return start..<end
  }

  public subscript(
    keyPath: KeyPath<PlantPerformance, Double>, interval: DateInterval
  ) -> [Double] {
    if performanceHistory.isEmpty { return [] }
    let r = range(of: interval).clamped(to: performanceHistory.indices)
    return performanceHistory[r].map { $0[keyPath: keyPath] }
  }

  public subscript(
    keyPath: KeyPath<Status, Double>, interval: DateInterval
  ) -> [Double] {
    if statusHistory.isEmpty { return [] }
    let r = range(of: interval).clamped(to: statusHistory.indices)
    return statusHistory[r].map { $0[keyPath: keyPath] }
  }

  public subscript(
    keyPath: KeyPath<Status, Cycle>, interval: DateInterval
  ) -> [[Double]] {
    if statusHistory.isEmpty { return [] }
    let r = range(of: interval).clamped(to: statusHistory.indices)
    return statusHistory[r].map { $0[keyPath: keyPath].cycle.numericalForm }
  }

  public subscript(_ keyPaths: KeyPath<PlantPerformance, Double>...,
    range range: DateInterval
  ) -> [[Double]] {
    keyPaths.map { kp in self[kp, range] }
  }

  public subscript(_ keyPaths: KeyPath<Status, Double>...,
    range range: DateInterval
  ) -> [[Double]] {
    keyPaths.map { kp in self[kp, range] }
  }

  subscript(
    keyPath: KeyPath<Status, HeatTransfer>, interval: DateInterval
  ) -> [[Double]] {
    if statusHistory.isEmpty { return [] } 
    let r = range(of: interval).clamped(to: statusHistory.indices)
    return statusHistory[r].map { $0[keyPath: keyPath].numericalForm }
  }

  public func solarFieldHeader(range: DateInterval) -> ([[Double]], [[Double]]) {
    let (m, i, o) = self[\.solarField.header, range].reduce(into: ([Double](), [Double](), [Double]())) {
      $0.0.append($1[0])
      $0.1.append($1[1])
      $0.2.append($1[2])
    }
    return ([m], [i, o])
  }

  public func power(range: DateInterval) -> ([[Double]], [[Double]]) {
    let s = self[\.thermal.solar.megaWatt, range]
    let t1 = self[\.thermal.toStorage.megaWatt, range]
    let t2 = self[\.thermal.storage.megaWatt, range]
    let p = self[\.thermal.production.megaWatt, range]

    let g = self[\.electric.steamTurbineGross, range]
    let n = self[\.electric.net, range]
    let c = self[\.electric.consum, range]

    return ([s, t1, t2, p], [g, n, c])
  }

  public subscript(_ keyPath: KeyPath<Status, Cycle>,
    range range: DateInterval
  ) -> ([[Double]], [[Double]]) {
    let (m, i, o) = self[keyPath, range].reduce(into: ([Double](), [Double](), [Double]())) {
      $0.0.append($1[0])
      $0.1.append($1[1])
      $0.2.append($1[2])
    }
    return ([m], [i, o])
  }  
}
