// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import Utilities
import Libc

/// Pinch point calculation for heat exchangers.
public struct Calculation: Codable {
  public init(parameter: HeatExchangerParameter) {
    self.parameter = parameter
  }
  /// The heat transfer fluid for the system.
  public var HTF = HeatTransferFluid.VP1

  /// The mass flow rate of the heat transfer fluid in the mixing point.
  public var mixHTFMassflow = 0.0

  /// The absolute enthalpy of the heat transfer fluid in the mixing point.
  public var mixHTFAbsoluteEnthalpy = 0.0

  /// The temperature of the heat transfer fluid in the mixing point.
  public var mixHTFTemperature: Temperature = 0.0

  /// The upper temperature limit for the heat transfer fluid.
  public var upperHTFTemperature = Temperature(celsius: 393)

  /// The feedwater temperature to the economizer.
  public var economizerFeedwaterTemperature = Temperature(celsius: 250.8)

  /// The properties of the turbine (temperature, pressure, and mass flow).
  public var turbine = WaterSteam(
    temperature: .init(celsius: 380.0),
    pressure: 102.85,
    massFlow: 66.42
  )

  /// The continuous blowdown of input mass flow in percentage (%).
  public var blowDownOfInputMassFlow = 1.0 // %

  public var reheatInlet = WaterSteam(
    temperature: .init(celsius: 217.8),
    pressure: 22.23,
    massFlow: 53.58,
    enthalpy: 2800.9
  )

  public var reheatOutletSteamPressure = 21.02

  let parameter: HeatExchangerParameter

  // Heat exchanger instances
  var economizer = HeatExchanger()
  var superheater = HeatExchanger()
  var reheater = HeatExchanger()
  var steamGenerator = HeatExchanger()

  /// The total power output of the power block.
  public var powerBlockPower: Double {
    economizer.power
      + steamGenerator.power
      + superheater.power
      + reheater.power
  }
  
  /// The temperature difference required for the reheater.
  var reheaterTemperatureDifference: Double {
    reheater(requiredLMTD: parameter.requiredLMTD)
  }
  /// Continuous blow down of input massflow
  var blowDownMassFlow: Double {
    economizer.massFlow.ws.outlet - superheater.massFlow.ws.inlet
  }

  /// Calculate the evaporation process in the steam generator.
  mutating func evaporation() -> (Double, Double, Double) {
    let pd = parameter.pressureDrop
    let pressureDropTotal =
      turbine.pressure
      + pd.steamGenerator_superHeater + pd.superHeater + pd.superHeater_turbine

    steamGenerator.pressure.ws.outlet = pressureDropTotal

    let enthalpyBeforeEvaporation =
      WaterSteam.enthalpyLiquid(pressure: pressureDropTotal)

    let enthalpyAfterEvaporation =
      WaterSteam.enthalpyVapor(pressure: pressureDropTotal)

    let enthalpy =
      enthalpyBeforeEvaporation + parameter.steamQuality
      * (enthalpyAfterEvaporation - enthalpyBeforeEvaporation)

    steamGenerator.enthalpy.ws.outlet = enthalpy

    steamGenerator.temperature.ws.outlet = WaterSteam.temperature(
      pressure: steamGenerator.pressure.ws.outlet,
      enthalpy: steamGenerator.enthalpy.ws.outlet
    )

    let enthalpyChangeDueToEvaporation =
      enthalpyAfterEvaporation - enthalpyBeforeEvaporation
    let evaporationPower = enthalpyChangeDueToEvaporation * turbine.massFlow / 1_000

    let enthalpyChangeDueToSuperHeating = enthalpy - enthalpyAfterEvaporation
    let superHeatingPower = enthalpyChangeDueToSuperHeating * turbine.massFlow / 1_000

    return (enthalpyBeforeEvaporation, evaporationPower, superHeatingPower)
  }

