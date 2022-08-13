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

public struct IGOAIW {
  let n: Int
  let maxIterations: Int
  let bounds: [ClosedRange<Double>]

  let cMax = 1.0
  let cMin = 0.00004
  let cr = 0.4
  let f = 0.9
  let sMax = 6.0
  let sMin = 0.0

  func S_func(r: Double) -> Double {
    let f = 0.5
    let l = 1.5
    return f * exp(-r / l) - exp(-r)  // Eq. (2.3) in the paper
  }

  func normalized(_ value: Double, _ range: ClosedRange<Double>) -> Double {
    guard range.lowerBound < range.upperBound else { return .zero }
    return (value - range.lowerBound) / (range.upperBound - range.lowerBound)
  }

  func euclideanDistance(x: [Double], y: [Double], range: [ClosedRange<Double>]) -> Double {
    let distance = range.indices.reduce(.zero) { acc, i in 
      acc + pow(normalized(x[i], range[i]) - normalized(y[i], range[i]), 2)
    }
    return sqrt(distance)
  }
  
  public init(n: Int, maxIterations: Int, bounds: [ClosedRange<Double>]) {
    let split = n.quotientAndRemainder(dividingBy: 3)
    self.n = split.remainder > 0 ? (split.quotient + 1) * 3 : split.quotient * 3
    self.maxIterations = maxIterations
    self.bounds = bounds
  }

