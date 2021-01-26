//
//  PowerBlock.swift
//  SolarField
//
//  Created by Daniel Muellenborn on 23/03/2015.
//  Copyright © 2015 Daniel Muellenborn. All rights reserved.
//

public class PowerBlock: Piping {

  public var name: String = "PowerBlock"

  public var distance: Double = 50.0
  public var numberOfPumps: Int = 3
  public var lossCoefficientHX = 75.0

  let solarField: SolarField

  init(solarField: SolarField) {
    self.solarField = solarField
  }

  var streamVelocity: Double {
    adaptedStreamVelocity ?? solarField.designStreamVelocity
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
    let temperature = SolarField.designTemperature.inlet
    let massFlow = solarField.massFlow
    let volumeFlow = Branch.volumeFlow(massFlow: massFlow,
                                       temperature: temperature)
    let headloss = solarField.totalHeadLoss + headLoss
    let volumeFlowPerPump = volumeFlow / Double(numberOfPumps)
    return volumeFlowPerPump * SolarField.fluid.density(temperature)
      * 9.81 * headloss / 10e5
  }

  var pumpElectricPower: Double { pumpHydraulicPower / 0.8 }

  var leadingPressureDrop: Double {
    return solarField.connectors.map { $0.totalPressureDrop }.max() ?? 0
  }

  var leadingHeadLoss: Double {
    return solarField.connectors.map { $0.totalHeadLoss }.max() ?? 0
  }

  var totalPressureDrop: Double { pressureDrop + leadingPressureDrop }

  var totalHeadLoss: Double { headLoss + leadingHeadLoss }

  var components: [Component] { branches.flatMap { $0.components } }

  var branches: [Branch] {

    if !_branches.isEmpty { return _branches }

    let temperature = SolarField.designTemperature

    var cold = Branch(temperature: temperature.inlet,
                      massFlow: solarField.massFlow,
                      header: self)
    cold.name = "Cold Header in powerblock"

    var hot = Branch(temperature: temperature.outlet,
                     massFlow: solarField.massFlow,
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