  /// Calculate the power for the steam generator.
  mutating func powerSteamGenerator() -> Double {
    steamGenerator.enthalpy.ws.inlet = WaterSteam.enthalpy(
      pressure: steamGenerator.pressure.ws.outlet,
      temperature: steamGenerator.temperature.ws.inlet
    )

    let enthalpyBeforeEvaporation =
      WaterSteam.enthalpyLiquid(pressure: steamGenerator.pressure.ws.outlet)

    let waterEnthalpyChangeDueToPreheating =
      enthalpyBeforeEvaporation - steamGenerator.enthalpy.ws.inlet

    let powerForWaterHeatingInsideSg =
      waterEnthalpyChangeDueToPreheating * economizer.massFlow.ws.outlet / 1_000

    return powerForWaterHeatingInsideSg
  }

  /// Preheat the heat transfer fluid in the economizer.
  mutating func preheat() -> Double {
    economizer.enthalpy.ws.inlet = WaterSteam.enthalpy(
      pressure: economizer.pressure.ws.inlet,
      temperature: economizer.temperature.ws.inlet
    )

    economizer.enthalpy.ws.outlet = WaterSteam.enthalpy(
      pressure: economizer.pressure.ws.outlet,
      temperature: economizer.temperature.ws.outlet
    )

    economizer.power = economizer.wsEnthalpyChange * economizer.massFlow.ws.outlet / 1_000  //

    let requiredHTFEnthalpyChange = economizer.power / economizer.massFlow.htf * 1_000

    economizer.enthalpy.htf.inlet = HTF.enthalpy(economizer.temperature.htf.inlet)
    let requiredHTFEnthalpyOutlet = economizer.enthalpy.htf.inlet - requiredHTFEnthalpyChange

    economizer.enthalpy.htf.outlet = requiredHTFEnthalpyOutlet
    economizer.temperature.htf.outlet = HTF.temperature(economizer.enthalpy.htf.outlet)

    let htfAbsoluteHeatFlowOutlet =
      economizer.massFlow.htf * economizer.enthalpy.htf.outlet / 1_000

    return htfAbsoluteHeatFlowOutlet
  }

  /// Reheat the heat transfer fluid in the reheater.
  mutating func reheat() -> Double {
    reheater.temperature.htf.outlet =
      reheater.temperature.ws.inlet + reheaterTemperatureDifference

    reheater.enthalpy.htf.inlet = HTF.enthalpy(reheater.temperature.htf.inlet)
    reheater.enthalpy.htf.outlet = HTF.enthalpy(reheater.temperature.htf.outlet)

    reheater.massFlow.htf = reheater.power * 1_000 / reheater.htfEnthalpyChange

    let htfAbsoluteHeatFlowOutlet =
      reheater.massFlow.htf * reheater.enthalpy.htf.outlet / 1_000

    return htfAbsoluteHeatFlowOutlet
  }
  /// Calculate the required LMTD for reheater.
  func reheater(requiredLMTD: Double) -> Double {
    seek(goal: requiredLMTD, 1...50) {
      ((upperHTFTemperature.kelvin - turbine.temperature.kelvin) - $0)
        / (log((upperHTFTemperature.kelvin - turbine.temperature.kelvin) / $0))
    }
  }

