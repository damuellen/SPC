import XCTest

@testable import BlackBoxModel
import Meteo
@testable import SolarPosition

class HCETests: XCTestCase {
  func testsRadiationLosses() {
    var status = Plant.initialState
    let meteo = MeteoData(
      dni: 555, ghi: 0, dhi: 0, temperature: 22, windSpeed: 11
    )
   /* var radiationLosses = HCE.radiationLosses(
      temperatures: (300.0, 22.0), collector: status.collector, meteo: meteo)
    status.collector.theta = 0.4
    status.collector.efficiency = 0.90
    XCTAssertEqual(radiationLosses, 14.54, accuracy: 0.01)
    radiationLosses = HCE.radiationLosses(
      temperatures: (300.0, 22.0),  collector: status.collector, meteo: meteo)
    XCTAssertEqual(radiationLosses, 14.54, accuracy: 0.01)*/
  }

  func testsMode1() {
   /* var status = Plant.initialState
    status.collector.theta = 0.4
    status.collector.efficiency = 0.90
    let meteo = MeteoData(dni: 555, ghi: 0, dhi: 0, temperature: 22, windSpeed: 11)
    HCE.mode1(&status.solarField, collector: status.collector,
              loop: .design, meteo: meteo)*/
  }

  func testsMode2() {
    var status = Plant.initialState
    status.collector.theta = 0.4
    status.collector.efficiency = 0.90
    status.solarField.loops[0].massFlow = 10.0
    let meteo = MeteoData(
      dni: 333, ghi: 0, dhi: 0, temperature: 22, windSpeed: 10
    )
   /* HCE.mode2(&status.solarField, collector: status.collector,
              loop: .design, meteo: meteo)*/
  }

  static var allTests: [(String, (HCETests) -> () throws -> Void)] {
    return [
      ("testsRadiationLosses", testsRadiationLosses),
      ("testsMode1", testsMode1),
      ("testsMode2", testsMode2),
    ]
  }
}
