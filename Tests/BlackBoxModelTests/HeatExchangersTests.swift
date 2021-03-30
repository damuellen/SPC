import XCTest

@testable import BlackBoxModel

class HeatExchangersTests: XCTestCase {
  func testsTemperatureFactor() {
    let factor = HeatExchanger.temperatureFactor(
      temperature: Temperature(celsius: 300.0),
      load: Ratio(0.5),
      max: Temperature(celsius: 393.0)
    )
    XCTAssertEqual(factor, 0.88, accuracy: 0.01)
  }
}
