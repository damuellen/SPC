import Foundation
import xlsxwriter
import Helpers

signal(SIGINT, SIG_IGN)
let source = DispatchSource.makeSignalSource(signal: SIGINT, queue: .global())
let semaphore = DispatchSemaphore(value: 0)
#if !os(Windows)
var results: [Set<XY>] = [[], [], []]

import Swifter
let server = HttpServer()
let enc = JSONEncoder()

// server["/Server/:path"] = shareFilesFromDirectory("/workspaces/SPC/Server")
// server.GET["sankey"] = { _ in try! .ok(.data(enc.encode(sankey(values: values)))) }

server["/"] = scopes {
  html {
    meta {
      httpEquiv = "refresh"
      content = "5"
    }
    body { div { inner = Gnuplot(xys: results[1], style: .points).svg! } }
  }
}

server["/capex"] = scopes {
  html {
    meta {
      httpEquiv = "refresh"
      content = "5"
    }
    body { div { inner = Gnuplot(xys: results[0], style: .points).svg! } }
  }
}

server["/loops"] = scopes {
  html {
    meta {
      httpEquiv = "refresh"
      content = "5"
    }
    body { div { inner = Gnuplot(xys: results[2], style: .points).svg! } }
  }
}

try server.start(9080, forceIPv4: true)

source.setEventHandler {
  server.stop()
  semaphore.signal()
  source.cancel()
}
#else
import WinSDK
_ = SetConsoleOutputCP(UINT(CP_UTF8))
SetConsoleCtrlHandler(
  { _ in source.cancel()
    semaphore.wait()
    return WindowsBool(true)
  }, true)
#endif
source.resume()

let now = Date()
main()

print("Elapsed seconds:", -now.timeIntervalSinceNow)
#if os(Windows)
semaphore.signal()
#else
semaphore.wait()
#endif

func main() {
  guard CommandLine.argc > 1 else { return }
  let url = URL(fileURLWithPath: CommandLine.arguments[1])
  guard let csv = CSV(url: url) else { return }

  let Q_Sol_MW_thLoop: [Double] = csv["csp"]
  let Reference_PV_plant_power_at_inverter_inlet_DC: [Double] = csv["pv"]
  let Reference_PV_MV_power_at_transformer_outlet: [Double] = csv["out"]
  
  let id = String(UUID().uuidString.prefix(6))
  let name = "SunOl_\(id).xlsx"
  let wb = Workbook(name: name)  
  let ws = wb.addWorksheet()
  var r = 1
  defer { 
    print(name)
    ws.table(range: [0,0,r,17], header: SpecificCost.labels)
    wb.close()
  }
  if CommandLine.argc == 3, let data = try? Data(contentsOf: .init(fileURLWithPath: CommandLine.arguments[2])), 
    let parameter = try? JSONDecoder().decode([Parameter].self, from: data) {
    parameter.forEach { calc(parameter: $0, ws: ws, r: &r) }
  } else {
    calc(parameter: .init(
      CSP_Loop_Nr: 10...190, PV_DC_Cap: 280...1200, PV_AC_Cap: 80...1000, Heater_cap: 10...400, TES_Full_Load_Hours: 10...15,
      EY_Nominal_elec_input: 80...450, PB_Nominal_gross_cap: 50...200, BESS_cap: 0...0, H2_storage_cap: 10...100,
      Meth_nominal_hourly_prod_cap: 12...30, El_boiler_cap: 0...100, grid_max_export: 50...50), ws: ws, r: &r)  
  }

  func calc(parameter: Parameter, ws: Worksheet, r: inout Int) {
    var parameter = parameter
    var resultStorage = [Int:[Double]]()
    var configHashes = Set<Int>()
    var bestResult = [Double]()
    var selection = parameter.randomValues(count: 1)
    var steps = 25
    for iter in 1...10 {
      let indices = parameter.ranges.indices.shuffled()
      if source.isCancelled { break }
      let permutations = parameter.steps(count: steps)
      for i in indices {
        if source.isCancelled { break }
        selection[i] = permutations[i]
        defer { selection[i] = [bestResult[i]] }
        if permutations[i].count == 1 { continue }
        var workingBuffer: [[Double]]
        workingBuffer = Array(CartesianProduct(selection))
        DispatchQueue.concurrentPerform(iterations: workingBuffer.count) {
        // workingBuffer.indices.forEach {
          let key = workingBuffer[$0].hashValue
          if let result = resultStorage[key] {
            workingBuffer[$0] = result
          } else {
            var model = SunOl(values: workingBuffer[$0])
            var pr_meth_plant_op = Array(repeating: 0.4, count: 8760)
            #if DEBUG
            var rows = [String](repeating: "", count: 8761)
            #else
            var rows = [String](repeating: "", count: 1)
            #endif
            let input = model(Q_Sol_MW_thLoop, Reference_PV_plant_power_at_inverter_inlet_DC, Reference_PV_MV_power_at_transformer_outlet, rows: &rows)
            model(&pr_meth_plant_op, input.Q_solar_before_dumping, input.PV_MV_power_at_transformer_outlet, input.aux_elec_for_CSP_SF_PV_Plant, rows: &rows)
            model(&pr_meth_plant_op, input.Q_solar_before_dumping, input.PV_MV_power_at_transformer_outlet, input.aux_elec_for_CSP_SF_PV_Plant, rows: &rows)
            model(&pr_meth_plant_op, input.Q_solar_before_dumping, input.PV_MV_power_at_transformer_outlet, input.aux_elec_for_CSP_SF_PV_Plant, rows: &rows)
            #if DEBUG
            try! rows.joined(separator: "\n").write(toFile: "Output_\(id).csv", atomically: false, encoding: .utf8)
            #endif
            workingBuffer[$0].append(contentsOf: SpecificCost.invest(model))
          }
        }

        for result in workingBuffer {
          if resultStorage.updateValue(result, forKey: result[0..<12].hashValue) == nil {
            #if !os(Windows)
            results[0].insert(XY(x: result[12], y: result[17]))
            results[1].insert(XY(x: result[13], y: result[17]))
            results[2].insert(XY(x: result[0], y: result[17]))
            #endif
            // output($0.readable)
            ws.write(result, row: r)
            r += 1
          }
        }

        let sortedResults = workingBuffer.sorted(by: { $0[17] < $1[17] })
        if iter == 1 {
          bestResult = sortedResults.first!
        } else if sortedResults.first![17] < bestResult[17] {
          bestResult = sortedResults.first!
        }
        print("\u{1B}[H\u{1B}[2J\(ASCIIColor.blue.rawValue)Iterations: \(iter)\n\(labeled(bestResult.readable))")
      }
      
      if configHashes.contains(selection.hashValue) {
        if steps > 25 {
          parameter.bisect(selection.compactMap(\.first))
          steps /= 2
          selection = parameter.randomValues(count: 1)
        } else {
          selection = parameter.randomValues(count: 1)
        }
      } else {
        steps *= steps < 100 ? 2 : 1
        configHashes.insert(selection.hashValue)
      }      
    }   
  }
}
