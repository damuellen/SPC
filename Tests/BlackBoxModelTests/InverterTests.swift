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
    /*
         let max = Array(zip(inverter.dc_power[2...], inverter.maxVoltage[2...]))
         let nom = Array(zip(inverter.dc_power[2...], inverter.nomVoltage[2...]))
         let min = Array(zip(inverter.dc_power[2...], inverter.minVoltage[2...]))
         let l = inverter.voltageLevels
         let r = inverter.dc_power[2]...inverter.dc_power.last!
         do {
         let v1 = 925.0
         let xy1 = solve(in: r, by: 30000) {
         inverter(power: $0 , voltage: v1)
         }
         let v2 = 980.0
         let xy2 = solve(in: r, by: 30000) {
         inverter(power: $0 , voltage: v2)
         }
         let v3 = 950.0
         let xy3 = solve(in: r, by: 30000) {
         inverter(power: $0 , voltage: v3)
         }
         let plotter = Gnuplot(
         xy1s: nom, min, xy1, xy2, xy3,
         titles: "\(l[1])", "\(l[2])", "\(v1)", "\(v2)", "\(v3)"
         )
         plotter.userSettings = [
         "ylabel 'Efficiency [%]'", "xlabel 'Power [W]'", "ytics nomirror", "yrange [97.6:98.8]"
         ]

         try! plotter.plot(.png(path: "inverter.png"))
         }
         do {
         let v1 = 1010.0
         let xy1 = solve(in: r, by: 30000) {
         inverter(power: $0 , voltage: v1)
         }
         let v2 = 1180.0
         let xy2 = solve(in: r, by: 30000) {
         inverter(power: $0 , voltage: v2)
         }
         let v3 = 1095.0
         let xy3 = solve(in: r, by: 30000) {
         inverter(power: $0 , voltage: v3)
         }
         let plotter = Gnuplot(
         xy1s: max, nom, xy1, xy2, xy3,
         titles: "\(l[0])", "\(l[1])", "\(v1)", "\(v2)", "\(v3)"
         )
         plotter.userSettings = [
         "ylabel 'Efficiency [%]'", "xlabel 'Power [W]'", "ytics nomirror", "yrange [97.4:98.7]"
         ]

         try! plotter.plot(.png(path: "inverter2.png"))
         }
         */
  }
}
