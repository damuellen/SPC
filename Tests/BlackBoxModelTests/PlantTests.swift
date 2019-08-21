import XCTest

@testable import BlackBoxModel

class PlantTests: XCTestCase {
  func testsPlant() {
    let df = DateFormatter()
    df.timeZone = TimeZone(secondsFromGMT: 0)
    df.dateFormat = "dd.MM.yyyy"
    Simulation.time.firstDateOfOperation = df.date(from: "02.07.2005")!
    Simulation.time.lastDateOfOperation = df.date(from: "03.07.2005")!
    
    Plant.setupComponentParameters()
    
    var status = Plant.initialState
    let ambientTemperature = Temperature(celsius: 20.0)
    
    status.solarField.inletTemperature(outlet: status.powerBlock)
    
    Plant.refresh(solarField: &status.solarField, status.storage)
    XCTAssertEqual(status.solarField.massFlow.rate, 854.82, accuracy: 0.1)
    Plant.refresh(solarField: &status.solarField, status.collector,
                  ambientTemperature)
    XCTAssertEqual(status.solarField.outletTemperature, 467.13, accuracy: 0.1)
    Plant.refresh(powerBlock: &status.powerBlock,
                  solarField: &status.solarField, status.collector,
                  storage: &status.storage,
                  heater: &status.heater,
                  heatExchanger: &status.heatExchanger,
                  boiler: &status.boiler,
                  gasTurbine: &status.gasTurbine,
                  steamTurbine: &status.steamTurbine,
                  ambientTemperature)

    Plant.refresh(storage: &status.storage, powerBlock: &status.powerBlock,
                  status.steamTurbine)
  }
  
  
  static var allTests: [(String, (PlantTests) -> () throws -> Void)] {
    return [
      ("testsPlant", testsPlant)
    ]
  }
}
