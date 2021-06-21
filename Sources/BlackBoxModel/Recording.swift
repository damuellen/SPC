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

  private let startDate: Date?

  init(
    startDate: Date? = nil,
    performance: PlantPerformance,
    radiation: SolarRadiation,
    performanceHistory: [PlantPerformance] = [],
    statusHistory: [Status] = []
  ) {
    self.startDate = startDate
    self.performance = performance
    self.radiation = radiation
    self.performanceHistory = performanceHistory
    self.statusHistory = statusHistory
  }

  private func range(of interval: DateInterval) -> Range<Int> {
    var start = calendar.ordinality(of: .hour, in: .year, for: interval.start)! - 1
    var end = calendar.ordinality(of: .hour, in: .year, for: interval.end)!
    var offset = 0
    if let startDate = startDate {
      offset = calendar.ordinality(of: .hour, in: .year, for: startDate)! - 1
    }
    start = (start - offset) * self.interval.rawValue
    end = (end - offset) * self.interval.rawValue
    return start..<end
  }

  subscript(
    performance keyPath: KeyPath<PlantPerformance, Double>, interval: DateInterval
  ) -> [Double] {
    if performanceHistory.isEmpty { return [] }
    let r = range(of: interval).clamped(to: performanceHistory.indices)
    return performanceHistory[r].map { $0[keyPath: keyPath] }
  }

  subscript(
    status keyPath: KeyPath<Status, Double>, interval: DateInterval
  ) -> [Double] {
    if statusHistory.isEmpty { return [] }
    let r = range(of: interval).clamped(to: statusHistory.indices)
    return statusHistory[r].map { $0[keyPath: keyPath] }
  }

  subscript(
    cycle keyPath: KeyPath<Status, Cycle>, interval: DateInterval
  ) -> [[Double]] {
    if statusHistory.isEmpty { return [] }
    let r = range(of: interval).clamped(to: statusHistory.indices)
    return statusHistory[r].map { $0[keyPath: keyPath].cycle.numericalForm }
  }

  public subscript(_ keyPaths: KeyPath<PlantPerformance, Double>...,
    range range: DateInterval
  ) -> [[Double]] {
    keyPaths.map { kp in self[performance: kp, range] }
  }

  public subscript(_ keyPaths: KeyPath<Status, Double>...,
    range range: DateInterval
  ) -> [[Double]] {
    keyPaths.map { kp in self[status: kp, range] }
  }

  private subscript(
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

  public func collector(range: DateInterval) -> [Double] {
    let pe: [Double] = self[status: \.collector.parabolicElevation, range]
    return pe
  }

  public func power(range: DateInterval) -> [[Double]] {
    let s = self[performance: \.thermal.solar.megaWatt, range]
    let p = self[performance: \.thermal.production.megaWatt, range]
    let t1 = self[performance: \.thermal.toStorage.megaWatt, range]
    let t2 = self[performance: \.thermal.storage.megaWatt, range]
    let g = self[performance: \.electric.steamTurbineGross, range]
    let n = self[performance: \.electric.net, range]
    let c = self[performance: \.electric.consum, range]

    return [s, p, t1, t2, g, n, c]
  }

  public func massFlows(range: DateInterval) -> [[Double]] {
    let s1 = self[status: \.solarField.massFlow.rate, range]
    let hx = self[status: \.heatExchanger.massFlow.rate, range]
    let s2 = self[status: \.storage.massFlow.rate, range]
    return [s1, hx, s2]
  }

  public subscript(_ keyPath: KeyPath<Status, Cycle>,
    range range: DateInterval
  ) -> ([[Double]], [[Double]]) {
    let (m, i, o) = self[cycle: keyPath, range].reduce(into: ([Double](), [Double](), [Double]())) {
      $0.0.append($1[0])
      $0.1.append($1[1])
      $0.2.append($1[2])
    }
    return ([m], [i, o])
  }
}
