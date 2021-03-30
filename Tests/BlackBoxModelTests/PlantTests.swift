import XCTest

@testable import BlackBoxModel

class PlantTests: XCTestCase {
  func testsPlant() {
    let df = DateFormatter()
    df.timeZone = TimeZone(secondsFromGMT: 0)
    df.dateFormat = "dd.MM.yyyy"
    Simulation.time.firstDateOfOperation = df.date(from: "02.07.2005")!
    Simulation.time.lastDateOfOperation = df.date(from: "03.07.2005")!

    let _ = Plant.setup()

    var _ = Plant.initialState
    let _ = Temperature(celsius: 20.0)

  //  status.solarField.setInletTemperature(equalToOutlet: status.powerBlock)

  }
}
