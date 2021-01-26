//
//  Collector.swift
//  SolarField
//
//  Created by Daniel Muellenborn on 23/03/2015.
//  Copyright © 2015 Daniel Muellenborn. All rights reserved.
//

struct Collector {

  let roughness = 0.10
  var scaleMassFlow = 1.0
  var temperature: Double
  var length: Double
  var insideDiameter: Double
  
  private unowned let subField: SubField

  init(temperature: Double,
       length: Double = 148.4,
       insideDiameter: Double = 66.0,
       subField: SubField) {
    self.temperature = temperature
    self.length = length
    self.insideDiameter = insideDiameter
    self.subField = subField
  }

  var crossSectionArea: Double {
    Branch.crossSectionalArea(diameter: insideDiameter)
  }

  var frictionFactor: Double {
    Branch.frictionFactor(insideDiameter: insideDiameter,
                          pipeRoughness: roughness,
                          reynoldsNumber: reynoldsnumber)
  }

  var reynoldsnumber: Double {
    Branch.reynoldsNumber(streamVelocity: streamVelocity,
                          insideDiameter: insideDiameter,
                          temperature: temperature)
  }

  var volume: Double { crossSectionArea * Double(length) }

  var designMassFlow: Double { subField.solarField.massFlowPerLoop }

  var massFlow: Double { designMassFlow * scaleMassFlow }

  var volumeFlow: Double {
    Branch.volumeFlow(massFlow: massFlow, temperature: temperature)
  }

  var streamVelocity: Double {
    Branch.streamVelocity(volumeFlow: volumeFlow,
                          crossSectionalArea: crossSectionArea)
  }

  var residenceTime: Double { length / streamVelocity }

  var headLoss: Double {
    Branch.headLoss(frictionFactor: frictionFactor,
                    length: length,
                    diameter: insideDiameter,
                    streamVelocity: streamVelocity)
  }

  var pressureDrop: Double {
    Branch.pressureDrop(headLoss: headLoss, temperature: temperature)
  }
}

extension Sequence where Element == Collector {
  func total(_ keyPath: KeyPath<Collector, Double>) -> Double {
    return map { $0[keyPath: keyPath] }.reduce(0.0, +)
  }
}
