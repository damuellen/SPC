// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import Units
import Utilities

/// An extension providing default parameter values for different components of a solar power plant.
extension Parameters {

  static let hx = HeatExchanger.Parameter(
    name: "",
    efficiency: 1,
    sccEfficiency: 0.99,
    temperature: HeatExchanger.Parameter.Temperatures(
      htf: (inlet: (max: 393, min: 296), outlet: (max: 296, min: 245)),
      h2o: (inlet: (max: 0, min: 263), outlet: (max: 300, min: 300))
    ),
    scc: HeatExchanger.Parameter.Temperatures(
      htf: (inlet: (max: 390, min: 260), outlet: (max: 292, min: 198)),
      h2o: (inlet: (max: 374, min: 255), outlet: (max: 234, min: 128))
    ),
    massFlowHTF: 1500.0,
    heatFlowHTF: 250,
    ToutMassFlow: nil,
    ToutTin: nil,
    ToutTinMassFlow: nil,
    useAndsolFunction: true,
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
    heatLossHotHeader: [0, 0.475, 0.0014],
    imbalanceDesign: [1.0, 1.0, 1.0],
    imbalanceMin: [1.03, 1.0, 0.97],
    windCoefficients: [1.005474, -2.181319e-03, -6.416373e-05, 0, 0, 0],
    useReferenceAmbientTemperature: false,
    referenceAmbientTemperature: 0.0,    
    designTemperatureInlet: 293.0,
    designTemperatureOutlet: 393.0,
    maxWind: Float(14.5),
    numberOfSCAsInRow: 2,
    rowDistance: 18.0,
    distanceSCA: 1.5,
    pipeHeatLosses: 13.0,
    azimut: 0.0,
    elevation: 0.0,
    antiFreezeParastics: 0.5,
    pumpParastics: [0.15, -0.293, 1.257],
    maxMassFlow: 1800.0,
    minFlow: 0.3,
    pumpParasticsFullLoad: 3.607,
    antiFreezeFlow: 0.12,
    HTFmass: 396_359.0,
    HTF: HeatTransferFluid.VP1,
    edgeFactor: []
  )

  static let st = Storage.Parameter(
    name: "2-Tank Molten Salt",
    chargeTo: 1.0,
    dischargeToTurbine: 0.199278169307103,
    dischargeToHeater: 0.199278169307103,
    stepSizeIteration: -99.99,
    heatStoredrel: 0,
    temperatureDischarge: [7, 0, 0, 0],
    temperatureDischarge2: [7, 0, 0, 0],
    temperatureCharge: [307, 0, 0, 0],
    temperatureCharge2: [-1, 0, 0, 0],
    heatlossCst: [1.953704, 301.1, 546.6, 2_630_000],
    heatlossC0to1: [21_700_148, 362.77, 0, 0],
    pumpEfficiency: 0.73,
    pressureLoss: 776000,
    massFlowShare: 0.7,
    startTemperature: .init(.init(celsius:288.0), .init(celsius:288.0)),
    startLoad: .init(1, 0),
    strategy: .demand, prefChargeToTurbine: 0.83,
    exception: 4...8,
    HTF: .solarSalt, freezeProtection: true, fossilCharging: false, 
    heatdiff: 0.25, dSRise: 1,
    minDischargeLoad: Ratio(0), fixedDischargeLoad: Ratio(0.97),
    heatTracingTime: [1, 1], heatTracingPower: [1, 1],
    dischargeParasitcsFactor: 1, definedBy: .hours,
    designTemperature: .init(566.15, 663.15),
    heatLoss: .init(79.967, 98.98),
    fossilChargingTime: [1,2,1,1,1,2,1,1],
    heatExchangerEfficiency: 1,
    heatExchangerCapacity: 70,
    heatExchangerMinCapacity: 10,
    DesAuxIN: 0, DesAuxEX: 1,
    heatProductionLoad: 0.0,
    heatProductionLoadWinter: 0.0,
    heatProductionLoadSummer: 0.0,
    dischargeWinter: 0, dischargeSummer: 0,
    badDNIwinter: 0, badDNIsummer: 0
  )

  static let LS3 = Collector.Parameter(
    name: "SKAL-ET", absorber: .rio,
    aperture: 5.73, lengthSCA: 142.8,
    areaSCAnet: 817.5, extensionHCE: 0,
    avgFocus: 2.12, rabsOut: 0.035,
    rabsInner: 0.033, rglas: 0.0625,
    glassEmission: 0.0, opticalEfficiency: 0.7933452,
    emissionHCE: [0.033, 0.0001, 0],
    shadingHCE: [0.962, 0.961, 0.938, 0.933],
    factorIAM: [0.996, 0.1556, -0.4821, 0.4028, -0.3085],
    useIntegralRadialoss: true
  )

   static let NT_PRO = Collector.Parameter(
    name: "NTPro_THVP1", absorber: .rio,
    aperture: 6.707, lengthSCA: 192.984,
    areaSCAnet: 1282.988103, extensionHCE: 0,
    avgFocus: 2.169, rabsOut: 0.04445,
    rabsInner: 0.04195, rglas: 0.071,
    glassEmission: 0.86, opticalEfficiency: 0.790135815,
    emissionHCE: [0.0047, 0.000134, 0],
    shadingHCE: [1, 1, 1, 1],
    factorIAM: [0.9999789, 0.0967598, -0.3307049, 0, 0],
    useIntegralRadialoss: true
  )

  static let hr = Heater.Parameter(
    name: "",
    efficiency: 0.9, minLoad: 0.3,
    maximumMassFlow: 150,
    nominalElectricalParasitics: 1,
    antiFreezeTemperature: .init(celsius: 180.0),
    nominalTemperatureOut: .init(celsius: 393.0),
    electricalParasitics: [0.2589, 0.7411],
    onlyWithSolarField: false
  )

  static let tb = SteamTurbine.Parameter(
    name: "",
    power: PowerRange(range: 10...77, nom: 75),
    efficiencyNominal: 0.4101728,
    efficiencyBoiler: 0.4101728,
    efficiencySCC: 0.4101728,
    efficiency: [0.5665709, 1.38914, -1.595333, 0.6396214, 0],
    efficiencyTemperature: [1.017685, 1.237701e-04, 5.270807e-05, -4.486609e-06, 4.374404e-08],
    startUpTime: 30, startUpEnergy: 51,
    minPowerFromTemp: [1],
    hotStartUpTime: 120,
    efficiencyWetBulb: [0, 0, 0, 0, 0, 0],
    WetBulbTstep: 0, efficiencyTempIn_A: 0.2383,
    efficiencyTempIn_B: 0.2404, efficiencyTempIn_cf: 1
  )

  static let pb = PowerBlock.Parameter(
    name: "powerblock",
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
    start: .init(
      hours: .init(cold: 0, warm: 0),
      energy: .init(cold: 0, warm: 0)),
    electricalParasitics: [0, 0],
    efficiency: [0]
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
