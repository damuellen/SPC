import XCTest
@testable import ModelsTests
@testable import CalculationTests

XCTMain([
  testCase(ModelsTests.allTests),
  testCase(CalculationTests.allTests),
])
