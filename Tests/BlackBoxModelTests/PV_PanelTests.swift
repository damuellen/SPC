import Utilities
import XCTest

@testable import BlackBoxModel

class PVPanelTests: XCTestCase {
  func testsPanel() {
    let panel = PV.Panel()
    let S = ((50...1050) / 100).numbers
    let P = { panel(radiation: $0, ambient: .init(celsius: $1), windSpeed: 0) }
    let p = { t in S.map { x in [x, P(x, t).power] }}
    let I = { t in S.map { x in [x, P(x, t).current] }}
    let V = { t in S.map { x in [x, P(x, t).voltage * 26] }}
    let plotting = true
    if plotting {
      let plot = Gnuplot(
        xy1s: I(10), I(50),
        xy2s: V(0), V(10), V(20), V(30), V(40), V(50),
        titles: "10__I", "50__I", "0__V", "10__V", "20__V", "30__V", "40__V", "50__V"
      )

      plot.settings = [
        "ylabel": "Current [A]", "y2label": "Voltage [V]", "xlabel": "GTI [W]'",
      ]
      let plot1 = Gnuplot(
        xy1s: p(10), p(20), p(30), p(40), p(50), p(60), p(70)
      )
      plot1.settings = [
        "ylabel": "Power", "xlabel": "GTI",
      ]

      _ = try? plot(.png("panel.png"))
      _ = try? plot(.png("panel2.png"))
    
      let plot2 = Gnuplot(
        xy1s: ((0...20) / 150).numbers.map { x in [x, lambertW(x)] },
        titles: "lambertW"
      )
      _ = try? plot2(.png("lambertW.png"))
    }
    let i = ((0...1000) / 20000).numbers.map { x in
      [x, panel.currentFrom(voltage: x, radiation: 50, cell_T: .init(celsius: 30))]
    }
    let v = ((0.8...1.1) / 100).numbers.map { x in
      [x, panel.voltageFrom(current: x, radiation: 50, cell_T: .init(celsius: 30))]
    }
    if plotting {
      let plot3 = Gnuplot(
        xy1s: v,
        titles: "10__I"
      )
      plot3.set(yrange: -2000...1000)
      _ = try? plot3(.pngLarge("panel3.png"))

      let plot4 = Gnuplot(
        xy1s: i,
        titles: "10__I"
      )
      _ = try? plot4(.pngLarge("panel4.png"))
    }
  }
}
