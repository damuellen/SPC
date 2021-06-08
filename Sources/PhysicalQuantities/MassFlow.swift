//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Libc

/// A mass flow rate in kilogram per second.
public struct MassFlow: CustomStringConvertible {
  /// Kilogram per second
  public var rate: Double

  public var isZero: Bool { self <= 0.0 }
  
  public var description: String {
    String(format: "%.1f", rate)
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
  
  public func share(of max: MassFlow) -> Ratio {
    let rate = abs(self.rate)
    return (rate - max.rate) <= 0.0001 ? Ratio(rate / max.rate) : Ratio(1)
  }

  public mutating func adjust(factor ratio: Double) {
    rate *= ratio
  }

  public mutating func adjust(withFactor ratio: Ratio) {
    rate *= ratio.quotient
  }

  public func adjusted(withFactor ratio: Double) -> MassFlow {
    MassFlow(rate * ratio)
  }

  public func adjusted(withFactor ratio: Ratio) -> MassFlow {
    MassFlow(rate * ratio.quotient)
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

  public static prefix func - (rhs: MassFlow) -> MassFlow {
    MassFlow(-rhs.rate)
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

extension MassFlow: Comparable, Equatable {
  public static func < (lhs: MassFlow, rhs: MassFlow) -> Bool {
    lhs.rate < rhs.rate
  }

  public static func == (lhs: MassFlow, rhs: MassFlow) -> Bool {
    fdim(lhs.rate, rhs.rate) < 1e-4
  }
}

extension MassFlow: AdditiveArithmetic {
  public static var zero: MassFlow = MassFlow()

  public static func + (lhs: MassFlow, rhs: MassFlow) -> MassFlow {
    MassFlow(lhs.rate + rhs.rate)
  }

  public static func - (lhs: MassFlow, rhs: MassFlow) -> MassFlow {
    MassFlow(lhs.rate - rhs.rate)
  }
}
