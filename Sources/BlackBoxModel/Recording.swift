// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import Foundation
import Meteo
import DateExtensions

/// Represents the recording of solar power plant performance data.
public struct Recording: CustomStringConvertible, Comparable {
  /// The design parameter used for the recording.
  let designParameter = Parameters()

  /// The overall performance of the solar power plant.
  public let performance: PlantPerformance

  /// The irradiance data for the recording.
  public let irradiance: Insolation

  /// The history of plant performance data.
  public let performanceHistory: [PlantPerformance]

  /// The history of status data.
  public let statusHistory: [Status]

  /// The solar field layout defined by the design parameters.
  var layout: Layout { designParameter.layout }

  /// The thermal energy data from the plant performance.
  var thermal: ThermalEnergy { performance.thermal }

  /// The electric power data from the plant performance.
  var electric: ElectricPower { performance.electric }

  /// The fitness value, representing the efficiency of the solar field layout.
  public var fitness: Double { layout.solarField / electric.net }

  /// Compare two `Recording` instances based on their fitness values.
  public static func < (lhs: Recording, rhs: Recording) -> Bool {
    lhs.fitness < rhs.fitness
  }

  /// Check if two `Recording` instances are equal based on their fitness values.
  public static func == (lhs: Recording, rhs: Recording) -> Bool {
    lhs.fitness == rhs.fitness
  }

  public var maxMassFlow: Double { designParameter.solarField.maxMassFlow.rate }

  public var maxHeatFlow: Double { designParameter.heatExchanger.heatFlowHTF / designParameter.storage.massFlowShare.quotient }

  /// A textual representation of the `Recording`.
  public var description: String { report() }

  /// The time interval for each recording step.
  public let interval = Simulation.time.steps

  /// The start date of the recording.
  let startDate: Date

  /// Print the annual results for the recording.
  /// - Parameter verbose: If true, print the design parameters.
  public func print(verbose: Bool) {
    // Print an empty line for spacing.
    Swift.print("")
    // Print a decorated header for the annual results.
    Swift.print(decorated("Annual results"))
    // Print the irradiance data.
    Swift.print(irradiance.prettyDescription)
    // Print the overall performance data.
    Swift.print(performance.prettyDescription)
    // If verbose mode is enabled, print the design parameters.
    if verbose { Swift.print(designParameter) }
  }

  /// Initialize the `Recording` instance with given parameters.
  /// - Parameters:
  ///   - startDate: The start date of the recording.
  ///   - irradiance: The irradiance data for the recording.
  ///   - performanceHistory: The history of plant performance data.
  ///   - statusHistory: The history of status data.
  init(
    startDate: Date,
    irradiance: Insolation,
    performanceHistory: [PlantPerformance] = [],
    statusHistory: [Status] = []
  ) {
    self.startDate = startDate
    // Calculate the annual performance based on the performance history and interval fraction.
    var annualPerformance = PlantPerformance()
    annualPerformance(performanceHistory, fraction: interval.fraction)
    self.performance = annualPerformance
    self.irradiance = irradiance
    self.performanceHistory = performanceHistory
    self.statusHistory = statusHistory
  }

  /// Calculate the index range for a given date interval.
  private func range(of interval: DateInterval) -> Range<Int> {
    var start = Greenwich.ordinality(of: .hour, in: .year, for: interval.start) - 1
    var end = Greenwich.ordinality(of: .hour, in: .year, for: interval.end)
    let offset = Greenwich.ordinality(of: .hour, in: .year, for: startDate) - 1
    start = (start - offset) * self.interval.rawValue
    end = (end - offset) * self.interval.rawValue
    return start..<end
  }

  /// Access the performance data within a given date interval using a keypath.
  /// - Parameters:
  ///   - performance: The keypath to access performance data.
  ///   - interval: The date interval for data extraction.
  /// - Returns: An array of `Double` values representing the extracted data.
  subscript(
    performance keyPath: KeyPath<PlantPerformance, Double>, interval: DateInterval
  ) -> [Double] {
    // If the performance history is empty, return an empty array.
    if performanceHistory.isEmpty { return [] }
    // Calculate the index range for the date interval and clamp it to the performance history indices.
    let r = range(of: interval).clamped(to: performanceHistory.indices)
    // Extract the specified keypath data for the given interval and return it as an array.
    return performanceHistory[r].map { $0[keyPath: keyPath] }
  }

  /// Access the status data within a given date interval using a keypath.
  /// - Parameters:
  ///   - status: The keypath to access status data.
  ///   - interval: The date interval for data extraction.
  /// - Returns: An array of `Double` values representing the extracted data.
  subscript(
    status keyPath: KeyPath<Status, Double>, interval: DateInterval
  ) -> [Double] {
    // If the status history is empty, return an empty array.
    if statusHistory.isEmpty { return [] }
    // Calculate the index range for the date interval and clamp it to the status history indices.
    let r = range(of: interval).clamped(to: statusHistory.indices)
    // Extract the specified keypath data for the given interval and return it as an array.
    return statusHistory[r].map { $0[keyPath: keyPath] }
  }

  /// Access the cycle data within a given date interval using a keypath.
  subscript(
    cycle keyPath: KeyPath<Status, HeatTransferCycle>, interval: DateInterval
  ) -> [[Double]] {
    // If the status history is empty, return an empty array.
    if statusHistory.isEmpty { return [] }
    // Calculate the index range for the date interval and clamp it to the status history indices.
    let r = range(of: interval).clamped(to: statusHistory.indices)
    // Extract the cycle values for the specified keypath data and return them as an array of arrays.
    return statusHistory[r].map { $0[keyPath: keyPath].cycle.values }
  }

