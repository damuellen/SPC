//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Config

extension Storage {
  public enum Definition: String, Encodable {
    case hours = "hrs", cap, ton
  }

  public enum TypeDir: String {
    case indirect, direct
  }
  
  public struct Parameter: ComponentParameter {
    let name: String
    let chargeTo, dischargeToTurbine, dischargeToHeater,
      stepSizeIteration, heatStoredrel: Double
    var temperatureDischarge, temperatureDischarge2: Polynomial
    var temperatureCharge, temperatureCharge2: Polynomial
    var heatlossCst, heatlossC0to1: Polynomial
    var pumpEfficiency, pressureLoss: Double
    var massFlow: MassFlow
    let startTemperature: (cold: Temperature, hot: Temperature) // TurbTL(0) TurbTL(1)
    let startLoad: (cold: Double, hot: Double) // TurbTL(2) TurbTL(3)

    public enum Strategy: String {
      case always, demand, shifter

      init?(string: String) {
        let string = string.trimmingCharacters(in: .whitespaces).lowercased()
        self.init(rawValue: string)
      }
    }

    var type: TypeDir = .indirect
    let strategy: Strategy
    let PrefChargeto: Double
    let startexcep, endexcep: Int
    let HTF: StorageMedium
    
    let FP, FC, heatdiff, dSRise: Double
    
    let minDischargeLoad, fixedDischargeLoad: Ratio
    
    let heatTracingTime, heatTracingPower: [Double]
    let DischrgParFac: Double
    
    var isVariable = true
    var heatExchangerRestrictedMin = false
    var auxConsumptionCurve = false
    var heatExchangerRestrictedMax = false

    var definedBy: Definition = .hours

  /*  let deltaTemperature: (design: Temperature,
    charging: Temperature, discharging: Temperature)*/
    let designTemperature: (cold: Temperature, hot: Temperature)
    
    let heatLoss: (hot: Double, cold: Double)
    
    let startFossilCharging, stopFossilCharging: (day: Int, month: Int)
    let startFossilCharging2, stopFossilCharging2: (day: Int, month: Int)
    
    let heatExchangerEfficiency: Double
    let heatExchangerCapacity: Double // (oil to salt) in MWt
    let heatExchangerMinCapacity: Double // HX minimum capacity in %
    
    // select if auxiliary consumption is to be calculated as quadratic polynom
    let DesAuxIN: Double // nominal auxiliary electrical consumption
    let DesAuxEX: Double // c0 coeff. for aux. consumption
    // AuxCons1     : Double       //Dummy
    // AuxCons2     : Double       //Dummy

    // variables added to calculate TES aux. consumption :

    var heatProductionLoad: Double // added for shifter
    let heatProductionLoadWinter: Ratio // added for shifter
    let heatProductionLoadSummer: Ratio // added for shifter
    let dischrgWinter: Int
    let dischrgSummer: Int
    let badDNIwinter: Double
    let badDNIsummer: Double
  }
}

extension Storage.Parameter: CustomStringConvertible {
  public var description: String {
    "Description:" >< name
    + "Capacity of Thermal Energy Storage [h]:\n" // Design.layout.storage)"
    + "Storage Availability [%]:"
    >< "\(Availability.current.values.storage.percentage)"
    + "Design Temperature of Cold Storage Tank [°C]:"
    >< "\(designTemperature.cold))"
    + "Design Temperature of Hot Storage Tank [°C]:"
    >< "\(designTemperature.hot)"
    + "DeltaT in Heat Exchanger during discharging [°C]:"
    >< "\(temperatureDischarge2[0])"
    + "DeltaT in Heat Exchanger during charging [°C]:"
    >< "\(temperatureCharge2[0])"
    + "Heat Loss of Cold Storage Tank [kW]:"
    >< String(format: "%G", heatlossC0to1[0])
    + "Heat Loss of Hot Storage Tank [kW]:"
    >< String(format: "%G", heatlossC0to1[1])
    + "Heat Exchanger Efficiency [%]:"
    >< "\(heatExchangerEfficiency * 100)"
    + "Temperature of Cold Tank at Program Start [°]:"
    >< "\(startTemperature.cold)"
    + "Temperature of Hot Tank at Program Start [°]:"
    >< "\(startTemperature.hot)"
    + "Load of Cold Tank at Program Start [%]:"
    >< "\(startLoad.cold * 100)"
    + "Load of Hot Tank at Program Start [%]:"
    >< "\(startLoad.hot * 100)"
    + "Charging of Storage during Night by HTF-heater (0=YES; -1=NO): \(FC)\n"
    + "Stop charging strategy at day:" >< "\(stopFossilCharging.day)"
    + "Stop charging strategy at month:" >< "\(stopFossilCharging.month)"
    + "Start charging strategy at day:" >< "\(startFossilCharging.day)"
    + "Start charging strategy at month:" >< "\(startFossilCharging.month)"
    + "Charge Storage up to relative Load before Start-up of Turbine:"
    >< "\(PrefChargeto)"
    + "Definition of Summer from Month:" >< "\(startexcep)"
    + "                       to Month:" >< "\(endexcep)"
    + "DNI for Bad Days Winter [kWh/m2]:" >< "\(badDNIwinter)"
    + "DNI for Bad Days Summer [kWh/m2]:" >< "\(badDNIsummer)"
    + "Massflow to POB during Charge in Bad Days Winter [%]:"
    >< "\(heatProductionLoadWinter.percentage )"
    + "Massflow to POB during Charge in Bad Days Summer [%]:"
    >< "\(heatProductionLoadSummer.percentage)"
    + "Time to begin TES Discharge in Winter [hr]:" >< "\(dischrgWinter)"
    + "Time to begin TES Discharge in Summer [hr]:" >< "\(dischrgSummer)"
  }
}

