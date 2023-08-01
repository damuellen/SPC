//
//  Copyright 2023 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Utilities

extension Storage {
  /// An enumeration defining the different units for storage definitions.
  public enum Definition: String, Codable {
    case hours = "hrs", cap, ton
  }

  /// An enumeration defining the operation types for storage.
  public enum TypeDir: String, Codable {
    case indirect, direct
  }

  /**
  A struct representing the parameters of the storage.
  
  The storage parameter set contains various properties related to storage,
  such as efficiency, heat loss, charging and discharging temperatures, etc.
  */
  public struct Parameter: Codable {
    /// The name of the storage parameter set.
    let name: String
    /// The charge efficiency of the storage.
    let chargeTo: Ratio
    /// The discharge efficiency of the storage to the turbine.
    let dischargeToTurbine: Ratio
    /// The discharge efficiency of the storage to the heater.
    let dischargeToHeater: Ratio
    /// The step size iteration used to iterate Tmin for the turbine.
    let stepSizeIteration: Double
    /// The relative filling of storage at program start (only for Thermocline).
    let heatStoredrel: Double
    /// Outlet temperature of storage during discharging (hot end) for Load = 0.
    let temperatureDischarge: Polynomial
    /// Outlet temperature (for Thermocline) or deltaT (for 2-Tank) of storage during discharging (hot end) for Load > 0.
    let temperatureDischarge2: Polynomial
    /// Outlet temperature of storage during charging (cold end) for Load = 0.
    let temperatureCharge: Polynomial
    /// Outlet temperature (for Thermocline) or deltaT (for 2-Tank) of storage during charging (cold end) for Load > 0.
    let temperatureCharge2: Polynomial
    /// Heat loss constant coefficient for storage.
    let heatlossCst: Polynomial
    /// Heat loss coefficient for storage from 0 to 1.
    let heatlossC0to1: Polynomial
    /// Pump efficiency of the storage.
    let pumpEfficiency: Double
    /// Pressure loss at the design point for storage.
    let pressureLoss: Double
    /// Mass flow share of storage to power block at the design point.
    let massFlowShare: Ratio
    /// Start temperature of cold and hot tanks at program start.
    let startTemperature: Sides<Temperature>
    /// Start load of cold and hot tanks at program start.
    let startLoad: Sides<Double>
    var type: TypeDir = .indirect
    /// The charging and discharging strategy of the storage.
    let strategy: Strategy
    /// The preferred charging efficiency of the storage to the turbine.
    let prefChargeToTurbine: Double
    /// The exception for storage definition in terms of months.
    let exception: ClosedRange<Int>
    /// The heat transfer fluid used in the storage.
    let HTF: StorageMedium
    /// Boolean indicating whether freeze protection is required for storage.
    let freezeProtection: Bool
    /// Boolean indicating whether fossil charging is allowed for storage.
    let fossilCharging: Bool
    /// Heat difference and dS rise for storage.
    let heatdiff, dSRise: Double
    /// The minimum and fixed discharge load for storage.
    let minDischargeLoad, fixedDischargeLoad: Ratio
    /// The time and power for heat tracing in storage.
    let heatTracingTime, heatTracingPower: [Double]
    /// Discharge parasitics factor for storage.
    let dischargeParasitcsFactor: Double
    /// Boolean indicating whether storage is variable.
    var isVariable = true
    /// Boolean indicating whether heat exchanger is restricted for storage.
    var heatExchangerRestrictedMin = false
    /// Boolean indicating whether auxiliary consumption curve is used for storage.
    var auxConsumptionCurve = false
    /// Boolean indicating whether heat exchanger is restricted for storage.
    var heatExchangerRestrictedMax = false
    /// The definition used for storage.
    var definedBy: Definition = .cap
    /// The design temperature for cold and hot storage tanks.
    let designTemperature: Sides<Temperature>
    /// The heat loss for cold and hot storage tanks.
    let heatLoss: Sides<Double>
    /// The fossil charging time in terms of day and month.
    let fossilChargingTime: [Int]
    /// The efficiency and capacity of the heat exchanger.
    let heatExchangerEfficiency, heatExchangerCapacity: Double
    /// The minimum capacity of the heat exchanger.
    let heatExchangerMinCapacity: Double
    /// The nominal auxiliary electrical consumption for storage.
    let DesAuxIN: Double
    /// The c0 coefficient for auxiliary consumption of storage.
    let DesAuxEX: Double
    /// The heat production load for storage.
    var heatProductionLoad: Double
    /// The mass flow to power block during charge in bad days winter.
    let heatProductionLoadWinter: Ratio
    /// The mass flow to power block during charge in bad days summer.
    let heatProductionLoadSummer: Ratio
    /// The time to begin TES discharge in winter and summer.
    let dischargeWinter, dischargeSummer: Int
    /// The DNI for bad days winter and summer.
    let badDNIwinter, badDNIsummer: Double
  }
}

