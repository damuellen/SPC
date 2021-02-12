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
    Collector.efficiency(&collector, ws: 0) // 0.90

    let maxFlow = SolarField.parameter.maxMassFlow
    SolarField.parameter.maxMassFlow = 300.0
    defer { SolarField.parameter.maxMassFlow = maxFlow }

    var dumping = 0.0
    collector.insolationAbsorber = 666.6
    solarField.calculate(dumping: &dumping, collector: collector, ambient: Temperature(celsius: 25.0))

    XCTAssertEqual(dumping, 159173093.3, accuracy: 0.1)
    XCTAssertEqual(solarField.outlet, 666.15, accuracy: 0.1)
    XCTAssertEqual(solarField.inFocus.quotient, 0.44, accuracy: 0.1)

    let parasitics = solarField.parasitics()

    XCTAssertEqual(parasitics, 4.0, accuracy: 0.1)

    collector.insolationAbsorber = 466.6
    solarField.calculate(dumping: &dumping, collector: collector, ambient: Temperature(celsius: 25.0))

    XCTAssertEqual(dumping, 63349013.3, accuracy: 0.1)
    XCTAssertEqual(solarField.outlet, 666.15, accuracy: 0.1)
    XCTAssertEqual(solarField.inFocus.quotient, 0.65, accuracy: 0.1)

    collector.insolationAbsorber = 66.6
    solarField.calculate(dumping: &dumping, collector: collector, ambient: Temperature(celsius: 25.0))

    XCTAssertEqual(dumping, 0, accuracy: 0.1)
    XCTAssertEqual(solarField.outlet, 467.96, accuracy: 0.1)
    XCTAssertEqual(solarField.inFocus.quotient, 0, accuracy: 0.1)
  }

  static var allTests: [(String, (SolarFieldTests) -> () throws -> Void)] {
    return [
      ("testsOutletTemperature", testsOutletTemperature),
    ]
  }
}
