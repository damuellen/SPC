
func bar() -> (Double, Double, Double, Double, Double, Double, Double) {
  let liveSteamMassflow: Double = 67.95
  let liveSteamPressureAtTurbineInlet: Double = 102.85
  let pressureDropBetw_Sg_Sh: Double = 0.2
  let superheaterPressureDrop: Double = 0.5
  let pressureDropBetwSh_OutAndTurbine_In = 1.5
  let steamgeneratorPressureDrop: Double = 0.1
  let steamgeneratorSteamQualityOutlet: Double = 1.0
  let steamgeneratorTemperatureDifferenceBetweenEvaporationTemperatureAndSgHtfOutletTemperature:
    Double = 3.0

  let pressure =
    liveSteamPressureAtTurbineInlet + pressureDropBetw_Sg_Sh + superheaterPressureDrop
    + pressureDropBetwSh_OutAndTurbine_In
  let steamgeneratorPressure = steamgeneratorPressureDrop + pressure

  let enthalpyAfterEvaporation = WaterSteam.enthalpyVapor(p: pressure)
  let enthalpyBeforeEvaporation = WaterSteam.enthalpyLiquid(p: pressure)
  let steamQuality = steamgeneratorSteamQualityOutlet
  let enthalpy =
    steamQuality * (enthalpyAfterEvaporation - enthalpyBeforeEvaporation)
    + enthalpyBeforeEvaporation
  //let steamgeneratorWaterTemperatureOutlet = WaterSteam.temperature(p: steamgeneratorSteamOutletPressure, h: steamgeneratorSteamEnthalpyOutlet)
  let saturatedSteamTemperature = WaterSteam.temperature(p: pressure)
  let enthalpyChangeDueToEvaporation = enthalpyAfterEvaporation - enthalpyBeforeEvaporation
  let evaporationPower = enthalpyChangeDueToEvaporation * liveSteamMassflow / 1_000
  let enthalpyChangeDueToSuperHeating = enthalpy - enthalpyAfterEvaporation
  let superHeatingPower = enthalpyChangeDueToSuperHeating * liveSteamMassflow / 1_000
  let temperatureHTF =
    saturatedSteamTemperature
    + steamgeneratorTemperatureDifferenceBetweenEvaporationTemperatureAndSgHtfOutletTemperature
  let steamgeneratorHtfEnthalpyOutlet = SolarField.parameter.HTF.enthalpy(temperatureHTF)
  return (
    enthalpy, steamgeneratorPressure, saturatedSteamTemperature.celsius, evaporationPower,
    enthalpyBeforeEvaporation, superHeatingPower, temperatureHTF.celsius
  )
}

