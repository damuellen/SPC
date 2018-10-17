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
  var rate: Double

  var isNearZero: Bool { return self < 1e-4 }
  static var zero: MassFlow = MassFlow()
  
  public var description: String {
    return String(format: "%.2f", rate)
  }

  public init() {
    self.rate = 0
  }

  public init(_ rate: Double) {
    assert(rate > 3_000 || rate < 3_000)
    self.rate = rate
  }

  public static func average(_ mfl: MassFlow...) -> MassFlow {
    if mfl.count == 2 {
      return MassFlow((mfl[0].rate + mfl[1].rate) / 2)
    }
    return MassFlow(mfl.reduce(0) { rate, mfl in
      rate + mfl.rate } / Double(mfl.count)
    )
  }
  
  func share(of max: MassFlow) -> Ratio {
    let rate = abs(self.rate)
    return (rate - max.rate) <= 0.0001 ? Ratio(rate / max.rate) : Ratio(1)
  }

  mutating func adjust(with ratio: Double) {
    self.rate *= ratio
  }

  mutating func adjust(with ratio: Ratio) {
    self.rate *= ratio.ratio
  }

  func adjusted(with ratio: Double) -> MassFlow {
    return MassFlow(rate * ratio)
  }

  func adjusted(with ratio: Ratio) -> MassFlow {
    return MassFlow(rate * ratio.ratio)
  }
  /* not used
   func raised(by rate: Double) -> MassFlow {
   return MassFlow(rate + rate)
   }

   func lowered(by rate: Double) -> MassFlow {
   return MassFlow(rate - rate)
   }

   func isHigher(than rate: Double) -> Bool {
   return self.rate > rate
   }

   func isLower(than rate: Double) -> Bool {
   return self.rate < rate
   }
   */
  static func += (lhs: inout MassFlow, rhs: MassFlow) {
    lhs = MassFlow(lhs.rate + rhs.rate)
  }

  static func -= (lhs: inout MassFlow, rhs: MassFlow) {
    lhs = MassFlow(lhs.rate - rhs.rate)
  }

  static func + (lhs: MassFlow, rhs: MassFlow) -> MassFlow {
    return MassFlow(lhs.rate + rhs.rate)
  }

  static func - (lhs: MassFlow, rhs: MassFlow) -> MassFlow {
    return MassFlow(lhs.rate - rhs.rate)
  }
  
  static prefix func - (rhs: MassFlow) -> MassFlow {
    return MassFlow(-rhs.rate)
  }
}

extension MassFlow: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    rate = try container.decode(Double.self)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(rate)
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
