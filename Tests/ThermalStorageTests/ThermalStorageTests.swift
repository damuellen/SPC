import XCTest

@testable import ThermalStorage

class ThermalStorageTests: XCTestCase {
  func testsCalculation() {
    let tol = 0.1


    XCTAssertEqual(1, 1, accuracy: tol)

  }
}
