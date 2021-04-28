//
//  Copyright 2021 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import PhysicalQuantities
import BlackBoxModel
import Libc

typealias Stream = HeatBalanceDiagram.Stream

fileprivate let HTF = ParameterDefaults.HTF

public struct HeatExchangerParameter: Codable {
  /// Difference between evaporation temperature and htf outlet temperature
  var temperatureDifferenceSteamGenerator: Double
  var temperatureDifferenceReheat: Double
  var steamQuality: Double
  var pressureDrop: PressureDrop

  struct PressureDrop: Codable {
    var economizer: Double
    var economizer_steamGenerator: Double
    var steamGenerator: Double
    var steamGenerator_superHeater: Double
    var superHeater: Double
    var superHeater_turbine: Double
  }
}

struct PinchPoint: Codable {

  let ws = WaterSteam(
    temperature: Temperature(celsius: 383.0),
    pressure: 102.85,
    massFlow: 67.95
  )

  let blowDownOfInputMassFlow: Double = 1.0

  let reheatOutletSteamPressure: Double = 19.32

  let reheatInlet = WaterSteam(
    temperature: Temperature(celsius: 217.8),
    pressure: 22.23,
    massFlow: 53.58,
    enthalpy: 2800.9
  )

  let upperHTFTemperature: Temperature = Temperature(celsius: 393)

  let economizerFeedwaterTemperature = Temperature(celsius: 249.6)

  let parameter: HeatExchangerParameter

  var economizer = HeatExchanger()
  var superheater = HeatExchanger()
  var reheater = HeatExchanger()
  var steamGenerator = HeatExchanger()

  mutating func evaporation() -> (Double, Double, Double) {
    let pd = parameter.pressureDrop

    let pressureDropTotal = ws.pressure
      + pd.steamGenerator_superHeater + pd.superHeater + pd.superHeater_turbine
    
    let enthalpyBeforeEvaporation = 
      WaterSteam.enthalpyLiquid(pressure: pressureDropTotal)

    let enthalpyAfterEvaporation = 
      WaterSteam.enthalpyVapor(pressure: pressureDropTotal)
    
    let enthalpy = enthalpyBeforeEvaporation + parameter.steamQuality
      * (enthalpyAfterEvaporation - enthalpyBeforeEvaporation)
    
    steamGenerator.enthalpy.ws.outlet = enthalpy
    steamGenerator.pressure.ws.outlet = pressureDropTotal
    steamGenerator.massFlow.ws = ws.massFlow

    steamGenerator.temperature.ws.outlet = WaterSteam.temperature(
      pressure: pressureDropTotal, enthalpy: enthalpy
    )

    let enthalpyChangeDueToEvaporation = 
      enthalpyAfterEvaporation - enthalpyBeforeEvaporation
    
    let evaporationPower = enthalpyChangeDueToEvaporation * ws.massFlow / 1_000
    
    let enthalpyChangeDueToSuperHeating = ws.enthalpy - enthalpyAfterEvaporation
    
    let superHeatingPower = enthalpyChangeDueToSuperHeating * ws.massFlow / 1_000
    
    return (enthalpyBeforeEvaporation, evaporationPower, superHeatingPower)
  }

  mutating func powerSteamGenerator() -> Double {
    steamGenerator.temperature.ws.inlet =
      steamGenerator.temperature.ws.outlet 
      - parameter.temperatureDifferenceSteamGenerator

    steamGenerator.enthalpy.ws.inlet = WaterSteam.enthalpy(
      pressure: steamGenerator.pressure.ws.outlet,
      temperature: steamGenerator.temperature.ws.inlet
    )

    let enthalpyBeforeEvaporation = WaterSteam
      .enthalpyLiquid(pressure: steamGenerator.pressure.ws.outlet)

    let waterEnthalpyChangeDueToPreheating = 
      enthalpyBeforeEvaporation - steamGenerator.enthalpy.ws.inlet

    let powerForWaterHeatingInsideSg = 
      waterEnthalpyChangeDueToPreheating * economizer.massFlow.ws / 1_000

    return powerForWaterHeatingInsideSg
  }

