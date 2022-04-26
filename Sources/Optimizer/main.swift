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

let server = HTTP(handler: handler)

source.resume()
server.start()

let now = Date()
DispatchQueue.global(qos: .background).sync { Command.main() }
print("\u{1b}[2J", "Elapsed seconds:", -now.timeIntervalSinceNow)

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
    let path: String
    #if os(Windows)
    if let file = file { 
      path = file
    } else {
      path = FileDialog() ?? "input2.txt"  
    }
    #else
    path = file ?? "input2.txt"
    #endif
    guard let csv = CSVReader(atPath: path) else { 
      #if os(Windows)
      MessageBox(text: "No input.", caption: "TunOl")
      #else
      print("No input.");
      #endif
      return
    }
    let parameter: [Parameter]
    if let path = json, let data = try? Data(contentsOf: .init(fileURLWithPath: path)), 
      let parameters = try? JSONDecoder().decode([Parameter].self, from: data) {
      parameter = parameters
    } else {
      parameter = [
        Parameter(
          BESS_cap_ud: 0...1400,
          CCU_CO2_nom_prod_ud: 10...110,
          CO2_storage_cap_ud: 0...5000,
          CSP_loop_nr_ud: 0...250,
          El_boiler_cap_ud: 0...110,
          EY_var_net_nom_cons_ud: 10...600,
          Grid_export_max_ud: 0...50,
          Grid_import_max_ud: 0...50,
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
    
    DispatchQueue.global().asyncAfter(deadline: .now()) { start("http://127.0.0.1:9080") }

    TunOl.Q_Sol_MW_thLoop = [0] + csv["csp"]
    TunOl.Reference_PV_plant_power_at_inverter_inlet_DC = [0] + csv["pv"]
    TunOl.Reference_PV_MV_power_at_transformer_outlet = [0] + csv["out"]

    parameter.forEach { parameter in      
      let optimizer = MGOADE(group: !noGroups, n: n ?? 90, maxIter: iterations ?? 30, bounds: parameter.ranges)
      let valid = optimizer(SunOl.fitness).filter(\.first!.isFinite)
      writeExcel(results: valid.sorted { $0[0] < $1[0] })
    }
  }
}



func writeExcel(results: [[Double]]) {
  let name = "SunOl_\(UUID().uuidString.prefix(6)).xlsx"
  let wb = Workbook(name: name)
  let ws = wb.addWorksheet()
  // let ws2 = wb.addWorksheet()
  var r = 0
  results.forEach { row in r += 1; ws.write(row, row: r) }
  // var r2 = 0
  let labels = [
    "LCOM", "CAPEX", "OPEX", "Methanol", "Import", "Export",
    "CSP_loop_nr", "TES_full_load_hours", "PB_nom_gross_cap",
    "PV_AC_cap", "PV_DC_cap", "EY_var_net_nom_cons",
    "Hydrogen_storage_cap", "Heater_cap", "CCU_CO2_nom_prod",
    "CO2_storage_cap", "MethSynt_RawMeth_nom_prod",
    "RawMeth_storage_cap", "MethDist_Meth_nom_prod", "El_boiler_cap",
    "BESS_cap", "Grid_export_max", "Grid_import_max",
  ]
  ws.table(range: [0, 0, r, labels.endIndex - 1], header: labels)
  for (column, name) in labels.enumerated() {
    if column < 6 { continue }
    let chart = wb.addChart(type: .scatter).set(y_axis: 800...1400)
    chart.addSeries().set(marker: 5, size: 4)
    .values(sheet: ws, range: [1, 0, r, 0])
    .categories(sheet: ws, range: [1, column, r, column])
     chart.remove(legends: 0)
     wb.addChartsheet(name: name).set(chart: chart)
  }

  wb.close()
  #if os(Windows)
  DispatchQueue.global().asyncAfter(deadline: .now()) { 
    start(currentDirectoryPath() + "/" + name)
  }
  #else
  print(name)
  #endif
}

func handler(request: HTTP.Request) -> HTTP.Response {
  var uri = request.uri
  if uri == "/cancel" {
    source.cancel()
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
    return .init(html: .init(body: plot.svg!, refresh: 20))
  }
  return .init(html: .init(refresh: 10))
}
