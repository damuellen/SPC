import ArgumentParser
import Foundation
import Utilities
import xlsxwriter
// import SwiftPlot

let source = DispatchSource.makeSignalSource(signal: SIGINT, queue: .global())
let semaphore = DispatchSemaphore(value: 0)
#if !os(Windows)
print("\u{1b}[1J", terminator: "")
print(tunol)
signal(SIGINT, SIG_IGN)
source.setEventHandler { source.cancel() }
#else
MessageBox(text: "Calculation started.\nhttp://127.0.0.1:9080", caption: "TunOl")
import WinSDK
_ = SetConsoleOutputCP(UINT(CP_UTF8))
SetConsoleCtrlHandler({_ in source.cancel();semaphore.wait();return WindowsBool(true)}, true)
DispatchQueue.global().asyncAfter(deadline: .now() + 3) { start("http://127.0.0.1:9080") }
#endif
#if os(Linux)
try! Gnuplot.process().run()
#endif
var stopwatch = 0
var convergenceCurves = [[[Double]]](repeating: [[Double]](), count: 3)

let server = HTTP { request -> HTTP.Response in var uri = request.uri
  if uri == "/cancel" {
    source.cancel()
    stopwatch = 0
  } else {
    uri.remove(at: uri.startIndex)
  }
  let curves = convergenceCurves.map { Array($0.suffix(Int(uri) ?? 10)) }
  if curves[0].count > 1 {
    let m = curves.map(\.last!).map { $0[1] }.min()
    let i = curves.firstIndex(where: { $0.last![1] == m })!
    /*
    var lineGraph = LineGraph<Float,Float>(enablePrimaryAxisGrid: true)
    lineGraph.addSeries(points: curves[0].map { Pair(Float($0[0]), Float($0[1])) }, label: "Best1")
    lineGraph.addSeries(points: curves[1].map { Pair(Float($0[0]), Float($0[1])) }, label: "Best2")
    lineGraph.addSeries(points: curves[2].map { Pair(Float($0[0]), Float($0[1])) }, label: "Best3")
    lineGraph.plotTitle = PlotTitle("Convergence curves")
    lineGraph.plotLabel = PlotLabel(xLabel: "Iteration", yLabel: "LCoM")
    lineGraph.plotLineThickness = 2.0
    let svg = SVGRenderer()
    lineGraph.drawGraph(renderer: svg)
    */
    let plot = Gnuplot(xys: curves, titles: ["Best1", "Best2", "Best3"])
      .plot(multi: true, index: 0).plot(index: 1).plot(index: 2)
      .plot(multi: true, index: i).plot(index: i, label: 2)
      .set(title: "Convergence curves")
      .set(xlabel: "Iteration").set(ylabel: "LCoM")
    plot.settings["xtics"] = "1"
    return .init(html: .init(body: plot.svg!, refresh: min(stopwatch, 30)))
  }
  return .init(html: .init(refresh: 10))
}

source.resume()
server.start()

let now = Date()

DispatchQueue.global(qos: .background).sync { Command.main() }

print("Elapsed seconds:", -now.timeIntervalSinceNow)

server.stop()
semaphore.signal()

var Q_Sol_MW_thLoop = [Double]()
var Reference_PV_plant_power_at_inverter_inlet_DC = [Double]()
var Reference_PV_MV_power_at_transformer_outlet = [Double]()

func fitness(values: [Double]) -> [Double] {
  var model = TunOl(values)
  let hour0 = model.hour0(Q_Sol_MW_thLoop, Reference_PV_plant_power_at_inverter_inlet_DC, Reference_PV_MV_power_at_transformer_outlet)
  hour0.head(8, steps: 8760)
  let hour1 = model.hour1(hour0: hour0)
  hour1.head(48, steps: 8760)
  let day6 = model.day(hour0: hour0)
  var day = [[Double]]()

  for j in 0..<4 {
    let hour2 = model.hour2(j: j, hour0: hour0, hour1: hour1)
    let hour3 = model.hour3(j: j, hour0: hour0, hour1: hour1, hour2: hour2)
    var day1 = model.day(case: j, hour2: hour2, hour3: hour3)
    let hour4 = model.hour4(j: j, day1: day1, hour0: hour0, hour1: hour1, hour2: hour2)
    model.night(case: j, day1: &day1, hour3: hour3, hour4: hour4)
    let day15 = model.day(hour0: hour0, hour2: hour2, hour3: hour3, day11: day1)
    let day16 = model.day(hour0: hour0, hour4: hour4, day11: day1, day15: day15)
    let day17 = model.day(case: j, day1: day1, day5: day15, day6: day16)
    day.append(day17)
    let day21 = model.day(case: j, hour0: hour0)     
    let day27 = model.day(case: j, day1: day21, day6: day6) 
    day.append(day27)
  }

  return values
}

