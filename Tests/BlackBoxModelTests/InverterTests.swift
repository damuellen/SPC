import XCTest
import Helpers

@testable import BlackBoxModel

class InverterTests: XCTestCase {
  func testsInverter() {
    let inverter = PV.Inverter()
    let max = Array(zip(inverter.dc_power[1...], inverter.maxVoltage[1...]))
    let nom = Array(zip(inverter.dc_power[1...], inverter.nomVoltage[1...]))
    let min = Array(zip(inverter.dc_power[1...], inverter.minVoltage[1...]))
    let l = inverter.voltageLevels
     do {
      let v1 = 925.0
      let xy1 = solve(in: inverter.dc_power[1]...inverter.dc_power.last!, by: 30000) {
        inverter(power: $0 , voltage: v1)
      }
      let v2 = 980.0
      let xy2 = solve(in: inverter.dc_power[1]...inverter.dc_power.last!, by: 30000) {
        inverter(power: $0 , voltage: v2)
      }
      let v3 = 950.0
      let xy3 = solve(in: inverter.dc_power[1]...inverter.dc_power.last!, by: 30000) {
        inverter(power: $0 , voltage: v3)
      }
      // let plotter = Gnuplot(
      //   xy1s: max, nom, min, xy1, xy2, xy3,
      //   titles: "\(l[0])", "\(l[1])", "\(l[2])", "\(v1)", "\(v2)", "\(v3)"
      // )
      // plotter.userSettings = [
      //   "ylabel 'Efficiency [%]'", "xlabel 'Power [W]'", "ytics nomirror", "yrange [97:99]"
      // ]

      // try! plotter.plot(.pngSmall(path: "inverter.png"))
    }
    do {
      let v1 = 1000.0
      let xy1 = solve(in: inverter.dc_power[1]...inverter.dc_power.last!, by: 30000) {
        inverter(power: $0 , voltage: v1)
      }
      let v2 = 1190.0
      let xy2 = solve(in: inverter.dc_power[1]...inverter.dc_power.last!, by: 30000) {
        inverter(power: $0 , voltage: v2)
      }
      let v3 = 1095.0
      let xy3 = solve(in: inverter.dc_power[1]...inverter.dc_power.last!, by: 30000) {
        inverter(power: $0 , voltage: v3)
      }
      // let plotter = Gnuplot(
      //   xy1s: max, nom, min, xy1, xy2, xy3,
      //   titles: "\(l[0])", "\(l[1])", "\(l[2])", "\(v1)", "\(v2)", "\(v3)"
      // )
      // plotter.userSettings = [
      //   "ylabel 'Efficiency [%]'", "xlabel 'Power [W]'", "ytics nomirror", "yrange [97:99]"
      // ]

      // try! plotter.plot(.pngSmall(path: "inverter2.png"))
    }

  }
}
