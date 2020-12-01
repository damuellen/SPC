import XCTest

@testable import BlackBoxModel
@testable import Meteo

class BlackBoxModelTests: XCTestCase {
  func testsPerformance() {
     
    let df = DateFormatter()
    df.timeZone = TimeZone(secondsFromGMT: 0)
    df.dateFormat = "dd.MM.yyyy"
    Simulation.time.firstDateOfOperation = df.date(from: "29.07.2005")!
    Simulation.time.lastDateOfOperation = df.date(from: "02.08.2005")!
    var location = Location(longitude: 47.73, latitude: 29, elevation: 0)
    location.timezone = 2

    BlackBoxModel.configure(year: 2005)
    BlackBoxModel.configure(location: location)
    measure {
      let log = PerformanceDataRecorder()
      let result = BlackBoxModel.runModel(with: log)
      XCTAssertEqual(result.electric.net, 1070, accuracy: 0.1)
    }
  }

  func testsSummer() {     
    let df = DateFormatter()
    df.timeZone = TimeZone(secondsFromGMT: 0)
    df.dateFormat = "dd.MM.yyyy"
    Simulation.time.firstDateOfOperation = df.date(from: "02.07.2005")!
    Simulation.time.lastDateOfOperation = df.date(from: "04.07.2005")!
    var location = Location(longitude: 47.73, latitude: 29, elevation: 0)
    location.timezone = 2

    BlackBoxModel.configure(year: 2005)
    BlackBoxModel.configure(location: location)
  
    let log = PerformanceDataRecorder()

    let result = BlackBoxModel.runModel(with: log)

    let tol = 0.2
    XCTAssertEqual(result.electric.net, 533.2, accuracy: tol)
    XCTAssertEqual(result.electric.consum, 48.2, accuracy: tol)
    XCTAssertEqual(result.electric.parasitics, 167.1, accuracy: tol)
    XCTAssertEqual(result.electric.steamTurbineGross, 652.1, accuracy: tol)
    XCTAssertEqual(result.thermal.solar.megaWatt, 4632.5, accuracy: tol)
   // XCTAssertEqual(result.thermal.startUp.megaWatt, 242.7, accuracy: tol)
    XCTAssertEqual(result.thermal.production.megaWatt, 3871.8, accuracy: tol)
    XCTAssertEqual(result.thermal.heatExchanger.megaWatt, 4164.4, accuracy: tol)
    
  }
  
  func testsWinter() {
    let df = DateFormatter()
    df.timeZone = TimeZone(secondsFromGMT: 0)
    df.dateFormat = "dd.MM.yyyy"
    Simulation.time.firstDateOfOperation = df.date(from: "02.01.2005")!
    Simulation.time.lastDateOfOperation = df.date(from: "04.01.2005")!
    var location = Location(longitude: 47.73, latitude: 29, elevation: 0)
    location.timezone = 2
    BlackBoxModel.configure(year: 2005)
    BlackBoxModel.configure(location: location)

    let log = PerformanceDataRecorder()

    let result = BlackBoxModel.runModel(with: log)
    let tol = 0.2
    XCTAssertEqual(result.electric.net, 258.7, accuracy: tol)
    XCTAssertEqual(result.electric.consum, 59.7, accuracy: tol)
    XCTAssertEqual(result.electric.parasitics, 112.6, accuracy: tol)
    XCTAssertEqual(result.electric.steamTurbineGross, 311.7, accuracy: tol)
    XCTAssertEqual(result.thermal.solar.megaWatt, 2377.2, accuracy: tol)
    //XCTAssertEqual(result.thermal.startUp.megaWatt, 243.5, accuracy: tol)
    XCTAssertEqual(result.thermal.production.megaWatt, 1850.5, accuracy: tol)
    XCTAssertEqual(result.thermal.heatExchanger.megaWatt, 2135.4, accuracy: tol)
  }

  static var allTests: [(String, (BlackBoxModelTests) -> () throws -> Void)] {
    return [
      ("testsSummer", testsSummer),
      ("testsWinter", testsWinter),
      ("testsPerformance", testsPerformance),
    ]
  }
}

