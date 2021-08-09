//
//  SolarField.swift
//  SolarField
//
//  Created by Daniel Muellenborn on 23/03/2015.
//  Copyright © 2015 Daniel Muellenborn. All rights reserved.
//

public final class SolarField {

  public var powerBlock: PowerBlock!
  public var expansionVolume: ExpansionVolume!

  public static var designTemperature = (inlet: 297.0, outlet: 393.0)
  public static var ambientTemperature = 20.0
  public static var fluid = Fluid.terminol

  public var connectors: [Connector] = []
  public var subfields: [SubField] = []

  public var loop: CollectorLoop { subfields.first!.loopExemplar }

  var isValid: Bool {
    !connectors.isEmpty
      && !subfields.isEmpty
      && massFlowPerLoop > 0
  }

  public var massFlow: Double {
    didSet { recalculation() }
  }

  public var designStreamVelocity: Double = 3.5 {
    didSet { recalculation() }
  }

  public var rowDistance: Double = 18.0 {
    didSet { recalculation() }
  }

  init(massFlow: Double = 0.0) {
    self.massFlow = massFlow
    self.powerBlock = PowerBlock(solarField: self)
    self.expansionVolume = ExpansionVolume(solarField: self)
  }

  public func callAsFunction(@Connector fields: () -> [SubField]) -> Connector {
    connectors.append(Connector(with: fields(), solarField: self))
    return connectors.last!
  }

  public func recalculation() {
    subfields = connectors.flatMap { $0.connections }
    func another(subField: SubField) {
      if let next = subField.successor {
        next.solarField = self
        subfields.append(next)
        another(subField: next)
      }
    }
    subfields.forEach { another(subField: $0) }
    connectors.forEach { $0.recalculation() }
    subfields.forEach { $0.recalculation() }
    powerBlock.recalculation()
  //  _ = branches // Make sure the order is right.
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

  public var branches: [Branch] {
    var result = powerBlock.branches
    result += connectors.flatMap { $0.branches }
    result += subfields.flatMap { $0.branches }

    let loops = subfields.map { ($0.loopExemplar, $0.loopsCount) }
    let loopsPiping = loops.flatMap {
      [[Branch]](repeating: $0.0!.branches, count: $0.1)
    }
    result += loopsPiping.flatMap { $0 }
    return result
  }

  public func massFlow(scale: Double) {
    guard case 1 ... 100 = scale else { return }
    recalculation()
    scaleMassFlow(percentage: scale)
  }
}

extension Array where Element == Connector {

  func total(_ keyPath: KeyPath<Connector, Double>) -> Double {
    return map { $0[keyPath: keyPath] }.sum()
  }
}

extension Array where Element == SubField {

  func total(_ keyPath: KeyPath<SubField, Double>) -> Double {
    map { $0[keyPath: keyPath] }.sum()
  }

  func sum(_ keyPath: KeyPath<SubField, Int>) -> Int {
    map { $0[keyPath: keyPath] }.reduce(0, +)
  }
}


extension Sequence where Element: FloatingPoint {
  func sum() -> Element {
    var result: Element = 0
    var excess: Element = 0

    for x in self {
      let large = Element.maximumMagnitude(result, x)
      let small = Element.minimumMagnitude(result, x)
      result += x
      excess += (result - large) - small
    }
    return result - excess
  }
}