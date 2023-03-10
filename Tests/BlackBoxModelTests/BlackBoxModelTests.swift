import XCTest

@testable import BlackBoxModel
@testable import Meteo
@testable import SolarPosition

class BlackBoxModelTests: XCTestCase {
  let df = DateFormatter()

  override func setUp() {
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
    let result = BlackBoxModel.runModel(with: log)
    let tol = 1.0
    XCTAssertEqual(result.electric.net, 2146, accuracy: tol, "electric.net")
    XCTAssertEqual(result.electric.consum, 21, accuracy: tol, "electric.consum")
    XCTAssertEqual(result.electric.parasitics, 156, accuracy: tol, "electric.parasitics")
    XCTAssertEqual(result.electric.steamTurbineGross, 2282, accuracy: tol, "electric.steamTurbineGross")
    XCTAssertEqual(result.thermal.solar.megaWatt, 5728, accuracy: tol, "thermal.solar")
    XCTAssertEqual(result.thermal.startUp.megaWatt, 91, accuracy: tol, "thermal.startUp")
    XCTAssertEqual(result.thermal.production.megaWatt, 5580, accuracy: tol, "thermal.production")
    XCTAssertEqual(result.thermal.heatExchanger.megaWatt, 5607.702011693181, accuracy: tol, "thermal.heatExchanger")
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

    let result = BlackBoxModel.runModel(with: log)
    let tol = 1.0
    XCTAssertEqual(result.electric.net, 1224, accuracy: tol, "electric.net")
    XCTAssertEqual(result.electric.consum, 38, accuracy: tol, "electric.consum")
    XCTAssertEqual(result.electric.parasitics, 105, accuracy: tol, "electric.parasitics")
    XCTAssertEqual(result.electric.steamTurbineGross, 1291, accuracy: tol, "electric.steamTurbineGross")
    XCTAssertEqual(result.thermal.solar.megaWatt, 3277, accuracy: tol, "thermal.solar")
    XCTAssertEqual(result.thermal.startUp.megaWatt, 94, accuracy: tol, "thermal.startUp")
    XCTAssertEqual(result.thermal.production.megaWatt, 3167, accuracy: tol, "thermal.production")
    XCTAssertEqual(result.thermal.heatExchanger.megaWatt, 3207, accuracy: tol, "thermal.heatExchanger")
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

