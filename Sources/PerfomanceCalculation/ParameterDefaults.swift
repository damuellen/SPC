//
//  Copyright (c) 2017 Daniel Müllenborn. All rights reserved.
//  Distributed under the The Non-Profit Open Software License version 3.0
//  http://opensource.org/licenses/NPOSL-3.0
//
//  This project is NOT free software. It is open source, you are allowed to
//  modify it (if you keep the license), but it may not be commercially
//  distributed other than under the conditions noted above.
//

public enum ParameterDefaults {
  
  public static func assign() {
    HeatExchanger.assign(parameter: hx)
    GasTurbine.assign(parameter: gt)
    SolarField.assign(parameter: sf)
    Storage.assign(parameter: st)
    Collector.assign(parameter: LS3)
    SteamTurbine.assign(parameter: tb)
    PowerBlock.assign(parameter: pb)
    WasteHeatRecovery.assign(parameter: whr)
    Heater.assign(parameter: hr)
    Boiler.assign(parameter: bo)
  }
  
  static let hx = HeatExchanger.Parameter(
    name: "",
    efficiency: 99,
    SCCEff: 99,
    temperature: HeatExchanger.Parameter.Temperatures(
      htf: (inlet: (max: 390, min: 260), outlet: (max: 292, min: 198)),
      h2o: (inlet: (max: 344, min: 255), outlet: (max: 154, min: 128))),
    scc: HeatExchanger.Parameter.Temperatures(
      htf: (inlet: (max: 390, min: 370), outlet: (max: 295, min: 258)),
      h2o: (inlet: (max: 344, min: 255), outlet: (max: 154, min: 100))),
    SCCHTFmassFlow: 1080,
    SCCHTFheat: 200,
    ToutMassFlow: nil,
    ToutTin: nil,
    ToutTinMassFlow: nil,
    useAndsolFunction: false,
    Tout_f_Mfl: false,
    Tout_f_Tin: false,
    Tout_exp_Tin_Mfl: false)
  
  static let gt = GasTurbine.Parameter(
    name: "",
    Pgross: 1.1,
    efficiencyISO: 1,
    Lmin: 1,
    altitude: 1,
    EfofLc: [41, 44, 47, 50, 53],
    loadmaxTc: [60, 63, 66, 69, 72],
    parasiticsLc: [79, 82, 85, 88, 91],
    designTemperature: 200)
  
  
  static let sf = SolarField.Parameter(
    imbalanceDesign: (1.0,1.0,1.0),
    imbalanceMin: (1.0,1.025,1.0),
    windCoefficients: .init(values: 0),
    useReferenceAmbientTemperature: false,
    referenceAmbientTemperature: 0.0,
    heatlosses: [0.0],
    designTemperature: (inlet: 293.0, outlet: 393.0),
    name: "",
    maxWind: Float(14.5),
    numberOfSCAsInRow: 2,
    rowDistance: 17.2,
    distanceSCA: 1.5,
    pipeHL: 13.0,
    azim: 0.0,
    elev: 0.0,
    antiFreezeParastics: 0.5,
    pumpParastics: [0.15, -0.293, 1.257],
    massFlow: (1070.0, 30.0),
    pumpParasticsFullLoad: 3.607,
    antiFreezeFlow: 12.0,
    HTFmass: 1_796_359.0,
    collector: LS3,
    EdgeFac: [0.0,0.0])
  
