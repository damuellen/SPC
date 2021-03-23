//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

extension Storage: CustomStringConvertible {
  public var description: String {
    "  Mode:".padding(20) + "\(operationMode)".padding(20)
    + relativeCharge.multiBar + .lineBreak + .lineBreak
    + String(format: "  Mass flow: %3.1f kg/s", massFlow.rate).padding(28) 
    + String(format: " T in: %3.1f degC", temperature.inlet.celsius).padding(20) 
    + String(format: "T out: %3.1f degC", temperature.outlet.celsius).padding(20) 
    + .lineBreak + "  Temperature tanks".padding(28)
    + String(format: " cold: %3.1f degC", temperatureTank.cold.celsius).padding(20)
    + String(format: "  hot: %3.1f degC", temperatureTank.hot.celsius).padding(20)
    + .lineBreak + "  Salt mass".padding(28)
    + String(format: " cold: %3.0f t", salt.cold.kg / 1000).padding(20)
    + String(format: "  hot: %3.0f t", salt.hot.kg / 1000 ).padding(20)
    + .lineBreak 
    + String(format: "  total: %3.0f t", salt.total.kg / 1000).padding(27)
    + String(format: "  active: %3.0f t", salt.active.kg / 1000).padding(21)
    + String(format: "  min: %3.0f t", salt.minimum.kg / 1000) .padding(20)
  }
}

extension Storage: MeasurementsConvertible {
  static var columns: [(name: String, unit: String)] {
    [
      ("Storage|TankCold", "degC"), ("Storage|TankHot", "degC"),
      ("Storage|Charge", "percent")
    ]
  }

  var numericalForm: [Double] {
    [temperatureTank.cold.celsius, temperatureTank.hot.celsius, relativeCharge.percentage]
  }
}
