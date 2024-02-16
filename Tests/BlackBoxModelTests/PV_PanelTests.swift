import Utilities
import XCTest
import CLambertW
@testable import BlackBoxModel

class PVPanelTests: XCTestCase {
  func testsPanel() {
    let panel = PV.Panel()
    let iter = ((50...1050) / 100).iteration
    let P = { panel(mpp: .init(irradiance: $0, ambient: Temperature(celsius: $1), windSpeed: 0)) }

    let I = { t in iter.map { x in P(x, t).current } }
    let V = { t in iter.map { x in P(x, t).voltage * 26 } }
    let p = { t in iter.map { x in P(x, t).power } }

    let plotting = true
    if plotting {
      _ = try? FileManager.default.createDirectory(atPath: ".plots", withIntermediateDirectories: true)
      do {
        let plot = Gnuplot()
        plot.data(
          xs: iter, I(10), I(50), V(0), V(10), V(20), V(30), V(40), V(50), titles: "aa", "10__I", "50__I", "0__V", "10__V",
          "20__V", "30__V", "40__V", "50__V"
        )
        .set(xlabel: "GTI [W]").set(ylabel: "Current [A]").set(y2label: "Voltage [V]")
        _ = try plot.plot2(x: 1, y1: 2, 3, y2: 4, 5, 6, 7, 8, 9)(.pngSmall(".plots/panel.png"))
      } catch { XCTFail(error.localizedDescription) }
      do {
        let plot = Gnuplot()
        plot.data(xs: iter, p(10), p(20), p(30), p(40), p(50), p(60), p(70)).set(xlabel: "GTI").set(ylabel: "Power")
        _ = try plot.plot(x: 1, y: 2, 3, 4, 5, 6, 7, 8)(.pngSmall(".plots/panel2.png"))
      } catch { XCTFail(error.localizedDescription) }
      do {
        let plot = Gnuplot()
        let xs = ((0...20) / 150).iteration
        plot.data(xs: xs, xs.map { x in LambertW(x) }, titles: "x", "LambertW")
        _ = try plot.plot(x: 1, y: 2, 3, 4, 5, 6, 7, 8)(.pngSmall(".plots/LambertW.png"))
      } catch { XCTFail(error.localizedDescription) }
    }
    let i = ((0...1000) / 100).iteration.map { x in panel.currentFrom(voltage: x, irradiance: 50, cell_T: .init(celsius: 30)) }
    let v = ((0.8...1.1) / 100).iteration.map { x in panel.voltageFrom(current: x, irradiance: 50, cell_T: .init(celsius: 30)) }
    if plotting {
      do {
        let plot = Gnuplot()
        plot.data(xs: ((0.8...1.1) / 100).iteration, v, titles: "", "10__I")
        plot.set(yrange: -2000...1000)
        _ = try plot(.pngSmall(".plots/panel3.png"))
      } catch { XCTFail(error.localizedDescription) }
      do {
        let plot = Gnuplot()
        plot.data(xs: ((0...1000) / 100).iteration, i, titles: "", "10__I")
        _ = try plot(.pngSmall(".plots/panel4.png"))
      } catch { XCTFail(error.localizedDescription) }
    }
  }

  func testPV() {
    let pv = PV()

    var conditions = [PV.InputValues]()

    for irradiance in stride(from: 10.0, to: 1300, by: 10) {
      conditions.append(.init(irradiance: irradiance, ambient: Temperature(celsius: 20), windSpeed: 0))
    }
    let photovoltaic = conditions.map { step -> Double in pv(step) / 10.0e6 }
    do {
      _ = try FileManager.default.createDirectory(atPath: ".plots", withIntermediateDirectories: true)
      try Gnuplot().data(xs: Array(stride(from: 10.0, to: 1300, by: 10)), photovoltaic)(.pngLarge(".plots/pv.png"))
    } catch { XCTFail(error.localizedDescription) }
  }
}
