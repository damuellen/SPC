//
//  SolarField.swift
//  SolarField
//
//  Created by Daniel Muellenborn on 23/03/2015.
//  Copyright © 2015 Daniel Muellenborn. All rights reserved.
//

public final class SolarField {

  public static let shared = SolarField()
  public let powerBlock = PowerBlock()
  public let expansionVolume = ExpansionVolume()

  public var designTemperature = (inlet: 297.0, outlet: 393.0)
  public var ambientTemperature = 20.0
  public var fluid = Fluid.terminol

  public var connectors: [Connector] = []
  public var subfields: [SubField] = []

  public var loop: CollectorLoop { subfields.first!.loopExemplar }

  static var isValid: Bool {
    !SolarField.shared.connectors.isEmpty
      && !SolarField.shared.subfields.isEmpty
      && SolarField.shared.massFlowPerLoop > 0
  }

  public static var designMassFlow: Double {
    get { SolarField.shared.massFlow }
    set { SolarField.shared.massFlow = newValue }
  }

  var massFlow: Double = 0.0 {
    didSet { recalculation() }
  }

  public var designStreamVelocity: Double = 3.5 {
    didSet { recalculation() }
  }

  public var rowDistance: Double = 18.0 {
    didSet { recalculation() }
  }

  public func recalculation() {
    connectors.forEach { $0.recalculation() }
    subfields.forEach { $0.recalculation() }
    powerBlock.recalculation()
  }

  public func scaleMassFlow(percentage: Double) {
    connectors.forEach { $0.scaleMassFlow(percentage: percentage) }
    subfields.forEach { $0.scaleMassFlow(percentage: percentage) }
    powerBlock.scaleMassFlow(percentage: percentage)
  }

  public var totalResidenceTime: Double {
    var totalTime = 0.0
    var connector = connectors.sorted { $0.massFlow > $1.massFlow }.first
    totalTime += connector?.totalResidenceTime ?? 0
    while let continued = connector?.successor {
      totalTime += continued.totalResidenceTime
      connector = continued
    }
    var field = connector?.connections.sorted { $0.massFlow > $1.massFlow }.first
    totalTime += field?.totalResidenceTime ?? 0
    while let successor = field?.successor {
      totalTime += successor.totalResidenceTime
      field = successor
    }
    return totalTime
  }

  var totalPressureDrop: Double {
    let loopMax = subfields.map { $0.loopExemplar.totalPressureDrop }.max() ?? 0
    return loopMax + powerBlock.totalPressureDrop
  }

  var totalHeadLoss: Double {
    let loopMax = subfields.map { $0.loopExemplar.totalHeadLoss }.max() ?? 0
    return loopMax + powerBlock.totalHeadLoss
  }

  var totalHeatLosses: Double {
    var result = connectors.total(\.heatLoss)
    result += subfields.total(\.heatLoss)
    result += powerBlock.heatLoss
    return result / 1000.0
  }

  var volume: Double {
    var result = connectors.total(\.volume)
    result += subfields.total(\.volume)
    result += powerBlock.volume
    result += volumeLoops
    return result
  }

  var volumeColdHeaders: Double {
    var result = connectors.total(\.volumeCold)
    result += subfields.total(\.volumeCold)
    return result
  }

  var volumeHotHeaders: Double {
    var result = connectors.total(\.volumeHot)
    result += subfields.total(\.volumeHot)
    return result
  }

  var volumeLoops: Double { subfields.total(\.volumeLoops) }

  var numberOfLoops: Int { subfields.sum(\.totalLoops) }

  var massFlowPerLoop: Double {
    return self.numberOfLoops != 0
      ? (self.massFlow / Double(self.numberOfLoops))
      : 0
  }

  static var branches: [Branch] {
    var result = SolarField.shared.powerBlock.branches
    result += SolarField.shared.connectors.flatMap { $0.branches }
    result += SolarField.shared.subfields.flatMap { $0.branches }

    let loops = SolarField.shared.subfields.map { ($0.loopExemplar, $0.loopsCount) }
    let loopsPiping = loops.flatMap {
      [[Branch]](repeating: $0.0!.branches, count: $0.1)
    }
    result += loopsPiping.flatMap { $0 }
    return result
  }

  public static var branchTable: String {
    var table = [Branch.tableHeader]
    table += SolarField.branches.map { $0.commaSeparatedValues }
    return table.joined(separator: "\n")
  }

  public static func massFlow(scale: Double) {
    guard case 1 ... 100 = scale else { return }
    SolarField.shared.recalculation()
    SolarField.shared.scaleMassFlow(percentage: scale)
  }

  public static func attach(_ connector: [Connector]) {

    var allConnectors: [Connector] = []

    func another(connector: Connector) {
      allConnectors.append(connector)
      if let next = connector.successor {
        another(connector: next)
      }
    }

    func another(subField: SubField) {
      if let next = subField.successor {
        SolarField.shared.subfields.append(next)
        another(subField: next)
      }
    }

    connector.forEach { another(connector: $0) }

    SolarField.shared.connectors = allConnectors
    SolarField.shared.subfields = allConnectors.flatMap { $0.connections }

    SolarField.shared.subfields.forEach { another(subField: $0) }
    _ = SolarField.branches // Make sure the order is right.

  }
}

extension Array where Element == Connector {

  func total(_ keyPath: KeyPath<Connector, Double>) -> Double {
    return map { $0[keyPath: keyPath] }.reduce(0.0, +)
  }
}

extension Array where Element == SubField {

  func total(_ keyPath: KeyPath<SubField, Double>) -> Double {
    map { $0[keyPath: keyPath] }.reduce(0.0, +)
  }

  func sum(_ keyPath: KeyPath<SubField, Int>) -> Int {
    map { $0[keyPath: keyPath] }.reduce(0, +)
  }
}
