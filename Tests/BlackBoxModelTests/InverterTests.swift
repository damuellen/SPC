import Helpers
import XCTest

@testable import BlackBoxModel

class InverterTests: XCTestCase {
  func testsInverter() {
    let inverter = PV.Inverter()
    let tol = 0.01
    XCTAssert(inverter(power: 11e3, voltage: 1100).isNaN)
    XCTAssert(inverter(power: 11e3, voltage: 900).isNaN)
    XCTAssert(inverter(power: 11e3, voltage: 950).isNaN)
    XCTAssert(inverter(power: 11e3, voltage: 1210).isNaN)
    XCTAssertEqual(80.26, inverter(power: 14e3, voltage: 1100), accuracy: tol)
    XCTAssert(inverter(power: 14e3, voltage: 900).isNaN)
    XCTAssertEqual(80.27, inverter(power: 14e3, voltage: 950), accuracy: tol)
    XCTAssert(inverter(power: 14e3, voltage: 1210).isNaN)
    XCTAssertEqual(96.1, inverter(power: 14e4, voltage: 1100), accuracy: tol)
    XCTAssertEqual(98.49, inverter(power: 14e5, voltage: 1100), accuracy: tol)
    XCTAssertEqual(96.51, inverter(power: 14e4, voltage: 980), accuracy: tol)
    XCTAssertEqual(98.57, inverter(power: 14e5, voltage: 980), accuracy: tol)
    XCTAssert(inverter(power: 14e5, voltage: 900).isNaN)
    XCTAssertEqual(98.62, inverter(power: 14e5, voltage: 950), accuracy: tol)
    XCTAssert(inverter(power: 14e5, voltage: 1210).isNaN)
    XCTAssertEqual(98.38, inverter(power: 23e5, voltage: 1100), accuracy: tol)
    XCTAssert(inverter(power: 23e5, voltage: 900).isNaN)
    XCTAssertEqual(98.51, inverter(power: 23e5, voltage: 950), accuracy: tol)
    XCTAssert(inverter(power: 23e5, voltage: 1210).isNaN)
    XCTAssert(inverter(power: 26e5, voltage: 1100).isNaN)
    XCTAssert(inverter(power: 26e5, voltage: 900).isNaN)
    XCTAssert(inverter(power: 26e5, voltage: 950).isNaN)
    XCTAssert(inverter(power: 26e5, voltage: 1210).isNaN)

    let r = inverter.dc_power[2]...inverter.dc_power.last!
    let iter = (r / 100).iteration

    do {
      let v1 = 925.0
      let xy1 = iter.map { inverter(power: $0, voltage: v1) }
      let v2 = 980.0
      let xy2 = iter.map { inverter(power: $0, voltage: v2) }
      let v3 = 950.0
      let xy3 = iter.map { inverter(power: $0, voltage: v3) }
      let plotter = Gnuplot()
      plotter.data(xs: iter, xy1, xy2, xy3, titles: "", "\(v1)", "\(v2)", "\(v3)")
      plotter.plot( x: 1, y: 2,3,4)
      .set(xlabel: "Power [W]")
      .set(ylabel: "Efficiency [%]")
      plotter.settings["yrange"] = "[97.6:98.8]"
      plotter.settings["ytics"] = "nomirror"
      _ = try FileManager.default.createDirectory(atPath: ".plots", withIntermediateDirectories: true)
      _ = try plotter(.pngLarge(".plots/inverter.png"))
    } catch { XCTFail(error.localizedDescription) }
    do {
      let v1 = 1010.0
      let xy1 = iter.map { inverter(power: $0, voltage: v1) }
      let v2 = 1180.0
      let xy2 = iter.map { inverter(power: $0, voltage: v2) }
      let v3 = 1095.0
      let xy3 = iter.map { inverter(power: $0, voltage: v3) }
      let plotter = Gnuplot()
      plotter.data(xs: iter, xy1, xy2, xy3, titles: "", "\(v1)",
        "\(v2)", "\(v3)")
     try FileManager.default.createDirectory(atPath: ".plots", withIntermediateDirectories: true)
     try plotter.callAsFunction(.pngLarge(".plots/inverter2.png"))
    } catch { XCTFail(error.localizedDescription) }
  }
}