  public func callAsFunction(_ fitness: FitnessFunction) -> [[Double]] {
    var targetResults = Matrix(n * (maxIterations+1), bounds.count + 8)
    var targetPosition = Matrix(3, bounds.count)
    var targetFitness = Vector(3, .infinity)
    var worstFitness = Vector(3, .zero)
    let EPSILON = 1E-14

    // Initialize the population of grasshoppers
    var grassHopperPositions = scattered(count: n, bounds: bounds)
    var grassHopperFitness = Vector(n, .infinity)
    var weedPositions = Matrix(Int(sMax), bounds.count)
    var weedFitness = Vector(Int(sMax), .infinity)
    let groups = grassHopperFitness.indices.split(in: 3)

    // Calculate the fitness of initial grasshoppers
    DispatchQueue.concurrentPerform(iterations: grassHopperPositions.count) { i in
      if source.isCancelled { return }
      let result = fitness(grassHopperPositions[i])
      targetResults[i] = result + [0]
      grassHopperFitness[i] = result[0]
    }

    // Find the best grasshopper per group (target) in the first population
    for i in grassHopperFitness.indices {
      if grassHopperFitness[i] < targetFitness[0] {
        for g in groups.indices {
          targetFitness[g] = grassHopperFitness[i]
          targetPosition[g] = grassHopperPositions[i]
        }
      }
    }
    for g in groups.indices {
      convergenceCurves[g].append([Double(0), (targetFitness[g] * 100).rounded() / 100])
    }

    ClearScreen()
    print("Population: \(grassHopperPositions.count) ".randomColor(), "Iterations: 0".leftpad(28).randomColor())
    print(pretty(values: targetFitness))
    print(pretty(values: targetPosition))

    let dims = bounds.count
    var r_ij_vec = Vector(dims), s_ij = Vector(dims)
    var iteration = 0
    while iteration < maxIterations && !source.isCancelled {
      let c = [
        cMin * pow(cMax / cMin, 1 / (1 + 2.5 * Double(iteration) / Double(maxIterations))),
        cMax - (Double(iteration) * ((cMax - cMin) / Double(maxIterations))),  // Eq. (2.8) in the paper
        cMax - (cMax - cMin) * pow(Double(iteration) / Double(maxIterations), 4)
      ]
      iteration += 1
      if iteration < 3 * maxIterations / 4 {
        let scoutGrassHoppers = groups.last!
        let randomGrassHoppers = bounds.randomValues(count: scoutGrassHoppers.count)
        for (s, r) in zip(scoutGrassHoppers.indices, randomGrassHoppers) { grassHopperPositions[s] = r }
      }
      for g in groups.indices {
        for i in groups[g].indices {
          var S_i = Vector(dims)
          for j in groups[g].indices {
            if i != j {
              // Calculate the normalized distance between two grasshoppers
              let distance = euclideanDistance(x: grassHopperPositions[i], y: grassHopperPositions[j], range: bounds)
              for p in r_ij_vec.indices {
                let xj = normalized(grassHopperPositions[j][p], bounds[p])
                let xi = normalized(grassHopperPositions[i][p], bounds[p])
                r_ij_vec[p] = (xj - xi) / (distance + EPSILON)  // xj-xi/dij in Eq. (2.7)
              }
              let xj_xi = 2 + distance.remainder(dividingBy: 2)  // |xjd - xid| in Eq. (2.7)
              for p in r_ij_vec.indices {
                // The first part inside the big bracket in Eq. (2.7)
                s_ij[p] = ((bounds[p].upperBound - bounds[p].lowerBound) * c[g] / 2) * S_func(r: xj_xi) * r_ij_vec[p]
              }
              for p in S_i.indices { S_i[p] += s_ij[p] }
            }
          }
          for p in S_i.indices { // Update the target
            grassHopperPositions[i][p] = c[g] * S_i[p] + targetPosition[g][p]  // Eq. (2.7) in the paper
          }
        }
      }
      var cursor = iteration * grassHopperPositions.count
      DispatchQueue.concurrentPerform(iterations: grassHopperPositions.count) { i in if source.isCancelled { return }
        for j in grassHopperPositions[i].indices { grassHopperPositions[i][j].clamp(to: bounds[j]) }
        let result = fitness(grassHopperPositions[i])
        targetResults[cursor + i] = result + [Double(iteration)]
        grassHopperFitness[i] = result[0]
      }
      if source.isCancelled { break }

      if source.isCancelled { break }
      for g in groups.indices {
        // Update the target
        for i in groups[g].indices {
          if grassHopperFitness[i] < targetFitness[g] {
            targetFitness[g] = grassHopperFitness[i]
            targetPosition[g] = grassHopperPositions[i]
          }
          if grassHopperFitness[i] > worstFitness[g] {
            worstFitness[g] = grassHopperFitness[i]
          }
        }
        convergenceCurves[g].append([Double(iteration), (targetFitness[g] * 100).rounded() / 100])
      }
      cursor += grassHopperPositions.count
      let firstHalf = grassHopperFitness.indices.sorted(by: { grassHopperFitness[$0] < grassHopperFitness[$1] }).prefix(grassHopperFitness.count / 2)
      for i in firstHalf {
        let s = Int(((grassHopperFitness[i] - worstFitness[0]) / (targetFitness.sorted().first! - worstFitness[0])) * (sMax - sMin) + sMin)
        for t in 0..<s {
          for p in bounds.indices {
            let ini = Double.randomGaussian(mu: grassHopperPositions[i][p], sigma: (bounds[p].upperBound - bounds[p].lowerBound) / 10)
            let fin = Double.randomGaussian(mu: grassHopperPositions[i][p], sigma: 0.001)
            weedPositions[t][p] = (pow(Double(maxIterations - iteration), 2) / pow(Double(maxIterations) , 2)) * (ini - fin) + fin
            weedPositions[t][p].clamp(to: bounds[p])
          }
        }

        DispatchQueue.concurrentPerform(iterations: s) { j in if source.isCancelled { return }
          let result = fitness(weedPositions[j])
          weedFitness[j] = result[0]
          targetResults[cursor + j] = result + [Double(iteration)]
        }
        cursor += s
        for j in 0..<s {
          if weedFitness[j] < grassHopperFitness[i] {
            grassHopperFitness[i] = weedFitness[j]
            grassHopperPositions[i] = weedPositions[j]
          }
        }
      }
      for g in groups.indices {
        // Update the target
        for i in groups[g].indices {
          if grassHopperFitness[i] < targetFitness[g] {
            targetFitness[g] = grassHopperFitness[i]
            targetPosition[g] = grassHopperPositions[i]
          }
        }
      }
      ClearScreen()
      print("Population: \(grassHopperPositions.count) ".randomColor(), "Iterations: \(iteration)".leftpad(28).randomColor())
      print(pretty(values: targetFitness))
      print(pretty(values: targetPosition))
      let sort = targetFitness.indices.sorted(by:{ targetFitness[$0] < targetFitness[$1] })
      sort.dropFirst().forEach {
        targetFitness[$0] = targetFitness[sort.first!]
        targetPosition[$0] = targetPosition[sort.first!]
      }
    }
    if source.isCancelled { 
      targetResults.removeLast((maxIterations - iteration) * n)
    }
    return targetResults
  }
}

extension Double {
  /// Returns a random number sampled from the specified Gaussian distribution.
  static func randomGaussian(mu: Double, sigma: Double) -> Double {
    let p = (0.322232431088, 1.0, 0.342242088547, 0.204231210245e-1, 0.453642210148e-4)
    let q = (0.099348462606, 0.588581570495, 0.531103462366, 0.103537752850, 0.385607006340e-2)
    let u = Double.random(in: 0...1), t: Double, z: Double
    if u < 0.5 { t = sqrt(-2.0 * log(u)) } else { t = sqrt(-2.0 * log(1.0 - u)) }
    let num = p.0 + t * (p.1 + t * (p.2 + t * (p.3 + t * p.4)))
    let denom = q.0 + t * (q.1 + t * (q.2 + t * (q.3 + t * q.4)))
    if u < 0.5 { z = (num / denom) - t } else { z = t - (num / denom) }
    return (mu + sigma * z)
  }
}
