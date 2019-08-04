import XCTest

@testable import BlackBoxModel

class BoilerTests: XCTestCase {
  func testsBoiler() {
    var status = Plant.initialState.boiler
    let energy = Boiler.update(&status, demand: 1, Qsf_load: 1, fuelAvailable: 1)
    XCTAssertEqual(energy.heat, 0.0, accuracy: 0.01)
    XCTAssertEqual(energy.electric, 0.0, accuracy: 0.01)
    XCTAssertEqual(energy.fuel, 0.0, accuracy: 0.01)
  }

  static var allTests: [(String, (BoilerTests) -> () throws -> Void)] {
    return [
      ("testsBoiler", testsBoiler),
    ]
  }
}
