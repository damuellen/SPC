@testable import CalculationTests
@testable import ModelsTests
import XCTest

XCTMain([
  testCase(ModelsTests.allTests),
  testCase(CalculationTests.allTests),
])
