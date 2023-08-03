import DateExtensions
import Meteo
import Utilities
import XCTest

@testable import BlackBoxModel
@testable import SolarPosition

func statistics(_ timings: [Double]) -> (mean: Double, stddev: Double) {
  var sum: Double = 0
  var sqsum: Double = 0
  for timing in timings {
    sum += timing
    sqsum += timing * timing
  }
  let n = Double(timings.count)
  let mean = sum / n
  let variance = sqsum / n - mean * mean
  return (mean: mean, stddev: sqrt(variance))
}

class CollectorTests: XCTestCase {
  func testsEfficiency() {
    let numberOfSCAsInRow = Double(SolarField.parameter.numberOfSCAsInRow)
    let edgeFactor1 = SolarField.parameter.distanceSCA / 2 * (1 - 1 / numberOfSCAsInRow) / Collector.parameter.lengthSCA
    let edgeFactor2 = (1 + 1 / numberOfSCAsInRow) / Collector.parameter.lengthSCA / 2
    SolarField.parameter.edgeFactor = [edgeFactor1, edgeFactor2]
    var collector = Collector(parabolicElevation: 63.96, theta: 29.18, cosTheta: 0.87, efficiency: 0, insolationAbsorber: 0)
    collector.efficiency(ws: 0)
    XCTAssertEqual(collector.efficiency, 0.72, accuracy: 0.1)
    collector = Collector(parabolicElevation: 51.49, theta: 55.53, cosTheta: 0.56, efficiency: 0, insolationAbsorber: 0)
    collector.efficiency(ws: 0)
    XCTAssertEqual(collector.efficiency, 0.6, accuracy: 0.1)
  }

  func testMean() {
    guard 
      let file = try? MeteoDataFileHandler(forReadingAtPath: "/Users/daniel/spc/COM/Tunol.mto"),
      let meteo = try? file.data(valuesPerHour: 12),
      let location = try? file.metadata().location
    else { return }
    
    let sun = SolarPosition(coords: location.coordinates, tz: -1, year: 2017, frequence: .fiveMinutes)
    
    let numberOfSCAsInRow = Double(SolarField.parameter.numberOfSCAsInRow)
    let edge1 = SolarField.parameter.distanceSCA / 2 * (1 - 1 / numberOfSCAsInRow) / Collector.parameter.lengthSCA
    let edge2 = (1 + 1 / numberOfSCAsInRow) / Collector.parameter.lengthSCA / 2
    SolarField.parameter.edgeFactor = [edge1, edge2]
    var collector = Plant.initialState.collector
    var cosTheta = [Double]()
    var efficiency = [Double]()
    for date in DateSeries(year: 2017, interval: .fiveMinutes) {
      if let pos = sun[date] {
        collector.tracking(sun: pos)
        collector.efficiency(ws: 1)
        cosTheta.append(collector.cosTheta)
        efficiency.append(collector.efficiency)
      } else {
        cosTheta.append(.zero)
        efficiency.append(.zero)
      }
    }

    let values1 = cosTheta.chunks(ofCount: 12)
      .map { perc -> Double in let cosTheta = perc.filter { !$0.isZero }
        if cosTheta.isEmpty { return 0 }
        return statistics(cosTheta).mean
      }

    let values2 = efficiency.chunks(ofCount: 12)
      .map { perc -> Double in let efficiency = perc.filter { !$0.isZero }
        if efficiency.isEmpty { return 0 }
        return statistics(efficiency).mean
      }

    let values12 = cosTheta.chunks(ofCount: 12)
      .map { perc -> Double in let cosTheta = perc.filter { !$0.isZero }
        if cosTheta.isEmpty { return 0 }
        return statistics(cosTheta).stddev
      }

    let values22 = efficiency.chunks(ofCount: 12)
      .map { perc -> Double in let efficiency = perc.filter { !$0.isZero }
        if efficiency.isEmpty { return 0 }
        return statistics(efficiency).stddev
      }

    var out = ""
    let dates = DateSeries(year: 2017, interval: .hour).map { $0 }
    for x in zip(zip(dates, meteo), values1.indices) { 
      let a = x.0.1
      let dni = a.insolation.direct
      print(DateTime(x.0.0).description, values12[x.1], values22[x.1], values1[x.1], values2[x.1], dni, dni * values1[x.1] * values2[x.1], to: &out)
    }
    try? out.write(toFile: "mto.csv", atomically: false, encoding: .utf8)
  }

  func testsTracking() {
    var collector = Plant.initialState.collector

    let januaryAM = SolarPosition.Output(
      zenith: 63.715, azimuth: 156.859, elevation: 26.284, hourAngle: -22.517,
      declination: -23.023, incidence: 0.442, cosIncidence: cos(0.442 * .pi / 18),
      sunrise: 435.029, sunset: 1005.108)

    let aprilAM = SolarPosition.Output(
      zenith: 38.333, azimuth: 141.835, elevation: 51.666, hourAngle: -22.626,
      declination: 4.810, incidence: 0.784, cosIncidence: cos(0.784 * .pi / 18),
      sunrise: 345.913, sunset: 1095.098)

    let julyAM = SolarPosition.Output(
      zenith: 35.192, azimuth: 102.700, elevation: 54.807, hourAngle: -37.677,
      declination: 23.058, incidence: 0.817, cosIncidence: cos(0.817 * .pi / 18),
      sunrise: 285.618, sunset: 1155.803)

    let julyPM = SolarPosition.Output(
      zenith: 34.916, azimuth: 256.965, elevation: 55.083, hourAngle: 37.312,
      declination: 23.043, incidence: 0.819, cosIncidence: cos(0.819 * .pi / 18),
      sunrise: 285.714, sunset: 1155.786)

    let octoberPM = SolarPosition.Output(
      zenith: 55.618, azimuth: 232.403, elevation: 34.381, hourAngle: 40.944,
      declination: -3.520, incidence: 0.564, cosIncidence: cos(0.564 * .pi / 18),
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
