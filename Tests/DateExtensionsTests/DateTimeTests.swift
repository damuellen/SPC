import DateExtensions
import Foundation
import Meteo
import SolarPosition
import Utilities
import XCTest

class DateTimeTests: XCTestCase {
  func testsConstructor() {
   let d1 = Date(timeIntervalSinceReferenceDate: 504882000) 
   let dt1 = DateTime(d1)
   XCTAssert(dt1.date == d1) 
  }
}