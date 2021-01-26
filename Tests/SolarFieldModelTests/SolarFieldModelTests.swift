import XCTest

@testable import SolarFieldModel
import Foundation

class SolarFieldModelTests: XCTestCase {
  func testsLayouts() {
    let h = SolarField.createLayout(loops: 100, layout: .h)
    h.massFlow = 666
    XCTAssertEqual(h.totalPressureDrop, 10.6, accuracy: 0.1)
    XCTAssertEqual(h.totalHeadLoss, 144.4, accuracy: 0.1)
    XCTAssertEqual(h.totalHeatLosses, 0.97, accuracy: 0.01)
    XCTAssertEqual(h.volumeHotHeaders, 213.6, accuracy: 0.1)
    XCTAssertEqual(h.volumeColdHeaders, 204.9, accuracy: 0.1)

    let i = SolarField.createLayout(loops: 60, layout: .i)
    i.massFlow = 444
    XCTAssertEqual(i.totalPressureDrop, 11.56, accuracy: 0.1)
    XCTAssertEqual(i.totalHeadLoss, 156.54, accuracy: 0.1)
    XCTAssertEqual(i.totalHeatLosses, 0.456, accuracy: 0.01)
    XCTAssertEqual(i.volumeHotHeaders, 86.66, accuracy: 0.1)
    XCTAssertEqual(i.volumeColdHeaders, 80.98, accuracy: 0.1)
  }

  static var allTests: [(String, (SolarFieldModelTests) -> () throws -> Void)] {
    return [
      ("testsLayouts", testsLayouts),
    ]
  }
}
