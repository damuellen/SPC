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
  static func setupComponentParameters() {
    guard componentsNeedUpdate else { return }
    //componentsNeedUpdate = false
    let steamTurbine = SteamTurbine.parameter
    let powerBlock = PowerBlock.parameter
    
    if steamTurbine.power.max == 0 {
      SteamTurbine.parameter.power.max = Design.layout.powerBlock
        + powerBlock.fixelectricalParasitics
        + powerBlock.nominalElectricalParasitics
        + powerBlock.electricalParasiticsStep[1]
    }
    
    let solarField = SolarField.parameter
    
    if Design.hasGasTurbine {
      
      HeatExchanger.parameter.sccHTFheat = Design.layout.heatExchanger
        / steamTurbine.efficiencySCC / HeatExchanger.parameter.sccEff
      
      let designHeatExchanger = solarField.HTF.deltaHeat(
        HeatExchanger.parameter.scc.htf.outlet.max,
        HeatExchanger.parameter.scc.htf.inlet.max
      )
      
      let heatExchanger = HeatExchanger.parameter
      SolarField.parameter.massFlow.max = MassFlow(
        heatExchanger.sccHTFheat * 1_000 / designHeatExchanger
      )
      
      WasteHeatRecovery.parameter.ratioHTF = heatExchanger.sccHTFheat
        / (steamTurbine.power.max - heatExchanger.sccHTFheat)
      
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
      )
      
      SolarField.parameter.massFlow.max = MassFlow(
        HeatExchanger.parameter.sccHTFheat * 1_000 / designHeatExchanger
      )
    }

    if Design.hasSolarField {
      let numberOfSCAsInRow = Double(solarField.numberOfSCAsInRow)
      let edgeFactor1 = solarField.distanceSCA / 2
        * (1 - 1 / numberOfSCAsInRow)
        / Collector.parameter.lengthSCA
      let edgeFactor2 = (1 + 1 / numberOfSCAsInRow)
        / Collector.parameter.lengthSCA / 2
      SolarField.parameter.edgeFactor = [edgeFactor1, edgeFactor2]
    }
  }
}
