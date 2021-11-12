import ArgumentParser
import Foundation
import Utilities
import xlsxwriter

signal(SIGINT, SIG_IGN)
let source = DispatchSource.makeSignalSource(signal: SIGINT, queue: .global())
let semaphore = DispatchSemaphore(value: 0)
#if !os(Windows)
var convergenceCurve = [[XY]](repeating: [XY](), count: 3)

import Swifter
let server = HttpServer()
let enc = JSONEncoder()

server["/"] = scopes {
  html {
    meta {
      httpEquiv = "refresh"
      content = "5"
    }
    body { div { inner = Gnuplot(xys: convergenceCurve[0], convergenceCurve[1], convergenceCurve[2], style: .points).svg! } }
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
  },
  true
)
#endif

source.resume()
let now = Date()
Command.main()
print("Elapsed seconds:", -now.timeIntervalSinceNow)
#if os(Windows)
semaphore.signal()
#else
semaphore.wait()
#endif

var Q_Sol_MW_thLoop = [Double]()
var Reference_PV_plant_power_at_inverter_inlet_DC = [Double]()
var Reference_PV_MV_power_at_transformer_outlet = [Double]()

func fitness(values: [Double]) -> [Double] {
  var model = SunOl(values: values)
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
  let result = SpecificCost.invest(model)
  return result
}

func MGOA(group: Bool, n: Int, maxIter: Int, bounds: [ClosedRange<Double>], fitness: ([Double]) -> [Double]) -> [[Double]] {
  var targetResults = [[Double]](repeating: [Double](repeating: 0, count: bounds.count + 13), count: n * maxIter)
  var targetPosition = [[Double]](repeating: [Double](repeating: 0, count: bounds.count), count: group ? 3 : 1)
  var targetFitness = [Double](repeating: .infinity, count: group ? 3 : 1)
  let EPSILON = 1E-14

  // Initialize the population of grasshoppers
  var grassHopperPositions = bounds.randomValues(count: n)
  var grassHopperFitness = [Double](repeating: 0, count: n)
  let groups = grassHopperFitness.indices.split(in: group ? 3 : 1)

  let cMax = 1.0
  let cMin = 0.00004

  print("\u{1B}[H\n\u{1B}[2J\(ASCIIColor.blue.rawValue)Calculate the fitness of initial population.")

  // Calculate the fitness of initial grasshoppers
  DispatchQueue.concurrentPerform(iterations: grassHopperPositions.count) { i in
    let result = fitness(grassHopperPositions[i])
    grassHopperFitness[i] = result[5]
  }
  
  for g in groups.indices {
    // Find the best grasshopper per group (target) in the first population
    for i in groups[g].indices {
      if grassHopperFitness[i] < targetFitness[g] {
        targetFitness[g] = grassHopperFitness[i]
        targetPosition[g] = grassHopperPositions[i]
      }
    }
    #if !os(Windows)
    convergenceCurve[g].append(XY(x: Double(0), y: targetFitness[g]))
    #endif
  }

  print("\u{1B}[H\u{1B}[2J\(ASCIIColor.blue.rawValue)First population:\n\(targetFitness) \(targetPosition)")

  func euclideanDistance(a: [Double], b: [Double]) -> Double {
    var distance = 0.0
    for i in a.indices { distance += pow((a[i] - b[i]), 2) }
    return sqrt(distance)
  }

  func S_func(r: Double) -> Double {
    let f = 0.5
    let l = 1.5
    return f * exp(-r / l) - exp(-r)  // Eq. (2.3) in the paper
  }
  var pos = 0
  var l = 0
  while l < maxIter && !source.isCancelled {
    l += 1
    let c = cMax - (Double(l) * ((cMax - cMin) / Double(maxIter)))  // Eq. (2.8) in the paper

    for g in groups.indices {
      for i in groups[g].indices {
        var S_i = [Double](repeating: 0, count: bounds.count)
        for j in 0..<n {
          if i != j {
            // Calculate the distance between two grasshoppers
            let distance = euclideanDistance(a: grassHopperPositions[i], b: grassHopperPositions[j])
            var r_ij_vec = [Double](repeating: 0, count: bounds.count)
            for p in r_ij_vec.indices {
              r_ij_vec[p] = (grassHopperPositions[j][p] - grassHopperPositions[i][p]) / (distance + EPSILON)  // xj-xi/dij in Eq. (2.7)
            }
            let xj_xi = 2 + distance.remainder(dividingBy: 2)  // |xjd - xid| in Eq. (2.7)

            var s_ij = [Double](repeating: 0, count: bounds.count)
            for p in r_ij_vec.indices {
              // The first part inside the big bracket in Eq. (2.7)
              s_ij[p] = ((bounds[p].upperBound - bounds[p].lowerBound) * c / 2) * S_func(r: xj_xi) * r_ij_vec[p]
            }
            for p in S_i.indices { S_i[p] = S_i[p] + s_ij[p] }
          }
        }

        let S_i_total = S_i
        var X_new = [Double](repeating: 0, count: bounds.count)
        for p in S_i.indices {
          X_new[p] = c * S_i_total[p] + targetPosition[g][p]  // Eq. (2.7) in the paper
        }
        // Update the target
        grassHopperPositions[i] = X_new
      }
    }
    DispatchQueue.concurrentPerform(iterations: grassHopperPositions.count) { i in
      for j in grassHopperPositions[i].indices {
        grassHopperPositions[i][j].clamp(to: bounds[j])
        targetResults[pos + i][j] = grassHopperPositions[i][j]
      }
      let result = fitness(grassHopperPositions[i])
      for r in result.indices { targetResults[pos + i][bounds.count + r] = result[r] }
      grassHopperFitness[i] = result[5]
    }
    pos += grassHopperPositions.count

    for g in groups.indices {
      // Update the target
      for i in groups[g].indices {
        if grassHopperFitness[i] < targetFitness[g] {
          targetFitness[g] = grassHopperFitness[i]
          targetPosition[g] = grassHopperPositions[i]
        }
      }

      #if !os(Windows)
      convergenceCurve[g].append(XY(x: Double(l), y: targetFitness[g]))
      #endif
    }
    // Multi-group strategy
    if group, (l % 10) == 0 {
      for g in groups.indices {
        var o = [0, 1, 2]
        o.remove(at: g)
        for i in groups[g].indices {
          for p in grassHopperPositions[i].indices { 
            grassHopperPositions[i][p] += Double.random(in: 0...1) * (((targetPosition[o[0]][p] + targetPosition[o[1]][p]) / 2) - grassHopperPositions[i][p])
          }
        }
      }
    }

    print("\u{1B}[H\u{1B}[2J\(ASCIIColor.blue.rawValue)Iterations: \(l)\n\(targetFitness) \(targetPosition)")
  }
  return targetResults
}

