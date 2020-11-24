//
//  FluidMechanics.swift
//  SolarField
//
//  Created by Daniel Muellenborn on 23/03/2015.
//  Copyright © 2015 Daniel Muellenborn. All rights reserved.
//

import Libc

typealias Kinematic = Double
typealias Dynamic = Double

public enum Fluid: String, Codable {
  case terminol, solarSalt

  var density: (_ temperature: Double) -> Double {

    func terminol(_ temperature: Double) -> Double {
      var result = -0.90797 * temperature
      result += 7.8116e-4 * pow(temperature, 2)
      result -= 2.367e-6 * pow(temperature, 3)
      result += 1083.25
      return result
    }

    func solarSalt(_ temperature: Double) -> Double {
      2090 - 0.636 * temperature
    }

    switch self {
    case .terminol: return terminol
    case .solarSalt: return solarSalt
    }
  }

  var viscosity: (_ temperature: Double) -> Double {

    func ny(_ temperature: Double) -> Kinematic {
      let result = exp(544.149 / (temperature + 114.43) - 2.59578)
      return result
    }

    func eta(_ temperature: Double) -> Dynamic {
      let result = ny(temperature) * density(temperature) / 10e5
      return result
    }

    func solarSalt(_ temperature: Double) -> Double {
      var result = 22.714 - 0.12 * temperature
      result += 0.0002281 * pow(temperature, 2)
      result -= 0.0000001474 * pow(temperature, 3)
      return result / 1000
    }

    switch self {
    case .terminol: return eta
    case .solarSalt: return solarSalt
    }
  }
}

extension Branch {

  static var fluid: Fluid { return SolarField.shared.fluid }

  static func insideDiameter(outsideDiameter: Double,
                             wallThickness: Double) -> Double {
    let result = outsideDiameter - (wallThickness + wallThickness)
    return result // Millimeter
  }

  static func crossSectionalArea(diameter: Double) -> Double {
    var result = pow(diameter / 1000, 2)
    result *= .pi / 4
    return result // Quadratmeter
  }

  static func frictionFactor(diameter: Double,
                             pipeRoughness: Double) -> Double {
    var result = log10(diameter / pipeRoughness)
    result *= 2.0
    result += 1.14
    result = pow(result, -2)
    return result
  }

  static func volumeFlow(massFlow: Double, temperature: Double) -> Double {
    massFlow / fluid.density(temperature)
  }

  static func streamVelocity(volumeFlow: Double,
                             crossSectionalArea: Double) -> Double {
    volumeFlow / crossSectionalArea // meter per second
  }

  static func reynoldsNumber(streamVelocity: Double,
                             insideDiameter: Double,
                             temperature: Double) -> Double {
    var result = fluid.density(temperature)
    result *= streamVelocity * insideDiameter
    result /= fluid.viscosity(temperature)
    return result
  }

  // Darcy friction factor Serghides equation
  static func frictionFactor(insideDiameter:Double,
                             pipeRoughness: Double,
                             reynoldsNumber: Double) -> Double {
    let s = (pipeRoughness / insideDiameter) / 3.7
    let A = -2 * log10(s + 12 / reynoldsNumber)
    let B = -2 * log10(s + ((2.51 * A) / reynoldsNumber))
    let C = -2 * log10(s + ((2.51 * B) / reynoldsNumber))
    let lambda = pow(A - (pow(B - A, 2) / (C - 2 * B + A)), -2)
    return lambda
  }

  static func headLoss(frictionFactor: Double,
                       length: Double,
                       diameter: Double,
                       streamVelocity: Double) -> Double {
    var result = length / (diameter / 1000)
    result *= pow(streamVelocity, 2) / 19.62
    result *= frictionFactor
    return result // meter
  }

  static func headLoss(lossCoeficient: Double,
                       streamVelocity: Double) -> Double {
    var result = lossCoeficient
    result *= pow(streamVelocity, 2) / 19.62
    return result // meter
  }

  static func pressureDrop(headLoss: Double, temperature: Double) -> Double {
    let result = fluid.density(temperature) * headLoss
    return result * 9.81e-5 // bar
  }
}