  mutating func preheat() -> Double {
    economizer.enthalpy.ws.inlet = WaterSteam.enthalpy(
      pressure: economizer.pressure.ws.inlet, temperature: economizer.temperature.ws.inlet
    )

    economizer.enthalpy.ws.outlet = WaterSteam.enthalpy(
      pressure: economizer.pressure.ws.outlet, temperature: economizer.temperature.ws.outlet
    )

    economizer.power = economizer.wsEnthalpyChange * economizer.massFlow.ws / 1_000

    let requiredHTFEnthalpyChange = economizer.power / economizer.massFlow.htf * 1_000

    economizer.enthalpy.htf.inlet = HTF.enthalpy(economizer.temperature.htf.inlet)
    let requiredHTFEnthalpyOutlet = economizer.enthalpy.htf.inlet - requiredHTFEnthalpyChange

    economizer.enthalpy.htf.outlet = requiredHTFEnthalpyOutlet

    economizer.temperature.htf.outlet = HTF.temperature(requiredHTFEnthalpyOutlet)

    let htfAbsoluteHeatFlowOutlet = 
      economizer.enthalpy.htf.outlet * economizer.massFlow.htf / 1_000

    return htfAbsoluteHeatFlowOutlet
  }

  mutating func reheat() -> Double { // D51
    reheater.temperature.htf.outlet = 
      reheater.temperature.ws.inlet + parameter.temperatureDifferenceReheat
    let htf = reheater.temperature.htf
    let ws = reheater.temperature.ws
    
    let reheatLmtd = 
      (htf.inlet.kelvin - ws.outlet.kelvin) - (htf.outlet.kelvin - ws.inlet.kelvin)
      / log((htf.inlet.kelvin - ws.outlet.kelvin) / (htf.outlet.kelvin - ws.inlet.kelvin))

    reheater.enthalpy.htf.inlet = HTF.enthalpy(reheater.temperature.htf.inlet)
    reheater.enthalpy.htf.outlet = HTF.enthalpy(reheater.temperature.htf.outlet)

    reheater.massFlow.htf = reheater.power * 1_000 / reheater.htfEnthalpyChange

    let htfAbsoluteHeatFlowOutlet = 
      reheater.massFlow.htf * reheater.enthalpy.htf.outlet / 1_000
    
    return htfAbsoluteHeatFlowOutlet
  }

