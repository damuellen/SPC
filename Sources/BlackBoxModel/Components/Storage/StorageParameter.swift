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
import Foundation

extension Storage {
  public enum Definition: String {
    case hours = "hrs", cap, ton
  }

  public struct Parameter: ComponentParameter {
    let name: String
    let chargeTo, dischargeToTurbine, dischargeToHeater,
      stepSizeIteration, heatStoredrel: Double
    var temperatureDischarge, temperatureDischarge2: Coefficients
    var temperatureCharge, temperatureCharge2: Coefficients
    var heatlossCst, heatlossC0to1: Coefficients
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

    let strategy: Strategy
    let PrefChargeto: Double
    let startexcep, endexcep: Int
    let HTF: StorageMedium

    let FCstopD, FCstopM, FCstartD, FCstartM: Int
    let FP, FC, heatdiff, dSRise, minDischargeLoad, fixedDischargeLoad: Double
    let heatTracingTime, heatTracingPower: [Double]
    let DischrgParFac: Double
    let isVariable = true
    let heatExchangerRestrictedMin = false
    let auxConsumptionCurve = false
    let heatExchangerRestrictedMax = false

    var definedBy: Definition = .hours

  /*  let deltaTemperature: (design: Temperature,
    charging: Temperature, discharging: Temperature)*/
    let designTemperature: (cold: Temperature, hot: Temperature)
    
    let heatLoss: (hot: Double, cold: Double)
    let FCstartD2: Int // Second Start fossil charging at Day
    let FCstartM2: Int // Second Start fossil charging at Month
    let FCstopD2: Int // second Stop fossil charing at Day
    let FCstopM2: Int // Second Stop fossil charing at Month
    
    let heatExchangerEfficiency: Double
    let heatExchangerCapacity: Double // (oil to salt) in MWt
    let heatExchangerMinCapacity: Double // HX minimum capacity in %
    let HXresMin: Bool // check box to restrict HX//s minimum load
    // select if auxiliary consumption is to be calculated as quadratic polynom
    let DesAuxIN: Double // nominal auxiliary electrical consumption
    let DesAuxEX: Double // c0 coeff. for aux. consumption
    // AuxCons1     : Double       //Dummy
    // AuxCons2     : Double       //Dummy

    // variables added to calculate TES aux. consumption :

    var heatProductionLoad: Double // added for shifter
    let heatProductionLoadWinter: Double // added for shifter
    let heatProductionLoadSummer: Double // added for shifter
    let dischrgWinter: Int
    let dischrgSummer: Int
    let badDNIwinter: Double
    let badDNIsummer: Double
  }
}

