import XCTest

@testable import BlackBoxModel

class DryCoolingTests: XCTestCase {
  func testsDryCooling() {
  /*  let (DCFactor, maxDCLoad) = DryCooling.perform(
      steamTurbineLoad: 1, temperature: Temperature(celsius: 30.0)
    )
    XCTAssertEqual(DCFactor.quotient, 0, accuracy: 0.01)
    XCTAssertEqual(maxDCLoad.quotient, 0, accuracy: 0.01)*/
  }

  static var allTests: [(String, (DryCoolingTests) -> () throws -> Void)] {
    return [
      ("testsDryCooling", testsDryCooling),
    ]
  }
}
