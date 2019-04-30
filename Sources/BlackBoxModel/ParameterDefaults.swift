//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

public enum ParameterDefaults {

  static let hx = HeatExchanger.Parameter(
    name: "",
    efficiency: 0.9,
    sccEff: 0.99,
    temperature: HeatExchanger.Parameter.Temperatures(
      htf: (inlet: (max: 393, min: 296), outlet: (max: 296, min: 0)),
      h2o: (inlet: (max: 0, min: 263), outlet: (max: 300, min: 300))
    ),
    scc: HeatExchanger.Parameter.Temperatures(
      htf: (inlet: (max: 390, min: 260), outlet: (max: 292, min: 198)),
      h2o: (inlet: (max: 374, min: 255), outlet: (max: 234, min: 128))
    ),
    sccHTFmassFlow: 1000.0,
    sccHTFheat: 70,
    ToutMassFlow: nil,
    ToutTin: nil,
    ToutTinMassFlow: nil,
    useAndsolFunction: false,
    Tout_f_Mfl: false,
    Tout_f_Tin: false,
    Tout_exp_Tin_Mfl: false
  )

  static let gt = GasTurbine.Parameter(
    name: "",
    powerGross: 1.1,
    efficiencyISO: 1,
    loadMin: 1,
    altitude: 1,
    efficiencyFromLoad: [41, 44, 47, 50, 53],
    loadMaxFromTemperature: [60, 63, 66, 69, 72],
    parasiticsFromLoad: [79, 82, 85, 88, 91],
    designTemperature: 200
  )

  static let sf = SolarField.Parameter(
    imbalanceDesign: [1.0, 1.0, 1.0],
    imbalanceMin: [1.0, 1.025, 1.0],
    windCoefficients: [0],
    useReferenceAmbientTemperature: false,
    referenceAmbientTemperature: 0.0,
    heatlosses: [0.0],
    designTemperature: (inlet: 293.0, outlet: 393.0),
    maxWind: Float(25.5),
    numberOfSCAsInRow: 2,
    rowDistance: 18.0,
    distanceSCA: 1.5,
    pipeHeatLosses: 13.0,
    azimut: 0.0,
    elevation: 0.0,
    antiFreezeParastics: 0.5,
    pumpParastics: [0.15, -0.293, 1.257],
    massFlow: (1800.0, 5.0),
    pumpParasticsFullLoad: 3.607,
    antiFreezeFlow: 50.0,
    HTFmass: 396_359.0,
    HTF: HTF,
    collector: LS3,
    edgeFactor: []
  )

  static let HTF = HeatTransferFluid(
    name: "Therminol",
    freezeTemperature: 12,
    heatCapacity: [1.4856, 0.0028],
    dens: [1074.964, -0.6740513, -0.000650017],
    visco: [-0.000201537, 0.1273247, -0.7167957],
    thermCon: [0.1378081, -8.41485e-05, -1.788e-07],
    maxTemperature: 393.0,
    h_T: [-0.62677, 1.51129, 0.0012941, 1.23697e-07, 0],
    T_h: [0.58315, 0.65556, -0.00032293, 1.9425e-07, -6.1133e-11],
    useEnthalpy: false
  )
  
  static let st = Storage.Parameter(
    name: "2-Tank Molten Salt",
    chargeTo: 1,
    dischargeToTurbine: 0.199278169307103,
    dischargeToHeater: 0.199278169307103 ,
    stepSizeIteration: -99.99,
    heatStoredrel: 0,
    temperatureDischarge: [7, 0, 0, 0],
    temperatureDischarge2: [7, 0, 0, 0],
    temperatureCharge: [307, 0, 0, 0],
    temperatureCharge2: [-1, 0, 0, 0],
    heatlossCst: [1.953704, 301.1, 546.6, 2630000],
    heatlossC0to1: [21700148, 362.77, 0, 0],
    pumpEfficiency: 0.73,
    pressureLoss: 776000,
    massFlow: 50.0,
    startTemperature: (.init(celsius: 288.0), .init(celsius: 288.0)),
    startLoad: (cold: 1, hot: 0),
    strategy: .demand, PrefChargeto: 0.83,
    startexcep: 4, endexcep: 8,
    HTF: .solarSalt,  FP: -1, FC: 0, heatdiff: 0.25, dSRise: 1,
    minDischargeLoad: Ratio(0), fixedDischargeLoad: Ratio(0.97),
    heatTracingTime: [1, 1], heatTracingPower: [1, 1],
    DischrgParFac: 1, definedBy: .ton,
  //  resultingTemperature: (.init(celsius: 293.0), .init(celsius: 390.0)),
    designTemperature: (.init(celsius: 293.0), .init(celsius: 390.0)),
    heatLoss: (1, 1),
    startFossilCharging: (1, 1), stopFossilCharging: (0, 1),
    startFossilCharging2: (1, 1), stopFossilCharging2: (0, 1),
    heatExchangerEfficiency: 1,
    heatExchangerCapacity: 70,
    heatExchangerMinCapacity: 10,
    HXresMin: false, DesAuxIN: 0, DesAuxEX: 1,
    heatProductionLoad: 0.0,
    heatProductionLoadWinter: 0.0,
    heatProductionLoadSummer: 0.0,
    dischrgWinter: 0, dischrgSummer: 0,
    badDNIwinter: 0, badDNIsummer: 0
  )

