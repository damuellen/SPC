import XCTest

@testable import BlackBoxModel
import Meteo
@testable import SolarPosition

class CollectorTests: XCTestCase {
  func testsEfficiency() {
   /* var status = Plant.initialState
    status.collector.parabolicElevation = 20
    let meteo = MeteoData(
      dni: 555, ghi: 0, dhi: 0, temperature: 22, windSpeed: 11
    )
    Collector.update(&status.collector, meteo: meteo)
    XCTAssertEqual(status.collector.efficiency, 0.95, accuracy: 0.01)

    status.collector.parabolicElevation = 70
    Collector.update(&status.collector, meteo: meteo)
    XCTAssertEqual(status.collector.efficiency, 0.95, accuracy: 0.01)

    var results = [Double]()
    for n in [99, 121, 124, 149, 168, 171] {
      status.collector.parabolicElevation = Double(n)
      Collector.update(&status.collector, meteo: meteo)
      results.append(status.collector.efficiency)
    }*/
  }

  func testsTracking() {
   /* Plant.setLocation(Meteo.Location(
      longitude: -14.19, latitude: 37.090000000000003, elevation: 0.0
    ))
    
     let januaryAM = SolarPosition.OutputValues(
     zenith: 63.715965270996094, azimuth: 156.85934448242188,
     elevation: 26.284036636352539, hourAngle: -22.517242431640625,
     declination: -23.023462295532227, incidence: 0.44282135367393494,
     dni: 1414.9132080078125, sunrise: 435.0296, sunset: 1005.1083)
     let aprilAM = SolarPosition.OutputValues(
     zenith: 38.333545684814453, azimuth: 141.83534240722656,
     elevation: 51.666454315185547, hourAngle: -22.62652587890625,
     declination: 4.8108587265014648, incidence: 0.78441339731216431,
     dni: 1368.119384765625, sunrise: 345.9135, sunset: 1095.0986)
     let julyAM = SolarPosition.OutputValues(
     zenith: 35.192836761474609, azimuth: 102.70011901855469,
     elevation: 54.807163238525391, hourAngle: -37.677745819091797,
     declination: 23.058448791503906, incidence: 0.81721693277359009,
     dni: 1321.367919921875, sunrise: 285.6184, sunset: 1155.8035)
     let julyPM = SolarPosition.OutputValues(
     zenith: 34.916896820068359, azimuth: 256.965087890625,
     elevation: 55.083103179931641, hourAngle: 37.312469482421875,
     declination: 23.043458938598633, incidence: 0.81998312473297119,
     dni: 1321.367919921875, sunrise: 285.7140, sunset: 1155.7861)
     let octoberPM = SolarPosition.OutputValues(
     zenith: 55.618637084960938, azimuth: 232.40342712402344,
     elevation: 34.381362915039062, hourAngle: 40.944198608398438,
     declination: -3.5206952095031738, incidence: 0.56469857692718506,
     dni: 1364.6182861328125, sunrise: 356.8873, sunset: 1055.5590)

     Collector.tracking(&Collector.status, sun: januaryAM)
     XCTAssertEqual(Collector.status.parabolicElevation, 0, accuracy: 0.01)
     XCTAssertEqual(Collector.status.cosTheta, 0, accuracy: 0.01)
     XCTAssertEqual(Collector.status.theta, 0, accuracy: 0.01)

     Collector.tracking(&Collector.status, sun: aprilAM)
     XCTAssertEqual(Collector.status.parabolicElevation, 0, accuracy: 0.01)
     XCTAssertEqual(Collector.status.cosTheta, 0, accuracy: 0.01)
     XCTAssertEqual(Collector.status.theta, 0, accuracy: 0.01)

     Collector.tracking(&Collector.status, sun: julyAM)
     XCTAssertEqual(Collector.status.parabolicElevation, 0, accuracy: 0.01)
     XCTAssertEqual(Collector.status.cosTheta, 0, accuracy: 0.01)
     XCTAssertEqual(Collector.status.theta, 0, accuracy: 0.01)

     Collector.tracking(&Collector.status, sun: julyPM)
     XCTAssertEqual(Collector.status.parabolicElevation, 0, accuracy: 0.01)
     XCTAssertEqual(Collector.status.cosTheta, 0, accuracy: 0.01)
     XCTAssertEqual(Collector.status.theta, 0, accuracy: 0.01)

     Collector.tracking(&Collector.status, sun: octoberPM)
     XCTAssertEqual(Collector.status.parabolicElevation, 0, accuracy: 0.01)
     XCTAssertEqual(Collector.status.cosTheta, 0, accuracy: 0.01)
     XCTAssertEqual(Collector.status.theta, 0, accuracy: 0.01)*/
  }

  static var allTests: [(String, (CollectorTests) -> () throws -> Void)] {
    return [
      ("testsEfficiency", testsEfficiency),
      ("testsTracking", testsTracking),
    ]
  }
}
