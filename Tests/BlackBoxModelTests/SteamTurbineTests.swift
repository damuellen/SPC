import XCTest

@testable import BlackBoxModel

class SteamTurbineTests: XCTestCase {
  func testsPerfomance() {
    var status = Plant.initialState
    let ambientTemperature = Temperature(celsius: 20.0)
    let heatExchanger = Temperature(celsius: 350.0)
    var (maxLoad, efficiency) = SteamTurbine.perform( Ratio(1),
      status.boiler.operationMode, status.gasTurbine.operationMode,
      heatExchanger, ambientTemperature
    )
    XCTAssertEqual(maxLoad, 1, accuracy: 0.01, "maxLoad")
    XCTAssertEqual(efficiency, 0.399, accuracy: 0.01, "efficiency")
    (maxLoad, efficiency) = SteamTurbine.perform(Ratio(0),
      status.boiler.operationMode,status.gasTurbine.operationMode,
      heatExchanger, ambientTemperature
    )
    XCTAssertEqual(maxLoad, 0, accuracy: 0.01, "maxLoad")
    XCTAssertEqual(efficiency, 0, accuracy: 0.01, "efficiency")
    status.boiler.operationMode = .operating
    (maxLoad, efficiency) = SteamTurbine.perform(Ratio(0.5),
      status.boiler.operationMode, status.gasTurbine.operationMode,
      heatExchanger, ambientTemperature
    )
    XCTAssertEqual(maxLoad, 1, accuracy: 0.01, "maxLoad")
    XCTAssertEqual(efficiency, 0.383, accuracy: 0.01, "efficiency")
  }

  static var allTests: [(String, (SteamTurbineTests) -> () throws -> Void)] {
    return [
      ("testsPerfomance", testsPerfomance),
    ]
  }
}