/**
 A set of strategies for storage operation.
 
 - always: Storage is always charged and discharged as required.
 - demand: Storage is charged and discharged based on demand.
 - shifter: Storage is used as a shifter.
 */
public enum Strategy: String, Codable {
  case always, demand, shifter
  
  /// Initializes a Strategy enum from a string.
  init?(string: String) {
    self.init(rawValue: string.lowercased())
  }
}

extension Storage.Parameter: CustomStringConvertible {
  /// A description of the `Storage.Parameter` instance.
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
    + "Charging of Storage during Night by HTF-heater: \(fossilCharging)\n"
    + "Stop charging strategy at day:" * fossilChargingTime[1].description
    + "Stop charging strategy at month:" * fossilChargingTime[0].description
    + "Start charging strategy at day:" * fossilChargingTime[3].description
    + "Start charging strategy at month:" * fossilChargingTime[2].description
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
  /// Creates a `Storage.Parameter` instance using the data from a `TextConfigFile`.
  /// - Parameter file: The `TextConfigFile` containing the data for the parameter.
  public init(file: TextConfigFile) throws {
    typealias T = Temperature
    let ln: (Int) throws -> Double = { try file.readDouble(lineNumber: $0) }
    let l2: (Int) throws -> Int = { try file.readInteger(lineNumber: $0) }
    if file.lines[6].contains("no TES") { 
      self = Parameters.st
      return
    }
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
    startTemperature = try .init(T(celsius: ln(162)), T(celsius:ln(165)))
    startLoad = try .init(ln(168), ln(171))
  //  HX = try ln(172) //bool

    //file.values[172]
    strategy = .demand//try ln(173) 
    prefChargeToTurbine = try ln(174)
    exception = try l2(175)...l2(176)
    HTF = .solarSalt //try ln(177)
    freezeProtection = try l2(178) == -1
    fossilCharging = try l2(179) == -1
    fossilChargingTime = try [l2(180), l2(181), l2(182), l2(183), l2(222), l2(223), l2(224),l2(225)]
    heatExchangerRestrictedMax = try l2(186) == -1
    heatExchangerCapacity = try ln(189)
  //  Qfldif = try ln(192)
    isVariable = try l2(194) == -1
    dSRise = try ln(196)
    minDischargeLoad = try Ratio(ln(198))
    if file.lines[199].contains("NO_TES (= no input required)") {
      fixedDischargeLoad = .zero
    } else {
      fixedDischargeLoad = try Ratio(ln(200))
    }
    heatTracingTime = try [ln(202), ln(205), ln(208)]
    heatTracingPower = try [ln(203), ln(206), ln(209)]
 //   HTb_time = try ln(205)
 //   HTb_pow = try ln(206)
 //   HTc_time = try ln(208)
 //   HTc_pow = try ln(209)
   // TempHeatTracing = try ln(211)
  //  HTc_Temp = try ln(_)
  //  HTe_pow = try ln(_ )
    heatExchangerRestrictedMin = try l2(217) == -1 
    heatExchangerMinCapacity = try ln(218)
    dischargeParasitcsFactor = try ln(220)
    auxConsumptionCurve = try l2(227) == -1 
    DesAuxIN = try ln(228)
    DesAuxEX = try ln(229)
    heatProductionLoadWinter = try Ratio(ln(233))
    heatProductionLoadSummer = try Ratio(ln(234))
    dischargeWinter = try l2(235)
    dischargeSummer = try l2(236)
    badDNIwinter = try ln(238)
    badDNIsummer = try ln(239)
    type = .indirect // try ln(241)
    designTemperature = try .init(T(celsius: ln(118)), T(celsius: ln(121)))
    heatdiff = 0.25
    heatLoss = .init(0,0)
    heatExchangerEfficiency = 1
    heatProductionLoad = 0
  }  
}

/// An enumeration defining the different storage mediums.
public enum StorageMedium: String, Codable {
  case hiXL = "HitecXL"
  case xlt600 = "XLT600"
  case th66 = "TH66"
  case solarSalt = "SolarSalt"

  /// Heat transfer fluid properties for Solar Salt.
  static var ss = HeatTransferFluid(
    name: "Solar Salt",
    freezeTemperature: 240.0,
    heatCapacity: [1.44657, 0.000171715],
    dens: [1969.9, -0.603505, 0],
    visco: [0.0175373, -7.01716e-05, 7.62774e-08],
    thermCon: [0.44152, 0.00019, 0],
    maxTemperature: 400.0,
    h_T: [], T_h: [],
    useEnthalpy: false
  )

  /// Get the heat transfer fluid properties for a specific storage medium.
  public var properties: HeatTransferFluid {
    switch self {
    case .solarSalt:
      return StorageMedium.ss
    default:
      fatalError()
    }
  }
}
