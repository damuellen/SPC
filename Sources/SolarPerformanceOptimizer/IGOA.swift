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
import BlackBoxModel

@_exported import Utilities

public var convergenceCurves = [[[Double]]](repeating: [[Double]](), count: 3)

public struct IGOA {
  let n: Int
  let maxIterations: Int
  let bounds: [ClosedRange<Double>]

  let cMax = 1.0
  let cMin = 0.00004
  let cr = 0.4
  let f = 0.9

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

  public func callAsFunction(_ file: String) -> [[Double]] {
    var targetResults = Matrix(n * (maxIterations+1), bounds.count + 8)
    var targetPosition = Matrix(3, bounds.count)
    var targetFitness = Vector(3, .infinity)
    let EPSILON = 1E-14
    
    // Initialize the population of grasshoppers
    var grassHopperPositions = scattered(count: n, bounds: bounds)
    var grassHopperFitness = Vector(n, .infinity)
    let groups = grassHopperFitness.indices.split(in: 3)
    print("Population: \(grassHopperPositions.count) " + "Iterations: 0".leftpad(28))
    // Calculate the fitness of initial grasshoppers
    var workers = [Process]()    
    for i in 0 ..< grassHopperPositions.count {
      if source.isCancelled { break }
      let worker = try! worker()
      let input = worker.currentDirectoryURL!.appendingPathComponent("layout").appendingPathExtension("json")
      try! Layout(grassHopperPositions[i]).storeToJSON(file: input)
      worker.arguments = ["-c", "layout.json", "-m", file, "-o", "0", "-n", "plantperformance"]
      try! worker.run()
      workers.append(worker)
      targetResults[i] = grassHopperPositions[i]
    }

    for i in workers.indices {
      if source.isCancelled { break }
      let (_, net, demand) = try! pick(process: workers[i])
      targetResults[i] += [net]
      grassHopperFitness[i] = demand - net
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
      convergenceCurves[g].removeAll()
      convergenceCurves[g].append([Double(0), (targetFitness[g] * 100).rounded() / 100])
    }

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
          for p in S_i.indices { // Update the target positions
            grassHopperPositions[i][p] = c[g] * S_i[p] + targetPosition[g][p]  // Eq. (2.7) in the paper
          }
        }
      }
      let timer = Date()
      let cursor = iteration * grassHopperPositions.count

      for i in 0 ..< grassHopperPositions.count {
        for j in grassHopperPositions[i].indices { grassHopperPositions[i][j].clamp(to: bounds[j]) }
      }

      var workers = [Process]()
      for i in 0 ..< grassHopperPositions.count {
        if source.isCancelled { break }
        let worker = try! worker()
        let input = worker.currentDirectoryURL!.appendingPathComponent("layout").appendingPathExtension("json")
        try! Layout(grassHopperPositions[i]).storeToJSON(file: input)
        worker.arguments = ["-c", "layout.json", "-m", file, "-o", "0", "-n", "plantperformance"]
        try! worker.run()
        workers.append(worker)
        targetResults[cursor + i] = grassHopperPositions[i]
      }
      
      for i in workers.indices {
        if source.isCancelled { break }
        let (_, net, demand) = try! pick(process: workers[i])
        targetResults[cursor + i] += [net]
        grassHopperFitness[i] = demand - net
      }

      let calculationsPerSecond = 1 / (-timer.timeIntervalSinceNow / Double(grassHopperPositions.count))
      let remainingTime = Double((maxIterations - iteration) * grassHopperPositions.count) / calculationsPerSecond
      if source.isCancelled { break }

      if source.isCancelled { break }
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
      print(
        "Population: \(grassHopperPositions.count) " + "Iterations: \(iteration)".leftpad(28),
        String(format: "Calculations per Second: %.1f", calculationsPerSecond),
        "Estimated time remaining: \(Int(remainingTime / 60)) min", separator: "\n"
      )

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

func worker() throws -> Process {
  let worker = Process()
  worker.executableURL = URL(fileURLWithPath: "/home/daniel/spc/.build/release/SPC")
  let uuid = UUID().uuidString
  worker.currentDirectoryURL = URL(fileURLWithPath: "/tmp/\(uuid)")
  worker.standardOutput = nil        
  try FileManager.default.createDirectory(atPath: "/tmp/\(uuid)", withIntermediateDirectories: false)
  return worker
}

func pick(process: Process) throws -> (Double, Double, Double) {
  process.waitUntilExit()
  let url = process.currentDirectoryURL!.appendingPathComponent("plantperformance")
  let data = try Data(contentsOf: url)
  try FileManager.default.removeItem(at: url.deletingLastPathComponent())
  let dict = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
  let sol = (dict!["thermal"] as! [String:Double])["dumping"]!
  let net = (dict!["electric"] as! [String:Double])["net"]!
  let demand = (dict!["electric"] as! [String:Double])["demand"]!
  return (sol, net, demand)
}

func eratosthenesSieve(to n: Int) -> [Int] {
  var composite = Array(repeating: false, count: n + 1) // The sieve
  var primes: [Int] = []
  let d = Double(n)
  let upperBound = Int(d / (log(d) - 4))
  primes.reserveCapacity(upperBound)

  let squareRootN = Int(Double(n).squareRoot())
  var p = 2
  while p <= squareRootN {
    if !composite[p] {
      primes.append(p)
      for q in stride(from: p * p, through: n, by: p) {
        composite[q] = true
      }
    }
    p += 1
  }
  while p <= n {
    if !composite[p] {
      primes.append(p)
    }
    p += 1
  }
  return primes
}

func scattered(count n: Int, bounds b: [ClosedRange<Double>]) -> [[Double]] {
  let variable: [Int] = b.indices.filter { b[$0].lowerBound < b[$0].upperBound }
  let N: Int = variable.count
  let primes = eratosthenesSieve(to: 100 * N)
  let q: Int = primes.first(where: { $0 >= (2 * N + 3) })!
  let pos = (1...N).map(Double.init).map { 2 * cos((2 * .pi * $0) / Double(q)) }
  var M: [[Double]] = (1...n).map { [Double](repeating: Double($0), count: N) }
  M = zip(M, [[Double]](repeating: pos, count: n)).map { zip($0, $1).map(*) }
  M = M.map { $0.map { $0 - ($0 / 1).rounded(.down) } }
  M = M.map { p -> [Double] in var d = 0
    return b.indices.map { i -> Double in var value: Double
      if variable.contains(i) {
        value = b[i].lowerBound + (p[d] * (b[i].upperBound - b[i].lowerBound))
        d += 1
      } else {
        value = b[i].lowerBound
      }
      return value
    }
  }
  return M
}
