import XCTest

@testable import BlackBoxModel
@testable import Meteo
@testable import SolarPosition

class BlackBoxModelTests: XCTestCase {
  let df = DateFormatter()
  let tol = 0.6
  override func setUp() {
    _ = try? FileManager.default.createDirectory(atPath: ".plots", withIntermediateDirectories: true)
    df.timeZone = TimeZone(secondsFromGMT: 0)
    df.dateFormat = "dd.MM.yyyy"
    let location = Location((47.73, 29, 0), tz: 2)
    BlackBoxModel.configure(year: 2005)
    BlackBoxModel.configure(location: location)
  }
  func testsModel() {
    summer()
    winter()
  }

  func summer() {
    
    Simulation.time.dateInterval = .init(
      start: df.date(from: "11.07.2005")!,
      end: df.date(from: "13.07.2005")!
    )

    let log = Historian(mode: .inMemory)
    BlackBoxModel.runModel(with: log)
    let result = log.finish()

    XCTAssertEqual(result.electric.net, 2247, accuracy: tol, "electric.net")
    XCTAssertEqual(result.electric.consum, 18, accuracy: tol, "electric.consum")
    XCTAssertEqual(result.electric.parasitics, 160, accuracy: tol, "electric.parasitics")
    XCTAssertEqual(result.electric.steamTurbineGross, 2389, accuracy: tol, "electric.steamTurbineGross")
    XCTAssertEqual(result.thermal.solar.megaWatt, 5888, accuracy: tol, "thermal.solar")
    XCTAssertEqual(result.thermal.startUp.megaWatt, 5, accuracy: tol, "thermal.startUp")
    XCTAssertEqual(result.thermal.production.megaWatt, 5774, accuracy: tol, "thermal.production")
    XCTAssertEqual(result.thermal.heatExchanger.megaWatt, 5778, accuracy: tol, "thermal.heatExchanger")
    for day in 192...193 {
      let interval = DateInterval(ofDay: day, in: 2005)
      let y1 = result.massFlows(range: interval)
      let y2 = result.power(range: interval)
      let plot = TimeSeriesPlot(y1: y1, y2: y2, range: interval, style: .impulses)
      plot.y1Titles = ["solarfield", "powerblock", "storage"]
      plot.y2Titles = ["solar", "toStorage", "production", "storage", "gross", "net", "consum"]
      _ = try? plot(toFile: ".plots/Day_\(day)_Summer.png")
    }
    
  }

  func winter() {    
    Simulation.time.dateInterval = .init(
      start: df.date(from: "11.01.2005")!,
      end: df.date(from: "13.01.2005")!
    )

    let log = Historian(mode: .inMemory)
    BlackBoxModel.runModel(with: log)

    let result = log.finish()

    XCTAssertEqual(result.electric.net, 1555, accuracy: tol, "electric.net")
    XCTAssertEqual(result.electric.consum, 32, accuracy: tol, "electric.consum")
    XCTAssertEqual(result.electric.parasitics, 129, accuracy: tol, "electric.parasitics")
    XCTAssertEqual(result.electric.steamTurbineGross, 1652, accuracy: tol, "electric.steamTurbineGross")
    XCTAssertEqual(result.thermal.solar.megaWatt, 4083, accuracy: tol, "thermal.solar")
    XCTAssertEqual(result.thermal.startUp.megaWatt, 0, accuracy: tol, "thermal.startUp")
    XCTAssertEqual(result.thermal.production.megaWatt, 3991, accuracy: tol, "thermal.production")
    XCTAssertEqual(result.thermal.heatExchanger.megaWatt, 3991, accuracy: tol, "thermal.heatExchanger")
    for day in 11...12 {
      let interval = DateInterval(ofDay: day, in: 2005)
      let y1 = result.massFlows(range: interval)
      let y2 = result.power(range: interval)
      let plot = TimeSeriesPlot(y1: y1, y2: y2, range: interval, style: .impulses)
      plot.y1Titles = ["solarfield", "powerblock", "storage"]
      plot.y2Titles = ["solar", "toStorage", "production", "storage", "gross", "net", "consum"]
      _ = try? plot(toFile: ".plots/Day_\(day)_Winter.png")
    }
    
  }
}

