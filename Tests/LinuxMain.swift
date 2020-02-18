@testable import BlackBoxModelTests
@testable import MeteoTests
import XCTest

XCTMain([
  testCase(MeteoTests.allTests),
  testCase(BlackBoxModelTests.allTests),
])
