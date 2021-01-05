//
//  Copyright 2017 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

import DateGenerator
/// Contains all data needed to simulate the operation of the gas turbine
public struct GasTurbine: Parameterizable {

  var operationMode: OperationMode

  var isMaintained: Bool

  var load: Ratio

  public enum OperationMode: String, Codable, CustomStringConvertible {
    case free, load, integrated, pure, noOperation, scheduledMaintenance

    public var description: String {
      return rawValue
    }
  }

  static let initialState = GasTurbine(
    operationMode: .free, isMaintained: false, load: 0.0
  )

  public static var parameter: Parameter = ParameterDefaults.gt

  /// Calculates the efficiency of the gas turbine which only depends on its own load
  static func efficiency(at load: Ratio) -> Double {

    let efficiency = parameter.efficiencyFromLoad(load)
      * parameter.efficiencyISO

    //	debugPrint("gas turbine efficiency at \(efficiency * 100.0)%")
    //	precondition(efficiency < 1, "gas turbine efficiency at over 100%")
    return efficiency
  }

  /// Calculates the parasitics of the gas turbine which only depends on its current load
  static func parasitics(estimateFrom load: Ratio) -> Double {
    return parameter.parasiticsFromLoad(load) * parameter.powerGross
  }

  /// Calculates the maximal load of the gas turbine which only depends on the ambient temperature
  static func maxLoad(at temperature: Temperature) -> Double {
    var maximumLoad = parameter.loadMaxFromTemperature(temperature)
    // correction for altitude effect
    maximumLoad *= ((101.3 - 9.81 * 1.2 / 1_000 * parameter.altitude) / 101.3)
    // GasTurbine.load.ratio = maximumLoad)
    return maximumLoad
  }

  static func perform(
    _ gt: GasTurbine, demand: Double, fuelAvailable: Double
  ) -> (neededLoad: Ratio, gasTurbineGross: Double) {
    // if status.isMaintained {
    /*
     gasTurbine.operationMode = .scheduledMaintenance
     gasTurbine.load = 0
     gasTurbine.efficiency = 0
     gasTurbine = 0
     PowerNeed = 0
     electricPerformance.gasTurbineGross = 0
     FuelFlowGasTurbine = 0
     */
    //  return 0
    // }

    let neededLoad = Ratio(demand / parameter.powerGross)
    /*
     //"N" means NO GasTurbine operation desired !!!
     if GasTurbine.status.load < parameter.load min || Ucase$(OpRCCmode(month, time.Tariff)) = "N" || FuelAvlGasTurbine <= 0 {
     if GasTurbine.status.load > 0 {
     debugPrint("\(DateTime.current) Gas Turbine Load Below minimum.")
     gasTurbine.load = 0
     gasTurbine.operationMode = .noOperation
     gasTurbine = 0
     gasTurbine.efficiency = 0
     electricPerformance.parasiticsGasTurbine = 0
     electricPerformance.gasTurbineGross = 0
     FuelFlowGasTurbine = 0
     // PowerNeed = 0
     return 0.0
     }
     */
    // electricPerformance.parasiticsGasTurbine = GasTurbineParFit * (gasTurbine.Pgross - Design.layout.gasTurbine)
    // gross GasTurbine Power Produced
    let gasTurbineGross = parameter.powerGross * gt.load.ratio
    //fuel = gasTurbineGross / GasTurbine.efficiency(at: gt.load)

    return (neededLoad, gasTurbineGross) // electricPerformance.GasTurbinegross - electricPerformance.parasiticsGasTurbine // net GasTurbine Power Produced
  }

