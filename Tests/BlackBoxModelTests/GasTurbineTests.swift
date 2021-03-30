import XCTest

@testable import BlackBoxModel

class GasTurbineTests: XCTestCase {
  func testsParasitics() {
    //let steamTurbine = Plant.initialState.steamTurbine
    let parasitics = GasTurbine.parasitics(estimateFrom: Ratio(1))
    XCTAssertEqual(parasitics, 467.5, accuracy: 0.01)
    let maxLoad = GasTurbine.maxLoad(at: Temperature(celsius: 40.0))
    XCTAssertEqual(maxLoad, 694420911682.47, accuracy: 0.01)
  }
}
