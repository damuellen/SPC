import ArgumentParser
import Foundation
import Utilities
import xlsxwriter

signal(SIGINT, SIG_IGN)
let source = DispatchSource.makeSignalSource(signal: SIGINT, queue: .global())

var convergenceCurves = [[[Double]]](repeating: [[Double]](), count: 3)


let server = HTTP() { request in 
  let curves = convergenceCurves.map { Array($0.suffix(10)) }
  let svg = Gnuplot(xys: curves, style: .linePoints).svg!
  return .init(html: .init(body: svg))
}

server.start()
#if !os(Windows)
source.setEventHandler {
  server.stop()
  source.cancel()
}
#else
import WinSDK
_ = SetConsoleOutputCP(UINT(CP_UTF8))
SetConsoleCtrlHandler(
  { _ in server.stop()
    source.cancel()
    return WindowsBool(true)
  },
  true
)
#endif

source.resume()
let now = Date()
Command.main()
print("Elapsed seconds:", -now.timeIntervalSinceNow)
server.stop()

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
  let result = CostModel.invest(model)
  return result
}

func MGOADE(group: Bool, n: Int, maxIter: Int, bounds: [ClosedRange<Double>], fitness: ([Double]) -> [Double]) -> [[Double]] {
  var targetResults = [[Double]](repeating: [Double](repeating: 0, count: bounds.count + 13), count: n * maxIter)
  var targetPosition = [[Double]](repeating: [Double](repeating: 0, count: bounds.count), count: group ? 3 : 1)
  var targetFitness = [Double](repeating: .infinity, count: group ? 3 : 1)
  let EPSILON = 1E-14

  // Initialize the population of grasshoppers
  var grassHopperPositions = bounds.randomValues(count: n)
  var grassHopperFitness = [Double](repeating: 0, count: n)
  var grassHopperTrialPositions = grassHopperPositions
  let groups = grassHopperFitness.indices.split(in: group ? 3 : 1)

  let cMax = 1.0
  let cMin = 0.00004
  let cr = 0.4
  let f = 0.9
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
    convergenceCurves[g].append([Double(0), targetFitness[g]])
  }

  print("\u{1B}[H\u{1B}[2J\(ASCIIColor.blue.rawValue)First population:\n\(targetFitness)")
  print(targetPosition.map(labeled(values:)).joined(separator: "\n"))

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
    if source.isCancelled { break }
    DispatchQueue.concurrentPerform(iterations: grassHopperPositions.count) { i in
      for j in grassHopperPositions[i].indices {
        grassHopperPositions[i][j].clamp(to: bounds[j])
        targetResults[pos + i][j] = grassHopperPositions[i][j]
      }
      let result = fitness(grassHopperPositions[i])
      targetResults[pos + i].replaceSubrange(bounds.count..., with: result)
      grassHopperFitness[i] = result[5]
    }

    var refresh = group
    // Multi-group strategy
    if group, l.isMultiple(of: 2) {
      for g in groups.indices {
        // Update the target
        for i in groups[g].indices {
          var o = [0, 1, 2]
          o.remove(at: g)
          let r1 = groups[o[0]].indices.randomElement()!
          let r2 = groups[o[1]].indices.randomElement()!
          
          for j in grassHopperPositions[i].indices {
            if Double.random(in: 0...1) < cr {
              grassHopperTrialPositions[i][j] =
                targetPosition[g][j] + f * (.random(in: 0...1) + 0.0001) * (grassHopperPositions[r1][j] - grassHopperPositions[r2][j])
              grassHopperTrialPositions[i][j].clamp(to: bounds[j])
            }
          }
        }
      }
    } else if group {
      for g in groups.indices {
        var o = [0, 1, 2]
        o.remove(at: g)
        for i in groups[g].indices {
          for p in grassHopperPositions[i].indices {
            grassHopperTrialPositions[i][p] += .random(in: 0...1) * (((targetPosition[o[0]][p] + targetPosition[o[1]][p]) / 2) - grassHopperPositions[i][p])
            grassHopperTrialPositions[i][p].clamp(to: bounds[p])
          }
        }
      }
    } else { refresh = false }

    if source.isCancelled { break }
    if refresh {
      DispatchQueue.concurrentPerform(iterations: grassHopperTrialPositions.count) { i in
        let result = fitness(grassHopperTrialPositions[i])
        if result[5] < grassHopperFitness[i] {
          grassHopperFitness[i] = result[5]
          grassHopperPositions[i] = grassHopperTrialPositions[i]
          targetResults[pos + i].replaceSubrange(0..<bounds.count, with: grassHopperPositions[i])
          targetResults[pos + i].replaceSubrange(bounds.count..., with: result)
        }
      }
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
      convergenceCurves[g].append([Double(l), targetFitness[g]])
    }

    print("\u{1B}[H\u{1B}[2J\(ASCIIColor.blue.rawValue)Iterations: \(l)\n\(targetFitness)")
    print(targetPosition.map(labeled(values:)).joined(separator: "\n"))
    if (targetFitness.reduce(0, +) / 3) - targetFitness.min()! < 0.001 { break }
  }
  targetResults.removeLast((maxIter - l) * n)
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
    let ws2 = wb.addWorksheet()
    let names = CostModel.labels[0..<11]

    var r = 0
    var r2 = 0
    defer {
      print(name)
      ws.table(range: [0, 0, r, CostModel.labels.count - 1], header: CostModel.labels)
      names.enumerated()
        .forEach { column, name in let chart = wb.addChart(type: .scatter)  //.set(y_axis: 1000...2500)
          chart.addSeries().set(marker: 5, size: 4).values(sheet: ws, range: [1, 17, r, 17]).categories(sheet: ws, range: [1, column, r, column])
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
      try! Gnuplot(xys: convergenceCurves, style: .lines(smooth: false))(.pngLarge(path: "SunOl_\(id).png"))
    }

    let parameter: [Parameter]
    if let path = json, let data = try? Data(contentsOf: .init(fileURLWithPath: path)), 
      let parameters = try? JSONDecoder().decode([Parameter].self, from: data) {
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
      let a = MGOADE(group: !noGroups, n: n ?? 150, maxIter: iterations ?? 100, bounds: parameter.ranges, fitness: fitness)
      a.forEach { row in r += 1; ws.write(row, row: r) }

      let (x,y) = (12, 17)
      let freq = 10e7
      var d = [Double:[Double]]()
      for i in a.indices {
        let key = (a[i][x] / freq).rounded(.up)
        if let v = d[key] { d[key] = [v[0] + 1, min(v[1], a[i][y]), max(v[2], a[i][y])] } 
        else { d[key] = [1, a[i][y], a[i][y]] }
      }
      d.keys.sorted().map { [$0 * freq] + d[$0]! }.forEach { row in r2 += 1; ws2.write(row, row: r2) }
      try? Gnuplot(xys: pareto_frontier(xys: a, x: x, y: y))(.pngLarge(path: "pareto_frontier.png"))
    }
  }
}
