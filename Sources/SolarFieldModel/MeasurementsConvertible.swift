//
//  Description.swift
//  SolarField
//
//  Created by Daniel Muellenborn on 23/03/2015.
//  Copyright © 2015 Daniel Muellenborn. All rights reserved.
//

public protocol MeasurementsConvertible {
  var name: String { get }
  var measurements: [String : String] { get }
}

extension CollectorLoop: CustomStringConvertible {

  public var description: String {
    return "Loop " + measurements.description.replacingOccurrences(of: "\"", with: "")
  }

  public var measurements: [String : String] {
    return [
      "Volume Pipes" : String(format:"%.2f ", volumePipes),
      "Volume Collectors" : String(format:"%.2f ", volumeCollectors),
      "Headloss Pipes" : String(format:"%.2f ", headLossPipes),
      "Pressuredrop Pipes" : String(format:"%.2f ", pressureDropPipes),
      "Headloss Collectors" : String(format:"%.2f ", headLossCollectors),
      "Pressuredrop Collectors" : String(format:"%.2f ", pressureDropCollectors)
    ]
  }
}
extension Connector: CustomStringConvertible {

  public var description: String {
    return name + " " + measurements.description.replacingOccurrences(of: "\"", with: "")
  }

  public var measurements: [String : String] {
    return [
      "Straight Length" : String(format:"%.2f ", length),
      "Length" : String(format:"%.2f ", length),
      "Volume" : String(format:"%.2f ", volume),
      "Massflow" : String(format:"%.2f ", massFlow),
      "Heatlosses" : String(format:"%.2f ", heatLoss),
      "Headloss" : String(format:"%.2f ", totalHeadLoss),
      "Pressuredrop" : String(format:"%.2f ", totalPressureDrop)
    ]
  }
}
extension ExpansionVolume: CustomStringConvertible {

  public var description: String {
    return "Expansion" + measurements.description.replacingOccurrences(of: "\"", with: "")
  }

  public var measurements: [String : String] {
    return [
      "Operation Volume" : String(format:"%.2f ", operationVolume),
      "Maxmimum Volume" : String(format:"%.2f ", maxVolume),
      "Vessel Volume" : String(format:"%.2f ", vesselVolume)
    ]
  }
}
extension PowerBlock: CustomStringConvertible {

  public var description: String {
    return "PowerBlock " + measurements.description.replacingOccurrences(of: "\"", with: "")
  }

  public var measurements: [String : String] {
    return [
      "Length" : String(format:"%.2f ", length),
      "Volume" : String(format:"%.2f ", volume),
      "Electric Power" : String(format:"%.2f ", pumpElectricPower),
      "Heatlosses" : String(format:"%.2f ", heatLoss),
      "Headloss" : String(format:"%.2f ", headLoss),
      "Pressuredrop" : String(format:"%.2f ", pressureDrop)
    ]
  }
}
extension SolarField: CustomStringConvertible {

  public var description: String {
    return "SolarField " + measurements.description.replacingOccurrences(of: "\"", with: "")
  }

  public var measurements: [String : String] {
    return [
      "Temperature In" : String(format:"%.2f ", designTemperature.inlet),
      "Temperature Out" : String(format:"%.2f ", designTemperature.outlet),
      "Volume" : String(format:"%.2f ", volume),
      "Massflow" : String(format:"%.2f ", massFlow),
      "MF Per Loop" : String(format:"%.2f ", massFlowPerLoop),
      "Residence Time" : String(format:"%.2f ", totalResidenceTime),
      "Heatlosses" : String(format:"%.2f ", totalHeatLosses),
      "Headloss" : String(format:"%.2f ", totalHeadLoss),
      "Pressuredrop" : String(format:"%.2f ", totalPressureDrop)
    ]
  }
}
extension SubField: CustomStringConvertible, MeasurementsConvertible {

  public var description: String {
    return name + " " + measurements.description.replacingOccurrences(of: "\"", with: "")
  }

  public var measurements: [String : String] {
    return [
      "Loops" : String(loopsCount),
      "Length" : String(format:"%.2f ", length),
      "Volume" : String(format:"%.2f ", volume),
      "Massflow" : String(format:"%.2f ", massFlow),
      "Residence Time" : String(format:"%.2f ", totalResidenceTime),
      "Heatlosses" : String(format:"%.2f ", heatLoss),
      "Headloss" : String(format:"%.2f ", totalHeadLoss),
      "Pressuredrop" : String(format:"%.2f ", totalPressureDrop)
    ]
  }
}