func MGOADE(group: Bool, n: Int, maxIter: Int, bounds: [ClosedRange<Double>], fitness: ([Double]) -> [Double]) -> [[Double]] {
  #if DEBUG
  let group = false
  let n = 2
  let maxIter = 2
  #endif
  var targetResults = Matrix(n * maxIter, bounds.count + 13)
  var targetPosition = Matrix(group ? 3 : 1, bounds.count)
  var targetFitness = Vector(group ? 3 : 1, .infinity)
  let EPSILON = 1E-14

  // Initialize the population of grasshoppers
  var grassHopperPositions = bounds.randomValues(count: n)
  var grassHopperFitness = Vector(n)
  var grassHopperTrialPositions = grassHopperPositions
  let groups = grassHopperFitness.indices.split(in: group ? 3 : 1)

  let cMax = 1.0
  let cMin = 0.00004
  let cr = 0.4
  let f = 0.9  
  let _ = fitness(grassHopperPositions[0])
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
  print("\u{1b}[1J", terminator: "")
  print("First population:\n\(targetFitness)".text(.green))
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
    var S_i = Vector(bounds.count)
    var r_ij_vec = Vector(bounds.count)
    var s_ij = Vector(bounds.count)
    var X_new = Vector(bounds.count)
    for g in groups.indices {
      for i in groups[g].indices {
        for j in 0..<n {
          if i != j {
            // Calculate the distance between two grasshoppers
            let distance = euclideanDistance(a: grassHopperPositions[i], b: grassHopperPositions[j])
            for p in r_ij_vec.indices {
              r_ij_vec[p] = (grassHopperPositions[j][p] - grassHopperPositions[i][p]) / (distance + EPSILON)  // xj-xi/dij in Eq. (2.7)
            }
            let xj_xi = 2 + distance.remainder(dividingBy: 2)  // |xjd - xid| in Eq. (2.7)
            for p in r_ij_vec.indices {
              // The first part inside the big bracket in Eq. (2.7)
              s_ij[p] = ((bounds[p].upperBound - bounds[p].lowerBound) * c / 2) * S_func(r: xj_xi) * r_ij_vec[p]
            }
            for p in S_i.indices { S_i[p] = S_i[p] + s_ij[p] }
          }
        }

        let S_i_total = S_i
        for p in S_i.indices {
          X_new[p] = c * S_i_total[p] + targetPosition[g][p]  // Eq. (2.7) in the paper
        }
        // Update the target
        grassHopperPositions[i] = X_new
      }
    }
    if l == maxIter { stopwatch = 0 }
    DispatchQueue.concurrentPerform(iterations: grassHopperPositions.count) { i in
      if source.isCancelled { return }
      for j in grassHopperPositions[i].indices {
        grassHopperPositions[i][j].clamp(to: bounds[j])
        targetResults[pos + i][j] = grassHopperPositions[i][j]
      }
      let result = fitness(grassHopperPositions[i])
      targetResults[pos + i].replaceSubrange(bounds.count..., with: result)
      grassHopperFitness[i] = result[5]
    }
    if source.isCancelled { break }
    if l == 1 { stopwatch = Int(-now.timeIntervalSinceNow) }
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

    if refresh {
      DispatchQueue.concurrentPerform(iterations: grassHopperTrialPositions.count) { i in
        if source.isCancelled { return }
        let result = fitness(grassHopperTrialPositions[i])
        if result[5] < grassHopperFitness[i] {
          grassHopperFitness[i] = result[5]
          grassHopperPositions[i] = grassHopperTrialPositions[i]
          targetResults[pos + i].replaceSubrange(0..<bounds.count, with: grassHopperPositions[i])
          targetResults[pos + i].replaceSubrange(bounds.count..., with: result)
        }
      }
    }
    if source.isCancelled { break }
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
    print("Iterations: \(l)\n\(targetFitness)".randomColor())
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
    let path = file ?? "input.txt"
    guard let csv = CSV(atPath: path) else { print("No input."); return }
    Q_Sol_MW_thLoop = [0] + csv["csp"]
    Reference_PV_plant_power_at_inverter_inlet_DC = [0] + csv["pv"]
    Reference_PV_MV_power_at_transformer_outlet = [0] + csv["out"]

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
      names.enumerated().forEach { column, name in let chart = wb.addChart(type: .scatter)  //.set(y_axis: 1000...2500)
        chart.addSeries().set(marker: 5, size: 4)
        .values(sheet: ws, range: [1, 17, r, 17])
        .categories(sheet: ws, range: [1, column, r, column])
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
    BESS_cap_ud: 0...1400, CCU_C_O_2_nom_prod_ud: 10...110, C_O_2_storage_cap_ud: 10...110,
    CSP_loop_nr_ud: 20...250, El_boiler_cap_ud: 10...110, EY_var_net_nom_cons_ud: 10...110,
    Grid_export_max_ud: 50...50, Grid_import_max_ud: 50...50, Hydrogen_storage_cap_ud: 10...110,
    Heater_cap_ud: 10...500, MethDist_Meth_nom_prod_ud: 10...110,
    MethSynt_RawMeth_nom_prod_ud: 10...110, PB_nom_gross_cap_ud: 10...110,
    PV_AC_cap_ud: 280...1280, PV_DC_cap_ud: 280...1380, RawMeth_storage_cap_ud: 10...110,
    TES_full_load_hours_ud: 10...110)
]

    }
    parameter.forEach { parameter in
      let a = MGOADE(group: !noGroups, n: n ?? 150, maxIter: iterations ?? 100, bounds: parameter.ranges, fitness: fitness)
      a.forEach { row in r += 1; ws.write(row, row: r) }
      if r < 2 { return }
      let (x,y) = (12, 17)
      let freq = 10e7
      var d = [Double:[Double]]()
      for i in a.indices {
        let key = (a[i][x] / freq).rounded(.up)
        if let v = d[key] { d[key] = [v[0] + 1, min(v[1], a[i][y]), max(v[2], a[i][y])] } 
        else { d[key] = [1, a[i][y], a[i][y]] }
      }
      d.keys.sorted().map { [$0 * freq] + d[$0]! }.forEach { row in r2 += 1; ws2.write(row, row: r2) }
    }
  }
}
