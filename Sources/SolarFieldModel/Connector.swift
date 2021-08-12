//
//  Connector.swift
//  SolarField
//
//  Created by Daniel Muellenborn on 23/03/2015.
//  Copyright © 2015 Daniel Muellenborn. All rights reserved.
//

/// Connects the subfields of the solar field to each other and to the power block.
@resultBuilder
public class Connector: Piping, Identifiable {

  public var name: String = "Header"
  public var distance: Double = 0.0 {
    didSet { solarField.recalculation() }
  }

  var successor: Connector? {
    didSet { solarField.recalculation() }
  }

  var connections: [SubField] = [] {
    didSet { solarField.recalculation() }
  }

  private unowned let solarField: SolarField

  var tail: (cold: Branch, hot: Branch)!

  public init(solarField: SolarField) {
    self.solarField = solarField
  }

  public init(with fields: [SubField], solarField: SolarField) {
    self.solarField = solarField
    fields.forEach { $0.head = self }
    fields.forEach { $0.solarField = solarField }
    self.distance = fields.map {  $0.loopExemplar.distance }.max() ?? 1
    connections = fields
  }

  public func connected(to other: Connector) {
    other.successor = self
  }

  public static func buildBlock(_ lhs: SubField, _ rhs: SubField) -> [SubField] {
    return [lhs, rhs]
  }

  public static func buildBlock(_ field: SubField) -> [SubField] {
    return [field]
  }

  public func scaleMassFlow(percentage: Double) {
    guard case 1 ... 100 = percentage else { return }
    let factor = percentage / 100
    _branches = branches.map {
      var branch = $0
      branch.massFlow *= factor
      return branch
    }
  }

  func recalculation() {
    _branches.removeAll(keepingCapacity: true)
    _branches = branches
  }

  var streamVelocity: Double {
    adaptedStreamVelocity ?? solarField.designStreamVelocity
  }

  public var adaptedStreamVelocity: Double? {
    didSet { recalculation() }
  }

  var leadingPressureDrop: Double {
    let result = connections.reduce(0) { (result, subField) in
        return result > subField.totalPressureDrop
          ? result : subField.totalPressureDrop
    }
    return max(successor?.totalPressureDrop ?? 0.0, result)
  }

  var leadingHeadLoss: Double {
    let result = connections.reduce(0) { (result, subField) in
      return result > subField.totalHeadLoss
        ? result : subField.totalHeadLoss
    }
    return max(successor?.totalHeadLoss ?? 0.0, result)
  }

  var worst: Bool {
    if !connections.isEmpty {
      return successor?.totalPressureDrop
        ?? 0 < connections.map { $0.totalPressureDrop }.max() ?? 0.0
    }
    return false
  }

  var totalResidenceTime: Double { return branches.residenceTime }

  var totalPressureDrop: Double {
    if successor == nil && connections.isEmpty { return pressureDrop }
    return pressureDrop + leadingPressureDrop
  }

  var totalHeadLoss: Double {
    if successor == nil && connections.isEmpty { return headLoss }
    return headLoss + leadingHeadLoss
  }

  var totalVolume: Double {
    if successor == nil && connections.isEmpty { return volume }
    return volume + connections.map { $0.volume }.reduce(0.0, +)
  }

  var massFlow: Double {
    var massFlow: Double = successor?.massFlow ?? 0.0
    massFlow = connections.reduce(massFlow) { (result, subField) in
      return result + subField.massFlow
    }
    return massFlow
  }

  var components: [Component] {
    return branches.flatMap { $0.components }
  }

  var branches: [Branch] {

    if !_branches.isEmpty { return _branches }

    let temperature = SolarField.designTemperature
    let numberOfElbows = Int(distance / 75.0) * 4

    var cold = Branch(temperature: temperature.inlet,
                      massFlow: massFlow,
                      header: self)
    cold.name = name + " cold side"

    cold.length = distance + ((distance / 75.0).rounded() * 4.0 * 5.0)
    cold.addElbows(count: numberOfElbows)

    var hot = Branch(temperature: temperature.outlet,
                     massFlow: massFlow,
                     header: self)
    hot.name = name + " hot side"

    hot.length = cold.length
    hot.addElbows(count: numberOfElbows)

    if successor == nil && connections.count == 1 {
      cold.components.append(Component(type: .elbow, size: cold.nps))
      hot.components.append(Component(type: .elbow, size: hot.nps))
    }

    _branches = [cold, hot]
    for (i, size) in zip(_branches.indices, sizeAdaptation) {
      _branches[i].increaseSize(by: size)
    }
    tail = (_branches[0], _branches[1])
    return _branches
  }

  private var _branches: [Branch] = []
  var sizeAdaptation: [Int] = []
}
