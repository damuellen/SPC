import Helpers

public struct Costs {
  public static let labels = ["Loops", "DC", "AC", "Heater", "TES", "EY", "PB", "BESS", "H2", "Meth",
   "Boiler", "Grid", "Total_CAPEX", "Meth_Prod", "LCoE", "LCoTh", "LCH2", "LCoM", "PB_startups",
   "TES_discharges", "EY_plant_starts", "EY_count", "Meth_starts", "H2_to_Meth", "limit_sum"]

  // static let AdditionalCostPerLoop = 762533.1364
  static let FX_USD = 0.82
  static let Hydrogen_density = 5.783
  static let CO2_density = 945
  static let RawMeth_density = 782

  static let Solar_field = (basis: 38.0, c1: 1_581_220.0, exp: 0.8, f: 0.71, coeff: 18_000_000.0, range: 19.0...130.0)
  static let Assembly_hall = (c4: -0.037401977, c3: 23.83076428, c2: -5296.963373, c1: 518074.8094, c0: 185180.2005, range: 1.0...270.0)
  static let PV_DC_part = (basis: 605.0, coeff: 465_124.0)
  static let PV_AC_part = (basis: 490.0, exp: 0.7, coeff: 64_150.0, range: 267...778)
  static let Heater_system = (basis: 200.0, c1: 4_000_000.0, exp: 0.4, c2: 211728.735839637, factor: 0.9, coeff: 3_500_000.0, range: 200.0...400.0)
  static let Thermal_energy_storage = (basis: 26920.0, c1: 2_000_000.0, exp: 0.75, c2: 1908.888181, factor: 0.55, coeff: 26_000_000.0)
  static let Power_Block = (basis: 50.0, c1: 84_370_000.0, coeff: 466_229.0, range: 50.0...200.0)
  static let Electrolysis_coeff = 700_000.0 * 1.2
  static let Hydrogen_storage = (basis: 240 * Hydrogen_density, exp: 0.9, coeff: 780_000 * 1.2)
  static let CCU_plant = (basis: 20.6, exp: 0.7, coeff: 15_000_000.0 / FX_USD)
  static let CO2_storage = (basis: 240 * CO2_density, exp: 0.9, coeff: 780_000)
  static let MethSynt_plant = (basis: 19.5, exp: 0.7, coeff: 60_000_000.0 / FX_USD * 0.4)
  static let RawMeth_storage = (basis: 240 * RawMeth_density, exp: 0.9, coeff: 694146.8625 / FX_USD)
  static let MethDist_plant = (basis: 12.5, exp: 0.7, coeff: 60_000_000.0 / FX_USD * 0.6)
  static let Battery_energy_storage = (basis: 50.0, c1: 5_317_746.0, coeff: 319_065.0)
  static let Electrical_boiler = (basis: 3.27, exp: 0.7, coeff: 494000 * 1.45 * 1.2)
  static let Substation = (basis: 135.0, exp: 0.7, coeff: 2_400_000.0)
 
  // var Heat_to_aux_directly_from_CSP_sum: Double
  // var Heat_to_aux_from_PB_sum: Double
  // var Q_solar_before_dumping_sum: Double
  // var Total_SF_heat_dumped_sum: Double
  // var TES_thermal_input_by_CSP_sum: Double
  // var meth_plant_heatConsumption_sum: Double
  // var EY_aux_heatConsumption_sum: Double
  // var elec_from_grid_sum: Double
  // var elec_to_grid_sum: Double
  // var meth_produced_MTPH_sum: Double
  // var avail_total_net_elec_sum: Double
  // var net_elec_above_max_consumers_sum: Double
  // var Produced_thermal_energy_sum: Double
  // var H2_to_meth_production_effective_MTPH_sum: Double

