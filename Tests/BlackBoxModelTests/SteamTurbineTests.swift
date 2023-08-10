import Units
import XCTest

@testable import BlackBoxModel

class SteamTurbineTests: XCTestCase {
  func testsPerfomance() {
    var status = Plant.initialState
    _ = Plant()
    let ambientTemperature = Temperature(celsius: 20.0)
    let heatExchanger = Temperature(celsius: 350.0)
    status.steamTurbine.adjust(load: 1.0)
    var efficiency = status.steamTurbine.perform(
      heatExchanger: heatExchanger, ambient: ambientTemperature)
    XCTAssertEqual(efficiency.quotient, 0.4, accuracy: 0.01, "efficiency")
    status.steamTurbine.adjust(load: 0.0)
    efficiency = status.steamTurbine.perform(
      heatExchanger: heatExchanger, ambient: ambientTemperature)
    XCTAssertEqual(efficiency.quotient, 0.23, accuracy: 0.02, "efficiency")
    status.boiler.change(mode: .operating)
    status.steamTurbine.adjust(load: 0.5)
    efficiency = status.steamTurbine.perform(
      heatExchanger: heatExchanger, ambient: ambientTemperature)
    XCTAssertEqual(efficiency.quotient, 0.381, accuracy: 0.001, "efficiency")
  }
}
