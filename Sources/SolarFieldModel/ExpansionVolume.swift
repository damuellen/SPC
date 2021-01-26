//
//  ExpansionVolume.swift
//  SolarField
//
//  Created by Daniel Muellenborn on 23/03/2015.
//  Copyright © 2015 Daniel Muellenborn. All rights reserved.
//

public class ExpansionVolume {

  public let temperatureFillIn: Double

  private unowned let solarField: SolarField 

  var temperatureLoops: Double {
    let temperature = SolarField.designTemperature
    return (temperature.inlet + temperature.outlet) / 2.0
  }

  public var totalMass: Double {
    let mass = self.mass()
    return mass.coldHeaders + mass.hotHeaders + mass.loops + mass.powerBlock
  }

  public var maxVolume: Double {
    let densityHotHeaders = Fluid.terminol.density(
      SolarField.designTemperature.outlet
    )
    return totalMass / densityHotHeaders
  }

  var vesselVolume: Double { maxVolume - solarField.volume }

  public init(temperatureFillIn: Double = 35, solarField: SolarField) {
    self.solarField = solarField 
    self.temperatureFillIn = temperatureFillIn
  }

  private func mass()
    -> (coldHeaders: Double, hotHeaders: Double, loops: Double, powerBlock: Double) {
      let densityFillIn = SolarField.fluid.density(temperatureFillIn)
      let massColdHeaders = solarField.volumeColdHeaders * densityFillIn
      let massHotHeaders = solarField.volumeHotHeaders * densityFillIn
      let massLoops = solarField.volumeLoops * densityFillIn
      let massPowerBlock = solarField.powerBlock.volume * densityFillIn

      return (massColdHeaders, massHotHeaders, massLoops, massPowerBlock)
  }

  private func density() -> (coldHeaders: Double, hotHeaders: Double, loops: Double) {

    let densityColdHeaders = SolarField.fluid.density(
      SolarField.designTemperature.inlet
    )
    let densityHotHeaders = SolarField.fluid.density(
      SolarField.designTemperature.outlet
    )
    let densityLoops = SolarField.fluid.density(temperatureLoops)

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
