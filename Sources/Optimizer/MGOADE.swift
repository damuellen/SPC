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
  let maxIterations: Int
  let bounds: [ClosedRange<Double>]

  let cMax = 1.0
  let cMin = 0.004
  let cr = 0.4
  let f = 0.9

  func S_func(r: Double) -> Double {
    let f = 0.5
    let l = 1.5
    return f * exp(-r / l) - exp(-r)  // Eq. (2.3) in the paper
  }

  func euclideanDistance(a: [Double], b: [Double]) -> Double {
    var distance = 0.0
    for i in a.indices { distance += pow((a[i] - b[i]), 2) }
    return sqrt(distance)
  }

  public init(group: Bool, n: Int, maxIterations: Int, bounds: [ClosedRange<Double>]) {
    self.group = group
    if group {
      let split = n.quotientAndRemainder(dividingBy: 3)
      self.n = split.remainder > 0 ? (split.quotient + 1) * 3 : split.quotient * 3
    } else {
      self.n = n
    }
    self.maxIterations = maxIterations
    self.bounds = bounds
  }

  public func callAsFunction(_ fitness: FitnessFunction) -> [[Double]] {
    var targetResults = Matrix(n * maxIterations, bounds.count + 8)
    var targetPosition = Matrix(group ? 3 : 1, bounds.count)
    var targetFitness = Vector(group ? 3 : 1, .infinity)
    let EPSILON = 1E-14

    // Initialize the population of grasshoppers
    var grassHopperPositions = bounds.randomValues(count: n)
    var grassHopperFitness = Vector(n, .infinity)
    var grassHopperTrialPositions = grassHopperPositions
    let groups = grassHopperFitness.indices.split(in: group ? 3 : 1)

    // Calculate the fitness of initial grasshoppers
    while grassHopperFitness.contains(.infinity) {
      let invalid = grassHopperFitness.indices.filter { grassHopperFitness[$0].isInfinite }
      // Replace invalid grasshoppers in the population
      for (i, position) in zip(invalid, bounds.randomValues(count: invalid.count)) {
        grassHopperPositions[i] = position
      }
      DispatchQueue.concurrentPerform(iterations: invalid.count) { i in let i = invalid[i]
        if source.isCancelled { return }
        let result = fitness(grassHopperPositions[i])
        grassHopperFitness[i] = result[0]
      }
      if source.isCancelled { break }
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
    print("Population: \(grassHopperPositions.count) ".randomColor(), "Iterations: 0".leftpad(28).randomColor())
    print(pretty(values: targetFitness))
    print(pretty(values: targetPosition))

    var pos = 0, iteration = 0
    let dims = bounds.count
    var r_ij_vec = Vector(dims), s_ij = Vector(dims), X_new = Vector(dims)

    while iteration < maxIterations && !source.isCancelled {
      let c1 = cMax - (Double(iteration) * ((cMax - cMin) / Double(maxIterations)))  // Eq. (2.8) in the paper
      let c2 = Double.random(in: cMin...cMax)
      for g in groups.indices {
        for i in groups[g].indices {
          var S_i = Vector(dims)
          for j in groups[g].indices {
            if i != j {
              // Calculate the distance between two grasshoppers
              let distance = euclideanDistance(a: grassHopperPositions[i], b: grassHopperPositions[j])
              for p in r_ij_vec.indices {
                r_ij_vec[p] = (grassHopperPositions[j][p] - grassHopperPositions[i][p]) / (distance + EPSILON)  // xj-xi/dij in Eq. (2.7)
              }
              let xj_xi = 2 + distance.remainder(dividingBy: 2)  // |xjd - xid| in Eq. (2.7)
              for p in r_ij_vec.indices {
                // The first part inside the big bracket in Eq. (2.7)
                s_ij[p] = ((bounds[p].upperBound - bounds[p].lowerBound) * c2 / 2) * S_func(r: xj_xi) * r_ij_vec[p]
              }
              for p in S_i.indices { S_i[p] += s_ij[p] }
            }
          }

          for p in S_i.indices { X_new[p] = c1 * S_i[p] + targetPosition[g][p] } // Eq. (2.7) in the paper
          // Update the target
          grassHopperPositions[i] = X_new
        }
      }

      DispatchQueue.concurrentPerform(iterations: grassHopperPositions.count) { i in if source.isCancelled { return }
        for j in grassHopperPositions[i].indices { grassHopperPositions[i][j].clamp(to: bounds[j]) }
        let result = fitness(grassHopperPositions[i])
        targetResults[pos + i] = result + [Double(iteration * n + i)]
        grassHopperFitness[i] = result[0]
      }
      if source.isCancelled { break }

      // Multi-group strategy
      if group {
        for g in groups.indices {
          let o = groups.indices.filter { $0 != g }
          let g0 = groups[g].indices
          let g1 = groups[o[0]].indices.shuffled()
          let g2 = groups[o[1]].indices.shuffled()
          for i in groups[0].indices {
            let i0 = g0[i], i1 = g1[i], i2 = g2[i]
            for j in grassHopperPositions[i].indices where .random(in: 0...1) > cr {
              grassHopperTrialPositions[i0][j] = targetPosition[g][j] + f * (.random(in: 0...1) + 0.0001) * (grassHopperPositions[i1][j] - grassHopperPositions[i2][j])
              grassHopperTrialPositions[i0][j].clamp(to: bounds[j])
            }
          }
        }

        DispatchQueue.concurrentPerform(iterations: grassHopperTrialPositions.count) { i in if source.isCancelled { return }
          let result = fitness(grassHopperTrialPositions[i])
          if result[0] < grassHopperFitness[i] {
            grassHopperFitness[i] = result[0]
            grassHopperPositions[i] = grassHopperTrialPositions[i]
            targetResults[pos + i] = result + [Double(iteration * n + i)]
          }
        }
      }
      if source.isCancelled { break }
      iteration += 1
      pos += grassHopperPositions.count
      for g in groups.indices {
        // Update the target
        for i in groups[g].indices {
          if grassHopperFitness[i] < targetFitness[g] {
            targetFitness[g] = grassHopperFitness[i]
            targetPosition[g] = grassHopperPositions[i]
          }
        }
        convergenceCurves[g].append([Double(iteration), (targetFitness[g] * 100).rounded() / 100])
      }
      ClearScreen()
      print("Population: \(grassHopperPositions.count) ".randomColor(), "Iterations: \(iteration)".leftpad(28).randomColor())
      print(pretty(values: targetFitness))
      print(pretty(values: targetPosition))
    }
    targetResults.removeLast((maxIterations - iteration) * n)
    return targetResults
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
        \(labels[i].leftpad(16).text(.red))\(": ".text(.red))\
        \(String(format: "%.1f", values[0][i]).leftpad(9).text(.yellow))
        """
      }
      .joined(separator: "\n")
  }
  return values[0].indices
    .map { i in
      """
      \(labels[i].leftpad(16).text(.red))\(": ".text(.red))\
      \(String(format: "%.1f", values[0][i]).leftpad(9).text(.green))\
      \(String(format: "%.1f", values[1][i]).leftpad(9).text(.yellow))\
      \(String(format: "%.1f", values[2][i]).leftpad(9).text(.magenta))
      """
    }
    .joined(separator: "\n")
}

func pretty(values: [Double]) -> String {
  let label = "LCOM"
  if values.count == 1 {
    return """
      \(label.leftpad(16).text(.red))\(": ".text(.red))\
      \(String(format: "%.2f", values[0]).leftpad(9).text(.cyan))
      """
  }
  return """
    \(label.leftpad(16).text(.red))\(": ".text(.red))\
    \(String(format: "%.2f", values[0]).leftpad(9).text(.green))\
    \(String(format: "%.2f", values[1]).leftpad(9).text(.yellow))\
    \(String(format: "%.2f", values[2]).leftpad(9).text(.magenta))
    """
}
