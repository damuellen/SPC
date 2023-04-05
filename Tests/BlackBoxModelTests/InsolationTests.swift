import XCTest

@testable import BlackBoxModel
@testable import Meteo

class InsolationTests: XCTestCase {

  func testsBeam() {
    let GHI = [0, 0, 413.82, 90.72]
    let DHI = [0, 0, 93.6100, 51.34]
    let AOI = [0, 88.0898, 48.3852, 82.5870]
    let zenith = [90.0, 89.1520, 64.1170, 86.7160]

    let expected =  [0, 0, 487.1496, 88.6937]

    let tol = 0.1
    var insolation = Insolation()
    for i in expected.indices {
      insolation.global = GHI[i]
      insolation.diffuse = DHI[i]
      let dni = insolation.beam(incidence: AOI[i], zenith: zenith[i])
      XCTAssertEqual(dni, expected[i], accuracy: tol)
    }
  }

  func testsPerez() {
    let tilt = [16, 0, 1.0862, 48.9017, 4.8147, 30.8742, 4.7337]
    let DHI = [290, 0, 0, 93.6100, 51.34, 109.76, 115.99]
    let DNI = [2.692, 0, 0, 733.5267, 687.4372, 885.8594, 854.6398]
    let AOI = [83, 0, 88.0898, 48.3852, 82.5870, 53.0572, 55.8419]
    let hExtra = [1414.91, 1.4149e3, 1.4149e3, 1.4149e3, 1.4149e3, 1.4149e3, 1.4149e3]
    let zenith = [77.21, 90.0, 89.1520, 64.1170, 86.7160, 58.9450, 55.9740]
    let AM = [4.43, 31.7349, 24.4956, 2.2777, 13.6228, 1.9311, 1.7816]

    let expected = [241.1, 0, 0, 128.2817, 51.3891, 128.4142, 118.4124]
    let tol = 0.1
    var insolation = Insolation()
    for i in expected.indices {
      insolation.direct = DNI[i]
      insolation.diffuse = DHI[i]
      let irradiance = insolation.perez(
        surfaceTilt: tilt[i], incidence: AOI[i], hExtra: hExtra[i],
        sunZenith: zenith[i], AM: AM[i])
      XCTAssertEqual(irradiance, expected[i], accuracy: tol)
    }
  }
}
