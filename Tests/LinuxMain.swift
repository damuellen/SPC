@testable import BlackBoxModelTests
@testable import SolarFieldModelTests
@testable import MeteoTests
import XCTest

XCTMain([
  testCase(MeteoTests.allTests),
 //testCase(BlackBoxModelTests.allTests),
  testCase(BoilerTests.allTests),
  testCase(CollectorTests.allTests),
 // testCase(DryCoolingTests.allTests),
  testCase(HCETests.allTests),
  testCase(HeaterTests.allTests),
  testCase(HeatExchangersTests.allTests),
  testCase(HeatTransferFluidTests.allTests),
  testCase(PlantTests.allTests),
  testCase(PowerBlockTests.allTests),
 // testCase(SolarFieldTests.allTests),
  testCase(SteamTurbineTests.allTests),
 // testCase(StorageTests.allTests),
  testCase(WasteHeatRecoveryTests.allTests),
  testCase(SolarFieldModelTests.allTests),
])
