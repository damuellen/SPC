import XCTest

@testable import BlackBoxModel
import Utilities

class HeatTransferFluidTests: XCTestCase {
  func testsTherminolDensiy() {
    let accuracy = 0.5
    XCTAssertEqual(HeatTransferFluid.VP1.density(373.15), 1001, accuracy: accuracy, "VP1 density @100degC")
    XCTAssertEqual(HeatTransferFluid.VP1.density(523.15), 866, accuracy: accuracy, "VP1 densit @250degC")
    XCTAssertEqual(HeatTransferFluid.VP1.density(566.15), 822, accuracy: accuracy, "VP1 density @293degC")
    XCTAssertEqual(HeatTransferFluid.VP1.density(623.15), 759, accuracy: accuracy, "VP1 density @350degC")
    XCTAssertEqual(HeatTransferFluid.VP1.density(666.15), 710, accuracy: accuracy, "VP1 density @393degC")
  }

  func testsHelisolDensiy() {
    let accuracy = 0.5
    XCTAssertEqual(HeatTransferFluid.XLP.density(373.15), 874, accuracy: accuracy, "XLP density @100degC")
    XCTAssertEqual(HeatTransferFluid.XLP.density(523.15), 711, accuracy: accuracy, "XLP density @250degC")
    XCTAssertEqual(HeatTransferFluid.XLP.density(566.15), 651, accuracy: accuracy, "XLP density @293degC")
    XCTAssertEqual(HeatTransferFluid.XLP.density(623.15), 552, accuracy: accuracy, "XLP density @350degC")
    XCTAssertEqual(HeatTransferFluid.XLP.density(666.15), 456, accuracy: accuracy, "XLP density @393degC")
    XCTAssertEqual(HeatTransferFluid.XLP.density(688.15), 399, accuracy: accuracy, "XLP density @415degC")
  }
}
