//
//  Copyright (c) 2017 Daniel Müllenborn. All rights reserved.
//  Distributed under the The Non-Profit Open Software License version 3.0
//  http://opensource.org/licenses/NPOSL-3.0
//
//  This project is NOT free software. It is open source, you are allowed to
//  modify it (if you keep the license), but it may not be commercially
//  distributed other than under the conditions noted above.
//

import Foundation

extension GasTurbine.Instance: CustomDebugStringConvertible {
  var debugDescription: String { return "\(workingConditions.current)" }
}

public enum GasTurbine: Model {
  
  final class Instance {
    // A singleton class holding the state of the gas turbine
    static let shared = Instance()
    var parameter: GasTurbine.Parameter!
    var workingConditions: (previous: PerformanceData?, current: PerformanceData)
    
    private init() {
      workingConditions = (nil, initialState)
    }
  }

  /// a struct for operation-relevant data of the gas turbine
  public struct PerformanceData {
    var operationMode: OperationMode
    var isMaintained: Bool
    var load: Ratio
    var heatFlow: Double = 0.0

    public enum OperationMode {
      case free, load, ic, pc, noOperation, scheduledMaintenance
    }
  }

  fileprivate static let initialState = PerformanceData(
    operationMode: .free, isMaintained: false,
    load: 0.0, heatFlow: 0.0)

  /// Returns the current working conditions of the gas turbine
  public static var status: PerformanceData {
    get { return Instance.shared.workingConditions.current }
    set {
      Instance.shared.workingConditions =
       (Instance.shared.workingConditions.current, newValue) 
    }
  }

  /// Returns the previous working conditions of the gas turbine
  public static var previous: PerformanceData? {
    return Instance.shared.workingConditions.previous
  }

  public static var parameter: GasTurbine.Parameter {
    get { return Instance.shared.parameter }
    set { Instance.shared.parameter = newValue }
  }

  public static var heatFlow: Double {
    get { return status.heatFlow }
    set { status.heatFlow = newValue }
  }

  /// Current load of the boiler
  public static var load: Ratio {
    get { return status.load }
    set { status.load = newValue }
  }

  /// Returns the efficiency of the gas turbine based on her working conditions
  /// - SeeAlso: `GasTurbine.efficiency(load:)`
  public static var efficiency: Double {
    return GasTurbine.efficiency(at: load)
  }

  /// Returns the parasitics of the gas turbine based on her working conditions
  /// - SeeAlso: `GasTurbine.parasitics(load:)`
  public static var parasitics: Double {
    return GasTurbine.parasitics(at: load)
  }

  /// Calculates the efficiency of the gas turbine which only depends on its own load
  private static func efficiency(at load: Ratio) -> Double {
    let efficiency = GasTurbine.parameter.EfofLc[load]
      * GasTurbine.parameter.efficiencyISO

    //	debugPrint("gas turbine efficiency at \(efficiency * 100.0)%")
    //	precondition(efficiency < 1, "gas turbine efficiency at over 100%")

    return efficiency
  }

  /// Calculates the parasitics of the gas turbine which only depends on its current load
  private static func parasitics(at load: Ratio) -> Double {
    if status.isMaintained { return 0 }
    return GasTurbine.parameter.parasiticsLc[load] * GasTurbine.parameter.Pgross
  }

  /// Calculates the maximal load of the gas turbine which only depends on the ambient temperature
  public static func setLoadMaximum(by temperature: Temperature) {
    var maximumLoad = GasTurbine.parameter.loadmaxTc[temperature]
    // correction for altitude effect
    maximumLoad *= ((101.3 - 9.81 * 1.2 / 1_000 * GasTurbine.parameter.altitude) / 101.3)

    GasTurbine.load = Ratio(maximumLoad)
  }
  
