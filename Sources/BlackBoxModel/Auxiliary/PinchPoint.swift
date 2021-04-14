

typealias Stream = HeatBalanceDiagram.Stream

struct SteamGenerator {
  var steamQuality: Double
  /// Difference between evaporation temperature and htf outlet temperature
  var temperatureDifference: Double
  var temperatureDifferenceReheat: Double
}
fileprivate let HTF = SolarField.parameter.HTF

public struct PressureDrop {
  var economizer: Double
  var economizer_steamGenerator: Double
  var steamGenerator: Double
  var steamGenerator_superHeater: Double
  var superHeater: Double
  var superHeater_turbine: Double
}

public var pd = PressureDrop(
  economizer: 1.2,
  economizer_steamGenerator: 6.0,
  steamGenerator: 0.1,
  steamGenerator_superHeater: 0.2,
  superHeater: 0.5,
  superHeater_turbine: 1.5
)

let reheatInlet = WaterSteam(temperature: .init(celsius: 217.8), pressure: 22.23, massFlow: 53.58, enthalpy: 2800.9)
let upperHTFTemperature = Temperature(celsius: 393.0)
let sg = SteamGenerator(steamQuality: 1.0, temperatureDifference: 3.0, temperatureDifferenceReheat: 29.1514)

func steamGenerator(
  pressureDrop: PressureDrop,
  steam: WaterSteam,
  parameter: SteamGenerator
) -> (Double, Double, WaterSteam, Double, Double, Double) {
  let pressureDropTotal = steam.pressure
    + pressureDrop.steamGenerator_superHeater
    + pressureDrop.superHeater
    + pressureDrop.superHeater_turbine
  let pressure = pressureDrop.steamGenerator + pressureDropTotal
  
  let enthalpyBeforeEvaporation = WaterSteam.enthalpyLiquid(pressure: pressureDropTotal)
  let enthalpyAfterEvaporation = WaterSteam.enthalpyVapor(pressure: pressureDropTotal)
  
  let enthalpy = parameter.steamQuality
    * (enthalpyAfterEvaporation - enthalpyBeforeEvaporation)
    + enthalpyBeforeEvaporation
  
  let steamGeneratorWaterOutlet = WaterSteam(
    enthalpy: enthalpy,
    pressure: pressureDropTotal,
    massFlow: steam.massFlow
  )
  let saturatedSteamTemperature = steamGeneratorWaterOutlet.temperature
  let enthalpyChangeDueToEvaporation = enthalpyAfterEvaporation - enthalpyBeforeEvaporation
  
  let evaporationPower = enthalpyChangeDueToEvaporation * steam.massFlow / 1_000
  
  let enthalpyChangeDueToSuperHeating = enthalpy - enthalpyAfterEvaporation
  
  let superHeatingPower = enthalpyChangeDueToSuperHeating * steam.massFlow / 1_000
  
  let temperatureHTF = saturatedSteamTemperature + parameter.temperatureDifference
  
  return (
    enthalpy, pressure, steamGeneratorWaterOutlet, evaporationPower,
    superHeatingPower, temperatureHTF.celsius
  )
}

func steamGenerator(
  saturatedSteam: WaterSteam,
  economizerInlet: WaterSteam,
  blowDownMassFlow: Double
) -> (Temperature, Double, Double) {
  let waterTemperature = Temperature(celsius:
                                      saturatedSteam.temperature.celsius - sg.temperatureDifference
  )
  let steamGeneratorInlet = WaterSteam.enthalpy(
    pressure: saturatedSteam.pressure,
    temperature: waterTemperature
  )
  let enthalpyBeforeEvaporation = WaterSteam.enthalpyLiquid(pressure: saturatedSteam.pressure)
  let waterEnthalpyChangeDueToPreheating =
    enthalpyBeforeEvaporation - steamGeneratorInlet
  let boilingWaterMassFlowBlowDown = blowDownMassFlow
  let powerOfBlowDownStream = boilingWaterMassFlowBlowDown
    * (enthalpyBeforeEvaporation - economizerInlet.enthalpy) / 1_000
  let powerForWaterHeatingInsideSg = waterEnthalpyChangeDueToPreheating * economizerInlet.massFlow / 1_000
  return (waterTemperature, powerForWaterHeatingInsideSg, powerOfBlowDownStream)
}

func economizer(
  htfTemperatureInlet: Temperature,
  economizerOutlet: WaterSteam,
  economizerInletFeedwater: WaterSteam,
  steamGeneratorShPower: Double,
  htfEnthalpyChangeInSgAndSh: Double
) -> (Double, Temperature, Double, Double) {
  let enthalpyOutlet = economizerOutlet.enthalpy
  let enthalpyInlet = economizerInletFeedwater.enthalpy
  let enthalpyChange = enthalpyOutlet - enthalpyInlet
  let power = enthalpyChange * economizerOutlet.massFlow / 1_000
  let htfMassFlowEc_Sg_ShTrain = steamGeneratorShPower * 1_000 / htfEnthalpyChangeInSgAndSh
  let requiredHTFEnthalpyChange = power / htfMassFlowEc_Sg_ShTrain * 1_000
  let htfEnthalpyInlet = HTF.enthalpy(htfTemperatureInlet)
  let requiredHTFEnthalpyOutlet = htfEnthalpyInlet - requiredHTFEnthalpyChange
  let htfMassflow = htfMassFlowEc_Sg_ShTrain
  let htfEnthalpyOutlet = requiredHTFEnthalpyOutlet
  let htfAbsoluteHeatFlowOutlet = htfEnthalpyOutlet * htfMassflow / 1_000
  let htfTemperatureOutlet = HTF.temperature(requiredHTFEnthalpyOutlet)
  return (htfAbsoluteHeatFlowOutlet, htfTemperatureOutlet, htfMassflow, power)
}

