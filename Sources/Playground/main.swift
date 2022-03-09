import ArgumentParser
import Foundation
import Utilities
import xlsxwriter
import SunOl

#if !os(Windows)
print("\u{1b}[1J", terminator: "")
print(tunol)
signal(SIGINT, SIG_IGN)
source.setEventHandler { source.cancel() }
#else
MessageBox(text: "Calculation started.", caption: "TunOl")
import WinSDK
_ = SetConsoleOutputCP(UINT(CP_UTF8))
SetConsoleCtrlHandler({_ in source.cancel();semaphore.wait();return WindowsBool(true)}, true)
DispatchQueue.global().asyncAfter(deadline: .now() + 3) { start("http://127.0.0.1:9080") }
#endif
#if os(Linux)
try! Gnuplot.process().run()
#endif
var stopwatch = 0


let server = HTTP { request -> HTTP.Response in var uri = request.uri
  if uri == "/cancel" {
    source.cancel()
    stopwatch = 0
  } else {
    uri.remove(at: uri.startIndex)
  }
  let curves = TunOl.convergenceCurves.map { Array($0.suffix(Int(uri) ?? 10)) }
  if curves[0].count > 1 {
    let m = curves.map(\.last!).map { $0[1] }.min()
    let i = curves.firstIndex(where: { $0.last![1] == m })!
    let plot = Gnuplot(xys: curves, titles: ["Best1", "Best2", "Best3"])
      .plot(multi: true, index: 0).plot(index: 1).plot(index: 2)
      .plot(multi: true, index: i).plot(index: i, label: 2)
      .set(title: "Convergence curves")
      .set(xlabel: "Iteration").set(ylabel: "LCoM")
    plot.settings["xtics"] = "1"
    return .init(html: .init(body: plot.svg!, refresh: min(stopwatch, 30)))
  }
  return .init(html: .init(refresh: 10))
}

source.resume()
server.start()

let now = Date()

DispatchQueue.global(qos: .background).sync { Command.main() }

print("Elapsed seconds:", -now.timeIntervalSinceNow)

server.stop()
semaphore.signal()

struct Command: ParsableCommand {

  @Option(name: .short, help: "Input data file") var file: String?

  @Option(name: .short, help: "Parameter file") var json: String?

  @Flag(name: .long, help: "Do not use Multi-group algorithm") var noGroups: Bool = false

  @Option(name: .short, help: "Population size") var n: Int?

  @Option(name: .short, help: "Iterations") var iterations: Int?

  func run() throws {
    let path = file ?? "input.txt"
    guard let csv = CSV(atPath: path) else { print("No input."); return }
    TunOl.Q_Sol_MW_thLoop = [0] + csv["csp"]
    TunOl.Reference_PV_plant_power_at_inverter_inlet_DC = [0] + csv["pv"]
    TunOl.Reference_PV_MV_power_at_transformer_outlet = [0] + csv["out"]

    let id = String(UUID().uuidString.prefix(6))
    let name = "SunOl_\(id).xlsx"
    let wb = Workbook(name: name)
    let ws = wb.addWorksheet()
    let ws2 = wb.addWorksheet()
    let names = labels[0..<11]

    var r = 0
    var r2 = 0
    defer {
      print(name)
      ws.table(range: [0, 0, r, labels.count - 1], header: labels)
      names.enumerated().forEach { column, name in let chart = wb.addChart(type: .scatter)  //.set(y_axis: 1000...2500)
        chart.addSeries().set(marker: 5, size: 4)
        .values(sheet: ws, range: [1, 17, r, 17])
        .categories(sheet: ws, range: [1, column, r, column])
        chart.remove(legends: 0)
        wb.addChartsheet(name: name).set(chart: chart)
      }
      ws2.table(range: [0, 0, r2, 3], header: ["CAPEX", "Count", "Min", "Max"])
      let chart = wb.addChart(type: .line)
      chart.addSeries().values(sheet: ws2, range: [1, 2, r2, 2]).categories(sheet: ws2, range: [1, 0, r2, 0])
      wb.addChartsheet(name: "CAPEX").set(chart: chart)
      let bc = wb.addChart(type: .bar)
      bc.addSeries().values(sheet: ws2, range: [1, 1, r2, 1]).categories(sheet: ws2, range: [1, 0, r2, 0])
      bc.remove(legends: 0)
      ws2.insert(chart: bc, (1, 5)).activate()
      wb.close()
      try! Gnuplot(xys: TunOl.convergenceCurves, style: .lines(smooth: false))(.pngLarge(path: "SunOl_\(id).png"))
    }

    let parameter: [Parameter]
    if let path = json, let data = try? Data(contentsOf: .init(fileURLWithPath: path)), 
      let parameters = try? JSONDecoder().decode([Parameter].self, from: data) {
      parameter = parameters
    } else {
     parameter = [
  Parameter(
    BESS_cap_ud: 0...1400, CCU_C_O_2_nom_prod_ud: 10...110, C_O_2_storage_cap_ud: 10...110,
    CSP_loop_nr_ud: 20...250, El_boiler_cap_ud: 10...110, EY_var_net_nom_cons_ud: 10...110,
    Grid_export_max_ud: 50...50, Grid_import_max_ud: 50...50, Hydrogen_storage_cap_ud: 10...110,
    Heater_cap_ud: 10...500, MethDist_Meth_nom_prod_ud: 10...110,
    MethSynt_RawMeth_nom_prod_ud: 10...110, PB_nom_gross_cap_ud: 10...110,
    PV_AC_cap_ud: 280...1280, PV_DC_cap_ud: 280...1380, RawMeth_storage_cap_ud: 10...110,
    TES_full_load_hours_ud: 10...110)
]

    }
    parameter.forEach { parameter in
      let a = MGOADE(group: !noGroups, n: n ?? 150, maxIter: iterations ?? 100, bounds: parameter.ranges, fitness: fitness)
      a.forEach { row in r += 1; ws.write(row, row: r) }
      if r < 2 { return }
      let (x,y) = (12, 17)
      let freq = 10e7
      var d = [Double:[Double]]()
      for i in a.indices {
        let key = (a[i][x] / freq).rounded(.up)
        if let v = d[key] { d[key] = [v[0] + 1, min(v[1], a[i][y]), max(v[2], a[i][y])] } 
        else { d[key] = [1, a[i][y], a[i][y]] }
      }
      d.keys.sorted().map { [$0 * freq] + d[$0]! }.forEach { row in r2 += 1; ws2.write(row, row: r2) }
    }
  }
}
