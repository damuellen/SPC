//
//  PowerBlock.swift
//  SolarField
//
//  Created by Daniel Muellenborn on 23/03/2015.
//  Copyright © 2015 Daniel Muellenborn. All rights reserved.
//

public class PowerBlock : Headers {

  public var name: String = "PowerBlock Header"

  public var distance: Double = 50.0
  public var numberOfPumps: Int = 3
  public var lossCoefficientHX = 75.0

  var streamVelocity: Double {
    adaptedStreamVelocity ?? SolarField.shared.designStreamVelocity
  }

  public var adaptedStreamVelocity: Double? {
    didSet { recalculation() }
  }

  var tail: (cold: Branch, hot: Branch)!

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
    _branches.removeAll()
  }

  var pumpHydraulicPower: Double {
    let temperature = SolarField.shared.designTemperature.inlet
    let massFlow = SolarField.shared.massFlow
    let volumeFlow = Branch.volumeFlow(massFlow: massFlow,
                                       temperature: temperature)
    let headloss = SolarField.shared.totalHeadLoss + headLoss
    let volumeFlowPerPump = volumeFlow / Double(numberOfPumps)
    return volumeFlowPerPump * SolarField.shared.fluid.density(temperature)
      * 9.81 * headloss / 10e5
  }

  var pumpElectricPower: Double { pumpHydraulicPower / 0.8 }

  var leadingPressureDrop: Double {
    return SolarField.shared.connectors.map { $0.totalPressureDrop }.max() ?? 0
  }

  var leadingHeadLoss: Double {
    return SolarField.shared.connectors.map { $0.totalHeadLoss }.max() ?? 0
  }

  var totalPressureDrop: Double { pressureDrop + leadingPressureDrop }

  var totalHeadLoss: Double { headLoss + leadingHeadLoss }

  var components: [Component] { branches.flatMap { $0.components } }

  var branches: [Branch] {

    if !_branches.isEmpty { return _branches }

    let temperature = SolarField.shared.designTemperature

    var cold = Branch(temperature: temperature.inlet,
                      massFlow: SolarField.shared.massFlow,
                      header: self)
    cold.name = "Cold Header in powerblock"

    var hot = Branch(temperature: temperature.outlet,
                     massFlow: SolarField.shared.massFlow,
                     header: self)
    hot.name = "Hot Header in powerblock"

    let numberOfElbows = Int(distance / 30.0) * 4

    cold.addElbows(count: numberOfElbows)
    hot.addElbows(count: numberOfElbows)
    hot.components.append(.init(lossCoeficient: lossCoefficientHX, size: hot.nps))
    cold.length = distance
    hot.length = distance

    _branches = [cold, hot]
    tail = (cold, hot)
    return _branches
  }

  private var _branches: [Branch] = []
}