func reheat(
  inlet: WaterSteam,
  power: Double,
  htfTemperatureInlet: Temperature,
  parameter: SteamGenerator = sg
) -> (Double, Temperature, Double) { // D51
  let steamTemperatureInlet = inlet.temperature
  let htfTemperatureOutlet = steamTemperatureInlet + parameter.temperatureDifferenceReheat
  // let reheatLmtd = ((reheatHTFTemperatureInlet - reheatSteamTemperatureOutlet)
  //   - (reheatHTFTemperatureOutlet - reheatSteamTemperatureInlet)
  //   / log((reheatHTFTemperatureInlet - reheatSteamTemperatureOutlet)
  //   / (reheatHTFTemperatureOutlet - reheatSteamTemperatureInlet)))
  let htfEnthalpyInlet = HTF.enthalpy(htfTemperatureInlet)//D122
  let htfEnthalpyOutlet = HTF.enthalpy(htfTemperatureOutlet)//D123 D129 D132
  let htfEnthalpyChange = htfEnthalpyInlet - htfEnthalpyOutlet
  let htfMassflow = power * 1_000 / htfEnthalpyChange//D112 D131
  let htfAbsoluteHeatFlowOutlet = htfMassflow * htfEnthalpyOutlet / 1_000//D133
  return (htfAbsoluteHeatFlowOutlet, htfTemperatureOutlet, htfMassflow)
}
public func foo(
  pressureDrop: PressureDrop = pd,
  economizerFeedwaterTemperature: Double = 249.6
) -> ([HeatBalanceDiagram.Stream], [(String, String)]) {
  let economizerFeedwaterTemperature = Temperature(celsius: 249.6)
  let steam = WaterSteam(temperature: 383.0, pressure: 102.85, massFlow: 67.95)
  let blowDownOfInputMassFlow: Double = 1.0
  let reheatOutletSteamPressure: Double = 19.32
  
  let (
    enthalpy, steamGeneratorPressure, saturatedSteam, evaporationPower, superHeatingPower, temperatureHTF
  ) = steamGenerator(pressureDrop: pd, steam: steam, parameter: sg)
  
  let economizerWaterPressureOutlet = steamGeneratorPressure + pressureDrop.economizer_steamGenerator
  let economizerFeedwaterPressure = economizerWaterPressureOutlet + pressureDrop.economizer
  let economizerFeedwaterMassflow = steam.massFlow / (1 - blowDownOfInputMassFlow / 100)
  
  let economizerInletFeedwater = WaterSteam(
    temperature: economizerFeedwaterTemperature,
    pressure: economizerFeedwaterPressure,
    massFlow: economizerFeedwaterMassflow
  )
  let blowDownMassFlow = economizerFeedwaterMassflow - steam.massFlow
  
  let superheaterSteam = WaterSteam(
    temperature: steam.temperature,
    pressure: steam.pressure,
    massFlow: economizerFeedwaterMassflow
  )
  
  let superheaterPressureDrop: Double = 0.5
  let superheaterOutletSteamTemperature = WaterSteam.temperature(
    pressure: steam.pressure + superheaterPressureDrop,
    enthalpy: superheaterSteam.enthalpy + 4
  )
  
  let reheatOutlet = WaterSteam(
    temperature: steam.temperature,
    pressure: reheatOutletSteamPressure,
    massFlow: reheatInlet.massFlow
  )
  
  let (steamGeneratorWaterTemperatureInlet, steamGeneratorPowerForWaterHeatingInsideSg, steamGeneratorPowerOfBlowDownStream) = steamGenerator(
    saturatedSteam: saturatedSteam,
    economizerInlet: economizerInletFeedwater,
    blowDownMassFlow: blowDownMassFlow
  )
  
  let enthalpyChangeDueToSuperheatingSteam = superheaterSteam.enthalpy - enthalpy
  let superheaterPower = enthalpyChangeDueToSuperheatingSteam * steam.massFlow / 1_000
  let pressureDropBetwSh_OutAndTurbine_In = 1.5
  
  let superheaterSaturatedSteamEnthalpyOutletVirtual = WaterSteam.enthalpyVapor(
    pressure: steam.pressure + pressureDropBetwSh_OutAndTurbine_In
  )
  let superheaterWaterEnthalpyOutletVirtual = WaterSteam.enthalpyLiquid(
    pressure: steam.pressure + pressureDropBetwSh_OutAndTurbine_In
  )
  let superheaterSteamQualityOutlet =
    (superheaterSteam.enthalpy - superheaterWaterEnthalpyOutletVirtual)
    / (superheaterSaturatedSteamEnthalpyOutletVirtual - superheaterWaterEnthalpyOutletVirtual)
  
  let superheaterHTFEnthalpyAtTrainInlet = HTF.enthalpy(upperHTFTemperature)
  
  let steamGeneratorPower =
    evaporationPower + steamGeneratorPowerForWaterHeatingInsideSg + superHeatingPower
  let steamGeneratorShPower = steamGeneratorPower + superheaterPower
  
  let powerEvaporationAndSuperheating = superheaterPower + evaporationPower
  
  let htfEnthalpyChangeInSgAndSh =
    superheaterHTFEnthalpyAtTrainInlet - HTF.enthalpy(Temperature(celsius: temperatureHTF))
  let economizerOutlet = WaterSteam(
    temperature: steamGeneratorWaterTemperatureInlet,
    pressure: economizerWaterPressureOutlet,
    massFlow: economizerFeedwaterMassflow
  )
  let (economizerHTFAbsoluteHeatFlowOutlet, economizerHTFTemperature, economizerHTFMassflow, economizerPower) = economizer(
    htfTemperatureInlet: Temperature(celsius: temperatureHTF),
    economizerOutlet: economizerOutlet,
    economizerInletFeedwater: economizerInletFeedwater,
    steamGeneratorShPower: steamGeneratorShPower,
    htfEnthalpyChangeInSgAndSh: htfEnthalpyChangeInSgAndSh
  )
  
  let economizer_Sg_ShTrainPower = steamGeneratorPower + superheaterPower + economizerPower
  let powerEc_Sg_Sh = economizerPower + steamGeneratorPower + superheaterPower
  let reheaterPower = economizerHTFMassflow
  //  reheatInlet.massFlow * (reheatOutlet.enthalpy - reheatInlet.enthalpy) / 1_000
  let powerBlockPower = economizer_Sg_ShTrainPower + reheaterPower
  let HTFMassFlowEc_Sg_ShTrain = economizerHTFMassflow
  let steamGeneratorHTFEnthalpyChangeForWaterHeatingInSg = steamGeneratorPowerForWaterHeatingInsideSg
    * 1_000 / HTFMassFlowEc_Sg_ShTrain
  //let steamGeneratorHTFEnthalpyAtPinchPoint = steamGeneratorHTFEnthalpyOutlet + steamGeneratorHTFEnthalpyChangeForWaterHeatingInSg
  //let steamGeneratorHTFTemperatureAtPinchPoint = steamGeneratorHTFTemperatureAtOutlet
  
  let (reheatHTFAbsoluteHeatFlowOutlet, reheatHTFTemperatureOutlet, reheatHTFMassflow) = reheat(
    inlet: reheatInlet, power: reheaterPower, htfTemperatureInlet: upperHTFTemperature
  )
  
  let mixHTFAbsoluteHeatFlow = economizerHTFAbsoluteHeatFlowOutlet + reheatHTFAbsoluteHeatFlowOutlet//D134
  let mixHTFMassflow = economizerHTFMassflow + reheatHTFMassflow//D135
  let mixHTFAbsoluteEnthalpy = mixHTFAbsoluteHeatFlow * 1_000 / mixHTFMassflow //D136
  let mixHTFTemperature = HTF.temperature(mixHTFAbsoluteEnthalpy)//D137
  return ([
    Stream(stream: economizerInletFeedwater),
    Stream(temperature: economizerHTFTemperature, pressure: 0, massFlow: economizerHTFMassflow, enthalpy: economizerHTFAbsoluteHeatFlowOutlet),
    Stream(temperature: reheatHTFTemperatureOutlet, pressure: 0, massFlow: reheatHTFMassflow, enthalpy: reheatHTFAbsoluteHeatFlowOutlet),
    Stream(temperature: mixHTFTemperature, pressure: 0, massFlow: mixHTFMassflow, enthalpy: mixHTFAbsoluteEnthalpy)
  ],[("blowDownMassFlow","\(blowDownMassFlow)")])
}

public func temperatures() -> String {
  let ec = "\"EC\"\n\(0), \(250.8)\n\(22.2), \(313.4)\n\n\n"
  let sg = "\"SG\"\n\(22.2), \(316.4)\n\(107.9), \(316.4)\n\n\n"
  let sh = "\"SH\"\n\(107.9), \(316.4)\n\(128.8), \(380.0)\n\n\n"
  let rh = "\"RH\"\n\(128.8), \(217.8)\n\(150.3), \(380.0)\n\n\n"
  let htf = "\"HTF\"\n\(0), \(303.2)\n\(22.2), \(319.4)\n\(128.8), \(393.0)\n\n\n"
  let htfrh = "\"HTF RH\"\n\(128.8), \(246.9)\n\(150.3), \(393.0)\n"
  return ec + sg + sh + rh + htf + htfrh
}
