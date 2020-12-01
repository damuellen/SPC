//
//  SubField.swift
//  SolarField
//
//  Created by Daniel Muellenborn on 23/03/2015.
//  Copyright © 2015 Daniel Muellenborn. All rights reserved.
//

public final class SubField: Piping {

  public var name: String

  public var loopExemplar: CollectorLoop!

  weak var connection: Piping? {
    didSet { SolarField.shared.recalculation() }
  }

  var successor: SubField? {
    didSet { SolarField.shared.recalculation() }
  }

  var tail: (cold: Branch, hot: Branch)!

  var rowDistance: Double {
    return adaptedRowDistance ?? SolarField.shared.rowDistance
  }

  public var adaptedRowDistance: Double? {
    didSet { SolarField.shared.recalculation() }
  }

  var streamVelocity: Double {
    adaptedStreamVelocity ?? SolarField.shared.designStreamVelocity
  }

  public var adaptedStreamVelocity: Double? {
    didSet { SolarField.shared.recalculation() }
  }

  public var distance: Double = 0 {
    didSet { SolarField.shared.recalculation() }
  }

  public var lhsLoops: Int {
    didSet { SolarField.shared.recalculation() }
  }

  public var rhsLoops: Int {
    didSet { SolarField.shared.recalculation() }
  }

  var loopsCount: Int { return lhsLoops + rhsLoops }
  var maxLoops: Int { return max(lhsLoops, rhsLoops) }

  var loopsBefore: Int {
    return ((connection as? SubField)?.loopsBefore ?? 0)
      + ((connection as? SubField)?.maxLoops ?? 0)
  }

  public init(name: String, lhs: Int = 0, rhs: Int = 0,
              solarField: SolarField = SolarField.shared) {
    self.name = name
    self.lhsLoops = lhs
    self.rhsLoops = rhs
    self.loopExemplar = CollectorLoop(subField: self)
  }

  public init(loops: Int) {
    self.name = "SubField " + numberPool.removeLast().description
    self.lhsLoops = (loops / 2) + (loops % 2)
    self.rhsLoops = loops / 2
    self.loopExemplar = CollectorLoop(subField: self)
  }

  public func isAttached(to other: SubField) -> Bool {
    if other.successor != nil { return false }
    other.successor = self
    self.connection = other
    return true
  }

  public func scaleMassFlow(percentage: Double) {
    guard case 1 ... 100 = percentage else { return }
    let factor = percentage / 100
    _branches = branches.map {
      var branch = $0
      branch.massFlow *= factor
      return branch
    }
    loopExemplar.scaleMassFlow(percentage: percentage)
  }

  public func recalculation() {
    loopExemplar.recalculation()
    _branches.removeAll(keepingCapacity: true)
  }

  var components: [Component] { branches.flatMap { $0.components } }

  var totalResidenceTime: Double { branches.residenceTime }

  var totalPressureDrop: Double {
    var result = branches.pressureDrop
    result += successor?.totalPressureDrop ?? 0.0
    return result
  }

  var totalHeadLoss: Double {
    var result = branches.headLoss
    result += successor?.totalHeadLoss ?? 0.0
    return result
  }

  var massFlowPerLoop: Double { SolarField.shared.massFlowPerLoop }

  var massFlow: Double {
    var result = Double(totalLoops) * massFlowPerLoop
    result += successor?.massFlow ?? 0
    return result
  }

  var totalLoops: Int { return lhsLoops + rhsLoops }

  var volumeLoops: Double {
    return loopExemplar.totalVolume * Double(totalLoops)
  }

  private func addExpansionLoopWhenRequired(
    at loop: Int, _ headers: inout (cold: Branch, hot: Branch)) {
    let isExpansionLoopRequired = (loop + loopsBefore) % 2 == 0

    if isExpansionLoopRequired {
      headers.cold.addElbows(count: 4)
      headers.cold.length += 22
      headers.hot.addElbows(count: 4)
      headers.hot.length += 22
    }
  }

  var branches: [Branch] {

    if !_branches.isEmpty { return _branches }
    _branches.reserveCapacity(maxLoops * 2)

    guard let start = connection else { return [] }

    var massFlow = self.massFlow

    if maxLoops == 0 {
      let headers = createHeaders(to: 0, lower: &massFlow)
      _branches.append(headers.cold)
      _branches.append(headers.hot)
      tail = headers
      return _branches
    }

    for loopPosition in 1 ... maxLoops {

      var headers = createHeaders(to: loopPosition, lower: &massFlow)

      let isSubFieldStart = loopPosition == 1

      if isSubFieldStart {
        // Check if the size of the connection does not fit.
        if start.tail.cold.nps > headers.cold.nps {
          headers.cold.addReducer(toSize: start.tail.cold.nps)
        }
        if start.tail.hot.nps > headers.hot.nps {
          headers.hot.addReducer(toSize: start.tail.hot.nps)
        }
        // Check if shut-off valve in branch is required
        if start is Connector {
          headers.cold.addValve(type: .butterfly)
          headers.hot.addValve(type: .butterfly)
        }

      } else {
        // Check the size of the previous pipe end
        if tail.cold.nps > headers.cold.nps {
          headers.cold.addReducer(toSize: tail.cold.nps)
        }
        if tail.hot.nps > headers.hot.nps {
          headers.hot.addReducer(toSize: tail.hot.nps)
        }
      }

      addExpansionLoopWhenRequired(at: loopPosition, &headers)

      _branches.append(headers.cold)
      _branches.append(headers.hot)
      tail = headers
    }

    for (i, size) in zip(_branches.indices, sizeAdaptation) {
      _branches[i].increaseSize(by: size)
    }

    return _branches
  }

  private var _branches: [Branch] = []
  var sizeAdaptation: [Int] = []

  private func createHeaders(to loop: Int, lower massFlow: inout Double)
    -> (cold: Branch, hot: Branch) {

      let temperature = SolarField.shared.designTemperature

      var cold = Branch(temperature: temperature.inlet,
                        massFlow: massFlow,
                        header: self)
      cold.name = name + " cold header loop \(loop)"

      cold.length = loop == 1
        ? rowDistance * 2.0 + distance
        : rowDistance * 2.0
      cold.length = loop == 0 ? 0 : cold.length
      var hot = Branch(temperature: temperature.outlet,
                       massFlow: massFlow,
                       header: self)
      hot.name = name + " hot header loop \(loop)"

      hot.length = loop == 1
        ? (connection is SubField ? cold.length : rowDistance) + distance
        : cold.length

      if lhsLoops >= loop { massFlow -= massFlowPerLoop }
      if rhsLoops >= loop { massFlow -= massFlowPerLoop }

      return (cold, hot)
  }
}

extension SubField: ExpressibleByIntegerLiteral {
  public convenience init(integerLiteral value: Int) {
    self.init(loops: value)
  }
}
