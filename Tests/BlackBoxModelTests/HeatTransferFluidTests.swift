import XCTest

@testable import BlackBoxModel

class HeatTransferFluidTests: XCTestCase {
  let htf = HeatTransferFluid(
    name: "Therminol",
    freezeTemperature: 12,
    heatCapacity: [1.4856, 0.0028],
    dens: [1074.964, -0.6740513, -0.000650017],
    visco: [-0.000201537, 0.1273247, -0.7167957],
    thermCon: [0.1378081, -8.41485e-05, -1.788e-07],
    maxTemperature: 393.0,
    h_T: [-0.62677, 1.51129, 0.0012941, 1.23697e-07, 0],
    T_h: [0.58315, 0.65556, -0.00032293, 1.9425e-07, -6.1133e-11],
    useEnthalpy: true
  )

  func testsTherminol() {
    var density = htf.density(Temperature(celsius: 300.0))
    XCTAssertEqual(density, 814.24, accuracy: 0.01, "density 300")
    density = htf.density(Temperature(celsius: 400.0))
    XCTAssertEqual(density, 701.34, accuracy: 0.01, "density 400")

    let temperature = htf.temperature(300, Temperature(celsius: 400.0))
    XCTAssertEqual(temperature.kelvin, 779.22, accuracy: 0.01)
  }

  func testsHydronic() {
    var tf = HeatTransfer(name: "")

    tf.massFlow = 500.0
    tf.temperature.inlet = Temperature(celsius: 293.0)
    tf.temperature.outlet = Temperature(celsius: 393.0)

    tf.temperature.inlet = Temperature(celsius: 393.0)
    tf.temperature.outlet = Temperature(celsius: 293.0)
  }

  static var allTests: [(String, (HeatTransferFluidTests) -> () throws -> Void)] {
    return [
      ("testsTherminol", testsTherminol),
      ("testsHydronic", testsHydronic),
    ]
  }
}
