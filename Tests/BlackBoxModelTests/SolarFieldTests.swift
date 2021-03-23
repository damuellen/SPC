import XCTest

@testable import BlackBoxModel

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
    let maxFlow = SolarField.parameter.maxMassFlow
    solarField.maxMassFlow = solarField.minMassFlow + 1.0
    defer { SolarField.parameter.maxMassFlow = maxFlow }

    collector.insolationAbsorber = 666.6
    solarField.calculate(collector: collector, ambient: Temperature(celsius: 25.0))
   
    XCTAssertEqual(solarField.outlet, 513.8, accuracy: 0.1)
    XCTAssertEqual(solarField.inFocus.quotient, 0.0, accuracy: 0.1)

    let parasitics = solarField.parasitics()

    XCTAssertEqual(parasitics, 0.5, accuracy: 0.1)

    collector.insolationAbsorber = 466.6
    solarField.calculate(collector: collector, ambient: Temperature(celsius: 25.0))
    
    XCTAssertEqual(solarField.outlet, 632.9, accuracy: 0.1)
    XCTAssertEqual(solarField.inFocus.quotient, 0.61, accuracy: 0.1)

    collector.insolationAbsorber = 66.6
    solarField.calculate(collector: collector, ambient: Temperature(celsius: 25.0))
    
    XCTAssertEqual(solarField.outlet, 632.9, accuracy: 0.1)
    XCTAssertEqual(solarField.inFocus.quotient, 1.0, accuracy: 0.1)
  }

  static var allTests: [(String, (SolarFieldTests) -> () throws -> Void)] {
    return [
      ("testsOutletTemperature", testsOutletTemperature),
    ]
  }
}
