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
  static func setup() -> Plant {
    let steamTurbine = SteamTurbine.parameter
    let powerBlock = PowerBlock.parameter
    
    if steamTurbine.power.max == 0 {
      SteamTurbine.parameter.power.max = Design.layout.powerBlock
        + powerBlock.fixElectricalParasitics
        + powerBlock.nominalElectricalParasitics
        + powerBlock.electricalParasiticsStep[1]
    }
    SolarField.parameter.wayLength()
    let solarField = SolarField.parameter

    if Design.hasGasTurbine {
      
      HeatExchanger.parameter.sccHTFheat = Design.layout.heatExchanger
        / steamTurbine.efficiencySCC / HeatExchanger.parameter.sccEff
      
      let designHeatExchanger = solarField.HTF.deltaHeat(
        HeatExchanger.parameter.scc.htf.outlet.max,
        HeatExchanger.parameter.scc.htf.inlet.max
      ) / 1_000
      
      let sccHTFheat = HeatExchanger.parameter.sccHTFheat
      SolarField.parameter.massFlow.max = MassFlow(
        sccHTFheat / designHeatExchanger
      )
      
      WasteHeatRecovery.parameter.ratioHTF = sccHTFheat
        / (steamTurbine.power.max - sccHTFheat)
      
    } else {
      
      if Design.layout.heatExchanger != Design.layout.powerBlock {
        
        HeatExchanger.parameter.sccHTFheat = Design.layout.heatExchanger
          / steamTurbine.efficiencyNominal
          / HeatExchanger.parameter.efficiency
        
      } else {
        
        HeatExchanger.parameter.sccHTFheat = steamTurbine.power.max
          / steamTurbine.efficiencyNominal
          / HeatExchanger.parameter.efficiency
      }
      
      let designHeatExchanger = solarField.HTF.deltaHeat(
        HeatExchanger.parameter.temperature.htf.inlet.max,
        HeatExchanger.parameter.temperature.htf.outlet.max
      ) / 1_000
      
      SolarField.parameter.massFlow.max = MassFlow(
        HeatExchanger.parameter.sccHTFheat / designHeatExchanger
      )
    }

    if Design.hasSolarField {
  /*    let name = Collector.parameter.name
      if name.hasPrefix("SKAL-ET") {
        Collector.parameter = .sklalet
      }*/

      let numberOfSCAsInRow = Double(solarField.numberOfSCAsInRow)
      let edgeFactor1 = solarField.distanceSCA / 2
        * (1 - 1 / numberOfSCAsInRow)
        / Collector.parameter.lengthSCA
      let edgeFactor2 = (1 + 1 / numberOfSCAsInRow)
        / Collector.parameter.lengthSCA / 2
      SolarField.parameter.edgeFactor = [edgeFactor1, edgeFactor2]

      if Design.hasStorage {
        SolarField.parameter.massFlow.max = MassFlow(100
          / Storage.parameter.massFlow.rate
          * SolarField.parameter.massFlow.max.rate
        )
        Storage.parameter.massFlow = MassFlow(
          (1 - Storage.parameter.massFlow.rate / 100)
            * SolarField.parameter.massFlow.max.rate
        )
      }
    }
    return Plant()
  }
}
