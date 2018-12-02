//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

public struct PerformanceLog: CustomStringConvertible {

  public let annual: Results
  
  let history: [Plant.PerformanceData]
  
  let results: [Results]
  
  private let interval = BlackBoxModel.interval
  
  init(annual: Results,
       history: [Plant.PerformanceData],
       results: [Results]) {
    self.annual = annual
    self.history = history
    self.results = results
  }

  public subscript(keyPath: KeyPath<Results, Double>, day day: Int)
    -> [Double] {
    let count = interval.rawValue * 24
    let rangeStart = (day - 1) * count
    let rangeEnd = day * count
    return results[rangeStart..<rangeEnd].map { $0[keyPath: keyPath] }
  }

  public subscript(keyPath: KeyPath<Plant.PerformanceData, Double>, day day: Int)
    -> [Double] {
    let count = interval.rawValue * 24
    let rangeStart = (day - 1) * count
    let rangeEnd = day * count
    return history[rangeStart..<rangeEnd].map { $0[keyPath: keyPath] }
  }

  subscript(forDay day:Int) -> [Results] {
    let count = interval.rawValue * 24
    let rangeStart = (day - 1) * count
    let rangeEnd = day * count
    return Array(results[rangeStart..<rangeEnd])
  }

  public var description: String {
    return annual.description
  }
}
