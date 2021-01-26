//
//  Headers.swift
//  SolarField
//
//  Created by Daniel Muellenborn on 23/03/2015.
//  Copyright © 2015 Daniel Muellenborn. All rights reserved.
//

protocol Piping: AnyObject, TableConvertible {
  var name: String { get }
  var branches: [Branch] { get }
  var tail: (cold: Branch, hot: Branch)! { get }
  var streamVelocity: Double { get }
}

extension Piping {
  var pressureDrop: Double { branches.pressureDrop }
  var headLoss: Double { branches.headLoss }
  var heatLoss: Double { branches.heatLoss }
  var volume: Double { branches.volume }
  var volumeCold: Double { branches.volumeCold }
  var volumeHot: Double { branches.volumeHot }
  var length: Double { branches.length }
}

extension Sequence where Element == Branch {

  func total(_ keyPath: KeyPath<Branch, Double>) -> Double {
    return map { $0[keyPath: keyPath] }.reduce(0.0,+)
  }

  /// Sum of length of branches.
  var length: Double { total(\.length) }
  /// Sum of residence time in branches.
  var residenceTime: Double { total(\.residenceTime) }
  /// Sum of pressure drop in branches.
  var pressureDrop: Double { total(\.pressureDrop) }
  /// Sum of head loss in branches.
  var headLoss: Double { total(\.headLoss) }
  /// Sum of heat losses in branches.
  var heatLoss: Double { total(\.heatLosses) }
  /// Sum of volume in branches.
  var volume: Double { total(\.volume) }
  /// Sum of volume in cold branches.
  var volumeCold: Double {
    let isCold: (Branch) -> Bool = {
      $0.temperature == SolarField.designTemperature.inlet
    }
    var sum = 0.0
    for branch in self where isCold(branch) { sum += branch.volume }
    return sum
  }
  /// Sum of volume in hot branches.
  var volumeHot: Double {
    let isHot: (Branch) -> Bool = {
      return $0.temperature == SolarField.designTemperature.outlet
    }
    var sum = 0.0
    for branch in self where isHot(branch) { sum += branch.volume }
    return sum
  }
}