extension Storage.Parameter: CustomStringConvertible {
  public var description: String {
    var d: String = ""
    d += "Description:" + name
    d += "Capacity of Thermal Energy Storage [h]:" // Design.layout.storage)"
    d += "Storage Availability [%]:"
      >< "\(Availability.current.values.storage.percentage)"
    d += "Design Temperature of Cold Storage Tank [°C]:"
      >< "\(designTemperature.cold))"
    d += "Design Temperature of Hot Storage Tank [°C]:"
      >< "\(designTemperature.hot)"
    d += "DeltaT in Heat Exchanger during discharging [°C]:"
      >< "\(temperatureDischarge2[0])"
    d += "DeltaT in Heat Exchanger during charging [°C]:"
      >< "\(temperatureCharge2[0])"
    d += "Heat Loss of Cold Storage Tank [kW]:"
      >< "\(heatlossC0to1[0])"
    d += "Heat Loss of Hot Storage Tank [kW]:"
      >< "\(heatlossC0to1[1])"
    d += "Heat Exchanger Efficiency [%]:"
      >< "\(heatExchangerEfficiency * 100)"
    d += "Temperature of Cold Tank at Program Start [°]:"
      >< "\(startTemperature.cold)"
    d += "Temperature of Hot Tank at Program Start [°]:"
      >< "\(startTemperature.hot)"
    d += "Load of Cold Tank at Program Start [%]:"
      >< "\(startLoad.cold * 100)"
    d += "Load of Hot Tank at Program Start [%]:"
      >< "\(startLoad.hot * 100)"
    d += "Charging of Storage during Night by HTF-heater (0=YES; -1=NO): \(FC)"
    d += "Stop charging strategy at day:" >< "\(FCstopD)"
    d += "Stop charging strategy at month:" >< "\(FCstopM)"
    d += "Start charging strategy at day:" >< "\(FCstartD)"
    d += "Start charging strategy at month:" >< "\(FCstartM)"
    d += "Charge Storage up to relative Load before Start-up of Turbine:"
      >< "\(PrefChargeto)"
    d += "Definition of Summer from Month:" >< "\(startexcep)"
    d += "                       to Month:" >< "\(endexcep)"
    d += "DNI for Bad Days Winter [kWh/m2]:" >< "\(badDNIwinter)"
    d += "DNI for Bad Days Summer [kWh/m2]:" >< "\(badDNIsummer)"
    d += "Massflow to POB during Charge in Bad Days Winter [%]:"
      >< "\(heatProductionLoadWinter * 100)"
    d += "Massflow to POB during Charge in Bad Days Summer [%]:"
      >< "\(heatProductionLoadSummer * 100)"
    d += "Time to begin TES Discharge in Winter [hr]:" >< "\(dischrgWinter)"
    d += "Time to begin TES Discharge in Summer [hr]:" >< "\(dischrgSummer)"
    return d
  }
}