  mutating func callAsFunction() {
    steamGenerator.temperature.ws.inlet = ws.temperature

    let (enthalpyBeforeEvaporation, evaporationPower, superHeatingPower) = 
      evaporation()

    let pressureDrop = parameter.pressureDrop
    steamGenerator.pressure.ws.inlet = 
      pressureDrop.steamGenerator + steamGenerator.pressure.ws.outlet

    economizer.pressure.ws.outlet = 
      steamGenerator.pressure.ws.inlet + pressureDrop.economizer_steamGenerator
    
    economizer.temperature.ws.inlet = economizerFeedwaterTemperature

    economizer.pressure.ws.inlet = 
      economizer.pressure.ws.outlet + pressureDrop.economizer

    economizer.massFlow.ws = ws.massFlow / (1 - blowDownOfInputMassFlow / 100)

    let blowDownMassFlow =  economizer.massFlow.ws - ws.massFlow
    
    let powerForWaterHeatingInsideSg = powerSteamGenerator()

    let boilingWaterMassFlowBlowDown = blowDownMassFlow

    let powerOfBlowDownStream = boilingWaterMassFlowBlowDown
      * (enthalpyBeforeEvaporation - economizer.enthalpy.ws.inlet) / 1_000

    steamGenerator.power = 
      evaporationPower + powerForWaterHeatingInsideSg + superHeatingPower
    
    let powerEvaporationAndSuperheating = superheater.power + evaporationPower

    superheater.temperature.ws.inlet = ws.temperature

    superheater.pressure.ws.inlet = ws.pressure

    superheater.enthalpy.ws.inlet = WaterSteam.enthalpy(
      pressure: superheater.pressure.ws.inlet,
      temperature: superheater.temperature.ws.inlet
    )
    superheater.massFlow.ws = economizer.massFlow.ws

    superheater.pressure.ws.outlet = ws.pressure + pressureDrop.superHeater

    superheater.enthalpy.ws.outlet = superheater.enthalpy.ws.inlet + 4

    superheater.temperature.ws.outlet = WaterSteam.temperature(
      pressure: superheater.pressure.ws.outlet,
      enthalpy: superheater.enthalpy.ws.outlet
    )

    let enthalpyChangeDueToSuperheatingSteam = 
      superheater.enthalpy.ws.inlet + steamGenerator.enthalpy.ws.outlet

    superheater.power = enthalpyChangeDueToSuperheatingSteam * ws.massFlow / 1_000

    let superheaterSaturatedSteamEnthalpyOutletVirtual = WaterSteam.enthalpyVapor(
      pressure: ws.pressure + pressureDrop.superHeater_turbine
    )

    let superheaterWaterEnthalpyOutletVirtual = WaterSteam.enthalpyLiquid(
      pressure: ws.pressure + pressureDrop.superHeater_turbine
    )

    let superheaterSteamQualityOutlet =
      (superheater.enthalpy.ws.inlet - superheaterWaterEnthalpyOutletVirtual)
      / (superheaterSaturatedSteamEnthalpyOutletVirtual - superheaterWaterEnthalpyOutletVirtual)
    
    superheater.temperature.htf.inlet = upperHTFTemperature
    superheater.enthalpy.htf.inlet = HTF.enthalpy(superheater.temperature.htf.inlet)
    
    superheater.temperature.htf.outlet =
      steamGenerator.temperature.ws.outlet 
      + parameter.temperatureDifferenceSteamGenerator
    
    superheater.enthalpy.htf.outlet = HTF.enthalpy(superheater.temperature.htf.outlet)

    steamGenerator.temperature.htf.outlet = steamGenerator.temperature.ws.inlet 
      + parameter.temperatureDifferenceSteamGenerator

    steamGenerator.enthalpy.htf.outlet = HTF.enthalpy(steamGenerator.temperature.htf.outlet)

    economizer.temperature.ws.outlet = steamGenerator.temperature.ws.inlet

    economizer.temperature.htf.inlet = steamGenerator.temperature.htf.outlet

    let steamGeneratorShPower = steamGenerator.power + superheater.power

    let htfMassFlowEc_Sg_ShTrain = 
      steamGeneratorShPower * 1_000 / superheater.htfEnthalpyChange

    superheater.massFlow.htf = htfMassFlowEc_Sg_ShTrain

    economizer.massFlow.htf = htfMassFlowEc_Sg_ShTrain    

    let economizerHTFAbsoluteHeatFlowOutlet = preheat()

    let economizer_Sg_ShTrainPower = 
      steamGenerator.power + superheater.power + economizer.power

    let powerEc_Sg_Sh = 
      economizer.power + steamGenerator.power + superheater.power

    reheater.temperature.ws.outlet = ws.temperature

    reheater.pressure.ws.outlet = reheatOutletSteamPressure

    reheater.enthalpy.ws.outlet = WaterSteam.enthalpy(
      pressure: reheatOutletSteamPressure, temperature: ws.temperature
    )

    reheater.massFlow.ws = reheatInlet.massFlow

    reheater.temperature.ws.inlet = reheatInlet.temperature

    reheater.enthalpy.ws.inlet = reheatInlet.enthalpy

    reheater.pressure.ws.inlet = reheatInlet.pressure

    reheater.temperature.htf.inlet = upperHTFTemperature

    reheater.power = reheater.massFlow.ws * reheater.wsEnthalpyChange / 1_000
    
    let powerBlockPower = economizer_Sg_ShTrainPower + reheater.power

    steamGenerator.massFlow.htf = htfMassFlowEc_Sg_ShTrain

    steamGenerator.temperature.htf.inlet = superheater.temperature.htf.outlet

    steamGenerator.enthalpy.htf.inlet = HTF.enthalpy(steamGenerator.temperature.htf.inlet)

    let steamGeneratorHTFEnthalpyChangeForWaterHeatingInSg = 
      powerForWaterHeatingInsideSg * 1_000 / steamGenerator.massFlow.htf

    let steamGeneratorHTFEnthalpyAtPinchPoint = 
      steamGenerator.enthalpy.htf.outlet 
      + steamGeneratorHTFEnthalpyChangeForWaterHeatingInSg

    let steamGeneratorHTFTemperatureAtPinchPoint = 
      steamGenerator.temperature.htf.outlet
    
    let reheatHTFAbsoluteHeatFlowOutlet = reheat()
    
    let mixHTFAbsoluteHeatFlow = economizerHTFAbsoluteHeatFlowOutlet 
      + reheatHTFAbsoluteHeatFlowOutlet

    let mixHTFMassflow = economizer.massFlow.htf + reheater.massFlow.htf

    let mixHTFAbsoluteEnthalpy = mixHTFAbsoluteHeatFlow * 1_000 / mixHTFMassflow

    let mixHTFTemperature = HTF.temperature(mixHTFAbsoluteEnthalpy)
    print(mixHTFTemperature, mixHTFAbsoluteEnthalpy, mixHTFMassflow)
  }

