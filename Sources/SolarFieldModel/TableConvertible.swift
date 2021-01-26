//
//  Description.swift
//  SolarField
//
//  Created by Daniel Muellenborn on 23/03/2015.
//  Copyright © 2015 Daniel Muellenborn. All rights reserved.
//

import Foundation

public protocol TableConvertible {
  var name: String { get }
  var table: KeyValuePairs<String, Double> { get }
}

extension CollectorLoop: CustomStringConvertible, TableConvertible {

  public var name: String { "Loop" }
  
  public var description: String {
    "Loop " + table.description.replacingOccurrences(of: "\"", with: "")
  }

  public var table: KeyValuePairs<String, Double> {
    [
      "Volume Pipes" : volumePipes,
      "Volume Collectors" : volumeCollectors,
      "Headloss Pipes" : headLossPipes,
      "Pressuredrop Pipes" : pressureDropPipes,
      "Headloss Collectors" : headLossCollectors,
      "Pressuredrop Collectors" : pressureDropCollectors
    ]
  }
}
extension Connector: CustomStringConvertible, TableConvertible {

  public var description: String {
    name + " " + table.description.replacingOccurrences(of: "\"", with: "")
  }

  public var table: KeyValuePairs<String, Double> {
    [
      "Straight Length" : length,
      "Length" : length,
      "Volume" : volume,
      "Massflow" : massFlow,
      "Heatlosses" : heatLoss,
      "Headloss" : totalHeadLoss,
      "Pressure drop" : totalPressureDrop
    ]
  }
}
extension ExpansionVolume: CustomStringConvertible, TableConvertible {

  public var name: String { "Expansion" }
  
  public var description: String {
    "Expansion" + table.description.replacingOccurrences(of: "\"", with: "")
  }

  public var table: KeyValuePairs<String, Double> {
    [
      "Operation Volume" : operationVolume,
      "Maxmimum Volume" : maxVolume,
      "Vessel Volume" : vesselVolume
    ]
  }
}
extension PowerBlock: CustomStringConvertible, TableConvertible {

  public var description: String {
    "PowerBlock " + table.description.replacingOccurrences(of: "\"", with: "")
  }

  public var table: KeyValuePairs<String, Double> {
    [
      "Length" : length,
      "Volume" : volume,
      "Electric Power" : pumpElectricPower,
      "Heatlosses" : heatLoss,
      "Headloss" : headLoss,
      "Pressure drop" : pressureDrop
    ]
  }
}
extension SolarField: CustomStringConvertible, TableConvertible {

  public var name: String { "Solarfield" }
  
  public var description: String {
    "SolarField " + table.description.replacingOccurrences(of: "\"", with: "")
  }

  public var table: KeyValuePairs<String, Double> {
    [
      "Temperature In" : SolarField.designTemperature.inlet,
      "Temperature Out" : SolarField.designTemperature.outlet,
      "Volume" : volume,
      "Massflow" : massFlow,
      "MF Per Loop" : massFlowPerLoop,
      "Residence Time" : totalResidenceTime,
      "Heatlosses" : totalHeatLosses,
      "Headloss" : totalHeadLoss,
      "Pressure drop" : totalPressureDrop
    ]
  }
}
extension SubField: CustomStringConvertible, TableConvertible {

  public var description: String {
    name + " " + table.description.replacingOccurrences(of: "\"", with: "")
  }

  public var table: KeyValuePairs<String, Double> {
    [
      "Loops" : Double(loopsCount),
      "Length" : length,
      "Volume" : volume,
      "Massflow" : massFlow,
      "Residence Time" : totalResidenceTime,
      "Heatlosses" : heatLoss,
      "Headloss" : totalHeadLoss,
      "Pressure drop" : totalPressureDrop
    ]
  }
}
