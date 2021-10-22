import Foundation
import xlsxwriter
import Helpers

var results: [Set<XY>] = [[], [], []]

#if !os(Windows)
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
let semaphore = DispatchSemaphore(value: 0)
#endif
signal(SIGINT, SIG_IGN)
let source = DispatchSource.makeSignalSource(signal: SIGINT, queue: .global())
#if !os(Windows)
source.setEventHandler {
  server.stop()
  semaphore.signal()
  source.cancel()
}
#else
import WinSDK
SetConsoleCtrlHandler(
  { _ in source.cancel()
    return WindowsBool(true)
  }, true)
#endif
source.resume()

let now = Date()
main()

print("Elapsed seconds:", -now.timeIntervalSinceNow)
#if !os(Windows)
semaphore.wait()
#endif

func main() {
  guard CommandLine.argc > 1 else { return }
  let url = URL(fileURLWithPath: CommandLine.arguments[1])
  guard let dataFile = DataFile(url) else { return }

  var Q_Sol_MW_thLoop: [Double] = [0]
  var Reference_PV_plant_power_at_inverter_inlet_DC: [Double] = [0]
  var Reference_PV_MV_power_at_transformer_outlet: [Double] = [0]

  for data in dataFile.data {
    Q_Sol_MW_thLoop.append(Double(data[0]))
    Reference_PV_plant_power_at_inverter_inlet_DC.append(Double(data[1]))
    Reference_PV_MV_power_at_transformer_outlet.append(Double(data[2]))
  }
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
      CSP_Loop_Nr: 10...190, PV_DC_Cap: 280...1200, PV_AC_Cap: 280...1200, Heater_cap: 10...400, TES_Full_Load_Hours: 10...15,
      EY_Nominal_elec_input: 80...400, PB_Nominal_gross_cap: 10...150, BESS_cap: 0...1470, H2_storage_cap: 10...100,
      Meth_nominal_hourly_prod_cap: 12...30, El_boiler_cap: 0...100, grid_max_export: 0...50), ws: ws, r: &r)  
  }

  func calc(parameter: Parameter, ws: Worksheet, r: inout Int) {
    let steps = 10

    var newParameter = parameter

    var selection = parameter.randomValues.map { [$0] }
    var resultStorage = [Int:[Double]]()
    var configHashes = Set<Int>()
    var bestResult = [Double]()
    for iter in 1...500 {
      print("\u{1B}[1A\u{1B}[\u{1B}[1A\u{1B}[K\(ASCIIColor.blue.rawValue)Iterations: \(iter)\n\(labeled(bestResult.readable))")
      let indices = parameter.ranges.indices.shuffled()
      if source.isCancelled { break }
      let permutations = newParameter.steps(count: steps)
      for i in indices {
        if source.isCancelled { break }
        selection[i] = permutations[i]
        if permutations[i].count == 1 { continue }
        var workingBuffer = Array(CartesianProduct(selection))
        DispatchQueue.concurrentPerform(iterations: workingBuffer.count) {
        // workingBuffer.indices.forEach {
          let key = workingBuffer[$0].hashValue
          if let result = resultStorage[key] {
            workingBuffer[$0] = result
          } else {
            var model = SunOl(values: workingBuffer[$0])
            var pr_meth_plant_op = Array(repeating: 0.4, count: 8760)
            var rows = [String](repeating: "", count: 8761)
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
            results[0].insert(XY(x: result[12], y: result[17]))
            results[1].insert(XY(x: result[13], y: result[17]))
            results[2].insert(XY(x: result[0], y: result[17]))
            // output($0.readable)
            ws.write(result, row: r)
            r += 1
          }
        }

        let sortedResults = workingBuffer.sorted(by: { $0[17] < $1[17] })
        let newRange = sortedResults.map { $0[i] }.dropLast(2)
        newParameter[i] = newParameter[i].clamped(to: (newRange.min()!...newRange.max()!))
        bestResult = sortedResults.first!        
        selection[i] = [bestResult[i]]        
      }


      if configHashes.contains(selection.hashValue) {
        configHashes.removeAll()
        newParameter = parameter
        selection = parameter.randomValues.map { [$0] }
        print("Lets roll!")
      } else {
        configHashes.insert(selection.hashValue)
      }      
    }   
  }
}
