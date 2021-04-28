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
import PhysicalQuantities

extension Storage {
  public enum Definition: String, Codable {
    case hours = "hrs", cap, ton
  }

  public enum TypeDir: String, Codable {
    case indirect, direct
  }
  
  public struct Parameter {
    let name: String
    let chargeTo, dischargeToTurbine, dischargeToHeater: Ratio
    let stepSizeIteration, heatStoredrel: Double
    var temperatureDischarge, temperatureDischarge2: Polynomial
    var temperatureCharge, temperatureCharge2: Polynomial
    var heatlossCst, heatlossC0to1: Polynomial
    var pumpEfficiency, pressureLoss: Double
    var massFlowShare: Ratio

    let startTemperature: (cold: Temperature, hot: Temperature) // TurbTL(0) TurbTL(1)
    let startLoad: (cold: Double, hot: Double) // TurbTL(2) TurbTL(3)

    public enum Strategy: String, Codable {
      case always, demand, shifter

      init?(string: String) {
        let string = string.trimmingCharacters(in: .whitespaces).lowercased()
        self.init(rawValue: string)
      }
    }

    var type: TypeDir = .indirect
    let strategy: Strategy
    let prefChargeToTurbine: Double
    let exception: ClosedRange<Int>
    let HTF: StorageMedium
    
    let FP, FC, heatdiff, dSRise: Double
    
    let minDischargeLoad, fixedDischargeLoad: Ratio
    
    let heatTracingTime, heatTracingPower: [Double]
    let dischargeParasitcsFactor: Double
    
    var isVariable = true
    var heatExchangerRestrictedMin = false
    var auxConsumptionCurve = false
    var heatExchangerRestrictedMax = false

    var definedBy: Definition = .hours

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
    /// Massflow to POB during Charge in Bad Days Winter 
    let heatProductionLoadWinter: Ratio // added for shifter
    /// Massflow to POB during Charge in Bad Days Summer 
    let heatProductionLoadSummer: Ratio // added for shifter
    let dischargeWinter: Int
    let dischargeSummer: Int
    /// DNI for Bad Days Winter
    let badDNIwinter: Double
    /// DNI for Bad Days Summer
    let badDNIsummer: Double
  }
}

extension Storage.Parameter: CustomStringConvertible {
  public var description: String {
    "Description:" * (name + " " + type.rawValue)
    + "Charge Storage up to Load:" * chargeTo.description
    + "Discharge Storage directly to Turbine down to Load:" * dischargeToTurbine.description
    + "Discharge Storage indirectly to Heater down to Load:" * dischargeToHeater.description
    + "Discharge Storage, if (Qsolarfield - Qdemand) <" * "\(heatdiff * 100) % of Qdemand" 
    + "Stepwidth of Qdemand to iterate Tmin for Turbine:" * stepSizeIteration.description
    + "Relative Filling of Storage at Program Start (only for Thermocline):" * heatStoredrel.description
    + "Outlet Temperature of storage during discharging (hot end)\n"
    + "for Load = 0; T = c0+c1*T+c2*T^2+c3*T^3:\n\(temperatureDischarge)"
    + "Outlet Temperature (for Thermocline) or deltaT (for 2-Tank) of storage\n"
    + "during discharging (hot end) for Load > 0; T = c0+c1*T+c2*T^2+c3*T^3:\n\(temperatureDischarge2)"
    + "Outlet Temperature of storage during charging (cold end)\nfor Load = 0; T = c0+c1*T+c2*T^2+c3*T^3:"
    + "\n\(temperatureCharge)"
    + "Outlet Temperature (for Thermocline) or deltaT (for 2-Tank) of storage\n"
    + "during charging (cold end) for Load > 0; T = c0+c1*T+c2*T^2+c3*T^3:\n\(temperatureCharge2)"
    + "Capacity of Thermal Energy Storage [h]:\n" // Design.layout.storage)"
    + "Storage Availability [%]:"
    * Availability.current.values.storage.percentage.description
    + "Design Temperature of Cold Storage Tank [°C]:"
    * String(format: "%.1f", designTemperature.cold.celsius)
    + "Design Temperature of Hot Storage Tank [°C]:"
    * String(format: "%.1f", designTemperature.hot.celsius)
    + "DeltaT in Heat Exchanger during discharging [°C]:"
    * temperatureDischarge2[0].description
    + "DeltaT in Heat Exchanger during charging [°C]:"
    * temperatureCharge2[0].description
    + "Heat Loss of Cold Storage Tank [kW]:"
    * String(format: "%G", heatlossC0to1[0])
    + "Heat Loss of Hot Storage Tank [kW]:"
    * String(format: "%G", heatlossC0to1[1])
    + "Heat Exchanger Efficiency [%]:" * "\(heatExchangerEfficiency * 100)"
    + "Pump Efficiency [%]:" * "\(pumpEfficiency * 100)"
    + "Pressure Loss at Design Point [Pa]:" * String(format: "%G", pressureLoss)
    + "Mass Flow to Power Block at design point;\n"
    + "Fraction of Total Solar Field Mass Flow [%]:"
    * String(format: "%G", massFlowShare.percentage)
    + "Temperature of Cold Tank at Program Start [°]:"
    * startTemperature.cold.celsius.description
    + "Temperature of Hot Tank at Program Start [°]:"
    * startTemperature.hot.celsius.description
    + "Load of Cold Tank at Program Start [%]:"
    * (startLoad.cold * 100).description
    + "Load of Hot Tank at Program Start [%]:"
    * (startLoad.hot * 100).description
    + "Charging of Storage during Night by HTF-heater (0=YES; -1=NO): \(FC)\n"
    + "Stop charging strategy at day:" * stopFossilCharging.day.description
    + "Stop charging strategy at month:" * stopFossilCharging.month.description
    + "Start charging strategy at day:" * startFossilCharging.day.description
    + "Start charging strategy at month:" * startFossilCharging.month.description
    + "Charge Storage up to relative Load before Start-up of Turbine:"
    * prefChargeToTurbine.description
    + "Definition of Summer from Month:" * exception.lowerBound.description
    + "                       to Month:" * exception.upperBound.description
    + "DNI for Bad Days Winter [kWh/m2]:" * badDNIwinter.description
    + "DNI for Bad Days Summer [kWh/m2]:" * badDNIsummer.description
    + "Massflow to POB during Charge in Bad Days Winter [%]:"
    * heatProductionLoadWinter.percentage.description
    + "Massflow to POB during Charge in Bad Days Summer [%]:"
    * heatProductionLoadSummer.percentage.description
    + "Time to begin TES Discharge in Winter [hr]:" * dischargeWinter.description
    + "Time to begin TES Discharge in Summer [hr]:" * dischargeSummer.description
  }
}

