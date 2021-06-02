//
//  Copyright 2021 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

public struct HeatExchangerParameter: Codable {
  /// Difference between evaporation temperature and htf outlet temperature
  public var temperatureDifferenceHTF: Double
  /// Difference between evaporation temperature and water inlet Temperature
  public var temperatureDifferenceWater: Double
  public var steamQuality: Double
  public var requiredLMTD: Double
  public var pressureDrop: PressureDrop

  public struct PressureDrop: Codable {
    public var economizer: Double
    public var economizer_steamGenerator: Double
    public var steamGenerator: Double
    public var steamGenerator_superHeater: Double
    public var superHeater: Double
    public var superHeater_turbine: Double
  }
}

extension HeatExchangerParameter {
  public init?(values: [Double]) {
    guard values.count == 10 else { return nil }
    self.temperatureDifferenceHTF = values[0]
    self.temperatureDifferenceWater = values[1]

    self.pressureDrop = .init(
      economizer: values[2],
      economizer_steamGenerator: values[3],
      steamGenerator: values[4],
      steamGenerator_superHeater: values[5],
      superHeater: values[6],
      superHeater_turbine: values[7]
    )

    self.steamQuality = values[8]
    self.requiredLMTD = values[9]
  }

  public static let case1 = HeatExchangerParameter(
    temperatureDifferenceHTF: 3.0,
    temperatureDifferenceWater: 3.0,
    steamQuality: 1.0,
    requiredLMTD: 10.5,
    pressureDrop: .init(
      economizer: 1.2,
      economizer_steamGenerator: 6.0,
      steamGenerator: 0.1,
      steamGenerator_superHeater: 0.2,
      superHeater: 0.5,
      superHeater_turbine: 1.5
    )
  )

  public static let case2 = HeatExchangerParameter(
    temperatureDifferenceHTF: 3.0,
    temperatureDifferenceWater: 3.0,
    steamQuality: 1.0,
    requiredLMTD: 20.0,
    pressureDrop: .init(
      economizer: 1.0,
      economizer_steamGenerator: 0.2,
      steamGenerator: 0.55,
      steamGenerator_superHeater: 0.1,
      superHeater: 1.25,
      superHeater_turbine: 3.2
    )
  )

  public static let case3 = HeatExchangerParameter(
    temperatureDifferenceHTF: 5.4,
    temperatureDifferenceWater: 3.0,
    steamQuality: 1.0,
    requiredLMTD: 22.0,
    pressureDrop: .init(
      economizer: 1.2,
      economizer_steamGenerator: 6.0,
      steamGenerator: 0.1,
      steamGenerator_superHeater: 0.2,
      superHeater: 0.5,
      superHeater_turbine: 1.5
    )
  )
}
