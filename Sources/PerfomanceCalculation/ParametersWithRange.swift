//
//  Copyright (c) 2017 Daniel Müllenborn. All rights reserved.
//  Distributed under the The Non-Profit Open Software License version 3.0
//  http://opensource.org/licenses/NPOSL-3.0
//
//  This project is NOT free software. It is open source, you are allowed to
//  modify it (if you keep the license), but it may not be commercially
//  distributed other than under the conditions noted above.
//

public struct PowerRange {
  var range: ClosedRange<Double>
  var min: Double { return range.lowerBound }
  var max: Double {
    get { return range.upperBound }
    set { range = self.range.lowerBound...newValue }
  }
}

extension PowerRange: Codable {
  enum CodingKeys: String, CodingKey {
    case min
    case max
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let min = try values.decode(Double.self, forKey: .min)
    let max = try values.decode(Double.self, forKey: .max)
    self.range = min...max
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(min, forKey: .min)
    try container.encode(max, forKey: .max)
  }
}

public struct TemperatureRange {
  var range: ClosedRange<Double>
  var cold: Double { return range.lowerBound }
  var hot: Double {
    get { return range.upperBound }
    set { range = self.range.lowerBound...newValue }
  }
}

extension TemperatureRange: Codable {
  enum CodingKeys: String, CodingKey {
    case cold
    case hot
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let cold = try values.decode(Double.self, forKey: .cold)
    let hot = try values.decode(Double.self, forKey: .hot)
    self.range = cold...hot
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(cold, forKey: .cold)
    try container.encode(hot, forKey: .hot)
  }
}