  /// Perform the calculations for the heat exchanger system.
  public mutating func callAsFunction() {
    reheater.temperature.ws.outlet = turbine.temperature
    reheater.pressure.ws.outlet = reheatOutletSteamPressure

    reheater.enthalpy.ws.outlet = WaterSteam.enthalpy(
      pressure: reheater.pressure.ws.outlet,
      temperature: reheater.temperature.ws.outlet
    )

    reheater.massFlow.ws.inlet = reheatInlet.massFlow
    reheater.temperature.ws.inlet = reheatInlet.temperature
    reheater.enthalpy.ws.inlet = reheatInlet.enthalpy
    reheater.pressure.ws.inlet = reheatInlet.pressure
    reheater.massFlow.ws.outlet = reheater.massFlow.ws.inlet
    reheater.temperature.htf.inlet = upperHTFTemperature

    reheater.power = reheater.massFlow.ws.outlet * reheater.wsEnthalpyChange / 1_000
    economizer.temperature.ws.inlet = economizerFeedwaterTemperature

    steamGenerator.temperature.ws.inlet = turbine.temperature
    steamGenerator.massFlow.ws.outlet = turbine.massFlow

    let (enthalpyBeforeEvaporation, evaporationPower, superHeatingPower) =
      evaporation()
    _ = enthalpyBeforeEvaporation
    /// Specified pressure drop of heat exchangers
    let pressureDrop = parameter.pressureDrop

    steamGenerator.pressure.ws.inlet =
      steamGenerator.pressure.ws.outlet + pressureDrop.steamGenerator
    steamGenerator.temperature.ws.inlet =
      steamGenerator.temperature.ws.outlet - parameter.temperatureDifferenceWater

    economizer.temperature.ws.outlet = steamGenerator.temperature.ws.inlet
    economizer.pressure.ws.outlet =
      steamGenerator.pressure.ws.inlet + pressureDrop.economizer_steamGenerator
    economizer.pressure.ws.inlet =
      economizer.pressure.ws.outlet + pressureDrop.economizer
    economizer.massFlow.ws.inlet =
      turbine.massFlow / (1 - blowDownOfInputMassFlow / 100)
    economizer.massFlow.ws.outlet = economizer.massFlow.ws.inlet

    steamGenerator.massFlow.ws.inlet = economizer.massFlow.ws.outlet

    let powerForWaterHeatingInsideSg = powerSteamGenerator()

    let boilingWaterMassFlowBlowDown = blowDownMassFlow

    let powerOfBlowDownStream =
      boilingWaterMassFlowBlowDown
      * (enthalpyBeforeEvaporation - economizer.enthalpy.ws.inlet) / 1_000
    _ = powerOfBlowDownStream
    steamGenerator.power =
      evaporationPower + powerForWaterHeatingInsideSg + superHeatingPower

    // let powerEvaporationAndSuperheating = superheater.power + evaporationPower

    superheater.enthalpy.ws.inlet = steamGenerator.enthalpy.ws.outlet
    superheater.enthalpy.ws.outlet = turbine.enthalpy
    superheater.pressure.ws.outlet = turbine.pressure + pressureDrop.superHeater_turbine
    superheater.massFlow.ws.inlet = turbine.massFlow
    superheater.massFlow.ws.outlet = superheater.massFlow.ws.inlet
    superheater.pressure.ws.inlet = superheater.pressure.ws.outlet + pressureDrop.superHeater

    superheater.temperature.ws.inlet = WaterSteam.temperature(
      pressure: superheater.pressure.ws.inlet,
      enthalpy: superheater.enthalpy.ws.inlet
    )
    superheater.temperature.ws.outlet = WaterSteam.temperature(
      pressure: superheater.pressure.ws.outlet,
      enthalpy: superheater.enthalpy.ws.outlet
    )
    let superheaterSaturatedSteamEnthalpyOutletVirtual = WaterSteam.enthalpyVapor(
      pressure: turbine.pressure + pressureDrop.superHeater_turbine
    )
    let superheaterWaterEnthalpyOutletVirtual = WaterSteam.enthalpyLiquid(
      pressure: turbine.pressure + pressureDrop.superHeater_turbine
    )

    let superheaterSteamQualityOutlet =
      (superheater.enthalpy.ws.inlet - superheaterWaterEnthalpyOutletVirtual)
      / (superheaterSaturatedSteamEnthalpyOutletVirtual - superheaterWaterEnthalpyOutletVirtual)
    _ = superheaterSteamQualityOutlet
    let enthalpyChangeDueToSuperheatingSteam =
      superheater.enthalpy.ws.outlet - steamGenerator.enthalpy.ws.outlet

    superheater.power = enthalpyChangeDueToSuperheatingSteam * turbine.massFlow / 1_000

    superheater.temperature.htf.inlet = upperHTFTemperature
    superheater.enthalpy.htf.inlet = HTF.enthalpy(superheater.temperature.htf.inlet)

    let saturatedSteam = WaterSteam.temperature(pressure: steamGenerator.pressure.ws.outlet)

    steamGenerator.temperature.htf.outlet = saturatedSteam + parameter.temperatureDifferenceHTF
    economizer.temperature.htf.inlet = steamGenerator.temperature.htf.outlet
    steamGenerator.enthalpy.htf.outlet = HTF.enthalpy(steamGenerator.temperature.htf.outlet)

    let htfMassFlowEc_Sg_ShTrain =
      (steamGenerator.power + superheater.power) * 1_000
      / (superheater.enthalpy.htf.inlet - steamGenerator.enthalpy.htf.outlet)

    superheater.massFlow.htf = htfMassFlowEc_Sg_ShTrain
    steamGenerator.massFlow.htf = htfMassFlowEc_Sg_ShTrain
    economizer.massFlow.htf = htfMassFlowEc_Sg_ShTrain

    superheater.enthalpy.htf.outlet = superheater.enthalpy.htf.inlet
      - (superheater.power * 1_000 / superheater.massFlow.htf)
    superheater.temperature.htf.outlet = HTF.temperature(superheater.enthalpy.htf.outlet)

    steamGenerator.temperature.htf.inlet = superheater.temperature.htf.outlet
    steamGenerator.enthalpy.htf.inlet = HTF.enthalpy(steamGenerator.temperature.htf.inlet)

    let steamGeneratorHTFEnthalpyChangeForWaterHeatingInSg =
      powerForWaterHeatingInsideSg * 1_000 / steamGenerator.massFlow.htf
    _ = steamGeneratorHTFEnthalpyChangeForWaterHeatingInSg
    // let steamGeneratorHTFEnthalpyAtPinchPoint =
    //   steamGenerator.enthalpy.htf.outlet
    //   + steamGeneratorHTFEnthalpyChangeForWaterHeatingInSg

    // let steamGeneratorHTFTemperatureAtPinchPoint =
    //   steamGenerator.temperature.htf.outlet

    let economizerHTFAbsoluteHeatFlowOutlet = preheat()
    let reheatHTFAbsoluteHeatFlowOutlet = reheat()

    let mixHTFAbsoluteHeatFlow =
      economizerHTFAbsoluteHeatFlowOutlet
      + reheatHTFAbsoluteHeatFlowOutlet

    mixHTFMassflow = economizer.massFlow.htf + reheater.massFlow.htf

    mixHTFAbsoluteEnthalpy = mixHTFAbsoluteHeatFlow * 1_000 / mixHTFMassflow

    mixHTFTemperature = HTF.temperature(mixHTFAbsoluteEnthalpy)
  }

