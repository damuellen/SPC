import Foundation
import xlsxwriter
import Helpers

var results: [Set<XY>] = [[],[],[]]

#if !os(Windows)
import Swifter
let server = HttpServer()
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

  let name = "SunOl_\(UUID().uuidString.prefix(6)).xlsx"
  let wb = Workbook(name: name)  
  defer { 
    print(name)
    wb.close()
  }

  if CommandLine.argc == 3, let data = try? Data(contentsOf: .init(fileURLWithPath: CommandLine.arguments[2])), 
    let parameter = try? JSONDecoder().decode([Parameter].self, from: data) {
    parameter.forEach { calc(parameter: $0, wb: wb) }
  } else {
    calc(parameter: .init(
      CSP_Loop_Nr: 10...210, PV_DC_Cap: 600...1000, PV_AC_Cap: 400...800, Heater_cap: 100...200, TES_Full_Load_Hours: 12...14,
      EY_Nominal_elec_input: 200...300, PB_Nominal_gross_cap: 100...200, BESS_cap: 20...120, H2_storage_cap: 40...60,
      Meth_nominal_hourly_prod_cap: 14...16, El_boiler_cap: 40...90, grid_max_export: 50...50), wb: wb)  
  }

  func calc(parameter: Parameter, wb: Workbook) {
    var all = parameter.ranges

    let ws = wb.addWorksheet(name: Int(parameter.CSP_Loop_Nr.lowerBound).description)

    dump(parameter, maxDepth: 1)

    if all[1][0] == 0 { all[2] = [0] }

    if all[0][0] == 0 {
      all[3] = [0]
      all[4] = [0]
      all[6] = [0]
    }
    if all[6] == [0] {
      all[4] = [0]
      all[3] = [0]
    }
    var selected = all.compactMap(\.last).map { [$0] }
    var best = [Double]()
    var r = 1
    var hashes = Set<Int>()
    var indices = all.indices.map {$0}
    var shuffled = false
    for _ in 1...25 {
      if source.isCancelled { break }
      for i in indices {
        if source.isCancelled { break }
        selected[i] = all[i]
        if all[i].count == 1 { continue }
        var buffer = Array(CartesianProduct(selected))
        DispatchQueue.concurrentPerform(iterations: buffer.count) {
        // buffer.indices.forEach { 
          var calc = SunOl(values: buffer[$0])
          var pr_meth_plant_op = Array(repeating: 0.4, count: 8760)
          calc(&pr_meth_plant_op, Q_Sol_MW_thLoop, Reference_PV_plant_power_at_inverter_inlet_DC, Reference_PV_MV_power_at_transformer_outlet)
          calc(&pr_meth_plant_op, Q_Sol_MW_thLoop, Reference_PV_plant_power_at_inverter_inlet_DC, Reference_PV_MV_power_at_transformer_outlet)
          calc(&pr_meth_plant_op, Q_Sol_MW_thLoop, Reference_PV_plant_power_at_inverter_inlet_DC, Reference_PV_MV_power_at_transformer_outlet)
          let result = SpecificCost().invest(config: calc)
          buffer[$0].append(result.CAPEX)
          buffer[$0].append(Double(calc.H2_to_meth_production_effective_MTPH_sum))
          buffer[$0].append(result.LCoE)
          buffer[$0].append(result.LCoTh)
          buffer[$0].append(result.LCH2)
          buffer[$0].append(result.LCoM)
          buffer[$0].append(Double(calc.PB_startup_heatConsumption_effective_count))
          buffer[$0].append(Double(calc.TES_discharge_effective_count))
          buffer[$0].append(Double(calc.EY_plant_start_count))
          buffer[$0].append(Double(calc.gross_operating_point_of_EY_count))
          buffer[$0].append(Double(calc.meth_plant_start_count))
          buffer[$0].append(Double(calc.H2_to_meth_production_effective_MTPH_count))
          buffer[$0].append(Double(calc.aux_elec_missing_due_to_grid_limit_sum))
        }
        //if i == 0 { for i in results.indices { results[i].removeAll() } }
        buffer.filter { $0[17] < best[17] }.forEach { 
          results[0].insert(XY(x: $0[12], y: $0[17]))
          results[1].insert(XY(x: $0[13], y: $0[17]))
          results[2].insert(XY(x: $0[0], y: $0[17]))
          ws.write($0, row: r)
          r += 1
        }
        best = buffer.sorted(by: { $0[17] < $1[17] }).first!
        output(best.readable)
        
        selected[i] = [best[i]]
        if selected[i] == [0] {
          all[i] = [0]
          continue
        }
        all[i].shift(half: best[i])
      }

      if hashes.contains(selected.hashValue) {
        indices = all.indices.shuffled()
        // all.indices.filter { all[$0].count > 1 }.forEach { i in 
        //   all[i].shift(half: all[i].last!)
        // }
        break
      }
      hashes.insert(selected.hashValue)
    }
    ws.table(range: [0,0,r,24], header: ["Loops", "PV DC", "PV AC", "Heater", "TES", "EY", "PB", "BESS", "H22", "Meth", "Boiler", "Grid", "CAPEX", "H2_", "LCoE", "LCoTh", "LCH2","LCoM","Other1","Other2","Other3","Other4","Other5","Other6","Other7"])
  }
}
