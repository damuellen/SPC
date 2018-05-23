import XCTest

import Meteo
@testable import SolarPosition
@testable import BlackBoxModel

class HCETests: XCTestCase {
  
  func testsRadiationLosses() {
    var status = Plant.initialState

    var radiationLosses = HCE.radiationLosses(status, temperature:
      (300.0, 22.0), meteo: MeteoData(
      dni: 555, temperature: 22, windSpeed: 11))
    status.collector.theta = 0.4
    status.collector.efficiency = 0.90
    XCTAssertEqual(radiationLosses, 14.54, accuracy: 0.01)
    radiationLosses = HCE.radiationLosses(status, temperature:
      (300.0, 22.0), meteo: MeteoData(
        dni: 555, temperature: 22, windSpeed: 11))
    XCTAssertEqual(radiationLosses, 14.54, accuracy: 0.01)
  }
  
  static var allTests: [(String, (HCETests) -> () throws -> Void)] {
    return [
      ("testsRadiationLosses", testsRadiationLosses),
    ]
  }
}
