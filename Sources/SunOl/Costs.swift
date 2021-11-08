import Helpers

enum SpecificCost {
  static let labels = ["Loops", "DC", "AC", "Heater", "TES", "EY", "PB", "BESS", "H2", "Meth", "Boiler", "Grid", "CAPEX", "H2_", "LCoE", "LCoTh", "LCH2", "LCoM"]
  static let AdditionalCostPerLoop = 762533.1364
  static let Solar_field = (basis: 38.0, c1: 1_581_220.0, exp: 0.8, f: 0.71, coeff: 18_000_000.0, range: 19.0...130.0)
  static let Assembly_hall_1_line = (c1: 12_000_000.0, c2: 3_300_000.0, range: 1.0...60.0)
  static let Assembly_hall_2_lines = (c1: 12_000_000.0, c2: 5_940_000.0, range: 61.0...130.0)
  static let Assembly_hall_3_lines = (c1: 12_000_000.0, c2: 9_240_000.0, range: 131.0...190.0)
  static let Assembly_hall_4_lines = (c1: 12_000_000.0, c2: 9_240_000.0, range: 191.0...220.0)
  static let Assembly_hall_5_lines = (c1: 12_000_000.0, c2: 9_240_000.0, range: 221.0...250.0)
  static let PV_DC_part = (basis: 605.0, coeff: 465_124.0)
  static let PV_AC_part = (basis: 490.0, exp: 0.7, coeff: 64_150.0, range: 267...778)
  static let Heater_system = (basis: 200.0, c1: 4_000_000.0, exp: 0.4, c2: 211728.735839637, factor: 0.9, coeff: 3_500_000.0, range: 200.0...400.0)
  static let Thermal_energy_storage = (basis: 26920.0, c1: 2_000_000.0, exp: 0.75, c2: 1908.888181, factor: 0.55, coeff: 26_000_000.0)
  static let Electrolysis_coeff = 840_000.0
  static let Hydrogen_storage = (basis: 60.0, coeff: 936_000.0)
  static let Methanol_plant_coeff = 5_865_366.0
  static let Power_Block = (basis: 50.0, c1: 84_370_000.0, coeff: 466_229.0, range: 50.0...200.0)
  static let Battery_energy_storage = (basis: 50.0, c1: 5_317_746.0, coeff: 319_065.0)
  static let Electrical_boiler_capacity = (basis: 3.27, exp: 0.7, coeff: 262_862.0)
  static let Substation_capacity = (basis: 135.0, exp: 0.7, coeff: 17_778.0)
 
