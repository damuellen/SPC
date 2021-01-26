import XCTest

@testable import BlackBoxModel

class StorageTests: XCTestCase {
  func testsParasitics() {
    var storage = Plant.initialState.storage
    var powerBlock = Plant.initialState.powerBlock
    var solarField = Plant.initialState.solarField
    var steamTurbine = Plant.initialState.steamTurbine
    var heater = Plant.initialState.heater
    let parasitics = Storage.parasitics(&storage)
    let fuel = 0.0
    var plant = Plant.setup()

    let demand = SteamTurbine.parameter.power.max

    plant.heat.demand.megaWatt = min(
      (demand / 0.39),
        HeatExchanger.parameter.sccHTFheat)

    plant.heat.demand.megaWatt = Storage.demandStrategy(
      storage: &storage, powerBlock: &powerBlock,
      demand: plant.heat.demand, production: Power(megaWatt: 300)
    )

    let energy = Storage.perform(
      storage: &storage,
      solarField: &solarField,
      steamTurbine: &steamTurbine,
      powerBlock: &powerBlock,
      heat: &plant.heat
    )

    XCTAssertEqual(parasitics, 0, accuracy: 0.01)
 //   storage.operationMode = .discharge
 //   storage.massFlow.rate = 200.0
 //   storage.temperature.outlet = Temperature(celsius: 380.0)
    var thermal = storage.massFlow.rate * storage.deltaHeat / 1_000

    storage.calculate(thermal: &thermal, powerBlock)

    storage.operationMode = .charging
    thermal = storage.massFlow.rate
      * SolarField.parameter.HTF.deltaHeat(storage) / 1_000
    storage.calculate(thermal: &thermal, powerBlock)
  }

  static var allTests: [(String, (StorageTests) -> () throws -> Void)] {
    return [
      ("testsParasitics", testsParasitics),
    ]
  }
}
