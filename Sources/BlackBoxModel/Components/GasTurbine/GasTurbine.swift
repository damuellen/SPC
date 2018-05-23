//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

public enum GasTurbine: Component {
  
  /// a struct for operation-relevant data of the gas turbine
  public struct PerformanceData: Codable {
    var operationMode: OperationMode
    var isMaintained: Bool
    var load: Ratio

    public enum OperationMode: String, Codable, CustomStringConvertible {
      case free, load, ic, pc, noOperation, scheduledMaintenance
      
      public var description: String {
        return self.rawValue
      }
    }
  }

  static let initialState = PerformanceData(
    operationMode: .free, isMaintained: false, load: 0.0)

  static var parameter: Parameter = ParameterDefaults.gt

  /// Calculates the efficiency of the gas turbine which only depends on its own load
  public static func efficiency(at load: Ratio) -> Double {
    let efficiency = GasTurbine.parameter.EfofLc[load]
      * GasTurbine.parameter.efficiencyISO

    //	debugPrint("gas turbine efficiency at \(efficiency * 100.0)%")
    //	assert(efficiency < 1, "gas turbine efficiency at over 100%")

    return efficiency
  }

  /// Calculates the parasitics of the gas turbine which only depends on its current load
  public static func parasitics(at load: Ratio) -> Double {

    return GasTurbine.parameter.parasiticsLc[load] * GasTurbine.parameter.Pgross
  }

  /// Calculates the maximal load of the gas turbine which only depends on the ambient temperature
  public static func setLoadMaximum(by temperature: Temperature) {
    var maximumLoad = GasTurbine.parameter.loadmaxTc[temperature]
    // correction for altitude effect
    maximumLoad *= ((101.3 - 9.81 * 1.2 / 1_000 * GasTurbine.parameter.altitude) / 101.3)

    //GasTurbine.load = Ratio(maximumLoad)
  }
  
  public static func power(gasTurbine: inout GasTurbine.PerformanceData,
                           demand: Double,
                           availableFuel _: inout Double,
                           fuelFlow _: inout FuelConsumption) -> Double {
    
   // if status.isMaintained {
      /*
       gasTurbine.operationMode = .scheduledMaintenance
       gasTurbine.load = 0
       gasTurbine.efficiency = 0
       gasTurbine = 0
       PowerNeed = 0
       electricEnergy.gasTurbineGross = 0
       FuelFlowGasTurbine = 0
       */
    //  return 0
   // }
    
    let neededLoad = demand / GasTurbine.parameter.Pgross
    if gasTurbine.load.ratio > neededLoad {
      gasTurbine.load = Ratio(neededLoad)
    }
/*
     //"N" means NO GasTurbine operation desired !!!
     if GasTurbine.status.load < parameter.load min || Ucase$(OpRCCmode(month, time.Tariff)) = "N" || FuelAvlGasTurbine <= 0 {
     if GasTurbine.status.load > 0 { ////report = " Gas Turbine Load Below Min! \n"
     gasTurbine.load = 0
     gasTurbine.operationMode = .noOperation
     gasTurbine = 0
     gasTurbine.efficiency = 0
     electricEnergy.parasiticsGasTurbine = 0
     electricEnergy.gasTurbineGross = 0
     FuelFlowGasTurbine = 0
     // PowerNeed = 0
     return 0.0
     }
*/
    // electricEnergy.parasiticsGasTurbine = GasTurbineParFit * (GasTurbine.parameter.Pgross - Design.layout.gasTurbine)
    // gross GasTurbine Power Produced
    Plant.electricEnergy.gasTurbineGross = parameter.Pgross * gasTurbine.load.ratio
    Plant.fuel.gasTurbine = Plant.electricEnergy.gasTurbineGross / GasTurbine.efficiency(at: gasTurbine.load)

    return 0.0 // electricEnergy.GasTurbinegross - electricEnergy.parasiticsGasTurbine // net GasTurbine Power Produced
  }
  
