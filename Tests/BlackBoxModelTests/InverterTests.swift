import XCTest

@testable import BlackBoxModel

class InverterTests: XCTestCase {
  func testsInverter() {
    let inverter = PV.Inverter()
    let efficiency = inverter(power: 312359, voltage: 1148)
    XCTAssertEqual(efficiency, 97.61, accuracy: 0.01)
  }
}
