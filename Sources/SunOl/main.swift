import Foundation
import xlsxwriter
import Helpers

var results: [Set<XY>] = [[], [], []]
var values: [Double] = [1]

#if !os(Windows)
import Swifter
let server = HttpServer()
let enc = JSONEncoder()

server["/Server/:path"] = shareFilesFromDirectory("/workspaces/SPC/Server")
server.GET["sankey"] = { _ in try! .ok(.data(enc.encode(sankey(values: values)))) }

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
source.setEventHandler {
  #if !os(Windows)
  server.stop()  
  semaphore.signal()
  #endif
  source.cancel() 
}
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
    ws.table(range: [0,0,r,17], header: [
      "Loops", "PV DC", "PV AC", "Heater", "TES", "EY", "PB", "BESS", "H22", "Meth", "Boiler", "Grid", "CAPEX", "H2_", "LCoE", "LCoTh", "LCH2","LCoM"
    ])
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
    var newParameter = parameter
    var all = newParameter.steps(count: 10)

    // dump(parameter, maxDepth: 1)

    // if all[1][0] == 0 { all[2] = [0] }

    // if all[0][0] == 0 {
    //   all[3] = [0]
    //   all[4] = [0]
    //   all[6] = [0]
    // }
    // if all[6] == [0] {
    //   all[4] = [0]
    //   all[3] = [0]
    // }
    var selected = parameter.random.map { [$0] }
    var best = [Double](repeating: .infinity, count: 30)
    var hashes = Set<Int>()
    var count = 10
    var LCOM = Double.infinity
    for iter in 1...100 {
      let indices = all.indices.shuffled()
      if source.isCancelled { break }
      for i in indices {
        if source.isCancelled { break }
        selected[i] = all[i]
        if all[i].count == 1 { continue }
        var buffer = Array(CartesianProduct(selected))
        DispatchQueue.concurrentPerform(iterations: buffer.count) {
        // buffer.indices.forEach { 
          var model = SunOl(values: buffer[$0])
          var pr_meth_plant_op = Array(repeating: 0.4, count: 8760)
          var rows = [String](repeating: "", count: 8761)
          let input = model(Q_Sol_MW_thLoop, Reference_PV_plant_power_at_inverter_inlet_DC, Reference_PV_MV_power_at_transformer_outlet, rows: &rows)
          model(&pr_meth_plant_op, input.Q_solar_before_dumping, input.PV_MV_power_at_transformer_outlet, input.aux_elec_for_CSP_SF_PV_Plant, rows: &rows)
          model(&pr_meth_plant_op, input.Q_solar_before_dumping, input.PV_MV_power_at_transformer_outlet, input.aux_elec_for_CSP_SF_PV_Plant, rows: &rows)
          let avg = model(&pr_meth_plant_op, input.Q_solar_before_dumping, input.PV_MV_power_at_transformer_outlet, input.aux_elec_for_CSP_SF_PV_Plant, rows: &rows)
          #if DEBUG
          try! rows.joined(separator: "\n").write(toFile: "Output_\(id).csv", atomically: false, encoding: .utf8)
          #endif
          let result = SpecificCost().invest(config: model)
          buffer[$0].append(result.CAPEX)
          buffer[$0].append(Double(model.H2_to_meth_production_effective_MTPH_sum))
          buffer[$0].append(result.LCoE)
          buffer[$0].append(result.LCoTh)
          buffer[$0].append(result.LCH2)
          buffer[$0].append(result.LCoM)
          buffer[$0].append(Double(model.PB_startup_heatConsumption_effective_count))
          buffer[$0].append(Double(model.TES_discharge_effective_count))
          buffer[$0].append(Double(model.EY_plant_start_count))
          buffer[$0].append(Double(model.gross_operating_point_of_EY_count))
          buffer[$0].append(Double(model.meth_plant_start_count))
          buffer[$0].append(Double(model.H2_to_meth_production_effective_MTPH_count))
          buffer[$0].append(Double(model.aux_elec_missing_due_to_grid_limit_sum))
          buffer[$0].append(contentsOf: avg)
        }
        //if i == 0 { for i in results.indices { results[i].removeAll() } }
        buffer.forEach { 
          results[0].insert(XY(x: $0[12], y: $0[17]))
          results[1].insert(XY(x: $0[13], y: $0[17]))
          results[2].insert(XY(x: $0[0], y: $0[17]))
          // output($0.readable)
          ws.write($0, row: r)
          r += 1
        }
        let sorted = buffer.sorted(by: { $0[17] < $1[17] })
        let new = sorted.map { $0[i] }.dropLast(2)
        // print(i, parameter[i])
        newParameter[i] = newParameter[i].clamped(to: (new.min()!...new.max()!))
        
        best = sorted.first!
        
        values = Array(best[25...])
        selected[i] = [best[i]]
        // print(parameter[i], best[i])
        // if selected[i] == [0] {
        //   all[i] = [0]
        //   continue
        // }
        all = parameter.steps(count: count)
      }
      if LCOM > best[17] { LCOM = best[17] }
      
      print(parameter.denormalized(values: selected.compactMap(\.first)).map(\.multiBar).joined(separator: "\n"))
      if LCOM < best[17] || iter.isMultiple(of: 10) || hashes.contains(selected.hashValue) {
        LCOM = Double.infinity
        selected = parameter.random.map { [$0] }
        print("Lets roll!")
      } else {
        hashes.insert(selected.hashValue)
      }      
    }   
  }
}
