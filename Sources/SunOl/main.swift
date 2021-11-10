import Foundation
import Utilities
import xlsxwriter

signal(SIGINT, SIG_IGN)
let source = DispatchSource.makeSignalSource(signal: SIGINT, queue: .global())
let semaphore = DispatchSemaphore(value: 0)
#if !os(Windows)
var convergenceCurve: [XY] = []

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
    body { div { inner = Gnuplot(xys: convergenceCurve, style: .points).svg! } }
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

var Q_Sol_MW_thLoop = [Double]()
var Reference_PV_plant_power_at_inverter_inlet_DC = [Double]()
var Reference_PV_MV_power_at_transformer_outlet = [Double]()

func main() {
  guard CommandLine.argc > 1 else { return }
  let url = URL(fileURLWithPath: CommandLine.arguments[1])
  guard let csv = CSV(url: url) else { return }

  Q_Sol_MW_thLoop = csv["csp"]
  Reference_PV_plant_power_at_inverter_inlet_DC = csv["pv"]
  Reference_PV_MV_power_at_transformer_outlet = csv["out"]
  let id = String(UUID().uuidString.prefix(6))
  let name = "SunOl_\(id).xlsx"
  let wb = Workbook(name: name)
  let ws = wb.addWorksheet()
  var r = 1
  defer {
    print(name)
    ws.table(range: [0, 0, r, SpecificCost.labels.count - 1], header: SpecificCost.labels)
    wb.close()
  }
  let parameter: [Parameter]
  if CommandLine.argc == 3, let data = try? Data(contentsOf: .init(fileURLWithPath: CommandLine.arguments[2])),
  let parameters = try? JSONDecoder().decode([Parameter].self, from: data) {
    parameter = parameters
  } else {
    parameter = [
      Parameter(
        CSP_Loop_Nr: 20...220,
        PV_DC_Cap: 280...1280,
        PV_AC_Cap: 280...1280,
        Heater_cap: 10...500,
        TES_Full_Load_Hours: 9...16,
        EY_Nominal_elec_input: 80...500,
        PB_Nominal_gross_cap: 20...250,
        BESS_cap: 0...0,
        H2_storage_cap: 10...110,
        Meth_nominal_hourly_prod_cap: 12...30,
        El_boiler_cap: 0...120,
        grid_max_export: 50...50
      )
    ]
  }
  parameter.forEach { parameter in 
    let history = GOA(n: 200, maxIter: 100, bounds: parameter.ranges, fitness: fitness)
    for population in zip(history.fitness, history.positions).map({ fitness, position in 
      fitness.indices.map { i in [fitness[i]] + position[i] } }) {
      for generation in population where !generation[0].isZero {
        ws.write(generation, row: r, col: 0)
        r += 1
      }
    }
  }
}

func fitness(values: [Double]) -> Double {
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
  return result[5]
}

func GOA(n: Int, maxIter: Int, bounds: [ClosedRange<Double>], fitness: ([Double]) -> Double) -> (fitness: [[Double]], positions: [[[Double]]]) {
  // var convergenceCurve = [Double](repeating: 0, count: maxIter)
  // var trajectories = [[Double]](repeating: [Double](repeating: 0, count: maxIter), count: n)
  var fitnessHistory = [[Double]](repeating: [Double](repeating: 0, count: maxIter), count: n)
  var positionHistory = [[[Double]]](repeating: [[Double]](repeating: [Double](repeating: 0, count: bounds.count), count: maxIter), count: n)
  var targetPosition = [Double]()
  var targetFitness = Double.infinity
  let EPSILON = 1E-14

  // Initialize the population of grasshoppers
  var grassHopperPositions = bounds.randomValues(count: n)
  var grassHopperFitness = [Double](repeating: 0, count: n)

  let cMax = 1.0
  let cMin = 0.00004

  print("\u{1B}[H\n\u{1B}[2J\(ASCIIColor.blue.rawValue)Calculate the fitness of initial population.")

  // Calculate the fitness of initial grasshoppers
  DispatchQueue.concurrentPerform(iterations: grassHopperPositions.count) { i in
    // for i in grassHopperPositions.indices {
    grassHopperFitness[i] = fitness(grassHopperPositions[i])

    fitnessHistory[i][0] = grassHopperFitness[i]
    positionHistory[i][0] = grassHopperPositions[i]// trajectories[i][0] = grassHopperPositions[i][0]
  }
  // Find the best grasshopper (target) in the first population
  for i in grassHopperFitness.indices {
    if grassHopperFitness[i] < targetFitness {
      targetFitness = grassHopperFitness[i]
      targetPosition = grassHopperPositions[i]
    }
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

  var l = 0
  convergenceCurve.append(XY(x: Double(l), y: targetFitness))
  while l < maxIter && !source.isCancelled {

    let c = cMax - (Double(l) * ((cMax - cMin) / Double(maxIter)))  // Eq. (2.8) in the paper

    for i in grassHopperPositions.indices {
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
        X_new[p] = c * S_i_total[p] + targetPosition[p]  // Eq. (2.7) in the paper
      }
      grassHopperPositions[i] = X_new
    }

    DispatchQueue.concurrentPerform(iterations: grassHopperPositions.count) { i in for j in grassHopperPositions[i].indices { grassHopperPositions[i][j].clamp(to: bounds[j]) }
      grassHopperFitness[i] = fitness(grassHopperPositions[i])

      fitnessHistory[i][l] = grassHopperFitness[i]
      positionHistory[i][l] = grassHopperPositions[i]
      // trajectories[i][l] = grassHopperPositions[i][l]

      // Update the target
      if grassHopperFitness[i] < targetFitness {
        targetPosition = grassHopperPositions[i]
        targetFitness = grassHopperFitness[i]
      }
    }
    // convergenceCurve[l] = targetFitness
    #if !os(Windows)
    convergenceCurve.append(XY(x: Double(l), y: targetFitness))
    #endif
    l += 1
    print("\u{1B}[H\u{1B}[2J\(ASCIIColor.blue.rawValue)Iterations: \(l)\n\(targetFitness) \(targetPosition)")
  }
  return (fitnessHistory, positionHistory)
}
