//
//  BillOfMaterials.swift
//  SolarField
//
//  Created by Daniel Muellenborn on 23/03/2015.
//  Copyright © 2015 Daniel Muellenborn. All rights reserved.
//

public enum BillOfMaterials {
  
  public static var headings: [String] =
    ["Description", "Material", "Schedule", "NPS", "Quantity", "Weight"]
  
  typealias Items<T> = KeyValuePairs<NominalPipeSize, Array<T>>
  
  public struct Item: Hashable, Comparable {
    public var name: String
    public var material: String
    public var schedule: String
    public var size: Float
    
    var description: String {
      "\(name) \(material) \(schedule) " + .init(format: "%04.1f", size)
    }
    
    public static func < (lhs: Self, rhs: Self) -> Bool {
      lhs.description < rhs.description
    }
  }
  
  static var tubeLength: Items<Float> {
    
    var sch10 = [Float](repeating: 0.0, count: NominalPipeSize.values.count)
    var (sch30, sch40, sch80, sch10S, sch80S, sch120, sch140, sch160) =
      (sch10, sch10, sch10, sch10, sch10, sch10, sch10, sch10)
    
    SolarField.branches.forEach { branch in
      guard let idx = NominalPipeSize.values.firstIndex(of: branch.nps)
      else { return }
      switch branch.schedule {
      case .sch10: sch10[idx] += Float(branch.length)
      case .sch30: sch30[idx] += Float(branch.length)
      case .sch40: sch40[idx] += Float(branch.length)
      case .sch80: sch80[idx] += Float(branch.length)
      case .sch10S: sch10S[idx] += Float(branch.length)
      case .sch80S: sch80S[idx] += Float(branch.length)
      case .sch120: sch120[idx] += Float(branch.length)
      case .sch140: sch140[idx] += Float(branch.length)
      case .sch160: sch160[idx] += Float(branch.length)
      }
    }
    return [.sch10: sch10, .sch30: sch30, .sch40: sch40,
            .sch10S: sch10S,.sch80: sch80, .sch80S: sch80S,
            .sch120: sch120, .sch140: sch140, .sch160: sch160]
  }
  
  static var elbowCount: Items<Int> {
    
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
  
  static var reducerCount: Items<Int> {
    
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
  
  static var valveList: [Item] {
    let branches = SolarField.branches.lazy
    let components = branches.flatMap { $0.components }
    let valves = components.filter { $0.type == .valve }
    let descriptons = valves.map {
      Item(name: $0.name, material: "", schedule: "", size: $0.nps)
    }
    return Array(descriptons)
  }
  
  public static var tubeLengthAndWeight: [Item: (length: Float, weight: Float)] {
    
    func weightAndLengthOfTubes(
      schedule: NominalPipeSize,_ sizes: [Float]
    ) -> [Item: (Float, Float)] {
      var results: [Item: (Float, Float)] = [:]
      let weightPerMeter = schedule.weightPerMeter
      
      for (idx, length) in sizes.enumerated() where length > 0.0 {
        let item = Item(
          name: "PIPE SEAMLESS, BE",
          material: "ASTM A106 GR. B",
          schedule: schedule.rawValue,
          size: NominalPipeSize.values[idx]
        )
        let length = length.rounded(.up)
        let weight = length * weightPerMeter[idx] / 1_000
        results[item] = (length, weight)
      }
      return results
    }
    
    var results = [Item: (Float, Float)]()
    tubeLength.forEach {
      results.merge(weightAndLengthOfTubes(schedule: $0.key, $0.value))
    }
    return results
  }
  
  public static var fittingsQuantityAndWeight: [Item: (qty: Float, weight: Float)] {
    
    func weightAndQuantityofElbows(
      schedule: NominalPipeSize,_ sizes: [Int]
    ) -> [Item: (Float, Float)] {
      var results: [Item: (Float, Float)] = [:]
      let weightOfElbows = CalculatedWeight .ofElbows(with: schedule)
      for (idx, qty) in sizes.enumerated() where qty > 0 {
        let item = Item(
          name: "90 DEGREE LR ELBOW, BE",
          material: "ASTM A234 GR. WPB",
          schedule: schedule.rawValue,
          size: NominalPipeSize.values[idx]
        )
        let qty = Float(qty)
        let weight = qty * weightOfElbows[idx] / 1_000
        results[item] = (qty, weight)
      }
      return results
    }
    
    func weightAndQuantityofReducers(
      schedule: NominalPipeSize,_ sizes: [Int]
    ) -> [Item: (Float, Float)] {
      var results: [Item: (Float, Float)] = [:]
      let weightOfReducers = CalculatedWeight.ofReducers(with: schedule)
      for (idx, qty) in sizes.enumerated() where qty > 0 {
        let item = Item(
          name: "REDUCER ECCENTRIC, BE",
          material: "ASTM A234 GR. WPB",
          schedule: schedule.rawValue,
          size: NominalPipeSize.values[idx]
        )
        let qty = Float(qty)
        let weight = qty * weightOfReducers[idx] / 1_000
        results[item] = (qty, weight)
      }
      return results
    }
    var results = [Item: (Float, Float)]()
    
    elbowCount.forEach {
      results.merge(weightAndQuantityofElbows(schedule: $0.key, $0.value))
    }
    
    reducerCount.forEach {
      results.merge(weightAndQuantityofReducers(schedule: $0.key, $0.value))
    }
    return results
  }
  
  static var valvesQuantity: [Item: (Float, Float)] {
    var results: [Item: (Float, Float)] = [:]
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
    for (key, value) in other { self[key] = value }
  }
}
