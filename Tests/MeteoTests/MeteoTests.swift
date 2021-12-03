import DateGenerator
import Foundation
import Meteo
import SolarPosition
import Utilities
import XCTest

class MeteoTests: XCTestCase {
  func testsGenerator() {
    let location = Location(longitude: -26, latitude: 35, elevation: 0, timezone: 2)
    if false {
      let sun = SolarPosition(coords: (-26, 35, 0), tz: 2, year: 2017, frequence: .hourly)
      let clearSky = MeteoDataProvider.using(sun, model: .special)
      clearSky.setInterval(.fiveMinutes)
      let dni = Array(clearSky.map(\.dni).prefix(24*12*4))
      try? Gnuplot(xs: dni)(.pngLarge(path: "dni.png"))
    }

    let hourly: [(dni: Double, temp: Double, ws: Double)] = [
      (0, 19.2, 3.9), (0, 18.4, 5.3), (0, 17.5, 6.2), (0, 16.9, 6), (0, 16.4, 4.6), (54, 16.7, 3.8), (309, 18.8, 3.2), (533, 22.4, 2.2), (699, 26, 2), (789, 28.7, 2.4), (845, 30.8, 3.2), (868, 32.4, 4), (874, 33.5, 4.9), (842, 34, 5.8),
      (794, 33.7, 6.3), (738, 33, 7), (669, 31.8, 7.8), (546, 30, 7.8), (347, 27.3, 6.8), (36, 24, 5.4), (0, 21.4, 4.7), (0, 20, 4.3), (0, 18.8, 3.4), (0, 17.6, 2.3),
    ]

    let goodDay: [(dni: Double, temp: Double, ws: Double)] = [
      (0.0, 23.4, 5.78), (0, 23.35, 5.78), (0, 23.3, 5.78), (0, 23.2, 5.94), (0, 23.15, 5.96), (0, 23.1, 5.99), (0, 23, 5.99), (0, 23, 5.99), (0, 23, 5.99), (0, 22.9, 5.99), (0, 22.9, 5.99), (0, 22.9, 5.99), (0, 22.9, 5.94), (30, 22.95, 5.94),
      (60, 23, 5.94), (171, 23.2, 5.04), (224, 23.25, 5.9), (278, 23.3, 5.88), (373, 23.5, 5.88), (408, 23.65, 5.8), (443, 23.8, 5.88), (504, 24.1, 5.88), (520, 24.25, 5.8), (536, 24.4, 5.88), (577, 24.8, 5.88), (597, 24.95, 5.7),
      (617, 25.1, 5.67), (653, 25.5, 5.67), (671, 25.65, 5.6), (690, 25.8, 5.62), (719, 26.1, 5.46), (731, 26.15, 5.4), (744, 26.2, 5.36), (766, 26.3, 5.30), (777, 26.35, 5.2), (789, 26.4, 5.10), (810, 26.5, 5.00), (821, 26.6, 4.98),
      (832, 26.7, 4.95), (849, 27, 4.95), (854, 27.15, 4.92), (860, 27.3, 4.90), (869, 27.5, 4.70), (876, 27.55, 4.7), (883, 27.6, 4.85), (889, 27.6, 4.85), (894, 27.6, 4.85), (900, 27.6, 4.8), (907, 27.6, 4.85), (909, 27.65, 4.8),
      (911, 27.7, 4.85), (918, 27.8, 4.85), (918, 27.85, 4.78), (919, 27.9, 4.70), (917, 28, 4.70), (918, 28, 4.70), (919, 28, 4.70), (925, 28.1, 4.65), (923, 28.1, 4.65), (922, 28.1, 4.65), (917, 28.1, 4.61), (916, 28.1, 4.68), (915, 28.1, 4.75),
      (905, 28.1, 4.70), (900, 28.1, 4.77), (895, 28.1, 4.84), (888, 28.1, 4.79), (882, 28.1, 4.86), (877, 28.1, 4.93), (869, 28.1, 4.93), (864, 28.1, 5.00), (859, 28.1, 5.07), (842, 28.1, 5.07), (833, 28.05, 5.1), (825, 28, 5.20), (807, 28, 5.20),
      (797, 28, 5.24), (787, 28, 5.28), (768, 27.9, 5.28), (756, 27.9, 5.37), (744, 27.9, 5.47), (713, 27.8, 5.60), (702, 27.8, 5.60), (692, 27.8, 5.60), (666, 27.8, 5.73), (649, 27.75, 5.7), (632, 27.7, 5.73), (599, 27.7, 5.85), (580, 27.7, 5.82),
      (561, 27.7, 5.79), (510, 27.5, 5.91), (482, 27.35, 5.9), (454, 27.2, 5.91), (389, 26.9, 5.97), (347, 26.7, 5.97), (305, 26.5, 5.97), (163, 26.2, 5.90), (93, 26.1, 5.96), (23, 26.1, 6.02), (0, 25.9, 6.02), (0, 25.85, 6.0), (0, 25.8, 6.02),
      (0, 25.7, 6.02), (0, 25.65, 6.0), (0, 25.6, 6.02), (0, 25.4, 6.02), (0, 25.35, 6.0), (0, 25.3, 6.02), (0, 25.2, 6.02), (0, 25.1, 6.02), (0, 25.1, 6.02), (0, 24.9, 6.21), (0, 24.85, 6.2), (0, 24.8, 6.21), (0, 24.7, 6.27), (0, 24.65, 6.3),
      (0, 24.6, 6.39), (0, 24.6, 6.39), (0, 24.55, 6.4), (0, 24.5, 6.58), (0, 24.4, 6.58), (0, 24.3, 6.58), (0, 24.2, 6.58), (0, 23.8, 6.58), (0, 23.65, 6.5), (0, 23.5, 6.51), (0, 23.3, 6.51), (0, 23.3, 6.54), (0, 23.3, 6.58), (0, 23.3, 6.58),
      (0, 23.3, 6.55), (0, 23.3, 6.53), (0, 23.3, 6.60), (0, 23.3, 6.54), (0, 23.3, 6.48), (0, 23.2, 6.36), (0, 23.2, 6.23), (0, 23.2, 6.11)
    ]
      
    let badDay: [(dni: Double, temp: Double, ws: Double)] = [
      (0, 23.3, 7.3), (0, 23.3, 6.3), (0, 23.5, 5.9), (0, 23.4, 4.3), (0, 23.6, 6.0), (0, 23.6, 8.0), (0, 23.3, 8.1), (0, 23.2, 7.6), (0, 23.1, 6.5), (0, 22.9, 4.8), (0, 22.7, 7.2), (0, 22.5, 6.3), (0, 22.3, 6.6), (0, 22.3, 6.0), (0, 22.2, 5.6),
      (0, 22.0, 4.4), (0, 21.9, 4.7), (0, 22.0, 5.4), (0, 22.2, 5.6), (0, 22.0, 4.2), (0, 21.8, 5.0), (0, 21.6, 6.3), (0, 21.4, 6.7), (0, 21.6, 8.0), (0, 21.5, 9.8), (0, 21.6, 12.4), (0, 21.6, 11.5), (0, 21.6, 10.8), (0, 21.7, 10.4), (0, 21.8, 8.7),
      (0, 21.6, 6.8), (0, 21.3, 5.9), (0, 21.2, 6.0), (0, 21.2, 5.9), (0, 21.5, 7.5), (0, 21.5, 8.1), (0, 21.6, 9.4), (0, 21.5, 9.8), (0, 21.6, 11.5), (0, 21.7, 10.6), (0, 21.7, 9.9), (0, 21.7, 8.8), (34, 21.8, 10.1), (377, 22.1, 9.2),
      (548, 22.9, 9.8), (516, 23.1, 10.8), (613, 23.4, 11.7), (641, 23.5, 13.8), (653, 23.6, 15.0), (668, 23.8, 14.7), (700, 24.0, 14.8), (721, 24.0, 15.6), (730, 24.1, 15.3), (753, 24.2, 15.5), (771, 24.3, 15.9), (775, 24.5, 15.5),
      (791, 24.7, 15.1), (811, 24.9, 15.0), (820, 25.3, 14.8), (835, 25.4, 14.0), (847, 25.7, 13.5), (851, 25.9, 12.8), (862, 26.0, 12.0), (869, 26.0, 11.6), (872, 26.3, 11.5), (871, 26.8, 10.6), (870, 26.9, 11.0), (869, 27.1, 10.5),
      (869, 26.7, 11.8), (863, 26.9, 10.6), (868, 27.1, 10.6), (867, 27.5, 10.1), (863, 28.1, 11.2), (693, 27.4, 9.3), (724, 27.8, 9.5), (514, 27.9, 10.5), (300, 28.2, 9.9), (73, 27.8, 8.4), (0, 27.2, 8.4), (0, 27.1, 7.9), (79, 27.3, 6.2),
      (198, 27.2, 6.3), (315, 28.2, 6.0), (188, 28.1, 9.5), (148, 27.4, 11.6), (0, 26.8, 11.1), (163, 27.0, 10.4), (294, 27.0, 10.0), (397, 26.8, 9.9), (792, 27.4, 11.7), (137, 27.1, 9.2), (64, 26.1, 8.0), (61, 26.1, 8.3), (411, 26.2, 8.3),
      (459, 25.9, 9.3), (669, 26.3, 7.1), (378, 26.7, 7.8), (355, 25.8, 6.1), (509, 26.6, 6.4), (453, 26.7, 8.7), (7, 25.8, 7.8), (0, 25.3, 6.8), (47, 25.2, 5.6), (296, 25.7, 6.1), (420, 25.9, 7.0), (463, 26.0, 7.4), (392, 26.0, 6.8),
      (377, 26.0, 7.2), (330, 25.9, 7.4), (125, 25.6, 6.7), (0, 25.0, 7.2), (0, 24.8, 6.8), (0, 24.6, 6.8), (0, 24.4, 7.3), (0, 24.2, 7.3), (0, 23.6, 8.6), (0, 23.3, 8.6), (0, 23.2, 8.8), (0, 23.1, 8.2), (0, 23.2, 8.6), (0, 22.7, 12.1),
      (0, 22.4, 11.6), (0, 22.3, 11.2), (0, 22.2, 10.0), (0, 22.0, 10.1), (0, 21.9, 10.1), (0, 21.6, 9.5), (0, 21.4, 10.8), (0, 21.3, 10.4), (0, 21.3, 9.2), (0, 21.3, 7.6), (0, 21.3, 6.5), (0, 21.2, 5.6), (0, 21.2, 5.6), (0, 21.0, 4.7),
      (0, 20.7, 5.3), (0, 20.8, 6.7), (0, 20.7, 6.3), (0, 20.4, 4.9), (0, 19.9, 3.9), (0, 19.7, 4.0), (0, 19.6, 4.0), (0, 19.5, 4.2), (0, 19.3, 4.5),
    ]

    let meteoDataHourly = hourly.map { MeteoData(dni: $0.dni, ghi: 0, dhi: 0, temperature: $0.temp, windSpeed: $0.ws) }
    let meteoDataGood = goodDay.map { MeteoData(dni: $0.dni, ghi: 0, dhi: 0, temperature: $0.temp, windSpeed: $0.ws) }
    let meteoDataBad = badDay.map { MeteoData(dni: $0.dni, ghi: 0, dhi: 0, temperature: $0.temp, windSpeed: $0.ws) }

    let meteoData = Array(repeatElement(meteoDataHourly, count: 365).joined())

    let m = MeteoDataProvider(name: "", data: meteoData, (2017, location))
    m.setInterval(.fiveMinutes)
    XCTAssertEqual(Array(m).count, 105120)
    m.setInterval(.teenMinutes)
    XCTAssertEqual(Array(m).count, 52560)
    m.setInterval(.fifteenMinutes)
    XCTAssertEqual(Array(m).count, 35040)
  }
}
