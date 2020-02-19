import XCTest

@testable import BlackBoxModel

class HeaterTests: XCTestCase {
  func testsHeater() {
    let status = Plant.initialState
    var heater = status.heater
    let plant = Plant()
    let energy = heater(
      temperatureSolarField: status.solarField.temperature.outlet,
      temperaturePowerBlock: status.powerBlock.temperature.inlet,
      massFlowStorage: status.storage.massFlow,
      modeStorage: status.storage.operationMode, 
      demand: 1, fuelAvailable: 10, heat: plant.heat
    )
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
