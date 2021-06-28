import Helpers
import PhysicalQuantities
import XCTest

@testable import BlackBoxModel

class PVPanelTests: XCTestCase {
  func testsPanel() {
    let panel = PV.Panel()
    let S = { solve(in: 25...1200, by: 25, f: $0) }
    let P = { panel(radiation: $0, ambient: .init(celsius: $1), windSpeed: 0) }
    let p = { t in S { P($0, t).power }}
    let I = { t in S { P($0, t).current }}
    let V = { t in S { P($0, t).voltage }}
    let plotter = Gnuplot(
      xy1s: I(10), I(50),
      xy2s: V(10), V(20), V(30), V(40), V(50),
      titles: "10__I", "50__I", "10__V", "20__V", "30__V", "40__V", "50__V"
    )
    plotter.userSettings = [
      "ylabel 'Current [A]'", "y2label 'Voltage [V]'", "xlabel 'GTI [W]'",
    ]
    let plotter2 = Gnuplot(
      xy1s: p(10), p(20), p(30), p(40), p(50), p(60), p(70)
    )
    plotter2.userSettings = [
      "ylabel 'Power'", "xlabel 'GTI'",
    ]

    // try! plotter.plot(.png(path: "panel.png"))
    // try! plotter2.plot(.pngSmall(path: "panel2.png"))

    let S2 = { solve(in: 0...1000, by: 0.05, f: $0) }
    let S3 = { solve(in: 0.8...1.1, by: 0.001, f: $0) }
    let i = S2 { panel.currentFrom(voltage: $0, radiation: 50, cell_T: .init(celsius: 30)) }
    let v = S3 { panel.voltageFrom(current: $0, radiation: 50, cell_T: .init(celsius: 30)) }

    let plotter3 = Gnuplot(
      xy1s: v,
      titles: "10__I"
    )
    // try! plotter3.plot(.pngLarge(path: "panel3.png"))

    let plotter4 = Gnuplot(
      xy1s: i,
      titles: "10__I"
    )
    // try! plotter4.plot(.pngLarge(path: "panel4.png"))
  }
}
