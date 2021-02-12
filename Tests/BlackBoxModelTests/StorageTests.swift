import XCTest

@testable import BlackBoxModel

class StorageTests: XCTestCase {
  func testsParasitics() {
    var storage = Plant.initialState.storage
    var powerBlock = Plant.initialState.powerBlock
    var solarField = Plant.initialState.solarField
    var steamTurbine = Plant.initialState.steamTurbine
    var heater = Plant.initialState.heater
    let parasitics = Storage.parasitics(storage)
    let fuel = 0.0
    var plant = Plant.setup()

    let demand = SteamTurbine.parameter.power.max

    plant.heatFlow.demand.megaWatt = min(
      (demand / 0.39),
        HeatExchanger.parameter.heatFlowHTF)

    plant.heatFlow = Storage.demandStrategy(
      storage: storage, powerBlock: &powerBlock, heatFlow: plant.heatFlow
    )
    
    let energy = Storage.perform(
      storage: &storage,
      solarField: &solarField,
      steamTurbine: &steamTurbine,
      powerBlock: &powerBlock,
      heatFlow: &plant.heatFlow
    )

    XCTAssertEqual(parasitics.kiloWatt, 0.0, accuracy: 0.01)
 //   storage.operationMode = .discharge
 //   storage.massFlow.rate = 200.0
 //   storage.temperature.outlet = Temperature(celsius: 380.0)
    var thermal = storage.massFlow.rate * storage.heat / 1_000

    storage.calculate(thermal: &plant.heatFlow, powerBlock)

    storage.operationMode = .charge(load: 1.0)
    thermal = storage.massFlow.rate
      * SolarField.parameter.HTF.heatContent(storage) / 1_000
    storage.calculate(thermal: &plant.heatFlow, powerBlock)
  }

  static var allTests: [(String, (StorageTests) -> () throws -> Void)] {
    return [
      ("testsParasitics", testsParasitics),
    ]
  }
}
