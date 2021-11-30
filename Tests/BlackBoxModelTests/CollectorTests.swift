import XCTest

@testable import BlackBoxModel
@testable import SolarPosition
import Meteo
import Utilities

class CollectorTests: XCTestCase {
  func testsEfficiency() {
    let numberOfSCAsInRow = Double(SolarField.parameter.numberOfSCAsInRow)
    let edgeFactor1 = SolarField.parameter.distanceSCA / 2
      * (1 - 1 / numberOfSCAsInRow) / Collector.parameter.lengthSCA
    let edgeFactor2 = (1 + 1 / numberOfSCAsInRow)
      / Collector.parameter.lengthSCA / 2
    SolarField.parameter.edgeFactor = [edgeFactor1, edgeFactor2]
    var collector = Plant.initialState.collector
    collector.parabolicElevation = 63.96
    collector.cosTheta = 0.87
    collector.theta = 29.18
    collector.efficiency(ws: 0)
    XCTAssertEqual(collector.efficiency, 0.72, accuracy: 0.1)
    collector.parabolicElevation = 51.49
    collector.cosTheta = 0.56
    collector.theta = 55.53
    collector.efficiency(ws: 0)
    XCTAssertEqual(collector.efficiency, 0.57, accuracy: 0.1)
  }

  func testMeteo() {
    //let sun1 = SolarPosition(coords: (-26, 35, 0), tz: 2, year: 2017, frequence: .half_hourly)
    //let sun2 = SolarPosition(coords: (-26, 35, 0), tz: 2, year: 2017, frequence: .every5minutes).calculatedValues
    //let meteo = MeteoDataProvider.using(sun1, model: .special)
    //meteo.setInterval(.every5minutes)
    //let dni = meteo.map(\.dni)
    //try? Gnuplot(xs: Array(dni))(.pngLarge(path: "____1.png"))
  }

  func testsTracking() {
     var collector = Plant.initialState.collector
    
     let januaryAM = SolarPosition.OutputValues(
     zenith: 63.715965270996094, azimuth: 156.85934448242188,
     elevation: 26.284036636352539, hourAngle: -22.517242431640625,
     declination: -23.023462295532227, incidence: 0.44282135367393494,
     cosIncidence: cos(0.44282135367393494 * .pi / 180),
     sunrise: 435.0296, sunset: 1005.1083)
    
     let aprilAM = SolarPosition.OutputValues(
     zenith: 38.333545684814453, azimuth: 141.83534240722656,
     elevation: 51.666454315185547, hourAngle: -22.62652587890625,
     declination: 4.8108587265014648, incidence: 0.78441339731216431,
     cosIncidence: cos(0.78441339731216431 * .pi / 180),
     sunrise: 345.9135, sunset: 1095.0986)
    
     let julyAM = SolarPosition.OutputValues(
     zenith: 35.192836761474609, azimuth: 102.70011901855469,
     elevation: 54.807163238525391, hourAngle: -37.677745819091797,
     declination: 23.058448791503906, incidence: 0.81721693277359009,
     cosIncidence: cos(0.81721693277359009 * .pi / 180),
     sunrise: 285.6184, sunset: 1155.8035)
    
     let julyPM = SolarPosition.OutputValues(
     zenith: 34.916896820068359, azimuth: 256.965087890625,
     elevation: 55.083103179931641, hourAngle: 37.312469482421875,
     declination: 23.043458938598633, incidence: 0.81998312473297119,
     cosIncidence: cos(0.81998312473297119 * .pi / 180),
     sunrise: 285.7140, sunset: 1155.7861)
    
     let octoberPM = SolarPosition.OutputValues(
     zenith: 55.618637084960938, azimuth: 232.40342712402344,
     elevation: 34.381362915039062, hourAngle: 40.944198608398438,
     declination: -3.5206952095031738, incidence: 0.56469857692718506,
     cosIncidence: cos(0.56469857692718506 * .pi / 180),
     sunrise: 356.8873, sunset: 1055.5590)

     collector.tracking(sun: januaryAM)
     XCTAssertEqual(collector.parabolicElevation, 51.49, accuracy: 0.01)
     XCTAssertEqual(collector.cosTheta, 0.56, accuracy: 0.01)
     XCTAssertEqual(collector.theta, 55.53, accuracy: 0.01)

     collector.tracking(sun: aprilAM)
     XCTAssertEqual(collector.parabolicElevation, 63.96, accuracy: 0.01)
     XCTAssertEqual(collector.cosTheta, 0.87, accuracy: 0.01)
     XCTAssertEqual(collector.theta, 29.18, accuracy: 0.01)

     collector.tracking(sun: julyAM)
     XCTAssertEqual(collector.parabolicElevation, 55.47, accuracy: 0.01)
     XCTAssertEqual(collector.cosTheta, 0.99, accuracy: 0.01)
     XCTAssertEqual(collector.theta, 7.27, accuracy: 0.01)

     collector.tracking(sun: julyPM)
     XCTAssertEqual(collector.parabolicElevation, 124.21, accuracy: 0.01)
     XCTAssertEqual(collector.cosTheta, 0.99, accuracy: 0.01)
     XCTAssertEqual(collector.theta, 7.41, accuracy: 0.01)

     collector.tracking(sun: octoberPM)
     XCTAssertEqual(collector.parabolicElevation, 139.18, accuracy: 0.01)
     XCTAssertEqual(collector.cosTheta, 0.86, accuracy: 0.01)
     XCTAssertEqual(collector.theta, 30.23, accuracy: 0.01)
  }
}
