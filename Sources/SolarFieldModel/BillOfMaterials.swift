//
//  BillOfMaterials.swift
//  SolarField
//
//  Created by Daniel Muellenborn on 23/03/2015.
//  Copyright © 2015 Daniel Muellenborn. All rights reserved.
//

var numberPool: [Int] = Array(1...100).shuffled()

public enum BillOfMaterials {

  static var tubeLength: [NominalPipeSize: [Double]] {

    var sch10 = [Double](repeating: 0.0, count: NominalPipeSize.values.count)
    var (sch30, sch40, sch80, sch10S, sch80S, sch120, sch140, sch160) =
      (sch10, sch10, sch10, sch10, sch10, sch10, sch10, sch10)

    SolarField.branches.forEach { branch in
      guard let idx = NominalPipeSize.values.firstIndex(of: branch.nps)
        else { return }
      switch branch.schedule {
      case .sch10: sch10[idx] += branch.length
      case .sch30: sch30[idx] += branch.length
      case .sch40: sch40[idx] += branch.length
      case .sch80: sch80[idx] += branch.length
      case .sch10S: sch10S[idx] += branch.length
      case .sch80S: sch80S[idx] += branch.length
      case .sch120: sch120[idx] += branch.length
      case .sch140: sch140[idx] += branch.length
      case .sch160: sch160[idx] += branch.length
      }
    }
    return [.sch10: sch10, .sch30: sch30, .sch40: sch40,
            .sch10S: sch10S,.sch80: sch80, .sch80S: sch80S,
            .sch120: sch120, .sch140: sch140, .sch160: sch160]
  }

  static var elbowCount: [NominalPipeSize: [Int]] {

    var sch10 = [Int](repeating: 0, count: NominalPipeSize.values.count)
    var (sch30, sch40, sch10S, sch80, sch80S, sch120, sch140, sch160) =
      (sch10, sch10, sch10, sch10, sch10, sch10, sch10, sch10)

    SolarField.branches.forEach { branch in
      guard let idx = NominalPipeSize.values.firstIndex(of: branch.nps)
        else { return }
      switch branch.schedule {
      case .sch10: sch10[idx] += branch.numberOfElbows
      case .sch30: sch30[idx] += branch.numberOfElbows
      case .sch40: sch40[idx] += branch.numberOfElbows
      case .sch80: sch80[idx] += branch.numberOfElbows
      case .sch10S: sch10S[idx] += branch.numberOfElbows
      case .sch80S: sch80S[idx] += branch.numberOfElbows
      case .sch120: sch120[idx] += branch.numberOfElbows
      case .sch140: sch140[idx] += branch.numberOfElbows
      case .sch160: sch160[idx] += branch.numberOfElbows
      }
    }
    return [.sch10: sch10, .sch30: sch30, .sch40: sch40,
            .sch10S: sch10S,.sch80: sch80, .sch80S: sch80S,
            .sch120: sch120, .sch140: sch140, .sch160: sch160]
  }

  static var reducerLists: [NominalPipeSize: [Component]] {

    var reducers: [NominalPipeSize: [Component]] =
      [.sch10: [], .sch30: [], .sch40: []]

    SolarField.branches.forEach { branch in
      let reducer = branch.components.filter({ $0.type == .reducer })
      if reducer.count > 0 {
        reducers[branch.schedule]! += reducer
      }
    }
    return reducers
  }

  static var reducerCount: [NominalPipeSize: [Int]] {

    var sch10 = [Int](repeating: 0, count: NominalPipeSize.values.count)
    var (sch30, sch40, sch10S, sch80, sch80S, sch120, sch140, sch160) =
      (sch10, sch10, sch10, sch10, sch10, sch10, sch10, sch10)

    for reducers in reducerLists {
      reducers.value.forEach { reducer in
        guard let idx = NominalPipeSize.values.firstIndex(of: reducer.nps)
          else { return }
        let one = Int(1)
        switch reducers.key {
        case .sch10: sch10[idx] += one
        case .sch30: sch30[idx] += one
        case .sch40: sch40[idx] += one
        case .sch80: sch80[idx] += one
        case .sch10S: sch10S[idx] += one
        case .sch80S: sch80S[idx] += one
        case .sch120: sch120[idx] += one
        case .sch140: sch140[idx] += one
        case .sch160: sch160[idx] += one
        }
      }
    }
    return [.sch10: sch10, .sch30: sch30, .sch40: sch40,
            .sch10S: sch10S,.sch80: sch80, .sch80S: sch80S,
            .sch120: sch120, .sch140: sch140, .sch160: sch160]
  }

