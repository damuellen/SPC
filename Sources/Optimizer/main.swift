import ArgumentParser
import Foundation
import Utilities
import xlsxwriter
import SunOl

let source = DispatchSource.makeSignalSource(signal: SIGINT, queue: .global())
let semaphore = DispatchSemaphore(value: 0)

#if !os(Windows)
print("\u{1b}[1J", terminator: "")
print(tunol)
signal(SIGINT, SIG_IGN)
source.setEventHandler { source.cancel() }
#else
import WinSDK
_ = SetConsoleOutputCP(UINT(CP_UTF8))
SetConsoleCtrlHandler({_ in source.cancel();semaphore.wait();return WindowsBool(true)}, true)
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
  let curves = convergenceCurves.map { Array($0.suffix(Int(uri) ?? 10)) }
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

  @Flag(name: .long, help: "No print out") var silent: Bool = false

  @Option(name: .short, help: "Population size") var n: Int?

  @Option(name: .short, help: "Iterations") var iterations: Int?

  func run() throws {
    let path = file ?? "input2.txt"
    #if os(Windows)
    guard let csv = CSVReader(atPath: path) else { MessageBox(text: "No input.", caption: "TunOl"); return }
    #else
    guard let csv = CSVReader(atPath: path) else { print("No input."); return }
    #endif
    
    TunOl.Q_Sol_MW_thLoop = [0] + csv["csp"]
    TunOl.Reference_PV_plant_power_at_inverter_inlet_DC = [0] + csv["pv"]
    TunOl.Reference_PV_MV_power_at_transformer_outlet = [0] + csv["out"]

    let id = String(UUID().uuidString.prefix(6))
    let name = "SunOl_\(id).xlsx"
    let wb = Workbook(name: name)
    let ws = wb.addWorksheet()
    // let ws2 = wb.addWorksheet()
    let labels = [
      "LCOM", "CSP_loop_nr_ud", "TES_full_load_hours_ud", "PB_nom_gross_cap_ud",
      "PV_AC_cap_ud", "PV_DC_cap_ud", "EY_var_net_nom_cons_ud",
      "Hydrogen_storage_cap_ud", "Heater_cap_ud", "CCU_C_O_2_nom_prod_ud",
      "C_O_2_storage_cap_ud", "MethSynt_RawMeth_nom_prod_ud",
      "RawMeth_storage_cap_ud", "MethDist_Meth_nom_prod_ud", "El_boiler_cap_ud",
      "BESS_cap_ud", "Grid_export_max_ud", "Grid_import_max_ud",
    ]

    var r = 0
    // var r2 = 0
    defer {
      #if os(Windows)
      DispatchQueue.global().asyncAfter(deadline: .now()) { 
        start(currentDirectoryPath() + "/" + name)
      }
      #else
      print(name)
      #endif
      ws.table(range: [0, 0, r, labels.endIndex - 1], header: labels)
      // names.enumerated().forEach { column, name in 
      //   let chart = wb.addChart(type: .scatter) //.set(y_axis: 1000...2500)
      //   chart.addSeries().set(marker: 5, size: 4)
      //   .values(sheet: ws, range: [1, 17, r, 17])
      //   .categories(sheet: ws, range: [1, column, r, column])
      //   chart.remove(legends: 0)
      //   wb.addChartsheet(name: name).set(chart: chart)
      // }
      // ws2.table(range: [0, 0, r2, 3], header: ["CAPEX", "Count", "Min", "Max"])
      // let chart = wb.addChart(type: .line)
      // chart.addSeries().values(sheet: ws2, range: [1, 2, r2, 2]).categories(sheet: ws2, range: [1, 0, r2, 0])
      // wb.addChartsheet(name: "CAPEX").set(chart: chart)
      // let bc = wb.addChart(type: .bar)
      // bc.addSeries().values(sheet: ws2, range: [1, 1, r2, 1]).categories(sheet: ws2, range: [1, 0, r2, 0])
      // bc.remove(legends: 0)
      // ws2.insert(chart: bc, (1, 5)).activate()
      wb.close()
      try! Gnuplot(xys: convergenceCurves, style: .lines(smooth: false))(.pngLarge(path: "SunOl_\(id).png"))
    }

    let parameter: [Parameter]
    if let path = json, let data = try? Data(contentsOf: .init(fileURLWithPath: path)), 
      let parameters = try? JSONDecoder().decode([Parameter].self, from: data) {
      parameter = parameters
    } else {
      parameter = [
        Parameter(
          BESS_cap_ud: 0...1400,
          CCU_C_O_2_nom_prod_ud: 10...110,
          C_O_2_storage_cap_ud: 0...5000,
          CSP_loop_nr_ud: 0...250,
          El_boiler_cap_ud: 0...110,
          EY_var_net_nom_cons_ud: 10...600,
          Grid_export_max_ud: 50...50,
          Grid_import_max_ud: 50...50,
          Hydrogen_storage_cap_ud: 0...110,
          Heater_cap_ud: 0...500,
          MethDist_Meth_nom_prod_ud: 10...110,
          MethSynt_RawMeth_nom_prod_ud: 10...110,
          PB_nom_gross_cap_ud: 0...300,
          PV_AC_cap_ud: 10...1280,
          PV_DC_cap_ud: 10...1380,
          RawMeth_storage_cap_ud: 0...300,
          TES_full_load_hours_ud: 0...30)
      ]
    }
    parameter.forEach { parameter in
      DispatchQueue.global().asyncAfter(deadline: .now()) { start("http://127.0.0.1:9080") }
      let a = MGOADE(group: !noGroups, n: n ?? 90, maxIter: iterations ?? 20, bounds: parameter.ranges, fitness: fitness)
      a.filter(\.first!.isFinite).forEach { row in r += 1; ws.write(row, row: r)
     }
    }
  }
}
