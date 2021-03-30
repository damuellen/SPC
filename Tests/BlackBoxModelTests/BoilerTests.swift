import XCTest

@testable import BlackBoxModel

class BoilerTests: XCTestCase {
  func testsBoiler() {
    var boiler = Plant.initialState.boiler
    let energy = boiler(demand: 1, Qsf_load: 1, fuelAvailable: 1)
    XCTAssertEqual(energy.heatFlow, 0.0, accuracy: 0.01)
    XCTAssertEqual(energy.electric, 0.0, accuracy: 0.01)
    XCTAssertEqual(energy.fuel, 0.0, accuracy: 0.01)
  }
}