  static func update(
  //  storage: inout Storage,
  //  powerBlock: inout PowerBlock,
    boiler: Boiler.OperationMode,
    gasTurbine: inout GasTurbine,
    heatExchanger: HeatExchanger,
    steamTurbine: inout SteamTurbine,
    temperature: Temperature,
    fuel: Double,
    plant: inout Plant)
    -> Double
  {
    var supply = 0.0

    let GasTurbineLmax = 0.0

    var demand = plant.electricity.demand

    demand -= plant.heat.production.megaWatt
      * HeatExchanger.parameter.efficiency
      * SteamTurbine.parameter.efficiencySCC

    demand = min(demand, SteamTurbine.parameter.power.max)
    // ***********************************************************************
    // 1. Free (OpRCCmode = "f"), plant produces as much electricity as possible
    // +, plant follows a specif ic demand profile, specified
    //                           in DEM-File: if plant produces more than defined
    //                           the GasTurbine will be throttled
    // OpRCCmode = "P" and "I" are only used for old cases and files
    // also the WasteHeatRecovery.parameter.Operation is no longer needed, but still used in old cases
    if supply == 0 { // Ucase$(OpRCCmode(month, time.Tariff)) = "F" || Ucase$(OpRCCmode(month, time.Tariff)) = "L" {
      if false { // Ucase$(OpRCCmode(month, time.Tariff)) = "F" {
        //      Nothinng else
      } else {
        while true { // just to estimate amount of WHR
          (_,supply) = GasTurbine.perform(gasTurbine, demand: demand, fuelAvailable: fuel)
          steamTurbine.load = Ratio(
            (plant.electricity.demand - plant.electricity.gasTurbineGross)
              / SteamTurbine.parameter.power.max)

        //  if status.steamTurbine.load.ratio != load {
            // The turbine load has changed recalculation of efficiency
            let (_,  eff) = SteamTurbine.perform(
              steamTurbine.load, plant.heat, boiler, gasTurbine.operationMode,
              heatExchanger.temperature.inlet, temperature)
        //  }
          
          
          if GasTurbine.efficiency(at: gasTurbine.load) > 0 {
            demand /= 1 + eff * WasteHeatRecovery.parameter.efficiencyPure
              * (1 / GasTurbine.efficiency(at: gasTurbine.load) - 1) // 1.135 *
            if abs(plant.electricity.gasTurbineGross - demand)
              < Simulation.parameter.heatTolerance {
              break
            }
          } else {
            if demand > plant.electricity.gasTurbineGross {
              if gasTurbine.load.ratio >= GasTurbineLmax {
                break
              }
              demand -= (demand - plant.electricity.gasTurbineGross) / 2
            } else {
              demand += (plant.electricity.gasTurbineGross - demand) / 2
            }
          }
        }
      }
    } else { // this is only used for old cases
      if case .pure = WasteHeatRecovery.parameter.operation {
        // Ucase$(OpRCCmode(month, time.Tariff)) = "P" {
        // Pure CC is possible and desired: all heat can be used (Qsol!)
        while true { // just to estimate amount of WHR
          (_,supply) = GasTurbine.perform(
            gasTurbine, demand: demand, fuelAvailable: fuel
          )

          let load = Ratio(
            (plant.electricity.demand - plant.electricity.gasTurbineGross)
              / SteamTurbine.parameter.power.max)
          
          if GasTurbine.efficiency(at: gasTurbine.load) > 0 {

          //  if status.steamTurbine.load.ratio != load {
              steamTurbine.load = load
              // The turbine load has changed recalculation of efficiency
              let (_, eff) = SteamTurbine.perform(
              steamTurbine.load, plant.heat, boiler, gasTurbine.operationMode,
              heatExchanger.temperature.inlet, temperature)
          //  }

            
            demand /= 1 + eff * WasteHeatRecovery.parameter.efficiencyPure
              * (1 / GasTurbine.efficiency(at: gasTurbine.load) - 1) // 1.135 *
            // for RH !!
            // Change of iteration procedure
            if abs(plant.electricity.gasTurbineGross - demand)
              < Simulation.parameter.heatTolerance { break }
          } else {
            if demand > plant.electricity.gasTurbineGross {
              if gasTurbine.load.ratio >= GasTurbineLmax { break }
              demand -= (demand - plant.electricity.gasTurbineGross) / 2
            } else {
              demand += (plant.electricity.gasTurbineGross - demand) / 2
            }
          }
        }
        // ST minimum load is always lower than what is required here !!
      } else {
        // WasteHeatRecovery.parameter.Operation = "Intg" or gasTurbine.operationMode = "IC"
        if demand < Design.layout.gasTurbine {
          demand = Design.layout.gasTurbine
          (_,supply) = GasTurbine.perform(gasTurbine, demand: demand, fuelAvailable: fuel) // GasTurbineLmax

          steamTurbine.load = Ratio(
            (plant.electricity.demand - plant.electricity.gasTurbineGross)
              / SteamTurbine.parameter.power.max)
          
          // to correctDC
          let htfShare = demand * (1 / parameter.efficiencyISO - 1)
            * WasteHeatRecovery.parameter.efficiencyNominal
            / WasteHeatRecovery.parameter.ratioHTF
          // if only Intg Mode possible GasTurbine should not be fired to avoid dumping Q-solar
          let production = plant.heat.production.megaWatt
          if case .integrated = WasteHeatRecovery.parameter.operation,
             production * HeatExchanger.parameter.efficiency > htfShare {

            demand = 0.0
            debugPrint("""
              \(DateTime.current)
              Excess solar heat: Gas Turbine not operating.
              """)
          } else if GasTurbine.efficiency(at: gasTurbine.load) > 0,
            production * HeatExchanger.parameter.efficiency > htfShare {
            // WasteHeatRecovery.parameter.Operation = "Pure"posbl
            debugPrint("""
              \(DateTime.current)
              Excess Q-solar: Gas Turbine operating at lower load.
              """)

            demand = (plant.electricity.demand - SteamTurbine.parameter.efficiencySCC
              * plant.heat.solar.megaWatt * HeatExchanger.parameter.efficiency) /
              (1 + SteamTurbine.parameter.efficiencySCC
                * WasteHeatRecovery.parameter.efficiencyNominal
                * (1 / GasTurbine.efficiency(at: gasTurbine.load) - 1))
            // Lower GasTurbine-demand, avoid production>demand
          } else if htfShare > plant.heat.demand.watt {

            demand *= plant.heat.demand.megaWatt / htfShare
          }

          if (plant.electricity.demand - demand) > SteamTurbine.parameter.power.max {
            
            demand = (SteamTurbine.parameter.power.max / SteamTurbine.parameter.efficiencySCC
              - plant.heat.solar.megaWatt * HeatExchanger.parameter.efficiency)
              / (WasteHeatRecovery.parameter.efficiencyNominal
                * (1 / parameter.efficiencyISO - 1))
          }
        } // WasteHeatRecovery.parameter.Operation
      }
      (_,supply) = GasTurbine.perform(gasTurbine, demand: demand, fuelAvailable: fuel) // GasTurbineLmax
      steamTurbine.load = Ratio((plant.electricity.demand - plant.electricity.gasTurbineGross)
        / SteamTurbine.parameter.power.max)
      steamTurbine.load.limited(to: Availability.current.value.powerBlock)
      
    //  if status.steamTurbine.load.ratio != load {
        // The turbine load has changed recalculation of efficiency
        let (_, eff) = SteamTurbine.perform(
        steamTurbine.load, plant.heat, boiler, gasTurbine.operationMode,
        heatExchanger.temperature.inlet, temperature)
    //  }
      
      plant.heat.demand.megaWatt = steamTurbine.load.ratio
        * SteamTurbine.parameter.power.max / eff
      // FIXME: thermal.wasteHeatRecovery = WasteHeatRecovery(electricPerformance.gasTurbineGross, hourFraction)

      if plant.heat.wasteHeatRecovery.watt < 0 {
        //	i = 0
      }
      // FIXME: SwitchTemp(gasTurbine.operationMode) // Change Temperatures according to Mode
    }
    return supply
  }
}