  static func invest(_ model: SunOl) -> [Double] {
    let factor = min(model.Heat_to_aux_directly_from_CSP_sum + model.Heat_to_aux_from_PB_sum * Float(model.PB_Ratio_Heat_input_vs_output),
     model.Q_solar_before_dumping_sum - model.Total_SF_heat_dumped_sum - model.TES_thermal_input_by_CSP_sum)

    var auxLoops = model.CSP_Loop_Nr > 0 ?
     min(model.CSP_Loop_Nr, Double(Float(model.CSP_Loop_Nr) * factor / model.Q_solar_before_dumping_sum)) : 0
    if (auxLoops <= 0 || factor <= 0) {
      auxLoops = 0
    }
    let Assembly_hall = 12_000_000.0 + (-132.967033 * Double(model.CSP_Loop_Nr) ** 2 + 62978.02 * Double(model.CSP_Loop_Nr) + -2.32831E-10)
		
    
    let CSP_SF_cost_dedicated_to_ICPH =
      Solar_field.coeff * ((model.CSP_Loop_Nr - auxLoops) / Solar_field.basis) ** Solar_field.exp + Solar_field.c1 * Solar_field.f
      * (model.CSP_Loop_Nr - auxLoops)

    var aux_Heat_ratio = Double(model.meth_plant_heatConsumption_sum / (model.meth_plant_heatConsumption_sum + model.EY_aux_heatConsumption_sum))
    if aux_Heat_ratio.isNaN { aux_Heat_ratio = 0 }
    let CSP_SF_cost_dedicated_to_Hydrogen = Solar_field.coeff * ((model.CSP_Loop_Nr - auxLoops * aux_Heat_ratio) / Solar_field.basis) ** Solar_field.exp + Solar_field.c1 * Solar_field.f
      * (model.CSP_Loop_Nr - auxLoops * aux_Heat_ratio)
    
    let CSP_SF_cost_dedicated_to_Methanol = Solar_field.coeff * (model.CSP_Loop_Nr / Solar_field.basis) ** Solar_field.exp + Solar_field.c1 * Solar_field.f
      * model.CSP_Loop_Nr
    let CSP_SF_cost_dedicated_to_aux_heat = AdditionalCostPerLoop * auxLoops

    let PV_DC_Cost = model.PV_DC_Cap * PV_DC_part.coeff + 0.0
    let PV_AC_Cost = (model.PV_AC_Cap / PV_AC_part.basis) ** PV_AC_part.exp * PV_AC_part.basis * PV_AC_part.coeff + 0.0

    let Heater_Cost = model.Heater_cap > 0 ?
      (Heater_system.c1 + Heater_system.coeff * (model.Heater_cap / Heater_system.basis) ** Heater_system.exp + model.Heater_cap
      * Heater_system.factor * Heater_system.c2) : 0

    var TES_Storage_cost =
      Thermal_energy_storage.c1 + Thermal_energy_storage.coeff * (model.TES_salt_mass / Thermal_energy_storage.basis) ** Thermal_energy_storage.exp
      + model.TES_salt_mass * Thermal_energy_storage.c2 * Thermal_energy_storage.factor
    if TES_Storage_cost.isNaN { TES_Storage_cost = 0 }
    let Electrolysis_Cost = model.EY_Nominal_elec_input * Electrolysis_coeff + 0.0

    let PB_Cost = model.PB_Nominal_gross_cap > 0 ? (Power_Block.c1 + (model.PB_Nominal_gross_cap - Power_Block.basis) * Power_Block.coeff) : 0

    let Battery_storage_cost = model.BESS_cap * Battery_energy_storage.coeff + (model.BESS_cap > 0 ? Battery_energy_storage.c1 : 0)

    let Hydrogen_Storage_cost = model.H2_storage_cap * Hydrogen_storage.coeff + 0.0

    let Methanol_plant_cost = model.Meth_nominal_hourly_prod_cap * Methanol_plant_coeff + 0.0

    let Electrical_boiler_cost = model.El_boiler_cap > 0 ?
      (Electrical_boiler_capacity.coeff * Electrical_boiler_capacity.basis * (model.El_boiler_cap / Electrical_boiler_capacity.basis)
      ** Electrical_boiler_capacity.exp) : 0

    let Substation_cost_ICPH =
      Substation_capacity.coeff * Substation_capacity.basis * ((model.Heater_cap + model.EY_Nominal_elec_input  + model.EY_aux_elec_input + model.Meth_nominal_aux_electr_cons) / Substation_capacity.basis) ** Substation_capacity.exp

    let Substation_cost =
      Substation_capacity.coeff * Substation_capacity.basis * (max(model.grid_max_export, model.grid_max_import) / Substation_capacity.basis) ** Substation_capacity.exp

    let CSP_O_M_Cost = (11.3333 / 3 * 1 / 3 * 1000 * 1000) + (0.00606061 / 3 * 1 / 3 * 1000 * 1000) * model.CSP_Loop_Nr
    let PV_O_M_Cost = (11.3333 * 1000 * 1000) + 0 * model.PV_DC_Cap
    let PB_O_M_Cost = (11.3333 / 3 * 2 / 3 * 1000 * 1000) + (0.00606061 / 3 * 2 / 3 * 1000 * 1000) * model.PB_Nominal_gross_cap

    let CAPEX_ICPH_assembly_hall_csp_sf_dedicated_to_ICPH_PC_DC_PV_AC_Heaters_TES_PB_Substation =
      Assembly_hall + CSP_SF_cost_dedicated_to_ICPH + PV_DC_Cost + PV_AC_Cost + Heater_Cost + TES_Storage_cost + PB_Cost + Substation_cost_ICPH

    let CAPEX_aux_thermal_energy_csp_sf_cost_dedicated_to_aux_heat = CSP_SF_cost_dedicated_to_aux_heat

    let CAPEX_Hydrogen_ICPH_half_of_loops_dedicated_to_aux_heat_electrolysis_half_of_electrical_boiler_cost =
      Assembly_hall + CSP_SF_cost_dedicated_to_Hydrogen + PV_DC_Cost + PV_AC_Cost + Heater_Cost
      + TES_Storage_cost + PB_Cost + (Electrical_boiler_cost * aux_Heat_ratio) + Substation_cost + Electrolysis_Cost

    let Total_CAPEX =
      Assembly_hall + CSP_SF_cost_dedicated_to_Methanol + PV_DC_Cost + PV_AC_Cost + Heater_Cost + TES_Storage_cost
      + Electrolysis_Cost + PB_Cost + Battery_storage_cost + Hydrogen_Storage_cost + Methanol_plant_cost + Electrical_boiler_cost + Substation_cost

    let Total_OPEX = CSP_O_M_Cost + PV_O_M_Cost + PB_O_M_Cost

    let Y = 25.0
    let R = 0.07
    let FCR = R * (1 + R) ** Y / ((1 + R) ** Y - 1)
    let BUY = 2 * 0.091
    let SELL = 0.33 * 0.091

    let LCH2 =
      (FCR * CAPEX_Hydrogen_ICPH_half_of_loops_dedicated_to_aux_heat_electrolysis_half_of_electrical_boiler_cost + Total_OPEX
        + Double(model.elec_from_grid_sum) * BUY * 1000 - Double(model.elec_to_grid_sum) * SELL * 1000) / Double(model.H2_to_meth_production_effective_MTPH_sum)
        
    let LCoM =
      (FCR * Total_CAPEX + Total_OPEX + Double(model.elec_from_grid_sum) * BUY * 1000 - Double(model.elec_to_grid_sum) * SELL * 1000)
      / Double(model.meth_produced_MTPH_sum)

    let LCoE =
      (FCR * CAPEX_ICPH_assembly_hall_csp_sf_dedicated_to_ICPH_PC_DC_PV_AC_Heaters_TES_PB_Substation + Total_OPEX) / Double(model.avail_total_net_elec_sum - model.net_elec_above_max_consumers_sum)

    var LCoTh =
      (FCR * CAPEX_aux_thermal_energy_csp_sf_cost_dedicated_to_aux_heat) 
      / Double(model.Produced_thermal_energy_sum)
    if LCoTh.isNaN { LCoTh = 0 }
    return [
      (Total_CAPEX * 100).rounded() / 100, Double(model.H2_to_meth_production_effective_MTPH_sum),
      (LCoE * 100).rounded() / 100, (LCoTh * 100).rounded() / 100, (LCH2 * 100).rounded() / 100,
      (LCoM * 1000).rounded() / 1000, Double(model.PB_startup_heatConsumption_effective_count),
      Double(model.TES_discharge_effective_count), Double(model.EY_plant_start_count),
      Double(model.gross_operating_point_of_EY_count), Double(model.meth_plant_start_count),
      Double(model.H2_to_meth_production_effective_MTPH_count),
      Double(model.aux_elec_missing_due_to_grid_limit_sum)
    ]
  }
}
