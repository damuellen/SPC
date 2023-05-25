import Utilities
import XCTest

@testable import BlackBoxModel

class PVPanelTests: XCTestCase {
  func testsPanel() {
    let panel = PV.Panel()
    let iter = ((50...1050) / 100).iteration
    let P = { panel(radiation: $0, ambient: .init(celsius: $1), windSpeed: 0) }
    let p = { t in iter.map { x in [x, P(x, t).power] }}
    let I = { t in iter.map { x in [x, P(x, t).current] }}
    let V = { t in iter.map { x in [x, P(x, t).voltage * 26] }}
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
      _ = try? FileManager.default.createDirectory(atPath: ".plots", withIntermediateDirectories: true)
      _ = try? plot(.png(".plots/panel.png"))
      _ = try? plot(.png(".plots/panel2.png"))
    
      let plot2 = Gnuplot(
        xy1s: ((0...20) / 150).iteration.map { x in [x, lambertW(x)] },
        titles: "lambertW"
      )
      _ = try? plot2(.png(".plots/lambertW.png"))
    }
    let i = ((0...1000) / 100).iteration.map { x in
      [x, panel.currentFrom(voltage: x, radiation: 50, cell_T: .init(celsius: 30))]
    }
    let v = ((0.8...1.1) / 100).iteration.map { x in
      [x, panel.voltageFrom(current: x, radiation: 50, cell_T: .init(celsius: 30))]
    }
    if plotting {
      let plot3 = Gnuplot(
        xy1s: v,
        titles: "10__I"
      )
      plot3.set(yrange: -2000...1000)
      _ = try? plot3(.pngLarge(".plots/panel3.png"))

      let plot4 = Gnuplot(
        xy1s: i,
        titles: "10__I"
      )
      _ = try? plot4(.pngLarge(".plots/panel4.png"))
    }
  }

  func testPV() {
    let pv = PV()

    var conditions = [(Double, Temperature, Double)]()

    for gti in stride(from: 10.0, to: 1300, by: 10) {
      conditions.append((gti, Temperature(celsius: 20), 0))
    }
    let photovoltaic = conditions.map { step -> Double in
      pv(step) / 10.0e6
    }
    _ = try? FileManager.default.createDirectory(atPath: ".plots", withIntermediateDirectories: true)
    let plot = Gnuplot(xs: Array(stride(from: 10.0, to: 1300, by: 10)), ys: photovoltaic)
    _ = try? plot(.pngLarge(".plots/pv.png"))
  }
}
