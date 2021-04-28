import XCTest

@testable import BlackBoxModel
import PhysicalQuantities

class SolarFieldTests: XCTestCase {
  func testsOutletTemperature() 
  {
    var plant = Plant.setup()
    var solarField = Plant.initialState.solarField
    var collector = Plant.initialState.collector
    collector.parabolicElevation = 63.96
    collector.cosTheta = 0.87
    collector.theta = 29.18
    collector.efficiency(ws: 0) // 0.90
    solarField.temperature.inlet = 
      Temperature(celsius: SolarField.parameter.designTemperature.inlet)
      solarField.temperature.outlet = 
      Temperature(celsius: SolarField.parameter.designTemperature.outlet)
    let maxFlow = SolarField.parameter.maxMassFlow
    solarField.maxMassFlow = maxFlow

    for i in solarField.loops.indices {
      solarField.loops[i].temperature = solarField.temperature
    }
    collector.insolationAbsorber = 700.0
    solarField.calculate(collector: collector, ambient: Temperature(celsius: 25.0))

    XCTAssertEqual(solarField.flow, maxFlow.rate, accuracy: 0.1)
    XCTAssertEqual(solarField.outlet, 666.0, accuracy: 0.5)
    XCTAssertEqual(solarField.inFocus.quotient, 0.82, accuracy: 0.1)

    for i in solarField.loops.indices {
      solarField.loops[i].temperature = solarField.temperature
    }
    collector.insolationAbsorber = 600.0
    solarField.calculate(collector: collector, ambient: Temperature(celsius: 25.0))

    XCTAssertEqual(solarField.flow, maxFlow.rate, accuracy: 0.5)
    XCTAssertEqual(solarField.outlet, 666.0, accuracy: 0.5)
    XCTAssertEqual(solarField.inFocus.quotient, 0.96, accuracy: 0.1)

    for i in solarField.loops.indices {
      solarField.loops[i].temperature = solarField.temperature
    }
    collector.insolationAbsorber = 500.0
    solarField.calculate(collector: collector, ambient: Temperature(celsius: 25.0))
    XCTAssertEqual(solarField.flow, 941.6, accuracy: 0.1)
    XCTAssertEqual(solarField.outlet, 666.0, accuracy: 0.5)
    for i in solarField.loops.indices {
      solarField.loops[i].temperature = solarField.temperature
    }
    collector.insolationAbsorber = 400.0
    solarField.calculate(collector: collector, ambient: Temperature(celsius: 25.0))
   
    XCTAssertEqual(solarField.outlet, 666.0, accuracy: 0.5)

    let parasitics = solarField.parasitics()
    XCTAssertEqual(parasitics, 1.9, accuracy: 0.1)

    solarField.maxMassFlow.rate = maxFlow.rate / 2

    for i in solarField.loops.indices {
      solarField.loops[i].temperature = solarField.temperature
    }
    collector.insolationAbsorber = 300.0
    solarField.calculate(collector: collector, ambient: Temperature(celsius: 25.0))
    XCTAssertEqual(solarField.flow, maxFlow.rate / 2, accuracy: 1.0)
    XCTAssertEqual(solarField.outlet, 666.0, accuracy: 0.5)
  }
}
