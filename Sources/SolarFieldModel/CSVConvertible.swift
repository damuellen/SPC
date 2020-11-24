//
//  CSVConvertible.swift
//  SolarField
//
//  Created by Daniel Muellenborn on 23/03/2015.
//  Copyright © 2015 Daniel Muellenborn. All rights reserved.
//

protocol CommaSeparatedValuesConvertible {
  var commaSeparatedValues: String { get }
}

extension CommaSeparatedValuesConvertible {
  static var separator: String { "," }
}

extension Branch: CommaSeparatedValuesConvertible {

  public static var tableHeader: String {
    let values = [
      "Name",
      "Size",
      "Length",
      "Temperature",
      "Volume",
      "MassFlow",
      "ReynoldsNumber",
      "StreamVelocity",
      "ResidenceTime",
      "HeadLoss",
      "PressureDrop",
      "HeatLosses",
      "Elbows",
      "Reducers",
      "Valves",
      ]

    return values.joined(separator: separator)
  }

  public var commaSeparatedValues: String {
    let values = [
      name,
      nps.description,
      length.description,
      temperature.description,
      volume.description,
      massFlow.description,
      reynoldsnumber.description,
      streamVelocity.description,
      residenceTime.description,
      headLoss.description,
      pressureDrop.description,
      heatLosses.description,
      numberOfElbows.description,
      hasReducer ? "yes" : "no",
      hasValve ? "yes" : "no"
    ]

    return values.joined(separator: Branch.separator)
  }
}
