import XCTest

import DateGenerator
import Foundation
import SolarPosition
@testable import Meteo

class MeteoTests: XCTestCase {
  func testsGenerator() {
    let location = Position(longitude: 47, latitude: 29, elevation: 0)
    let sun = SolarPosition(position: (47, 29, 0), year: 2017,
                            timezone: 4, frequence: .every5minutes)
    
    let dg = DateGenerator(year: 2017, interval: .every5minutes)
    
    let mds = MeteoDataSource.generatedFrom(sun)
    
    let valuesDay: [(dni: Float, temp: Float, ws: Float)] = [
      (0,23.3,7.3), (0,23.3,6.3), (0,23.5,5.9), (0,23.4,4.3),
      (0,23.6,6.0), (0,23.6,8.0), (0,23.3,8.1), (0,23.2,7.6),
      (0,23.1,6.5), (0,22.9,4.8), (0,22.7,7.2), (0,22.5,6.3),
      (0,22.3,6.6), (0,22.3,6.0), (0,22.2,5.6), (0,22.0,4.4),
      (0,21.9,4.7), (0,22.0,5.4), (0,22.2,5.6), (0,22.0,4.2),
      (0,21.8,5.0), (0,21.6,6.3), (0,21.4,6.7), (0,21.6,8.0),
      (0,21.5,9.8), (0,21.6,12.4), (0,21.6,11.5), (0,21.6,10.8),
      (0,21.7,10.4), (0,21.8,8.7), (0,21.6,6.8), (0,21.3,5.9),
      (0,21.2,6.0), (0,21.2,5.9), (0,21.5,7.5), (0,21.5,8.1),
      (0,21.6,9.4), (0,21.5,9.8), (0,21.6,11.5), (0,21.7,10.6),
      (0,21.7,9.9), (0,21.7,8.8), (34,21.8,10.1), (377,22.1,9.2),
      (548,22.9,9.8), (516,23.1,10.8), (613,23.4,11.7), (641,23.5,13.8),
      (653,23.6,15.0), (668,23.8,14.7), (700,24.0,14.8), (721,24.0,15.6),
      (730,24.1,15.3), (753,24.2,15.5), (771,24.3,15.9), (775,24.5,15.5),
      (791,24.7,15.1), (811,24.9,15.0), (820,25.3,14.8), (835,25.4,14.0),
      (847,25.7,13.5), (851,25.9,12.8), (862,26.0,12.0), (869,26.0,11.6),
      (872,26.3,11.5), (871,26.8,10.6), (870,26.9,11.0), (869,27.1,10.5),
      (869,26.7,11.8), (863,26.9,10.6), (868,27.1,10.6), (867,27.5,10.1),
      (863,28.1,11.2), (693,27.4,9.3), (724,27.8,9.5), (514,27.9,10.5),
      (300,28.2,9.9), (73,27.8,8.4), (0,27.2,8.4), (0,27.1,7.9),
      (79,27.3,6.2), (198,27.2,6.3), (315,28.2,6.0), (188,28.1,9.5),
      (148,27.4,11.6), (0,26.8,11.1), (163,27.0,10.4), (294,27.0,10.0),
      (397,26.8,9.9), (792,27.4,11.7), (137,27.1,9.2), (64,26.1,8.0),
      (61,26.1,8.3), (411,26.2,8.3), (459,25.9,9.3), (669,26.3,7.1),
      (378,26.7,7.8), (355,25.8,6.1), (509,26.6,6.4), (453,26.7,8.7),
      (7,25.8,7.8), (0,25.3,6.8), (47,25.2,5.6), (296,25.7,6.1),
      (420,25.9,7.0), (463,26.0,7.4), (392,26.0,6.8), (377,26.0,7.2),
      (330,25.9,7.4), (125,25.6,6.7), (0,25.0,7.2), (0,24.8,6.8),
      (0,24.6,6.8), (0,24.4,7.3), (0,24.2,7.3), (0,23.6,8.6),
      (0,23.3,8.6), (0,23.2,8.8), (0,23.1,8.2), (0,23.2,8.6),
      (0,22.7,12.1), (0,22.4,11.6), (0,22.3,11.2), (0,22.2,10.0),
      (0,22.0,10.1), (0,21.9,10.1), (0,21.6,9.5), (0,21.4,10.8),
      (0,21.3,10.4), (0,21.3,9.2), (0,21.3,7.6), (0,21.3,6.5),
      (0,21.2,5.6), (0,21.2,5.6), (0,21.0,4.7), (0,20.7,5.3),
      (0,20.8,6.7), (0,20.7,6.3), (0,20.4,4.9), (0,19.9,3.9),
      (0,19.7,4.0), (0,19.6,4.0), (0,19.5,4.2), (0,19.3,4.5)
    ]
    
    let meteoDataDay = valuesDay.map { return MeteoData(
      dni: $0.dni, ghi: 0, dhi: 0, temperature: $0.temp, windSpeed: $0.ws)
    }

    let meteoData = Array(repeatElement(meteoDataDay, count: 365).joined())

    let datasource = MeteoDataSource(
      name: "", data: meteoData, location: location,year: 2017, timeZone: 8
    )

    let generatorA = MeteoDataGenerator(datasource, frequence: .every5minutes)

    let range = DateGenerator.dateInterval(day: 1, year: 2017)
    generatorA.setRange(range)

    var counter = -1
    var idx = 0
    
    for meteo in generatorA {
      if counter % 2 != 0 {
        XCTAssertEqual(meteo.dni, valuesDay[idx].dni, accuracy: 0.01)
        idx += 1
        if idx == valuesDay.endIndex { idx = 0 }
      }
      counter += 1
    }
    
    let generatorB = MeteoDataGenerator(datasource, frequence: .every10minutes)

    generatorB.setRange(range)

    idx = 0
    
    for meteo in generatorB {
      XCTAssertEqual(meteo.dni, valuesDay[idx].dni, accuracy: 0.01)
      idx += 1
    }
  }

  static var allTests: [(String, (MeteoTests) -> () throws -> Void)] {
    return [
      ("testsGenerator", testsGenerator),
    ]
  }
}
