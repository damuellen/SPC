//
//  Copyright 2023 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

// A struct representing a power range with minimum, nominal, and maximum values.
struct PowerRange {

  var range: ClosedRange<Double>

  // Computed property to get the minimum value of the range.
  var min: Double { self.range.lowerBound }

  // Property to store the nominal value of the power range.
  var nominal: Double = 0

  // Computed property to get the maximum value of the range and also set the maximum value.
  var max: Double {
    get { self.range.upperBound }
    set { self.range = self.range.lowerBound...newValue }
  }

  // Initializes a PowerRange with the given range and nominal value.
  init(range: ClosedRange<Double>, nom: Double) {
    self.range = range
    self.nominal = nom
  }
}

// Extension of PowerRange to make it Codable (to support encoding and decoding).
extension PowerRange: Codable {
  enum CodingKeys: String, CodingKey {
    case min
    case nom
    case max
  }

  // Initializes a PowerRange from a decoder, decoding the values for min, nominal, and max.
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let min = try values.decode(Double.self, forKey: .min)
    let nom = try values.decode(Double.self, forKey: .nom)
    let max = try values.decode(Double.self, forKey: .max)
    nominal = nom
    range = min...max
  }

  // Encodes the values of min, nominal, and max to an encoder.
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(min, forKey: .min)
    try container.encode(nominal, forKey: .nom)
    try container.encode(max, forKey: .max)
  }
}

// A generic struct representing sides with cold and hot properties, both Codable.
struct Sides<T>: Codable where T: Codable {
  var cold: T
  var hot: T

  // Initializes a Sides instance with the given cold and hot values.
  public init(_ cold: T, _ hot: T) {
    self.cold = cold
    self.hot = hot
  }
}
