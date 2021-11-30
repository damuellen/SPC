import XCTest

@testable import BlackBoxModel
@testable import Meteo

class BlackBoxModelTests: XCTestCase {
  let df = DateFormatter()

  override func setUp() {
    df.timeZone = TimeZone(secondsFromGMT: 0)
    df.dateFormat = "dd.MM.yyyy"
  }

  func testsSummer() {
    Simulation.time.firstDateOfOperation = df.date(from: "11.07.2005")!
    Simulation.time.lastDateOfOperation = df.date(from: "13.07.2005")!
    var location = Location(longitude: 47.73, latitude: 29, elevation: 0, timezone: 2)
    location.timezone = 2

    BlackBoxModel.configure(year: 2005)
    BlackBoxModel.configure(location: location)
    let log = Recorder(mode: .inMemory)
    let result = BlackBoxModel.runModel(with: log)
    let tol = 0.2
    XCTAssertEqual(result.radiation.ico, 17233.7, accuracy: tol)
    XCTAssertEqual(result.electric.net, 1994.4, accuracy: tol)
    XCTAssertEqual(result.electric.consum, 19.9, accuracy: tol)
    XCTAssertEqual(result.electric.parasitics, 140.2, accuracy: tol)
    XCTAssertEqual(result.electric.steamTurbineGross, 2114.6, accuracy: tol)
    XCTAssertEqual(result.thermal.solar.megaWatt, 5260.2, accuracy: tol)
   // XCTAssertEqual(result.thermal.startUp.megaWatt, 242.7, accuracy: tol)
    XCTAssertEqual(result.thermal.production.megaWatt, 5165.1, accuracy: tol)
    XCTAssertEqual(result.thermal.heatExchanger.megaWatt, 5192.7, accuracy: tol)
    if false {
      let interval = DateInterval(ofDay: 192, in: 2005)
      let y1 = result.massFlows(range: interval)
      let y2 = result.power(range: interval)
      let plot = TimeSeriesPlot(y1: y1, y2: y2, range: interval, style: .impulses)
      plot.y1Titles = ["solarfield", "powerblock", "storage"]
      plot.y2Titles = ["solar", "toStorage", "production", "storage", "gross", "net", "consum"]
      try! plot(toFile: "PowerSummer3")
    }
    if false {
      let interval = DateInterval(ofDay: 193, in: 2005)
      let y1 = result.massFlows(range: interval)
      let y2 = result.power(range: interval)
      let plot = TimeSeriesPlot(y1: y1, y2: y2, range: interval, style: .impulses)
      plot.y1Titles = ["solarfield", "powerblock", "storage"]
      plot.y2Titles = ["solar", "toStorage", "production", "storage", "gross", "net", "consum"]
      try! plot(toFile: "PowerSummer")
    }
  }

  func testsWinter() {
    Simulation.time.firstDateOfOperation = df.date(from: "11.01.2005")!
    Simulation.time.lastDateOfOperation = df.date(from: "13.01.2005")!
    var location = Location(longitude: 47.73, latitude: 29, elevation: 0, timezone: 2)
    location.timezone = 2
    BlackBoxModel.configure(year: 2005)
    BlackBoxModel.configure(location: location)

    let log = Recorder(mode: .inMemory)

    let result = BlackBoxModel.runModel(with: log)
    let tol = 0.2
    XCTAssertEqual(result.radiation.ico, 8089.1, accuracy: tol)
    XCTAssertEqual(result.electric.net, 772.5, accuracy: tol)
    XCTAssertEqual(result.electric.consum, 34.7, accuracy: tol)
    XCTAssertEqual(result.electric.parasitics, 70.1, accuracy: tol)
    XCTAssertEqual(result.electric.steamTurbineGross, 807.8, accuracy: tol)
    XCTAssertEqual(result.thermal.solar.megaWatt, 2041.4, accuracy: tol)
    //XCTAssertEqual(result.thermal.startUp.megaWatt, 243.5, accuracy: tol)
    XCTAssertEqual(result.thermal.production.megaWatt, 1999.5, accuracy: tol)
    XCTAssertEqual(result.thermal.heatExchanger.megaWatt, 2036.9, accuracy: tol)
    if false {
      let interval = DateInterval(ofDay: 11, in: 2005)
      let y1 = result.massFlows(range: interval)
      let y2 = result.power(range: interval)
      let plot = TimeSeriesPlot(y1: y1, y2: y2, range: interval, style: .impulses)
      plot.y1Titles = ["solarfield", "powerblock", "storage"]
      plot.y2Titles = ["solar", "toStorage", "production", "storage", "gross", "net", "consum"]
      try! plot(toFile: "PowerWinter")
    }
  }
}

