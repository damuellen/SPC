import XCTest

@testable import BlackBoxModel
import PhysicalQuantities

class SteamTurbineTests: XCTestCase {
  func testsPerfomance() {
    var status = Plant.initialState
    let plant = Plant()
    let ambientTemperature = Temperature(celsius: 20.0)
    let heatExchanger = Temperature(celsius: 350.0)
    var (maxLoad, efficiency) = SteamTurbine.perform(load: Ratio(1),
      heatExchanger: heatExchanger, ambient: ambientTemperature
    )
    XCTAssertEqual(maxLoad, 1, accuracy: 0.01, "maxLoad")
    XCTAssertEqual(efficiency, 0.399, accuracy: 0.01, "efficiency")
    (maxLoad, efficiency) = SteamTurbine.perform(load:Ratio(0),
      heatExchanger: heatExchanger, ambient: ambientTemperature
    )
    XCTAssertEqual(maxLoad, 1, accuracy: 0.01, "maxLoad")
    XCTAssertEqual(efficiency, 0.22, accuracy: 0.01, "efficiency")
    status.boiler.operationMode = .operating
    (maxLoad, efficiency) = SteamTurbine.perform(load:Ratio(0.5),
      heatExchanger: heatExchanger, ambient: ambientTemperature
    )
    XCTAssertEqual(maxLoad, 1, accuracy: 0.01, "maxLoad")
    XCTAssertEqual(efficiency, 0.383, accuracy: 0.01, "efficiency")
  }
}