  static func update(_ status: inout Plant.PerformanceData,
    availableFuel: inout Double,
    fuel: inout FuelConsumption,
    electricEnergy: inout ElectricEnergy,
    thermal: inout ThermalEnergy) -> Double {
    
    var supply = 0.0
    let GasTurbineLmax = 0.0
    
    var demand = electricEnergy.demand - min(
      thermal.production * HeatExchanger.parameter.efficiency
        * SteamTurbine.parameter.efficiencySCC, SteamTurbine.parameter.power.max)
    // ***********************************************************************
    // 1. Free (OpRCCmode = "f"), plant produces as much electricity as possible
    // +, plant follows a specif ic demand profile, specified
    //                           in DEM-File: if plant produces more than defined
    //                           the GasTurbine will be throttled
    // OpRCCmode = "P" and "I" are only used for old cases and files
    // also the WasteHeatRecovery.parameter.Operation is no longer needed, but still used in old cases
    if supply == 0 { // Ucase$(OpRCCmode(month, time.Tariff)) = "F" || Ucase$(OpRCCmode(month, time.Tariff)) = "L" {
      if false { // Ucase$(OpRCCmode(month, time.Tariff)) = "F" {
        //      NotheatIng else
      } else {
        while true { // just to estimate amount of WHR
          supply = GasTurbine.power(gasTurbine: &status.gasTurbine, demand: demand,
                                    availableFuel: &availableFuel,
                                    fuelFlow: &fuel)
          status.steamTurbine.load = Ratio(
            (electricEnergy.demand - electricEnergy.gasTurbineGross)
            / SteamTurbine.parameter.power.max)
          let efficiency = SteamTurbine.efficiency(
            &status, Lmax: 1.0)
          if GasTurbine.efficiency(at: status.gasTurbine.load) > 0 {
            demand /= (1 + efficiency * WasteHeatRecovery.parameter.efficiencyPure
              * (1 / GasTurbine.efficiency(at: status.gasTurbine.load) - 1)) // 1.135 *
            if abs(electricEnergy.gasTurbineGross - demand)
              < Simulation.parameter.heatTolerance {
              break
            }
          } else {
            if demand > electricEnergy.gasTurbineGross {
              if status.gasTurbine.load.ratio >= GasTurbineLmax {
                break
              }
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
          supply = GasTurbine.power(gasTurbine: &status.gasTurbine, demand: demand,
                                    availableFuel: &availableFuel,
                                    fuelFlow: &fuel)

          status.steamTurbine.load = Ratio(
            (electricEnergy.demand - electricEnergy.gasTurbineGross)
            / SteamTurbine.parameter.power.max)

          if GasTurbine.efficiency(at: status.gasTurbine.load) != 0 {
            demand = demand /
              (1 + SteamTurbine.efficiency(&status, Lmax: 1.0)
                * WasteHeatRecovery.parameter.efficiencyPure
                * (1 / GasTurbine.efficiency(at: status.gasTurbine.load) - 1)) // 1.135 *
            // for RH !!
            // Change of iteration procedure
            if abs(electricEnergy.gasTurbineGross - demand)
              < Simulation.parameter.heatTolerance { break }
          } else {
            if demand > electricEnergy.gasTurbineGross {
              if status.gasTurbine.load.ratio >= GasTurbineLmax { break }
              demand -= (demand - electricEnergy.gasTurbineGross) / 2
            } else {
              demand += (electricEnergy.gasTurbineGross - demand) / 2
            }
          }
        }
        // ST minimum load is always lower than what is required here !!
      } else {
        // WasteHeatRecovery.parameter.Operation = "Intg" or gasTurbine.operationMode = "IC"
        if demand < Design.layout.gasTurbine {
          demand = Design.layout.gasTurbine
          supply = GasTurbine.power(gasTurbine: &status.gasTurbine, demand: demand,
                                    availableFuel: &availableFuel,
                                    fuelFlow: &fuel) // GasTurbineLmax

          status.steamTurbine.load = Ratio(
            (electricEnergy.demand - electricEnergy.gasTurbineGross)
            / SteamTurbine.parameter.power.max)
          // to correctDC
          let HTFshare = demand * (1 / GasTurbine.parameter.efficiencyISO - 1)
            * WasteHeatRecovery.parameter.efficiencyNominal
            / WasteHeatRecovery.parameter.ratioHTF
          // if only Intg Mode possible GasTurbine should not be fired to avoid dumping Q-solar

          if case .integrated = WasteHeatRecovery.parameter.operation,
            thermal.production * HeatExchanger.parameter.efficiency > HTFshare {
            demand = 0
            // report = " Excess solar heat: Gas Turbine not operating\n"
          } else if GasTurbine.efficiency(at: status.gasTurbine.load) > 0 ,
            thermal.production * HeatExchanger.parameter.efficiency > HTFshare {
            // WasteHeatRecovery.parameter.Operation = "Pure"posbl
            // report = " Excess Q-solar: Gas Turbine operating at lower load\n"
            demand = (electricEnergy.demand - SteamTurbine.parameter.efficiencySCC
              * thermal.solar * HeatExchanger.parameter.efficiency) /
              (1 + SteamTurbine.parameter.efficiencySCC
                * WasteHeatRecovery.parameter.efficiencyNominal
                * (1 / GasTurbine.efficiency(at: status.gasTurbine.load) - 1))
            // Lower GasTurbine-demand, avoid production>demand
          } else if HTFshare > thermal.demand {
            demand *= thermal.demand / HTFshare
          }

          if (electricEnergy.demand - demand) > SteamTurbine.parameter.power.max {
            demand = (SteamTurbine.parameter.power.max
              / SteamTurbine.parameter.efficiencySCC
              - thermal.solar * HeatExchanger.parameter.efficiency)
              / (WasteHeatRecovery.parameter.efficiencyNominal
                * (1 / GasTurbine.parameter.efficiencyISO - 1))
          }
        } // WasteHeatRecovery.parameter.Operation
      }
      supply = GasTurbine.power(gasTurbine: &status.gasTurbine, demand: demand,
                                availableFuel: &availableFuel,
                                fuelFlow: &fuel) // GasTurbineLmax
      
      status.steamTurbine.load = Ratio(
        min(Plant.availability.value.powerBlock.ratio,
            (electricEnergy.demand - electricEnergy.gasTurbineGross)
              / SteamTurbine.parameter.power.max)
      )

      thermal.demand = status.steamTurbine.load.ratio
        * SteamTurbine.parameter.power.max
        / SteamTurbine.efficiency(&status, Lmax: 1.0)
      // FIXME  thermal.wasteHeatRecovery = WasteHeatRecovery(electricEnergy.gasTurbineGross, hourFraction)

      if thermal.wasteHeatRecovery < 0 {
        //	i = 0
      }

      // FIXME  SwitchTemp(gasTurbine.operationMode) // Change Temperatures according to Mode
    }
    return supply
  }
}

extension GasTurbine.PerformanceData: CustomStringConvertible {
  public var description: String {
    return "\(operationMode), "
      + "Maintenance: \(isMaintained ? "Yes" : "No"), "
      + "Load: \(load)"
  }
}
