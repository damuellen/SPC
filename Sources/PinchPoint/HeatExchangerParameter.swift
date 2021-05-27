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
  var temperatureDifferenceHTF: Double
  /// Difference between evaporation temperature and water inlet Temperature
  var temperatureDifferenceWater: Double
  var steamQuality: Double
  var requiredLMTD: Double
  var pressureDrop: PressureDrop

  public struct PressureDrop: Codable {
    var economizer: Double
    var economizer_steamGenerator: Double
    var steamGenerator: Double
    var steamGenerator_superHeater: Double
    var superHeater: Double
    var superHeater_turbine: Double
  }
}

extension HeatExchangerParameter {
  static let case1 = HeatExchangerParameter(
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

  static let case2 = HeatExchangerParameter(
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

  static let case3 = HeatExchangerParameter(
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