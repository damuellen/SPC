import XCTest

@testable import BlackBoxModel

class DryCoolingTests: XCTestCase {
  func testsDryCooling() {
  /*  let (DCFactor, maxDCLoad) = DryCooling.perform(
      steamTurbineLoad: 1, temperature: Temperature(celsius: 30.0)
    )
    XCTAssertEqual(DCFactor.ratio, 0, accuracy: 0.01)
    XCTAssertEqual(maxDCLoad.ratio, 0, accuracy: 0.01)*/
  }

  static var allTests: [(String, (DryCoolingTests) -> () throws -> Void)] {
    return [
      ("testsDryCooling", testsDryCooling),
    ]
  }
}
