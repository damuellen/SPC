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
      XCTAssertEqual(result.electric.net, 1139.7, accuracy: 0.1)
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
    XCTAssertEqual(result.electric.net, 585.4, accuracy: tol)
    XCTAssertEqual(result.electric.consum, 41.7, accuracy: tol)
    XCTAssertEqual(result.electric.parasitics, 167.1, accuracy: tol)
    XCTAssertEqual(result.electric.steamTurbineGross, 710.9, accuracy: tol)
    XCTAssertEqual(result.thermal.solar.megaWatt, 4206.9, accuracy: tol)
   // XCTAssertEqual(result.thermal.startUp.megaWatt, 242.7, accuracy: tol)
    XCTAssertEqual(result.thermal.production.megaWatt, 4107.6, accuracy: tol)
    XCTAssertEqual(result.thermal.heatExchanger.megaWatt, 4203.2, accuracy: tol)
    
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
    XCTAssertEqual(result.electric.net, 338.2, accuracy: tol)
    XCTAssertEqual(result.electric.consum, 53.9, accuracy: tol)
    XCTAssertEqual(result.electric.parasitics, 111.5, accuracy: tol)
    XCTAssertEqual(result.electric.steamTurbineGross, 395.8, accuracy: tol)
    XCTAssertEqual(result.thermal.solar.megaWatt, 2378.3, accuracy: tol)
    //XCTAssertEqual(result.thermal.startUp.megaWatt, 243.5, accuracy: tol)
    XCTAssertEqual(result.thermal.production.megaWatt, 2287.0, accuracy: tol)
    XCTAssertEqual(result.thermal.heatExchanger.megaWatt, 2374.1, accuracy: tol)
  }

  static var allTests: [(String, (BlackBoxModelTests) -> () throws -> Void)] {
    return [
      ("testsPerformance", testsPerformance),
      ("testsSummer", testsSummer),
      ("testsWinter", testsWinter),      
    ]
  }
}

