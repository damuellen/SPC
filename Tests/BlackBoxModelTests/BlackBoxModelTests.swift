import XCTest

@testable import BlackBoxModel
@testable import Meteo
@testable import SolarPosition

class BlackBoxModelTests: XCTestCase {
  let df = DateFormatter()

  override func setUp() {
    _ = try? FileManager.default.createDirectory(atPath: ".plots", withIntermediateDirectories: true)
    df.timeZone = TimeZone(secondsFromGMT: 0)
    df.dateFormat = "dd.MM.yyyy"
  }

  func testsSummer() {
    Simulation.time.dateInterval = .init(
      start: df.date(from: "11.07.2005")!,
      end: df.date(from: "13.07.2005")!
    )
    var location = Location((47.73, 29, 0), tz: 2)
    location.timezone = 2

    BlackBoxModel.configure(year: 2005)
    BlackBoxModel.configure(location: location)
    let log = Historian(mode: .inMemory)
    BlackBoxModel.runModel(with: log)
    let result = log.finish()
    let tol = 1.0
    XCTAssertEqual(result.electric.net, 2209, accuracy: tol, "electric.net")
    XCTAssertEqual(result.electric.consum, 19, accuracy: tol, "electric.consum")
    XCTAssertEqual(result.electric.parasitics, 160, accuracy: tol, "electric.parasitics")
    XCTAssertEqual(result.electric.steamTurbineGross, 2390, accuracy: tol, "electric.steamTurbineGross")
    XCTAssertEqual(result.thermal.solar.megaWatt, 5888, accuracy: tol, "thermal.solar")
    XCTAssertEqual(result.thermal.startUp.megaWatt, 105, accuracy: tol, "thermal.startUp")
    XCTAssertEqual(result.thermal.production.megaWatt, 5752, accuracy: tol, "thermal.production")
    XCTAssertEqual(result.thermal.heatExchanger.megaWatt, 5778, accuracy: tol, "thermal.heatExchanger")
    for day in 192...193 {
      let interval = DateInterval(ofDay: day, in: 2005)
      let y1 = result.massFlows(range: interval)
      let y2 = result.power(range: interval)
      let plot = TimeSeriesPlot(y1: y1, y2: y2, range: interval, style: .impulses)
      plot.y1Titles = ["solarfield", "powerblock", "storage"]
      plot.y2Titles = ["solar", "toStorage", "production", "storage", "gross", "net", "consum"]
      _ = try? plot(toFile: ".plots/Day_\(day)_Summer")
    }
  }

  func testsWinter() {
    Simulation.time.dateInterval = .init(
      start: df.date(from: "11.01.2005")!,
      end: df.date(from: "13.01.2005")!
    )
    var location = Location((47.73, 29, 0), tz: 2)
    location.timezone = 2
    BlackBoxModel.configure(year: 2005)
    BlackBoxModel.configure(location: location)

    let log = Historian(mode: .inMemory)
    BlackBoxModel.runModel(with: log)

    let result = log.finish()
    let tol = 1.0
    XCTAssertEqual(result.electric.net, 1519, accuracy: tol, "electric.net")
    XCTAssertEqual(result.electric.consum, 31, accuracy: tol, "electric.consum")
    XCTAssertEqual(result.electric.parasitics, 128, accuracy: tol, "electric.parasitics")
    XCTAssertEqual(result.electric.steamTurbineGross, 1652, accuracy: tol, "electric.steamTurbineGross")
    XCTAssertEqual(result.thermal.solar.megaWatt, 4082, accuracy: tol, "thermal.solar")
    XCTAssertEqual(result.thermal.startUp.megaWatt, 92, accuracy: tol, "thermal.startUp")
    XCTAssertEqual(result.thermal.production.megaWatt, 3963, accuracy: tol, "thermal.production")
    XCTAssertEqual(result.thermal.heatExchanger.megaWatt, 3991, accuracy: tol, "thermal.heatExchanger")
    for day in 11...12 {
      let interval = DateInterval(ofDay: day, in: 2005)
      let y1 = result.massFlows(range: interval)
      let y2 = result.power(range: interval)
      let plot = TimeSeriesPlot(y1: y1, y2: y2, range: interval, style: .impulses)
      plot.y1Titles = ["solarfield", "powerblock", "storage"]
      plot.y2Titles = ["solar", "toStorage", "production", "storage", "gross", "net", "consum"]
      _ = try? plot(toFile: ".plots/Day_\(day)_Winter")
    }
  }
}

