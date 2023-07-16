import ArgumentParser
import Foundation
import SunOl
import Utilities
import Web
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
    if let file = file { path = file } else { path = FileDialog() ?? "input5.txt" }
    #else
    path = file ?? "input5.txt"
    #endif
    guard let csv = CSVReader(atPath: path) else {
      #if os(Windows)
      MessageBox(text: "No input.", caption: "TunOl")
      #else
      print("No input.")
      #endif
      return
    }
    TunOl.Q_Sol_MW_thLoop = [0] + csv["csp"]
    TunOl.Reference_PV_plant_power_at_inverter_inlet_DC = [0] + csv["pv"]
    TunOl.Reference_PV_MV_power_at_transformer_outlet = [0] + csv["out"]

    let server = HTTP(handler: respond)
    if http {
      server.start()
      print("web server listening on port \(server.port)")
      DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) { 
        start("http://127.0.0.1:\(server.port)") 
      }
    }

    defer {
      if http {
        source.cancel()
        if -timeout.timeIntervalSinceNow < 10 {
          print("waiting before shutting down")
          Thread.sleep(until: timeout.addingTimeInterval(10))
          Thread.sleep(forTimeInterval: 1)
        }
        server.stop()
      }
    }
    let past = Date()
    let id = String(Int(past.timeIntervalSince1970), radix: 36, uppercase: true).suffix(4)
    if let parameter = try? InputParameter.loadFromJSONIfExists(file: .init(fileURLWithPath: path)) {
      let worker = IGOA(n: n ?? 30, maxIterations: iterations ?? 300, bounds: parameter.ranges)
      let results = worker(SunOl.fitness)
      print("Elapsed seconds:", -past.timeIntervalSinceNow)
      let name = "SunOl_\(id).xlsx"
      writeExcel(name, results: [Int(parameter.ranges[5].lowerBound):results])    
      print(name)
      #if os(Windows)
      if excel { start(currentDirectoryPath() + "/" + name) }
      #endif
    }

    // try? InputParameter(ranges: ranges).storeToJSON(file: .init(fileURLWithPath: "Parameter.json"))
    var parameter = Parameter()
    var resultsA = Tables()
    for EY in stride(from: 100, through: 300, by: 20).reversed() where !source.isCancelled {
      var results = Table()
      for _ in 1...3 where !source.isCancelled {
        parameter.ranges[5] = Double(EY)...Double(EY)
        let worker = IGOA(n: n ?? 45, maxIterations: iterations ?? 180, bounds: parameter.ranges)
        let result = worker(SunOl.fitnessPenalized)
        results.append(contentsOf: result)
      }
      results = removingNearby(results.filter { $0[0].isFinite }.sorted { $0[0] < $1[0] })
      resultsA[EY] = Array(results.prefix(5000))
    }

    writeExcel("SunOl_\(id).xlsx", results: resultsA)
/*
    var resultsB = Tables()
    for EY in stride(from: 140, through: 280, by: 20) where !source.isCancelled {
      var results = Table()
      for _ in 1...10 where !source.isCancelled {
        parameter.ranges[5] = Double(EY)...Double(EY)
        let worker = IGOA(n: n ?? 60, maxIterations: iterations ?? 270, bounds: parameter.ranges)
        let result = worker(SunOl.fitnessPenalized)
        results.append(contentsOf: result)
      }
      results = removingNearby(results.filter { $0[0].isFinite }.sorted { $0[0] < $1[0] })
      resultsB[EY] = Array(results.prefix(1000))
    }
    
    writeExcel("SunOl_\(id).xlsx", results: resultsB)
*/
    // parameter = Parameter(
    //   CSP_loop_nr: 0...0.0,
    //   TES_thermal_cap: 0...0.0,
    //   PB_nom_gross_cap: 0...0.0,
    //   El_boiler_cap: 0...100.0,
    //   EY_var_net_nom_cons: 180...180,
    //   Heater_cap: 0...0.0
    // )
    // var resultsC = Tables()
    // for EY in stride(from: 220, through: 300, by: 20) where !source.isCancelled {
    //   var results = Table()
    //   for _ in 1...5 where !source.isCancelled {
    //     parameter.ranges[5] = Double(EY)...Double(EY)
    //     let worker = IGOA(n: n ?? 30, maxIterations: iterations ?? 270, bounds: parameter.ranges)
    //     results.append(contentsOf: worker(SunOl.fitness))
    //   }
    //   results = removingNearby(results.filter { $0[0].isFinite }.sorted { $0[0] < $1[0] })
    //   resultsC[EY] = Array(results.prefix(1000))
    // }
    // writeExcel("SunOl_\(id)_PV_only.xlsx", results: resultsC)
    // writeExcel("SunOl_\(id)_All.xlsx", results: resultsA, resultsB, resultsC)
  }
}

func writeCSV(result: ([Double], [Double], [Double], [Double])) {
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

func removingNearby(_ results: Table) -> Table {
  var addedDict = [Int:Bool]()
  return results.filter {
    addedDict.updateValue(true, forKey: Int($0[1] * 10)) == nil
  }
} 

func writeExcel(_ name: String, results: Tables...) {
  let wb = Workbook(name: name)
  let ws = wb.addWorksheet()
  var cursor = 1
  var smallest = Double.infinity
  for r in results {
    let result = Array(r.keys.sorted().map { r[$0]! }.joined())
    for (row, n) in zip(result, cursor...) { 
      ws.write(row.map { round($0 * 100) / 100 }, row: n)
      smallest = min(smallest, row[0])
    }
    cursor += result.count
  }
  smallest = (smallest / 50).rounded(.down) * 50
  let labels = [
    "LCOM", "LCOM2", "CAPEX", "OPEX", "Methanol", "Import", "Export", "Hours", "CSP_loop_nr", "TES_thermal_cap_ud", "PB_nom_gross_cap", "PV_AC_cap", "PV_DC_cap", "EY_var_net_nom_cons", "Hydrogen_storage_cap", "Heater_cap", "CCU_CO2_nom_prod", "CO2_storage_cap", "RawMeth_storage_cap",
    "MethDist_Meth_nom_prod", "El_boiler_cap", "BESS_cap", "Grid_export_max", "Grid_import_max", "Iteration"
  ]
  ws.table(range: [0, 0, cursor-1, labels.endIndex - 1], header: labels)

  let charting = [2, 4, 7, 8, 9, 10, 11, 12, 13, 15, 19, 20, 21]
  for (column, name) in labels.enumerated() where charting.contains(column) {
    let chart = wb.addChart(type: .scatter)
      .set(y_axis: smallest...(smallest*1.20))
      .major_unit(.Y, 10.0)
    var start = 1
    for r in results {
      let end = start + r.keys.sorted().map { r[$0]!.count }.reduce(-1, +)
      chart.addSeries().set(marker: 6, size: 4).values(sheet: ws, range: [start, 1, end, 1]).categories(sheet: ws, range: [start, column, end, column])
      chart.addSeries().set(marker: 5, size: 4).values(sheet: ws, range: [start, 0, end, 0]).categories(sheet: ws, range: [start, column, end, column])
      start = end + 1
    }
    chart.remove(legends: 0, 1, 2)
    wb.addChartsheet(name: name).set(chart: chart)
  }
  wb.close()
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
    return .init(html: .init(body: plot.svg(), refresh: source.isCancelled ? 0:10))
  }
  return .init(html: .init(refresh: 10))
}

typealias Row = [Double]
typealias Table = [Row]
typealias Tables = [Int:Table]