import XCTest

@testable import BlackBoxModel

class WasteHeatRecoveryTests: XCTestCase {
  func testsEfficiency() {    
   // let efficiency = WasteHeatRecovery.efficiencyFor(gasTurbineLoad: Ratio(1))
   // XCTAssertEqual(efficiency, 0.399, accuracy: 0.01)
  }

  static var allTests: [(String, (WasteHeatRecoveryTests) -> () throws -> Void)] {
    return [
      ("testsEfficiency", testsEfficiency),
    ]
  }
}
