import XCTest

import Foundation
import DateGenerator
@testable import Meteo

class MeteoDataTests: XCTestCase {
  
  func testsGenerator() {
    let location = Location(longitude: 0, latitude: 0, elevation: 0)
    
    let valuesDay: [(dni: Float, temp: Float, ws: Float)] = [
      (0,5.5,2),(0,5,3),(0,4,3),(0,4,5),(0,4,3),(0,5,1),(100,7,3),(200,8,2),
      (400,10,1),(500,12,2.5),(600,13,1.5),(700,13,4.5),(800,15,3),(700,15,2.5),
      (500,14,2),(300,12,2),(350,10,2),(150,10,2),(0,10,3),(0,8,2),(0,7,2),
      (0,7,3),(0,6,2),(0,6,2)
    ]
    
    let meteoDataDay = valuesDay.map {
      return MeteoData(dni: $0.dni, temperature: $0.temp, windSpeed: $0.ws)
    }
    
    let meteoData = Array(repeatElement(meteoDataDay, count: 365).joined())
    
    let datasource = MeteoDataSource(
      data: meteoData, location: location, year: 2017, timeZone: 8)
    let interval: DateGenerator.Interval = .every5minutes
    let generator = MeteoDataGenerator(from: datasource, interval: interval)
    
    let range = DateGenerator.getMonth(3, year: 2017)
    generator.setRange(to: range)
    
    var counter = 0
    var idx = 0
    
    for meteo in generator {
      if counter % interval.rawValue == 0 {
        XCTAssertEqualWithAccuracy(meteo.dni, valuesDay[idx].dni, accuracy: 0.01)
        idx += 1
        if idx == valuesDay.endIndex { idx = 0 }
      }
      counter += 1
    }
    
    var dateCounter = 0
    for _ in DateGenerator(range: range, interval: .every5minutes) {
      dateCounter += 1
    }
    XCTAssert(counter == dateCounter)
  }
  
  static var allTests: [(String, (MeteoDataTests) -> () throws -> Void)] {
    return [
      ("testsGenerator", testsGenerator),
    ]
  }
}