  static let LS3 = Collector.Parameter(
    name: "SKAL-ET", absorber: .rio,
    aperture: 5.73, lengthSCA: 142.8,
    areaSCAnet: 817.5, extensionHCE: 0,
    avgFocus: 2.12, rabsOut: 0.035,
    rabsInner: 0.033, rglas: 0.0625,
    glassEmission: 0.0, opticalEfficiency: 0.7933452,
    emissionHCE: [0.033, 0.0001],
    shadingHCE: [0.962, 0.961, 0.938, 0.933],
    IAMfac: [1, 0, -0.0817, 0.1689, -0.2639],
    useIntegralRadialoss: true
  )

  static let hr = Heater.Parameter(
    name: "",
    efficiency: 1,
    maximumMassFlow: 10,
    minLoad: 0, nominalElectricalParasitics: 1,
    antiFreezeTemperature: .init(celsius: 100.0),
    nominalTemperatureOut: .init(celsius: 200.0),
    electricalParasitics: [10, 0],
    onlyWithSolarField: false
  )

  static let tb = SteamTurbine.Parameter(
    name: "",
    power: PowerRange(range: 33 ... 102, nom: 100),
    efficiencyNominal: 0.4101728,
    efficiencyBoiler: 0.4101728,
    efficiencySCC: 0.4101728,
    efficiency: [0.6526, 1.1839, -1.8611, 1.5008, -0.4761],
    efficiencyTemperature: [0.99976, -0.00011537, 3.5579e-05, -1.6357e-06, 0],
    startUpTime: 40, startUpEnergy: 250,
    minPowerFromTemp: [1],
    hotStartUpTime: 120,
    efficiencyWetBulb: [0, 0, 0, 0, 0, 0],
    WetBulbTstep: 0, efficiencyTempIn_A: 0.2383,
    efficiencyTempIn_B: 0.2404, efficiencyTempIn_cf: 0
  )

  static let pb = PowerBlock.Parameter(
    name: "",
    fixElectricalParasitics: 0.3218,
    nominalElectricalParasitics: 0.5378732,
    fixElectricalParasitics0: 0.2497,
    startUpElectricalParasitics: 0.4945,
    nominalElectricalParasiticsACC: 0.5378732,
    electricalParasiticsShared: [0.2137136, 0.2137136],
    electricalParasiticsStep: [0, 0],
    electricalParasitics: [0.360782, 0.639218, 0],
    electricalParasiticsACC: [1, 0, 0, 0, 0],
    electricalParasiticsACCTamb: [1, 0, 0, 0, 0]
  )

  static let bo = Boiler.Parameter(
    name: "",
    nominalTemperatureOut: 1,
    minLoad: 0,
    nominalElectricalParasitics: 1,
    start: .init(hours: .init(cold: 0, warm: 0),
                 energy: .init(cold: 0, warm: 0)),
    electricalParasitics: .init(values: 0),
    efficiency: .init(values: 0)
  )

  static let whr = WasteHeatRecovery.Parameter(
    name: "",
    operation: .integrated,
    efficiencyNominal: 1,
    efficiencyPure: 1,
    ratioHTF: 1,
    efficiencySolar: [32, 35, 38, 41, 44],
    efficiencyGasTurbine: [47, 50, 53, 56, 59]
  )
}
