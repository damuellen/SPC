import XCTest

@testable import BlackBoxModel

class HeaterTests: XCTestCase {
  func testsHeater() {
    let status = Plant.initialState
    var heater = status.heater
    let plant = Plant()
    let energy = heater(
      storage: status.storage.massFlow,
      mode: status.storage.operationMode, 
      heatDiff: 10, fuelAvailable: 10,
      heatFlow: plant.heatFlow
    )
    XCTAssertEqual(energy.heatFlow, 0.0, accuracy: 0.01, "heat")
    XCTAssertEqual(energy.electric, 1.0, accuracy: 0.01, "electric")
    XCTAssertEqual(energy.fuel, 0.0, accuracy: 0.01, "fuel")
  }

  static var allTests: [(String, (HeaterTests) -> () throws -> Void)] {
    return [
      ("testsHeater", testsHeater),
    ]
  }
}
