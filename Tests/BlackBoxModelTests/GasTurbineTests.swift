import XCTest

@testable import BlackBoxModel

class GasTurbineTests: XCTestCase {
  func testsParasitics() {
    //let steamTurbine = Plant.initialState.steamTurbine
    let parasitics = GasTurbine.parasitics(estimateFrom: Ratio(1))
    XCTAssertEqual(parasitics, 0, accuracy: 0.01)
    let maxLoad = GasTurbine.maxLoad(at: Temperature(celsius: 40.0))
    XCTAssertEqual(maxLoad, 0, accuracy: 0.01)
  }

  static var allTests: [(String, (GasTurbineTests) -> () throws -> Void)] {
    return [
      ("testsParasitics", testsParasitics),
    ]
  }
}