  /// Get the temperatures in the heat exchanger system.
  public func temperatures() -> String {
    """
    $data <<EOD
    "EC"
    \(0) \(economizer.temperature.ws.inlet.celsius)
    \(economizer.power) \(economizer.temperature.ws.outlet.celsius)


    "SG"
    \(economizer.power) \(steamGenerator.temperature.ws.inlet.celsius)
    \(economizer.power) \(steamGenerator.temperature.ws.outlet.celsius) //SG Water Temperature Start Evaporation (Pinch-Point) [°C]
    \(economizer.power) \(steamGenerator.temperature.ws.outlet.celsius) //SG Steam Temperature after Evaporation [°C]
    \(steamGenerator.power) \(steamGenerator.temperature.ws.outlet.celsius)


    "SH"
    \(steamGenerator.power) \(superheater.temperature.ws.inlet.celsius)
    \(powerBlockPower - reheater.power) \(superheater.temperature.ws.outlet.celsius)


    "RH"
    \(powerBlockPower - reheater.power) \(reheater.temperature.ws.inlet.celsius)
    \(powerBlockPower) \(reheater.temperature.ws.outlet.celsius)


    "HTF"
    \(0) \(economizer.temperature.htf.outlet.celsius)
    \(economizer.power) \(steamGenerator.temperature.htf.outlet.celsius)
    \(powerBlockPower - reheater.power) \(upperHTFTemperature.celsius)


    "HTF RH"
    \(powerBlockPower - reheater.power) \(reheater.temperature.htf.outlet.celsius)
    \(powerBlockPower) \(reheater.temperature.htf.inlet.celsius)


    EOD
    """
  }
}

