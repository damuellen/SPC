//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation

/// A mass flow rate in kilogram per second.
public struct MassFlow: CustomStringConvertible {
  
  var rate: Double {
    willSet { assert(newValue >= 0) }
  }
  
  var isNearZero: Bool { return self < 1e-4 }
  
  public var description: String {
    return String(format:"%.2f", rate)
  }
  
  public init() {
    self.rate = 0
  }
  
  public init(_ rate: Double) {
      self.rate = rate
  }
  
  func share(of max: MassFlow) -> Ratio {
    let rate = abs(self.rate)
    assert(rate <= max.rate)
    return Ratio(rate / max.rate)
  }
  
  mutating func adjust(with ratio: Double) {
    rate *= ratio
  }
  
  func adjusted(with ratio: Double) -> MassFlow {
    return MassFlow(rate * ratio)
  }
  
  mutating func adjust(with ratio: Ratio) {
    rate *= ratio.ratio
  }

  func adjusted(with ratio: Ratio) -> MassFlow {
    return MassFlow(rate * ratio.ratio)
  }
  
  func raised(by degree: Double) -> MassFlow {
    return MassFlow(rate + degree)
  }
  
  func lowered(by degree: Double) -> MassFlow {
    return MassFlow(rate - degree)
  }
  
  func isHigher(than rate: Double) -> Bool {
    return self.rate > rate
  }
  
  func isLower(than rate: Double) -> Bool {
    return self.rate < rate
  }
  
  static func + (lhs: MassFlow, rhs: MassFlow) -> MassFlow {
    return MassFlow(lhs.rate + rhs.rate)
  }
  
  static func - (lhs: MassFlow, rhs: MassFlow) -> MassFlow {
    return MassFlow(lhs.rate - rhs.rate)
  }
}

extension MassFlow: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.rate = try container.decode(Double.self)
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(self.rate)
  }
}

extension MassFlow: ExpressibleByFloatLiteral {
  public init(floatLiteral rate: Double) {
    self.rate = rate
  }
}

extension MassFlow: Comparable {
  public static func < (lhs: MassFlow, rhs: MassFlow) -> Bool {
    return lhs.rate < rhs.rate
  }
  
  public static func == (lhs: MassFlow, rhs: MassFlow) -> Bool {
    return fdim(lhs.rate, rhs.rate) < 1e-4
  }
}
