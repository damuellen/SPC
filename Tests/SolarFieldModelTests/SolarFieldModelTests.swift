import XCTest

@testable import SolarFieldModel
import Foundation

class SolarFieldModelTests: XCTestCase {
  func testsLayouts() {
    SolarField.createLayout(loops: 100, layout: .h)
    SolarField.designMassFlow = 666
    XCTAssertEqual(SolarField.shared.totalPressureDrop, 10.6, accuracy: 0.1)
    XCTAssertEqual(SolarField.shared.totalHeadLoss, 144.4, accuracy: 0.1)
    XCTAssertEqual(SolarField.shared.totalHeatLosses, 0.97, accuracy: 0.01)
    XCTAssertEqual(SolarField.shared.volumeHotHeaders, 213.6, accuracy: 0.1)
    XCTAssertEqual(SolarField.shared.volumeColdHeaders, 204.9, accuracy: 0.1)

    SolarField.createLayout(loops: 60, layout: .i)
    SolarField.designMassFlow = 444
    XCTAssertEqual(SolarField.shared.totalPressureDrop, 11.2, accuracy: 0.1)
    XCTAssertEqual(SolarField.shared.totalHeadLoss, 152.6, accuracy: 0.1)
    XCTAssertEqual(SolarField.shared.totalHeatLosses, 0.42, accuracy: 0.01)
    XCTAssertEqual(SolarField.shared.volumeHotHeaders, 77.9, accuracy: 0.1)
    XCTAssertEqual(SolarField.shared.volumeColdHeaders, 72.3, accuracy: 0.1)
  }

  static var allTests: [(String, (SolarFieldModelTests) -> () throws -> Void)] {
    return [
      ("testsLayouts", testsLayouts),
    ]
  }
}