public func foo() -> Double {

  let economizerInletFeedwaterTemperature: Double = 249.6

  let liveSteamMassflow: Double = 67.95
  let liveSteamTemperatureAtTurbineInlet: Double = 383.0
  let blowDownOfInputMassFlow: Double = 1.0

  let reheatInletSteamTemperature: Double = 214.4
  //let reheatInletSteamPressure: Double = 20.78
  let reheatInletSteamEnthalpy: Double = 2799.2
  let reheatInletSteamMassflow: Double = 56.63
  let reheatOutletSteamPressure: Double = 19.32

  //let HexCase = 2
  let upperHtfTemperature: Double = 393.0

  let steamgeneratorTemperatureDifferenceBetweenEvaporationTemperatureAndSgWaterInletTemperature:
    Double = 3.0
  let reheatOil_Outlet_SteamInletTemperatureDifference: Double = 35.1286
  let economizerPressureDrop: Double = 1.2
  let pressureDropBetw_Ec_Sg: Double = 6.0

  let liveSteamPressureAtTurbineInlet: Double = 102.85
  let (
    enthalpy, steamgeneratorPressure, saturatedSteamTemperature, evaporationPower,
    enthalpyBeforeEvaporation, superHeatingPower, temperatureHTF
  ) = bar()

  let economizerWaterPressureOutlet = steamgeneratorPressure + pressureDropBetw_Ec_Sg
  let economizerInletFeedwaterPressure = economizerWaterPressureOutlet + economizerPressureDrop
  let economizerInletFeedwaterEnthalpy = WaterSteam.enthalpy(
    p: economizerInletFeedwaterPressure,
    t: Temperature(celsius: economizerInletFeedwaterTemperature))
  let economizerFeedwaterMassflow = liveSteamMassflow / (1 - blowDownOfInputMassFlow / 100)
  //let blowDownMassFlow = economizerFeedwaterMassflow - liveSteamMassflow
  let superheaterLiveSteamEnthalpy = WaterSteam.enthalpy(
    p: liveSteamPressureAtTurbineInlet, t: Temperature(celsius: liveSteamTemperatureAtTurbineInlet))
  //let superheaterOutletSteamTemperature = WaterSteam.temperature(p: liveSteamPressureAtTurbineInlet + superheaterPressureDrop, h: superheaterLiveSteamEnthalpy)
  let reheatOutletSteamTemperature = liveSteamTemperatureAtTurbineInlet
  let reheatOutletSteamEnthalpy = WaterSteam.enthalpy(
    p: reheatOutletSteamPressure, t: Temperature(celsius: reheatOutletSteamTemperature))
  //let reheatOutletSteamMassflow = reheatInletSteamMassflow

  let steamgeneratorWaterMassFlowInlet = economizerFeedwaterMassflow

  let steamgeneratorWaterTemperatureInlet =
    saturatedSteamTemperature
    - steamgeneratorTemperatureDifferenceBetweenEvaporationTemperatureAndSgWaterInletTemperature
  let steamgeneratorWaterEnthalpyInlet = WaterSteam.enthalpy(
    p: steamgeneratorPressure, t: Temperature(celsius: steamgeneratorWaterTemperatureInlet))
  let steamgeneratorWaterEnthalpyChangeDueToPreheating =
    enthalpyBeforeEvaporation - steamgeneratorWaterEnthalpyInlet
  let steamgeneratorPowerForWaterHeatingInsideSg =
    steamgeneratorWaterEnthalpyChangeDueToPreheating * steamgeneratorWaterMassFlowInlet / 1_000
  //let steamgeneratorBoilingWaterMassFlowBlowDown = blowDownMassFlow
  //let steamgeneratorPowerOfBlowDownStream = steamgeneratorBoilingWaterMassFlowBlowDown * (steamgeneratorWaterEnthalpyBeforeEvaporation - economizerInletFeedwaterEnthalpy) / 1_000

  let superheaterEnthalpyChangeDueToSuperheatingSteam = superheaterLiveSteamEnthalpy - enthalpy
  let superheaterPower = superheaterEnthalpyChangeDueToSuperheatingSteam * liveSteamMassflow / 1_000
  //let superheaterSaturatedSteamEnthalpyOutletVirtual = WaterSteam.enthalpyVapor(p: liveSteamPressureAtTurbineInlet + pressureDropBetwSh_OutAndTurbine_In)
  //let superheaterWaterEnthalpyOutletVirtual = WaterSteam.enthalpyLiquid(p: liveSteamPressureAtTurbineInlet + pressureDropBetwSh_OutAndTurbine_In)
  //let superheaterSteamQualityOutlet = (superheaterLiveSteamEnthalpy - superheaterWaterEnthalpyOutletVirtual) / (superheaterSaturatedSteamEnthalpyOutletVirtual - superheaterWaterEnthalpyOutletVirtual)
  let superheaterHtfEnthalpyAtTrainInlet = SolarField.parameter.HTF.enthalpy(
    Temperature(celsius: upperHtfTemperature))

  let steamgeneratorPower =
    evaporationPower + steamgeneratorPowerForWaterHeatingInsideSg + superHeatingPower
  let steamgeneratorShPower = steamgeneratorPower + superheaterPower

  //let PowerEvaporationAndSuperheating = superheaterPower + steamgeneratorEvaporationPower

  let HtfEnthalpyChangeInSgAndSh =
    superheaterHtfEnthalpyAtTrainInlet
    - SolarField.parameter.HTF.enthalpy(Temperature(celsius: temperatureHTF))
  let HtfMassFlowEc_Sg_ShTrain = steamgeneratorShPower * 1_000 / HtfEnthalpyChangeInSgAndSh

  let waterTemperatureEcOutlet = steamgeneratorWaterTemperatureInlet
  let economizerWaterMassFlow = economizerFeedwaterMassflow

  let economizerWaterEnthalpyOutlet = WaterSteam.enthalpy(
    p: economizerWaterPressureOutlet, t: Temperature(celsius: waterTemperatureEcOutlet))
  let economizerWaterEnthalpyInlet = economizerInletFeedwaterEnthalpy
  let economizerWaterEnthalpyChange = economizerWaterEnthalpyOutlet - economizerWaterEnthalpyInlet
  let economizerPower = economizerWaterEnthalpyChange * economizerWaterMassFlow / 1_000
  let economizerHtfTemperatureInlet = temperatureHTF
  let economizerHtfEnthalpyInlet = SolarField.parameter.HTF.enthalpy(
    Temperature(celsius: economizerHtfTemperatureInlet))
  let economizerRequiredHtfEnthalpyChange = economizerPower / HtfMassFlowEc_Sg_ShTrain * 1_000
  let economizerRequiredHtfEnthalpyOutlet =
    economizerHtfEnthalpyInlet - economizerRequiredHtfEnthalpyChange
  let economizerHtfMassflow = HtfMassFlowEc_Sg_ShTrain
  let economizerHtfEnthalpyOutlet = economizerRequiredHtfEnthalpyOutlet
  let economizerHtfAbsoluteHeatFlowOutlet =
    economizerHtfEnthalpyOutlet * economizerHtfMassflow / 1_000
  //let HtfTemperatureAtEcOutlet = SolarField.parameter.HTF.temperature(economizerRequiredHtfEnthalpyOutlet)

  //let economizer_Sg_ShTrainPower = steamgeneratorPower + superheaterPower + economizerPower
  //let PowerEc_Sg_Sh = economizerPower + steamgeneratorPower + superheaterPower
  let ReheaterPower =
    reheatInletSteamMassflow * (reheatOutletSteamEnthalpy - reheatInletSteamEnthalpy) / 1_000
  //let powerBlockPower = economizer_Sg_ShTrainPower + ReheaterPower

  //let steamgeneratorHtfEnthalpyChangeForWaterHeatingInSg = steamgeneratorPowerForWaterHeatingInsideSg * 1_000 / HtfMassFlowEc_Sg_ShTrain
  //let steamgeneratorHtfEnthalpyAtPinchPoint = steamgeneratorHtfEnthalpyOutlet + steamgeneratorHtfEnthalpyChangeForWaterHeatingInSg
  //let steamgeneratorHtfTemperatureAtPinchPoint = steamgeneratorHtfTemperatureAtOutlet

  let reheatPower = ReheaterPower
  let reheatHtfTemperatureInlet = upperHtfTemperature
  let reheatSteamTemperatureInlet = reheatInletSteamTemperature
  let reheatHtfTemperatureOutlet =
    reheatSteamTemperatureInlet + reheatOil_Outlet_SteamInletTemperatureDifference
  //let reheatLmtd = ((reheatHtfTemperatureInlet - reheatSteamTemperatureOutlet) - (reheatHtfTemperatureOutlet - reheatSteamTemperatureInlet) / log((reheatHtfTemperatureInlet - reheatSteamTemperatureOutlet)/(reheatHtfTemperatureOutlet - reheatSteamTemperatureInlet)))
  let reheatHtfEnthalpyInlet = SolarField.parameter.HTF.enthalpy(
    Temperature(celsius: reheatHtfTemperatureInlet))
  let reheatHtfEnthaplyOutlet = SolarField.parameter.HTF.enthalpy(
    Temperature(celsius: reheatHtfTemperatureOutlet))
  let reheatHtfEnthalpyChange = reheatHtfEnthalpyInlet - reheatHtfEnthaplyOutlet
  let reheatHtfMassflow = reheatPower * 1_000 / reheatHtfEnthalpyChange

  let reheatHtfEnthalpyOutlet = reheatHtfEnthaplyOutlet
  let reheatHtfAbsoluteHeatFlowOutlet = reheatHtfMassflow * reheatHtfEnthalpyOutlet / 1_000

  let MixHtfAbsoluteHeatFlow = economizerHtfAbsoluteHeatFlowOutlet + reheatHtfAbsoluteHeatFlowOutlet
  let MixHtfMassflow = economizerHtfMassflow + reheatHtfMassflow
  let MixHtfAbsoluteEnthalpy = MixHtfAbsoluteHeatFlow * 1_000 / MixHtfMassflow
  let mixHtfTemperature = SolarField.parameter.HTF.temperature(MixHtfAbsoluteEnthalpy)
  return mixHtfTemperature.kelvin
}
