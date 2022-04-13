//
//  Copyright 2022 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation
import Utilities

public var convergenceCurves = [[[Double]]](repeating: [[Double]](), count: 3)

public func MGOADE(group: Bool, n: Int, maxIter: Int, bounds: [ClosedRange<Double>], source: DispatchSourceSignal, fitness: ([Double]) -> [Double]) -> [[Double]] {
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
  let _ = fitness([])

  print(-date.timeIntervalSinceNow)
  // Calculate the fitness of initial grasshoppers
  let date2 = Date()
  DispatchQueue.concurrentPerform(iterations: grassHopperPositions.count) { i in 
    let result = fitness(grassHopperPositions[i])
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
    convergenceCurves[g].append([Double(0), targetFitness[g]])
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
    DispatchQueue.concurrentPerform(iterations: grassHopperPositions.count) { i in
      if source.isCancelled { return }
      for j in grassHopperPositions[i].indices {
        grassHopperPositions[i][j].clamp(to: bounds[j])
        targetResults[pos + i][j] = grassHopperPositions[i][j]
      }
      let result = fitness(grassHopperPositions[i])
      targetResults[pos+i] = result
      // targetResults[pos + i].replaceSubrange(bounds.count..., with: result)
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
          targetResults[pos + i] = result
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

extension Array where Element == ClosedRange<Double> {
  func randomValues(count: Int) -> [[Double]] {
    (1...count).map { _ in map { range in Double.random(in: range) } }
  }
}

extension Range where Bound == Int {
  func split(in parts: Int) -> [Self] {
    let size = count / parts + (count % parts > 0 ? 1 : 0)
    return stride(from: 0, to: count, by: size).map { cursor in cursor..<Swift.min(cursor.advanced(by: size), endIndex) }
  }
}

func labeled(values: [Double]) -> String {
  let labels = [
    "CSP_loop_nr", "TES_full_load_hours", "PB_nom_gross_cap", "PV_AC_cap", "PV_DC_cap", "EY_var_net_nom_cons", "Hydrogen_storage_cap", "Heater_cap", "CCU_C_O_2_nom_prod", "C_O_2_storage_cap", "MethSynt_RawMeth_nom_prod", "RawMeth_storage_cap", "MethDist_Meth_nom_prod",
    "El_boiler_cap", "BESS_cap", "Grid_export_max", "Grid_import_max",
  ]

  return zip(labels, values).map { l, v in "\(l.text(.red)) \(String(format: "%.1f", v).text(.red))" }.joined(separator: " ")
}