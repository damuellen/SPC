import Foundation
import Utilities

public let source = DispatchSource.makeSignalSource(signal: SIGINT, queue: .global())
public let semaphore = DispatchSemaphore(value: 0)

public func fitness(values: [Double]) -> [Double] {
  guard let model = TunOl(values) else { return [Double.infinity] + values }
  let costs = Costs(model)
  //dump(costs)
  //TunOl.Grid_import_yes_no_BESS_strategy = 0
  //TunOl.Grid_import_yes_no_PB_strategy = 0
  //dump(model)
  let hour0 = model.hour0(TunOl.Q_Sol_MW_thLoop, TunOl.Reference_PV_plant_power_at_inverter_inlet_DC, TunOl.Reference_PV_MV_power_at_transformer_outlet)
  let hour1 = model.hour1(hour0: hour0)
  let day0 = model.day0(hour0: hour0)
  let day6 = model.day26(hour0: hour0)
  var day = [[Double]]()

  var hour2 = [Double](repeating: .zero, count: 183_960)
  var hour3 = [Double](repeating: .zero, count: 271_560)
  var hour4 = [Double](repeating: .zero, count: 490560 + 8760)
  var day1 = [Double](repeating: .zero, count: 13_140)
  var day15 = [Double](repeating: .zero, count: 17_155)
  var day16 = [Double](repeating: .zero, count: 17_155)
  var day17 = [Double](repeating: .zero, count: 46_720)
  var day27 = [Double](repeating: .zero, count: 47_815)
  var day21 = [Double](repeating: .zero, count: 9_855)

  for j in 0..<4 {
    model.hour2(&hour2, j: j, hour0: hour0, hour1: hour1)
    model.hour3(&hour3, j: j, hour0: hour0, hour1: hour1, hour2: hour2)
    model.day1(&day1, case: j, hour2: hour2, hour3: hour3)
    model.hour4(&hour4, j: j, day1: day1, hour0: hour0, hour1: hour1, hour2: hour2)
    model.night(case: j, day1: &day1, hour3: hour3, hour4: hour4)
    model.day15(&day15, hour0: hour0, hour2: hour2, hour3: hour3, day11: day1)
    model.day16(&day16, hour0: hour0, hour4: hour4, day11: day1, day15: day15)
    model.day17(&day17, case: j, day1: day1, day5: day15, day6: day16)

    day.append(Array(day17[31755..<32850]))
    day.append(Array(day17[44165..<45625]))

    model.day21(&day21, case: j, day0: day0)
    model.day27(&day27, case: j, day0: day0, day1: day21, day6: day6)

    day.append(Array(day27[33945..<35040]))
    day.append(Array(day27[44895..<45990]))
  }

  var meth_produced_MTPH_sum = Double.zero
  var elec_from_grid_sum = Double.zero
  var elec_to_grid_MTPH_sum = Double.zero
  var counter = 365
  for d in 0..<365 {
    let cases = day.indices.map { i in costs.LCOM(meth_produced_MTPH: day[i][d] * 365.0, elec_from_grid: day[i][d + 365 + 365] * 365.0, elec_to_grid: day[i][d + 365] * 365.0) }
    let best = cases.indices.filter { cases[$0].isFinite }.filter { cases[$0] > 0 }.sorted { cases[$0] < cases[$1] }.first
    if let best = best {
      counter -= 1
      meth_produced_MTPH_sum += day[best][d]
      elec_from_grid_sum += day[best][d + 365 + 365]
      elec_to_grid_MTPH_sum += day[best][d + 365]
    }
  }
  let LCOM = costs.LCOM(meth_produced_MTPH: meth_produced_MTPH_sum, elec_from_grid: elec_from_grid_sum, elec_to_grid: elec_to_grid_MTPH_sum)
  if counter > 100 || LCOM < 666 || LCOM.isInfinite || meth_produced_MTPH_sum.isZero { return [Double.infinity] + values }
  return [LCOM] + values
}

public func MGOADE(group: Bool, n: Int, maxIter: Int, bounds: [ClosedRange<Double>], fitness: ([Double]) -> [Double]) -> [[Double]] {
  var targetResults = Matrix(n * maxIter, bounds.count + 1)
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
  let date = Date()
  let dummy = fitness([])
  TunOl.convergenceCurves[0].append([Double(0), dummy[0]])
  TunOl.convergenceCurves[1].append([Double(0), dummy[0]])
  TunOl.convergenceCurves[2].append([Double(0), dummy[0]])
  print(-date.timeIntervalSinceNow)
  // Calculate the fitness of initial grasshoppers
  let date2 = Date()
  DispatchQueue.concurrentPerform(iterations: grassHopperPositions.count) { i in let result = fitness(grassHopperPositions[i])
    grassHopperFitness[i] = result[0]
  }
  print(-date2.timeIntervalSinceNow / Double(grassHopperPositions.count))
  for g in groups.indices {
    // Find the best grasshopper per group (target) in the first population
    for i in groups[g].indices {
      if grassHopperFitness[i] < targetFitness[g] {
        targetFitness[g] = grassHopperFitness[i]
        targetPosition[g] = grassHopperPositions[i]
      }
    }
    TunOl.convergenceCurves[g].append([Double(0), targetFitness[g]])
  }
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
    DispatchQueue.concurrentPerform(iterations: grassHopperPositions.count) { i in if source.isCancelled { return }
      for j in grassHopperPositions[i].indices {
        grassHopperPositions[i][j].clamp(to: bounds[j])
        targetResults[pos + i][j] = grassHopperPositions[i][j]
      }
      let result = fitness(grassHopperPositions[i])
      //targetResults[pos+i] = result
      targetResults[pos + i].replaceSubrange(bounds.count..., with: result)
      grassHopperFitness[i] = result[0]
    }
    if source.isCancelled { break }

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
              grassHopperTrialPositions[i][j] = targetPosition[g][j] + f * (.random(in: 0...1) + 0.0001) * (grassHopperPositions[r1][j] - grassHopperPositions[r2][j])
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
    } else {
      refresh = false
    }

    if refresh {
      DispatchQueue.concurrentPerform(iterations: grassHopperTrialPositions.count) { i in if source.isCancelled { return }
        let result = fitness(grassHopperTrialPositions[i])
        if result[0] < grassHopperFitness[i] {
          grassHopperFitness[i] = result[0]
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
      TunOl.convergenceCurves[g].append([Double(l), targetFitness[g]])
    }
    print("Iterations: \(l)\n\(targetFitness)".randomColor())
    print(targetPosition.map(labeled(values:)).joined(separator: "\n"))
    if (targetFitness.reduce(0, +) / 3) - targetFitness.min()! < 0.001 { break }
  }
  targetResults.removeLast((maxIter - l) * n)
  return targetResults
}

typealias Matrix<T> = [[T]]
typealias Vector<T> = [T]

extension Matrix where Element == Vector<Double> {
  init(_ x: Int, _ y: Int, _ z: Double = .zero) {
    self = Matrix(repeating: Vector(y), count: x)
  }
}

extension Vector where Element == Double {
  init(_ x: Int,  _ z: Double = .zero) {
    self = Vector(repeating: z, count: x)
  }
}