  public static func power(demand: Double,
                           availableFuel _: inout Double,
                           fuelFlow _: inout FuelConsumption) -> Double {
    
    if status.isMaintained {
      /*
       gasTurbine.operationMode = "SM"
       GasTurbine.status.load = 0
       GasTurbine.status.efficiency = 0
       GasTurbine = 0
       PowerNeed = 0
       electricEnergy.gasTurbineGross = 0
       FuelFlowGasTurbine = 0
       */
      return 0
    }
    
    let neededLoad = demand / GasTurbine.parameter.Pgross
    if GasTurbine.load.value > neededLoad {
      GasTurbine.load = Ratio(neededLoad)
    }

    /* "N" means NO GasTurbine operation desired !!!
     if GasTurbine.status.load < parameter.load min || Ucase$(OpRCCmode(month, time.Tariff)) = "N" || FuelAvlGasTurbine <= 0 {
     if GasTurbine.status.load > 0 { ////report = " Gas Turbine Load Below Min! \n"
     GasTurbine.status.load = 0
     GasTurbine.status.operationMode = .noOperation
     GasTurbine = 0
     GasTurbine.status.efficiency = 0
     electricEnergy.parasiticsGasTurbine = 0
     electricEnergy.gasTurbineGross = 0
     FuelFlowGasTurbine = 0
     // PowerNeed = 0
     return 0.0
     } */

    // electricEnergy.parasiticsGasTurbine = GasTurbineParFit * (GasTurbine.parameter.Pgross - Design.layout.gasTurbine)
    // gross GasTurbine Power Produced
    Plant.electricEnergy.gasTurbineGross = parameter.Pgross * GasTurbine.load.value
    Plant.fuel.gasTurbine = Plant.electricEnergy.gasTurbineGross / GasTurbine.efficiency

    return 0.0 // electricEnergy.GasTurbinegross - electricEnergy.parasiticsGasTurbine // net GasTurbine Power Produced
  }