  /// Access multiple performance data keypaths within a given date interval.
  subscript(_ keyPaths: KeyPath<PlantPerformance, Double>...,
    range range: DateInterval
  ) -> [[Double]] {
    // Map each keypath to the corresponding performance data array using the subscript function.
    keyPaths.map { kp in self[performance: kp, range] }
  }

  /// Access multiple status data keypaths within a given date interval.
  subscript(_ keyPaths: KeyPath<Status, Double>...,
    range range: DateInterval
  ) -> [[Double]] {
    // Map each keypath to the corresponding status data array using the subscript function.
    keyPaths.map { kp in self[status: kp, range] }
  }

  /// Access the heat transfer data within a given date interval using a keypath.
  private subscript(
    keyPath: KeyPath<Status, ThermalProcess>, interval: DateInterval
  ) -> [[Double]] {
    // If the status history is empty, return an empty array.
    if statusHistory.isEmpty { return [] }
    // Calculate the index range for the date interval and clamp it to the status history indices.
    let r = range(of: interval).clamped(to: statusHistory.indices)
    // Extract the heat transfer values for the specified keypath data and return them as an array of arrays.
    return statusHistory[r].map { $0[keyPath: keyPath].values }
  }

  /// Access the solar field header data within a given date interval.
  public func solarFieldHeader(range: DateInterval) -> ([[Double]], [[Double]]) {
    // Reduce the solar field header data to separate arrays for mass, inlet, and outlet values.
    let (m, i, o) = self[\.solarField.header, range].reduce(into: ([Double](), [Double](), [Double]())) {
      $0.0.append($1[0])
      $0.1.append($1[1])
      $0.2.append($1[2])
    }
    return ([m], [i, o])
  }

  /// Access the collector data within a given date interval.
  public func collector(range: DateInterval) -> [Double] {
    // Get the parabolic elevation data for the collector within the specified date interval.
    let pe: [Double] = self[status: \.collector.parabolicElevation, range]
    return pe
  }

  /// Access the power-related data within a given date interval.
  public func power(range: DateInterval) -> [[Double]] {
    // Extract various power-related data for the specified date interval.
    let s = self[performance: \.thermal.solar.megaWatt, range]
    let p = self[performance: \.thermal.production.megaWatt, range]
    let t1 = self[performance: \.thermal.toStorage.megaWatt, range]
    let t2 = zip(self[performance: \.thermal.storage.megaWatt, range], t1).map(-)
    let g = self[performance: \.electric.steamTurbineGross, range]
    let n = self[performance: \.electric.net, range]
    let c = self[performance: \.electric.consum, range]

    // Return the power-related data as an array of arrays.
    return [s, p, t1, t2, g, n, c]
  }

  /// Access the mass flow data within a given date interval.
  public func massFlows(range: DateInterval) -> [[Double]] {
    // Extract various mass flow data for the specified date interval.
    let s1 = self[status: \.solarField.massFlow.rate, range]
    let hx = self[status: \.heatExchanger.massFlow.rate, range]
    let s2 = self[status: \.storage.massFlow.rate, range]

    // Return the mass flow data as an array of arrays.
    return [s1, hx, s2]
  }

  /// Access the cycle data within a given date interval using a keypath.
  subscript(_ keyPath: KeyPath<Status, HeatTransferCycle>,
    range range: DateInterval
  ) -> ([[Double]], [[Double]]) {
    // Reduce the cycle data to separate arrays for mass, inlet, and outlet values.
    let (m, i, o) = self[cycle: keyPath, range].reduce(into: ([Double](), [Double](), [Double]())) {
      $0.0.append($1[0])
      $0.1.append($1[1])
      $0.2.append($1[2])
    }
    return ([m], [i, o])
  }

  /// Calculate the annual data for a specific status keypath.
  public func annual(_ keyPath: KeyPath<Status, Double>) -> [[[Double]]] {
    // Extract the year from the start date.
    let dt = DateTime(startDate)
    // Define the day numbers before each month.
    let daysBeforeMonth = [31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334]
    var month = 0
    var months = [[[Double]]](repeating: [[Double]](), count: 12)
    for d in 1...(dt.isLeapYear ? 366 : 365) {
      // Create a date interval for each day within the year.
      let range = DateInterval(ofDay: d, in: dt.year)
      // Extract the data for the specified status keypath within the date interval.
      let day = self[status: keyPath, range]
      // Append the data to the corresponding month in the result array.
      months[month].append(day)
      // Check if a new month is starting and update the month index.
      if daysBeforeMonth.contains(d) {
        month += 1
      }
    }
    return months
  }

  /// Calculate the annual data for a specific plant performance keypath.
  public func annual(_ keyPath: KeyPath<PlantPerformance, Double>) -> [[[Double]]] {
    // Extract the year from the start date.
    let dt = DateTime(startDate)
    // Define the day numbers before each month.
    let daysBeforeMonth = [31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334]
    var month = 0
    
    var months = [[[Double]]](repeating: [[Double]](), count: 12)
    for d in 1...(dt.isLeapYear ? 366 : 365) {
      // Create a date interval for each day within the year.
      let range = DateInterval(ofDay: d, in: dt.year)
      // Extract the data for the specified plant performance keypath within the date interval.
      let day = self[performance: keyPath, range]
      // Append the data to the corresponding month in the result array.
      months[month].append(day)
      // Check if a new month is starting and update the month index.
      if daysBeforeMonth.contains(d) {
        month += 1
      }
    }
    return months
  }
}
