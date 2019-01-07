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
  /// Contains all data needed to simulate the operation of the gas turbine
  public struct PerformanceData: Codable {

    var operationMode: OperationMode

    var isMaintained: Bool

    var load: Ratio

    public enum OperationMode: String, Codable, CustomStringConvertible {
      case free, load, integrated, pure, noOperation, scheduledMaintenance

      public var description: String {
        return rawValue
      }
    }
  }

  static let initialState = PerformanceData(
    operationMode: .free, isMaintained: false, load: 0.0
  )

  public static var parameter: Parameter = ParameterDefaults.gt

  /// Calculates the efficiency of the gas turbine which only depends on its own load
  static func efficiency(at load: Ratio) -> Double {

    let efficiency = parameter.efficiencyFromLoad[load]
      * parameter.efficiencyISO

    //	debugPrint("gas turbine efficiency at \(efficiency * 100.0)%")
    //	precondition(efficiency < 1, "gas turbine efficiency at over 100%")
    return efficiency
  }

  /// Calculates the parasitics of the gas turbine which only depends on its current load
  static func parasitics(estimateFrom load: Ratio) -> Double {
    return parameter.parasiticsFromLoad[load] * parameter.powerGross
  }

  /// Calculates the maximal load of the gas turbine which only depends on the ambient temperature
  static func maxLoad(at temperature: Temperature) -> Double {
    var maximumLoad = parameter.loadMaxFromTemperature[temperature]
    // correction for altitude effect
    maximumLoad *= ((101.3 - 9.81 * 1.2 / 1_000 * parameter.altitude) / 101.3)
    // GasTurbine.load.ratio = maximumLoad)
    return maximumLoad
  }

  static func perform(_ gt: inout GasTurbine.PerformanceData,
                      demand: Double, fuelAvailable: Double) -> Double {
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

    let neededLoad = demand / parameter.powerGross
    if gt.load.ratio > neededLoad {
      gt.load.ratio = neededLoad
    }
    /*
     //"N" means NO GasTurbine operation desired !!!
     if GasTurbine.status.load < parameter.load min || Ucase$(OpRCCmode(month, time.Tariff)) = "N" || FuelAvlGasTurbine <= 0 {
     if GasTurbine.status.load > 0 {
     💬.infoMessage("\(TimeStep.current) Gas Turbine Load Below minimum.")
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
    // electricEnergy.parasiticsGasTurbine = GasTurbineParFit * (gasTurbine.Pgross - Design.layout.gasTurbine)
    // gross GasTurbine Power Produced
    let gasTurbineGross = parameter.powerGross * gt.load.ratio
    //fuel = gasTurbineGross / GasTurbine.efficiency(at: gt.load)

    return gasTurbineGross // electricEnergy.GasTurbinegross - electricEnergy.parasiticsGasTurbine // net GasTurbine Power Produced
  }

  static func update(_ status: inout Plant.PerformanceData,
                     fuel: Double) -> Double {
    let heatExchanger = HeatExchanger.parameter

    let steamTurbine = SteamTurbine.parameter

    var supply = 0.0

    let GasTurbineLmax = 0.0

    var demand = Plant.electricalEnergy.demand

    demand -= Plant.heat.production.megaWatt
      * heatExchanger.efficiency
      * steamTurbine.efficiencySCC

    demand = demand.limited(by: steamTurbine.power.max)
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
          supply = GasTurbine.perform(
            &status.gasTurbine, demand: demand, fuelAvailable: fuel
          )
          status.steamTurbine.load.ratio = 
            (Plant.electricalEnergy.demand - Plant.electricalEnergy.gasTurbineGross)
              / steamTurbine.power.max

          (_, status.steamTurbine.efficiency) = SteamTurbine.perform(
            steamTurbine: status.steamTurbine, boiler: status.boiler,
            gasTurbine: status.gasTurbine, heatExchanger: status.heatExchanger
          )
          
          let eff = status.steamTurbine.efficiency
          
          if GasTurbine.efficiency(at: status.gasTurbine.load) > 0 {
            demand /= 1 + eff * WasteHeatRecovery.parameter.efficiencyPure
              * (1 / GasTurbine.efficiency(at: status.gasTurbine.load) - 1) // 1.135 *
            if abs(Plant.electricalEnergy.gasTurbineGross - demand)
              < Simulation.parameter.heatTolerance {
              break
            }
          } else {
            if demand > Plant.electricalEnergy.gasTurbineGross {
              if status.gasTurbine.load.ratio >= GasTurbineLmax {
                break
              }
              demand -= (demand - Plant.electricalEnergy.gasTurbineGross) / 2
            } else {
              demand += (Plant.electricalEnergy.gasTurbineGross - demand) / 2
            }
          }
        }
      }
    } else { // this is only used for old cases
      if case .pure = WasteHeatRecovery.parameter.operation {
        // Ucase$(OpRCCmode(month, time.Tariff)) = "P" {
        // Pure CC is possible and desired: all heat can be used (Qsol!)
        while true { // just to estimate amount of WHR
          supply = GasTurbine.perform(
            &status.gasTurbine, demand: demand, fuelAvailable: fuel
          )

          status.steamTurbine.load.ratio = 
            (Plant.electricalEnergy.demand - Plant.electricalEnergy.gasTurbineGross)
              / steamTurbine.power.max
          
          if GasTurbine.efficiency(at: status.gasTurbine.load) > 0 {

            (_, status.steamTurbine.efficiency) = SteamTurbine.perform(
              steamTurbine: status.steamTurbine, boiler: status.boiler,
              gasTurbine: status.gasTurbine, heatExchanger: status.heatExchanger
            )

            let eff = status.steamTurbine.efficiency
            
            demand /= 1 + eff * WasteHeatRecovery.parameter.efficiencyPure
              * (1 / GasTurbine.efficiency(at: status.gasTurbine.load) - 1) // 1.135 *
            // for RH !!
            // Change of iteration procedure
            if abs(Plant.electricalEnergy.gasTurbineGross - demand)
              < Simulation.parameter.heatTolerance { break }
          } else {
            if demand > Plant.electricalEnergy.gasTurbineGross {
              if status.gasTurbine.load.ratio >= GasTurbineLmax { break }
              demand -= (demand - Plant.electricalEnergy.gasTurbineGross) / 2
            } else {
              demand += (Plant.electricalEnergy.gasTurbineGross - demand) / 2
            }
          }
        }
        // ST minimum load is always lower than what is required here !!
      } else {
        // WasteHeatRecovery.parameter.Operation = "Intg" or gasTurbine.operationMode = "IC"
        if demand < Design.layout.gasTurbine {
          demand = Design.layout.gasTurbine
          supply = GasTurbine.perform(
            &status.gasTurbine, demand: demand, fuelAvailable: fuel
          ) // GasTurbineLmax

          status.steamTurbine.load.ratio = 
            (Plant.electricalEnergy.demand - Plant.electricalEnergy.gasTurbineGross)
              / steamTurbine.power.max
          
          // to correctDC
          let htfShare = demand * (1 / parameter.efficiencyISO - 1)
            * WasteHeatRecovery.parameter.efficiencyNominal
            / WasteHeatRecovery.parameter.ratioHTF
          // if only Intg Mode possible GasTurbine should not be fired to avoid dumping Q-solar
          let production = Plant.heat.production.megaWatt
          if case .integrated = WasteHeatRecovery.parameter.operation,
             production * heatExchanger.efficiency > htfShare {

            demand = 0.0
            💬.infoMessage("""
              \(TimeStep.current)
              Excess solar heat: Gas Turbine not operating.
              """)
          } else if GasTurbine.efficiency(at: status.gasTurbine.load) > 0,
            production * heatExchanger.efficiency > htfShare {
            // WasteHeatRecovery.parameter.Operation = "Pure"posbl
            💬.infoMessage("""
              \(TimeStep.current)
              Excess Q-solar: Gas Turbine operating at lower load.
              """)

            demand = (Plant.electricalEnergy.demand - steamTurbine.efficiencySCC
              * Plant.heat.solar.megaWatt * heatExchanger.efficiency) /
              (1 + steamTurbine.efficiencySCC
                * WasteHeatRecovery.parameter.efficiencyNominal
                * (1 / GasTurbine.efficiency(at: status.gasTurbine.load) - 1))
            // Lower GasTurbine-demand, avoid production>demand
          } else if htfShare > Plant.heat.demand.watt {

            demand *= Plant.heat.demand.megaWatt / htfShare
          }

          if (Plant.electricalEnergy.demand - demand) > steamTurbine.power.max {
            
            demand = (steamTurbine.power.max / steamTurbine.efficiencySCC
              - Plant.heat.solar.megaWatt * heatExchanger.efficiency)
              / (WasteHeatRecovery.parameter.efficiencyNominal
                * (1 / parameter.efficiencyISO - 1))
          }
        } // WasteHeatRecovery.parameter.Operation
      }
      supply = GasTurbine.perform(
        &status.gasTurbine, demand: demand, fuelAvailable: fuel
      ) // GasTurbineLmax

      status.steamTurbine.load.ratio =
        (Plant.electricalEnergy.demand - Plant.electricalEnergy.gasTurbineGross)
        / steamTurbine.power.max
      
      status.steamTurbine.load.ratio = status.steamTurbine.load.ratio
        .limited(by: Availability.current.value.powerBlock.ratio)
      
      (_, status.steamTurbine.efficiency) = SteamTurbine.perform(
        steamTurbine: status.steamTurbine, boiler: status.boiler,
        gasTurbine: status.gasTurbine, heatExchanger: status.heatExchanger
      )
      
      Plant.heat.demand.megaWatt = status.steamTurbine.load.ratio
        * steamTurbine.power.max / status.steamTurbine.efficiency
      // FIXME: thermal.wasteHeatRecovery = WasteHeatRecovery(electricEnergy.gasTurbineGross, hourFraction)

      if Plant.heat.wasteHeatRecovery.watt < 0 {
        //	i = 0
      }
      // FIXME: SwitchTemp(gasTurbine.operationMode) // Change Temperatures according to Mode
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
