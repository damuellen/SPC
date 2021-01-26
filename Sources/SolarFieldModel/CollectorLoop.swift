//
//  CollectorLoop.swift
//  SolarField
//
//  Created by Daniel Muellenborn on 23/03/2015.
//  Copyright © 2015 Daniel Muellenborn. All rights reserved.
//

public class CollectorLoop {

  private unowned let subField: SubField

  private var _branches: [Branch] = []
  private var _collectors: [Collector] = []

  init(subField: SubField) {
    self.subField = subField
  }

  var solarField: SolarField {
    subField.solarField
  }

  public func scaleMassFlow(percentage: Double) {
    guard case 1 ... 100 = percentage else { return }
    let factor = percentage / 100
    _collectors = collectors.map {
      var collector = $0
      collector.scaleMassFlow = factor
      return collector
    }
    _branches = branches.map {
      var branch = $0
      branch.massFlow *= factor
      return branch
    }
  }

  func recalculation() {
    _branches.removeAll(keepingCapacity: true)
    _collectors.removeAll(keepingCapacity: true)
  }

  var insideDiameterAbsorber: Double = 65.6
  var insideDiameter: Double = 52.48

  var roughness: Double = 0.15
  var numberOfCollectors: Int = 4

  var distance: Double { (collectors.first?.length ?? 0) * 2 }

  var designMassFlow: Double { solarField.massFlowPerLoop }

  var totalVolume: Double { volumePipes + volumeCollectors }

  var pressureDropPipes: Double { branches.total(\.pressureDrop) }

  var headLossPipes: Double { branches.total(\.headLoss) }

  var pressureDropCollectors: Double { collectors.total(\.pressureDrop) }

  var headLossCollectors: Double { collectors.total(\.headLoss) }

  var volumePipes: Double {
    var pipes = Branch(temperature: 0.0, nps: 3)
    pipes.length = 30 + solarField.rowDistance
    return pipes.volume
  }

  var volumeCollectors: Double { collectors.total(\.volume) }

  var totalHeadLoss: Double { headLossPipes + headLossCollectors }

  var totalPressureDrop: Double { pressureDropPipes + pressureDropCollectors }

  var collectors: [Collector] {

    if !_collectors.isEmpty { return _collectors }

    let inlet = SolarField.designTemperature.inlet
    let outlet = SolarField.designTemperature.outlet
    let gainPerCollector = (outlet - inlet) / Double(numberOfCollectors)

    for n in 0 ..< numberOfCollectors {
      let averageTemperature =
        inlet + gainPerCollector * (0.5 + Double(n))
      _collectors.append(Collector(temperature: averageTemperature, subField: subField))
    }
    return _collectors
  }

  var branches: [Branch] {

    if !_branches.isEmpty { return _branches }

    let temperatureInlet = SolarField.designTemperature.inlet
    let temperatureOutlet = SolarField.designTemperature.outlet
    let temperatureMean = (temperatureInlet + temperatureOutlet) / 2

    var inlet = Branch(temperature: temperatureInlet, nps: 3.0)
    var outlet = Branch(temperature: temperatureOutlet, nps: 3.0)
    var cross = Branch(temperature: temperatureMean, nps: 3.0)

    inlet.name = "Loop inlet pipe"
    inlet.length = 10.0
    inlet.addElbows(count: 5)
    inlet.massFlow = designMassFlow
    inlet.addValve(type: .globe)
    inlet.addValve(type: .control)

    outlet.name = "Loop outlet pipe"
    outlet.length = 10.0
    outlet.addElbows(count: 5)
    outlet.massFlow = designMassFlow
    outlet.addValve(type: .globe)

    cross.name = "Loop crossover pipe"
    cross.length = subField.rowDistance + 0.5
    cross.massFlow = designMassFlow

    _branches = [inlet, outlet, cross]
    return _branches
  }
}
