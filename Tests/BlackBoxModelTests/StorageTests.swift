import XCTest

@testable import BlackBoxModel

class StorageTests: XCTestCase {
  func testsParasitics() {
    var storage = Plant.initialState.storage
    let parasitics = Storage.parasitics(&storage)
    XCTAssertEqual(parasitics, 0, accuracy: 0.01)
    storage.operationMode = .discharge
    storage.massFlow.rate = 200.0
    storage.temperature.outlet = Temperature(celsius: 380.0)
    var thermal = storage.massFlow.rate
      * storage.deltaHeat / 1_000
   // (thermal, _) = Storage.calculate(thermal, storage: storage)
  //  XCTAssertEqual(thermal, -82.71, accuracy: 0.01, "thermal power")
    storage.operationMode = .charging
    thermal = storage.massFlow.rate
      * SolarField.parameter.HTF.deltaHeat(storage) / 1_000
 //   (thermal, _) = Storage.calculate(thermal, storage: storage)
  //  XCTAssertEqual(thermal, 82.71, accuracy: 0.01, "thermal power")
  }

  static var allTests: [(String, (StorageTests) -> () throws -> Void)] {
    return [
      ("testsParasitics", testsParasitics),
    ]
  }
}