  static let st = Storage.Parameter(
    name: "2-Tank Molten Salt",
    chargeTo: 1,
    dischargeToTurbine: 0.01, dischargeToHeater: 0.01,
    TturbIterate: -99.99,
    heatStoredrel: 0,
    tempExCst: [293, 0, 0 , 0],
    tempExC0to1: [7,0, 0, 0],
    tempInCst: [293, 0, 0, 0],
    tempInC0to1: [],
    heatlossCst: [],
    heatlossC0to1: [],
    pumpEfficiency: 0.82,
    pressureLoss: 776000,
    massFlow: 50,
    startTemperature: (cold: 288, hot: 288),
    startLoad: (cold: 1, hot: 0),
    strategy: .demand, PrefChargeto: 0.83,
    startexcep: 4, endexcep: 8,
    HTF: .solarSalt, FCstopD: 20, FCstopM: 6,
    FCstartD: 18, FCstartM: 9, FP: -1, FC: 0,
    heatdiff: 0.25, dSRise: 1, MinDis: 0,
    fixedLoadDischarge: 0,
    heatTracingTime: [1,1], heatTracingPower: [1,1],
    DischrgParFac: 1, definedBy: .cap,
    deltaTemperature: (300,400),
    designTemperature: (300,400),
    heatLoss: (1,1), FCstartD2: 1,
    FCstartM2: 0, FCstopD2: 0, FCstopM2: 0,
    heatExchangerEfficiency: 0,
    heatExchangerCapacity: 0,
    heatExchangerMinCapacity: 0,
    HXresMin: false, DesAuxIN: 0, DesAuxEX: 1,
    heatProductionLoad: 0,
    heatProductionLoadWinter: 0,
    heatProductionLoadSummer: 0,
    dischrgWinter: 0, dischrgSummer: 0,
    badDNIwinter: 0, badDNIsummer: 0)
 
  static let LS3 = Collector.Parameter(
    name: "LS-3+ SKAL-ET", absorber: .rio,
    aperture: 5.73, lengthSCA: 142.8,
    areaSCAnet: 817.5, extensionHCE: 0,
    avgFocus: 2.12, rabsOut: 0.035,
    rabsInner: 0.033, rglas: 0.0625,
    glassEmission: 0.0, opticalEfficiency: 0.78,
    emissionHCE: [ -0.0619, 0.0003],
    shadingHCE: [0.954, 0.953, 0.93, 0.925],
    IAMfac: [1, 0, -0.0817, 0.1689, -0.2639],
    IntradiationLosses: false)
  
  static let hr = Heater.Parameter(
    name: "",
    efficiency: 0,
    antiFreezeTemperature: 0,
    nomTemperatureOut: 0,
    maxMassFlow: 0,
    minLoad: 0,
    nominalElectricalParasitics: 0,
    electricalParasitics: [0,0],
    onlyWithSolarField: false)
  
  static let tb = SteamTurbine.Parameter(
    name: "",
    power: PowerRange(range: 63.4375...285.8908),
    efficiencyNominal: 0.4101728,
    efficiencyBoiler: 0.4101728,
    efficiencySCC: 0.4101728,
    efficiency: [0.374256, 2.135076, -2.54458, 1.035248, 0],
    efficiencyTemperature: [
      0.99976, -0.00011537, 0.000035579, -0.0000016357, 0],
    startUpTime: 40, startUpEnergy: 250, PminT: [1,0,0,0,0],
    PminLim: 25, hotStartUpTime: 120,
    efficiencyWetBulb: [0, 0, 0, 0, 0, 0],
    WetBulbTstep: 0, efficiencytempIn_A: 0.2383,
    efficiencytempIn_B:  0.2404, efficiencytempIn_cf: 0)
  
  static let pb = PowerBlock.Parameter(
    name: "", fixelectricalParasitics: 0.3218,
    nominalElectricalParasitics: 0.5378732,
    fixElectricalParasitics0: 0.2497,
    startUpelectricalParasitics: 0.4945,
    nominalElectricalParasiticsACC: 0.5378732,
    electricalParasiticsShared: [0.2137136, 0.2137136],
    electricalParasiticsStep: [0, 0],
    electricalParasitics: [0.360782, 0.639218 ,0],
    electricalParasiticsACC: [1,0,0,0,0],
    electricalParasiticsACCTamb: [1,0,0,0,0])
  
  static let bo = Boiler.Parameter(
    name: "",
    nominalTemperatureOut: 1,
    minLoad: 0,
    nominalElectricalParasitics: 1,
    start: .init(hours: .init(cold: 0, warm: 0),
                 energy: .init(cold: 0, warm: 0)),
    electricalParasitics: .init(values: 0),
    efficiency: .init(values: 0))
  
  static let whr = WasteHeatRecovery.Parameter(
    name: "",
    operation: .integrated,
    efficiencyNominal: 1,
    efficiencyPure: 1,
    ratioHTF: 1,
    efficiencySolar: [32, 35, 38, 41, 44],
    efficiencyGasTurbine: [47, 50, 53, 56, 59])
}
