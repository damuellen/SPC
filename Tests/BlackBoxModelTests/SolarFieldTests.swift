import XCTest

@testable import BlackBoxModel
import Units

class SolarFieldTests: XCTestCase {
  func testsSingleAxisTracker() {
    let zenith = [90.0, 89.152, 64.117, 86.716]
    let azimuth = [110.6, 118.4, 146.2, 239.8]

    let expected: [(Double, Double, Double, Double)] = [
      (trackerTheta: 0, AOI: 0, surfTilt: 0, surfAz: 270),
      (trackerTheta: -1.2076, AOI: 88.0898, surfTilt: 1.0862, surfAz: 90),
      (trackerTheta: -48.9047, AOI: 48.3852, surfTilt: 48.9017, surfAz: 90),
      (trackerTheta: 4.7822, AOI: 82.5870, surfTilt: 4.8147, surfAz: 270)
    ]

    for i in expected.indices {
      let angles = singleAxisTracker(
        apparentZenith: zenith[i],
        apparentAzimuth: azimuth[i],
        latitude: 1.0,
        maxAngle: 55.0,
        GCR: 0.444
      )
      XCTAssertEqual(angles.0, expected[i].0, accuracy: 0.01)
      XCTAssertEqual(angles.1, expected[i].1, accuracy: 0.01)
      XCTAssertEqual(angles.2, expected[i].2, accuracy: 0.01)
      XCTAssertEqual(angles.3, expected[i].3, accuracy: 0.01)
    }
  }
  
  func testsOutletTemperature() {
    var _ = Plant.setup()
    var solarField = Plant.initialState.solarField
    var collector = Collector(parabolicElevation: 63.96, theta: 29.18, cosTheta: 0.87, efficiency: 0, insolationAbsorber: 0)

    collector.efficiency(ws: 0) // 0.90
    solarField.temperature.inlet =
      Temperature(celsius: SolarField.parameter.designTemperatureInlet)
      solarField.temperature.outlet =
      Temperature(celsius: SolarField.parameter.designTemperatureOutlet)
    let maxFlow = SolarField.parameter.maxMassFlow
    solarField.requiredMassFlow = maxFlow

    for i in solarField.loops.indices {
      solarField.loops[i].temperature = solarField.temperature
    }
    collector.irradiance(dni: 700.0)
    solarField.calculate(collector: collector, ambient: Temperature(celsius: 25.0))

    XCTAssertEqual(solarField.flow, maxFlow.rate, accuracy: 0.1)
    XCTAssertEqual(solarField.outlet, 664.7, accuracy: 0.5)
    XCTAssertEqual(solarField.inFocus.quotient, 0.87, accuracy: 0.1)

    for i in solarField.loops.indices {
      solarField.loops[i].temperature = solarField.temperature
    }
    collector.irradiance(dni: 600.0)
    solarField.calculate(collector: collector, ambient: Temperature(celsius: 25.0))

    XCTAssertEqual(solarField.flow, maxFlow.rate, accuracy: 0.5)
    XCTAssertEqual(solarField.outlet, 658.7, accuracy: 0.5)
    XCTAssertEqual(solarField.inFocus.quotient, 0.87, accuracy: 0.1)

    for i in solarField.loops.indices {
      solarField.loops[i].temperature = solarField.temperature
    }
    collector.irradiance(dni: 500.0)
    solarField.calculate(collector: collector, ambient: Temperature(celsius: 25.0))
    XCTAssertEqual(solarField.flow, 1058.6, accuracy: 0.1)
    XCTAssertEqual(solarField.outlet, 649.8, accuracy: 0.5)
    for i in solarField.loops.indices {
      solarField.loops[i].temperature = solarField.temperature
    }
    collector.irradiance(dni: 400.0)
    solarField.calculate(collector: collector, ambient: Temperature(celsius: 25.0))

    XCTAssertEqual(solarField.outlet, 646.1, accuracy: 0.5)

    let parasitics = solarField.parasitics()
    XCTAssertEqual(parasitics, 2.4, accuracy: 0.1)

    solarField.requiredMassFlow.rate = maxFlow.rate / 2

    for i in solarField.loops.indices {
      solarField.loops[i].temperature = solarField.temperature
    }
    collector.irradiance(dni: 300.0)
    solarField.calculate(collector: collector, ambient: Temperature(celsius: 25.0))
    XCTAssertEqual(solarField.flow, maxFlow.rate / 2, accuracy: 1.0)
    XCTAssertEqual(solarField.outlet, 644.4, accuracy: 0.5)
  }
}