  public func invest(_ model: TunOl) -> [Double]
   {
    // let factor = min(Heat_to_aux_directly_from_CSP_sum + Heat_to_aux_from_PB_sum * model.PB_Ratio_Heat_input_vs_output,
    //  Q_solar_before_dumping_sum - Total_SF_heat_dumped_sum - TES_thermal_input_by_CSP_sum)

    // var auxLoops = model.CSP_loop_nr_ud > 0 ?
    //  min(model.CSP_loop_nr_ud, Double(model.CSP_loop_nr_ud * factor / Q_solar_before_dumping_sum)) : 0
    // if (auxLoops <= 0 || factor <= 0) {
    //   auxLoops = 0
    // }
    let Assembly_hall_cost = model.CSP_loop_nr_ud > 0 ? Assembly_hall.c4 * Double(model.CSP_loop_nr_ud) ** 4 + Assembly_hall.c3 * Double(model.CSP_loop_nr_ud) ** 3
      + Assembly_hall.c2 * Double(model.CSP_loop_nr_ud) ** 2 + Assembly_hall.c1 * Double(model.CSP_loop_nr_ud) ** 1 + Assembly_hall.c0 : 0
    // let CSP_SF_cost_dedicated_to_ICPH =
    //   Costs.Solar_field.coeff * ((model.CSP_loop_nr_ud - auxLoops) / Costs.Solar_field.basis) ** Costs.Solar_field.exp + Costs.Solar_field.c1 * Costs.Solar_field.f
    //   * (model.CSP_loop_nr_ud - auxLoops)

    // var aux_Heat_ratio = Double(meth_plant_heatConsumption_sum / (meth_plant_heatConsumption_sum + EY_aux_heatConsumption_sum))
    // if aux_Heat_ratio.isNaN { aux_Heat_ratio = 0 }
    // let CSP_SF_cost_dedicated_to_Hydrogen = Costs.Solar_field.coeff * ((model.CSP_loop_nr_ud - auxLoops * aux_Heat_ratio) / Costs.Solar_field.basis) ** Costs.Solar_field.exp + Costs.Solar_field.c1 * Costs.Solar_field.f
    //   * (model.CSP_loop_nr_ud - auxLoops * aux_Heat_ratio)
    
    let CSP_SF_cost_dedicated_to_Methanol = Costs.Solar_field.coeff * (model.CSP_loop_nr_ud / Costs.Solar_field.basis) ** Costs.Solar_field.exp + Costs.Solar_field.c1 * Costs.Solar_field.f
      * model.CSP_loop_nr_ud
    // let CSP_SF_cost_dedicated_to_aux_heat = Costs.AdditionalCostPerLoop * auxLoops

    let PV_DC_cost = model.PV_DC_cap_ud * Costs.PV_DC_part.coeff + 0.0
    let PV_AC_cost = (model.PV_AC_cap_ud / Costs.PV_AC_part.basis) ** Costs.PV_AC_part.exp * Costs.PV_AC_part.basis * Costs.PV_AC_part.coeff + 0.0

    let Heater_cost = model.Heater_cap_ud > 0 ?
      (Costs.Heater_system.c1 + Costs.Heater_system.coeff * (model.Heater_cap_ud / Costs.Heater_system.basis) ** Costs.Heater_system.exp + model.Heater_cap_ud
      * Costs.Heater_system.factor * Costs.Heater_system.c2) : 0

    var TES_storage_cost =
      Costs.Thermal_energy_storage.c1 + Costs.Thermal_energy_storage.coeff * (model.TES_salt_mass / Costs.Thermal_energy_storage.basis) ** Costs.Thermal_energy_storage.exp
      + model.TES_salt_mass * Costs.Thermal_energy_storage.c2 * Costs.Thermal_energy_storage.factor
    if TES_Storage_cost.isNaN { TES_Storage_cost = 0 }
    
    let PB_cost = model.PB_nom_gross_cap_ud > 0 ? (Costs.Power_Block.c1 + (model.PB_nom_gross_cap_ud - Costs.Power_Block.basis) * Costs.Power_Block.coeff) : 0

    let Electrolysis_cost = model.EY_var_net_nom_cons_ud * Costs.Electrolysis_coeff + 0.0

    let Hydrogen_storage_cost = Costs.Hydrogen_storage.coeff * (model.Hydrogen_storage_cap_ud / Costs.Hydrogen_storage.basis) ** Costs.Hydrogen_storage.exp + 0.0

    let CCU_plant_cost = Costs.CCU_plant.coeff * (model.CCU_CO2_nom_prod_ud / Costs.CCU_plant.basis) ** Costs.CCU_plant.exp + 0.0

    let CO2_storage_cost = Costs.CO2_storage.coeff * (model.CO2_storage_cap_ud / Costs.CO2_storage.basis) ** Costs.CO2_storage.exp + 0.0

    let MethSynt_plant_cost = Costs.MethSynt_plant.coeff * (model.MethSynt_RawMeth_nom_prod_ud / Costs.MethSynt_plant.basis) ** Costs.MethSynt_plant.exp + 0.0

    let RawMeth_storage_cost = Costs.RawMeth_storage.coeff * (model.RawMeth_storage_cap_ud / Costs.RawMeth_storage.basis) ** Costs.RawMeth_storage.exp + 0.0

    let MethDist_plant_cost = Costs.MethDist_plant.coeff * (model.MethDist_Meth_nom_prod_ud / Costs.MethDist_plant.basis) ** Costs.MethDist_plant.exp + 0.0

    let Battery_storage_cost = model.BESS_cap_ud * Costs.Battery_energy_storage.coeff + (model.BESS_cap_ud > 0 ? Costs.Battery_energy_storage.c1 : 0)

    let Electrical_boiler_cost = model.El_boiler_cap_ud > 0 ?
      (Costs.Electrical_boiler.coeff * (model.El_boiler_cap_ud / Costs.Electrical_boiler.basis) ** Costs.Electrical_boiler.exp) : 0

    // let Substation_cost_ICPH =
      // Substation_capacity.coeff * Substation_capacity.basis * ((model.Heater_cap_ud + model.EY_var_net_nom_cons_ud  + model.EY_aux_elec_input + model.Meth_nominal_aux_electr_cons) / Substation_capacity.basis) ** Substation_capacity.exp

    let Substation_cost =
      Costs.Substation.coeff * (max(model.Grid_export_max_ud, model.Grid_import_max_ud) / Costs.Substation.basis) ** Costs.Substation.exp

    let CSP_O_M_Cost = (11.3333 / 3 * 1 / 3 * 1000 * 1000) + (0.00606061 / 3 * 1 / 3 * 1000 * 1000) * model.CSP_loop_nr_ud
    let PV_O_M_Cost = (11.3333 * 1000 * 1000) + (0.00606061 / 100 * 1000 * 1000) * model.PV_DC_cap_ud
    let PB_O_M_Cost = (11.3333 / 3 * 2 / 3 * 1000 * 1000) + (0.00606061 / 3 * 2 / 3 * 1000 * 1000) * model.PB_nom_gross_cap_ud

    // let CAPEX_ICPH_assembly_hall_csp_sf_dedicated_to_ICPH_PC_DC_PV_AC_Heaters_TES_PB_Substation =
      // Assembly_hall + CSP_SF_cost_dedicated_to_ICPH + PV_DC_Cost + PV_AC_Cost + Heater_Cost + TES_Storage_cost + PB_Cost + Substation_cost_ICPH

    // let CAPEX_aux_thermal_energy_csp_sf_cost_dedicated_to_aux_heat = CSP_SF_cost_dedicated_to_aux_heat

    // let CAPEX_Hydrogen_ICPH_half_of_loops_dedicated_to_aux_heat_electrolysis_half_of_electrical_boiler_cost =
    //  Assembly_hall + CSP_SF_cost_dedicated_to_Hydrogen + PV_DC_Cost + PV_AC_Cost + Heater_Cost
    //  + TES_Storage_cost + PB_Cost + (Electrical_boiler_cost * aux_Heat_ratio) + Substation_cost + Electrolysis_Cost

    let Total_CAPEX =
      Assembly_hall_cost + CSP_SF_cost_dedicated_to_Methanol + PV_DC_cost + PV_AC_cost + Heater_cost + TES_storage_cost + PB_cost + Electrolysis_cost + Hydrogen_storage_cost
      + CCU_plant_cost + CO2_storage_cost + MethSynt_plant_cost + RawMeth_storage_cost + MethDist_plant_cost + Battery_storage_cost + Electrical_boiler_cost + Substation_cost

    let Total_OPEX = CSP_O_M_Cost + PV_O_M_Cost + PB_O_M_Cost

    let Plant_life = 25.0
    let Rate_of_return = 0.07
    let FCR = Rate_of_return * (1 + Rate_of_return) ** Plant_life / ((1 + Rate_of_return) ** Plant_life - 1)
    let Elec_buy = 2 * 0.091
    let Elec_sell = 0.33 * 0.091

    // let LCH2 =
    //   (FCR * CAPEX_Hydrogen_ICPH_half_of_loops_dedicated_to_aux_heat_electrolysis_half_of_electrical_boiler_cost + Total_OPEX
    //     + elec_from_grid_sum * BUY * 1000 - elec_to_grid_sum * SELL * 1000) / H2_to_meth_production_effective_MTPH_sum
        
    // let LCoM =
    //   (FCR * Total_CAPEX + Total_OPEX + elec_from_grid_sum * Elec_buy * 1000 - elec_to_grid_sum * Elec_sell * 1000) / meth_produced_MTPH_sum

    // let LCoE =
    //   (FCR * CAPEX_ICPH_assembly_hall_csp_sf_dedicated_to_ICPH_PC_DC_PV_AC_Heaters_TES_PB_Substation + Total_OPEX) / Double(avail_total_net_elec_sum - net_elec_above_max_consumers_sum)

    // var LCoTh =
    //   (FCR * CAPEX_aux_thermal_energy_csp_sf_cost_dedicated_to_aux_heat) / Produced_thermal_energy_sum
    // if LCoTh.isNaN { LCoTh = 0 }
    return [
      Total_CAPEX, Total_OPEX, FCR, Elec_buy, Elec_sell
    //   Double(model.H2_to_meth_production_effective_MTPH_sum), (LCoM * 1000).rounded() / 1000, 
    //   (LCoE * 100).rounded() / 100, (LCoTh * 100).rounded() / 100, (LCH2 * 100).rounded() / 100, Double(model.PB_startup_heatConsumption_effective_count),
    //   Double(model.TES_discharge_effective_count), Double(model.EY_plant_start_count),
    //   Double(model.gross_operating_point_of_EY_count), Double(model.meth_plant_start_count),
    //   Double(model.H2_to_meth_production_effective_MTPH_count),
    //   Double(aux_elec_missing_due_to_grid_limit_sum)
    ]

    return []
  }
}
