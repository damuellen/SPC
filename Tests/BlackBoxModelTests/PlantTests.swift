import XCTest

@testable import BlackBoxModel

class PlantTests: XCTestCase {
  func testsPlant() {
    let df = DateFormatter()
    df.timeZone = TimeZone(secondsFromGMT: 0)
    df.dateFormat = "dd.MM.yyyy"
    Simulation.time.firstDateOfOperation = df.date(from: "02.07.2005")!
    Simulation.time.lastDateOfOperation = df.date(from: "03.07.2005")!
    
    let plant = Plant.setup()
    
    var status = Plant.initialState
    let ambientTemperature = Temperature(celsius: 20.0)
    
    status.solarField.setInletTemperature(equalToOutlet: status.powerBlock)
    
  }
  
  
  static var allTests: [(String, (PlantTests) -> () throws -> Void)] {
    return [
      ("testsPlant", testsPlant)
    ]
  }
}
