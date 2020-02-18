import XCTest

@testable import BlackBoxModel
@testable import Meteo

class BlackBoxModelTests: XCTestCase {
  func testsSummer() {
    let df = DateFormatter()
    df.timeZone = TimeZone(secondsFromGMT: 0)
    df.dateFormat = "dd.MM.yyyy"
    Simulation.time.firstDateOfOperation = df.date(from: "02.07.2005")!
    Simulation.time.lastDateOfOperation = df.date(from: "03.07.2005")!
    let location = Position(longitude: 47.73, latitude: 29, elevation: 0)
    BlackBoxModel.configure(location: location, year: 2005, timeZone: 2)
    let log = PerformanceDataRecorder(mode: .none)
    let result = BlackBoxModel.runModel(with: log)

    XCTAssertEqual(result.electric.net, 250.3, accuracy: 0.1)
    XCTAssertEqual(result.electric.consum, 27.7, accuracy: 0.1)
    XCTAssertEqual(result.electric.parasitics, 83.4, accuracy: 0.1)
    XCTAssertEqual(result.electric.steamTurbineGross, 305.9, accuracy: 0.1)
    XCTAssertEqual(result.thermal.solar.megaWatt, 2314.4, accuracy: 0.1)
    XCTAssertEqual(result.thermal.startUp.megaWatt, 242.7, accuracy: 0.1)
    XCTAssertEqual(result.thermal.production.megaWatt, 1816.6, accuracy: 0.1)
    XCTAssertEqual(result.thermal.heatExchanger.megaWatt, 2079.4, accuracy: 0.1)
  }
  
  func testsWinter() {
    let df = DateFormatter()
    df.timeZone = TimeZone(secondsFromGMT: 0)
    df.dateFormat = "dd.MM.yyyy"
    Simulation.time.firstDateOfOperation = df.date(from: "02.01.2005")!
    Simulation.time.lastDateOfOperation = df.date(from: "03.01.2005")!
    let location = Position(longitude: 47.73, latitude: 29, elevation: 0)
    BlackBoxModel.configure(location: location, year: 2005, timeZone: 2)
    let log = PerformanceDataRecorder(mode: .none)
    let result = BlackBoxModel.runModel(with: log)
    
    XCTAssertEqual(result.electric.net, 111.5, accuracy: 0.1)
    XCTAssertEqual(result.electric.consum, 33.5, accuracy: 0.1)
    XCTAssertEqual(result.electric.parasitics, 55.7, accuracy: 0.1)
    XCTAssertEqual(result.electric.steamTurbineGross, 133.7, accuracy: 0.1)
    XCTAssertEqual(result.thermal.solar.megaWatt, 1185.2, accuracy: 0.1)
    XCTAssertEqual(result.thermal.startUp.megaWatt, 243.5, accuracy: 0.1)
    XCTAssertEqual(result.thermal.production.megaWatt, 793.8, accuracy: 0.1)
    XCTAssertEqual(result.thermal.heatExchanger.megaWatt, 1063.0, accuracy: 0.1)
  }

  static var allTests: [(String, (BlackBoxModelTests) -> () throws -> Void)] {
    return [
      ("testsSummer", testsSummer), ("testsWinter", testsWinter),
    ]
  }
}