  func temperatures() -> String {
    """
    "EC"
    \(0), \(economizer.temperature.ws.inlet.celsius)
    \(economizer.power), \(economizer.temperature.ws.outlet.celsius)


    "SG"
    \(22.2), \(313.4)
    \(22.2), \(316.4)
    \(22.2), \(316.4)
    \(107.9), \(316.4)


    "SH"
    \(107.9), \(316.4)
    \(128.8), \(380.0)


    "RH"
    \(128.8), \(217.8)
    \(150.3), \(380.0)
    

    "HTF"
    \(0), \(303.2)
    \(22.2), \(319.4)
    \(128.8), \(393.0)


    "HTF RH"
    \(128.8), \(246.9)
    \(150.3), \(393.0)
    """
  }
}

struct HeatExchanger: Codable {
  var massFlow = MassFlow()
  var temperature = Temperatures()
  var enthalpy = Enthalpy()
  var pressure = Pressure()
  var power: Double = 0.0

  var htfEnthalpyChange: Double {
    enthalpy.htf.inlet - enthalpy.htf.outlet
  }

  var wsEnthalpyChange: Double {
    enthalpy.ws.outlet - enthalpy.ws.inlet
  }
}

struct Connection<T: Codable>: Codable {
  var inlet: T
  var outlet: T
} 

extension HeatExchanger {

  struct MassFlow: Codable {
    var htf: Double = 0
    var ws: Double = 0
  }

  struct Enthalpy: Codable {
    var htf: Connection = .init(inlet: 0.0, outlet: 0.0)
    var ws: Connection = .init(inlet: 0.0, outlet: 0.0)
  }

  struct Pressure: Codable {
    var ws: Connection = .init(inlet: 0.0, outlet: 0.0)
  }

  struct Temperatures: Codable {
    var htf: Connection<Temperature> = .init(inlet: 0.0, outlet: 0.0)
    var ws: Connection<Temperature> = .init(inlet: 0.0, outlet: 0.0)
  }
}

/*

EC Power Inlet
EC Power Outlet
EC Temperature Inlet 
EC Temperature Outlet

SG Power Inlet
SG Power at Pinch-Point
SG Power after Evaporation
SG Power Outlet 
SG Water Temperature Inlet 
SG Water Temperature Start Evaporation (Pinch-Point) 
SG Steam Temperature after Evaporation
SG Steam Temperature Outlet 

SH Power Inlet 
SH Power after Evaporation 
SH Power Outlet 
SH Steam Temperature Inlet 
SH Steam Temperature after Evaporation 
SH Steam Temperature Outlet

HTF Temperature Inlet 
HTF Temperature Pinch-Point 
HTF Temperature SG Outlet 
HTF Temperature EC Outlet 

RH Steam Temperature Inlet 
RH Steam Temperature Outlet 
RH Power Inlet 
RH Power Outlet 
RH HTF Temperature Inlet 
RH HTF Temperature Outlet 
*/