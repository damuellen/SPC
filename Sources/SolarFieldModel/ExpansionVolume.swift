//
//  ExpansionVolume.swift
//  SolarField
//
//  Created by Daniel Muellenborn on 23/03/2015.
//  Copyright © 2015 Daniel Muellenborn. All rights reserved.
//

public class ExpansionVolume {

  public let temperatureFillIn: Double
  lazy var solarField: SolarField = SolarField.shared

  var temperatureLoops: Double {
    let temperature = solarField.designTemperature
    return (temperature.inlet + temperature.outlet) / 2.0
  }

  public var totalMass: Double {
    let mass = self.mass()
    return mass.coldHeaders + mass.hotHeaders + mass.loops + mass.powerBlock
  }

  public var maxVolume: Double {
    let densityHotHeaders = Fluid.terminol.density(
      solarField.designTemperature.outlet
    )
    return totalMass / densityHotHeaders
  }

  var vesselVolume: Double { maxVolume - solarField.volume }

  public init(temperatureFillIn: Double = 35) {
    self.temperatureFillIn = temperatureFillIn
  }

  private func mass()
    -> (coldHeaders: Double, hotHeaders: Double, loops: Double, powerBlock: Double) {
      let densityFillIn = solarField.fluid.density(temperatureFillIn)
      let massColdHeaders = solarField.volumeColdHeaders * densityFillIn
      let massHotHeaders = solarField.volumeHotHeaders * densityFillIn
      let massLoops = solarField.volumeLoops * densityFillIn
      let massPowerBlock = solarField.powerBlock.volume * densityFillIn

      return (massColdHeaders, massHotHeaders, massLoops, massPowerBlock)
  }

  private func density() -> (coldHeaders: Double, hotHeaders: Double, loops: Double) {

    let densityColdHeaders = solarField.fluid.density(
      solarField.designTemperature.inlet
    )
    let densityHotHeaders = solarField.fluid.density(
      solarField.designTemperature.outlet
    )
    let densityLoops = solarField.fluid.density(temperatureLoops)

    return (densityColdHeaders, densityHotHeaders, densityLoops)
  }

  public var operationVolume: Double {

    let density = self.density()
    let mass = self.mass()

    var operationVolume = mass.coldHeaders / density.coldHeaders
    operationVolume += mass.hotHeaders / density.hotHeaders
    operationVolume += mass.loops / density.loops
    operationVolume += mass.powerBlock / density.loops
    return operationVolume
  }
}
