import XCTest

@testable import BlackBoxModel
import Units

class StorageTests: XCTestCase {
  func testsParasitics() {
    var storage = Plant.initialState.storage
    var powerBlock = Plant.initialState.powerBlock
    var solarField = Plant.initialState.solarField
    var steamTurbine = Plant.initialState.steamTurbine
    _ = Plant.initialState.heater
    let parasitics = Storage.parasitics(storage)

    var plant = Plant.setup()

    let demand = SteamTurbine.parameter.power.max

    plant.heatFlow.demand.megaWatt = min(
      (demand / 0.39),
        HeatExchanger.parameter.heatFlowHTF)

    plant.heatFlow = storage.demandStrategy(
      powerBlock: &powerBlock, heatFlow: plant.heatFlow
    )
    
    _ = Storage.perform(
      storage: &storage,
      solarField: &solarField,
      steamTurbine: &steamTurbine,
      powerBlock: &powerBlock,
      heatFlow: &plant.heatFlow
    )

    XCTAssertEqual(parasitics.kiloWatt, 2.0, accuracy: 0.01)
 //   storage.operationMode = .discharge
 //   storage.massFlow.rate = 200.0
 //   storage.temperature.outlet = Temperature(celsius: 380.0)
    _ = storage.massFlow.rate * storage.heat / 1_000

    storage.calculate(
      output: &plant.heatFlow.storage,
      input: plant.heatFlow.toStorage,
      powerBlock: powerBlock
    )

    storage.operationMode = .charge(load: 1.0)
    _ = storage.massFlow.rate
      * SolarField.parameter.HTF.heatContent(storage) / 1_000
  //  storage.calculate(thermal: &plant.heatFlow, powerBlock)
  }
}
