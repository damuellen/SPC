//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Utilities

extension Plant {

  static var parameterDescriptions: String {
    decorated("Fixed Parameter")
    + "HEAT TRANSFER FLUID\n\n\(SolarField.parameter.HTF)\n\n"
    + "HEATER\n\n\(Heater.parameter)\n"
    + "HEAT EXCHANGER\n\n\(HeatExchanger.parameter)\n"
    + "STEAM TURBINE\n\n\(SteamTurbine.parameter)\n"
    + "STORAGE\n\n\(Storage.parameter)\n"
    + "SOLAR FIELD\n\n\(SolarField.parameter)\n"
    + "COLLECTOR\n\n\(Collector.parameter)\n"
  }
  /// Sets some component parameter 
  static func setup() -> Plant {
    let steamTurbine = SteamTurbine.parameter
    let powerBlock = PowerBlock.parameter

    if steamTurbine.power.max == .zero {
      SteamTurbine.parameter.power.max =
        Design.layout.powerBlock
        + powerBlock.fixElectricalParasitics
        + powerBlock.nominalElectricalParasitics
        + powerBlock.electricalParasiticsStep[1]
    }

    SolarField.parameter.wayLength()

    HeatExchanger.parameter.heatFlowHTF = HeatExchanger.parameter.heatFlow()

    if Design.hasGasTurbine {
      let heatFlowRate = HeatExchanger.parameter.heatFlowHTF
      WasteHeatRecovery.parameter.ratioHTF =
        heatFlowRate / (steamTurbine.power.max - heatFlowRate)
    } 

    let heatFlowRate = HeatExchanger.parameter.heatFlowHTF * 1_000
    SolarField.parameter.maxMassFlow = MassFlow(
      heatFlowRate / HeatExchanger.capacity
    )

    if Design.hasSolarField {
      let numberOfSCAsInRow = Double(SolarField.parameter.numberOfSCAsInRow)
      let edgeFactor1 =
        SolarField.parameter.distanceSCA / 2
        * (1 - 1 / numberOfSCAsInRow)
        / Collector.parameter.lengthSCA
      let edgeFactor2 =
        (1 + 1 / numberOfSCAsInRow)
        / Collector.parameter.lengthSCA / 2
      SolarField.parameter.edgeFactor = [edgeFactor1, edgeFactor2]

      if Design.hasStorage {
        SolarField.parameter.maxMassFlow = MassFlow(
          SolarField.parameter.maxMassFlow.rate / Storage.parameter.massFlowShare.quotient
        )
      }
    }
    return Plant()
  }
}
