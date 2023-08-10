import Units
import XCTest

@testable import BlackBoxModel

class HCETests: XCTestCase {
  func testsRadiationLosses() {
    var collector = Plant.initialState.collector
    var t1 = Temperature(celsius: 390.0)
    let t2 = Temperature(celsius: 43.0)

    var previous = -Double.infinity
    for t in 50...400 {
      t1 = Temperature(celsius: Double(t))
      let current = HCE.radiationLossesNew((t1, t1, t2), insolation: 400)
      XCTAssertGreaterThan(current, previous)
      previous = current
    }
  }
  /*
  func testsMode1() {
    var solarField = Plant.initialState.solarField
    var collector = Plant.initialState.collector
    var amb = Temperature(celsius: 20.0)
    collector.insolationAbsorber = 500.0
    collector.efficiency = 80.0
    var (_,dumping) = HCE.mode1(&solarField, collector, .design, amb)
    var hce = solarField.loops[0]
    XCTAssertEqual(hce.massFlow.rate, 490.5, accuracy: 0.1)
    XCTAssertEqual(hce.temperature.outlet.celsius, 393.0, accuracy: 0.1)
    XCTAssertEqual(dumping.isZero, true)
    XCTAssertEqual(solarField.heatLossesHCE, 31.18, accuracy: 0.01)
    XCTAssertEqual(solarField.heatLosses, 41.98, accuracy: 0.01)
    XCTAssertEqual(solarField.loopEta, 79.99, accuracy: 0.01)
    XCTAssertEqual(solarField.eta, 79.99, accuracy: 0.01)
    XCTAssertEqual(solarField.inFocus.quotient, 1, accuracy: 0.01)
    collector.insolationAbsorber = 600.0
    amb = Temperature(celsius: 30.0)
    (_,dumping) = HCE.mode1(&solarField, collector, .design, amb)
    hce = solarField.loops[0]
    XCTAssertEqual(hce.massFlow.rate, 598.9, accuracy: 0.1)
    XCTAssertEqual(hce.temperature.outlet.celsius, 393.0, accuracy: 0.1)
    XCTAssertEqual(dumping.isZero, true)
    XCTAssertEqual(solarField.heatLossesHCE, 30.48, accuracy: 0.01)
    XCTAssertEqual(solarField.heatLosses, 40.88, accuracy: 0.01)
    XCTAssertEqual(solarField.inFocus.quotient, 1, accuracy: 0.01)
    collector.insolationAbsorber = 300.0
    amb = Temperature(celsius: 10.0)
    (_,dumping) = HCE.mode1(&solarField, collector, .design, amb)
    hce = solarField.loops[0]
    XCTAssertEqual(hce.massFlow.rate, 274.97, accuracy: 0.1)
    XCTAssertEqual(hce.temperature.outlet.celsius, 393.0, accuracy: 0.1)
    XCTAssertEqual(dumping.isZero, true)
    XCTAssertEqual(solarField.heatLossesHCE, 31.86, accuracy: 0.01)
    XCTAssertEqual(solarField.heatLosses, 43.05, accuracy: 0.01)
    XCTAssertEqual(solarField.inFocus.quotient, 1, accuracy: 0.01)
    collector.insolationAbsorber = 0.0
    (_,dumping) = HCE.mode1(&solarField, collector, .design, amb)
    hce = solarField.loops[0]
    XCTAssertEqual(hce.massFlow.rate, 230.8, accuracy: 0.1)
    XCTAssertEqual(hce.temperature.outlet.celsius, 393.0, accuracy: 0.1) // FIXME
    XCTAssertEqual(dumping.isZero, true)
    XCTAssertEqual(solarField.heatLossesHCE, 14.59, accuracy: 0.01)
    XCTAssertEqual(solarField.heatLosses, 21.64, accuracy: 0.01)
    XCTAssertEqual(solarField.inFocus.quotient, 1, accuracy: 0.01)
  }

  func testsMode2() {
    var solarField = Plant.initialState.solarField
    var collector = Plant.initialState.collector
    let amb = Temperature(celsius: 20.0)
    collector.insolationAbsorber = 500.0
    collector.efficiency = 80.0
    let (_,dumping) = HCE.mode2(&solarField, collector, .design, amb)
    let hce = solarField.loops[0]
    XCTAssertEqual(hce.massFlow.rate, 0, accuracy: 0.1)
    XCTAssertEqual(hce.temperature.outlet.celsius, 200.0, accuracy: 0.1) // FIXME
    XCTAssertEqual(dumping.isZero, true)
    XCTAssertEqual(solarField.heatLossesHCE, 15.11, accuracy: 0.01)
    XCTAssertEqual(solarField.heatLosses, 22.14, accuracy: 0.01)
    XCTAssertEqual(solarField.inFocus.quotient, 0, accuracy: 0.01)
  }
*/
}
