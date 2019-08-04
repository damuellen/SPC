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
    let temperature = Temperature(celsius: 20.0)
    
    status.solarField.inletTemperature(outlet: status.powerBlock)
    
    Plant.update(solarField: &status.solarField,
                 storage: status.storage)
    XCTAssertEqual(status.solarField.massFlow.rate, 854.82, accuracy: 0.1)
    
    Plant.update(solarField: &status.solarField,
                 collector: status.collector,
                 ambient: temperature)
    XCTAssertEqual(status.solarField.outletTemperature, 467.13, accuracy: 0.1)
    Plant.update(solarField: &status.solarField,
                 collector: status.collector,
                 storage: &status.storage,
                 powerBlock: &status.powerBlock,
                 boiler: &status.boiler,
                 gasTurbine: &status.gasTurbine,
                 heater: &status.heater,
                 heatExchanger: &status.heatExchanger,
                 steamTurbine: &status.steamTurbine,
                 ambient: temperature)
    
    Plant.update(storage: &status.storage,
                 powerBlock: &status.powerBlock,
                 steamTurbine: status.steamTurbine)
    
  }
  
  
  static var allTests: [(String, (PlantTests) -> () throws -> Void)] {
    return [
      ("testsPlant", testsPlant)
    ]
  }
}
