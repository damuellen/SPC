//
//  CSVConvertible.swift
//  SolarField
//
//  Created by Daniel Muellenborn on 23/03/2015.
//  Copyright © 2015 Daniel Muellenborn. All rights reserved.
//

extension Branch {

  public static var tableHeader: [String] {
    [
      "Size",
      "Length",
      "Temperature",
      "Volume",
      "MassFlow",
      "ReynoldsNumber",
      "StreamVelocity",
      "ResidenceTime",
      "HeadLoss",
      "Pressure drop",
      "HeatLosses",
      "Elbows",
     // "Reducers",
     // "Valves",
    ]
  }

  public var values: [Double] {
    [
      Double(nps),
      length,
      temperature,
      volume,
      massFlow,
      reynoldsnumber,
      streamVelocity,
      residenceTime,
      headLoss,
      pressureDrop,
      heatLosses,
      Double(numberOfElbows),
    //  hasReducer ? "yes" : "no",
    //  hasValve ? "yes" : "no"
    ]
  }
}
