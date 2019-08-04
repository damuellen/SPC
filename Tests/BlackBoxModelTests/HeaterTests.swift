import XCTest

@testable import BlackBoxModel

class HeaterTests: XCTestCase {
  func testsHeater() {
    let status = Plant.initialState
    var heater = status.heater
    let energy = Heater.update(
      heater: &heater,
      powerBlock: status.powerBlock,
      storage: status.storage,
      solarField: status.solarField,
      demand: 1,
      fuelAvailable: 10)
    XCTAssertEqual(energy.heat, 0.0, accuracy: 0.01, "heat")
    XCTAssertEqual(energy.electric, 10.0, accuracy: 0.01, "electric")
    XCTAssertEqual(energy.fuel, 0.0, accuracy: 0.01, "fuel")
  }

  static var allTests: [(String, (HeaterTests) -> () throws -> Void)] {
    return [
      ("testsHeater", testsHeater),
    ]
  }
}
