import XCTest
import Utilities
@testable import BlackBoxModel

class BESSTests: XCTestCase {

  func testStoreAndRetrieveEnergy() {
    var bess = BESS()
    BESS.capacity = 10000 // Set capacity to 10000 Wh
    BESS.efficiency = Ratio(0.95) // Set efficiency to 95%

    // Test storing and retrieving energy
    let energyToStore: Double = 5000
    let energyDumped = bess.store(energy: energyToStore)

    XCTAssertEqual(energyDumped, 0)
    // Check that energy is stored correctly
    XCTAssertEqual(bess.energy, energyToStore * 0.95)

    // Test retrieving energy
    let energyToRetrieve: Double = 3000
    let retrievedEnergy = bess.retrieve(energy: energyToRetrieve)

    // Check that the retrieved energy matches the requested energy
    XCTAssertEqual(retrievedEnergy, energyToRetrieve)

    // Check that the remaining energy in the system is correct after retrieval
    XCTAssertEqual(bess.energy, energyToStore * 0.95 - energyToRetrieve)

    // Try to retrieve more energy than available
    let excessiveEnergyToRetrieve: Double = 3000
    let energyStored = bess.energy
    let excessiveRetrievedEnergy = bess.retrieve(energy: excessiveEnergyToRetrieve)

    // Check that the retrieved energy is capped at the available energy
    XCTAssertEqual(0, bess.energy)
    XCTAssertEqual(energyStored, excessiveRetrievedEnergy)
    // Check that the remaining energy in the system is zero after retrieval of all energy
    XCTAssertEqual(bess.energy, 0)
  }


  func testStoreEnergyWithPowerAndTime() {
    var bess = BESS()
    BESS.capacity = 10000 // Set capacity to 10000 Wh
    BESS.efficiency = Ratio(0.95) // Set efficiency to 95%

    // Test storing energy with power and time
    let powerToStore: Double = 1000 // 1000 W
    let timeSpan: TimeInterval = 3600 // 1 hour

    let energyToStore = powerToStore * (timeSpan / 3600) // 1 hour is equivalent to 3600 seconds
    let energyDumped = bess.store(power: powerToStore, span: timeSpan)

    // Check that energy is stored correctly
    XCTAssertEqual(bess.energy, energyToStore * 0.95)

    // Check that the dumped energy is 0, as no energy exceeds the capacity
    XCTAssertEqual(energyDumped, 0)
  }
}