extension Storage.Parameter: TextConfigInitializable {
  public init(file: TextConfigFile) throws {
    typealias T = Temperature
    let line: (Int) throws -> Double = { try file.parseDouble(line: $0) }
    let line2: (Int) throws -> Int = { try file.parseInteger(line: $0) }
    name = file.name
    chargeTo = try line(10)
    dischargeToTurbine = try line(13)
    dischargeToHeater = try line(16)
    stepSizeIteration = try line(19)
    heatStoredrel = try line(22)
    temperatureDischarge = try [line(47), line(50), line(53), line(56)]
    temperatureDischarge2 = try [line(62), line(65), line(68), line(71)]
    temperatureCharge = try [line(81), line(84), line(87), line(90)]
    temperatureCharge2 = try [line(96), line(99), line(102), line(105)]
    heatlossCst = try [line(115), line(118), line(121), line(124)]
    heatlossC0to1 = try [line(130), line(133), line(136), line(139)]
    pumpEfficiency = try line(146) / 100
    pressureLoss = try line(149)
    massFlow = try .init(line(152))
    startTemperature = try (T(line(162)), T(line(165)))
    startLoad = try (line(168), line(171))
  //  HX = try line(172) //bool

    file.values[172]
    strategy = .demand//try line(173) 
    PrefChargeto = try line(174)
    startexcep = try line2(175)
    endexcep = try line2(176)
    HTF = .solarSalt //try line(177)
    FP = try line(178)
    FC = try line(179)
    stopFossilCharging = try (line2(180), line2(181))
    startFossilCharging = try (line2(182), line2(183))
    heatExchangerRestrictedMax = try line2(186) == 1 ? true:false
    heatExchangerCapacity = try line(189)
  //  Qfldif = try line(192)
    isVariable = try line2(194) == 1 ? true:false
    dSRise = try line(196)
    minDischargeLoad = try Ratio(line(198))
    fixedDischargeLoad = try Ratio(line(200))
    heatTracingTime = try [line(202), line(205), line(208)]
    heatTracingPower = try [line(203), line(206), line(209)]
 //   HTb_time = try line(205)
 //   HTb_pow = try line(206)
 //   HTc_time = try line(208)
 //   HTc_pow = try line(209)
   // TempHeatTracing = try line(211)
  //  HTc_Temp = try line(_)
  //  HTe_pow = try line(_ )
    heatExchangerRestrictedMin = try line2(217) == 1 ? true:false
    heatExchangerMinCapacity = try line(218)
    DischrgParFac = try line(220)
    stopFossilCharging2 = try (line2(222), line2(223))
    startFossilCharging2 = try (line2(224),line2(225))
    auxConsumptionCurve = try line2(227) == 1 ? true:false
    DesAuxIN = try line(228)
    DesAuxEX = try line(229)
    heatProductionLoadWinter = try Ratio(line(233))
    heatProductionLoadSummer = try Ratio(line(234))
    dischrgWinter = try line2(235)
    dischrgSummer = try line2(236)
    badDNIwinter = try line(238)
    badDNIsummer = try line(239)
    type = .indirect // try line(241)
    designTemperature = (T(290), T(390))
    heatdiff = 0
    heatLoss = (0,0)
    heatExchangerEfficiency = 0
    heatProductionLoad = 0
  }  
}
