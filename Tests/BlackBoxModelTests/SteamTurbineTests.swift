import XCTest

@testable import BlackBoxModel

class SteamTurbineTests: XCTestCase {
  func testsPerfomance() {
    var status = Plant.initialState
    let temperature = Temperature(celsius: 20.0)
    let heatExchanger = Temperature(celsius: 350.0)
    var (maxLoad, efficiency) = SteamTurbine.perform(
      steamTurbine: Ratio(1),
      boiler: status.boiler.operationMode,
      gasTurbine: status.gasTurbine.operationMode,
      heatExchanger: heatExchanger, ambient: temperature
    )
    XCTAssertEqual(maxLoad, 1, accuracy: 0.01, "maxLoad")
    XCTAssertEqual(efficiency, 0.399, accuracy: 0.01, "efficiency")
    (maxLoad, efficiency) = SteamTurbine.perform(
      steamTurbine: Ratio(0),
      boiler: status.boiler.operationMode,
      gasTurbine: status.gasTurbine.operationMode,
      heatExchanger: heatExchanger, ambient: temperature
    )
    XCTAssertEqual(maxLoad, 0, accuracy: 0.01, "maxLoad")
    XCTAssertEqual(efficiency, 0, accuracy: 0.01, "efficiency")
    status.boiler.operationMode = .operating
    (maxLoad, efficiency) = SteamTurbine.perform(
      steamTurbine: Ratio(0.5),
      boiler: status.boiler.operationMode,
      gasTurbine: status.gasTurbine.operationMode,
      heatExchanger: heatExchanger, ambient: temperature
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