struct Command: ParsableCommand {

  @Option(name: .short, help: "Input data file") var file: String?

  @Option(name: .short, help: "Parameter file") var json: String?

  @Flag(name: .long, help: "Do not use Multi-group algorithm") var noGroups: Bool = false

  @Option(name: .short, help: "Population size") var n: Int?

  @Option(name: .short, help: "Iterations") var iterations: Int?

  func run() throws {
    let url = URL(fileURLWithPath: file ?? "input.txt")
    guard let csv = CSV(url: url) else { return }

    Q_Sol_MW_thLoop = csv["csp"]
    Reference_PV_plant_power_at_inverter_inlet_DC = csv["pv"]
    Reference_PV_MV_power_at_transformer_outlet = csv["out"]
    let id = String(UUID().uuidString.prefix(6))
    let name = "SunOl_\(id).xlsx"
    let wb = Workbook(name: name)
    let ws = wb.addWorksheet()
    let names = SpecificCost.labels[0..<11]

    var r = 0
    defer {
      print(name)
      ws.table(range: [0, 0, r, SpecificCost.labels.count - 1], header: SpecificCost.labels)
      names.enumerated()
        .forEach { column, name in let chart = wb.addChart(type: .scatter)  //.set(y_axis: 1000...2500)
          chart.addSeries().set(marker: 5, size: 4).values(sheet: ws, range: [1, 17, r, 17]).categories(sheet: ws, range: [1, column, r, column])
          chart.remove(legends: 0)
          wb.addChartsheet(name: name).set(chart: chart)
        }
      wb.close()
    }
    let parameter: [Parameter]
    if let path = json, let data = try? Data(contentsOf: .init(fileURLWithPath: path)), let parameters = try? JSONDecoder().decode([Parameter].self, from: data) {
      parameter = parameters
    } else {
      parameter = [
        Parameter(
          CSP_Loop_Nr: 20...250,
          PV_DC_Cap: 280...1380,
          PV_AC_Cap: 280...1280,
          Heater_cap: 10...500,
          TES_Full_Load_Hours: 8...18,
          EY_Nominal_elec_input: 80...400,
          PB_Nominal_gross_cap: 20...220,
          BESS_cap: 0...1400,
          H2_storage_cap: 10...110,
          Meth_nominal_hourly_prod_cap: 12...30,
          El_boiler_cap: 0...120,
          grid_max_export: 50...50
        )
      ]
    }
    parameter.forEach { parameter in
      MGOA(group: !noGroups, n: n ?? 225, maxIter: iterations ?? 500, bounds: parameter.ranges, fitness: fitness)
        .forEach { row in r += 1
          ws.write(row, row: r)
        }
    }
  }
}
