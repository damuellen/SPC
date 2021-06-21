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

    let tol = 1.0
    XCTAssertEqual(result.radiation.ico, 17608.5, accuracy: tol)
    XCTAssertEqual(result.electric.net, 1986.0, accuracy: tol)
    XCTAssertEqual(result.electric.consum, 19.9, accuracy: tol)
    XCTAssertEqual(result.electric.parasitics, 141.7, accuracy: tol)
    XCTAssertEqual(result.electric.steamTurbineGross, 2106.4, accuracy: tol)
    XCTAssertEqual(result.thermal.solar.megaWatt, 5234.5, accuracy: tol)
   // XCTAssertEqual(result.thermal.startUp.megaWatt, 242.7, accuracy: tol)
    XCTAssertEqual(result.thermal.production.megaWatt, 5135.5, accuracy: tol)
    XCTAssertEqual(result.thermal.heatExchanger.megaWatt, 5169.8, accuracy: tol)
    if false {
      let interval = DateInterval(ofDay: 192, in: 2005)
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
    let tol = 1.0
    XCTAssertEqual(result.radiation.ico, 7771.7, accuracy: tol)
    XCTAssertEqual(result.electric.net, 730.1, accuracy: tol)
    XCTAssertEqual(result.electric.consum, 35.1, accuracy: tol)
    XCTAssertEqual(result.electric.parasitics, 68.8, accuracy: tol)
    XCTAssertEqual(result.electric.steamTurbineGross, 763.8, accuracy: tol)
    XCTAssertEqual(result.thermal.solar.megaWatt, 1928.7, accuracy: tol)
    //XCTAssertEqual(result.thermal.startUp.megaWatt, 243.5, accuracy: tol)
    XCTAssertEqual(result.thermal.production.megaWatt, 1864.4, accuracy: tol)
    XCTAssertEqual(result.thermal.heatExchanger.megaWatt, 1924.9, accuracy: tol)
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

