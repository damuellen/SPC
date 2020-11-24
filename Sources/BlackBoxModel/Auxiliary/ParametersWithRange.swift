//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

public struct PowerRange {

  var range: ClosedRange<Double>

  var min: Double { return self.range.lowerBound }

  var nominal: Double = 0

  var max: Double {
    get { return self.range.upperBound }
    set { self.range = self.range.lowerBound...newValue }
  }

  init(range: ClosedRange<Double>, nom: Double) {
    self.range = range
    self.nominal = nom
  }
}

extension PowerRange: Codable {
  enum CodingKeys: String, CodingKey {
    case min
    case nom
    case max
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let min = try values.decode(Double.self, forKey: .min)
    let nom = try values.decode(Double.self, forKey: .nom)
    let max = try values.decode(Double.self, forKey: .max)
    nominal = nom
    range = min...max
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(min, forKey: .min)
    try container.encode(nominal, forKey: .nom)
    try container.encode(max, forKey: .max)
  }
}
