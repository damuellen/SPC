//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

extension Plant {

  static var parameterDescriptions: String {
    heading("Fixed Parameter")
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

    if steamTurbine.power.max == 0 {
      SteamTurbine.parameter.power.max =
        Design.layout.powerBlock
        + powerBlock.fixElectricalParasitics
        + powerBlock.nominalElectricalParasitics
        + powerBlock.electricalParasiticsStep[1]
    }

    SolarField.parameter.wayLength()

    let heatExchangerCapacity =
      SolarField.parameter.HTF.deltaHeat(
        HeatExchanger.parameter.temperature.htf.inlet.max,
        HeatExchanger.parameter.temperature.htf.outlet.max
      ) / 1_000

    if Design.hasGasTurbine {

      HeatExchanger.parameter.sccHTFheat =
        Design.layout.heatExchanger
        / steamTurbine.efficiencySCC / HeatExchanger.parameter.sccEff

      let sccHTFheat = HeatExchanger.parameter.sccHTFheat
      SolarField.parameter.maxMassFlow = MassFlow(
        sccHTFheat / heatExchangerCapacity
      )

      WasteHeatRecovery.parameter.ratioHTF =
        sccHTFheat
        / (steamTurbine.power.max - sccHTFheat)

    } else {

      if Design.layout.heatExchanger != Design.layout.powerBlock {

        HeatExchanger.parameter.sccHTFheat =
          Design.layout.heatExchanger
          / steamTurbine.efficiencyNominal
          / HeatExchanger.parameter.efficiency

      } else {

        HeatExchanger.parameter.sccHTFheat =
          steamTurbine.power.max
          / steamTurbine.efficiencyNominal
          / HeatExchanger.parameter.efficiency
      }


      let sccHTFheat = HeatExchanger.parameter.sccHTFheat
      SolarField.parameter.maxMassFlow = MassFlow(
        sccHTFheat / heatExchangerCapacity
      )
    }

    if Design.hasSolarField {
      /*    let name = Collector.parameter.name
      if name.hasPrefix("SKAL-ET") {
        Collector.parameter = .sklalet
      }*/
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
          100
            / Storage.parameter.massFlowShare.percentage
            * SolarField.parameter.maxMassFlow.rate
        )
        Storage.parameter.designMassFlow = MassFlow(
          (1 - Storage.parameter.massFlowShare.ratio)
            * SolarField.parameter.maxMassFlow.rate
        )
      }
    }
    return Plant()
  }
}
