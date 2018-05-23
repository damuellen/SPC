import XCTest

import Meteo
@testable import SolarPosition
@testable import BlackBoxModel

class SolarFieldTests: XCTestCase {
  
  func testsOutletTemperature() {

  }
  
  static var allTests: [(String, (SolarFieldTests) -> () throws -> Void)] {
    return [
      ("testsOutletTemperature", testsOutletTemperature),
    ]
  }
}
