import Utilities
import XCTest

@testable import BlackBoxModel

class PVPanelTests: XCTestCase {
  func testsPanel() {
    let panel = PV.Panel()
    let S = { evaluate(in: 50...1050, numberOfSamples: 100, f: $0) }
    let P = { panel(radiation: $0, ambient: .init(celsius: $1), windSpeed: 0) }
    let p = { t in S { P($0, t).power }}
    let I = { t in S { P($0, t).current }}
    let V = { t in S { P($0, t).voltage * 26}}
    // let plot = Gnuplot(
    //   xy1s: I(10), I(50),
    //   xy2s: V(0), V(10), V(20), V(30), V(40), V(50),
    //   titles: "10__I", "50__I", "0__V", "10__V", "20__V", "30__V", "40__V", "50__V"
    // )

    // plot.userSettings = [
    //   "ylabel 'Current [A]'", "y2label 'Voltage [V]'", "xlabel 'GTI [W]'",
    // ]
    // let plot2 = Gnuplot(
    //   xy1s: p(10), p(20), p(30), p(40), p(50), p(60), p(70)
    // )
    // plot2.userSettings = [
    //   "ylabel 'Power'", "xlabel 'GTI'",
    // ]

    // try! plot(.png(path: "panel.png"))
    // try! plot(.png(path: "panel2.png"))

    let S2 = { evaluate(in: 0...1000, numberOfSamples: 20000, f: $0) }
    let S3 = { evaluate(in: 0.8...1.1, numberOfSamples: 100, f: $0)  }
    let i = S2 { panel.currentFrom(voltage: $0, radiation: 50, cell_T: .init(celsius: 30)) }
    let v = S3 { panel.voltageFrom(current: $0, radiation: 50, cell_T: .init(celsius: 30)) }

    // let plot3 = Gnuplot(
    //   xy1s: v,
    //   titles: "10__I"
    // )
    // try! plotter3.plot(.pngLarge(path: "panel3.png"))

    // let plot4 = Gnuplot(
    //   xy1s: i,
    //   titles: "10__I"
    // )
    // try! plotter4.plot(.pngLarge(path: "panel4.png"))
  }
}

func evaluate(in range: ClosedRange<Double>, numberOfSamples: Int = 100, f: (Double)->Double) -> [[Double]] {
  let step = (range.upperBound - range.lowerBound) / Double(numberOfSamples)
  return stride(from: range.lowerBound, through: range.upperBound, by: step).map{[$0,f($0)]}
}