import XCTest

import Meteo
@testable import SolarPosition
@testable import BlackBoxModel

class HCETests: XCTestCase {
  
  func testsRadiationLosses() {
    var status = Plant.initialState
    let meteo = MeteoData(
      dni: 555, ghi: 0, dhi: 0, temperature: 22, windSpeed: 11)
    var radiationLosses = HCE.radiationLosses(for: status.collector, at:
      (300.0, 22.0), meteo: meteo)
    status.collector.theta = 0.4
    status.collector.efficiency = 0.90
    XCTAssertEqual(radiationLosses, 14.54, accuracy: 0.01)
    radiationLosses = HCE.radiationLosses(for: status.collector, at:
      (300.0, 22.0), meteo: meteo)
    XCTAssertEqual(radiationLosses, 14.54, accuracy: 0.01)
  }
  
  func testsMode1() {
    var status = Plant.initialState
    status.collector.theta = 0.4
    status.collector.efficiency = 0.90
    let meteo = MeteoData(dni: 555, ghi: 0, dhi: 0, temperature: 22, windSpeed: 11)
    HCE.mode1(&status, loop: .design, mode: .variable, meteo: meteo)
 
  }
  
  func testsMode2() {
    var status = Plant.initialState
    status.collector.theta = 0.4
    status.collector.efficiency = 0.90
    status.solarField.loops[0].massFlow = 10.0
    let meteo = MeteoData(dni: 333, ghi: 0, dhi: 0, temperature: 22, windSpeed: 10)
    HCE.mode2(&status, loop: .design, mode: .variable, meteo: meteo)
  }
  
  static var allTests: [(String, (HCETests) -> () throws -> Void)] {
    return [
      ("testsRadiationLosses", testsRadiationLosses),
      ("testsMode1", testsMode1),
      ("testsMode2", testsMode2),
    ]
  }
}
