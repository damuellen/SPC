import XCTest

@testable import BlackBoxModel
import Units

class SteamTurbineTests: XCTestCase {
  func testsPerfomance() {
    var status = Plant.initialState
    _ = Plant()
    let ambientTemperature = Temperature(celsius: 20.0)
    let heatExchanger = Temperature(celsius: 350.0)
    status.steamTurbine.load = 1.0
    status.steamTurbine.efficiency(
      heatExchanger: heatExchanger, ambient: ambientTemperature
    )
    XCTAssertEqual(status.steamTurbine.efficiency.quotient, 0.4, accuracy: 0.01, "efficiency")
    status.steamTurbine.load = 0.0
    status.steamTurbine.efficiency(
      heatExchanger: heatExchanger, ambient: ambientTemperature
    )
    XCTAssertEqual(status.steamTurbine.efficiency.quotient, 0.40, accuracy: 0.02, "efficiency")
    status.boiler.change(mode: .operating)
    status.steamTurbine.load = 0.5
    status.steamTurbine.efficiency(
      heatExchanger: heatExchanger, ambient: ambientTemperature
    )
    XCTAssertEqual(status.steamTurbine.efficiency.quotient, 0.381, accuracy: 0.001, "efficiency")
  }
}