  static var valveList: [String] {
    let branches = SolarField.branches.lazy
    let components = branches.flatMap { $0.components }
    let valves = components.filter { $0.type == .valve }
    let descriptons = valves.map { $0.description }
    return Array(descriptons)
  }

  public static var tubesWeightAndLength: [String: (Float, Float)] {
    let description = "PIPE SEAMLESS, BE, ASTM A106 GR. B "

    func weightAndLengthOfTubes(with schedule: NominalPipeSize)
      -> [String: (Float, Float)] {
        var results: [String: (Float, Float)] = [:]
        let weightPerMeter = schedule.weightPerMeter
        for (idx, sum) in tubeLength[schedule]!.enumerated() where sum > 0.0 {
          let key = description + schedule.rawValue
            + " NPS \(Int(NominalPipeSize.values[idx]))\""
          let length = Float(sum)
          let weight = length * weightPerMeter[idx] / 1_000
          results[key] = (weight, length)
        }
        return results
    }

    var results = [String: (Float, Float)]()
    NominalPipeSize.allCases.forEach { schedule in
      results.merge(weightAndLengthOfTubes(with: schedule))
    }
    return results
  }

  public static var fittingsWeightAndQuantity: [String: (Float, Float)] {

    func weightAndQuantityofElbows(with schedule: NominalPipeSize)
      -> [String: (Float, Float)] {
        let description = "90 DEGREE LR ELBOW, BE, A-234 GR. WPB "
        var results: [String: (Float, Float)] = [:]

        let weightOfElbows = CalculatedWeight .ofElbows(with: schedule)
        for (idx, sum) in elbowCount[schedule]!.enumerated() where sum > 0 {
          let key = description + schedule.rawValue
            + " NPS \(Int(NominalPipeSize.values[idx]))\""
          let qty = Float(sum)
          let weight = qty * weightOfElbows[idx] / 1_000
          results[key] = (weight, qty)
        }
        return results
    }

    var results = [String: (Float, Float)]()
    NominalPipeSize.allCases.forEach { schedule in
      results.merge(weightAndQuantityofElbows(with: schedule))
    }

    func weightAndQuantityofReducers(with schedule: NominalPipeSize)
      -> [String: (Float, Float)] {
        let description = "REDUCER ECCENTRIC, BE, A-234 GR. WPB "
        var results: [String: (Float, Float)] = [:]
        let weightOfReducers = CalculatedWeight.ofReducers(with: schedule)
        for (idx, sum) in reducerCount[schedule]!.enumerated() where sum > 0 {
          let key = description + schedule.rawValue
            + " NPS \(Int(NominalPipeSize.values[idx]))\""
          let qty = Float(sum)
          let weight = qty * weightOfReducers[idx] / 1_000
          results[key] = (weight, qty)
        }
        return results
    }

    NominalPipeSize.allCases.forEach { schedule in
      results.merge(weightAndQuantityofReducers(with: schedule))
    }
    return results
  }

  static var valvesQuantity: [String: (Float, Float)] {
    var results: [String: (Float, Float)] = [:]
    for valve in valveList {
      let zeroWeight = Float(0)
      if let qty = results[valve] {
        let sum = (zeroWeight, qty.1 + 1)
        results[valve] = sum
      } else {
        results[valve] = (zeroWeight, 1)
      }
    }
    return results
  }
}

extension Dictionary {
  mutating func merge(_ other: Dictionary<Key, Value>) {
    for (key, value) in other {
      self[key] = value
    }
  }
}
