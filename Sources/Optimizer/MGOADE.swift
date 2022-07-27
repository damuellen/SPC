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
@_exported import SunOl
@_exported import Utilities

public var convergenceCurves = [[[Double]]](repeating: [[Double]](), count: 3)
public typealias FitnessFunction = ([Double]) -> [Double]

public struct MGOADE {
  let group: Bool
  let n: Int
  let maxIter: Int
  let bounds: [ClosedRange<Double>]

  let cMax = 1.0
  let cMin = 0.000_04
  let cr = 0.4
  let f = 0.9

  public init(group: Bool, n: Int, maxIter: Int, bounds: [ClosedRange<Double>]) {
    self.group = group
    self.n = n
    self.maxIter = maxIter
    self.bounds = bounds
  }

  public func callAsFunction(_ fitness: FitnessFunction) -> [[Double]] {
    var targetResults = Matrix(n * maxIter, bounds.count + 7)
    var targetPosition = Matrix(group ? 3 : 1, bounds.count)
    var targetFitness = Vector(group ? 3 : 1, .infinity)
    let EPSILON = 1E-14

    // Initialize the population of grasshoppers
    var grassHopperPositions = bounds.randomValues(count: n)
    var grassHopperFitness = Vector(n)
    var grassHopperTrialPositions = grassHopperPositions
    let groups = grassHopperFitness.indices.split(in: group ? 3 : 1)

    // Calculate the fitness of initial grasshoppers

    DispatchQueue.concurrentPerform(iterations: grassHopperPositions.count) { i in if source.isCancelled { return }
      let result = fitness(grassHopperPositions[i])
      grassHopperFitness[i] = result[0]
    }

    for g in groups.indices {
      // Find the best grasshopper per group (target) in the first population
      for i in groups[g].indices {
        if grassHopperFitness[i] < targetFitness[g] {
          targetFitness[g] = grassHopperFitness[i]
          targetPosition[g] = grassHopperPositions[i]
        }
      }
      convergenceCurves[g].append([Double(0), (targetFitness[g] * 100).rounded() / 100])
    }

    ClearScreen()
    print("Population: \(grassHopperPositions.count) ".randomColor(), "Iterations: 0".leftpad(length: 28).randomColor())
    print(pretty(values: targetFitness))
    print(pretty(values: targetPosition))

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
        for j in grassHopperPositions[i].indices { grassHopperPositions[i][j].clamp(to: bounds[j]) }
        let result = fitness(grassHopperPositions[i])
        targetResults[pos + i] = result
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
        convergenceCurves[g].append([Double(l), (targetFitness[g] * 100).rounded() / 100])
      }

      ClearScreen()
      print("Population: \(grassHopperPositions.count) ".randomColor(), "Iterations: \(l)".leftpad(length: 28).randomColor())
      print(pretty(values: targetFitness))
      print(pretty(values: targetPosition))

      if (targetFitness.reduce(0, +) / 3) - targetFitness.min()! < 0.001 { break }
    }
    targetResults.removeLast((maxIter - l) * n)
    return targetResults
  }

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
}

typealias Matrix<T> = [[T]]
typealias Vector<T> = [T]

extension Matrix where Element == Vector<Double> { init(_ x: Int, _ y: Int, _ z: Double = .zero) { self = Matrix(repeating: Vector(y), count: x) } }

extension Vector where Element == Double { init(_ x: Int, _ z: Double = .zero) { self = Vector(repeating: z, count: x) } }

extension Array where Element == ClosedRange<Double> { func randomValues(count: Int) -> [[Double]] { (1...count).map { _ in map { range in Double.random(in: range) } } } }

extension Range where Bound == Int {
  func split(in parts: Int) -> [Self] {
    let size = count / parts + (count % parts > 0 ? 1 : 0)
    return stride(from: 0, to: count, by: size).map { cursor in cursor..<Swift.min(cursor.advanced(by: size), endIndex) }
  }
}

func pretty(values: [[Double]]) -> String {
  let labels = ["Loops", "TES", "PB", "PV_AC", "PV_DC", "EY_cons", "H2_storage", "Heater", "CCU_CO2_prod", "CO2_storage", "RawMeth_storage", "MethDist_prod", "El_boiler", "BESS", "Grid_export", "Grid_import"]
  if values.count == 1 {
    return values[0].indices
      .map { i in
        """
        \(labels[i].leftpad(length: 16).text(.red))\(": ".text(.red))\
        \(String(format: "%.1f", values[0][i]).leftpad(length: 9).text(.yellow))
        """
      }
      .joined(separator: "\n")
  }
  return values[0].indices
    .map { i in
      """
      \(labels[i].leftpad(length: 16).text(.red))\(": ".text(.red))\
      \(String(format: "%.1f", values[0][i]).leftpad(length: 9).text(.green))\
      \(String(format: "%.1f", values[1][i]).leftpad(length: 9).text(.yellow))\
      \(String(format: "%.1f", values[2][i]).leftpad(length: 9).text(.magenta))
      """
    }
    .joined(separator: "\n")
}

func pretty(values: [Double]) -> String {
  let label = "LCOM"
  if values.count == 1 {
    return """
      \(label.leftpad(length: 16).text(.red))\(": ".text(.red))\
      \(String(format: "%.2f", values[0]).leftpad(length: 9).text(.cyan))
      """
  }
  return """
    \(label.leftpad(length: 16).text(.red))\(": ".text(.red))\
    \(String(format: "%.2f", values[0]).leftpad(length: 9).text(.green))\
    \(String(format: "%.2f", values[1]).leftpad(length: 9).text(.yellow))\
    \(String(format: "%.2f", values[2]).leftpad(length: 9).text(.magenta))
    """
}
