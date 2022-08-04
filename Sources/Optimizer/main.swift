import ArgumentParser
import Foundation
import SunOl
import Utilities
import xlsxwriter

let source = DispatchSource.makeSignalSource(signal: SIGINT, queue: .global())
let semaphore = DispatchSemaphore(value: 0)
var timeout = Date()

ClearScreen()
#if os(Windows)
import WinSDK
_ = SetConsoleOutputCP(UINT(CP_UTF8))
SetConsoleCtrlHandler({_ in source.cancel();semaphore.wait();return WindowsBool(true)}, true)
#else
print(tunol)
signal(SIGINT, SIG_IGN)
source.setEventHandler { source.cancel() }
#endif

source.resume()

Command.main()

semaphore.signal()

struct Command: ParsableCommand {
  @Option(name: .short, help: "Input data file") var file: String?

  @Option(name: .short, help: "Parameter file") var json: String?

  @Flag(name: .long, help: "Do not use Multi-group algorithm") var noGroups = false

  @Flag(name: .long, help: "Run HTTP server") var http = false
  #if os(Windows)
  @Flag(name: .long, help: "Start excel afterwards") var excel = false
  #endif
  @Option(name: .short, help: "Population size") var n: Int?

  @Option(name: .short, help: "Iterations") var iterations: Int?

  func run() throws {
    let path: String
    #if os(Windows)
    if let file = file { path = file } else { path = FileDialog() ?? "input2.txt" }
    #else
    path = file ?? "input2.txt"
    #endif
    guard let csv = CSVReader(atPath: path) else {
      #if os(Windows)
      MessageBox(text: "No input.", caption: "TunOl")
      #else
      print("No input.")
      #endif
      return
    }
    let parameter: Parameter
    if let path = json, let data = try? Data(contentsOf: .init(fileURLWithPath: path)),
     let parameters = try? JSONDecoder().decode(Parameter.self, from: data) {
      parameter = parameters
    } else {
      parameter = Parameter(
        BESS_cap_ud: 0...0,
        CCU_CO2_nom_prod_ud: 1000...1000,
        CO2_storage_cap_ud: 100_000...100_000,
        CSP_loop_nr_ud: 20...300,
        El_boiler_cap_ud: 0...30,
        EY_var_net_nom_cons_ud: 200...200,
        Grid_export_max_ud: 0...0,
        Grid_import_max_ud: 0...0,
        Hydrogen_storage_cap_ud: 0...0, 
        Heater_cap_ud: 0...600, 
        MethDist_Meth_nom_prod_ud: 5...40,
        // MethSynt_RawMeth_nom_prod_ud: 10...60,
        PB_nom_gross_cap_ud: 10...200, 
        PV_AC_cap_ud: 100...1500, 
        PV_DC_cap_ud: 100...1600, 
        RawMeth_storage_cap_ud: 100_000...100_000, 
        TES_thermal_cap_ud: 500...20_000)
      let data = try? JSONEncoder().encode(parameter)
      try? data?.write(to: "parameter.txt")
    }

    let server = HTTP(handler: respond)
    if http {
      server.start()
      print("web server listening on port \(server.port)")
      DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) { 
        start("http://127.0.0.1:\(server.port)") 
      }
    }
    TunOl.Q_Sol_MW_thLoop = [0] + csv["csp"].map(Float.init)
    TunOl.Reference_PV_plant_power_at_inverter_inlet_DC = [0] + csv["pv"].map(Float.init)
    TunOl.Reference_PV_MV_power_at_transformer_outlet = [0] + csv["out"].map(Float.init)

    let optimizer = MGOADE(group: !noGroups, n: n ?? 90, maxIterations: iterations ?? 30, bounds: parameter.ranges)
    let now = Date()
    let valid = optimizer(SunOl.fitness).filter(\.first!.isFinite)
    print("Elapsed seconds:", -now.timeIntervalSinceNow)
    let name = writeExcel(results: valid)
    print(name)
    // if !source.isCancelled {
    //   var best = Array(sorted[0][6...])
    //   best.remove(at: 10)
    //   let result = SunOl.results(values: best)
    //   writeCSV(result: result)
    // }
    if http {
      source.cancel()
      if -timeout.timeIntervalSinceNow < 10 {
        print("waiting before shutting down")
        Thread.sleep(until: timeout.addingTimeInterval(10))
        Thread.sleep(forTimeInterval: 1)
      }
      server.stop()
    }
    #if os(Windows)
    if excel { start(currentDirectoryPath() + "/" + name) }
    #endif
  }
}

func writeCSV(result: ([Float], [Float], [Float], [Float])) {
  var hour = ""
  let v1 = result.1
  for n in 1..<8760 {
    let row = stride(from: n, to: v1.endIndex, by: 8760).lazy.map { String(v1[$0]) }.joined(separator: "\t")
    print(row, to: &hour)
  }
  try? hour.write(toFile: "out1.csv", atomically: false, encoding: .ascii)
  hour = ""
  let v2 = result.2
  for n in 0..<365 {
    let row = stride(from: n, to: v2.endIndex, by: 365).lazy.map { String(v2[$0]) }.joined(separator: "\t")
    print(row, to: &hour)
  }
  try? hour.write(toFile: "out2.csv", atomically: false, encoding: .ascii)
  hour = ""
  let v3 = result.3
  for n in 0..<365 {
    let row = stride(from: n, to: v3.endIndex, by: 365).lazy.map { String(v3[$0]) }.joined(separator: "\t")
    print(row, to: &hour)
  }
  try? hour.write(toFile: "out3.csv", atomically: false, encoding: .ascii)
}

func writeExcel(results: [[Float]]) -> String {
  let name = "SunOl_\(UUID().uuidString.prefix(4)).xlsx"
  let wb = Workbook(name: name)
  let ws = wb.addWorksheet()
  var r = 0
  var lowest = Float.infinity
  results.reversed().forEach { row in r += 1
    if lowest > row[1] {
      lowest = row[1]
    }
    ws.write(row.map(Double.init), row: r)
  }
  let labels = [
    "LCOM", "LCOM2", "CAPEX", "OPEX", "Methanol", "Import", "Export", "Hours", "CSP_loop_nr", "TES_thermal_cap_ud", "PB_nom_gross_cap", "PV_AC_cap", "PV_DC_cap", "EY_var_net_nom_cons", "Hydrogen_storage_cap", "Heater_cap", "CCU_CO2_nom_prod", "CO2_storage_cap", "RawMeth_storage_cap",
    "MethDist_Meth_nom_prod", "El_boiler_cap", "BESS_cap", "Grid_export_max", "Grid_import_max",
  ]

  lowest = (lowest / 50).rounded(.down) * 50
  ws.table(range: [0, 0, r, labels.endIndex - 1], header: labels)
  for (column, name) in labels.enumerated() {
    if column < 7 { continue }
    let chart = wb.addChart(type: .scatter).set(y_axis: Double(lowest)...Double(lowest+500))
    chart.addSeries().set(marker: 5, size: 4)
    .values(sheet: ws, range: [1, 1, r, 1])
    .categories(sheet: ws, range: [1, column, r, column])
    chart.remove(legends: 0)
    wb.addChartsheet(name: name).set(chart: chart)
  }
  wb.close()
  return name
}

func respond(request: HTTP.Request) -> HTTP.Response {
  var uri = request.uri
  if uri == "/cancel" {
    source.cancel()
  } else {
    uri.remove(at: uri.startIndex)
    timeout = Date()
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
    return .init(html: .init(body: plot.svg!, refresh: source.isCancelled ? 0:10))
  }
  return .init(html: .init(refresh: 10))
}