extension Storage.Parameter: TextConfigInitializable {
  public init(file: TextConfigFile) throws {
    typealias T = Temperature
    let ln: (Int) throws -> Double = { try file.double(line: $0) }
    let l2: (Int) throws -> Int = { try file.integer(line: $0) }
    name = file.name
    chargeTo = try Ratio(ln(10))
    dischargeToTurbine = try Ratio(ln(13))
    dischargeToHeater = try Ratio(ln(16))
    stepSizeIteration = try ln(19)
    heatStoredrel = try ln(22)
    temperatureDischarge = try [ln(47), ln(50), ln(53), ln(56)]
    temperatureDischarge2 = try [ln(62), ln(65), ln(68), ln(71)]
    temperatureCharge = try [ln(81), ln(84), ln(87), ln(90)]
    temperatureCharge2 = try [ln(96), ln(99), ln(102), ln(105)]
    heatlossCst = try [ln(115), ln(118), ln(121), ln(124)]
    heatlossC0to1 = try [ln(130), ln(133), ln(136), ln(139)]
    pumpEfficiency = try ln(146) / 100
    pressureLoss = try ln(149)
    massFlowShare = try .init(ln(152) / 100) 
    startTemperature = try (T(celsius: ln(162)), T(celsius:ln(165)))
    startLoad = try (ln(168), ln(171))
  //  HX = try ln(172) //bool

    //file.values[172]
    strategy = .demand//try ln(173) 
    prefChargeToTurbine = try ln(174)
    exception = try l2(175)...l2(176)
    HTF = .solarSalt //try ln(177)
    FP = try ln(178)
    FC = try ln(179)
    stopFossilCharging = try (l2(180), l2(181))
    startFossilCharging = try (l2(182), l2(183))
    heatExchangerRestrictedMax = try l2(186) == 1 ? true:false
    heatExchangerCapacity = try ln(189)
  //  Qfldif = try ln(192)
    isVariable = try l2(194) == 1 ? true:false
    dSRise = try ln(196)
    minDischargeLoad = try Ratio(ln(198))
    fixedDischargeLoad = try Ratio(ln(200))
    heatTracingTime = try [ln(202), ln(205), ln(208)]
    heatTracingPower = try [ln(203), ln(206), ln(209)]
 //   HTb_time = try ln(205)
 //   HTb_pow = try ln(206)
 //   HTc_time = try ln(208)
 //   HTc_pow = try ln(209)
   // TempHeatTracing = try ln(211)
  //  HTc_Temp = try ln(_)
  //  HTe_pow = try ln(_ )
    heatExchangerRestrictedMin = try l2(217) == 1 ? true:false
    heatExchangerMinCapacity = try ln(218)
    dischargeParasitcsFactor = try ln(220)
    stopFossilCharging2 = try (l2(222), l2(223))
    startFossilCharging2 = try (l2(224),l2(225))
    auxConsumptionCurve = try l2(227) == 1 ? true:false
    DesAuxIN = try ln(228)
    DesAuxEX = try ln(229)
    heatProductionLoadWinter = try Ratio(ln(233))
    heatProductionLoadSummer = try Ratio(ln(234))
    dischargeWinter = try l2(235)
    dischargeSummer = try l2(236)
    badDNIwinter = try ln(238)
    badDNIsummer = try ln(239)
    type = .indirect // try ln(241)
    designTemperature = try (T(celsius: ln(118)), T(celsius: ln(121)))
    heatdiff = 0.25
    heatLoss = (0,0)
    heatExchangerEfficiency = 1
    heatProductionLoad = 0
  }  
}

extension Storage.Parameter: Codable {

  public init(from decoder: Decoder) throws {
    fatalError()
  }

  public func encode(to encoder: Encoder) throws {
   fatalError()
  }
}