/*
 extension Storage.Parameter: TextConfigInitializable {
 public init(file: TextConfigFile)throws {
 let row: (Int)throws -> Double = { try file.double(row: $0) }
 let int: (Int)throws -> Int = { try file.integer(row: $0) }
 self.name = file.name
 self.chargeTo = try row(10)
 self.dischargeToTurbine = try row(13)
 self.dischargeToHeater = try row(16)
 self.TturbIterate = try row(19)
 self.heatStoredrel = try row(22)
 self.tempExCst = [try row(47), try row(50), try row(53), try row(56)]
 self.tempExC0to1 = [try row(62), try row(65), try row(68), try row(71)]
 self.tempInCst = [try row(81), try row(84), try row(87), try row(90)]
 self.tempInC0to1 = [try row(96), try row(99), try row(102), try row(105)]
 self.heatlossCst = [try row(115), try row(118), try row(121), try row(124)]
 self.heatlossC0to1 = [try row(130), try row(133), try row(136), try row(139)]
 self.pumpEfficiency = try row(146)
 self.pressureLoss = try row(149)
 self.massFlow = try row(152)
 self.startTemperature = (cold: try row(162), hot: try row(165))
 self.startLoad = (cold: try row(168), hot: try row(171))
 self.heatExchangerEfficiency = try row(172)
 if let value = file[row: 173], let strategy = Strategy(rawValue: value) {
 self.strategy = strategy
 } else {
 self.strategy = .demand
 }
 self.PrefChargeto = try row(174)
 self.startexcep = Int(file[row: 175] ?? "0") ?? 0
 self.endexcep = Int(file[row: 176] ?? "0") ?? 0
 if let value = file[row: 173], let htf = StorageFluid(rawValue: value) {
 self.HTF = htf
 } else {
 self.HTF = .solarSalt
 }
 self.FP = try row(178)
 self.FC = try row(179)
 self.FCstopD = try int(180)
 self.FCstopM = try int(181)
 self.FCstartD = try int(182)
 self.FCstartM = try int(183)
 }
 }

 Double       // stepwidth of Qdemand to iterate MinTurbTemp
 pumpEfficiency      : Double       // efficiency of pump
 pressureLoss  : Double       // pressure loss during discharge at design pnt
 massFlow        : Double  // massflow at DP design point

 heatLossConstants0(3) : Double       // heatLosses, cubic            smaller than 0
 heatLossC0to1(3): Double       // polynomfit       Estorel is greater than 0

 tempInCst0(3)   : Double       //outlet temperature of HTF    smaller than 0
 tempInC0to1(3)  : Double       // during charging  Estorel is greater than 0

 TexCst0(3)   : Double       // outlet temperature of HTF    smaller than 0
 TexC0to1(3)  : Double       // during discharging, Estorel greater than 0

 startLoad.hot    : Double     // fit Temp(Load) of turbine inøC
 Strategy     : String     // Operation Strategy
 PrefChargeto : Double     // Preference to Charging of Storage up to load
 startexcep: Int     // Start of Exception of storage preference
 endexcep  : Int     // End of Exception of storage preference
 HTF       : String  // Storage Fluid
 FP        : Int  // Activation of Freeze Protection of solar field by storage
 FC        : Int  // Activation offossil storage charging
 FCstartD  : Int  // Start fossil charging at Day
 FCstartM  : Int  // Start fossil charging at Month
 FCstopD   : Int  // Stop fossil charging at Day
 FCstopM   : Int  // Stop fossil charging at Month
 FCstartD2 : Int  // Second Start fossil charging at Day   091211: added, to be used for sites in regions like Austria
 FCstartM2 : Int  // Second Start fossil charging at Month 091211: added, to be used for sites in regions like Austria
 FCstopD2  : Int  // second Stop fossil charing at Day    091211: added, to be used for sites in regions like Austria
 FCstopM2  : Int  // Second Stop fossil charing at Month  091211: added, to be used for sites in regions like Austria
 HX           : Double       // HX Efficiency
 HXcap        : Double       // HX capacity (oil to salt) in MWt
 heatExchangerRestrictedMax   : Bool     // check box to restrict the max. capacity of HX
 HXmin        : Double       // HX minimum capacity in %
 HXresMin  : Int     // check box to restrict HX//s minimum load

 HTa_time     : Double  // time for heat tracing A begin
 HTa_pow      : Double  // power for heat tracing A
 HTb_time     : Double  // time for heat tracing B begin
 HTb_pow      : Double  // power for heat tracing B
 HTc_time     : Double  // time for heat tracing C begin
 HTc_pow      : Double  // power for heat tracing C
 HTd_time     : Double  // time for heat tracing D begin
 HTd_pow      : Double  // power for heat tracing D
 HTe_time     : Double  // time for heat tracing E begin
 HTe_pow      : Double  // power for heat tracing E

 heatdiff       : Double       //(Qsol-Qdemand)/Qdemand in % to discharge STO

 isVariable       : Double      //check box to discharge the storage at variable load or (at usual by 97%)constant load
 minDischargeLoad       : Double       //minimum load during storage discharge in %
 dSRise       : Double       //number of hours before (-) or after (+) sunrise for variable load calculation
 fixedDischargeLoad       : Double       //dicharge with fixed load, as usual. Now given as user input
 DischrgParFac: Double       //factor to multiply parasitics during discharge to consider HTF pumps

 definedBy           : String * 3      //how the TES size is defined (hours, MWh, Ton)

 AuxConsCurve  : Integer       //select if auxiliary consumption is to be calculated as quadratic polynom
 DesAuxIN      : Double       //nominal auxiliary electrical consumption
 DesAuxEX     : Double       //c0 coeff. for aux. consumption
 // AuxCons1     : Double       //Dummy
 // AuxCons2     : Double       //Dummy

 AuxModel: Bool
 Expn: Single
 level          : Double
 level2         : Double
 lowCh          : Double
 lowDc          : Double
 QinDES         : Double
 DesINmassSalt     : Double
 QexDes         : Double
 DesEXmassSalt     : Double

 QprodLoad: Double// 111130: added for shif ter
 QprodLoadWinter: Double// 111203: added for shif ter
 QprodLoadSummer: Double// 111203: added for shif ter
 dischrgWinter: Double
 dischrgSummer: Double
 badDNIwinter: Double
 badDNIsummer: Double

 TypeDir        : String   // 120130: added

 OU1_PeakHours : Double  // 120208: added
 }

 */
