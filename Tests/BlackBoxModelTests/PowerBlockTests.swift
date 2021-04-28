import XCTest

@testable import BlackBoxModel
import PhysicalQuantities

class PowerBlockTests: XCTestCase {
  func testsParasitics() {
    let steamTurbine = Plant.initialState.steamTurbine
    let parasitics = PowerBlock.parasitics(
      heat: 100, steamTurbine: steamTurbine,
      temperature: Temperature(celsius: 390.0))
    XCTAssertEqual(parasitics, 0.78, accuracy: 0.01, "parasitics")
  }
}