  public static func operate(at date: Date,
                             availableFuel: inout Double,
                             fuel: inout FuelConsumption,
                             electricEnergy: inout ElectricEnergy,
                             heatFlow: inout HeatFlow,
                             steamTurbine: inout SteamTurbine.PerformanceData) -> Double {

    var supply = 0.0
    let GasTurbineLmax = 0.0
    
    var demand = electricEnergy.demand - min(
      heatFlow.production * HeatExchanger.parameter.efficiency
        * SteamTurbine.parameter.efficiencySCC, SteamTurbine.parameter.power.max)
    // ***********************************************************************
    // 1. Free (OpRCCmode = "f"), plant produces as much electricity as possible
    // 2. Load (OpRCCmode = "l"), plant follows a specif ic demand profile, specified
    //                           in DEM-File: if plant produces more than defined
    //                           the GasTurbine will be throttled
    // OpRCCmode = "P" and "I" are only used for old cases and files
    // also the WasteHeatRecovery.parameter.Operation is no longer needed, but still used in old cases
    if supply == 0 { // Ucase$(OpRCCmode(month, time.Tariff)) = "F" || Ucase$(OpRCCmode(month, time.Tariff)) = "L" {
      if false { // Ucase$(OpRCCmode(month, time.Tariff)) = "F" {
        //      Nothing else
      } else {
        while true { // just to estimate amount of WHR
          supply = GasTurbine.power(demand: demand,
                                    availableFuel: &availableFuel,
                                    fuelFlow: &fuel)
          SteamTurbine.status.load = Ratio(
            (electricEnergy.demand - electricEnergy.gasTurbineGross)
            / SteamTurbine.parameter.power.max)
          let efficiency = SteamTurbine.efficiency
          if GasTurbine.efficiency != 0 {
            demand /= (1 + efficiency * WasteHeatRecovery.parameter.efficiencyPure
              * (1 / GasTurbine.efficiency - 1)) // 1.135 *
            if abs(electricEnergy.gasTurbineGross - demand)
              < Simulation.parameter.heatTolerance { break }
          } else {
            if demand > electricEnergy.gasTurbineGross {
              if GasTurbine.status.load.value >= GasTurbineLmax { break }
              demand -= (demand - electricEnergy.gasTurbineGross) / 2
            } else {
              demand += (electricEnergy.gasTurbineGross - demand) / 2
            }
          }
        }
      }
    } else { // this is only used for old cases
      if case .pure = WasteHeatRecovery.parameter.operation {
        // Ucase$(OpRCCmode(month, time.Tariff)) = "P" {
        // Pure CC is possible and desired: all heat can be used (Qsol!)
        while true { // just to estimate amount of WHR
          supply = GasTurbine.power(demand: demand,
                                    availableFuel: &availableFuel,
                                    fuelFlow: &fuel)

          steamTurbine.load = Ratio(
            (electricEnergy.demand - electricEnergy.gasTurbineGross)
            / SteamTurbine.parameter.power.max)

          if GasTurbine.efficiency != 0 {
            demand = demand /
              (1 + SteamTurbine.efficiency * WasteHeatRecovery.parameter.efficiencyPure
                * (1 / GasTurbine.efficiency - 1)) // 1.135 *
            // for RH !!
            // Change of iteration procedure
            if abs(electricEnergy.gasTurbineGross - demand)
              < Simulation.parameter.heatTolerance { break }
          } else {
            if demand > electricEnergy.gasTurbineGross {
              if GasTurbine.status.load.value >= GasTurbineLmax { break }
              demand -= (demand - electricEnergy.gasTurbineGross) / 2
            } else {
              demand += (electricEnergy.gasTurbineGross - demand) / 2
            }
          }
        }
        // ST minimum load is always lower than what is required here !!
      } else {
        // WasteHeatRecovery.parameter.Operation = "Intg" or GasTurbine.status.operationMode = "IC"
        if demand < Design.layout.gasTurbine {
          demand = Design.layout.gasTurbine
          supply = GasTurbine.power(demand: demand,
                                    availableFuel: &availableFuel,
                                    fuelFlow: &fuel) // GasTurbineLmax

          steamTurbine.load = Ratio(
            (electricEnergy.demand - electricEnergy.gasTurbineGross)
            / SteamTurbine.parameter.power.max)
          // to correctDC
          let HTFshare = demand * (1 / GasTurbine.parameter.efficiencyISO - 1)
            * WasteHeatRecovery.parameter.efficiencyNominal
            / WasteHeatRecovery.parameter.ratioHTF
          // if only Intg Mode possible GasTurbine should not be fired to avoid dumping Q-solar

          if case .integrated = WasteHeatRecovery.parameter.operation,
            heatFlow.production * HeatExchanger.parameter.efficiency > HTFshare {
            demand = 0
            ////report = " Excess solar heat: Gas Turbine not operating\n"
          } else if GasTurbine.efficiency > 0 ,
            heatFlow.production * HeatExchanger.parameter.efficiency > HTFshare {
            // WasteHeatRecovery.parameter.Operation = "Pure"posbl
            ////report = " Excess Q-solar: Gas Turbine operating at lower load\n"
            demand = (electricEnergy.demand - SteamTurbine.parameter.efficiencySCC
              * heatFlow.solar * HeatExchanger.parameter.efficiency) /
              (1 + SteamTurbine.parameter.efficiencySCC
                * WasteHeatRecovery.parameter.efficiencyNominal
                * (1 / GasTurbine.efficiency - 1))
            
          } else if HTFshare > heatFlow.demand { // Lower GasTurbine-demand, avoid production>demand
            demand *= heatFlow.demand / HTFshare
          }

          if (electricEnergy.demand - demand) > SteamTurbine.parameter.power.max {
            demand = (SteamTurbine.parameter.power.max
              / SteamTurbine.parameter.efficiencySCC
              - heatFlow.solar * HeatExchanger.parameter.efficiency)
              / (WasteHeatRecovery.parameter.efficiencyNominal
                * (1 / GasTurbine.parameter.efficiencyISO - 1))
          }
        } // WasteHeatRecovery.parameter.Operation
      }
      supply = GasTurbine.power(demand: demand,
                                availableFuel: &availableFuel,
                                fuelFlow: &fuel) // GasTurbineLmax
      
      steamTurbine.load = Ratio(
        min(Plant.availability[date.month].powerBlock.value,
            (electricEnergy.demand - electricEnergy.gasTurbineGross)
              / SteamTurbine.parameter.power.max)
      )

      heatFlow.demand = SteamTurbine.status.load.value
        * SteamTurbine.parameter.power.max
        / SteamTurbine.efficiency
      // FIXME  heatFlow.wasteHeatRecovery = WasteHeatRecovery(electricEnergy.gasTurbineGross, hourFraction)

      if heatFlow.wasteHeatRecovery < 0 {
        //	i = 0
      }

      // FIXME  SwitchTemp(GasTurbine.status.operationMode) // Change Temperatures according to Mode
    }
    return supply
  }
}
