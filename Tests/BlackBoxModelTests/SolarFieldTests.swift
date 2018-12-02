import XCTest

@testable import BlackBoxModel
import Meteo
@testable import SolarPosition

class SolarFieldTests: XCTestCase {
  func testsOutletTemperature() {
  }

  static var allTests: [(String, (SolarFieldTests) -> () throws -> Void)] {
    return [
      ("testsOutletTemperature", testsOutletTemperature),
    ]
  }
}
